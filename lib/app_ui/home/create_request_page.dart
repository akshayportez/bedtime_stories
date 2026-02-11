part of 'package:bedtime_stories/utils/lib_files.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  static const double _taxHeaderHeight = 30;
  static const double _taxRowHeight = 34;

  bool isTdsChecked = true;
  bool isTaxableChecked = true;
  int? _selectedAccountId;
  int? _selectedCategoryId;
  int? _selectedSectionId;
  final TextEditingController _requestedAmountController =
      TextEditingController();
  final TextEditingController _tdsRateController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  int _selectedProjectId = 0;
  int _uploadCounter = 0;
  final List<_CreateRequestUploadItem> _uploadItems = [];

  final List<String> taxOptions = [];
  final Map<String, String> taxRates = {};
  List<Map<String, String>> taxList = [
    {"name": "", "rate": ""},
  ];
  final List<TextEditingController> _taxRateControllers = [
    TextEditingController(),
  ];

  String get _defaultTaxName => taxOptions.isNotEmpty ? taxOptions.first : "";

  String _defaultTaxRate() => taxRates[_defaultTaxName] ?? "";

  void _mergeTaxOptionsFromApi(List<BedtimeGetTaxList> taxes) {
    for (final tax in taxes) {
      if (tax.cTaxName.isNotEmpty && !taxOptions.contains(tax.cTaxName)) {
        taxOptions.add(tax.cTaxName);
      }
    }
  }

  void _onTaxNameChanged(int index, String? selectedTax) {
    if (selectedTax == null) return;
    setState(() {
      taxList[index]["name"] = selectedTax;
      taxList[index]["rate"] = taxRates[selectedTax] ?? "";
      _taxRateControllers[index].text = taxList[index]["rate"] ?? "";
    });
  }

  void _onTaxRateChanged(int index, String value) {
    setState(() {
      taxList[index]["rate"] = value;
    });
  }

  void _addTaxRow() {
    setState(() {
      final defaultTax = _defaultTaxName;
      taxList.add({"name": defaultTax, "rate": taxRates[defaultTax] ?? ""});
      _taxRateControllers.add(
        TextEditingController(text: taxRates[defaultTax] ?? ""),
      );
    });
  }

  void _removeTaxRow(int index) {
    setState(() {
      _taxRateControllers[index].dispose();
      _taxRateControllers.removeAt(index);
      taxList.removeAt(index);
    });
  }

  String _formatRate(double rate) {
    if (rate == rate.truncateToDouble()) return rate.toStringAsFixed(0);
    final withTwo = rate.toStringAsFixed(2);
    return withTwo
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _applyAccountTaxAndTds(BedtimeGetAccountsList account) {
    isTdsChecked = account.bTDS;
    _tdsRateController.text = _formatRate(account.nTDSPercent);
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
              "rate": _formatRate(tax.nTaxRate),
            },
          )
          .toList();
      for (final tax in taxList) {
        final name = tax["name"] ?? "";
        final rate = tax["rate"] ?? "";
        if (name.isNotEmpty && !taxOptions.contains(name)) {
          taxOptions.add(name);
        }
        if (name.isNotEmpty) {
          taxRates[name] = rate;
        }
        _taxRateControllers.add(
          TextEditingController(text: rate),
        );
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

  String _formatCurrency(double value) => "₹${value.toStringAsFixed(2)}";

  double get _requestedAmount => _parseNumber(_requestedAmountController.text);

  double get _tdsRate => _parseNumber(_tdsRateController.text);

  double get _tdsAmount {
    if (!isTdsChecked) return 0;
    return _requestedAmount * _tdsRate / 100;
  }

  double get _totalTaxAmount {
    if (!isTaxableChecked) return 0;
    return taxList.fold<double>(0, (sum, tax) {
      final rate = _parseNumber(tax["rate"] ?? "");
      return sum + (_requestedAmount * rate / 100);
    });
  }

  double get _payableAmount => _requestedAmount - _tdsAmount + _totalTaxAmount;

  String get _attachmentValueForSave => _uploadItems
      .where((item) => item.attachmentPath.isNotEmpty)
      .map((item) => item.attachmentPath)
      .join(",");

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadSelectedProject() async {
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    if (!mounted) return;
    setState(() {
      _selectedProjectId = projectId;
    });
  }

  @override
  void dispose() {
    _requestedAmountController.dispose();
    _tdsRateController.dispose();
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
        BlocListener<BedtimePaymentRequestUploadBloc,
            BedtimePaymentRequestUploadState>(
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
        leading: const Icon(Icons.arrow_back_ios, size: 18,color: Colors.black,),
       
      ),

      /// Body Scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 170),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Dropdown Fields
            _accountDropdownField(),
            const SizedBox(height: 12),
            _categoryDropdownField(),
            const SizedBox(height: 12),
            _sectionDropdownField(),

            const SizedBox(height: 16),

            /// Requested Amount + TDS
            const Text("Requested Amount", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: _inputBox(
                    hint: "",
                    controller: _requestedAmountController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => isTdsChecked = !isTdsChecked);
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
                         const SizedBox(width: 16),
                         SizedBox(
                           width: 70,
                           child: _inputBox(
                             hint: "0",
                             controller: _tdsRateController,
                             onChanged: (_) => setState(() {}),
                             enabled: isTdsChecked,
                             trailingText: "%",
                             keyboardType:
                                 const TextInputType.numberWithOptions(
                               decimal: true,
                             ),
                           ),
                         ),
                      ],
                    ),
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
                  if (isTaxableChecked && taxList.isEmpty) {
                    final defaultTax = _defaultTaxName;
                    taxList = [
                      {
                        "name": defaultTax,
                        "rate": taxRates[defaultTax] ?? "",
                      },
                    ];
                    _taxRateControllers.add(
                      TextEditingController(
                        text: taxRates[defaultTax] ?? "",
                      ),
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
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
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
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: (tax["name"] ?? "").isNotEmpty
                                                  && taxOptions.contains(
                                                    tax["name"] ?? "",
                                                  )
                                              ? tax["name"]
                                              : null,
                                          isExpanded: true,
                                          hint: const Text(
                                            "Select Tax",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF7F7F7F),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.chevron_right,
                                            size: 16,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          items: taxOptions
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
                                              onChanged: (value) =>
                                                  _onTaxRateChanged(
                                                index,
                                                value,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                hintText: "0",
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                focusedErrorBorder:
                                                    InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
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
                                    child: const Icon(
                                      Icons.delete,
                                      size: 14,
                                      color: Colors.white,
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
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(3),
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
              child: const TextField(
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
          children: const [
            Text("Account", style: TextStyle(fontSize: 13)),
            Spacer(),
            Text(
              "+ Add New Account",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2E7CF6),
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
          ),
          child:
              BlocBuilder<BedtimeGetAccountsListBloc, BedtimeGetAccountsListState>(
            builder: (context, state) {
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
                return DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: state.accounts.any(
                      (account) => account.nAccountId == _selectedAccountId,
                    )
                        ? _selectedAccountId
                        : null,
                    hint: const Text(
                      "Select Account",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 16),
                    items: state.accounts
                        .map(
                          (account) => DropdownMenuItem<int>(
                            value: account.nAccountId,
                            child: Text(
                              account.cAccountName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountId = value;
                        if (value == null) return;
                        for (final account in state.accounts) {
                          if (account.nAccountId == value) {
                            _applyAccountTaxAndTds(account);
                            break;
                          }
                        }
                      });
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  /// Dropdown Style Field
  Widget _categoryDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Category", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCDDEB)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: BlocBuilder<BedtimeGetCategoryListBloc, BedtimeGetCategoryListState>(
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
                return DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: state.categories.any(
                      (category) => category.nCategoryId == _selectedCategoryId,
                    )
                        ? _selectedCategoryId
                        : null,
                    hint: const Text(
                      "Select Category",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 16),
                    items: state.categories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: category.nCategoryId,
                            child: Text(
                              category.cCategoryName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  /// Dropdown Style Field
  Widget _sectionDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Section", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCDDEB)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: BlocBuilder<BedtimeGetSectionListBloc, BedtimeGetSectionListState>(
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
                return DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: state.sections.any(
                      (section) => section.nSectionId == _selectedSectionId,
                    )
                        ? _selectedSectionId
                        : null,
                    hint: const Text(
                      "Select Section",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 16),
                    items: state.sections
                        .map(
                          (section) => DropdownMenuItem<int>(
                            value: section.nSectionId,
                            child: Text(
                              section.cSectionName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedSectionId = value);
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  void _onSaveTapped() {
    final attachmentValue = _attachmentValueForSave;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          attachmentValue.isEmpty
              ? "No attachments selected"
              : "Attachments ready: $attachmentValue",
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    if (_selectedProjectId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a project before uploading files"),
        ),
      );
      return;
    }

    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final localId = "${DateTime.now().microsecondsSinceEpoch}_${_uploadCounter++}";
    final fileName = pickedFile.name.isNotEmpty
        ? pickedFile.name
        : pickedFile.path.split(RegExp(r"[\\\\/]")).last;
    final fileSizeBytes = await pickedFile.length();

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

    if (!mounted) return;
    context.read<BedtimePaymentRequestUploadBloc>().add(
      BedtimePaymentRequestUploadRequested(
        companyId: 1,
        projectId: _selectedProjectId,
        localId: localId,
        filePath: pickedFile.path,
        fileName: fileName,
      ),
    );
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
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 KB";
    if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    return "${(bytes / 1024).toStringAsFixed(0)} KB";
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
            const Icon(
              Icons.cloud_upload_outlined,
              color: Color(0xFF7A5CF5),
            ),
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
              "(JPEG, PNG, format, up to 50MB)",
              style: TextStyle(fontSize: 10, color: Color(0xFF6F6F6F)),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _smallButton(
                  "Camera",
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: const Color(0xFF9F9F9F),
                  onTap: () => _pickAndUpload(ImageSource.camera),
                ),
                const SizedBox(width: 8),
                _smallButton(
                  "Gallery",
                  onTap: () => _pickAndUpload(ImageSource.gallery),
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
    final sizeText = _formatFileSize(item.fileSizeBytes);

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
          ClipRRect(
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
                  : const Icon(
                      Icons.insert_drive_file_outlined,
                      color: Color(0xFF7A5CF5),
                      size: 16,
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
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5F5F5F),
              ),
            )
          else
            GestureDetector(
              onTap: () => _removeUploadItem(item.localId),
              child: const Icon(
                Icons.delete_outline,
                size: 19,
                color: Color(0xFFF85A5A),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCDDEB)),
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
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              minLines: null,
              maxLines: null,
              expands: true,
              decoration: InputDecoration.collapsed(
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
            const SizedBox(width: 4),
            Text(trailingText, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  /// Small Upload Buttons
  Widget _smallButton(
    String text, {
    required VoidCallback onTap,
    Color backgroundColor = const Color(0xFF25008C),
    Color textColor = Colors.white,
    Color borderColor = const Color(0xFF25008C),
  }) {
    return InkWell(
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
  final VoidCallback onSave;

  const _CreateRequestSummaryBar({
    required this.requestedAmount,
    required this.tds,
    required this.tax,
    required this.payable,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
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
            label: "TDS (Less)",
            value: tds,
            labelColor: const Color(0xFF00B421),
          ),
          const SizedBox(height: 4),
          _CreateRequestSummaryRow(
            label: "Tax (Add)",
            value: tax,
            labelColor: const Color(0xFFFB0000),
          ),
          const Divider(),
          _CreateRequestSummaryRow(
            label: "Payable Amount",
            value: payable,
            isBold: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 90,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onSave,
                child: const Text("Save", style: TextStyle(fontSize: 16,color: Colors.white)),
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
  final String value;
  final Color? labelColor;
  final bool isBold;

  const _CreateRequestSummaryRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.w500 : FontWeight.w500,
              color: labelColor ?? Colors.black,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: isBold ? FontWeight.w500 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
