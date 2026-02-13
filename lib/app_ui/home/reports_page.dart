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
      builder: (_) => const _PaymentRequestReportSheet(),
    );
  }

  Future<void> _openVoucherReportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _VoucherReportSheet(),
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
  const _PaymentRequestReportSheet();

  @override
  State<_PaymentRequestReportSheet> createState() =>
      _PaymentRequestReportSheetState();
}

class _PaymentRequestReportSheetState extends State<_PaymentRequestReportSheet> {
  int? _selectedProjectId;
  int? _selectedAccountId;
  int? _selectedCategoryId;
  int? _selectedSectionId;
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
    setState(() {
      _projectName = name;
      _selectedProjectId = projectId == 0 ? null : projectId;
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
                    onPressed: () => Navigator.pop(context),
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
  const _VoucherReportSheet();

  @override
  State<_VoucherReportSheet> createState() => _VoucherReportSheetState();
}

class _VoucherReportSheetState extends State<_VoucherReportSheet> {
  int? _selectedProjectId;
  int? _selectedAccountId;
  int? _selectedCategoryId;
  int? _selectedSectionId;
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
    setState(() {
      _projectName = name;
      _selectedProjectId = projectId == 0 ? null : projectId;
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
                    onPressed: () => Navigator.pop(context),
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
