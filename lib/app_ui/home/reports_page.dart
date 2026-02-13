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
          color: const Color(0xFFF2F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD3DCEA)),
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
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
  int? _selectedAccountId;
  String _selectedAccountName = "";
  int? _selectedCategoryId;
  String _selectedCategoryName = "";
  int? _selectedSectionId;
  String _selectedSectionName = "";
  String _selectedStatus = "All";
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedUser;
  String _projectName = "";

  static const List<String> _userOptions = [
    "Admin User",
    "Sai Krishna",
    "Finance User",
  ];

  @override
  void initState() {
    super.initState();
    _loadProjectName();
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
  }

  Future<void> _loadProjectName() async {
    final name = await BedtimeLocalStorage.getSelectedProjectName();
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    if (!mounted) return;
    final initial = widget.initialFilters;
    setState(() {
      _projectName = initial?.projectName.isNotEmpty == true
          ? initial!.projectName
          : name;
      _selectedProjectId =
          initial?.projectId ?? (projectId == 0 ? null : projectId);
      _selectedProjectName = _projectName;
      _selectedAccountId = initial?.accountId;
      _selectedAccountName = initial?.accountName ?? "";
      _selectedCategoryId = initial?.categoryId;
      _selectedCategoryName = initial?.categoryName ?? "";
      _selectedSectionId = initial?.sectionId;
      _selectedSectionName = initial?.sectionName ?? "";
      _selectedStatus = initial?.status ?? "All";
      _fromDate = initial?.fromDate;
      _toDate = initial?.toDate;
      _selectedUser = initial?.user;
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _toDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final accountState = context.watch<BedtimeGetAccountsListBloc>().state;
    final categoryState = context.watch<BedtimeGetCategoryListBloc>().state;
    final sectionState = context.watch<BedtimeGetSectionListBloc>().state;
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
                  color: const Color(0xFFDCEAF8),
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
                hint: "Select Account",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: accounts.any((e) => e.nAccountId == _selectedAccountId)
                        ? _selectedAccountId
                        : null,
                    hint: const Text(
                      "Select Account",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: accounts
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nAccountId,
                            child: Text(
                              item.cAccountName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedAccountId = v);
                      if (v == null) return;
                      for (final item in accounts) {
                        if (item.nAccountId == v) {
                          _selectedAccountName = item.cAccountName;
                          break;
                        }
                      }
                    },
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
                hint: "Select Category",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: categories.any((e) => e.nCategoryId == _selectedCategoryId)
                        ? _selectedCategoryId
                        : null,
                    hint: const Text(
                      "Select Category",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: categories
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nCategoryId,
                            child: Text(
                              item.cCategoryName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedCategoryId = v);
                      if (v == null) return;
                      for (final item in categories) {
                        if (item.nCategoryId == v) {
                          _selectedCategoryName = item.cCategoryName;
                          break;
                        }
                      }
                    },
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
                hint: "Select Section",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: sections.any((e) => e.nSectionId == _selectedSectionId)
                        ? _selectedSectionId
                        : null,
                    hint: const Text(
                      "Select Section",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: sections
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nSectionId,
                            child: Text(
                              item.cSectionName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedSectionId = v);
                      if (v == null) return;
                      for (final item in sections) {
                        if (item.nSectionId == v) {
                          _selectedSectionName = item.cSectionName;
                          break;
                        }
                      }
                    },
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
                hint: "Select User",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedUser,
                    hint: const Text(
                      "Select User",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: _userOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUser = v),
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

                      var accountName = _selectedAccountName;
                      if (accountName.isEmpty) {
                        for (final item in accounts) {
                          if (item.nAccountId == _selectedAccountId) {
                            accountName = item.cAccountName;
                            break;
                          }
                        }
                      }

                      var categoryName = _selectedCategoryName;
                      if (categoryName.isEmpty) {
                        for (final item in categories) {
                          if (item.nCategoryId == _selectedCategoryId) {
                            categoryName = item.cCategoryName;
                            break;
                          }
                        }
                      }

                      var sectionName = _selectedSectionName;
                      if (sectionName.isEmpty) {
                        for (final item in sections) {
                          if (item.nSectionId == _selectedSectionId) {
                            sectionName = item.cSectionName;
                            break;
                          }
                        }
                      }

                      final filters = PaymentRequestReportFilters(
                        projectId: _selectedProjectId,
                        projectName: projectName,
                        status: _selectedStatus,
                        fromDate: _fromDate,
                        toDate: _toDate,
                        accountId: _selectedAccountId,
                        accountName: accountName,
                        categoryId: _selectedCategoryId,
                        categoryName: categoryName,
                        sectionId: _selectedSectionId,
                        sectionName: sectionName,
                        user: _selectedUser,
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
  int? _selectedAccountId;
  String _selectedAccountName = "";
  int? _selectedCategoryId;
  String _selectedCategoryName = "";
  int? _selectedSectionId;
  String _selectedSectionName = "";
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedUser;
  String _projectName = "";

  static const List<String> _userOptions = [
    "Admin User",
    "Sai Krishna",
    "Finance User",
  ];

  @override
  void initState() {
    super.initState();
    _loadProjectName();
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
  }

  Future<void> _loadProjectName() async {
    final name = await BedtimeLocalStorage.getSelectedProjectName();
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    if (!mounted) return;
    final initial = widget.initialFilters;
    setState(() {
      _projectName = initial?.projectName.isNotEmpty == true
          ? initial!.projectName
          : name;
      _selectedProjectId =
          initial?.projectId ?? (projectId == 0 ? null : projectId);
      _selectedProjectName = _projectName;
      _selectedAccountId = initial?.accountId;
      _selectedAccountName = initial?.accountName ?? "";
      _selectedCategoryId = initial?.categoryId;
      _selectedCategoryName = initial?.categoryName ?? "";
      _selectedSectionId = initial?.sectionId;
      _selectedSectionName = initial?.sectionName ?? "";
      _fromDate = initial?.fromDate;
      _toDate = initial?.toDate;
      _selectedUser = initial?.user;
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _toDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final accountState = context.watch<BedtimeGetAccountsListBloc>().state;
    final categoryState = context.watch<BedtimeGetCategoryListBloc>().state;
    final sectionState = context.watch<BedtimeGetSectionListBloc>().state;
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
                hint: "Select Account",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: accounts.any((e) => e.nAccountId == _selectedAccountId)
                        ? _selectedAccountId
                        : null,
                    hint: const Text(
                      "Select Account",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: accounts
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nAccountId,
                            child: Text(
                              item.cAccountName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAccountId = v),
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
                hint: "Select Category",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: categories.any((e) => e.nCategoryId == _selectedCategoryId)
                        ? _selectedCategoryId
                        : null,
                    hint: const Text(
                      "Select Category",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: categories
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nCategoryId,
                            child: Text(
                              item.cCategoryName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
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
                hint: "Select Section",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: sections.any((e) => e.nSectionId == _selectedSectionId)
                        ? _selectedSectionId
                        : null,
                    hint: const Text(
                      "Select Section",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: sections
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item.nSectionId,
                            child: Text(
                              item.cSectionName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSectionId = v),
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
                hint: "Select User",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedUser,
                    hint: const Text(
                      "Select User",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    items: _userOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUser = v),
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

                      var accountName = _selectedAccountName;
                      if (accountName.isEmpty) {
                        for (final item in accounts) {
                          if (item.nAccountId == _selectedAccountId) {
                            accountName = item.cAccountName;
                            break;
                          }
                        }
                      }

                      var categoryName = _selectedCategoryName;
                      if (categoryName.isEmpty) {
                        for (final item in categories) {
                          if (item.nCategoryId == _selectedCategoryId) {
                            categoryName = item.cCategoryName;
                            break;
                          }
                        }
                      }

                      var sectionName = _selectedSectionName;
                      if (sectionName.isEmpty) {
                        for (final item in sections) {
                          if (item.nSectionId == _selectedSectionId) {
                            sectionName = item.cSectionName;
                            break;
                          }
                        }
                      }

                      final filters = VoucherReportFilters(
                        projectId: _selectedProjectId,
                        projectName: projectName,
                        fromDate: _fromDate,
                        toDate: _toDate,
                        accountId: _selectedAccountId,
                        accountName: accountName,
                        categoryId: _selectedCategoryId,
                        categoryName: categoryName,
                        sectionId: _selectedSectionId,
                        sectionName: sectionName,
                        user: _selectedUser,
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
  final int? accountId;
  final String accountName;
  final int? categoryId;
  final String categoryName;
  final int? sectionId;
  final String sectionName;
  final String? user;

  const PaymentRequestReportFilters({
    required this.projectId,
    required this.projectName,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    required this.sectionId,
    required this.sectionName,
    required this.user,
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

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentRequestReportSheet(
        initialFilters: _filters,
        onApply: (filters) {
          setState(() => _filters = filters);
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

  List<Map<String, String>> _rows() {
    return [
      {
        "Srl": "1",
        "Req No": "REQ001",
        "Date": "22 Jan 2025",
        "User": "User 1",
        "Account": "Mammon",
        "Category": "Travel",
        "Section": "Cash",
        "Status": _filters.status == "All" ? "Approved" : _filters.status,
        "Req Amount": "\u20B9460000.00",
        "TDS": "100",
        "Tax": "1000",
        "Payable Amount": "\u20B9450000.00",
      },
    ];
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
      if ((_filters.user ?? "").isNotEmpty) "User : ${_filters.user}",
    ];

    final applied = _showAllFilters ? appliedAll : appliedPrimary;
    final rows = _rows();

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
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
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
              child: Column(
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
                                      value: rows[index]["Srl"] ?? "",
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
                                      _TableHeaderCell(label: "Payable Amount", width: 140),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: rows.length,
                                      itemBuilder: (context, index) {
                                        final row = rows[index];
                                        return Row(
                                          children: [
                                            _TableBodyCell(value: row["Req No"] ?? "", width: 95),
                                            _TableBodyCell(value: row["Date"] ?? "", width: 90),
                                            _TableBodyCell(value: row["User"] ?? "", width: 90),
                                            _TableBodyCell(value: row["Account"] ?? "", width: 120),
                                            _TableBodyCell(value: row["Category"] ?? "", width: 110),
                                            _TableBodyCell(value: row["Section"] ?? "", width: 90),
                                            _TableBodyCell(value: row["Status"] ?? "", width: 90),
                                            _TableBodyCell(value: row["Req Amount"] ?? "", width: 120),
                                            _TableBodyCell(value: row["TDS"] ?? "", width: 70),
                                            _TableBodyCell(value: row["Tax"] ?? "", width: 70),
                                            _TableBodyCell(value: row["Payable Amount"] ?? "", width: 140),
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
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D6D6D)),
                          ),
                        ),
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
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFDCEAF8),
              border: Border(top: BorderSide(color: Color(0xFFCADDF4))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TDS : 100",
                      style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
                    ),
                    Text(
                      "Tax : 1000",
                      style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Payable Amt : ",
                      style: TextStyle(fontSize: 12, color: Color(0xFF2D2D2D)),
                    ),
                    Text(
                      "\u20B9450000.00",
                      style: TextStyle(
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
  final int? accountId;
  final String accountName;
  final int? categoryId;
  final String categoryName;
  final int? sectionId;
  final String sectionName;
  final String? user;

  const VoucherReportFilters({
    required this.projectId,
    required this.projectName,
    required this.fromDate,
    required this.toDate,
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    required this.sectionId,
    required this.sectionName,
    required this.user,
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

  String _userIdString(String? userValue) {
    if (userValue == null || userValue.trim().isEmpty) return "";
    return userValue.trim();
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
            accountIds: _idString(selected.accountId),
            categoryIds: _idString(selected.categoryId),
            sectionIds: _idString(selected.sectionId),
            userIds: _userIdString(selected.user),
            payModes: "",
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
      if ((_filters.user ?? "").isNotEmpty) "User : ${_filters.user}",
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
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
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
                                border: Border.all(color: const Color(0xFFCDD6E2)),
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
              color: Color(0xFFDCEAF8),
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
