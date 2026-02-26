part of 'package:bedtime_stories/utils/lib_files.dart';

enum _VoucherPaymentMode { cash, bank, cheque, upi }

class VoucherApprovalRequestDetailPage extends StatefulWidget {
  final BedtimePaymentRequest request;

  const VoucherApprovalRequestDetailPage({super.key, required this.request});

  @override
  State<VoucherApprovalRequestDetailPage> createState() =>
      _VoucherApprovalRequestDetailPageState();
}

class _VoucherApprovalRequestDetailPageState
    extends State<VoucherApprovalRequestDetailPage> {
  static const int _upiTransactionIdMaxLength = 35;
  static const int _upiAppMaxLength = 50;
  static final RegExp _upiTransactionIdPattern = RegExp(r"^[A-Za-z0-9]+$");

  bool _showApprovedDetails = false;
  _VoucherPaymentMode _paymentMode = _VoucherPaymentMode.cash;
  int? _selectedBankId;
  DateTime? _chequeDate;
  bool _isSuccessDialogVisible = false;
  final TextEditingController _chequeNumberController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _upiAppController = TextEditingController();
  String? _bankFieldError;
  String? _chequeNumberFieldError;
  String? _chequeDateFieldError;
  String? _transactionIdFieldError;
  String? _upiAppFieldError;

  String _money(double value) => value.toStringAsFixed(2);
  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    context.read<BedtimeGetBankListBloc>().add(
      BedtimeGetBankListLoadRequested(companyId: 1),
    );
    context.read<BedtimePaymentRequestDetailBloc>().add(
      BedtimePaymentRequestDetailLoadRequested(
        companyId: 1,
        payReqId: widget.request.nPayReqId,
      ),
    );
  }

  @override
  void dispose() {
    _chequeNumberController.dispose();
    _transactionIdController.dispose();
    _upiAppController.dispose();
    super.dispose();
  }

  List<String> _attachmentList(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _approvedBannerText() {
    final approvedBy = widget.request.cApprovedBy ?? "";
    final by = approvedBy.trim().isEmpty ? "you" : approvedBy;
    final on = (widget.request.cApprovedDateTime ?? "").trim();
    if (on.isEmpty) return "(by $by)";
    return "(by $by on $on)";
  }

  String _requestedBannerText() {
    final requestedBy = widget.request.cRequestedBy.trim().isEmpty
        ? "you"
        : widget.request.cRequestedBy;
    final on = (widget.request.cRequestDateTime ?? "").trim();
    if (on.isEmpty) return "(by $requestedBy)";
    return "(by $requestedBy on $on)";
  }

  Future<void> _pickChequeDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _chequeDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _chequeDate = picked;
      _chequeDateFieldError = null;
    });
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  String _formatApiDate(DateTime date) {
    return "${_formatDate(date)}T00:00:00";
  }

  String _selectedPayModeValue() {
    switch (_paymentMode) {
      case _VoucherPaymentMode.cash:
        return "cash";
      case _VoucherPaymentMode.bank:
        return "bank";
      case _VoucherPaymentMode.cheque:
        return "cheque";
      case _VoucherPaymentMode.upi:
        return "upi";
    }
  }

  void _clearInlineValidationErrors() {
    _bankFieldError = null;
    _chequeNumberFieldError = null;
    _chequeDateFieldError = null;
    _transactionIdFieldError = null;
    _upiAppFieldError = null;
  }

  void _changePaymentMode(_VoucherPaymentMode mode) {
    setState(() {
      _paymentMode = mode;
      _clearInlineValidationErrors();
    });
  }

  bool _validateVoucherInline() {
    String? bankFieldError;
    String? chequeNumberFieldError;
    String? chequeDateFieldError;
    String? transactionIdFieldError;
    String? upiAppFieldError;

    if (_paymentMode == _VoucherPaymentMode.bank && _selectedBankId == null) {
      bankFieldError = "Bank name is required";
    }

    if (_paymentMode == _VoucherPaymentMode.cheque) {
      final chequeNumber = _chequeNumberController.text.trim();
      if (chequeNumber.isEmpty) {
        chequeNumberFieldError = "Cheque number is required";
      } else if (chequeNumber.length != 6) {
        chequeNumberFieldError = "Cheque number must be 6 digits";
      }
      if (_chequeDate == null) {
        chequeDateFieldError = "Cheque date is required";
      }
      if (_selectedBankId == null) {
        bankFieldError = "Bank name is required";
      }
    }

    if (_paymentMode == _VoucherPaymentMode.upi) {
      final transactionId = _transactionIdController.text.trim();
      final upiApp = _upiAppController.text.trim();

      if (transactionId.isEmpty) {
        transactionIdFieldError = "Transaction id is required";
      } else if (transactionId.length > _upiTransactionIdMaxLength) {
        transactionIdFieldError =
            "Transaction id must be at most $_upiTransactionIdMaxLength characters";
      } else if (!_upiTransactionIdPattern.hasMatch(transactionId)) {
        transactionIdFieldError =
            "Transaction id must contain only letters and numbers";
      }

      if (upiApp.isEmpty) {
        upiAppFieldError = "UPI app is required";
      } else if (upiApp.length > _upiAppMaxLength) {
        upiAppFieldError = "UPI app must be at most $_upiAppMaxLength characters";
      }
    }

    final hasErrors =
        bankFieldError != null ||
        chequeNumberFieldError != null ||
        chequeDateFieldError != null ||
        transactionIdFieldError != null ||
        upiAppFieldError != null;

    if (hasErrors) {
      setState(() {
        _bankFieldError = bankFieldError;
        _chequeNumberFieldError = chequeNumberFieldError;
        _chequeDateFieldError = chequeDateFieldError;
        _transactionIdFieldError = transactionIdFieldError;
        _upiAppFieldError = upiAppFieldError;
      });
      return false;
    }

    _clearInlineValidationErrors();
    return true;
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
                  "Voucher Created Successfully",
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

  Future<void> _saveVoucher() async {
    if (!_validateVoucherInline()) {
      return;
    }

    final userData = await BedtimeLocalStorage.getUserData();
    final nUserActionId = int.tryParse(userData["userId"]?.toString() ?? "") ?? 0;
    final nProjectId = await BedtimeLocalStorage.getSelectedProjectId();

    final payload = {
      "nPayVoucherId": 0,
      "nPayReqId": widget.request.nPayReqId,
      "cPayMode": _selectedPayModeValue(),
      "dVoucherDate": _formatApiDate(DateTime.now()),
      "cChequeNo": _paymentMode == _VoucherPaymentMode.cheque
          ? _chequeNumberController.text.trim()
          : "",
      "dChequeDate":
          _paymentMode == _VoucherPaymentMode.cheque && _chequeDate != null
              ? _formatApiDate(_chequeDate!)
              : null,
      "nBankId":
          (_paymentMode == _VoucherPaymentMode.bank ||
                  _paymentMode == _VoucherPaymentMode.cheque)
              ? (_selectedBankId ?? 0)
              : 0,
      "cUPIRefNo": _paymentMode == _VoucherPaymentMode.upi
          ? _transactionIdController.text.trim()
          : "",
      "cComment": "",
      "cUPIApp": _paymentMode == _VoucherPaymentMode.upi
          ? _upiAppController.text.trim()
          : "",
      "nProjectId": nProjectId,
      "nUserActionId": nUserActionId,
      "bActive": true,
      "nCompanyId": 1,
    };

    if (!mounted) return;
    context.read<BedtimePaymentVoucherSaveBloc>().add(
      BedtimePaymentVoucherSaveRequested(payload: payload),
    );
  }

  Future<void> _refreshRequestPageData() async {
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userData = await BedtimeLocalStorage.getUserData();
    final userActionId = _resolveInt(userData["userId"]);
    if (!mounted) return;
    context.read<BedtimePaymentRequestBloc>().add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: projectId,
        userActionId: userActionId,
        search: "",
        statusFilter: "",
        dFrom: "",
        dTo: "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final voucherSaveState = context.watch<BedtimePaymentVoucherSaveBloc>().state;
    final isSavingVoucher = voucherSaveState is BedtimePaymentVoucherSaving;
    final bankListState = context.watch<BedtimeGetBankListBloc>().state;
    final bankItems = bankListState is BedtimeGetBankListLoaded
        ? bankListState.banks.where((bank) => bank.bActive).toList()
        : <BedtimeGetBankList>[];
    final bankHint = bankListState is BedtimeGetBankListLoading
        ? "Loading banks..."
        : "Select Bank";
    final bankError = bankListState is BedtimeGetBankListFailure
        ? bankListState.message
        : null;

    return BlocListener<BedtimePaymentVoucherSaveBloc, BedtimePaymentVoucherSaveState>(
      listener: (context, state) async {
        if (state is BedtimePaymentVoucherSaveSuccess) {
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

          await _refreshRequestPageData();

          if (!context.mounted) return;
          Navigator.pop(context, true);
          return;
        }
        if (state is BedtimePaymentVoucherSaveFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _RequestDetailHeader(
                title: "Voucher",
                onBack: () => Navigator.pop(context),
              ),
              _ExpandableStatusBanner(
                label: "Approved",
                details: _approvedBannerText(),
                isExpanded: _showApprovedDetails,
                onTap: () {
                  setState(() {
                    _showApprovedDetails = !_showApprovedDetails;
                  });
                },
                expandedChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        children: [
                          const TextSpan(text: "Requested "),
                          TextSpan(
                            text: _requestedBannerText(),
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF3C3C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Req No : ${widget.request.cRequestNo}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    BlocBuilder<
                      BedtimePaymentRequestDetailBloc,
                      BedtimePaymentRequestDetailState
                    >(
                    builder: (context, state) {
                      BedtimePaymentRequestDetail? detail;
                      List<BedtimePaymentRequestTax> taxes = [];

                      if (state is BedtimePaymentRequestDetailLoaded) {
                        detail = state.detail.data;
                        taxes = state.detail.taxDtl;
                      }

                      if (state is BedtimePaymentRequestDetailFailure) {
                        return Center(child: Text(state.message));
                      }

                      if (state is BedtimePaymentRequestDetailLoading &&
                          detail == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final requestedAmount =
                          detail?.nRequestedAmount ?? request.nPayableAmount;
                      final tdsPercent = detail?.nTDSPercent ?? 0.0;
                      final tdsAmount = detail?.nTDSAmount ?? 0.0;
                      final taxAmount = detail?.nTaxAmount ?? 0.0;
                      final payableAmount =
                          detail?.nPayableAmount ?? request.nPayableAmount;
                      final comment = detail?.cComment ?? "";
                      final attachments = _attachmentList(
                        detail?.cAttachment ?? "",
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ApprovalInfoCard(
                                    account: request.cAccountName,
                                    category: request.cCategoryName,
                                    section: request.cSectionName,
                                  ),
                                  const SizedBox(height: 10),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: "Requested Amount",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              " : ${String.fromCharCode(8377)}${_money(requestedAmount)}",
                                        ),
                                      ],
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "TDS : ${_money(tdsPercent)} %",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Tax Details",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _ApprovalTaxTable(taxes: taxes),
                                  const SizedBox(height: 8),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: "Comment ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              comment.isEmpty ? "-" : comment,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.3,
                                            color: Color(0xFF444444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    "Uploaded Files",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (attachments.isEmpty)
                                    const Text(
                                      "No attachments",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  for (final file in attachments) ...[
                                    _UploadRow(
                                      title: file,
                                      size: "Loading...",
                                      enableImagePreview: true,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                                    child: Column(
                                      children: [
                                        _SummaryRow(
                                          label: "Requested Amount",
                                          value:
                                              "${String.fromCharCode(8377)}${_money(requestedAmount)}",
                                        ),
                                        const SizedBox(height: 6),
                                        _SummaryRow(
                                          label: "TDS (Less)",
                                          value:
                                              "${String.fromCharCode(8377)}${_money(tdsAmount)}",
                                          labelColor: const Color(0xFF00B421),
                                        ),
                                        const SizedBox(height: 6),
                                        _SummaryRow(
                                          label: "Tax (Add)",
                                          value:
                                              "${String.fromCharCode(8377)}${_money(taxAmount)}",
                                          labelColor: const Color(0xFFFB0000),
                                        ),
                                        const SizedBox(height: 6),
                                        _SummaryRow(
                                          label: "Payable Amount",
                                          value:
                                              "${String.fromCharCode(8377)}${_money(payableAmount)}",
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F8),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Payment Modes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _VoucherPaymentModeButton(
                                        label: "Cash",
                                        assetIcon: "assets/icons/cash.png",
                                        selected:
                                            _paymentMode == _VoucherPaymentMode.cash,
                                        onTap: () => _changePaymentMode(
                                          _VoucherPaymentMode.cash,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _VoucherPaymentModeButton(
                                        label: "Bank",
                                        assetIcon: "assets/icons/bank.png",
                                        selected:
                                            _paymentMode == _VoucherPaymentMode.bank,
                                        onTap: () => _changePaymentMode(
                                          _VoucherPaymentMode.bank,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _VoucherPaymentModeButton(
                                        label: "Cheque",
                                        assetIcon: "assets/icons/cheque.png",
                                        selected:
                                            _paymentMode == _VoucherPaymentMode.cheque,
                                        onTap: () => _changePaymentMode(
                                          _VoucherPaymentMode.cheque,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _VoucherPaymentModeButton(
                                        label: "UPI",
                                        assetIcon: "assets/icons/upi.png",
                                        selected:
                                            _paymentMode == _VoucherPaymentMode.upi,
                                        onTap: () => _changePaymentMode(
                                          _VoucherPaymentMode.upi,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (_paymentMode != _VoucherPaymentMode.cash) ...[
                                    const Text(
                                      "All fields shown below are mandatory for the selected payment mode.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6A6A6A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  if (_paymentMode == _VoucherPaymentMode.bank) ...[
                                    _VoucherLabelText(label: "Bank Name"),
                                    const SizedBox(height: 6),
                                    _VoucherDropdownField(
                                      value: _selectedBankId,
                                      hasError: _bankFieldError != null,
                                      hint: bankHint,
                                      items: bankItems,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedBankId = value;
                                          _bankFieldError = null;
                                        });
                                      },
                                    ),
                                    if (_bankFieldError != null) ...[
                                      const SizedBox(height: 6),
                                      _VoucherInlineErrorText(text: _bankFieldError!),
                                    ],
                                    if (bankError != null && bankItems.isEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        bankError,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFCC2B2B),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                  ],
                                  if (_paymentMode == _VoucherPaymentMode.cheque) ...[
                                    _VoucherLabelText(label: "Cheque Number"),
                                    const SizedBox(height: 6),
                                    _VoucherTextField(
                                      controller: _chequeNumberController,
                                      hint: "",
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      hasError: _chequeNumberFieldError != null,
                                      onChanged: (_) {
                                        if (_chequeNumberFieldError == null) return;
                                        setState(() {
                                          _chequeNumberFieldError = null;
                                        });
                                      },
                                    ),
                                    if (_chequeNumberFieldError != null) ...[
                                      const SizedBox(height: 6),
                                      _VoucherInlineErrorText(
                                        text: _chequeNumberFieldError!,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    _VoucherLabelText(label: "Date"),
                                    const SizedBox(height: 6),
                                    _VoucherDateField(
                                      hasError: _chequeDateFieldError != null,
                                      value: _chequeDate == null
                                          ? ""
                                          : _formatDate(_chequeDate!),
                                      onTap: _pickChequeDate,
                                    ),
                                    if (_chequeDateFieldError != null) ...[
                                      const SizedBox(height: 6),
                                      _VoucherInlineErrorText(
                                        text: _chequeDateFieldError!,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    _VoucherLabelText(label: "Bank Name"),
                                    const SizedBox(height: 6),
                                    _VoucherDropdownField(
                                      value: _selectedBankId,
                                      hasError: _bankFieldError != null,
                                      hint: bankHint,
                                      items: bankItems,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedBankId = value;
                                          _bankFieldError = null;
                                        });
                                      },
                                    ),
                                    if (_bankFieldError != null) ...[
                                      const SizedBox(height: 6),
                                      _VoucherInlineErrorText(text: _bankFieldError!),
                                    ],
                                    if (bankError != null && bankItems.isEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        bankError,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFCC2B2B),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                  ],
                                  if (_paymentMode == _VoucherPaymentMode.upi) ...[
                                    _VoucherLabelText(label: "Transaction Id"),
                                    const SizedBox(height: 6),
                                    _VoucherTextField(
                                      controller: _transactionIdController,
                                      hint: "",
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r"[A-Za-z0-9]"),
                                        ),
                                        LengthLimitingTextInputFormatter(
                                          _upiTransactionIdMaxLength,
                                        ),
                                      ],
                                      hasError: _transactionIdFieldError != null,
                                      onChanged: (_) {
                                        if (_transactionIdFieldError == null) return;
                                        setState(() {
                                          _transactionIdFieldError = null;
                                        });
                                      },
                                    ),
                                    if (_transactionIdFieldError != null) ...[
                                      const SizedBox(height: 6),
                                      _VoucherInlineErrorText(
                                        text: _transactionIdFieldError!,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    _VoucherLabelText(label: "UPI APP"),
                                    const SizedBox(height: 6),
                                    _VoucherTextField(
                                      controller: _upiAppController,
                                      hint: "",
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(
                                          _upiAppMaxLength,
                                        ),
                                      ],
                                      hasError: _upiAppFieldError != null,
                                      onChanged: (_) {
                                        if (_upiAppFieldError == null) return;
                                        setState(() {
                                          _upiAppFieldError = null;
                                        });
                                      },
                                    ),
                                    if (_upiAppFieldError != null) ...[
                                      const SizedBox(height: 6),
                                      _VoucherInlineErrorText(
                                        text: _upiAppFieldError!,
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                  ],
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        width: 86,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: isSavingVoucher
                                              ? null
                                              : _saveVoucher,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF1BA8FF),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: isSavingVoucher
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text(
                                                  "Save",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
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

class _VoucherPaymentModeButton extends StatelessWidget {
  final String label;
  final String assetIcon;
  final bool selected;
  final VoidCallback onTap;

  const _VoucherPaymentModeButton({
    required this.label,
    required this.assetIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE5F2FE) : null,
              gradient: selected
                  ? null
                  : const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF6BA5F0),
                        Color(0xFF00C5F2),
                      ],
                    ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: selected ? const Color(0xFF2DA9F9) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Image.asset(
                
                assetIcon,
                fit: BoxFit.contain,
                color: selected ? const Color(0xFF2DA9F9) : Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF4A4A4A)),
          ),
        ],
      ),
    );
  }
}

class _VoucherLabelText extends StatelessWidget {
  final String label;

  const _VoucherLabelText({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF2D2D2D),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _VoucherInlineErrorText extends StatelessWidget {
  final String text;

  const _VoucherInlineErrorText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFFCC2B2B),
      ),
    );
  }
}

class _VoucherTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _VoucherTextField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.hasError = false,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: hasError ? const Color(0xFFCC2B2B) : const Color(0xFFCCDDEB),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _VoucherDropdownField extends StatelessWidget {
  final int? value;
  final String hint;
  final List<BedtimeGetBankList> items;
  final ValueChanged<int?> onChanged;
  final bool hasError;

  const _VoucherDropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: hasError ? const Color(0xFFCC2B2B) : const Color(0xFFCCDDEB),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: items.any((item) => item.nBankId == value) ? value : null,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
          ),
          icon: const Icon(Icons.chevron_right, size: 18),
          items: items
              .map(
                (bank) => DropdownMenuItem<int>(
                  value: bank.nBankId,
                  child: Text(
                    bank.cBankName,
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _VoucherDateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final bool hasError;

  const _VoucherDateField({
    required this.value,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: hasError ? const Color(0xFFCC2B2B) : const Color(0xFFCCDDEB),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: value.isEmpty ? const Color(0xFF7F7F7F) : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
