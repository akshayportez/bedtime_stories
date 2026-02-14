part of 'package:bedtime_stories/utils/lib_files.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int _approvalPendingCount = 0;
  int _voucherPendingCount = 0;

  final List<String> tabs = ["Request", "Approval", "Voucher", "Reports"];

  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  Future<void> _reloadApprovalList() async {
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userData = await BedtimeLocalStorage.getUserData();
    final userActionId = _resolveInt(userData["userId"]);

    if (!mounted) return;
    context.read<BedtimePaymentRequestBloc>().add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: projectId,
        userActionId: userActionId,
        search: "",
        statusFilter: "",
        dFrom: "",
        dTo: "",
      ),
    );

    await _loadApprovalPendingCount();
  }

  Future<void> _reloadVoucherList() async {
    await _loadVoucherPendingCount();
  }

  Future<void> _loadApprovalPendingCount() async {
    try {
      final repository = context.read<BedtimePaymentRequestBloc>().repository;
      final projectId = await BedtimeLocalStorage.getSelectedProjectId();
      final requests = await repository.getPaymentRequests(
            companyId: 1,
            projectId: projectId,
            userActionId: 0,
            search: "",
            statusFilter: "Requested",
            dFrom: "",
            dTo: "",
          );

      final pendingCount = requests
          .where((r) {
            final status = r.cStatus.trim().toLowerCase();
            return status == "requested" || status == "reqested";
          })
          .length;

      if (!mounted) return;
      setState(() {
        _approvalPendingCount = pendingCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _approvalPendingCount = 0;
      });
    }
  }

  Future<void> _loadVoucherPendingCount() async {
    try {
      final repository = context.read<BedtimePaymentRequestBloc>().repository;
      final projectId = await BedtimeLocalStorage.getSelectedProjectId();
      final requests = await repository.getPaymentRequests(
        companyId: 1,
        projectId: projectId,
        userActionId: 0,
        search: "",
        statusFilter: "Approved",
        dFrom: "",
        dTo: "",
      );

      final pendingCount = requests
          .where((r) => r.cStatus.trim().toLowerCase() == "approved")
          .length;

      if (!mounted) return;
      setState(() {
        _voucherPendingCount = pendingCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _voucherPendingCount = 0;
      });
    }
  }

  Widget _buildFabIcon() {
    final badgeCount = switch (selectedIndex) {
      1 => _approvalPendingCount,
      2 => _voucherPendingCount,
      _ => 0,
    };

    if (badgeCount <= 0) {
      return const Icon(Icons.add, size: 28, color: Colors.white);
    }

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(child: Icon(Icons.add, size: 28, color: Colors.white)),
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4D5A),
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount > 99 ? "99" : "$badgeCount",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadApprovalPendingCount();
    _loadVoucherPendingCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // MOST IMPORTANT
      backgroundColor: Colors.white,

      /// Body Pages
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          RequestPage(),
          ApprovalPage(),
          VoucherPage(),
          ReportsPage(),
        ],
      ),

      /// Floating Action Button
      floatingActionButton: selectedIndex == 3
          ? null
          : FloatingActionButton(
              backgroundColor: appPrimaryColor,
              shape: const CircleBorder(),
              onPressed: () async {
                if (selectedIndex == 1) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApprovalRequestedPage(),
                    ),
                  );
                  await _reloadApprovalList();
                  return;
                }
                if (selectedIndex == 2) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoucherApprovalRequestsPage(),
                    ),
                  );
                  await _reloadVoucherList();
                  return;
                }
                Navigator.pushNamed(context, "/createRequestPage");
              },
              child: _buildFabIcon(),
            ),

      /// Bottom Navigation
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 14 + MediaQuery.of(context).padding.bottom,
        ),
        child: _BottomNavBar(
          selectedIndex: selectedIndex,
          showApprovalDot: selectedIndex != 1 && _approvalPendingCount > 0,
          showVoucherDot: selectedIndex != 2 && _voucherPendingCount > 0,
          onChanged: (index) {
            setState(() => selectedIndex = index);
            _loadApprovalPendingCount();
            _loadVoucherPendingCount();
          },
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool showApprovalDot;
  final bool showVoucherDot;
  final Function(int) onChanged;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.showApprovalDot,
    required this.showVoucherDot,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: appPrimaryColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            assetIcon: "assets/icons/request_icon.png",
            text: "Request",
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            assetIcon: "assets/icons/approval_icon.png",
            text: "Approval",
            isSelected: selectedIndex == 1,
            showDot: showApprovalDot,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            assetIcon: "assets/icons/voucher_icon.png",
            text: "Voucher",
            isSelected: selectedIndex == 2,
            showDot: showVoucherDot,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            assetIcon: "assets/icons/reports_icon.png",
            text: "Reports",
            isSelected: selectedIndex == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String assetIcon;
  final String text;
  final bool isSelected;
  final bool showDot;
  final VoidCallback onTap;

  const _NavItem({
    required this.assetIcon,
    required this.text,
    required this.isSelected,
    this.showDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: isSelected ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.transparent,
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF04BBD0), Color(0xFF79A2F4)],
                )
              : null,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ImageIcon(
                  AssetImage(assetIcon),
                  size: 22,
                  color: isSelected ? Colors.white : appPrimaryColor,
                ),
                if (showDot)
                  const Positioned(
                    right: -1,
                    top: -2,
                    child: SizedBox(
                      width: 8,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
