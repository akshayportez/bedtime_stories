part of 'package:bedtime_stories/utils/lib_files.dart';

class RejectApprovePage extends StatefulWidget {
  final BedtimePaymentRequest request;

  const RejectApprovePage({super.key, required this.request});

  @override
  State<RejectApprovePage> createState() => _RejectApprovePageState();
}

class _RejectApprovePageState extends State<RejectApprovePage> {
  bool _isApproving = false;
  bool _isRejecting = false;
  bool _isResultDialogVisible = false;

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

  String _requestedBannerText() {
    final requestedBy = widget.request.cRequestedBy;
    final by = requestedBy.trim().isEmpty ? 'user' : requestedBy;
    final on = (widget.request.cRequestDateTime ?? '').trim();
    if (on.isEmpty) return '(by $by)';
    return '(by $by on $on)';
  }

  Future<void> _showActionSuccessDialog({
    required String gifPath,
    required String title,
    required String message,
  }) async {
    if (_isResultDialogVisible) return;
    _isResultDialogVisible = true;

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
                  gifPath,
                  width: 76,
                  height: 76,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

  Future<void> _onApproveTapped() async {
    if (_isApproving) return;

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
    if (_isRejecting) return;

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
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              unawaited(
                Future<void>.delayed(const Duration(seconds: 2), () {
                  if (!rootNavigator.mounted) return;
                  if (rootNavigator.canPop()) {
                    rootNavigator.pop();
                  }
                }),
              );
              _showActionSuccessDialog(
                gifPath: "assets/icons/succesfull_animation.gif",
                title: "Approved",
                message: "Payment Request Approved Successfully",
              ).then((_) {
                _isResultDialogVisible = false;
                if (!mounted) return;
                Navigator.pop(context, true);
              });
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
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              unawaited(
                Future<void>.delayed(const Duration(seconds: 2), () {
                  if (!rootNavigator.mounted) return;
                  if (rootNavigator.canPop()) {
                    rootNavigator.pop();
                  }
                }),
              );
              _showActionSuccessDialog(
                gifPath: "assets/icons/rejected_animation.gif",
                title: "Rejected",
                message: "Payment Request Rejected",
              ).then((_) {
                _isResultDialogVisible = false;
                if (!mounted) return;
                Navigator.pop(context, true);
              });
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
              _StatusBanner(label: 'Requested', details: _requestedBannerText()),
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
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
                                    'Comments :',
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
                                    _UploadRow(
                                      title: file,
                                      size: 'Loading...',
                                      enableImagePreview: true,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  const SizedBox(height: 110),
                                ],
                              ),
                            ),
                          ),
                            _RejectApproveSummaryBar(
                              requestedAmount: _money(requestedAmount),
                              tds: _money(tdsAmount),
                              tax: _money(taxAmount),
                              payable: _money(payableAmount),
                              bottomPadding: bottomInset,
                              isRejecting: _isRejecting,
                              isApproving: _isApproving,
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

class _RejectApproveSummaryBar extends StatelessWidget {
  final String requestedAmount;
  final String tds;
  final String tax;
  final String payable;
  final double bottomPadding;
  final bool isRejecting;
  final bool isApproving;
  final VoidCallback onRejectTap;
  final VoidCallback onApproveTap;

  const _RejectApproveSummaryBar({
    required this.requestedAmount,
    required this.tds,
    required this.tax,
    required this.payable,
    required this.bottomPadding,
    required this.isRejecting,
    required this.isApproving,
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
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: (isRejecting || isApproving) ? null : onRejectTap,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }
}
