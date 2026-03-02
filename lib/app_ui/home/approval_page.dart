part of 'package:bedtime_stories/utils/lib_files.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final TextEditingController _searchController = TextEditingController();
  late final BedtimePaymentRequestBloc _approvalBloc;
  bool _permissionsLoaded = false;
  bool _canViewApprovalPage = false;
  bool _canViewApprovalDetailPage = false;
  int _projectId = 0;
  int _userActionId = 0;
  String _statusFilter = "";
  String _dFrom = "";
  String _dTo = "";

  @override
  void initState() {
    super.initState();
    _approvalBloc = BedtimePaymentRequestBloc(
      context.read<BedtimePaymentRequestBloc>().repository,
    );
    BedtimeLocalStorage.selectedProjectChangeNotifier.addListener(
      _handleSelectedProjectChanged,
    );
    BedtimeLocalStorage.paymentDataChangeNotifier.addListener(
      _handlePaymentDataChanged,
    );
    _initializePage();
  }

  @override
  void dispose() {
    BedtimeLocalStorage.selectedProjectChangeNotifier.removeListener(
      _handleSelectedProjectChanged,
    );
    BedtimeLocalStorage.paymentDataChangeNotifier.removeListener(
      _handlePaymentDataChanged,
    );
    _approvalBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSelectedProjectChanged() {
    if (!_canViewApprovalPage) return;
    unawaited(_loadApprovals());
  }

  void _handlePaymentDataChanged() {
    if (!_canViewApprovalPage) return;
    unawaited(_loadApprovals());
  }

  Future<void> _initializePage() async {
    final permissionSet = await BedtimeLocalStorage.getMenuPermissionSet();
    final canViewApprovalPage = permissionSet.contains("paymentapproval");
    final canViewApprovalDetailPage =
        permissionSet.contains("transaction-paymentapproval-view");
    if (!mounted) return;
    setState(() {
      _canViewApprovalPage = canViewApprovalPage;
      _canViewApprovalDetailPage = canViewApprovalDetailPage;
      _permissionsLoaded = true;
    });
    if (!canViewApprovalPage) return;
    await _loadApprovals();
  }

  Future<int?> _getStoredUserId() async {
    return BedtimeLocalStorage.getUserId();
  }

  Future<void> _loadApprovals() async {
    if (!_canViewApprovalPage) return;
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userIdValue = await _getStoredUserId();
    _projectId = projectId;
    _userActionId = userIdValue ?? 0;

    if (!mounted) return;
    if (_userActionId <= 0) return;

    _approvalBloc.add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: projectId,
        userActionId: _userActionId,
        search: "",
        statusFilter: _statusFilter,
        cStatus: "APPROVAL",
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
    if (!_canViewApprovalPage) return;
    if (_userActionId == 0) {
      _getStoredUserId().then((resolvedUserId) {
        if (!mounted) return;
        if (resolvedUserId == null || resolvedUserId <= 0) return;
        _userActionId = resolvedUserId;
        _approvalBloc.add(
          BedtimePaymentRequestSearchRequested(
            companyId: 1,
            projectId: _projectId,
            userActionId: _userActionId,
            search: value.trim(),
            statusFilter: _statusFilter,
            cStatus: "APPROVAL",
            dFrom: _dFrom,
            dTo: _dTo,
          ),
        );
      });
      return;
    }

    _approvalBloc.add(
      BedtimePaymentRequestSearchRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: value.trim(),
        statusFilter: _statusFilter,
        cStatus: "APPROVAL",
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

  String _selectedDateRangeText() {
    if (_dFrom.isEmpty && _dTo.isEmpty) return "";
    if (_dFrom.isNotEmpty && _dTo.isNotEmpty) {
      return "Date: $_dFrom - $_dTo";
    }
    return "Date: ${_dFrom.isNotEmpty ? _dFrom : _dTo}";
  }

  Future<void> _openFilterSheet() async {
    if (!_canViewApprovalPage) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ApprovalFilterBottomSheet(
          initialStatus: _statusFilter,
          initialFromDate: _dFrom.isEmpty ? null : DateTime.tryParse(_dFrom),
          initialToDate: _dTo.isEmpty ? null : DateTime.tryParse(_dTo),
          onApply: (fromDate, toDate, status) async {
            _statusFilter = status;
            if (fromDate == null && toDate == null) {
              _dFrom = "";
              _dTo = "";
            } else {
              _dFrom = fromDate == null ? "" : _formatDate(fromDate);
              _dTo = toDate == null ? "" : _formatDate(toDate);
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
    final selectedDateRangeText = _selectedDateRangeText();

    return Scaffold(
      appBar: BedtimeGradientAppBar(onProjectTap: _openProjectSelectionSheet),
      body: !_permissionsLoaded
          ? const Center(child: CircularProgressIndicator())
          : !_canViewApprovalPage
              ? const Center(
                  child: Text(
                    "No permission to view approval page",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5F5F5F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Padding(
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
            if (selectedDateRangeText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedDateRangeText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child:
                  BlocBuilder<
                    BedtimePaymentRequestBloc,
                    BedtimePaymentRequestState
                  >(
                    bloc: _approvalBloc,
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
                                if (!_canViewApprovalDetailPage) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "No permission to view approval detail page",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ApprovalDetailPage(request: request),
                                  ),
                                );
                                if (updated == true) {
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

class _ApprovalFilterBottomSheet extends StatefulWidget {
  final String initialStatus;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final void Function(DateTime? fromDate, DateTime? toDate, String status)
  onApply;

  const _ApprovalFilterBottomSheet({
    required this.initialStatus,
    required this.initialFromDate,
    required this.initialToDate,
    required this.onApply,
  });

  @override
  State<_ApprovalFilterBottomSheet> createState() =>
      _ApprovalFilterBottomSheetState();
}

class _ApprovalFilterBottomSheetState
    extends State<_ApprovalFilterBottomSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime _activeDate = DateTime.now();
  String _selectedStatus = "";

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
    _activeDate =
        widget.initialToDate ?? widget.initialFromDate ?? DateTime.now();
    _selectedStatus = widget.initialStatus;
  }

  String _formatDate(DateTime date) {
    final y = (date.year % 100).toString().padLeft(2, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$d/$m/$y";
  }

  void _onCalendarDateChanged(DateTime date) {
    setState(() {
      _activeDate = date;
      if (_fromDate == null || _toDate != null) {
        _fromDate = date;
        _toDate = null;
        return;
      }

      if (date.isBefore(_fromDate!)) {
        _toDate = _fromDate;
        _fromDate = date;
      } else {
        _toDate = date;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Container(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: 16 + bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "Filter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: CalendarDatePicker(
                          initialDate: _activeDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          onDateChanged: _onCalendarDateChanged,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "From: ${_fromDate == null ? '-' : _formatDate(_fromDate!)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4C4C4C),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "To: ${_toDate == null ? '-' : _formatDate(_toDate!)}",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4C4C4C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _fromDate = null;
                              _toDate = null;
                            });
                          },
                          child: const Text("Clear range"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 6),
                      _FilterRadioRow(
                        label: "All",
                        value: "",
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                        },
                      ),
                      _FilterRadioRow(
                        label: "Approved",
                        value: "Approved",
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                        },
                      ),
                      _FilterRadioRow(
                        label: "Rejected",
                        value: "Rejected",
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 80,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B84F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      final effectiveToDate = _toDate ?? _fromDate;
                      widget.onApply(
                        _fromDate,
                        effectiveToDate,
                        _selectedStatus,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "OK",
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
                    Text(
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
                  ],
                ),
                const SizedBox(height: 6),
                Container(height: 2, color: const Color(0xFFF3F7FC)),
                const SizedBox(height: 8),
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
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        requestDate,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF3B3B3B),
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
              ],
            ),
          ),
          Container(
            height: 39,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F9FC),
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
