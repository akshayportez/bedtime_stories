part of 'package:bedtime_stories/utils/lib_files.dart';

class VoucherViewPage extends StatefulWidget {
  final BedtimePaymentRequest request;

  const VoucherViewPage({super.key, required this.request});

  @override
  State<VoucherViewPage> createState() => _VoucherViewPageState();
}

class _VoucherViewPageState extends State<VoucherViewPage> {
  bool _showPaidDetails = false;
  bool _isDeleting = false;
  bool _isSuccessDialogVisible = false;
  bool _isSharingPdf = false;
  bool _isPrintingPdf = false;

  String _money(double value) => value.toStringAsFixed(2);
  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  Future<int> _getStoredUserActionId() async {
    final userData = await BedtimeLocalStorage.getUserData();
    return _resolveInt(userData["userId"]);
  }

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

  String _who(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? 'you' : text;
  }

  String _on(String? value) {
    return (value ?? '').trim();
  }

  String _paidBannerText() {
    final by = _who(widget.request.cPaidBy);
    final on = _on(widget.request.cVoucherDateTime);
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

  Future<void> _showDeleteSuccessDialog() async {
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
                  "Voucher Deleted Successfully",
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

  Future<void> _deleteVoucher() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    try {
      final userData = await BedtimeLocalStorage.getUserData();
      final userActionId = _resolveInt(userData["userId"]);

      await context.read<BedtimePaymentVoucherDetailBloc>().repository
          .deletePaymentVoucher(
            companyId: 1,
            payReqId: widget.request.nPayReqId,
            userActionId: userActionId,
          );
      if (!mounted) return;

      Navigator.pop(context);

      final rootNavigator = Navigator.of(context, rootNavigator: true);
      unawaited(
        Future<void>.delayed(const Duration(seconds: 2), () {
          if (!rootNavigator.mounted) return;
          if (rootNavigator.canPop()) {
            rootNavigator.pop();
          }
        }),
      );

      await _showDeleteSuccessDialog();
      _isSuccessDialogVisible = false;
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
                Image.asset(
                  "assets/icons/delete_animation.gif",
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Delete",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Do you really want to delete these records?\nThis process cannot be undone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isDeleting ? null : _deleteVoucher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
      final userActionId = await _getStoredUserActionId();
      context.read<BedtimePaymentVoucherPdfBloc>().add(
        BedtimePaymentVoucherPdfLoadRequested(
          companyId: 1,
          payReqId: widget.request.nPayReqId,
          userActionId: userActionId,
        ),
      );
    }
  }

  Future<BedtimePaymentVoucherPdfLoaded> _ensureVoucherPdfLoaded() async {
    final bloc = context.read<BedtimePaymentVoucherPdfBloc>();
    final payReqId = widget.request.nPayReqId;
    final currentState = bloc.state;

    if (currentState is BedtimePaymentVoucherPdfLoaded &&
        currentState.payReqId == payReqId) {
      return currentState;
    }

    final isAlreadyLoading =
        currentState is BedtimePaymentVoucherPdfLoading &&
        currentState.payReqId == payReqId;

    if (!isAlreadyLoading) {
      final userActionId = await _getStoredUserActionId();
      bloc.add(
        BedtimePaymentVoucherPdfLoadRequested(
          companyId: 1,
          payReqId: payReqId,
          userActionId: userActionId,
        ),
      );
    }

    final state = await bloc.stream.firstWhere((state) {
      if (state is BedtimePaymentVoucherPdfLoaded) {
        return state.payReqId == payReqId;
      }
      if (state is BedtimePaymentVoucherPdfFailure) {
        return state.payReqId == payReqId;
      }
      return false;
    });

    if (state is BedtimePaymentVoucherPdfLoaded) {
      return state;
    }
    if (state is BedtimePaymentVoucherPdfFailure) {
      throw Exception(state.message);
    }
    throw Exception('Unable to load voucher PDF');
  }

  Future<void> _openVoucherPdf() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Preparing PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

      final pdfState = await _ensureVoucherPdfLoaded();
      if (!mounted) return;

      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => _VoucherPdfViewerPage(
            title: 'Voucher PDF',
            pdfBytes: pdfState.pdfBytes,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to open PDF: $e')),
      );
    }
  }

  String _buildPdfFileName([String? suggestedName]) {
    var candidateName = (suggestedName ?? '').trim();
    candidateName = candidateName.split('/').last.split('\\').last;
    candidateName = candidateName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

    final now = DateTime.now().millisecondsSinceEpoch;
    final hasValidPdfName =
        candidateName.isNotEmpty &&
        candidateName.toLowerCase().endsWith('.pdf') &&
        candidateName != '.pdf';

    if (!hasValidPdfName) {
      return 'voucher_${widget.request.nPayReqId}_$now.pdf';
    }

    final baseName = candidateName.replaceFirst(
      RegExp(r'\.pdf$', caseSensitive: false),
      '',
    );
    return '${baseName}_$now.pdf';
  }

  Future<File> _downloadPdfToTempFile(Uint8List pdfBytes) async {
    final fileName = _buildPdfFileName();
    final filePath =
        '${Directory.systemTemp.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }

  Future<void> _shareVoucherPdf() async {
    if (_isSharingPdf) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSharingPdf = true);

    try {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Preparing PDF to share...'),
          duration: Duration(seconds: 1),
        ),
      );

      final pdfState = await _ensureVoucherPdfLoaded();
      final pdfFile = await _downloadPdfToTempFile(pdfState.pdfBytes);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(pdfFile.path, mimeType: 'application/pdf'),
          ],
          text: 'Voucher PDF',
          subject: 'Voucher PDF',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to share PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharingPdf = false);
      }
    }
  }

  Future<void> _printVoucherPdf() async {
    if (_isPrintingPdf) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isPrintingPdf = true);

    try {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Preparing PDF for print...'),
          duration: Duration(seconds: 1),
        ),
      );

      final pdfState = await _ensureVoucherPdfLoaded();
      if (!mounted) return;

      await Printing.layoutPdf(
        name: _buildPdfFileName(),
        onLayout: (_) async => pdfState.pdfBytes,
      );
    } catch (e) {
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to print PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrintingPdf = false);
      }
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
            _ExpandableStatusBanner(
              label: 'Paid',
              details: _paidBannerText(),
              isExpanded: _showPaidDetails,
              onTap: () {
                setState(() {
                  _showPaidDetails = !_showPaidDetails;
                });
              },
              expandedChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Approved '),
                        TextSpan(
                          text:
                              '(by ${_who(request.cApprovedBy)} on ${_on(request.cApprovedDateTime)})',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF3C3C3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Requested '),
                        TextSpan(
                          text:
                              '(by ${_who(request.cRequestedBy)} on ${_on(request.cRequestDateTime)})',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF3C3C3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Req No : ${request.cRequestNo}',
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
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Comments ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: comment.isEmpty ? '-' : comment,
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
                        onDeleteTap: _showDeleteDialog,
                        onPrintPdfTap: _isPrintingPdf ? null : _printVoucherPdf,
                        onViewPdfTap: _openVoucherPdf,
                        onSharePdfTap: _isSharingPdf ? null : _shareVoucherPdf,
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
  final VoidCallback? onDeleteTap;
  final VoidCallback? onPrintPdfTap;
  final VoidCallback? onViewPdfTap;
  final VoidCallback? onSharePdfTap;
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
    required this.onDeleteTap,
    required this.onPrintPdfTap,
    required this.onViewPdfTap,
    required this.onSharePdfTap,
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
              GestureDetector(
                onTap: onPrintPdfTap,
                child: const _VoucherActionIcon(
                  assetPath: 'assets/icons/print_icon.png',
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onViewPdfTap,
                child: const _VoucherActionIcon(
                  assetPath: 'assets/icons/watch_icon.png',
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onSharePdfTap,
                child: const _VoucherActionIcon(
                  assetPath: 'assets/icons/share_icon.png',
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onEditTap,
                child: const _VoucherActionIcon(
                  assetPath: 'assets/icons/edit_voucher.png',
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDeleteTap,
                child: const _VoucherActionIcon(
                  assetPath: 'assets/icons/delete_voucher.png',
                  backgroundColor: Color(0xFFFF4545),
                  borderColor: Color(0xFFFF4545),
                  iconColor: Colors.white,
                ),
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

class _VoucherPdfViewerPage extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;

  const _VoucherPdfViewerPage({required this.title, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SfPdfViewer.memory(
        pdfBytes,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to load PDF: ${details.error}')),
          );
        },
      ),
    );
  }
}
