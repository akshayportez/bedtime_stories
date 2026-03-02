part of 'package:bedtime_stories/utils/lib_files.dart';

double _clampPercentageValue(double value) {
  if (value < 0) return 0;
  if (value > 100) return 100;
  return value;
}

String _clampPercentageText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return "";

  final parsed = double.tryParse(trimmed);
  if (parsed == null) return trimmed;

  final clamped = _clampPercentageValue(parsed);
  if (clamped == clamped.truncateToDouble()) {
    return clamped.toStringAsFixed(0);
  }

  return clamped
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

TextInputFormatter _percentageLimit100InputFormatter() {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    // Allow intermediate decimal input like "." while user is typing.
    if (text == ".") {
      return newValue;
    }

    final parsed = double.tryParse(text);
    if (parsed == null) {
      return oldValue;
    }

    if (parsed <= 100) {
      return newValue;
    }

    const clampedText = "100";
    return const TextEditingValue(
      text: clampedText,
      selection: TextSelection.collapsed(offset: 3),
    );
  });
}

TextInputFormatter _currencyTwoDecimalInputFormatter() {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(text)) {
      return oldValue;
    }

    // Allow intermediate decimal input like "." while user is typing.
    if (text == ".") {
      return newValue;
    }

    return newValue;
  });
}

class CreateRequestPage extends StatefulWidget {
  final bool isEditMode;
  final BedtimePaymentRequest? initialRequest;
  final BedtimePaymentRequestDetail? initialDetail;
  final List<BedtimePaymentRequestTax> initialTaxes;

  const CreateRequestPage({
    super.key,
    this.isEditMode = false,
    this.initialRequest,
    this.initialDetail,
    this.initialTaxes = const [],
  });

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  static const double _taxHeaderHeight = 30;
  static const double _taxRowHeight = 34;

  bool isTdsChecked = false;
  bool isTaxableChecked = false;
  int? _selectedAccountId;
  int? _selectedCategoryId;
  int? _selectedSectionId;
  final TextEditingController _requestedAmountController =
      TextEditingController();
  final TextEditingController _tdsRateController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  int _selectedProjectId = 0;
  int _editingPayReqId = 0;
  String _editingStatus = "Requested";
  int _uploadCounter = 0;
  bool _isSaving = false;
  bool _isPreparingUploadFile = false;
  bool _isSuccessDialogVisible = false;
  String? _accountInlineError;
  String? _categoryInlineError;
  String? _sectionInlineError;
  String? _requestedAmountInlineError;
  String? _tdsInlineError;
  String? _taxInlineError;
  final List<_CreateRequestUploadItem> _uploadItems = [];
  final Set<String> _resolvingRemoteUploadSizeIds = <String>{};
  final Set<String> _remoteUploadSizeResolutionAttemptedIds = <String>{};

  final List<String> taxOptions = [];
  final Map<String, String> taxRates = {};
  final Map<String, int> _taxIdByName = {};
  List<Map<String, String>> taxList = [
    {"name": "", "rate": ""},
  ];
  final List<TextEditingController> _taxRateControllers = [
    TextEditingController(),
  ];

  String get _defaultTaxName => taxOptions.isNotEmpty ? taxOptions.first : "";

  String _defaultTaxRate() =>
      _clampPercentageText(taxRates[_defaultTaxName] ?? "");

  List<String> _availableTaxOptionsForRow(int index) {
    final currentTaxName = index >= 0 && index < taxList.length
        ? (taxList[index]["name"] ?? "").trim()
        : "";

    final selectedInOtherRows = <String>{};
    for (int i = 0; i < taxList.length; i++) {
      if (i == index) continue;
      final name = (taxList[i]["name"] ?? "").trim();
      if (name.isNotEmpty) {
        selectedInOtherRows.add(name);
      }
    }

    return taxOptions
        .where(
          (taxName) =>
              taxName == currentTaxName || !selectedInOtherRows.contains(taxName),
        )
        .toList();
  }

  void _mergeTaxOptionsFromApi(List<BedtimeGetTaxList> taxes) {
    for (final tax in taxes) {
      if (tax.cTaxName.isNotEmpty && !taxOptions.contains(tax.cTaxName)) {
        taxOptions.add(tax.cTaxName);
      }
      if (tax.cTaxName.isNotEmpty) {
        _taxIdByName[tax.cTaxName] = tax.nTaxId;
      }
    }
  }

  void _onTaxNameChanged(int index, String? selectedTax) {
    if (selectedTax == null) return;
    setState(() {
      final rate = _clampPercentageText(taxRates[selectedTax] ?? "");
      taxList[index]["name"] = selectedTax;
      taxList[index]["rate"] = rate;
      _taxRateControllers[index].text = taxList[index]["rate"] ?? "";
      if (_taxInlineError != null && _hasValidTaxSelection()) {
        _taxInlineError = null;
      }
    });
  }

  void _onTaxRateChanged(int index, String value) {
    final typedValue = value.trim();
    final parsedValue = typedValue.isEmpty ? null : double.tryParse(typedValue);
    final normalizedValue = parsedValue != null && parsedValue > 100
        ? "100"
        : typedValue;
    setState(() {
      taxList[index]["rate"] = normalizedValue;
      if (normalizedValue != typedValue) {
        _taxRateControllers[index].value = TextEditingValue(
          text: normalizedValue,
          selection: TextSelection.collapsed(offset: normalizedValue.length),
        );
      }
      if (_taxInlineError != null && _hasValidTaxSelection()) {
        _taxInlineError = null;
      }
    });
  }

  void _addTaxRow() {
    if (taxList.isNotEmpty) {
      final lastTax = taxList.last;
      final lastTaxName = (lastTax["name"] ?? "").trim();
      final lastTaxId = _taxIdByName[lastTaxName] ?? 0;
      final lastTaxRate = _parseNumber(lastTax["rate"] ?? "");

      if (lastTaxId <= 0 || lastTaxRate <= 0) {
        setState(() {
          _taxInlineError = "Please select tax and enter tax rate";
        });
        return;
      }
    }

    setState(() {
      _taxInlineError = null;
      final selectedTaxNames = taxList
          .map((tax) => (tax["name"] ?? "").trim())
          .where((name) => name.isNotEmpty)
          .toSet();
      final nextAvailableTax = taxOptions.firstWhere(
        (taxName) => !selectedTaxNames.contains(taxName),
        orElse: () => "",
      );

      if (nextAvailableTax.isEmpty) {
        _taxInlineError = "All taxes are already added";
        return;
      }

      taxList.add({"name": "", "rate": ""});
      _taxRateControllers.add(TextEditingController());
    });
  }

  void _removeTaxRow(int index) {
    setState(() {
      if (taxList.length <= 1) {
        taxList[index]["name"] = "";
        taxList[index]["rate"] = "";
        _taxRateControllers[index].clear();
        _taxInlineError = null;
        return;
      }

      _taxRateControllers[index].dispose();
      _taxRateControllers.removeAt(index);
      taxList.removeAt(index);
      if (_taxInlineError != null && _hasValidTaxSelection()) {
        _taxInlineError = null;
      }
    });
  }

  String _formatRate(double rate) {
    if (rate == rate.truncateToDouble()) return rate.toStringAsFixed(0);
    final withTwo = rate.toStringAsFixed(2);
    return withTwo
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _formatPercentageRate(double rate) {
    return _formatRate(_clampPercentageValue(rate));
  }

  void _applyAccountTaxAndTds(BedtimeGetAccountsList account) {
    isTdsChecked = account.bTDS;
    _tdsRateController.text = _formatPercentageRate(account.nTDSPercent);
    _tdsInlineError = null;
    _taxInlineError = null;
    taxRates.clear();

    if (account.taxDetails.isNotEmpty) {
      isTaxableChecked = true;

      for (final controller in _taxRateControllers) {
        controller.dispose();
      }
      _taxRateControllers.clear();
      taxList = account.taxDetails
          .map(
            (tax) => {
              "name": tax.cTaxName,
              "rate": _formatPercentageRate(tax.nTaxRate),
            },
          )
          .toList();
      for (int i = 0; i < taxList.length; i++) {
        final tax = taxList[i];
        final detail = account.taxDetails[i];
        final name = tax["name"] ?? "";
        final rate = tax["rate"] ?? "";
        if (name.isNotEmpty && !taxOptions.contains(name)) {
          taxOptions.add(name);
        }
        if (name.isNotEmpty) {
          taxRates[name] = rate;
          _taxIdByName[name] = detail.nTaxId;
        }
        _taxRateControllers.add(TextEditingController(text: rate));
      }
      return;
    }

    isTaxableChecked = false;
    for (final controller in _taxRateControllers) {
      controller.dispose();
    }
    _taxRateControllers
      ..clear()
      ..add(TextEditingController(text: _defaultTaxRate()));
    taxList = [
      {"name": _defaultTaxName, "rate": _defaultTaxRate()},
    ];
  }

  double _parseNumber(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(sanitized) ?? 0;
  }

  double _roundCurrencyValue(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  double _parsePercentage(String value) {
    return _clampPercentageValue(_parseNumber(value));
  }

  String _formatCurrency(double value) => "₹${value.toStringAsFixed(2)}";

  double get _requestedAmount =>
      _roundCurrencyValue(_parseNumber(_requestedAmountController.text));

  double get _tdsRate => _parsePercentage(_tdsRateController.text);

  double get _tdsAmount {
    if (!isTdsChecked) return 0;
    return _roundCurrencyValue(_requestedAmount * _tdsRate / 100);
  }

  double get _totalTaxAmount {
    if (!isTaxableChecked) return 0;
    final total = taxList.fold<double>(0, (sum, tax) {
      final rate = _parsePercentage(tax["rate"] ?? "");
      return sum + (_requestedAmount * rate / 100);
    });
    return _roundCurrencyValue(total);
  }

  double get _payableAmount =>
      _roundCurrencyValue(_requestedAmount - _tdsAmount + _totalTaxAmount);

  String get _attachmentValueForSave => _uploadItems
      .where((item) => item.attachmentPath.isNotEmpty)
      .map((item) => item.attachmentPath)
      .join(",");

  bool _hasValidTaxSelection() {
    if (!isTaxableChecked) return true;

    for (final tax in taxList) {
      final taxName = (tax["name"] ?? "").trim();
      final taxId = _taxIdByName[taxName] ?? 0;
      final taxRate = _parsePercentage(tax["rate"] ?? "");
      if (taxId > 0 && taxRate > 0) return true;
    }
    return false;
  }

  bool _validateTdsAndTaxInline() {
    final tdsError = isTdsChecked && _tdsRate <= 0
        ? "Please enter TDS percentage"
        : null;
    final taxError = isTaxableChecked && !_hasValidTaxSelection()
        ? "Please select tax and enter tax rate"
        : null;

    setState(() {
      _tdsInlineError = tdsError;
      _taxInlineError = taxError;
    });

    return tdsError == null && taxError == null;
  }

  bool _validatePrimaryRequiredFieldsInline() {
    final accountError =
        _selectedAccountId == null ? "This field is required" : null;
    final categoryError =
        _selectedCategoryId == null ? "This field is required" : null;
    final sectionError =
        _selectedSectionId == null ? "This field is required" : null;
    final amountError = _requestedAmount <= 0 ? "This field is required" : null;

    setState(() {
      _accountInlineError = accountError;
      _categoryInlineError = categoryError;
      _sectionInlineError = sectionError;
      _requestedAmountInlineError = amountError;
    });

    return accountError == null &&
        categoryError == null &&
        sectionError == null &&
        amountError == null;
  }

  @override
  void initState() {
    super.initState();
    _applyInitialDataForEdit();
    _loadSelectedProject();
    context.read<BedtimeGetAccountsListBloc>().add(
      BedtimeGetAccountsListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetTaxListBloc>().add(
      BedtimeGetTaxListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetCategoryListBloc>().add(
      BedtimeGetCategoryListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetSectionListBloc>().add(
      BedtimeGetSectionListLoadRequested(companyId: 1),
    );
  }

  void _applyInitialDataForEdit() {
    if (!widget.isEditMode) return;

    final request = widget.initialRequest;
    final detail = widget.initialDetail;

    _editingPayReqId = detail?.nPayReqId ?? request?.nPayReqId ?? 0;
    _editingStatus = (detail?.cStatus ?? request?.cStatus ?? "Requested")
        .trim();

    _selectedAccountId = detail?.nAccountId ?? request?.nAccountId;
    _selectedCategoryId = detail?.nCategoryId ?? request?.nCategoryId;
    _selectedSectionId = detail?.nSectionId ?? request?.nSectionId;
    _selectedProjectId = detail?.nProjectId ?? 0;

    final requestedAmount =
        detail?.nRequestedAmount ?? request?.nPayableAmount ?? 0;
    _requestedAmountController.text = requestedAmount > 0
        ? _formatRate(requestedAmount)
        : "";

    isTdsChecked = detail?.bTDS ?? false;
    _tdsRateController.text = _formatPercentageRate(detail?.nTDSPercent ?? 0);
    isTaxableChecked = detail?.bTaxable ?? false;
    _commentController.text = detail?.cComment ?? "";

    for (final controller in _taxRateControllers) {
      controller.dispose();
    }
    _taxRateControllers.clear();
    taxList.clear();

    if (isTaxableChecked && widget.initialTaxes.isNotEmpty) {
      for (final tax in widget.initialTaxes) {
        final taxName = tax.cTaxName.trim();
        final taxRate = _formatPercentageRate(tax.nTaxRate);
        if (taxName.isNotEmpty && !taxOptions.contains(taxName)) {
          taxOptions.add(taxName);
        }
        if (taxName.isNotEmpty) {
          taxRates[taxName] = taxRate;
          _taxIdByName[taxName] = tax.nTaxId;
        }
        taxList.add({"name": taxName, "rate": taxRate});
        _taxRateControllers.add(TextEditingController(text: taxRate));
      }
    } else {
      taxList.add({"name": "", "rate": ""});
      _taxRateControllers.add(TextEditingController());
    }

    final existingAttachments = (detail?.cAttachment ?? "")
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    for (final path in existingAttachments) {
      final name = path.split(RegExp(r"[\\\\/]")).last;
      _uploadItems.add(
        _CreateRequestUploadItem(
          localId: "existing_${_uploadCounter++}",
          filePath: "",
          fileName: name.isEmpty ? path : name,
          fileSizeBytes: 0,
          progress: 1,
          isUploading: false,
          isUploaded: true,
          attachmentPath: path,
          errorMessage: "",
        ),
      );
    }
  }

  Future<void> _loadSelectedProject() async {
    if (_selectedProjectId > 0) return;
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    if (!mounted) return;
    setState(() {
      _selectedProjectId = projectId;
    });
  }

  Future<void> _showSaveSuccessDialog() async {
    if (_isSuccessDialogVisible) return;
    _isSuccessDialogVisible = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFEFEFEF),
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            // width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/succesfull_animation.gif",
                  width: 76,
                  height: 76,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                const Text(
                  "Successful",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Payment Request Submitted Successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _requestedAmountController.dispose();
    _tdsRateController.dispose();
    _commentController.dispose();
    for (final controller in _taxRateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BedtimeGetTaxListBloc, BedtimeGetTaxListState>(
          listener: (context, state) {
            if (state is BedtimeGetTaxListLoaded) {
              setState(() {
                _mergeTaxOptionsFromApi(state.taxes);
                if (isTaxableChecked &&
                    taxList.length == 1 &&
                    (taxList.first["name"] ?? "").isEmpty &&
                    taxOptions.isNotEmpty) {
                  taxList[0]["name"] = _defaultTaxName;
                  taxList[0]["rate"] = _defaultTaxRate();
                  _taxRateControllers[0].text = taxList[0]["rate"] ?? "";
                }
              });
            }
          },
        ),
        BlocListener<
          BedtimePaymentRequestUploadBloc,
          BedtimePaymentRequestUploadState
        >(
          listener: (context, state) {
            if (state is BedtimePaymentRequestUploading) {
              _updateUploadProgress(state.localId, state.progress);
            } else if (state is BedtimePaymentRequestUploadSuccess) {
              _markUploadSuccess(state.localId, state.response.cAttachment);
            } else if (state is BedtimePaymentRequestUploadFailure) {
              _markUploadFailed(state.localId, state.message);
            }
          },
        ),
        BlocListener<
          BedtimePaymentRequestSaveBloc,
          BedtimePaymentRequestSaveState
        >(
          listener: (context, state) async {
            if (state is BedtimePaymentRequestSaving) {
              if (!mounted) return;
              setState(() => _isSaving = true);
              return;
            }

            if (state is BedtimePaymentRequestSaveFailure) {
              if (!mounted) return;
              setState(() => _isSaving = false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              return;
            }

            if (state is BedtimePaymentRequestSaveSuccess) {
              if (!mounted) return;
              setState(() => _isSaving = false);

              final rootNavigator = Navigator.of(context, rootNavigator: true);
              unawaited(
                Future<void>.delayed(const Duration(seconds: 2), () {
                  if (!rootNavigator.mounted) return;
                  if (rootNavigator.canPop()) {
                    rootNavigator.pop();
                  }
                }),
              );
              await _showSaveSuccessDialog();
              _isSuccessDialogVisible = false;

              final userData = await BedtimeLocalStorage.getUserData();
              final companyId = _resolveInt(userData["companyId"], fallback: 1);
              final userActionId = _resolveInt(userData["userId"]);

              if (!context.mounted) return;
              context.read<BedtimePaymentRequestBloc>().add(
                BedtimePaymentRequestLoadRequested(
                  companyId: companyId,
                  projectId: _selectedProjectId,
                  userActionId: userActionId,
                ),
              );
              BedtimeLocalStorage.notifyPaymentDataChanged();
              Navigator.pop(context, true);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,

        /// AppBar
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Request",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: Colors.black,
            ),
          ),
        ),

        /// Body Scroll
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 170),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isEditMode && widget.initialRequest != null) ...[
                Row(
                  children: [
                    Text(
                      "Req No : ${widget.initialRequest!.cRequestNo}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.initialRequest!.cRequestDateTime ?? "",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF242424),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              /// Dropdown Fields
              _accountDropdownField(),
              const SizedBox(height: 12),
              _categoryDropdownField(),
              const SizedBox(height: 12),
              _sectionDropdownField(),

              const SizedBox(height: 16),

              /// Requested Amount + TDS
              _requiredFieldLabel("Requested Amount", fontSize: 12),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputBox(
                          hint: "",
                          controller: _requestedAmountController,
                          onChanged: (_) {
                            setState(() {
                              if (_requestedAmountInlineError != null &&
                                  _requestedAmount > 0) {
                                _requestedAmountInlineError = null;
                              }
                            });
                          },
                          inputFormatters: [
                            _currencyTwoDecimalInputFormatter(),
                          ],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        if (_requestedAmountInlineError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _requestedAmountInlineError!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isTdsChecked = !isTdsChecked;
                                if (!isTdsChecked) {
                                  _tdsRateController.clear();
                                  _tdsInlineError = null;
                                }
                              });
                            },
                            child: _CreateRequestBlueCheckBox(
                              isChecked: isTdsChecked,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "TDS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isTdsChecked
                                      ? const Color(0xFFCCDDEB)
                                      : const Color(0xFFE2E2E2),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 46,
                                      child: TextField(
                                        controller: _tdsRateController,
                                        onChanged: isTdsChecked
                                            ? (value) {
                                                setState(() {
                                                  if (_tdsInlineError != null &&
                                                      _parseNumber(value) > 0) {
                                                    _tdsInlineError = null;
                                                  }
                                                });
                                              }
                                            : null,
                                        enabled: isTdsChecked,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: [
                                          _percentageLimit100InputFormatter(),
                                        ],
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          hintText: "",
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "%",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isTdsChecked
                                            ? Colors.black
                                            : const Color(0xFFBDBDBD),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_tdsInlineError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _tdsInlineError!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Taxable Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    isTaxableChecked = !isTaxableChecked;
                    if (!isTaxableChecked) {
                      _taxInlineError = null;
                    }
                    if (isTaxableChecked && taxList.isEmpty) {
                      final defaultTax = _defaultTaxName;
                      final defaultRate = _defaultTaxRate();
                      taxList = [
                        {
                          "name": defaultTax,
                          "rate": defaultRate,
                        },
                      ];
                      _taxRateControllers.add(
                        TextEditingController(text: defaultRate),
                      );
                    }
                  });
                },
                child: Row(
                  children: [
                    _CreateRequestBlueCheckBox(isChecked: isTaxableChecked),
                    const SizedBox(width: 6),
                    const Text("Taxable", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              /// Tax Table
              if (isTaxableChecked) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF98D5F9)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: _taxHeaderHeight,
                              color: const Color(0xFFBBE3FA),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        "Tax Name",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    color: Color(0xFF98D5F9),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        "Tax Rate %",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...taxList.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final Map<String, String> tax = entry.value;
                              final selectedTaxName =
                                  (tax["name"] ?? "").trim();
                              final availableTaxNames =
                                  _availableTaxOptionsForRow(index);
                              return Container(
                                height: _taxRowHeight,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF98D5F9)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value:
                                                selectedTaxName.isNotEmpty &&
                                                    availableTaxNames.contains(
                                                      selectedTaxName,
                                                    )
                                                ? selectedTaxName
                                                : null,
                                            isExpanded: true,
                                            dropdownColor: Colors.white,
                                            hint: const Text(
                                              "Select Tax",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF7F7F7F),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.chevron_right,
                                              size: 20,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            items: availableTaxNames
                                                .map(
                                                  (taxName) => DropdownMenuItem(
                                                    value: taxName,
                                                    child: Text(taxName),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) =>
                                                _onTaxNameChanged(index, val),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(
                                      width: 1,
                                      thickness: 1,
                                      color: Color(0xFF98D5F9),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _taxRateControllers[index],
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                inputFormatters: [
                                                  _percentageLimit100InputFormatter(),
                                                ],
                                                onChanged: (value) =>
                                                    _onTaxRateChanged(
                                                      index,
                                                      value,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                      isDense: true,
                                                      hintText: "0",
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      focusedErrorBorder:
                                                          InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      filled: false,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              "%",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        const SizedBox(height: _taxHeaderHeight + 1),
                        ...taxList.asMap().entries.map(
                          (entry) => SizedBox(
                            height: _taxRowHeight,
                            child: Row(
                              children: [
                                Center(
                                  child: GestureDetector(
                                    onTap: () => _removeTaxRow(entry.key),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF4040),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          "assets/icons/delete_icon.png",
                                          width: 22,
                                          height: 22,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (entry.key == taxList.length - 1)
                                  Center(
                                    child: GestureDetector(
                                      onTap: _addTaxRow,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: const Icon(Icons.add, size: 14),
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 22),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_taxInlineError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _taxInlineError!,
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ],
              ],

              const SizedBox(height: 14),

              /// Comment Box
              const Text("Comment", style: TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCCDDEB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: null,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// Upload Box
              _buildUploadSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),

        bottomNavigationBar: _CreateRequestSummaryBar(
          requestedAmount: _formatCurrency(_requestedAmount),
          tds: _formatCurrency(_tdsAmount),
          tax: _formatCurrency(_totalTaxAmount),
          payable: _formatCurrency(_payableAmount),
          saveButtonLabel: widget.isEditMode ? "Save" : "Save",
          isSaving: _isSaving,
          onSave: _onSaveTapped,
        ),
      ),
    );
  }

  /// Dropdown Style Field
  Widget _accountDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            widget.isEditMode
                ? const Text(
                    "Account",
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  )
                : _requiredFieldLabel("Account", fontSize: 13),
            const Spacer(),
            if (!widget.isEditMode)
              GestureDetector(
                onTap: _openAddNewAccountSheet,
                child: const Text(
                  "+ Add New Account",
                  style: TextStyle(fontSize: 13, color: Color(0xFF2E7CF6)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCDDEB)),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child:
              BlocBuilder<
                BedtimeGetAccountsListBloc,
                BedtimeGetAccountsListState
              >(
                builder: (context, state) {
                  if (widget.isEditMode) {
                    final preloadedAccountName =
                        (widget.initialRequest?.cAccountName ?? "").trim();
                    return _buildSearchableDropdownTrigger(
                      hintText: "Select Account",
                      selectedText: preloadedAccountName.isEmpty
                          ? null
                          : preloadedAccountName,
                      onTap: null,
                    );
                  }

                  if (state is BedtimeGetAccountsListLoading) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (state is BedtimeGetAccountsListFailure) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<BedtimeGetAccountsListBloc>().add(
                              BedtimeGetAccountsListLoadRequested(companyId: 1),
                            );
                          },
                          child: const Icon(Icons.refresh, size: 18),
                        ),
                      ],
                    );
                  }

                  if (state is BedtimeGetAccountsListLoaded) {
                    final activeAccounts = state.accounts
                        .where((account) => account.bActive)
                        .toList();
                    final options = activeAccounts
                        .map(
                          (account) => _SearchableDropdownOption(
                            id: account.nAccountId,
                            label: account.cAccountName,
                          ),
                        )
                        .toList();

                    return _buildSearchableDropdownTrigger(
                      hintText: "Select Account",
                      selectedText: _selectedOptionLabel(
                        options,
                        _selectedAccountId,
                      ),
                      onTap: () async {
                        final selectedId = await _showSearchableDropdownSheet(
                          title: "Select Account",
                          options: options,
                          selectedId: _selectedAccountId,
                        );
                        if (!mounted || selectedId == null) return;

                        setState(() {
                          _selectedAccountId = selectedId;
                          _accountInlineError = null;
                          for (final account in activeAccounts) {
                            if (account.nAccountId == selectedId) {
                              _applyAccountTaxAndTds(account);
                              break;
                            }
                          }
                        });
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
        ),
        if (_accountInlineError != null) ...[
          const SizedBox(height: 4),
          Text(
            _accountInlineError!,
            style: const TextStyle(fontSize: 11, color: Colors.red),
          ),
        ],
      ],
    );
  }

  Future<void> _openAddNewAccountSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddNewAccoutnSheet(
          taxOptions: taxOptions,
          taxRates: taxRates,
          taxIdByName: _taxIdByName,
          onAccountCreated: _onAccountCreated,
        );
      },
    );
  }

  Future<void> _onAccountCreated(int accountId) async {
    setState(() {
      _selectedAccountId = accountId;
      _accountInlineError = null;
    });

    final accountsBloc = context.read<BedtimeGetAccountsListBloc>();
    accountsBloc.add(
      BedtimeGetAccountsListLoadRequested(companyId: 1),
    );

    final refreshedState = await accountsBloc.stream.firstWhere(
      (state) =>
          state is BedtimeGetAccountsListLoaded ||
          state is BedtimeGetAccountsListFailure,
    );

    if (!mounted || refreshedState is! BedtimeGetAccountsListLoaded) return;

    BedtimeGetAccountsList? createdAccount;
    for (final account in refreshedState.accounts) {
      if (account.nAccountId == accountId) {
        createdAccount = account;
        break;
      }
    }
    if (createdAccount == null) return;

    setState(() {
      _applyAccountTaxAndTds(createdAccount!);
    });
  }

  /// Dropdown Style Field
  Widget _categoryDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredFieldLabel("Category", fontSize: 13),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCDDEB)),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child:
              BlocBuilder<
                BedtimeGetCategoryListBloc,
                BedtimeGetCategoryListState
              >(
                builder: (context, state) {
                  if (state is BedtimeGetCategoryListLoading) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (state is BedtimeGetCategoryListFailure) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<BedtimeGetCategoryListBloc>().add(
                              BedtimeGetCategoryListLoadRequested(companyId: 1),
                            );
                          },
                          child: const Icon(Icons.refresh, size: 18),
                        ),
                      ],
                    );
                  }

                  if (state is BedtimeGetCategoryListLoaded) {
                    final options = state.categories
                        .where((category) => category.bActive)
                        .map(
                          (category) => _SearchableDropdownOption(
                            id: category.nCategoryId,
                            label: category.cCategoryName,
                          ),
                        )
                        .toList();

                    return _buildSearchableDropdownTrigger(
                      hintText: "Select Category",
                      selectedText: _selectedOptionLabel(
                        options,
                        _selectedCategoryId,
                      ),
                      onTap: () async {
                        final selectedId = await _showSearchableDropdownSheet(
                          title: "Select Category",
                          options: options,
                          selectedId: _selectedCategoryId,
                        );
                        if (!mounted || selectedId == null) return;
                        setState(() {
                          _selectedCategoryId = selectedId;
                          _categoryInlineError = null;
                        });
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
        ),
        if (_categoryInlineError != null) ...[
          const SizedBox(height: 4),
          Text(
            _categoryInlineError!,
            style: const TextStyle(fontSize: 11, color: Colors.red),
          ),
        ],
      ],
    );
  }

  /// Dropdown Style Field
  Widget _sectionDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredFieldLabel("Section", fontSize: 13),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCDDEB)),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child:
              BlocBuilder<
                BedtimeGetSectionListBloc,
                BedtimeGetSectionListState
              >(
                builder: (context, state) {
                  if (state is BedtimeGetSectionListLoading) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (state is BedtimeGetSectionListFailure) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<BedtimeGetSectionListBloc>().add(
                              BedtimeGetSectionListLoadRequested(companyId: 1),
                            );
                          },
                          child: const Icon(Icons.refresh, size: 18),
                        ),
                      ],
                    );
                  }

                  if (state is BedtimeGetSectionListLoaded) {
                    final options = state.sections
                        .where((section) => section.bActive)
                        .map(
                          (section) => _SearchableDropdownOption(
                            id: section.nSectionId,
                            label: section.cSectionName,
                          ),
                        )
                        .toList();

                    return _buildSearchableDropdownTrigger(
                      hintText: "Select Section",
                      selectedText: _selectedOptionLabel(
                        options,
                        _selectedSectionId,
                      ),
                      onTap: () async {
                        final selectedId = await _showSearchableDropdownSheet(
                          title: "Select Section",
                          options: options,
                          selectedId: _selectedSectionId,
                        );
                        if (!mounted || selectedId == null) return;
                        setState(() {
                          _selectedSectionId = selectedId;
                          _sectionInlineError = null;
                        });
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
        ),
        if (_sectionInlineError != null) ...[
          const SizedBox(height: 4),
          Text(
            _sectionInlineError!,
            style: const TextStyle(fontSize: 11, color: Colors.red),
          ),
        ],
      ],
    );
  }

  String? _selectedOptionLabel(
    List<_SearchableDropdownOption> options,
    int? selectedId,
  ) {
    if (selectedId == null) return null;
    for (final option in options) {
      if (option.id == selectedId) return option.label;
    }
    return null;
  }

  Future<int?> _showSearchableDropdownSheet({
    required String title,
    required List<_SearchableDropdownOption> options,
    int? selectedId,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CreateRequestSearchableSelectionSheet(
          title: title,
          options: options,
          selectedId: selectedId,
        );
      },
    );
  }

  Widget _buildSearchableDropdownTrigger({
    required String hintText,
    required String? selectedText,
    required VoidCallback? onTap,
  }) {
    final hasValue = (selectedText ?? "").trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasValue ? selectedText! : hintText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: hasValue ? Colors.black : const Color(0xFF7F7F7F),
              ),
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right, size: 29),
        ],
      ),
    );
  }

  Widget _requiredFieldLabel(String text, {required double fontSize}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: " *",
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  List<Map<String, dynamic>> _buildTaxDetailsForSave() {
    if (!isTaxableChecked) return [];

    return taxList
        .map((tax) {
          final taxName = (tax["name"] ?? "").trim();
          final taxId = _taxIdByName[taxName] ?? 0;
          final taxRate = _parsePercentage(tax["rate"] ?? "");
          return {"nTaxId": taxId, "nTaxRate": taxRate};
        })
        .where((tax) {
          final taxId = tax["nTaxId"] as int;
          final taxRate = (tax["nTaxRate"] as num).toDouble();
          return taxId > 0 && taxRate > 0;
        })
        .toList();
  }

  void _onSaveTapped() async {
    if (_isSaving) return;

    if (_selectedProjectId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a project")));
      return;
    }

    if (!_validatePrimaryRequiredFieldsInline()) {
      return;
    }

    if (!_validateTdsAndTaxInline()) {
      return;
    }

    final hasUploadingItems = _uploadItems.any((item) => item.isUploading);
    if (hasUploadingItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait for file upload to finish")),
      );
      return;
    }

    final taxDtl = _buildTaxDetailsForSave();
    if (isTaxableChecked && taxDtl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select valid tax details")),
      );
      return;
    }

    final userData = await BedtimeLocalStorage.getUserData();
    final companyId = _resolveInt(userData["companyId"], fallback: 1);
    final userActionId = _resolveInt(userData["userId"]);
    final normalizedEditStatus = _editingStatus.trim().toLowerCase();
    final saveStatus = (widget.isEditMode && normalizedEditStatus == "rejected")
        ? "Requested"
        : (_editingStatus.isEmpty ? "Requested" : _editingStatus);

    final payload = <String, dynamic>{
      "nPayReqId": widget.isEditMode ? _editingPayReqId : 0,
      "nAccountId": _selectedAccountId ?? 0,
      "nCategoryId": _selectedCategoryId ?? 0,
      "nSectionId": _selectedSectionId ?? 0,
      "nRequestedAmount": _requestedAmount,
      "bTDS": isTdsChecked,
      "nTDSPercent": isTdsChecked ? _tdsRate : 0,
      "bTaxable": isTaxableChecked,
      "taxDtl": taxDtl,
      "cComment": _commentController.text.trim(),
      "cAttachment": _attachmentValueForSave,
      "cStatus": saveStatus,
      "nProjectId": _selectedProjectId,
      "nCompanyId": companyId,
      "nUserActionId": userActionId,
      "bActive": true,
    };

    if (!mounted) return;
    context.read<BedtimePaymentRequestSaveBloc>().add(
      BedtimePaymentRequestSaveRequested(payload: payload),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    if (_isPreparingUploadFile) return;

    if (_selectedProjectId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a project before uploading files"),
        ),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final uploadBloc = context.read<BedtimePaymentRequestUploadBloc>();
    setState(() => _isPreparingUploadFile = true);

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
      );
      if (pickedFile == null || !mounted) return;

      final localId =
          "${DateTime.now().microsecondsSinceEpoch}_${_uploadCounter++}";
      final fileName = pickedFile.name.isNotEmpty
          ? pickedFile.name
          : pickedFile.path.split(RegExp(r"[\\\\/]")).last;
      final fileSizeBytes = await pickedFile.length();
      if (fileSizeBytes > BedtimeApiConstants.attachmentUploadMaxBytes) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("File size must be 5 MB or less")),
        );
        return;
      }

      setState(() {
        _uploadItems.add(
          _CreateRequestUploadItem(
            localId: localId,
            filePath: pickedFile.path,
            fileName: fileName,
            fileSizeBytes: fileSizeBytes,
            progress: 0,
            isUploading: true,
            isUploaded: false,
            attachmentPath: "",
            errorMessage: "",
          ),
        );
      });

      uploadBloc.add(
        BedtimePaymentRequestUploadRequested(
          companyId: 1,
          projectId: _selectedProjectId,
          localId: localId,
          filePath: pickedFile.path,
          fileName: fileName,
        ),
      );
    } on PlatformException catch (_) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Unable to read the selected file. Please try again."),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while preparing the file."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPreparingUploadFile = false);
      }
    }
  }

  void _updateUploadProgress(String localId, double progress) {
    final index = _uploadItems.indexWhere((item) => item.localId == localId);
    if (index < 0) return;
    if (!mounted) return;

    setState(() {
      final current = _uploadItems[index];
      _uploadItems[index] = current.copyWith(
        progress: progress,
        isUploading: true,
      );
    });
  }

  void _markUploadSuccess(String localId, String attachmentPath) {
    final index = _uploadItems.indexWhere((item) => item.localId == localId);
    if (index < 0) return;
    if (!mounted) return;

    setState(() {
      final current = _uploadItems[index];
      _uploadItems[index] = current.copyWith(
        progress: 1,
        isUploading: false,
        isUploaded: true,
        attachmentPath: attachmentPath,
        errorMessage: "",
      );
    });
  }

  void _markUploadFailed(String localId, String message) {
    final index = _uploadItems.indexWhere((item) => item.localId == localId);
    if (index < 0) return;
    if (!mounted) return;

    setState(() {
      final current = _uploadItems[index];
      _uploadItems[index] = current.copyWith(
        isUploading: false,
        isUploaded: false,
        errorMessage: message,
      );
    });
  }

  void _removeUploadItem(String localId) {
    setState(() {
      _uploadItems.removeWhere((item) => item.localId == localId);
      _resolvingRemoteUploadSizeIds.remove(localId);
      _remoteUploadSizeResolutionAttemptedIds.remove(localId);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 KB";
    if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    return "${(bytes / 1024).toStringAsFixed(0)} KB";
  }

  Future<int> _fetchRemoteFileSizeBytes(String url) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(url);
      var contentLength = 0;

      try {
        final headRequest = await client
            .headUrl(uri)
            .timeout(const Duration(seconds: 6));
        final headResponse = await headRequest.close().timeout(
          const Duration(seconds: 6),
        );
        contentLength = headResponse.contentLength;
        await headResponse.drain<void>();
        if (contentLength > 0) {
          return contentLength;
        }
      } catch (_) {
        // Some servers reject HEAD. Fall back to GET.
      }

      final getRequest = await client.getUrl(uri).timeout(
        const Duration(seconds: 6),
      );
      final getResponse = await getRequest.close().timeout(
        const Duration(seconds: 8),
      );
      contentLength = getResponse.contentLength;
      if (contentLength > 0) {
        await getResponse.drain<void>();
        return contentLength;
      }

      var totalBytes = 0;
      await for (final chunk in getResponse) {
        totalBytes += chunk.length;
      }
      return totalBytes;
    } catch (_) {
      return 0;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _resolveRemoteUploadItemSize(_CreateRequestUploadItem item) async {
    final localId = item.localId;
    if (item.fileSizeBytes > 0 ||
        item.filePath.trim().isNotEmpty ||
        item.attachmentPath.trim().isEmpty ||
        item.isUploading ||
        _remoteUploadSizeResolutionAttemptedIds.contains(localId)) {
      return;
    }

    _remoteUploadSizeResolutionAttemptedIds.add(localId);
    _resolvingRemoteUploadSizeIds.add(localId);

    final imageUrl = _imageUrl(item.attachmentPath);
    final bytes = imageUrl.isEmpty ? 0 : await _fetchRemoteFileSizeBytes(imageUrl);

    if (!mounted) return;

    setState(() {
      _resolvingRemoteUploadSizeIds.remove(localId);

      if (bytes <= 0) return;

      final index = _uploadItems.indexWhere((e) => e.localId == localId);
      if (index < 0) return;

      _uploadItems[index] = _uploadItems[index].copyWith(fileSizeBytes: bytes);
    });
  }

  String _imageUrl(String value) {
    final path = value.trim();
    if (path.isEmpty) return "";
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return path;
    }
    final base = BedtimeApiConstants.baseUrl.endsWith("/")
        ? BedtimeApiConstants.baseUrl.substring(
            0,
            BedtimeApiConstants.baseUrl.length - 1,
          )
        : BedtimeApiConstants.baseUrl;
    final normalizedPath = path.startsWith("/") ? path : "/$path";
    return "$base$normalizedPath";
  }

  void _openImagePreview(_CreateRequestUploadItem item) {
    final localPath = item.filePath.trim();
    final remoteUrl = _imageUrl(item.attachmentPath);
    if (localPath.isEmpty && remoteUrl.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: localPath.isNotEmpty
                      ? Image.file(
                          File(localPath),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Center(
                              child: Text(
                                "Unable to load image",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        )
                      : Image.network(
                          remoteUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) {
                            return const Center(
                              child: Text(
                                "Unable to load image",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   "Choose File",
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Color(0xFF6A42C8),
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            const SizedBox(height: 10),
            _buildUploadPickerCard(),
            if (_uploadItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              ..._uploadItems.map(_buildUploadedItemCard),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildUploadPickerCard() {
    return CustomPaint(
      foregroundPainter: const _DashedRoundedBorderPainter(
        color: Color(0xFFC8B3FF),
        radius: 8,
        strokeWidth: 1.2,
        dashWidth: 1.2,
        dashGap: 3.2,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9FE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: Color(0xFF7A5CF5)),
            const SizedBox(height: 4),
            const Text(
              "Choose files",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "(JPEG, PNG format, up to 5MB)",
              style: TextStyle(fontSize: 10, color: Color(0xFF6F6F6F)),
            ),
            if (_isPreparingUploadFile) ...[
              const SizedBox(height: 8),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Preparing file...",
                    style: TextStyle(fontSize: 11, color: Color(0xFF6F6F6F)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _smallButton(
                  "Camera",
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: const Color(0xFF9F9F9F),
                  onTap: _isPreparingUploadFile
                      ? null
                      : () => _pickAndUpload(ImageSource.camera),
                ),
                const SizedBox(width: 8),
                _smallButton(
                  "Gallery",
                  onTap: _isPreparingUploadFile
                      ? null
                      : () => _pickAndUpload(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedItemCard(_CreateRequestUploadItem item) {
    final progressPercent = (item.progress * 100).round().clamp(0, 100);
    final hasError = item.errorMessage.isNotEmpty;
    final imageUrl = _imageUrl(item.attachmentPath);
    final hasPreview = item.filePath.isNotEmpty || imageUrl.isNotEmpty;
    final shouldResolveRemoteSize =
        item.fileSizeBytes <= 0 &&
        item.filePath.trim().isEmpty &&
        item.attachmentPath.trim().isNotEmpty &&
        !item.isUploading;
    if (shouldResolveRemoteSize) {
      _resolveRemoteUploadItemSize(item);
    }
    final isResolvingSize = _resolvingRemoteUploadSizeIds.contains(item.localId);
    final sizeText = shouldResolveRemoteSize
        ? (isResolvingSize
              ? "Loading..."
              : item.fileSizeBytes > 0
              ? _formatFileSize(item.fileSizeBytes)
              : "-")
        : _formatFileSize(item.fileSizeBytes);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFFFFF4F4) : const Color(0xFFF2F8FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasError ? const Color(0xFFFFCACA) : const Color(0xFFC9DEF5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: hasPreview ? () => _openImagePreview(item) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 34,
                height: 34,
                color: const Color(0xFFEAE2FF),
                alignment: Alignment.center,
                child: item.filePath.isNotEmpty
                    ? Image.file(
                        File(item.filePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.insert_drive_file_outlined,
                          color: Color(0xFF7A5CF5),
                          size: 16,
                        ),
                      )
                    : imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.insert_drive_file_outlined,
                          color: Color(0xFF7A5CF5),
                          size: 16,
                        ),
                      )
                    : const Icon(
                        Icons.insert_drive_file_outlined,
                        color: Color(0xFF7A5CF5),
                        size: 16,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.isUploading) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    minHeight: 3,
                    value: item.progress,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4733C8),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    hasError ? item.errorMessage : sizeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: hasError
                          ? const Color(0xFFD14343)
                          : const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (item.isUploading)
            Text(
              "$progressPercent%",
              style: const TextStyle(fontSize: 11, color: Color(0xFF5F5F5F)),
            )
          else
            GestureDetector(
              onTap: () => _removeUploadItem(item.localId),
              child: Image.asset(
                "assets/icons/image_delete.png",
                width: 19,
                height: 19,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  /// Input Box
  Widget _inputBox({
    required String hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    String? trailingText,
    double trailingSpacing = 4,
    TextAlign textAlign = TextAlign.start,
    Color borderColor = const Color(0xFFCCDDEB),
    Color? trailingTextColor,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: enabled ? onChanged : null,
              enabled: enabled,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textAlign: textAlign,
              textAlignVertical: TextAlignVertical.center,
              minLines: null,
              maxLines: null,
              expands: true,
              decoration:
                  InputDecoration.collapsed(
                    hintText: hint,
                    border: InputBorder.none,
                  ).copyWith(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                  ),
            ),
          ),
          if (trailingText != null) ...[
            SizedBox(width: trailingSpacing),
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 13,
                color: trailingTextColor ?? Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Small Upload Buttons
  Widget _smallButton(
    String text, {
    required VoidCallback? onTap,
    Color backgroundColor = const Color(0xFF25008C),
    Color textColor = Colors.white,
    Color borderColor = const Color(0xFF25008C),
  }) {
    final isEnabled = onTap != null;
    return Opacity(
      opacity: isEnabled ? 1 : 0.6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchableDropdownOption {
  final int id;
  final String label;

  const _SearchableDropdownOption({required this.id, required this.label});
}

class _CreateRequestSearchableSelectionSheet extends StatefulWidget {
  final String title;
  final List<_SearchableDropdownOption> options;
  final int? selectedId;

  const _CreateRequestSearchableSelectionSheet({
    required this.title,
    required this.options,
    required this.selectedId,
  });

  @override
  State<_CreateRequestSearchableSelectionSheet> createState() =>
      _CreateRequestSearchableSelectionSheetState();
}

class _CreateRequestSearchableSelectionSheetState
    extends State<_CreateRequestSearchableSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final query = _searchController.text.trim().toLowerCase();
    final filteredOptions = query.isEmpty
        ? widget.options
        : widget.options
              .where((option) => option.label.toLowerCase().contains(query))
              .toList();

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: 18 + bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: appPrimaryColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/icons/search_icon.svg",
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                      ),
                    ),
                    hintText: "Search",
                    hintStyle: const TextStyle(
                      color: Color(0xFF7F7F7F),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFFC8DFEE),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFFC8DFEE),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredOptions.isEmpty
                    ? const Center(
                        child: Text(
                          "No results found",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredOptions.length,
                        itemBuilder: (context, index) {
                          final option = filteredOptions[index];
                          final isSelected = option.id == widget.selectedId;

                          return GestureDetector(
                            onTap: () => Navigator.pop(context, option.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color.fromRGBO(229, 238, 255, 0.95)
                                    : const Color.fromRGBO(236, 241, 251, 0.91),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF7EA6F1)
                                      : const Color(0xFFB7CBEF),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Color(0xFF174A98),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRequestUploadItem {
  final String localId;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final double progress;
  final bool isUploading;
  final bool isUploaded;
  final String attachmentPath;
  final String errorMessage;

  const _CreateRequestUploadItem({
    required this.localId,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.progress,
    required this.isUploading,
    required this.isUploaded,
    required this.attachmentPath,
    required this.errorMessage,
  });

  _CreateRequestUploadItem copyWith({
    String? localId,
    String? filePath,
    String? fileName,
    int? fileSizeBytes,
    double? progress,
    bool? isUploading,
    bool? isUploaded,
    String? attachmentPath,
    String? errorMessage,
  }) {
    return _CreateRequestUploadItem(
      localId: localId ?? this.localId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      isUploaded: isUploaded ?? this.isUploaded,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth) < metric.length
            ? (distance + dashWidth)
            : metric.length;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

class AddNewAccoutnSheet extends StatefulWidget {
  final List<String> taxOptions;
  final Map<String, String> taxRates;
  final Map<String, int> taxIdByName;
  final ValueChanged<int> onAccountCreated;

  const AddNewAccoutnSheet({
    super.key,
    required this.taxOptions,
    required this.taxRates,
    required this.taxIdByName,
    required this.onAccountCreated,
  });

  @override
  State<AddNewAccoutnSheet> createState() => _AddNewAccoutnSheetState();
}

class _UpperCaseTextInputFormatter extends TextInputFormatter {
  const _UpperCaseTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperCaseText = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upperCaseText,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class _AddNewAccoutnSheetState extends State<AddNewAccoutnSheet> {
  static const double _taxHeaderHeight = 30;
  static const double _taxRowHeight = 34;
  static const int _accountNameMinLength = 3;
  static const int _accountNameMaxLength = 100;
  static const int _shortNameMinLength = 2;
  static const int _shortNameMaxLength = 20;
  static const int _panLength = 10;
  static const int _gstLength = 15;
  static final RegExp _accountNamePattern = RegExp(r"^[A-Za-z0-9 ]+$");
  static final RegExp _shortNamePattern = RegExp(r"^[A-Za-z0-9]+$");
  static final RegExp _panPattern = RegExp(r"^[A-Z0-9]{10}$");
  static final RegExp _gstPattern = RegExp(r"^[A-Z0-9]{15}$");

  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _tdsRateController = TextEditingController();

  bool _isTdsChecked = false;
  bool _isTaxableChecked = false;
  bool _isSaving = false;
  String? _accountNameError;
  String? _shortNameError;
  String? _panError;
  String? _gstError;
  String? _taxInlineError;
  late List<Map<String, String>> _taxList;
  final List<TextEditingController> _taxRateControllers = [];

  String get _defaultTaxName =>
      widget.taxOptions.isNotEmpty ? widget.taxOptions.first : "";

  String _defaultTaxRate() =>
      _clampPercentageText(widget.taxRates[_defaultTaxName] ?? "");

  @override
  void initState() {
    super.initState();
    _taxList = [
      {"name": "", "rate": ""},
    ];
    _taxRateControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _shortNameController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _tdsRateController.dispose();
    for (final controller in _taxRateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTaxNameChanged(int index, String? selectedTax) {
    if (selectedTax == null) return;
    setState(() {
      final rate = _clampPercentageText(widget.taxRates[selectedTax] ?? "");
      _taxList[index]["name"] = selectedTax;
      _taxList[index]["rate"] = rate;
      _taxRateControllers[index].text = _taxList[index]["rate"] ?? "";
      if (_taxInlineError != null && _hasValidTaxSelection()) {
        _taxInlineError = null;
      }
    });
  }

  void _onTaxRateChanged(int index, String value) {
    final typedValue = value.trim();
    final parsedValue = typedValue.isEmpty ? null : double.tryParse(typedValue);
    final normalizedValue = parsedValue != null && parsedValue > 100
        ? "100"
        : typedValue;
    setState(() {
      _taxList[index]["rate"] = normalizedValue;
      if (normalizedValue != typedValue) {
        _taxRateControllers[index].value = TextEditingValue(
          text: normalizedValue,
          selection: TextSelection.collapsed(offset: normalizedValue.length),
        );
      }
      if (_taxInlineError != null && _hasValidTaxSelection()) {
        _taxInlineError = null;
      }
    });
  }

  void _addTaxRow() {
    if (_taxList.isNotEmpty && !_isTaxRowComplete(_taxList.last)) {
      setState(() {
        _taxInlineError = "Please select tax and enter tax rate";
      });
      return;
    }

    setState(() {
      _taxInlineError = null;
      _taxList.add({
        "name": "",
        "rate": "",
      });
      _taxRateControllers.add(
        TextEditingController(),
      );
    });
  }

  void _removeTaxRow(int index) {
    setState(() {
      if (_taxList.length <= 1) {
        _taxList[index]["name"] = "";
        _taxList[index]["rate"] = "";
        _taxRateControllers[index].clear();
        _taxInlineError = null;
        return;
      }

      _taxRateControllers[index].dispose();
      _taxRateControllers.removeAt(index);
      _taxList.removeAt(index);
      if (_taxInlineError != null && _hasValidTaxSelection()) {
        _taxInlineError = null;
      }
    });
  }

  double _parseNumber(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(sanitized) ?? 0;
  }

  double _parsePercentage(String value) {
    return _clampPercentageValue(_parseNumber(value));
  }

  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  bool _isTaxRowComplete(Map<String, String> tax) {
    final taxName = (tax["name"] ?? "").trim();
    final taxId = widget.taxIdByName[taxName] ?? 0;
    final taxRate = _parsePercentage(tax["rate"] ?? "");
    return taxId > 0 && taxRate > 0;
  }

  bool _hasValidTaxSelection() {
    if (!_isTaxableChecked) return true;
    return _taxList.any(_isTaxRowComplete);
  }

  List<Map<String, dynamic>> _buildTaxDetails() {
    if (!_isTaxableChecked) return [];

    return _taxList
        .map((tax) {
          final taxName = (tax["name"] ?? "").trim();
          final taxId = widget.taxIdByName[taxName] ?? 0;
          final taxRate = _parsePercentage(tax["rate"] ?? "");
          return {"nTaxId": taxId, "cTaxName": taxName, "nTaxRate": taxRate};
        })
        .where(
          (tax) => (tax["nTaxId"] as int) > 0 && (tax["nTaxRate"] as double) > 0,
        )
        .toList();
  }

  String? _validateAccountName(String value) {
    if (value.isEmpty) return "Account name is required";
    if (value.length < _accountNameMinLength) {
      return "Account name must be at least $_accountNameMinLength characters";
    }
    if (value.length > _accountNameMaxLength) {
      return "Account name must be at most $_accountNameMaxLength characters";
    }
    if (!_accountNamePattern.hasMatch(value)) {
      return "Special characters are not allowed in account name";
    }
    return null;
  }

  String? _validateShortName(String value) {
    if (value.isEmpty) return "Short name is required";
    if (value.length < _shortNameMinLength) {
      return "Short name must be at least $_shortNameMinLength characters";
    }
    if (value.length > _shortNameMaxLength) {
      return "Short name must be at most $_shortNameMaxLength characters";
    }
    if (!_shortNamePattern.hasMatch(value)) {
      return "Special characters are not allowed in short name";
    }
    return null;
  }

  String? _validatePan(String value) {
    final normalized = _normalizeAlphaNumeric(value);
    if (normalized.isEmpty) return null;
    if (!_panPattern.hasMatch(normalized)) {
      return "PAN must be 10 letters/numbers";
    }
    return null;
  }

  String? _validateGst(String value) {
    final normalized = _normalizeAlphaNumeric(value);
    if (normalized.isEmpty) return null;
    if (!_gstPattern.hasMatch(normalized)) {
      return "GST must be 15 letters/numbers";
    }
    return null;
  }

  String _normalizeAlphaNumeric(String value) {
    return value.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "");
  }

  void _setNormalizedControllerText(
    TextEditingController controller,
    String normalizedValue,
  ) {
    if (controller.text == normalizedValue) return;
    controller.value = TextEditingValue(
      text: normalizedValue,
      selection: TextSelection.collapsed(offset: normalizedValue.length),
    );
  }

  bool _validateInlineFields() {
    final normalizedPan = _normalizeAlphaNumeric(_panController.text.trim());
    final normalizedGst = _normalizeAlphaNumeric(_gstController.text.trim());
    _setNormalizedControllerText(_panController, normalizedPan);
    _setNormalizedControllerText(_gstController, normalizedGst);

    final accountNameError = _validateAccountName(
      _accountNameController.text.trim(),
    );
    final shortNameError = _validateShortName(_shortNameController.text.trim());
    final panError = _validatePan(normalizedPan);
    final gstError = _validateGst(normalizedGst);

    setState(() {
      _accountNameError = accountNameError;
      _shortNameError = shortNameError;
      _panError = panError;
      _gstError = gstError;
    });

    return accountNameError == null &&
        shortNameError == null &&
        panError == null &&
        gstError == null;
  }

  void _onAccountNameChanged(String value) {
    if (_accountNameError == null) return;
    setState(() {
      _accountNameError = _validateAccountName(value.trim());
    });
  }

  void _onShortNameChanged(String value) {
    if (_shortNameError == null) return;
    setState(() {
      _shortNameError = _validateShortName(value.trim());
    });
  }

  void _onPanChanged(String value) {
    final normalized = _normalizeAlphaNumeric(value);
    _setNormalizedControllerText(_panController, normalized);
    if (_panError == null) return;
    setState(() {
      _panError = _validatePan(normalized);
    });
  }

  void _onGstChanged(String value) {
    final normalized = _normalizeAlphaNumeric(value);
    _setNormalizedControllerText(_gstController, normalized);
    if (_gstError == null) return;
    setState(() {
      _gstError = _validateGst(normalized);
    });
  }

  void _saveAccount() async {
    if (_isSaving) return;
    if (!_validateInlineFields()) {
      return;
    }
    final accountName = _accountNameController.text.trim();
    final shortName = _shortNameController.text.trim();
    final panNumber = _normalizeAlphaNumeric(_panController.text.trim());
    final gstNumber = _normalizeAlphaNumeric(_gstController.text.trim());

    final taxDetails = _buildTaxDetails();
    if (_isTaxableChecked && taxDetails.isEmpty) {
      setState(() {
        _taxInlineError = "Please select tax and enter tax rate";
      });
      return;
    }

    final selectedProjectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userData = await BedtimeLocalStorage.getUserData();
    final companyId = _resolveInt(userData["companyId"], fallback: 1);
    final userActionId = _resolveInt(userData["userId"]);

    if (!mounted) return;
    context.read<BedtimeAddAccountBloc>().add(
      BedtimeAddAccountSaveRequested(
        payload: {
          "nAccountId": 0,
          "cAccountName": accountName,
          "cAccountShName": shortName,
          "cPAN": panNumber,
          "cGST": gstNumber,
          "bTDS": _isTdsChecked,
          "nTDSPercent": _isTdsChecked
              ? _parsePercentage(_tdsRateController.text)
              : 0,
          "bTaxable": _isTaxableChecked,
          "nProjectId": selectedProjectId,
          "nUserActionId": userActionId,
          "nCompanyId": companyId,
          "bActive": true,
          "taxDetails": taxDetails,
        },
      ),
    );
  }

  Future<void> _showCenteredSuccessPopup() async {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF22A447),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Account created successfully",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget _fieldLabel(String text, {bool isMandatory = false}) {
    if (!isMandatory) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          const TextSpan(
            text: " *",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineErrorText(String message) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFFCC2B2B),
      ),
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    double? width,
    bool enabled = true,
    String hint = "",
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    double fontSize = 13,
    double hintFontSize = 13,
    double suffixFontSize = 15,
    ValueChanged<String>? onChanged,
    bool hasError = false,
  }) {
    final field = Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasError ? const Color(0xFFCC2B2B) : const Color(0xFFCCDDEB),
        ),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              onChanged: enabled ? onChanged : null,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              minLines: null,
              maxLines: null,
              expands: true,
              style: TextStyle(fontSize: fontSize),
              decoration:
                  InputDecoration.collapsed(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: hintFontSize,
                      color: const Color(0xFFB6B6B6),
                    ),
                  ).copyWith(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                  ),
            ),
          ),
          if (suffixText != null) ...[
            const SizedBox(width: 4),
            Text(
              suffixText,
              style: TextStyle(
                fontSize: suffixFontSize,
                color: const Color(0xFF6F6F6F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    if (width == null) return field;
    return SizedBox(width: width, child: field);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return BlocListener<BedtimeAddAccountBloc, BedtimeAddAccountState>(
      listener: (context, state) async {
        if (state is BedtimeAddAccountSaving) {
          setState(() => _isSaving = true);
          return;
        }

        if (state is BedtimeAddAccountSaveFailure) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          return;
        }

        if (state is BedtimeAddAccountSaveSuccess) {
          setState(() => _isSaving = false);
          await _showCenteredSuccessPopup();
          if (!mounted) return;
          widget.onAccountCreated(state.response.nAccountId);
          Navigator.pop(context);
        }
      },
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 10,
            bottom: 12 + keyboardInset,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Add Account",
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel("Account Name", isMandatory: true),
                    const SizedBox(height: 4),
                    _textInput(
                      controller: _accountNameController,
                      hasError: _accountNameError != null,
                      onChanged: _onAccountNameChanged,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[A-Za-z0-9 ]"),
                        ),
                        LengthLimitingTextInputFormatter(_accountNameMaxLength),
                      ],
                    ),
                    if (_accountNameError != null) ...[
                      const SizedBox(height: 4),
                      _inlineErrorText(_accountNameError!),
                    ],
                    const SizedBox(height: 8),
                    _fieldLabel("Short Name", isMandatory: true),
                    const SizedBox(height: 4),
                    _textInput(
                      controller: _shortNameController,
                      width: 120,
                      hasError: _shortNameError != null,
                      onChanged: _onShortNameChanged,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[A-Za-z0-9]"),
                        ),
                        LengthLimitingTextInputFormatter(_shortNameMaxLength),
                      ],
                    ),
                    if (_shortNameError != null) ...[
                      const SizedBox(height: 4),
                      _inlineErrorText(_shortNameError!),
                    ],
                    const SizedBox(height: 8),
                    _fieldLabel("PAN Number"),
                    const SizedBox(height: 4),
                    _textInput(
                      controller: _panController,
                      hasError: _panError != null,
                      onChanged: _onPanChanged,
                      inputFormatters: [
                        const _UpperCaseTextInputFormatter(),
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[A-Za-z0-9]"),
                        ),
                        LengthLimitingTextInputFormatter(_panLength),
                      ],
                    ),
                    if (_panError != null) ...[
                      const SizedBox(height: 4),
                      _inlineErrorText(_panError!),
                    ],
                    const SizedBox(height: 8),
                    _fieldLabel("GST Number"),
                    const SizedBox(height: 4),
                    _textInput(
                      controller: _gstController,
                      hasError: _gstError != null,
                      onChanged: _onGstChanged,
                      inputFormatters: [
                        const _UpperCaseTextInputFormatter(),
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[A-Za-z0-9]"),
                        ),
                        LengthLimitingTextInputFormatter(_gstLength),
                      ],
                    ),
                    if (_gstError != null) ...[
                      const SizedBox(height: 4),
                      _inlineErrorText(_gstError!),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isTdsChecked = !_isTdsChecked;
                              if (!_isTdsChecked) {
                                _tdsRateController.clear();
                              }
                            });
                          },
                          child: _CreateRequestBlueCheckBox(
                            isChecked: _isTdsChecked,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text("TDS", style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 10),
                        _textInput(
                          controller: _tdsRateController,
                          width: 92,
                          enabled: _isTdsChecked,
                          hint: "0",
                          suffixText: "%",
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            _percentageLimit100InputFormatter(),
                          ],
                          fontSize: 15,
                          hintFontSize: 14,
                          suffixFontSize: 15,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTaxableChecked = !_isTaxableChecked;
                          if (!_isTaxableChecked) {
                            _taxInlineError = null;
                          }
                          if (_isTaxableChecked && _taxList.isEmpty) {
                            _taxList = [
                              {
                                "name": "",
                                "rate": "",
                              },
                            ];
                            _taxRateControllers.add(
                              TextEditingController(),
                            );
                          }
                        });
                      },
                      child: Row(
                        children: [
                          _CreateRequestBlueCheckBox(
                            isChecked: _isTaxableChecked,
                          ),
                          const SizedBox(width: 6),
                          const Text("Taxable", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    if (_isTaxableChecked) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF98D5F9),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: _taxHeaderHeight,
                                    color: const Color(0xFFBBE3FA),
                                    child: Row(
                                      children: const [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              "Tax Name",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        VerticalDivider(
                                          width: 1,
                                          thickness: 1,
                                          color: Color(0xFF98D5F9),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              "Tax Rate %",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ..._taxList.asMap().entries.map((entry) {
                                    final int index = entry.key;
                                    final Map<String, String> tax = entry.value;
                                    return Container(
                                      height: _taxRowHeight,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Color(0xFF98D5F9),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value:
                                                      (tax["name"] ?? "")
                                                              .isNotEmpty &&
                                                          widget.taxOptions
                                                              .contains(
                                                                tax["name"] ??
                                                                    "",
                                                              )
                                                      ? tax["name"]
                                                      : null,
                                                  isExpanded: true,
                                                  dropdownColor: Colors.white,
                                                  hint: const Text(
                                                    "Select Tax",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF7F7F7F),
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.chevron_right,
                                                    size: 20,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black,
                                                  ),
                                                  items: widget.taxOptions
                                                      .map(
                                                        (taxName) =>
                                                            DropdownMenuItem(
                                                              value: taxName,
                                                              child: Text(
                                                                taxName,
                                                              ),
                                                            ),
                                                      )
                                                      .toList(),
                                                  onChanged: (val) =>
                                                      _onTaxNameChanged(
                                                        index,
                                                        val,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            width: 1,
                                            thickness: 1,
                                            color: Color(0xFF98D5F9),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: TextField(
                                                controller:
                                                    _taxRateControllers[index],
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                inputFormatters: [
                                                  _percentageLimit100InputFormatter(),
                                                ],
                                                onChanged: (value) =>
                                                    _onTaxRateChanged(
                                                      index,
                                                      value,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                      isDense: true,
                                                      hintText: "0",
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      focusedErrorBorder:
                                                          InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            children: [
                              const SizedBox(height: _taxHeaderHeight + 1),
                              ..._taxList.asMap().entries.map((entry) {
                                return SizedBox(
                                  height: _taxRowHeight,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _removeTaxRow(entry.key),
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF4040),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              "assets/icons/delete_icon.png",
                                              width: 22,
                                              height: 22,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (entry.key == _taxList.length - 1)
                                        GestureDetector(
                                          onTap: _addTaxRow,
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 14,
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(width: 22),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      if (_taxInlineError != null) ...[
                        const SizedBox(height: 6),
                        _inlineErrorText(_taxInlineError!),
                      ],
                    ],
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 72,
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A8DEB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _isSaving ? null : _saveAccount,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateRequestBlueCheckBox extends StatelessWidget {
  final bool isChecked;

  const _CreateRequestBlueCheckBox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFF0096FB) : Colors.white,
        border: Border.all(color: const Color(0xFF0096FB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}

class _CreateRequestSummaryBar extends StatelessWidget {
  final String requestedAmount;
  final String tds;
  final String tax;
  final String payable;
  final String saveButtonLabel;
  final bool isSaving;
  final VoidCallback onSave;

  const _CreateRequestSummaryBar({
    required this.requestedAmount,
    required this.tds,
    required this.tax,
    required this.payable,
    required this.saveButtonLabel,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final buttonWidth = saveButtonLabel.length > 6 ? 120.0 : 90.0;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F616161),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CreateRequestSummaryRow(
            label: "Requested Amount",
            value: requestedAmount,
          ),
          const SizedBox(height: 4),
          _CreateRequestSummaryRow(
            label: "TDS ",
            labelSuffix: "(Less)",
            labelSuffixColor: const Color(0xFF00B421),
            value: tds,
          ),
          const SizedBox(height: 4),
          _CreateRequestSummaryRow(
            label: "Tax ",
            labelSuffix: "(Add)",
            labelSuffixColor: const Color(0xFFFB0000),
            value: tax,
          ),
          // const Divider(),
          _CreateRequestSummaryRow(
            label: "Payable Amount",
            value: payable,
            isBold: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: buttonWidth,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        saveButtonLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateRequestSummaryRow extends StatelessWidget {
  final String label;
  final String? labelSuffix;
  final Color? labelSuffixColor;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool isBold;

  const _CreateRequestSummaryRow({
    required this.label,
    this.labelSuffix,
    this.labelSuffixColor,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: isBold ? 16 : 12,
                fontWeight:isBold ?  FontWeight.w700 :FontWeight.w500,
                color: labelColor ?? Colors.black,
              ),
              children: [
                TextSpan(text: label),
                if ((labelSuffix ?? "").isNotEmpty)
                  TextSpan(
                    text: labelSuffix,
                    style: TextStyle(
                      color: labelSuffixColor ?? labelColor ?? Colors.black,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
