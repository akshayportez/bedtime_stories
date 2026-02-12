part of 'package:bedtime_stories/utils/lib_files.dart';

class VoucherViewPage extends StatefulWidget {
  final BedtimePaymentRequest request;

  const VoucherViewPage({super.key, required this.request});

  @override
  State<VoucherViewPage> createState() => _VoucherViewPageState();
}

class _VoucherViewPageState extends State<VoucherViewPage> {
  String _money(double value) => value.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    _loadVoucherDetail();
  }

  void _loadVoucherDetail() {
    context.read<BedtimePaymentVoucherDetailBloc>().add(
      BedtimePaymentVoucherDetailLoadRequested(
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

  String _paidBannerText() {
    final approvedBy = widget.request.cApprovedBy ?? '';
    final by = approvedBy.trim().isEmpty ? 'you' : approvedBy;
    final on = (widget.request.cVoucherDateTime ?? '').trim();
    if (on.isEmpty) return '(by $by)';
    return '(by $by on $on)';
  }

  List<String> _mergeAttachments(
    List<String> files,
    String rawAttachment,
  ) {
    final result = <String>{...files};
    for (final path in _attachmentList(rawAttachment)) {
      result.add(path);
    }
    return result.toList();
  }

  Future<void> _openEditPage(BedtimePaymentVoucherDetailResponse detail) async {
    final didUpdate = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VoucherEditPage(
          request: widget.request,
          voucherDetail: detail,
        ),
      ),
    );

    if (didUpdate == true && mounted) {
      _loadVoucherDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _RequestDetailHeader(
              title: 'Voucher',
              onBack: () => Navigator.pop(context),
            ),
            _StatusBanner(label: 'Paid', details: _paidBannerText()),
            Expanded(
              child:
                  BlocBuilder<
                    BedtimePaymentVoucherDetailBloc,
                    BedtimePaymentVoucherDetailState
                  >(
                builder: (context, state) {
                  BedtimePaymentVoucherDetailResponse? detail;

                  if (state is BedtimePaymentVoucherDetailLoaded) {
                    detail = state.detail;
                  }

                  if (state is BedtimePaymentVoucherDetailFailure) {
                    return Center(child: Text(state.message));
                  }

                  if (state is BedtimePaymentVoucherDetailLoading &&
                      detail == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final reqHdr = detail?.reqHdr;
                  final payDtl = detail?.payDtl;
                  final voucherHdr = detail?.voucherHdr;
                  final taxes = (detail?.taxDtl ?? const <BedtimePaymentVoucherTax>[])
                      .map(
                        (e) => BedtimePaymentRequestTax(
                          nTaxId: e.nTaxId,
                          cTaxName: e.cTaxName,
                          nTaxRate: e.nTaxRate,
                        ),
                      )
                      .toList();

                  final requestedAmount =
                      reqHdr?.nRequestedAmount ?? request.nPayableAmount;
                  final tdsPercent = reqHdr?.nTDSPercent ?? 0.0;
                  final tdsAmount = reqHdr?.nTDSAmt ?? 0.0;
                  final taxAmount = reqHdr?.nTaxAmount ?? 0.0;
                  final payableAmount =
                      reqHdr?.nPayableAmount ?? request.nPayableAmount;
                  final comment = reqHdr?.cComment ?? '';
                  final attachments = _mergeAttachments(
                    detail?.files ?? const [],
                    reqHdr?.cAttachment ?? '',
                  );
                  final payMode = (voucherHdr?.cPayMode ?? '').trim();

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
                                      'Voucher No : ${(request.cVoucherNo ?? '').isEmpty ? request.cRequestNo : (request.cVoucherNo ?? '')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    request.cVoucherDateTime ??
                                        request.cRequestDateTime ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                                  _ApprovalInfoCard(
                                account: reqHdr?.cAccountName.isNotEmpty == true
                                    ? reqHdr!.cAccountName
                                    : request.cAccountName,
                                category: reqHdr?.cCategoryName.isNotEmpty == true
                                    ? reqHdr!.cCategoryName
                                    : request.cCategoryName,
                                section: reqHdr?.cSectionName.isNotEmpty == true
                                    ? reqHdr!.cSectionName
                                    : request.cSectionName,
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
                              const SizedBox(height: 140),
                            ],
                          ),
                        ),
                      ),
                      _VoucherViewSummaryBar(
                        requestedAmount: _money(requestedAmount),
                        tds: _money(tdsAmount),
                        tax: _money(taxAmount),
                        payable: _money(payableAmount),
                        payMode: payMode,
                        chequeNumber: payDtl?.cChequeNo ?? '',
                        chequeDate: payDtl?.dChequeDate ?? '',
                        bankName: payDtl?.cBankName ?? '',
                        upiRefNo: payDtl?.cUPIRefNo ?? '',
                        upiApp: payDtl?.cUpiApp ?? '',
                        onEditTap: detail == null
                            ? null
                            : () => _openEditPage(detail!),
                        bottomPadding: bottomInset,
                      ),
                    ],
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

class _VoucherViewSummaryBar extends StatelessWidget {
  final String requestedAmount;
  final String tds;
  final String tax;
  final String payable;
  final String payMode;
  final String chequeNumber;
  final String chequeDate;
  final String bankName;
  final String upiRefNo;
  final String upiApp;
  final VoidCallback? onEditTap;
  final double bottomPadding;

  const _VoucherViewSummaryBar({
    required this.requestedAmount,
    required this.tds,
    required this.tax,
    required this.payable,
    required this.payMode,
    required this.chequeNumber,
    required this.chequeDate,
    required this.bankName,
    required this.upiRefNo,
    required this.upiApp,
    required this.onEditTap,
    required this.bottomPadding,
  });

  List<Widget> _payModeInfo() {
    final mode = payMode.trim().toLowerCase();
    final rows = <Widget>[
      Text(
        'Paymode : ${payMode.isEmpty ? '-' : payMode}',
        style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
      ),
    ];

    if (mode == 'bank') {
      rows.add(const SizedBox(height: 3));
      rows.add(
        Text(
          'Bank Name : ${bankName.isEmpty ? '-' : bankName}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        ),
      );
      return rows;
    }

    if (mode == 'cheque') {
      rows.add(const SizedBox(height: 3));
      rows.add(
        Text(
          'Cheque number : ${chequeNumber.isEmpty ? '-' : chequeNumber}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        ),
      );
      rows.add(const SizedBox(height: 3));
      rows.add(
        Text(
          'Date : ${chequeDate.isEmpty ? '-' : chequeDate}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        ),
      );
      rows.add(const SizedBox(height: 3));
      rows.add(
        Text(
          'Bank Name : ${bankName.isEmpty ? '-' : bankName}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        ),
      );
      return rows;
    }

    if (mode == 'upi') {
      rows.add(const SizedBox(height: 3));
      rows.add(
        Text(
          'UPI Ref No : ${upiRefNo.isEmpty ? '-' : upiRefNo}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        ),
      );
      rows.add(const SizedBox(height: 3));
      rows.add(
        Text(
          'UPI App : ${upiApp.isEmpty ? '-' : upiApp}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
        ),
      );
      return rows;
    }

    return rows;
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ..._payModeInfo(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const _VoucherActionIcon(assetPath: 'assets/icons/print_icon.png'),
              const SizedBox(width: 10),
              const _VoucherActionIcon(assetPath: 'assets/icons/watch_icon.png'),
              const SizedBox(width: 10),
              const _VoucherActionIcon(assetPath: 'assets/icons/share_icon.png'),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onEditTap,
                child: const _VoucherActionIcon(
                  assetPath: 'assets/icons/edit_icon.png',
                ),
              ),
              const SizedBox(width: 10),
              const _VoucherActionIcon(
                assetPath: 'assets/icons/delete_icon.png',
                backgroundColor: Color(0xFFFF4545),
                borderColor: Color(0xFFFF4545),
                iconColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoucherActionIcon extends StatelessWidget {
  final String assetPath;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const _VoucherActionIcon({
    required this.assetPath,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFF888888),
    this.iconColor = const Color(0xFF2D2D2D),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        color: iconColor,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
