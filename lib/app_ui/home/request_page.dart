part of 'package:bedtime_stories/utils/lib_files.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final TextEditingController _searchController = TextEditingController();
  late final BedtimePaymentRequestBloc _requestBloc;
  int _projectId = 0;
  int? _userActionId;
  bool _permissionsLoaded = false;
  bool _canViewRequestPage = false;
  bool _canViewRequestDetailPage = false;
  String _statusFilter = "";
  String _dFrom = "";
  String _dTo = "";

  @override
  void initState() {
    super.initState();
    _requestBloc = BedtimePaymentRequestBloc(
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
    _requestBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSelectedProjectChanged() {
    if (!_canViewRequestPage) return;
    unawaited(_loadRequests());
  }

  void _handlePaymentDataChanged() {
    if (!_canViewRequestPage) return;
    unawaited(_loadRequests());
  }

  Future<void> _initializePage() async {
    final permissionSet = await BedtimeLocalStorage.getMenuPermissionSet();
    final canViewRequestPage = permissionSet.contains("paymentrequest");
    final canViewRequestDetailPage =
        permissionSet.contains("transaction-paymentrequest-view");
    if (!mounted) return;
    setState(() {
      _canViewRequestPage = canViewRequestPage;
      _canViewRequestDetailPage = canViewRequestDetailPage;
      _permissionsLoaded = true;
    });
    if (!canViewRequestPage) return;
    await _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!_canViewRequestPage) return;
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userIdValue = await _getStoredUserId();
    _projectId = projectId;
    _userActionId = userIdValue;

    if (!mounted) return;
    if (_userActionId == null) return;

    _requestBloc.add(
          BedtimePaymentRequestLoadRequested(
            companyId: 1,
            projectId: projectId,
            userActionId: _userActionId!,
            search: "",
            statusFilter: _statusFilter,
            dFrom: _dFrom,
            dTo: _dTo,
          ),
        );
  }

  Future<int?> _getStoredUserId() async {
    return BedtimeLocalStorage.getUserId();
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
            await _loadRequests();
          },
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    if (!_canViewRequestPage) return;
    if (_userActionId == null) {
      _getStoredUserId().then((resolvedUserId) {
        if (!mounted) return;
        if (resolvedUserId == null) return;
        _userActionId = resolvedUserId;
        _requestBloc.add(
              BedtimePaymentRequestSearchRequested(
                companyId: 1,
                projectId: _projectId,
                userActionId: _userActionId!,
                search: value.trim(),
                statusFilter: _statusFilter,
                dFrom: _dFrom,
                dTo: _dTo,
              ),
            );
      });
      return;
    }

    final resolvedUserId = _userActionId;
    if (resolvedUserId == null) return;

    _requestBloc.add(
          BedtimePaymentRequestSearchRequested(
            companyId: 1,
            projectId: _projectId,
            userActionId: resolvedUserId,
            search: value.trim(),
            statusFilter: _statusFilter,
            dFrom: _dFrom,
            dTo: _dTo,
          ),
        );
  }

  Color _statusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == "requested" || normalized == "reqested") {
      return const Color(0xFFF6B504);
    }
    if (normalized == "paid") {
      return const Color(0xFF07CE07);
    }
    if (normalized == "approved") {
      return const Color(0xFF0792CE);
    }
    if (normalized == "rejected") {
      return const Color(0xFFFB5F38);
    }
    return const Color(0xFF7F7F7F);
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  Future<void> _openFilterSheet() async {
    if (!_canViewRequestPage) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RequestFilterBottomSheet(
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
            await _loadRequests();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BedtimeGradientAppBar(
        onProjectTap: _openProjectSelectionSheet,
      ),
      body: !_permissionsLoaded
          ? const Center(child: CircularProgressIndicator())
          : !_canViewRequestPage
              ? const Center(
                  child: Text(
                    "No permission to view request page",
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

            /// Page Title
            const Text(
              "Request",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            /// Search + Filter Row
            Row(
              children: [
                Expanded(
                  child: _RequestSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),

                /// Filter Button
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

            /// Request Cards List
            Expanded(
              child: BlocBuilder<BedtimePaymentRequestBloc,
                  BedtimePaymentRequestState>(
                bloc: _requestBloc,
                builder: (context, state) {
                  if (state is BedtimePaymentRequestLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BedtimePaymentRequestFailure) {
                    return Center(child: Text(state.message));
                  }

                  if (state is BedtimePaymentRequestLoaded) {
                    if (state.requests.isEmpty) {
                      return const Center(child: Text("No requests found"));
                    }

                    final bottomInset =
                        MediaQuery.of(context).padding.bottom;
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: 16 + bottomInset + 96,
                      ),
                      itemCount: state.requests.length,
                      itemBuilder: (context, index) {
                        final request = state.requests[index];
                        return GestureDetector(
                          onTap: () async {
                            if (!_canViewRequestDetailPage) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "No rights to view request detail page",
                                  ),
                                ),
                              );
                              return;
                            }

                            final action = await Navigator.push<Object?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RequestDetailPage(request: request),
                              ),
                            );
                            if (action == "deleted" || action == "updated") {
                              if (!mounted) return;
                              if (action == "deleted") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Deleted successfully"),
                                  ),
                                );
                              }
                              await _loadRequests();
                            }
                          },
                          child: _RequestCard(
                            reqNo: request.cRequestNo,
                            dateTime: request.cRequestDateTime ?? "",
                            name: request.cAccountName,
                            category: request.cCategoryName,
                            section: request.cSectionName,
                            amount: _formatAmount(request.nPayableAmount),
                            status: request.cStatus,
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

class _RequestSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _RequestSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: "Search",
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF5F5F5F),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              "assets/icons/search_icon.svg",
              width: 14,
              height: 14,
              fit: BoxFit.contain,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xFF8FBFDE), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xFF8FBFDE), width: 1),
          ),
        ),
      ),
    );
  }
}

class _ProjectSelectionBottomSheet extends StatefulWidget {
  final Future<void> Function() onProjectSelected;

  const _ProjectSelectionBottomSheet({
    required this.onProjectSelected,
  });

  @override
  State<_ProjectSelectionBottomSheet> createState() =>
      _ProjectSelectionBottomSheetState();
}

class _ProjectSelectionBottomSheetState
    extends State<_ProjectSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadProjectsForSavedUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final resolvedUserId = _userId;
    if (resolvedUserId == null) return;

    context.read<BedtimeProjectBloc>().add(
          BedtimeProjectSearchRequested(
            companyId: 1,
            userId: resolvedUserId,
            search: value.trim(),
          ),
        );
  }

  Future<void> _loadProjectsForSavedUser() async {
    final userData = await BedtimeLocalStorage.getUserData();
    final userIdValue = userData["userId"];
    final resolvedUserId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? "") ?? 1;

    if (!mounted) return;

    setState(() {
      _userId = resolvedUserId;
    });

    context.read<BedtimeProjectBloc>().add(
          BedtimeProjectLoadRequested(companyId: 1, userId: resolvedUserId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: 18 + bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "Select Project",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: appPrimaryColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Please choose a project to continue",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: TextFormField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/icons/search_icon.svg",
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                      ),
                    ),
                    hintText: "Search",
                    hintStyle: const TextStyle(
                      color: Color(0xFF7F7F7F),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Color(0xFFC8DFEE), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Color(0xFFC8DFEE), width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: BlocBuilder<BedtimeProjectBloc, BedtimeProjectState>(
                  builder: (context, state) {
                    if (state is BedtimeProjectLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is BedtimeProjectFailure) {
                      return Center(child: Text(state.message));
                    }

                    if (state is BedtimeProjectLoaded) {
                      final activeProjects = state.projects
                          .where((project) => project.bActive)
                          .toList();

                      if (activeProjects.isEmpty) {
                        return const Center(child: Text("No projects found"));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: activeProjects.length,
                        itemBuilder: (context, index) {
                          final project = activeProjects[index];
                          return _BottomSheetProjectTile(
                            title: project.cProjectName,
                            onTap: () async {
                              await BedtimeLocalStorage.saveSelectedProject(
                                projectId: project.nProjectId,
                                projectName: project.cProjectName,
                              );
                              await widget.onProjectSelected();
                              if (mounted) Navigator.pop(context);
                            },
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
      ),
    );
  }
}

class _BottomSheetProjectTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _BottomSheetProjectTile({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xE8ECF1FB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFB7CBEF)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _RequestFilterBottomSheet extends StatefulWidget {
  final String initialStatus;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final void Function(DateTime? fromDate, DateTime? toDate, String status)
      onApply;

  const _RequestFilterBottomSheet({
    required this.initialStatus,
    required this.initialFromDate,
    required this.initialToDate,
    required this.onApply,
  });

  @override
  State<_RequestFilterBottomSheet> createState() =>
      _RequestFilterBottomSheetState();
}

class _RequestFilterBottomSheetState extends State<_RequestFilterBottomSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime _activeDate = DateTime.now();
  String _selectedStatus = "";

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
    _activeDate = widget.initialToDate ??
        widget.initialFromDate ??
        DateTime.now();
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
                        label: "Requested",
                        value: "Requested",
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
                      _FilterRadioRow(
                        label: "Paid",
                        value: "Paid",
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
                      widget.onApply(_fromDate, effectiveToDate, _selectedStatus);
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

class _FilterRadioRow extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _FilterRadioRow({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String reqNo;
  final String dateTime;
  final String name;
  final String category;
  final String section;
  final String amount;
  final String status;
  final Color statusColor;

  const _RequestCard({
    required this.reqNo,
    required this.dateTime,
    required this.name,
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
      // padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                /// Top Row: Req No + Date
                Row(
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
                      dateTime,
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
                const SizedBox(height: 6),

                /// Name Row with Avatar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFEAF2FF),
                      child: Text(
                        name.isNotEmpty ? name[0] : "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// Category + Section
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
                    Text(
                      " : $category",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F7F7F),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "Section",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      " : $section",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F7F7F),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: 10),
              ],
            ),
          ),

          /// Bottom Strip Row
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

                /// Amount Text
                const Text(
                  "Payable Amt : ",
                  style: TextStyle(fontSize: 12, color: Color(0xFF7F7F7F)),
                ),

                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "\u20B9$amount",
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF256DFB),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                /// Status Dot + Text
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
