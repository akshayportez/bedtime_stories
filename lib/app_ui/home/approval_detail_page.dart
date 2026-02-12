part of 'package:bedtime_stories/utils/lib_files.dart';

class ApprovalDetailPage extends StatefulWidget {
  final BedtimePaymentRequest request;

  const ApprovalDetailPage({super.key, required this.request});

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  bool _showActionButtons = false;
  bool _isApproving = false;
  bool _isRejecting = false;

  String _money(double value) => value.toStringAsFixed(2);
  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    context.read<BedtimePaymentRequestDetailBloc>().add(
      BedtimePaymentRequestDetailLoadRequested(
        companyId: 1,
        payReqId: widget.request.nPayReqId,
      ),
    );
  }

  List<String> _attachmentList(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _approvedBannerText() {
    final approvedBy = widget.request.cApprovedBy ?? '';
    final by = approvedBy.trim().isEmpty ? 'you' : approvedBy;
    final on = (widget.request.cApprovedDateTime ?? '').trim();
    if (on.isEmpty) return '(by $by)';
    return '(by $by on $on)';
  }

  Future<void> _onApproveTapped() async {
    if (_isApproving || _isRejecting) return;
    final userData = await BedtimeLocalStorage.getUserData();
    final userActionId = _resolveInt(userData["userId"]);
    if (!mounted) return;
    context.read<BedtimeRequestApproveBloc>().add(
      BedtimeRequestApproveRequested(
        nPayReqId: widget.request.nPayReqId,
        nCompanyId: 1,
        nUserActionId: userActionId,
        cApprovalComment: "",
      ),
    );
  }

  Future<void> _onRejectTapped() async {
    if (_isApproving || _isRejecting) return;
    final userData = await BedtimeLocalStorage.getUserData();
    final userActionId = _resolveInt(userData["userId"]);
    if (!mounted) return;
    context.read<BedtimeRequestRejectBloc>().add(
      BedtimeRequestRejectRequested(
        nPayReqId: widget.request.nPayReqId,
        nCompanyId: 1,
        nUserActionId: userActionId,
        cApprovalComment: " ",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return MultiBlocListener(
      listeners: [
        BlocListener<BedtimeRequestApproveBloc, BedtimeRequestApproveState>(
          listener: (context, state) {
            if (state is BedtimeRequestApproveLoading) {
              if (mounted) setState(() => _isApproving = true);
              return;
            }
            if (state is BedtimeRequestApproveFailure) {
              if (mounted) setState(() => _isApproving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              return;
            }
            if (state is BedtimeRequestApproveSuccess) {
              if (mounted) setState(() => _isApproving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.response.cMessage.isEmpty
                        ? "Approved successfully"
                        : state.response.cMessage,
                  ),
                ),
              );
              Navigator.pop(context, true);
            }
          },
        ),
        BlocListener<BedtimeRequestRejectBloc, BedtimeRequestRejectState>(
          listener: (context, state) {
            if (state is BedtimeRequestRejectLoading) {
              if (mounted) setState(() => _isRejecting = true);
              return;
            }
            if (state is BedtimeRequestRejectFailure) {
              if (mounted) setState(() => _isRejecting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              return;
            }
            if (state is BedtimeRequestRejectSuccess) {
              if (mounted) setState(() => _isRejecting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.response.cMessage.isEmpty
                        ? "Rejected successfully"
                        : state.response.cMessage,
                  ),
                ),
              );
              Navigator.pop(context, true);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _RequestDetailHeader(
                title: 'Request',
                onBack: () => Navigator.pop(context),
              ),
              _StatusBanner(label: 'Approved', details: _approvedBannerText()),
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
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
        
                      final requestedAmount =
                          detail?.nRequestedAmount ?? request.nPayableAmount;
                      final tdsPercent = detail?.nTDSPercent ?? 0.0;
                      final tdsAmount = detail?.nTDSAmount ?? 0.0;
                      final taxAmount = detail?.nTaxAmount ?? 0.0;
                      final payableAmount =
                          detail?.nPayableAmount ?? request.nPayableAmount;
                      final comment = detail?.cComment ?? '';
                      final attachments = _attachmentList(
                        detail?.cAttachment ?? '',
                      );
        
                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                8,
                                12,
                                0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Req No : ${request.cRequestNo}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Color(0xFF222222),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        request.cRequestDateTime ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF222222),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _ApprovalInfoCard(
                                    account: request.cAccountName,
                                    category: request.cCategoryName,
                                    section: request.cSectionName,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Requested Amount : ${String.fromCharCode(8377)}${_money(requestedAmount)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'TDS : ${_money(tdsPercent)} %',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tax Details',
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
                                    'Comments',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    comment.isEmpty ? '-' : comment,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                      color: Color(0xFF444444),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Uploaded Files',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (attachments.isEmpty)
                                    const Text(
                                      'No attachments',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  for (final file in attachments) ...[
                                    _UploadRow(title: file, size: '550KB'),
                                    const SizedBox(height: 8),
                                  ],
                                  const SizedBox(height: 110),
                                ],
                              ),
                            ),
                          ),
                            _ApprovalSummaryBar(
                              requestedAmount: _money(requestedAmount),
                              tds: _money(tdsAmount),
                              tax: _money(taxAmount),
                              payable: _money(payableAmount),
                              bottomPadding: bottomInset,
                              showActionButtons: _showActionButtons,
                              isApproving: _isApproving,
                              isRejecting: _isRejecting,
                              onEditTap: () {
                                setState(() => _showActionButtons = true);
                              },
                              onRejectTap: _onRejectTapped,
                              onApproveTap: _onApproveTapped,
                            ),
                        ],
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

class _ApprovalInfoCard extends StatelessWidget {
  final String account;
  final String category;
  final String section;

  const _ApprovalInfoCard({
    required this.account,
    required this.category,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD7DCE2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          _ApprovalInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Account',
            value: account,
          ),
          const SizedBox(height: 6),
          _ApprovalInfoRow(
            icon: Icons.category_outlined,
            title: 'Category',
            value: category,
          ),
          const SizedBox(height: 6),
          _ApprovalInfoRow(
            icon: Icons.receipt_long_outlined,
            title: 'Section',
            value: section,
          ),
        ],
      ),
    );
  }
}

class _ApprovalInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ApprovalInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD0D5DB)),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF616161)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$title : $value',
            style: const TextStyle(fontSize: 13, color: Color(0xFF3A3A3A)),
          ),
        ),
      ],
    );
  }
}

class _ApprovalTaxTable extends StatelessWidget {
  final List<BedtimePaymentRequestTax> taxes;

  const _ApprovalTaxTable({required this.taxes});

  @override
  Widget build(BuildContext context) {
    final rows = taxes.isEmpty
        ? const [_ApprovalTaxRow(name: '-', rate: '-')]
        : taxes
              .map(
                (tax) => _ApprovalTaxRow(
                  name: tax.cTaxName,
                  rate: '${tax.nTaxRate} %',
                ),
              )
              .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFA8CEE8)),
      ),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFAED6EE),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Tax Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Tax Rate %',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFA8CEE8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].rate,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApprovalTaxRow {
  final String name;
  final String rate;

  const _ApprovalTaxRow({required this.name, required this.rate});
}

class _ApprovalSummaryBar extends StatelessWidget {
  final String requestedAmount;
  final String tds;
  final String tax;
  final String payable;
  final double bottomPadding;
  final bool showActionButtons;
  final bool isApproving;
  final bool isRejecting;
  final VoidCallback onEditTap;
  final VoidCallback onRejectTap;
  final VoidCallback onApproveTap;

  const _ApprovalSummaryBar({
    required this.requestedAmount,
    required this.tds,
    required this.tax,
    required this.payable,
    required this.bottomPadding,
    required this.showActionButtons,
    required this.isApproving,
    required this.isRejecting,
    required this.onEditTap,
    required this.onRejectTap,
    required this.onApproveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7),
        border: Border(top: BorderSide(color: Color(0xFFE4E4E4))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            label: 'Requested Amount',
            value: '${String.fromCharCode(8377)}$requestedAmount',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'TDS (Less)',
            value: '${String.fromCharCode(8377)}$tds',
            labelColor: const Color(0xFF00B421),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Tax (Add)',
            value: '${String.fromCharCode(8377)}$tax',
            labelColor: const Color(0xFFFB0000),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Payable Amount',
            value: '${String.fromCharCode(8377)}$payable',
            isBold: true,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!showActionButtons)
                GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Image.asset(
                      'assets/icons/edit_icon.png',
                      width: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (isApproving || isRejecting) ? null : onRejectTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4B4B),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isRejecting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Reject',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (isApproving || isRejecting) ? null : onApproveTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1BA8FF),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isApproving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Approve',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
