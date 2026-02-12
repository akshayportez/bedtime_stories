part of 'package:bedtime_stories/utils/lib_files.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final TextEditingController _searchController = TextEditingController();
  int _projectId = 0;
  int _userActionId = 0;
  String _statusFilter = "";
  String _dFrom = "";
  String _dTo = "";

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApprovals() async {
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userData = await BedtimeLocalStorage.getUserData();
    final userIdValue = userData["userId"];
    _projectId = projectId;
    _userActionId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? "") ?? 0;

    if (!mounted) return;

    context.read<BedtimePaymentRequestBloc>().add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: projectId,
        userActionId: _userActionId,
        search: "",
        statusFilter: _statusFilter,
        dFrom: _dFrom,
        dTo: _dTo,
      ),
    );
  }

  Future<void> _openProjectSelectionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProjectSelectionBottomSheet(
          onProjectSelected: () async {
            if (!mounted) return;
            setState(() {});
            await _loadApprovals();
          },
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    if (_userActionId == 0) {
      BedtimeLocalStorage.getUserData().then((userData) {
        if (!mounted) return;
        final userIdValue = userData["userId"];
        final resolvedUserId = userIdValue is int
            ? userIdValue
            : int.tryParse(userIdValue?.toString() ?? "") ?? 0;
        _userActionId = resolvedUserId;
        context.read<BedtimePaymentRequestBloc>().add(
          BedtimePaymentRequestSearchRequested(
            companyId: 1,
            projectId: _projectId,
            userActionId: _userActionId,
            search: value.trim(),
            statusFilter: _statusFilter,
            dFrom: _dFrom,
            dTo: _dTo,
          ),
        );
      });
      return;
    }

    context.read<BedtimePaymentRequestBloc>().add(
      BedtimePaymentRequestSearchRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: value.trim(),
        statusFilter: _statusFilter,
        dFrom: _dFrom,
        dTo: _dTo,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RequestFilterBottomSheet(
          initialStatus: _statusFilter,
          initialDate: _dFrom.isEmpty ? null : DateTime.tryParse(_dFrom),
          onApply: (selectedDate, status) async {
            _statusFilter = status;
            if (selectedDate == null) {
              _dFrom = "";
              _dTo = "";
            } else {
              final formatted = _formatDate(selectedDate);
              _dFrom = formatted;
              _dTo = formatted;
            }
            if (mounted) setState(() {});
            await _loadApprovals();
          },
        );
      },
    );
  }

  bool _isApprovalStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == "approved" ||
        normalized == "rejected" ||
        normalized == "paid";
  }

  bool _matchesStatusFilter(String status) {
    if (_statusFilter.trim().isEmpty) return true;
    return status.trim().toLowerCase() == _statusFilter.trim().toLowerCase();
  }

  Color _statusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == "paid") return const Color(0xFF07CE07);
    if (normalized == "approved") return const Color(0xFF07CE07);
    if (normalized == "rejected") return const Color(0xFFFB5F38);
    return const Color(0xFF7F7F7F);
  }

  String _displayStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == "paid") return "Approved (Paid)";
    if (normalized == "approved") return "Approved";
    if (normalized == "rejected") return "Rejected";
    return status;
  }

  String _actionDateValue(BedtimePaymentRequest request) {
    final normalized = request.cStatus.trim().toLowerCase();
    if (normalized == "paid") return request.cVoucherDateTime ?? "-";
    if (normalized == "rejected") return request.cRejectedDateTime ?? "-";
    return request.cApprovedDateTime ?? "-";
  }

  String _formatAmount(double amount) => amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BedtimeGradientAppBar(onProjectTap: _openProjectSelectionSheet),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Approval",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RequestSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: _openFilterSheet,
                    child: Center(
                      child: Image.asset(
                        "assets/icons/filter.png",
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child:
                  BlocBuilder<
                    BedtimePaymentRequestBloc,
                    BedtimePaymentRequestState
                  >(
                    builder: (context, state) {
                      if (state is BedtimePaymentRequestLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is BedtimePaymentRequestFailure) {
                        return Center(child: Text(state.message));
                      }

                      if (state is BedtimePaymentRequestLoaded) {
                        final approvals = state.requests
                            .where((r) => _isApprovalStatus(r.cStatus))
                            .where((r) => _matchesStatusFilter(r.cStatus))
                            .toList();

                        if (approvals.isEmpty) {
                          return const Center(
                            child: Text("No approvals found"),
                          );
                        }

                        final bottomInset = MediaQuery.of(
                          context,
                        ).padding.bottom;
                        return ListView.builder(
                          padding: EdgeInsets.only(
                            bottom: 16 + bottomInset + 96,
                          ),
                          itemCount: approvals.length,
                          itemBuilder: (context, index) {
                            final request = approvals[index];
                            return GestureDetector(
                              onTap: () async {
                                final deleted = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ApprovalDetailPage(request: request),
                                  ),
                                );
                                if (deleted == true) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text("Deleted successfully"),
                                    ),
                                  );
                                  await _loadApprovals();
                                }
                              },
                              child: _ApprovalCard(
                                reqNo: request.cRequestNo,
                                requestedBy: request.cRequestedBy,
                                requestDate: request.cRequestDateTime ?? "-",
                                actionDate: _actionDateValue(request),
                                accountName: request.cAccountName,
                                category: request.cCategoryName,
                                section: request.cSectionName,
                                amount: _formatAmount(request.nPayableAmount),
                                status: _displayStatus(request.cStatus),
                                statusColor: _statusColor(request.cStatus),
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final String reqNo;
  final String requestedBy;
  final String requestDate;
  final String actionDate;
  final String accountName;
  final String category;
  final String section;
  final String amount;
  final String status;
  final Color statusColor;

  const _ApprovalCard({
    required this.reqNo,
    required this.requestedBy,
    required this.requestDate,
    required this.actionDate,
    required this.accountName,
    required this.category,
    required this.section,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCADDF4)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Req No : $reqNo",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      requestDate,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF3B3B3B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(height: 2, color: const Color(0xFFF3F7FC)),
                const SizedBox(height: 8),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        actionDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3B3B3B),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFEAF2FF),
                      child: Text(
                        accountName.isNotEmpty
                            ? accountName[0].toUpperCase()
                            : "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        accountName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "Requested by : ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        requestedBy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F7F7F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        " : $category",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F7F7F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      "Section",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        " : $section",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F7F7F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 39,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F9FC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/icons/payment_animation.gif",
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                const Text(
                  "Payable Amt : ",
                  style: TextStyle(fontSize: 12, color: Color(0xFF7F7F7F)),
                ),
                Flexible(
                  child: Text(
                    "\u20B9$amount",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF256DFB),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
