part of 'package:bedtime_stories/utils/lib_files.dart';

class VoucherEditPage extends StatefulWidget {
  final BedtimePaymentRequest request;
  final BedtimePaymentVoucherDetailResponse voucherDetail;

  const VoucherEditPage({
    super.key,
    required this.request,
    required this.voucherDetail,
  });

  @override
  State<VoucherEditPage> createState() => _VoucherEditPageState();
}

class _VoucherEditPageState extends State<VoucherEditPage> {
  _VoucherPaymentMode _paymentMode = _VoucherPaymentMode.cash;
  int? _selectedBankId;
  DateTime? _chequeDate;
  bool _isSuccessDialogVisible = false;
  final TextEditingController _chequeNumberController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _upiAppController = TextEditingController();

  String _money(double value) => value.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    context.read<BedtimeGetBankListBloc>().add(
      BedtimeGetBankListLoadRequested(companyId: 1),
    );
    _prefillFromVoucherDetail();
  }

  @override
  void dispose() {
    _chequeNumberController.dispose();
    _transactionIdController.dispose();
    _upiAppController.dispose();
    super.dispose();
  }

  void _prefillFromVoucherDetail() {
    final voucherHdr = widget.voucherDetail.voucherHdr;
    final payDtl = widget.voucherDetail.payDtl;

    _paymentMode = _payModeFromRaw(voucherHdr.cPayMode);
    _selectedBankId = payDtl.nBankId > 0 ? payDtl.nBankId : null;
    _chequeNumberController.text = payDtl.cChequeNo;
    _transactionIdController.text = payDtl.cUPIRefNo;
    _upiAppController.text = payDtl.cUpiApp;
    _chequeDate = _parseDate(payDtl.dChequeDate);
  }

  _VoucherPaymentMode _payModeFromRaw(String value) {
    switch (value.trim().toLowerCase()) {
      case "bank":
        return _VoucherPaymentMode.bank;
      case "cheque":
        return _VoucherPaymentMode.cheque;
      case "upi":
        return _VoucherPaymentMode.upi;
      default:
        return _VoucherPaymentMode.cash;
    }
  }

  DateTime? _parseDate(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    if (raw.length >= 10) {
      final firstTen = raw.substring(0, 10);
      final parsed = DateTime.tryParse(firstTen);
      if (parsed != null) return parsed;
    }
    return DateTime.tryParse(raw);
  }

  List<String> _attachmentList(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> _allAttachments() {
    final result = <String>{...widget.voucherDetail.files};
    for (final item in _attachmentList(widget.voucherDetail.reqHdr.cAttachment)) {
      result.add(item);
    }
    return result.toList();
  }

  String _paidBannerText() {
    final approvedBy = widget.request.cApprovedBy ?? "";
    final by = approvedBy.trim().isEmpty ? "you" : approvedBy;
    final on = (widget.request.cVoucherDateTime ?? "").trim();
    if (on.isEmpty) return "(by $by)";
    return "(by $by on $on)";
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
    setState(() => _chequeDate = picked);
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

  void _showValidation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                  "Voucher Updated Successfully",
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
    if (_paymentMode == _VoucherPaymentMode.bank && _selectedBankId == null) {
      _showValidation("Please select bank");
      return;
    }

    if (_paymentMode == _VoucherPaymentMode.cheque) {
      if (_chequeNumberController.text.trim().isEmpty) {
        _showValidation("Please enter cheque number");
        return;
      }
      if (_chequeDate == null) {
        _showValidation("Please select cheque date");
        return;
      }
      if (_selectedBankId == null) {
        _showValidation("Please select bank");
        return;
      }
    }

    if (_paymentMode == _VoucherPaymentMode.upi) {
      if (_transactionIdController.text.trim().isEmpty) {
        _showValidation("Please enter transaction id");
        return;
      }
      if (_upiAppController.text.trim().isEmpty) {
        _showValidation("Please enter UPI app");
        return;
      }
    }

    final reqHdr = widget.voucherDetail.reqHdr;
    final voucherHdr = widget.voucherDetail.voucherHdr;
    final payDtl = widget.voucherDetail.payDtl;
    final userData = await BedtimeLocalStorage.getUserData();
    final nUserActionId = int.tryParse(userData["userId"]?.toString() ?? "") ?? 0;
    final selectedProjectId = await BedtimeLocalStorage.getSelectedProjectId();
    final nProjectId = reqHdr.nProjectId > 0 ? reqHdr.nProjectId : selectedProjectId;
    final voucherDate = _parseDate(voucherHdr.dVoucherDate) ?? DateTime.now();

    final payload = {
      "nPayVoucherId": voucherHdr.nPayVoucherId,
      "nPayReqId": widget.request.nPayReqId,
      "cPayMode": _selectedPayModeValue(),
      "dVoucherDate": _formatApiDate(voucherDate),
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
      "cComment": payDtl.cComment,
      "cUPIApp": _paymentMode == _VoucherPaymentMode.upi
          ? _upiAppController.text.trim()
          : "",
      "nProjectId": nProjectId,
      "nUserActionId": nUserActionId,
      "bActive": voucherHdr.bActive,
      "nCompanyId": 1,
    };

    if (!mounted) return;
    context.read<BedtimePaymentVoucherSaveBloc>().add(
      BedtimePaymentVoucherSaveRequested(payload: payload),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reqHdr = widget.voucherDetail.reqHdr;
    final request = widget.request;
    final taxes = widget.voucherDetail.taxDtl
        .map(
          (tax) => BedtimePaymentRequestTax(
            nTaxId: tax.nTaxId,
            cTaxName: tax.cTaxName,
            nTaxRate: tax.nTaxRate,
          ),
        )
        .toList();
    final attachments = _allAttachments();

    final voucherSaveState = context.watch<BedtimePaymentVoucherSaveBloc>().state;
    final isSavingVoucher = voucherSaveState is BedtimePaymentVoucherSaving;
    final bankListState = context.watch<BedtimeGetBankListBloc>().state;
    final bankItems = bankListState is BedtimeGetBankListLoaded
        ? bankListState.banks
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
              _StatusBanner(label: "Paid", details: _paidBannerText()),
              Expanded(
                child: SingleChildScrollView(
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
                              account: reqHdr.cAccountName.isNotEmpty
                                  ? reqHdr.cAccountName
                                  : request.cAccountName,
                              category: reqHdr.cCategoryName.isNotEmpty
                                  ? reqHdr.cCategoryName
                                  : request.cCategoryName,
                              section: reqHdr.cSectionName.isNotEmpty
                                  ? reqHdr.cSectionName
                                  : request.cSectionName,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Requested Amount : ${String.fromCharCode(8377)}${_money(reqHdr.nRequestedAmount)}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "TDS : ${_money(reqHdr.nTDSPercent)} %",
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
                            const Text(
                              "Comment",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              reqHdr.cComment.isEmpty ? "-" : reqHdr.cComment,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.3,
                                color: Color(0xFF444444),
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
                                        "${String.fromCharCode(8377)}${_money(reqHdr.nRequestedAmount)}",
                                  ),
                                  const SizedBox(height: 6),
                                  _SummaryRow(
                                    label: "TDS (Less)",
                                    value:
                                        "${String.fromCharCode(8377)}${_money(reqHdr.nTDSAmt)}",
                                    labelColor: const Color(0xFF00B421),
                                  ),
                                  const SizedBox(height: 6),
                                  _SummaryRow(
                                    label: "Tax (Add)",
                                    value:
                                        "${String.fromCharCode(8377)}${_money(reqHdr.nTaxAmount)}",
                                    labelColor: const Color(0xFFFB0000),
                                  ),
                                  const SizedBox(height: 6),
                                  _SummaryRow(
                                    label: "Payable Amount",
                                    value:
                                        "${String.fromCharCode(8377)}${_money(reqHdr.nPayableAmount)}",
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
                                  selected: _paymentMode == _VoucherPaymentMode.cash,
                                  onTap: () => setState(
                                    () => _paymentMode = _VoucherPaymentMode.cash,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _VoucherPaymentModeButton(
                                  label: "Bank",
                                  assetIcon: "assets/icons/bank.png",
                                  selected: _paymentMode == _VoucherPaymentMode.bank,
                                  onTap: () => setState(
                                    () => _paymentMode = _VoucherPaymentMode.bank,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _VoucherPaymentModeButton(
                                  label: "Cheque",
                                  assetIcon: "assets/icons/cheque.png",
                                  selected: _paymentMode == _VoucherPaymentMode.cheque,
                                  onTap: () => setState(
                                    () => _paymentMode = _VoucherPaymentMode.cheque,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _VoucherPaymentModeButton(
                                  label: "UPI",
                                  assetIcon: "assets/icons/upi.png",
                                  selected: _paymentMode == _VoucherPaymentMode.upi,
                                  onTap: () => setState(
                                    () => _paymentMode = _VoucherPaymentMode.upi,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_paymentMode == _VoucherPaymentMode.bank) ...[
                              _VoucherLabelText(label: "Bank Name"),
                              const SizedBox(height: 6),
                              _VoucherDropdownField(
                                value: _selectedBankId,
                                hint: bankHint,
                                items: bankItems,
                                onChanged: (value) {
                                  setState(() => _selectedBankId = value);
                                },
                              ),
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
                              ),
                              const SizedBox(height: 10),
                              _VoucherLabelText(label: "Date"),
                              const SizedBox(height: 6),
                              _VoucherDateField(
                                value:
                                    _chequeDate == null ? "" : _formatDate(_chequeDate!),
                                onTap: _pickChequeDate,
                              ),
                              const SizedBox(height: 10),
                              _VoucherLabelText(label: "Bank Name"),
                              const SizedBox(height: 6),
                              _VoucherDropdownField(
                                value: _selectedBankId,
                                hint: bankHint,
                                items: bankItems,
                                onChanged: (value) {
                                  setState(() => _selectedBankId = value);
                                },
                              ),
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
                              ),
                              const SizedBox(height: 10),
                              _VoucherLabelText(label: "UPI APP"),
                              const SizedBox(height: 6),
                              _VoucherTextField(
                                controller: _upiAppController,
                                hint: "",
                              ),
                              const SizedBox(height: 14),
                            ],
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 86,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: isSavingVoucher ? null : _saveVoucher,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1BA8FF),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: isSavingVoucher
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
