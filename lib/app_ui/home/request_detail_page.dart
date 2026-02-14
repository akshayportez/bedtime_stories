part of 'package:bedtime_stories/utils/lib_files.dart';

class RequestDetailPage extends StatefulWidget {
  final BedtimePaymentRequest request;

  const RequestDetailPage({super.key, required this.request});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  bool _isDeleting = false;
  bool _showApprovedRequestDetails = false;
  bool _showRejectedRequestDetails = false;
  bool _showPaidRequestDetails = false;

  String get _status => widget.request.cStatus.trim();

  bool get _isRequested =>
      _status.toLowerCase() == "requested" ||
      _status.toLowerCase() == "reqested";

  bool get _isApproved => _status.toLowerCase() == "approved";

  bool get _isPaid => _status.toLowerCase() == "paid";

  bool get _isRejected => _status.toLowerCase() == "rejected";

  String _money(double value) => value.toStringAsFixed(2);

  Widget _inlineValueBox({required String value}) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCDDEB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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
                        onPressed: _isDeleting
                            ? null
                            : () async {
                                setState(() => _isDeleting = true);
                                try {
                                  await context
                                      .read<BedtimePaymentRequestDetailBloc>()
                                      .repository
                                      .deletePaymentRequest(
                                        companyId: 1,
                                        payReqId: widget.request.nPayReqId,
                                      );
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  Navigator.pop(context, "deleted");
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
                              },
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

  Future<void> _openEditPage({
    required BedtimePaymentRequestDetail? detail,
    required List<BedtimePaymentRequestTax> taxes,
  }) async {
    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait, request details are loading")),
      );
      return;
    }

    final isUpdated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditRequestPage(
          request: widget.request,
          detail: detail,
          taxes: taxes,
        ),
      ),
    );

    if (isUpdated == true && mounted) {
      Navigator.pop(context, "updated");
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
              title: "Request",
              onBack: () => Navigator.pop(context),
              onEdit: null,
            ),

            if (_isApproved)
              _ExpandableStatusBanner(
                label: "Approved",
                details:
                    "(by ${request.cApprovedBy ?? ""} on ${request.cApprovedDateTime ?? ""})",
                isExpanded: _showApprovedRequestDetails,
                onTap: () {
                  setState(() {
                    _showApprovedRequestDetails = !_showApprovedRequestDetails;
                  });
                },
                expandedChild: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    children: [
                      const TextSpan(text: "Requested "),
                      TextSpan(
                        text:
                            "(by you on ${request.cRequestDateTime ?? ""})",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isPaid)
              _ExpandableStatusBanner(
                label: "Paid",
                details:
                    "(by ${(request.cPaidBy ?? "").trim().isEmpty ? "you" : request.cPaidBy} on ${request.cVoucherDateTime ?? ""})",
                isExpanded: _showPaidRequestDetails,
                onTap: () {
                  setState(() {
                    _showPaidRequestDetails = !_showPaidRequestDetails;
                  });
                },
                expandedChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        children: [
                          const TextSpan(text: "Approved "),
                          TextSpan(
                            text:
                                "(by ${(request.cApprovedBy ?? "").trim().isEmpty ? "you" : request.cApprovedBy} on ${request.cApprovedDateTime ?? ""})",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF3C3C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        children: [
                          const TextSpan(text: "Requested "),
                          TextSpan(
                            text:
                                "(by you on ${request.cRequestDateTime ?? ""})",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF3C3C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (_isRejected)
              _ExpandableStatusBanner(
                label: "Rejected",
                details:
                    "(by ${request.cRejectedBy ?? ""} on ${request.cRejectedDateTime ?? ""})",
                isExpanded: _showRejectedRequestDetails,
                onTap: () {
                  setState(() {
                    _showRejectedRequestDetails = !_showRejectedRequestDetails;
                  });
                },
                expandedChild: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    children: [
                      const TextSpan(text: "Requested "),
                      TextSpan(
                        text:
                            "(by you on ${request.cRequestDateTime ?? ""})",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF3C3C3C),
                        ),
                      ),
                    ],
                  ),
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
                      final isTaxable = detail?.bTaxable ?? false;
                      final attachments = _attachmentList(
                        detail?.cAttachment ?? "",
                      );

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  if (!(_isApproved || _isRejected || _isPaid))
                                    Row(
                                      children: [
                                        Text(
                                          "Req No : ${request.cRequestNo}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          request.cRequestDateTime ?? "",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF242424),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 14),
                                  _DetailField(
                                    label: "Account",
                                    value: request.cAccountName,
                                    showArrow: true,
                                  ),
                                  const SizedBox(height: 14),
                                  _DetailField(
                                    label: "Category",
                                    value: request.cCategoryName,
                                    showArrow: true,
                                  ),
                                  const SizedBox(height: 14),
                                  _DetailField(
                                    label: "Section",
                                    value: request.cSectionName,
                                    showArrow: true,
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    "Requested Amount",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: _inlineValueBox(
                                          value:
                                              "\u20B9 ${_money(requestedAmount)}",
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const _BlueCheckBox(),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "TDS",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 76,
                                        child: _inlineValueBox(
                                          value: "${_money(tdsPercent)} %",
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const _BlueCheckBox(),
                                      const SizedBox(width: 6),
                                      Text(
                                        isTaxable ? "Taxable" : "Non Taxable",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _TaxTable(taxes: taxes),
                                  const SizedBox(height: 14),
                                  _DetailField(
                                    label: "Comment",
                                    value: comment.isEmpty ? "-" : comment,
                                    height: 120,
                                    multiline: true,
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    "Uploaded Files",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (attachments.isEmpty)
                                    const Text(
                                      "No attachments",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF494949),
                                      ),
                                    ),
                                  for (final file in attachments) ...[
                                    _UploadRow(
                                      title: file,
                                      size: "Loading...",
                                      enableImagePreview: true,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  const SizedBox(height: 140),
                                ],
                              ),
                            ),
                          ),
                          _RequestSummaryBar(
                            requestedAmount: _money(requestedAmount),
                            tds: _money(tdsAmount),
                            tax: _money(taxAmount),
                            payable: _money(payableAmount),
                            showActions: _isRequested || _isRejected,
                            onEdit: _isRequested || _isRejected
                                ? () => _openEditPage(detail: detail, taxes: taxes)
                                : null,
                            onDelete: _isRequested || _isRejected
                                ? _showDeleteDialog
                                : null,
                            onPrimary: null,
                            primaryLabel: null,
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

class _RequestDetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onEdit;

  const _RequestDetailHeader({
    required this.title,
    required this.onBack,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // if (onEdit != null)
          //   GestureDetector(
          //     onTap: onEdit,
          //     child: Container(
          //       width: 36,
          //       height: 36,
          //       decoration: BoxDecoration(
          //         border: Border.all(color: Colors.black),
          //         borderRadius: BorderRadius.circular(6),
          //       ),
          //       child: const Icon(Icons.edit, size: 18),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String label;
  final String details;

  const _StatusBanner({required this.label, required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 38,
      color: const Color(0xFFE5F2FE),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black),
          children: [
            TextSpan(text: "$label "),
            TextSpan(
              text: details,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF3C3C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableStatusBanner extends StatelessWidget {
  final String label;
  final String details;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget expandedChild;

  const _ExpandableStatusBanner({
    required this.label,
    required this.details,
    required this.isExpanded,
    required this.onTap,
    required this.expandedChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE5F2FE),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        children: [
                          TextSpan(text: "$label "),
                          TextSpan(
                            text: details,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF3C3C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: const Color(0xFF3C3C3C),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: expandedChild,
            ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  final bool showArrow;
  final bool leadingDot;
  final bool multiline;
  final double height;

  const _DetailField({
    required this.label,
    required this.value,
    this.showArrow = false,
    this.leadingDot = false,
    this.multiline = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFCCDDEB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (leadingDot)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0096FB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  maxLines: multiline ? 6 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // if (showArrow)
              //   const Icon(Icons.chevron_right, size: 18, color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlueCheckBox extends StatelessWidget {
  const _BlueCheckBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF0096FB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.check,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

class _TaxTable extends StatelessWidget {
  final List<BedtimePaymentRequestTax> taxes;

  const _TaxTable({this.taxes = const []});

  static const Color _lineColor = Color(0xFF98D5F9);
  static const Color _headerColor = Color(0xFFA9CFE6);

  Widget _cell({
    required String text,
    required bool isHeader,
    required EdgeInsetsGeometry padding,
  }) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 13 : 14,
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildRow({
    required String name,
    required String rate,
    required bool isHeader,
    bool showTopDivider = false,
  }) {
    final rowHeight = isHeader ? 40.0 : 36.0;
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        color: isHeader ? _headerColor : Colors.white,
        border: showTopDivider
            ? const Border(
                top: BorderSide(color: _lineColor, width: 0.6),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _cell(
              text: name,
              isHeader: isHeader,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          Container(
            width: 0.8,
            color: _lineColor,
          ),
          Expanded(
            child: _cell(
              text: rate,
              isHeader: isHeader,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = taxes.isEmpty
        ? const <Map<String, String>>[
            {"name": "-", "rate": "-"},
          ]
        : taxes
            .map(
              (tax) => {
                "name": tax.cTaxName,
                "rate": "${tax.nTaxRate} %",
              },
            )
            .toList();

    return Align(
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 320 ? 320.0 : constraints.maxWidth;
          return SizedBox(
            width: width,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _lineColor, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRow(
                    name: "Tax Name",
                    rate: "Tax Rate %",
                    isHeader: true,
                  ),
                  for (var i = 0; i < rows.length; i++)
                    _buildRow(
                      name: rows[i]["name"] ?? "-",
                      rate: rows[i]["rate"] ?? "-",
                      isHeader: false,
                      showTopDivider: true,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  final String title;
  final String size;
  final bool enableImagePreview;

  const _UploadRow({
    required this.title,
    required this.size,
    this.enableImagePreview = false,
  });

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

  void _openImagePreview(BuildContext context, String imageUrl) {
    if (!enableImagePreview || imageUrl.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "-";
    const units = ["B", "KB", "MB", "GB"];
    double value = bytes.toDouble();
    int unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    final text = value >= 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return "$text ${units[unitIndex]}";
  }

  String _displayName(String raw) {
    return raw.split('/').last.split('\\').last;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl(title);
    if (!enableImagePreview) {
      return _RequestAttachmentTile(
        title: _displayName(title),
        imageUrl: imageUrl,
        sizeText: size,
        onTap: () => _openImagePreview(context, imageUrl),
      );
    }
    return _RequestAttachmentTile(
      title: _displayName(title),
      imageUrl: imageUrl,
      sizeText: size.trim().isEmpty ? "Loading..." : size,
      onTap: () => _openImagePreview(context, imageUrl),
      formatBytes: _formatBytes,
    );
  }
}

class _RequestAttachmentTile extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String sizeText;
  final VoidCallback onTap;
  final String Function(int bytes)? formatBytes;

  const _RequestAttachmentTile({
    required this.title,
    required this.imageUrl,
    required this.sizeText,
    required this.onTap,
    this.formatBytes,
  });

  @override
  State<_RequestAttachmentTile> createState() => _RequestAttachmentTileState();
}

class _RequestAttachmentTileState extends State<_RequestAttachmentTile> {
  String? _resolvedSize;

  @override
  void initState() {
    super.initState();
    _resolveSize();
  }

  @override
  void didUpdateWidget(covariant _RequestAttachmentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolvedSize = null;
      _resolveSize();
    }
  }

  Future<void> _resolveSize() async {
    if (widget.imageUrl.isEmpty || widget.formatBytes == null) return;
    try {
      final provider = NetworkImage(widget.imageUrl);
      final stream = provider.resolve(const ImageConfiguration());
      final completer = Completer<int>();
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (_, __) {},
        onChunk: (chunk) {
          if (!completer.isCompleted &&
              chunk.expectedTotalBytes != null &&
              chunk.expectedTotalBytes! > 0) {
            completer.complete(chunk.expectedTotalBytes!);
            stream.removeListener(listener);
          }
        },
        onError: (_, __) {
          if (!completer.isCompleted) completer.complete(0);
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);
      final bytes = await completer.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () => 0,
      );
      if (!mounted || bytes <= 0) return;
      setState(() {
        _resolvedSize = widget.formatBytes!(bytes);
      });
    } catch (_) {
      // Keep fallback text.
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeText = (_resolvedSize ?? widget.sizeText).trim().isEmpty
        ? "-"
        : (_resolvedSize ?? widget.sizeText);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFA7DDFD)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.imageUrl.isEmpty
                  ? const Icon(Icons.image, size: 20, color: Colors.black54)
                  : Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.image,
                          size: 20,
                          color: Colors.black54,
                        );
                      },
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sizeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF494949),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _RequestSummaryBar extends StatelessWidget {
  final String requestedAmount;
  final String tds;
  final String tax;
  final String payable;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrimary;
  final String? primaryLabel;
  final double bottomPadding;

  const _RequestSummaryBar({
    required this.requestedAmount,
    required this.tds,
    required this.tax,
    required this.payable,
    required this.showActions,
    required this.onEdit,
    required this.onDelete,
    required this.onPrimary,
    required this.primaryLabel,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomPadding),
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
          _SummaryRow(
            label: "Requested Amount",
            value: "\u20B9$requestedAmount",
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: "TDS (Less)",
            value: "\u20B9$tds",
            labelColor: const Color(0xFF00B421),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: "Tax (Add)",
            value: "\u20B9$tax",
            labelColor: const Color(0xFFFB0000),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: "Payable Amount",
            value: "\u20B9$payable",
            isBold: true,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showActions) ...[
                   
                  
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 47,
                        height: 47,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(
                          "assets/icons/edit_icon.png",
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                      const SizedBox(width: 10),
                     GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 47,
                        height: 47,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(
                          "assets/icons/delete_icon.png",
                          width: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                  if (onPrimary != null && primaryLabel != null) ...[
                    if (showActions) const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        primaryLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: labelColor ?? Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
