part of 'package:bedtime_stories/utils/lib_files.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
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
          },
        );
      },
    );
  }

  Future<void> _openPaymentRequestReportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentRequestReportSheet(
        onApply: (filters) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PaymentRequestReportPage(initialFilters: filters),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openVoucherReportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VoucherReportSheet(
        onApply: (filters) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VoucherReportPage(initialFilters: filters),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BedtimeGradientAppBar(onProjectTap: _openProjectSelectionSheet),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Text(
              "Reports",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 14),
            _ReportCard(
              iconPath: "assets/icons/pay_request_report.png",
              title: "Payment Request Report",
              onTap: _openPaymentRequestReportSheet,
            ),
            SizedBox(height: 10),
            _ReportCard(
              iconPath: "assets/icons/voucher_report.png",
              title: "Voucher Report",
              onTap: _openVoucherReportSheet,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const _ReportCard({
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xE8F7F9FE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD3DCEA)),
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRequestReportSheet extends StatefulWidget {
  final PaymentRequestReportFilters? initialFilters;
  final ValueChanged<PaymentRequestReportFilters>? onApply;

  const _PaymentRequestReportSheet({
    this.initialFilters,
    this.onApply,
  });

  @override
  State<_PaymentRequestReportSheet> createState() =>
      _PaymentRequestReportSheetState();
}

class _PaymentRequestReportSheetState extends State<_PaymentRequestReportSheet> {
  int? _selectedProjectId;
  String _selectedProjectName = "";
  Set<int> _selectedAccountIds = <int>{};
  bool _isAllAccountsSelected = true;
  String _selectedAccountName = "All";
  Set<int> _selectedCategoryIds = <int>{};
  bool _isAllCategoriesSelected = true;
  String _selectedCategoryName = "All";
  Set<int> _selectedSectionIds = <int>{};
  bool _isAllSectionsSelected = true;
  String _selectedSectionName = "All";
  String _selectedStatus = "All";
  DateTime? _fromDate;
  DateTime? _toDate;
  Set<int> _selectedUserIds = <int>{};
  bool _isAllUsersSelected = true;
  String _selectedUserName = "All";
  int? _loggedInUserId;
  String _loggedInUsername = "";
  String _projectName = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _fromDate = today;
    _toDate = today;
    _loadProjectName();
    _loadLoggedInUser();
    context.read<BedtimeProjectBloc>().add(
      BedtimeProjectLoadRequested(companyId: 1, userId: 1),
    );
    context.read<BedtimeGetAccountsListBloc>().add(
      BedtimeGetAccountsListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetCategoryListBloc>().add(
      BedtimeGetCategoryListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetSectionListBloc>().add(
      BedtimeGetSectionListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetUsersListBloc>().add(
      BedtimeGetUsersListLoadRequested(companyId: 1, search: ""),
    );
  }

  Future<void> _loadLoggedInUser() async {
    final userData = await BedtimeLocalStorage.getUserData();
    if (!mounted) return;
    setState(() {
      _loggedInUserId = int.tryParse(userData["userId"]?.toString() ?? "");
      _loggedInUsername = (userData["username"] ?? "").toString();
    });
  }

  Future<void> _loadProjectName() async {
    final name = await BedtimeLocalStorage.getSelectedProjectName();
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    if (!mounted) return;
    final initial = widget.initialFilters;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _projectName = initial?.projectName.isNotEmpty == true
          ? initial!.projectName
          : name;
      _selectedProjectId =
          initial?.projectId ?? (projectId == 0 ? null : projectId);
      _selectedProjectName = _projectName;
      final initialAccountIds = initial?.accountIds ?? const <int>[];
      _selectedAccountIds = {...initialAccountIds};
      _isAllAccountsSelected = initialAccountIds.isEmpty;
      _selectedAccountName = (initial?.accountName ?? "").trim().isEmpty
          ? (_isAllAccountsSelected ? "All" : "")
          : initial!.accountName;
      final initialCategoryIds = initial?.categoryIds ?? const <int>[];
      _selectedCategoryIds = {...initialCategoryIds};
      _isAllCategoriesSelected = initialCategoryIds.isEmpty;
      _selectedCategoryName = (initial?.categoryName ?? "").trim().isEmpty
          ? (_isAllCategoriesSelected ? "All" : "")
          : initial!.categoryName;
      final initialSectionIds = initial?.sectionIds ?? const <int>[];
      _selectedSectionIds = {...initialSectionIds};
      _isAllSectionsSelected = initialSectionIds.isEmpty;
      _selectedSectionName = (initial?.sectionName ?? "").trim().isEmpty
          ? (_isAllSectionsSelected ? "All" : "")
          : initial!.sectionName;
      _selectedStatus = initial?.status ?? "All";
      _fromDate = initial?.fromDate ?? _fromDate ?? today;
      _toDate = initial?.toDate ?? _toDate ?? today;
      final initialUserIds = initial?.userIds ?? const <int>[];
      _selectedUserIds = {...initialUserIds};
      _isAllUsersSelected = initialUserIds.isEmpty;
      _selectedUserName = (initial?.userName ?? "").trim().isEmpty
          ? (_isAllUsersSelected ? "All" : "")
          : initial!.userName;
    });
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$d-$m-$y";
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final firstAllowed = DateTime(2000);
    final lastAllowed = _toDate ?? DateTime(2100);
    final baseInitialDate = _fromDate ?? _toDate ?? now;
    final initialDate = baseInitialDate.isAfter(lastAllowed)
        ? lastAllowed
        : (baseInitialDate.isBefore(firstAllowed)
            ? firstAllowed
            : baseInitialDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );
    if (picked == null || !mounted) return;
    setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final firstAllowed = _fromDate ?? DateTime(2000);
    final lastAllowed = DateTime(2100);
    final baseInitialDate = _toDate ?? _fromDate ?? now;
    final initialDate = baseInitialDate.isBefore(firstAllowed)
        ? firstAllowed
        : (baseInitialDate.isAfter(lastAllowed)
            ? lastAllowed
            : baseInitialDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );
    if (picked == null || !mounted) return;
    setState(() => _toDate = picked);
  }

  List<String> _selectedAccountNamesFrom(
    List<BedtimeGetAccountsList> accounts,
  ) {
    if (_isAllAccountsSelected || _selectedAccountIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in accounts) {
      if (_selectedAccountIds.contains(item.nAccountId)) {
        names.add(item.cAccountName);
      }
    }
    return names;
  }

  String _accountFieldLabel(List<BedtimeGetAccountsList> accounts) {
    if (_isAllAccountsSelected || _selectedAccountIds.isEmpty) return "All";
    final names = _selectedAccountNamesFrom(accounts);
    if (names.isEmpty) {
      return _selectedAccountName.isEmpty ? "All" : _selectedAccountName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _accountFilterLabel(List<BedtimeGetAccountsList> accounts) {
    if (_isAllAccountsSelected || _selectedAccountIds.isEmpty) return "All";
    final names = _selectedAccountNamesFrom(accounts);
    if (names.isEmpty) {
      return _selectedAccountName.isEmpty ? "All" : _selectedAccountName;
    }
    return names.join(", ");
  }

  Future<void> _openAccountPicker(
    List<BedtimeGetAccountsList> accounts,
  ) async {
    final result = await showModalBottomSheet<_AccountMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountMultiSelectSheet(
        accounts: accounts,
        initialAllSelected: _isAllAccountsSelected,
        initialSelectedIds: _selectedAccountIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllAccountsSelected = result.isAllSelected;
      _selectedAccountIds = {...result.selectedIds};
      _selectedAccountName = _accountFilterLabel(accounts);
    });
  }

  List<String> _selectedCategoryNamesFrom(
    List<BedtimeGetCategoryList> categories,
  ) {
    if (_isAllCategoriesSelected || _selectedCategoryIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in categories) {
      if (_selectedCategoryIds.contains(item.nCategoryId)) {
        names.add(item.cCategoryName);
      }
    }
    return names;
  }

  String _categoryFieldLabel(List<BedtimeGetCategoryList> categories) {
    if (_isAllCategoriesSelected || _selectedCategoryIds.isEmpty) return "All";
    final names = _selectedCategoryNamesFrom(categories);
    if (names.isEmpty) {
      return _selectedCategoryName.isEmpty ? "All" : _selectedCategoryName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _categoryFilterLabel(List<BedtimeGetCategoryList> categories) {
    if (_isAllCategoriesSelected || _selectedCategoryIds.isEmpty) return "All";
    final names = _selectedCategoryNamesFrom(categories);
    if (names.isEmpty) {
      return _selectedCategoryName.isEmpty ? "All" : _selectedCategoryName;
    }
    return names.join(", ");
  }

  Future<void> _openCategoryPicker(
    List<BedtimeGetCategoryList> categories,
  ) async {
    final result = await showModalBottomSheet<_CategoryMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryMultiSelectSheet(
        categories: categories,
        initialAllSelected: _isAllCategoriesSelected,
        initialSelectedIds: _selectedCategoryIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllCategoriesSelected = result.isAllSelected;
      _selectedCategoryIds = {...result.selectedIds};
      _selectedCategoryName = _categoryFilterLabel(categories);
    });
  }

  List<String> _selectedSectionNamesFrom(
    List<BedtimeGetSectionList> sections,
  ) {
    if (_isAllSectionsSelected || _selectedSectionIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in sections) {
      if (_selectedSectionIds.contains(item.nSectionId)) {
        names.add(item.cSectionName);
      }
    }
    return names;
  }

  String _sectionFieldLabel(List<BedtimeGetSectionList> sections) {
    if (_isAllSectionsSelected || _selectedSectionIds.isEmpty) return "All";
    final names = _selectedSectionNamesFrom(sections);
    if (names.isEmpty) {
      return _selectedSectionName.isEmpty ? "All" : _selectedSectionName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _sectionFilterLabel(List<BedtimeGetSectionList> sections) {
    if (_isAllSectionsSelected || _selectedSectionIds.isEmpty) return "All";
    final names = _selectedSectionNamesFrom(sections);
    if (names.isEmpty) {
      return _selectedSectionName.isEmpty ? "All" : _selectedSectionName;
    }
    return names.join(", ");
  }

  Future<void> _openSectionPicker(
    List<BedtimeGetSectionList> sections,
  ) async {
    final result = await showModalBottomSheet<_SectionMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SectionMultiSelectSheet(
        sections: sections,
        initialAllSelected: _isAllSectionsSelected,
        initialSelectedIds: _selectedSectionIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllSectionsSelected = result.isAllSelected;
      _selectedSectionIds = {...result.selectedIds};
      _selectedSectionName = _sectionFilterLabel(sections);
    });
  }

  List<String> _selectedUserNamesFrom(List<BedtimeGetUsersList> users) {
    if (_isAllUsersSelected || _selectedUserIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in users) {
      if (_selectedUserIds.contains(item.nUserId)) {
        names.add(item.cCusername);
      }
    }
    return names;
  }

  String _userFieldLabel(List<BedtimeGetUsersList> users) {
    if (_isAllUsersSelected || _selectedUserIds.isEmpty) return "All";
    final names = _selectedUserNamesFrom(users);
    if (names.isEmpty) {
      return _selectedUserName.isEmpty ? "All" : _selectedUserName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _userFilterLabel(List<BedtimeGetUsersList> users) {
    if (_isAllUsersSelected || _selectedUserIds.isEmpty) return "All";
    final names = _selectedUserNamesFrom(users);
    if (names.isEmpty) {
      return _selectedUserName.isEmpty ? "All" : _selectedUserName;
    }
    return names.join(", ");
  }

  Future<void> _openUserPicker(List<BedtimeGetUsersList> users) async {
    final result = await showModalBottomSheet<_UserMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserMultiSelectSheet(
        users: users,
        initialAllSelected: _isAllUsersSelected,
        initialSelectedIds: _selectedUserIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllUsersSelected = result.isAllSelected;
      _selectedUserIds = {...result.selectedIds};
      _selectedUserName = _userFilterLabel(users);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final accountState = context.watch<BedtimeGetAccountsListBloc>().state;
    final categoryState = context.watch<BedtimeGetCategoryListBloc>().state;
    final sectionState = context.watch<BedtimeGetSectionListBloc>().state;
    final userState = context.watch<BedtimeGetUsersListBloc>().state;
    final projectState = context.watch<BedtimeProjectBloc>().state;

    final accounts = accountState is BedtimeGetAccountsListLoaded
        ? accountState.accounts
        : <BedtimeGetAccountsList>[];
    final categories = categoryState is BedtimeGetCategoryListLoaded
        ? categoryState.categories
        : <BedtimeGetCategoryList>[];
    final sections = sectionState is BedtimeGetSectionListLoaded
        ? sectionState.sections
        : <BedtimeGetSectionList>[];
    final apiUsers = userState is BedtimeGetUsersListLoaded
        ? userState.users
        : <BedtimeGetUsersList>[];
    final users = _usersWithLoggedInUser(
      users: apiUsers,
      loggedInUserId: _loggedInUserId,
      loggedInUsername: _loggedInUsername,
    );
    final projects = projectState is BedtimeProjectLoaded
        ? projectState.projects
        : <BedtimeProject>[];

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 16 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  const Text(
                    "Payment Request Report",
                    style: TextStyle(
                      fontSize: 28 / 1.6,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Project",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _projectName.isEmpty ? "Project" : _projectName,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: projects.any((e) => e.nProjectId == _selectedProjectId)
                        ? _selectedProjectId
                        : null,
                    hint: Text(
                      _projectName.isEmpty ? "Project" : _projectName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F7F7F),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: projects
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nProjectId,
                            child: Text(
                              item.cProjectName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v == null || projects.isEmpty) return;
                      final selected = projects.firstWhere(
                        (e) => e.nProjectId == v,
                        orElse: () => projects.first,
                      );
                      setState(() {
                        _selectedProjectId = v;
                        _projectName = selected.cProjectName;
                        _selectedProjectName = selected.cProjectName;
                      });
                      await BedtimeLocalStorage.saveSelectedProject(
                        projectId: selected.nProjectId,
                        projectName: selected.cProjectName,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F2FE),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Status",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusOption(
                          label: "All",
                          value: "All",
                          groupValue: _selectedStatus,
                          onChanged: (v) => setState(() => _selectedStatus = v),
                        ),
                        const SizedBox(width: 12),
                        _StatusOption(
                          label: "Approved",
                          value: "Approved",
                          groupValue: _selectedStatus,
                          onChanged: (v) => setState(() => _selectedStatus = v),
                        ),
                        const SizedBox(width: 12),
                        _StatusOption(
                          label: "Rejected",
                          value: "Rejected",
                          groupValue: _selectedStatus,
                          onChanged: (v) => setState(() => _selectedStatus = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ReportDateField(
                      label: "From",
                      value: _fromDate == null ? "" : _formatDate(_fromDate!),
                      onTap: _pickFromDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReportDateField(
                      label: "To",
                      value: _toDate == null ? "" : _formatDate(_toDate!),
                      onTap: _pickToDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Account",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _accountFieldLabel(accounts),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (accounts.isEmpty) return;
                    _openAccountPicker(accounts);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _accountFieldLabel(accounts),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Category",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _categoryFieldLabel(categories),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (categories.isEmpty) return;
                    _openCategoryPicker(categories);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _categoryFieldLabel(categories),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Section",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _sectionFieldLabel(sections),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (sections.isEmpty) return;
                    _openSectionPicker(sections);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _sectionFieldLabel(sections),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "User",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _userFieldLabel(users),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (users.isEmpty) return;
                    _openUserPicker(users);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _userFieldLabel(users),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B94F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      var projectName = _selectedProjectName;
                      if (projectName.isEmpty) {
                        for (final item in projects) {
                          if (item.nProjectId == _selectedProjectId) {
                            projectName = item.cProjectName;
                            break;
                          }
                        }
                      }
                      if (projectName.isEmpty) {
                        projectName = _projectName;
                      }

                      final selectedAccountIds = _isAllAccountsSelected
                          ? <int>[]
                          : (_selectedAccountIds.toList()..sort());
                      final accountName = _isAllAccountsSelected
                          ? "All"
                          : _accountFilterLabel(accounts);

                      final selectedCategoryIds = _isAllCategoriesSelected
                          ? <int>[]
                          : (_selectedCategoryIds.toList()..sort());
                      final categoryName = _isAllCategoriesSelected
                          ? "All"
                          : _categoryFilterLabel(categories);

                      final selectedSectionIds = _isAllSectionsSelected
                          ? <int>[]
                          : (_selectedSectionIds.toList()..sort());
                      final sectionName = _isAllSectionsSelected
                          ? "All"
                          : _sectionFilterLabel(sections);
                      final selectedUserIds = _isAllUsersSelected
                          ? <int>[]
                          : (_selectedUserIds.toList()..sort());
                      final userName = _isAllUsersSelected
                          ? "All"
                          : _userFilterLabel(users);

                      final filters = PaymentRequestReportFilters(
                        projectId: _selectedProjectId,
                        projectName: projectName,
                        status: _selectedStatus,
                        fromDate: _fromDate,
                        toDate: _toDate,
                        accountIds: selectedAccountIds,
                        accountName: accountName,
                        categoryIds: selectedCategoryIds,
                        categoryName: categoryName,
                        sectionIds: selectedSectionIds,
                        sectionName: sectionName,
                        userIds: selectedUserIds,
                        userName: userName,
                      );
                      Navigator.pop(context);
                      widget.onApply?.call(filters);
                    },
                    child: const Text(
                      "Apply",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

class _ReportDropdownField extends StatelessWidget {
  final String hint;
  final Widget child;

  const _ReportDropdownField({
    required this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hasChild = child is! SizedBox;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCDDEB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: hasChild
          ? child
          : Row(
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F7F7F),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
    );
  }
}

class _ReportDateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ReportDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
        ),
        const SizedBox(height: 4),
        InkWell(
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
                      color: value.isEmpty
                          ? const Color(0xFF7F7F7F)
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountMultiSelectResult {
  final bool isAllSelected;
  final List<int> selectedIds;

  const _AccountMultiSelectResult({
    required this.isAllSelected,
    required this.selectedIds,
  });
}

class _AccountMultiSelectSheet extends StatefulWidget {
  final List<BedtimeGetAccountsList> accounts;
  final bool initialAllSelected;
  final Set<int> initialSelectedIds;

  const _AccountMultiSelectSheet({
    required this.accounts,
    required this.initialAllSelected,
    required this.initialSelectedIds,
  });

  @override
  State<_AccountMultiSelectSheet> createState() => _AccountMultiSelectSheetState();
}

class _AccountMultiSelectSheetState extends State<_AccountMultiSelectSheet> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isAllSelected;
  late Set<int> _selectedIds;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _isAllSelected = widget.initialAllSelected;
    _selectedIds = {...widget.initialSelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BedtimeGetAccountsList> _filteredAccounts() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.accounts;
    return widget.accounts
        .where((item) => item.cAccountName.toLowerCase().contains(query))
        .toList();
  }

  void _toggleAll(bool value) {
    setState(() {
      _isAllSelected = value;
      if (value) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleAccount(int accountId, bool value) {
    setState(() {
      _isAllSelected = false;
      if (value) {
        _selectedIds.add(accountId);
      } else {
        _selectedIds.remove(accountId);
        if (_selectedIds.isEmpty) {
          _isAllSelected = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final filteredAccounts = _filteredAccounts();

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 12, 14, 14 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Select Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCCDDEB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: "Search account",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7F7F7F),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _toggleAll(!_isAllSelected),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAllSelected,
                      onChanged: (value) => _toggleAll(value ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "All",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Expanded(
                child: filteredAccounts.isEmpty
                    ? const Center(
                        child: Text(
                          "No accounts found",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredAccounts.length,
                        itemBuilder: (context, index) {
                          final account = filteredAccounts[index];
                          final isChecked =
                              !_isAllSelected &&
                              _selectedIds.contains(account.nAccountId);
                          return InkWell(
                            onTap: () =>
                                _toggleAccount(account.nAccountId, !isChecked),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) => _toggleAccount(
                                    account.nAccountId,
                                    value ?? false,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: Text(
                                    account.cAccountName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 88,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B94F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final ids = _selectedIds.toList()..sort();
                        Navigator.pop(
                          context,
                          _AccountMultiSelectResult(
                            isAllSelected: _isAllSelected || ids.isEmpty,
                            selectedIds: _isAllSelected ? const [] : ids,
                          ),
                        );
                      },
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryMultiSelectResult {
  final bool isAllSelected;
  final List<int> selectedIds;

  const _CategoryMultiSelectResult({
    required this.isAllSelected,
    required this.selectedIds,
  });
}

class _CategoryMultiSelectSheet extends StatefulWidget {
  final List<BedtimeGetCategoryList> categories;
  final bool initialAllSelected;
  final Set<int> initialSelectedIds;

  const _CategoryMultiSelectSheet({
    required this.categories,
    required this.initialAllSelected,
    required this.initialSelectedIds,
  });

  @override
  State<_CategoryMultiSelectSheet> createState() =>
      _CategoryMultiSelectSheetState();
}

class _CategoryMultiSelectSheetState extends State<_CategoryMultiSelectSheet> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isAllSelected;
  late Set<int> _selectedIds;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _isAllSelected = widget.initialAllSelected;
    _selectedIds = {...widget.initialSelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BedtimeGetCategoryList> _filteredCategories() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.categories;
    return widget.categories
        .where((item) => item.cCategoryName.toLowerCase().contains(query))
        .toList();
  }

  void _toggleAll(bool value) {
    setState(() {
      _isAllSelected = value;
      if (value) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleCategory(int categoryId, bool value) {
    setState(() {
      _isAllSelected = false;
      if (value) {
        _selectedIds.add(categoryId);
      } else {
        _selectedIds.remove(categoryId);
        if (_selectedIds.isEmpty) {
          _isAllSelected = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final filteredCategories = _filteredCategories();

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 12, 14, 14 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Select Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCCDDEB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: "Search category",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7F7F7F),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _toggleAll(!_isAllSelected),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAllSelected,
                      onChanged: (value) => _toggleAll(value ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "All",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Expanded(
                child: filteredCategories.isEmpty
                    ? const Center(
                        child: Text(
                          "No categories found",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final isChecked =
                              !_isAllSelected &&
                              _selectedIds.contains(category.nCategoryId);
                          return InkWell(
                            onTap: () =>
                                _toggleCategory(category.nCategoryId, !isChecked),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) => _toggleCategory(
                                    category.nCategoryId,
                                    value ?? false,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: Text(
                                    category.cCategoryName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 88,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B94F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final ids = _selectedIds.toList()..sort();
                        Navigator.pop(
                          context,
                          _CategoryMultiSelectResult(
                            isAllSelected: _isAllSelected || ids.isEmpty,
                            selectedIds: _isAllSelected ? const [] : ids,
                          ),
                        );
                      },
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionMultiSelectResult {
  final bool isAllSelected;
  final List<int> selectedIds;

  const _SectionMultiSelectResult({
    required this.isAllSelected,
    required this.selectedIds,
  });
}

class _SectionMultiSelectSheet extends StatefulWidget {
  final List<BedtimeGetSectionList> sections;
  final bool initialAllSelected;
  final Set<int> initialSelectedIds;

  const _SectionMultiSelectSheet({
    required this.sections,
    required this.initialAllSelected,
    required this.initialSelectedIds,
  });

  @override
  State<_SectionMultiSelectSheet> createState() =>
      _SectionMultiSelectSheetState();
}

class _SectionMultiSelectSheetState extends State<_SectionMultiSelectSheet> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isAllSelected;
  late Set<int> _selectedIds;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _isAllSelected = widget.initialAllSelected;
    _selectedIds = {...widget.initialSelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BedtimeGetSectionList> _filteredSections() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.sections;
    return widget.sections
        .where((item) => item.cSectionName.toLowerCase().contains(query))
        .toList();
  }

  void _toggleAll(bool value) {
    setState(() {
      _isAllSelected = value;
      if (value) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSection(int sectionId, bool value) {
    setState(() {
      _isAllSelected = false;
      if (value) {
        _selectedIds.add(sectionId);
      } else {
        _selectedIds.remove(sectionId);
        if (_selectedIds.isEmpty) {
          _isAllSelected = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final filteredSections = _filteredSections();

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 12, 14, 14 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Select Section",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCCDDEB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: "Search section",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7F7F7F),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _toggleAll(!_isAllSelected),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAllSelected,
                      onChanged: (value) => _toggleAll(value ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "All",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Expanded(
                child: filteredSections.isEmpty
                    ? const Center(
                        child: Text(
                          "No sections found",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSections.length,
                        itemBuilder: (context, index) {
                          final section = filteredSections[index];
                          final isChecked =
                              !_isAllSelected &&
                              _selectedIds.contains(section.nSectionId);
                          return InkWell(
                            onTap: () =>
                                _toggleSection(section.nSectionId, !isChecked),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) => _toggleSection(
                                    section.nSectionId,
                                    value ?? false,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: Text(
                                    section.cSectionName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 88,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B94F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final ids = _selectedIds.toList()..sort();
                        Navigator.pop(
                          context,
                          _SectionMultiSelectResult(
                            isAllSelected: _isAllSelected || ids.isEmpty,
                            selectedIds: _isAllSelected ? const [] : ids,
                          ),
                        );
                      },
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<BedtimeGetUsersList> _usersWithLoggedInUser({
  required List<BedtimeGetUsersList> users,
  required int? loggedInUserId,
  required String loggedInUsername,
}) {
  final result = <BedtimeGetUsersList>[...users];
  final hasLoggedInUser = loggedInUserId != null &&
      users.any((user) => user.nUserId == loggedInUserId);
  final fallbackName = loggedInUsername.trim();

  if (!hasLoggedInUser && loggedInUserId != null && fallbackName.isNotEmpty) {
    result.insert(
      0,
      BedtimeGetUsersList(
        nUserId: loggedInUserId,
        cCusername: fallbackName,
        cEmail: "",
        cMobile: "",
        bActive: true,
        dCreatedDate: "",
        dModifiedDate: null,
      ),
    );
  }

  final seen = <int>{};
  return result.where((user) => seen.add(user.nUserId)).toList();
}

class _UserMultiSelectResult {
  final bool isAllSelected;
  final List<int> selectedIds;

  const _UserMultiSelectResult({
    required this.isAllSelected,
    required this.selectedIds,
  });
}

class _UserMultiSelectSheet extends StatefulWidget {
  final List<BedtimeGetUsersList> users;
  final bool initialAllSelected;
  final Set<int> initialSelectedIds;

  const _UserMultiSelectSheet({
    required this.users,
    required this.initialAllSelected,
    required this.initialSelectedIds,
  });

  @override
  State<_UserMultiSelectSheet> createState() => _UserMultiSelectSheetState();
}

class _UserMultiSelectSheetState extends State<_UserMultiSelectSheet> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isAllSelected;
  late Set<int> _selectedIds;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _isAllSelected = widget.initialAllSelected;
    _selectedIds = {...widget.initialSelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BedtimeGetUsersList> _filteredUsers() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.users;
    return widget.users
        .where((item) => item.cCusername.toLowerCase().contains(query))
        .toList();
  }

  void _toggleAll(bool value) {
    setState(() {
      _isAllSelected = value;
      if (value) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleUser(int userId, bool value) {
    setState(() {
      _isAllSelected = false;
      if (value) {
        _selectedIds.add(userId);
      } else {
        _selectedIds.remove(userId);
        if (_selectedIds.isEmpty) {
          _isAllSelected = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final filteredUsers = _filteredUsers();

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 12, 14, 14 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Select User",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCCDDEB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: "Search user",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7F7F7F),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _toggleAll(!_isAllSelected),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAllSelected,
                      onChanged: (value) => _toggleAll(value ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "All",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Expanded(
                child: filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          "No users found",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final isChecked =
                              !_isAllSelected && _selectedIds.contains(user.nUserId);
                          return InkWell(
                            onTap: () => _toggleUser(user.nUserId, !isChecked),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) => _toggleUser(
                                    user.nUserId,
                                    value ?? false,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: Text(
                                    user.cCusername,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 88,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B94F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final ids = _selectedIds.toList()..sort();
                        Navigator.pop(
                          context,
                          _UserMultiSelectResult(
                            isAllSelected: _isAllSelected || ids.isEmpty,
                            selectedIds: _isAllSelected ? const [] : ids,
                          ),
                        );
                      },
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _StatusOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF565656)),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3D3D3D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _VoucherReportSheet extends StatefulWidget {
  final VoucherReportFilters? initialFilters;
  final ValueChanged<VoucherReportFilters>? onApply;

  const _VoucherReportSheet({
    this.initialFilters,
    this.onApply,
  });

  @override
  State<_VoucherReportSheet> createState() => _VoucherReportSheetState();
}

class _VoucherReportSheetState extends State<_VoucherReportSheet> {
  int? _selectedProjectId;
  String _selectedProjectName = "";
  Set<int> _selectedAccountIds = <int>{};
  bool _isAllAccountsSelected = true;
  String _selectedAccountName = "All";
  Set<int> _selectedCategoryIds = <int>{};
  bool _isAllCategoriesSelected = true;
  String _selectedCategoryName = "All";
  Set<int> _selectedSectionIds = <int>{};
  bool _isAllSectionsSelected = true;
  String _selectedSectionName = "All";
  DateTime? _fromDate;
  DateTime? _toDate;
  Set<int> _selectedUserIds = <int>{};
  bool _isAllUsersSelected = true;
  String _selectedUserName = "All";
  String _selectedPayMode = "All";
  int? _loggedInUserId;
  String _loggedInUsername = "";
  String _projectName = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _fromDate = today;
    _toDate = today;
    _loadProjectName();
    _loadLoggedInUser();
    context.read<BedtimeProjectBloc>().add(
      BedtimeProjectLoadRequested(companyId: 1, userId: 1),
    );
    context.read<BedtimeGetAccountsListBloc>().add(
      BedtimeGetAccountsListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetCategoryListBloc>().add(
      BedtimeGetCategoryListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetSectionListBloc>().add(
      BedtimeGetSectionListLoadRequested(companyId: 1),
    );
    context.read<BedtimeGetUsersListBloc>().add(
      BedtimeGetUsersListLoadRequested(companyId: 1, search: ""),
    );
  }

  Future<void> _loadLoggedInUser() async {
    final userData = await BedtimeLocalStorage.getUserData();
    final resolvedUserId = int.tryParse(userData["userId"]?.toString() ?? "");
    final resolvedUsername = (userData["username"] ?? "").toString().trim();
    if (!mounted) return;
    setState(() {
      _loggedInUserId = resolvedUserId;
      _loggedInUsername = resolvedUsername;
      final shouldDefaultToLoggedInUser =
          widget.initialFilters == null &&
          resolvedUserId != null &&
          resolvedUsername.isNotEmpty &&
          _selectedUserIds.isEmpty;
      if (shouldDefaultToLoggedInUser) {
        _selectedUserIds = {resolvedUserId};
        _isAllUsersSelected = false;
        _selectedUserName = resolvedUsername;
      }
    });
  }

  Future<void> _loadProjectName() async {
    final name = await BedtimeLocalStorage.getSelectedProjectName();
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    if (!mounted) return;
    final initial = widget.initialFilters;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _projectName = initial?.projectName.isNotEmpty == true
          ? initial!.projectName
          : name;
      _selectedProjectId =
          initial?.projectId ?? (projectId == 0 ? null : projectId);
      _selectedProjectName = _projectName;
      final initialAccountIds = initial?.accountIds ?? const <int>[];
      _selectedAccountIds = {...initialAccountIds};
      _isAllAccountsSelected = initialAccountIds.isEmpty;
      _selectedAccountName = (initial?.accountName ?? "").trim().isEmpty
          ? (_isAllAccountsSelected ? "All" : "")
          : initial!.accountName;
      final initialCategoryIds = initial?.categoryIds ?? const <int>[];
      _selectedCategoryIds = {...initialCategoryIds};
      _isAllCategoriesSelected = initialCategoryIds.isEmpty;
      _selectedCategoryName = (initial?.categoryName ?? "").trim().isEmpty
          ? (_isAllCategoriesSelected ? "All" : "")
          : initial!.categoryName;
      final initialSectionIds = initial?.sectionIds ?? const <int>[];
      _selectedSectionIds = {...initialSectionIds};
      _isAllSectionsSelected = initialSectionIds.isEmpty;
      _selectedSectionName = (initial?.sectionName ?? "").trim().isEmpty
          ? (_isAllSectionsSelected ? "All" : "")
          : initial!.sectionName;
      _selectedPayMode = (initial?.payMode ?? "All").trim().isEmpty
          ? "All"
          : initial!.payMode;
      _fromDate = initial?.fromDate ?? _fromDate ?? today;
      _toDate = initial?.toDate ?? _toDate ?? today;

      if (initial != null) {
        final initialUserIds = initial.userIds;
        _selectedUserIds = {...initialUserIds};
        _isAllUsersSelected = initialUserIds.isEmpty;
        _selectedUserName = initial.userName.trim().isEmpty
            ? (_isAllUsersSelected ? "All" : "")
            : initial.userName;
      } else if (_loggedInUserId != null && _loggedInUsername.trim().isNotEmpty) {
        _selectedUserIds = {_loggedInUserId!};
        _isAllUsersSelected = false;
        _selectedUserName = _loggedInUsername.trim();
      } else {
        _selectedUserIds = <int>{};
        _isAllUsersSelected = true;
        _selectedUserName = "All";
      }
    });
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$d-$m-$y";
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final firstAllowed = DateTime(2000);
    final lastAllowed = _toDate ?? DateTime(2100);
    final baseInitialDate = _fromDate ?? _toDate ?? now;
    final initialDate = baseInitialDate.isAfter(lastAllowed)
        ? lastAllowed
        : (baseInitialDate.isBefore(firstAllowed)
            ? firstAllowed
            : baseInitialDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );
    if (picked == null || !mounted) return;
    setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final firstAllowed = _fromDate ?? DateTime(2000);
    final lastAllowed = DateTime(2100);
    final baseInitialDate = _toDate ?? _fromDate ?? now;
    final initialDate = baseInitialDate.isBefore(firstAllowed)
        ? firstAllowed
        : (baseInitialDate.isAfter(lastAllowed)
            ? lastAllowed
            : baseInitialDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );
    if (picked == null || !mounted) return;
    setState(() => _toDate = picked);
  }

  List<String> _selectedAccountNamesFrom(
    List<BedtimeGetAccountsList> accounts,
  ) {
    if (_isAllAccountsSelected || _selectedAccountIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in accounts) {
      if (_selectedAccountIds.contains(item.nAccountId)) {
        names.add(item.cAccountName);
      }
    }
    return names;
  }

  String _accountFieldLabel(List<BedtimeGetAccountsList> accounts) {
    if (_isAllAccountsSelected || _selectedAccountIds.isEmpty) return "All";
    final names = _selectedAccountNamesFrom(accounts);
    if (names.isEmpty) {
      return _selectedAccountName.isEmpty ? "All" : _selectedAccountName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _accountFilterLabel(List<BedtimeGetAccountsList> accounts) {
    if (_isAllAccountsSelected || _selectedAccountIds.isEmpty) return "All";
    final names = _selectedAccountNamesFrom(accounts);
    if (names.isEmpty) {
      return _selectedAccountName.isEmpty ? "All" : _selectedAccountName;
    }
    return names.join(", ");
  }

  Future<void> _openAccountPicker(
    List<BedtimeGetAccountsList> accounts,
  ) async {
    final result = await showModalBottomSheet<_AccountMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountMultiSelectSheet(
        accounts: accounts,
        initialAllSelected: _isAllAccountsSelected,
        initialSelectedIds: _selectedAccountIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllAccountsSelected = result.isAllSelected;
      _selectedAccountIds = {...result.selectedIds};
      _selectedAccountName = _accountFilterLabel(accounts);
    });
  }

  List<String> _selectedCategoryNamesFrom(
    List<BedtimeGetCategoryList> categories,
  ) {
    if (_isAllCategoriesSelected || _selectedCategoryIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in categories) {
      if (_selectedCategoryIds.contains(item.nCategoryId)) {
        names.add(item.cCategoryName);
      }
    }
    return names;
  }

  String _categoryFieldLabel(List<BedtimeGetCategoryList> categories) {
    if (_isAllCategoriesSelected || _selectedCategoryIds.isEmpty) return "All";
    final names = _selectedCategoryNamesFrom(categories);
    if (names.isEmpty) {
      return _selectedCategoryName.isEmpty ? "All" : _selectedCategoryName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _categoryFilterLabel(List<BedtimeGetCategoryList> categories) {
    if (_isAllCategoriesSelected || _selectedCategoryIds.isEmpty) return "All";
    final names = _selectedCategoryNamesFrom(categories);
    if (names.isEmpty) {
      return _selectedCategoryName.isEmpty ? "All" : _selectedCategoryName;
    }
    return names.join(", ");
  }

  Future<void> _openCategoryPicker(
    List<BedtimeGetCategoryList> categories,
  ) async {
    final result = await showModalBottomSheet<_CategoryMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryMultiSelectSheet(
        categories: categories,
        initialAllSelected: _isAllCategoriesSelected,
        initialSelectedIds: _selectedCategoryIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllCategoriesSelected = result.isAllSelected;
      _selectedCategoryIds = {...result.selectedIds};
      _selectedCategoryName = _categoryFilterLabel(categories);
    });
  }

  List<String> _selectedSectionNamesFrom(
    List<BedtimeGetSectionList> sections,
  ) {
    if (_isAllSectionsSelected || _selectedSectionIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in sections) {
      if (_selectedSectionIds.contains(item.nSectionId)) {
        names.add(item.cSectionName);
      }
    }
    return names;
  }

  String _sectionFieldLabel(List<BedtimeGetSectionList> sections) {
    if (_isAllSectionsSelected || _selectedSectionIds.isEmpty) return "All";
    final names = _selectedSectionNamesFrom(sections);
    if (names.isEmpty) {
      return _selectedSectionName.isEmpty ? "All" : _selectedSectionName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _sectionFilterLabel(List<BedtimeGetSectionList> sections) {
    if (_isAllSectionsSelected || _selectedSectionIds.isEmpty) return "All";
    final names = _selectedSectionNamesFrom(sections);
    if (names.isEmpty) {
      return _selectedSectionName.isEmpty ? "All" : _selectedSectionName;
    }
    return names.join(", ");
  }

  Future<void> _openSectionPicker(
    List<BedtimeGetSectionList> sections,
  ) async {
    final result = await showModalBottomSheet<_SectionMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SectionMultiSelectSheet(
        sections: sections,
        initialAllSelected: _isAllSectionsSelected,
        initialSelectedIds: _selectedSectionIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllSectionsSelected = result.isAllSelected;
      _selectedSectionIds = {...result.selectedIds};
      _selectedSectionName = _sectionFilterLabel(sections);
    });
  }

  List<String> _selectedUserNamesFrom(List<BedtimeGetUsersList> users) {
    if (_isAllUsersSelected || _selectedUserIds.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final item in users) {
      if (_selectedUserIds.contains(item.nUserId)) {
        names.add(item.cCusername);
      }
    }
    return names;
  }

  String _userFieldLabel(List<BedtimeGetUsersList> users) {
    if (_isAllUsersSelected || _selectedUserIds.isEmpty) return "All";
    final names = _selectedUserNamesFrom(users);
    if (names.isEmpty) {
      return _selectedUserName.isEmpty ? "All" : _selectedUserName;
    }
    if (names.length == 1) return names.first;
    return "${names.first} +${names.length - 1}";
  }

  String _userFilterLabel(List<BedtimeGetUsersList> users) {
    if (_isAllUsersSelected || _selectedUserIds.isEmpty) return "All";
    final names = _selectedUserNamesFrom(users);
    if (names.isEmpty) {
      return _selectedUserName.isEmpty ? "All" : _selectedUserName;
    }
    return names.join(", ");
  }

  Future<void> _openUserPicker(List<BedtimeGetUsersList> users) async {
    final result = await showModalBottomSheet<_UserMultiSelectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserMultiSelectSheet(
        users: users,
        initialAllSelected: _isAllUsersSelected,
        initialSelectedIds: _selectedUserIds,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isAllUsersSelected = result.isAllSelected;
      _selectedUserIds = {...result.selectedIds};
      _selectedUserName = _userFilterLabel(users);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final accountState = context.watch<BedtimeGetAccountsListBloc>().state;
    final categoryState = context.watch<BedtimeGetCategoryListBloc>().state;
    final sectionState = context.watch<BedtimeGetSectionListBloc>().state;
    final userState = context.watch<BedtimeGetUsersListBloc>().state;
    final projectState = context.watch<BedtimeProjectBloc>().state;

    final accounts = accountState is BedtimeGetAccountsListLoaded
        ? accountState.accounts
        : <BedtimeGetAccountsList>[];
    final categories = categoryState is BedtimeGetCategoryListLoaded
        ? categoryState.categories
        : <BedtimeGetCategoryList>[];
    final sections = sectionState is BedtimeGetSectionListLoaded
        ? sectionState.sections
        : <BedtimeGetSectionList>[];
    final apiUsers = userState is BedtimeGetUsersListLoaded
        ? userState.users
        : <BedtimeGetUsersList>[];
    final users = _usersWithLoggedInUser(
      users: apiUsers,
      loggedInUserId: _loggedInUserId,
      loggedInUsername: _loggedInUsername,
    );
    final projects = projectState is BedtimeProjectLoaded
        ? projectState.projects
        : <BedtimeProject>[];

    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 16 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  const Text(
                    "Voucher Report",
                    style: TextStyle(
                      fontSize: 28 / 1.6,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Project",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _projectName.isEmpty ? "Project" : _projectName,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: projects.any((e) => e.nProjectId == _selectedProjectId)
                        ? _selectedProjectId
                        : null,
                    hint: Text(
                      _projectName.isEmpty ? "Project" : _projectName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F7F7F),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: projects
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nProjectId,
                            child: Text(
                              item.cProjectName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v == null || projects.isEmpty) return;
                      final selected = projects.firstWhere(
                        (e) => e.nProjectId == v,
                        orElse: () => projects.first,
                      );
                      setState(() {
                        _selectedProjectId = v;
                        _projectName = selected.cProjectName;
                      });
                      await BedtimeLocalStorage.saveSelectedProject(
                        projectId: selected.nProjectId,
                        projectName: selected.cProjectName,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ReportDateField(
                      label: "From",
                      value: _fromDate == null ? "" : _formatDate(_fromDate!),
                      onTap: _pickFromDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReportDateField(
                      label: "To",
                      value: _toDate == null ? "" : _formatDate(_toDate!),
                      onTap: _pickToDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Account",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _accountFieldLabel(accounts),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (accounts.isEmpty) return;
                    _openAccountPicker(accounts);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _accountFieldLabel(accounts),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Category",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _categoryFieldLabel(categories),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (categories.isEmpty) return;
                    _openCategoryPicker(categories);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _categoryFieldLabel(categories),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Section",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _sectionFieldLabel(sections),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (sections.isEmpty) return;
                    _openSectionPicker(sections);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _sectionFieldLabel(sections),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "User",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _userFieldLabel(users),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (users.isEmpty) return;
                    _openUserPicker(users);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _userFieldLabel(users),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Pay Mode",
                style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 4),
              _ReportDropdownField(
                hint: _selectedPayMode,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPayMode,
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: const [
                      DropdownMenuItem<String>(
                        value: "All",
                        child: Text("All", style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem<String>(
                        value: "Cash",
                        child: Text("Cash", style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem<String>(
                        value: "Bank",
                        child: Text("Bank", style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem<String>(
                        value: "Cheque",
                        child: Text("Cheque", style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem<String>(
                        value: "UPI",
                        child: Text("UPI", style: TextStyle(fontSize: 13)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedPayMode = value);
                    },
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B94F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      var projectName = _selectedProjectName;
                      if (projectName.isEmpty) {
                        for (final item in projects) {
                          if (item.nProjectId == _selectedProjectId) {
                            projectName = item.cProjectName;
                            break;
                          }
                        }
                      }
                      if (projectName.isEmpty) {
                        projectName = _projectName;
                      }

                      final selectedAccountIds = _isAllAccountsSelected
                          ? <int>[]
                          : (_selectedAccountIds.toList()..sort());
                      final accountName = _isAllAccountsSelected
                          ? "All"
                          : _accountFilterLabel(accounts);

                      final selectedCategoryIds = _isAllCategoriesSelected
                          ? <int>[]
                          : (_selectedCategoryIds.toList()..sort());
                      final categoryName = _isAllCategoriesSelected
                          ? "All"
                          : _categoryFilterLabel(categories);

                      final selectedSectionIds = _isAllSectionsSelected
                          ? <int>[]
                          : (_selectedSectionIds.toList()..sort());
                      final sectionName = _isAllSectionsSelected
                          ? "All"
                          : _sectionFilterLabel(sections);
                      final selectedUserIds = _isAllUsersSelected
                          ? <int>[]
                          : (_selectedUserIds.toList()..sort());
                      final userName = _isAllUsersSelected
                          ? "All"
                          : _userFilterLabel(users);

                      final filters = VoucherReportFilters(
                        projectId: _selectedProjectId,
                        projectName: projectName,
                        fromDate: _fromDate,
                        toDate: _toDate,
                        accountIds: selectedAccountIds,
                        accountName: accountName,
                        categoryIds: selectedCategoryIds,
                        categoryName: categoryName,
                        sectionIds: selectedSectionIds,
                        sectionName: sectionName,
                        userIds: selectedUserIds,
                        userName: userName,
                        payMode: _selectedPayMode,
                      );
                      Navigator.pop(context);
                      widget.onApply?.call(filters);
                    },
                    child: const Text(
                      "Apply",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

class PaymentRequestReportFilters {
  final int? projectId;
  final String projectName;
  final String status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<int> accountIds;
  final String accountName;
  final List<int> categoryIds;
  final String categoryName;
  final List<int> sectionIds;
  final String sectionName;
  final List<int> userIds;
  final String userName;

  const PaymentRequestReportFilters({
    required this.projectId,
    required this.projectName,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.accountIds,
    required this.accountName,
    required this.categoryIds,
    required this.categoryName,
    required this.sectionIds,
    required this.sectionName,
    required this.userIds,
    required this.userName,
  });
}

class PaymentRequestReportPage extends StatefulWidget {
  final PaymentRequestReportFilters initialFilters;

  const PaymentRequestReportPage({super.key, required this.initialFilters});

  @override
  State<PaymentRequestReportPage> createState() => _PaymentRequestReportPageState();
}

class _PaymentRequestReportPageState extends State<PaymentRequestReportPage> {
  late PaymentRequestReportFilters _filters;
  final ScrollController _horizontalController = ScrollController();
  bool _showAllFilters = false;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPaymentRequestReport();
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$d-$m-$y";
  }

  String _dateRangeLabel() {
    if (_filters.fromDate == null || _filters.toDate == null) return "";
    return "${_formatDate(_filters.fromDate!)} - ${_formatDate(_filters.toDate!)}";
  }

  String _formatApiDate(DateTime? date) {
    if (date == null) return "";
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  String _idString(int? id) {
    if (id == null || id == 0) return "";
    return id.toString();
  }

  String _idsString(List<int> ids) {
    if (ids.isEmpty) return "";
    return ids.where((id) => id > 0).map((id) => id.toString()).join(",");
  }

  String _statusApiValue(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == "all") return "ALL";
    if (normalized == "approved") return "Approved";
    if (normalized == "rejected") return "Rejected";
    return status;
  }

  String _money(double value) => value.toStringAsFixed(2);

  void _loadPaymentRequestReport([PaymentRequestReportFilters? sourceFilters]) {
    final selected = sourceFilters ?? _filters;
    context.read<BedtimePaymentRequestReportBloc>().add(
          BedtimePaymentRequestReportLoadRequested(
            companyId: 1,
            projectIds: _idString(selected.projectId),
            status: _statusApiValue(selected.status),
            dFrom: _formatApiDate(selected.fromDate),
            dTo: _formatApiDate(selected.toDate),
            accountIds: _idsString(selected.accountIds),
            categoryIds: _idsString(selected.categoryIds),
            sectionIds: _idsString(selected.sectionIds),
            userIds: _idsString(selected.userIds),
          ),
        );
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentRequestReportSheet(
        initialFilters: _filters,
        onApply: (filters) {
          setState(() => _filters = filters);
          _loadPaymentRequestReport(filters);
        },
      ),
    );
  }

  void _scrollHorizontally(double offset) {
    if (!_horizontalController.hasClients) return;
    final target = _horizontalController.offset + offset;
    _horizontalController.animateTo(
      target.clamp(0.0, _horizontalController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const scrollableColumnsWidth = 1085.0;
    final dateRange = _dateRangeLabel();
    final appliedPrimary = [
      if (_filters.projectName.isNotEmpty) "Project : ${_filters.projectName}",
      if (dateRange.isNotEmpty) "Date : $dateRange",
    ];
    final appliedAll = [
      ...appliedPrimary,
      if (_filters.status.isNotEmpty) "Status : ${_filters.status}",
      if (_filters.accountName.isNotEmpty) "Account : ${_filters.accountName}",
      if (_filters.categoryName.isNotEmpty)
        "Category : ${_filters.categoryName}",
      if (_filters.sectionName.isNotEmpty) "Section : ${_filters.sectionName}",
      if (_filters.userName.isNotEmpty) "User : ${_filters.userName}",
    ];

    final applied = _showAllFilters ? appliedAll : appliedPrimary;
    final reportState = context.watch<BedtimePaymentRequestReportBloc>().state;
    final rows = reportState is BedtimePaymentRequestReportLoaded
        ? reportState.rows
        : <BedtimePaymentRequestReportRow>[];
    final totalTds = rows.fold<double>(0.0, (sum, row) => sum + row.nTDS);
    final totalTax = rows.fold<double>(0.0, (sum, row) => sum + row.nTax);
    final totalPayable =
        rows.fold<double>(0.0, (sum, row) => sum + row.nPayable);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Payment Request Report",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openFilterSheet,
            icon: Image.asset(
              "assets/icons/filter.png",
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFFDDE8F3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Applied",
                  style: TextStyle(fontSize: 12, color: Color(0xFF5A5A5A)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    applied.join(", "),
                    maxLines: _showAllFilters ? null : 1,
                    overflow: _showAllFilters
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    softWrap: _showAllFilters,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showAllFilters = !_showAllFilters),
                  child: Text(
                    _showAllFilters ? "View Less" : "View All",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A4B9A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E6EE)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Builder(
                builder: (context) {
                  if (reportState is BedtimePaymentRequestReportLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (reportState is BedtimePaymentRequestReportFailure) {
                    return Center(child: Text(reportState.message));
                  }

                  if (rows.isEmpty) {
                    return const Center(
                      child: Text("No payment request report found"),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Column(
                                children: [
                                  const _TableHeaderCell(label: "Srl", width: 50),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: rows.length,
                                      itemBuilder: (context, index) {
                                        return _TableBodyCell(
                                          value: "${index + 1}",
                                          width: 50,
                                          align: TextAlign.center,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: scrollableColumnsWidth,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: const [
                                          _TableHeaderCell(label: "Req No", width: 95),
                                          _TableHeaderCell(label: "Date", width: 90),
                                          _TableHeaderCell(label: "User", width: 90),
                                          _TableHeaderCell(label: "Account", width: 120),
                                          _TableHeaderCell(label: "Category", width: 110),
                                          _TableHeaderCell(label: "Section", width: 90),
                                          _TableHeaderCell(label: "Status", width: 90),
                                          _TableHeaderCell(label: "Req Amount", width: 120),
                                          _TableHeaderCell(label: "TDS", width: 70),
                                          _TableHeaderCell(label: "Tax", width: 70),
                                          _TableHeaderCell(
                                            label: "Payable Amount",
                                            width: 140,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: rows.length,
                                          itemBuilder: (context, index) {
                                            final row = rows[index];
                                            return Row(
                                              children: [
                                                _TableBodyCell(
                                                  value: row.cRequestNo,
                                                  width: 95,
                                                ),
                                                _TableBodyCell(
                                                  value: row.dDate,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cUserName,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cAccountName,
                                                  width: 120,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cCategoryName,
                                                  width: 110,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cSectionName,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cStatus,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value:
                                                      "${String.fromCharCode(8377)}${_money(row.nReqAmount)}",
                                                  width: 120,
                                                ),
                                                _TableBodyCell(
                                                  value: _money(row.nTDS),
                                                  width: 70,
                                                ),
                                                _TableBodyCell(
                                                  value: _money(row.nTax),
                                                  width: 70,
                                                ),
                                                _TableBodyCell(
                                                  value:
                                                      "${String.fromCharCode(8377)}${_money(row.nPayable)}",
                                                  width: 140,
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
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F9FC),
                          border: Border(top: BorderSide(color: Color(0xFFE2E6EE))),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Swipe Horizontally for All Columns",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6D6D6D),
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 14,
                                onPressed: () => _scrollHorizontally(-120),
                                icon: const Icon(Icons.chevron_left),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 24,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCDD6E2)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 14,
                                onPressed: () => _scrollHorizontally(120),
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD5E8FB),
              border: Border(top: BorderSide(color: Color(0xFFCADDF4))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "TDS : ",
                        children: [
                          TextSpan(
                            text:
                                "${String.fromCharCode(8377)}${_money(totalTds)}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: "Tax : ",
                        children: [
                          TextSpan(
                            text:
                                "${String.fromCharCode(8377)}${_money(totalTax)}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Payable Amt : ",
                      style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
                    ),
                    Text(
                      "${String.fromCharCode(8377)}${_money(totalPayable)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00A32A),
                        fontWeight: FontWeight.w700,
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

class VoucherReportFilters {
  final int? projectId;
  final String projectName;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<int> accountIds;
  final String accountName;
  final List<int> categoryIds;
  final String categoryName;
  final List<int> sectionIds;
  final String sectionName;
  final List<int> userIds;
  final String userName;
  final String payMode;

  const VoucherReportFilters({
    required this.projectId,
    required this.projectName,
    required this.fromDate,
    required this.toDate,
    required this.accountIds,
    required this.accountName,
    required this.categoryIds,
    required this.categoryName,
    required this.sectionIds,
    required this.sectionName,
    required this.userIds,
    required this.userName,
    required this.payMode,
  });
}

class VoucherReportPage extends StatefulWidget {
  final VoucherReportFilters initialFilters;

  const VoucherReportPage({super.key, required this.initialFilters});

  @override
  State<VoucherReportPage> createState() => _VoucherReportPageState();
}

class _VoucherReportPageState extends State<VoucherReportPage> {
  late VoucherReportFilters _filters;
  final ScrollController _horizontalController = ScrollController();
  bool _showAllFilters = false;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadVoucherReport();
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$d-$m-$y";
  }

  String _dateRangeLabel() {
    if (_filters.fromDate == null || _filters.toDate == null) return "";
    return "${_formatDate(_filters.fromDate!)} - ${_formatDate(_filters.toDate!)}";
  }

  String _formatApiDate(DateTime? date) {
    if (date == null) return "";
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  String _idString(int? id) {
    if (id == null || id == 0) return "";
    return id.toString();
  }

  String _idsString(List<int> ids) {
    if (ids.isEmpty) return "";
    return ids.where((id) => id > 0).map((id) => id.toString()).join(",");
  }

  String _payModeApiValue(String payMode) {
    final normalized = payMode.trim().toLowerCase();
    if (normalized.isEmpty || normalized == "all") return "";
    return normalized;
  }

  String _money(double value) => value.toStringAsFixed(2);

  void _loadVoucherReport([VoucherReportFilters? sourceFilters]) {
    final selected = sourceFilters ?? _filters;
    context.read<BedtimeVoucherReportBloc>().add(
          BedtimeVoucherReportLoadRequested(
            companyId: 1,
            projectIds: _idString(selected.projectId),
            dFrom: _formatApiDate(selected.fromDate),
            dTo: _formatApiDate(selected.toDate),
            accountIds: _idsString(selected.accountIds),
            categoryIds: _idsString(selected.categoryIds),
            sectionIds: _idsString(selected.sectionIds),
            userIds: _idsString(selected.userIds),
            payModes: _payModeApiValue(selected.payMode),
          ),
        );
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VoucherReportSheet(
        initialFilters: _filters,
        onApply: (filters) {
          setState(() => _filters = filters);
          _loadVoucherReport(filters);
        },
      ),
    );
  }

  void _scrollHorizontally(double offset) {
    if (!_horizontalController.hasClients) return;
    final target = _horizontalController.offset + offset;
    _horizontalController.animateTo(
      target.clamp(
        0.0,
        _horizontalController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const scrollableColumnsWidth = 820.0;
    final dateRange = _dateRangeLabel();
    final appliedPrimary = [
      if (_filters.projectName.isNotEmpty) "Project : ${_filters.projectName}",
      if (dateRange.isNotEmpty) "Date : $dateRange",
    ];
    final appliedAll = [
      ...appliedPrimary,
      if (_filters.accountName.isNotEmpty) "Account : ${_filters.accountName}",
      if (_filters.categoryName.isNotEmpty)
        "Category : ${_filters.categoryName}",
      if (_filters.sectionName.isNotEmpty) "Section : ${_filters.sectionName}",
      if (_filters.userName.isNotEmpty) "User : ${_filters.userName}",
      if (_filters.payMode.isNotEmpty) "Pay Mode : ${_filters.payMode}",
    ];

    final applied = _showAllFilters ? appliedAll : appliedPrimary;
    final voucherState = context.watch<BedtimeVoucherReportBloc>().state;
    final rows = voucherState is BedtimeVoucherReportLoaded
        ? voucherState.rows
        : <BedtimeVoucherReportRow>[];
    final totalPayableAmount = rows.fold<double>(
      0.0,
      (sum, item) => sum + item.nPayableAmount,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Voucher Report",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openFilterSheet,
            icon: Image.asset(
              "assets/icons/filter.png",
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFFF2F6FB),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Applied",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A5A5A),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    applied.join(", "),
                    maxLines: _showAllFilters ? null : 1,
                    overflow: _showAllFilters
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    softWrap: _showAllFilters,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showAllFilters = !_showAllFilters),
                  child: Text(
                    _showAllFilters ? "View Less" : "View All",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A4B9A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E6EE)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Builder(
                builder: (context) {
                  if (voucherState is BedtimeVoucherReportLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (voucherState is BedtimeVoucherReportFailure) {
                    return Center(child: Text(voucherState.message));
                  }

                  if (rows.isEmpty) {
                    return const Center(child: Text("No voucher report found"));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Column(
                                children: [
                                  const _TableHeaderCell(
                                    label: "Srl",
                                    width: 50,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: rows.length,
                                      itemBuilder: (context, index) {
                                        return _TableBodyCell(
                                          value: "${index + 1}",
                                          width: 50,
                                          align: TextAlign.center,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: scrollableColumnsWidth,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: const [
                                          _TableHeaderCell(label: "Vou No", width: 90),
                                          _TableHeaderCell(label: "Date", width: 90),
                                          _TableHeaderCell(label: "User", width: 90),
                                          _TableHeaderCell(label: "Account", width: 120),
                                          _TableHeaderCell(label: "Category", width: 110),
                                          _TableHeaderCell(label: "Section", width: 90),
                                          _TableHeaderCell(
                                            label: "Payable Amount",
                                            width: 140,
                                          ),
                                          _TableHeaderCell(label: "Section", width: 90),
                                        ],
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: rows.length,
                                          itemBuilder: (context, index) {
                                            final row = rows[index];
                                            return Row(
                                              children: [
                                                _TableBodyCell(
                                                  value: row.cVoucherNo,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cVoucherDate,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cUserName,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cAccountName,
                                                  width: 120,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cCategoryName,
                                                  width: 110,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cSectionName,
                                                  width: 90,
                                                ),
                                                _TableBodyCell(
                                                  value:
                                                      "${String.fromCharCode(8377)}${_money(row.nPayableAmount)}",
                                                  width: 140,
                                                ),
                                                _TableBodyCell(
                                                  value: row.cPayMode,
                                                  width: 90,
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
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F9FC),
                          border: Border(top: BorderSide(color: Color(0xFFE2E6EE))),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Swipe Horizontally for All Columns",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6D6D6D),
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 14,
                                onPressed: () => _scrollHorizontally(-120),
                                icon: const Icon(Icons.chevron_left),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 24,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCDD6E2)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 14,
                                onPressed: () => _scrollHorizontally(120),
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD5E8FB),
              border: Border(top: BorderSide(color: Color(0xFFCADDF4))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Payable Amt : ",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                Text(
                  "${String.fromCharCode(8377)}${_money(totalPayableAmount)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00A32A),
                    fontWeight: FontWeight.w700,
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

class _TableHeaderCell extends StatelessWidget {
  final String label;
  final double width;

  const _TableHeaderCell({
    required this.label,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 34,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F6FA),
        border: Border(
          right: BorderSide(color: Color(0xFFE2E6EE)),
          bottom: BorderSide(color: Color(0xFFE2E6EE)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2D2D2D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TableBodyCell extends StatelessWidget {
  final String value;
  final double width;
  final TextAlign align;

  const _TableBodyCell({
    required this.value,
    required this.width,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E6EE)),
          bottom: BorderSide(color: Color(0xFFE2E6EE)),
        ),
      ),
      child: Text(
        value,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF3B3B3B),
        ),
      ),
    );
  }
}
