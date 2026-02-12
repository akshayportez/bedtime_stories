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
  _VoucherPaymentMode _paymentMode = _VoucherPaymentMode.cash;
  int? _selectedBankId;
  DateTime? _chequeDate;
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

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _RequestDetailHeader(
              title: "Voucher",
              onBack: () => Navigator.pop(context),
            ),
            _StatusBanner(label: "Approved", details: _approvedBannerText()),
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
                                  Text(
                                    "Requested Amount : ${String.fromCharCode(8377)}${_money(requestedAmount)}",
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
                                    comment.isEmpty ? "-" : comment,
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
                                    _UploadRow(title: file, size: "550KB"),
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
                                        onTap: () => setState(
                                          () => _paymentMode = _VoucherPaymentMode.cash,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _VoucherPaymentModeButton(
                                        label: "Bank",
                                        assetIcon: "assets/icons/bank.png",
                                        selected:
                                            _paymentMode == _VoucherPaymentMode.bank,
                                        onTap: () => setState(
                                          () => _paymentMode = _VoucherPaymentMode.bank,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _VoucherPaymentModeButton(
                                        label: "Cheque",
                                        assetIcon: "assets/icons/cheque.png",
                                        selected:
                                            _paymentMode == _VoucherPaymentMode.cheque,
                                        onTap: () => setState(
                                          () => _paymentMode = _VoucherPaymentMode.cheque,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _VoucherPaymentModeButton(
                                        label: "UPI",
                                        assetIcon: "assets/icons/upi.png",
                                        selected:
                                            _paymentMode == _VoucherPaymentMode.upi,
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
                                      value: _chequeDate == null
                                          ? ""
                                          : _formatDate(_chequeDate!),
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
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1BA8FF),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
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

class _VoucherTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _VoucherTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCDDEB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
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

  const _VoucherDropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCDDEB)),
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

  const _VoucherDateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFCCDDEB)),
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
