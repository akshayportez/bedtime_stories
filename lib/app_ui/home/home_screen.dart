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
  bool _accessRightsLoaded = false;
  bool _canViewPaymentRequestPage = false;
  bool _canAddPaymentRequest = false;
  bool _canViewPaymentApprovalPage = false;
  bool _canAddPaymentApproval = false;
  bool _canViewPaymentVoucherPage = false;
  bool _canAddPaymentVoucher = false;
  bool _canViewReportsPage = false;
  final Set<int> _initializedTabs = <int>{};

  final List<String> tabs = ["Request", "Approval", "Voucher", "Reports"];

  Future<void> _reloadApprovalList() async {
    await _loadApprovalPendingCount();
  }

  Future<void> _reloadVoucherList() async {
    await _loadVoucherPendingCount();
  }

  void _showNoRightsMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadAccessRights() async {
    final permissionSet = await BedtimeLocalStorage.getMenuPermissionSet();
    final canViewPaymentRequestPage = permissionSet.contains("paymentrequest");
    final canAddPaymentRequest = permissionSet.contains(
      "transaction-paymentrequest-add",
    );
    final canViewPaymentApprovalPage = permissionSet.contains("paymentapproval");
    final canAddPaymentApproval = permissionSet.contains(
      "transaction-paymentapproval-add",
    );
    final canViewPaymentVoucherPage = permissionSet.contains("paymentvoucher");
    final canAddPaymentVoucher = permissionSet.contains(
      "transaction-paymentvoucher-add",
    );
    final canViewReportsPage = permissionSet.contains("reports");
    if (!mounted) return;

    final pageAccess = [
      canViewPaymentRequestPage,
      canViewPaymentApprovalPage,
      canViewPaymentVoucherPage,
      canViewReportsPage,
    ];
    var nextIndex = selectedIndex;
    if (nextIndex < 0 || nextIndex >= pageAccess.length || !pageAccess[nextIndex]) {
      nextIndex = pageAccess.indexWhere((canView) => canView);
      if (nextIndex == -1) {
        nextIndex = 0;
      }
    }

    setState(() {
      _accessRightsLoaded = true;
      _canViewPaymentRequestPage = canViewPaymentRequestPage;
      _canAddPaymentRequest = canAddPaymentRequest;
      _canViewPaymentApprovalPage = canViewPaymentApprovalPage;
      _canAddPaymentApproval = canAddPaymentApproval;
      _canViewPaymentVoucherPage = canViewPaymentVoucherPage;
      _canAddPaymentVoucher = canAddPaymentVoucher;
      _canViewReportsPage = canViewReportsPage;
      selectedIndex = nextIndex;
      _initializedTabs.add(nextIndex);
    });

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 350), () async {
        if (!mounted) return;
        await _loadApprovalPendingCount();
        await _loadVoucherPendingCount();
      }),
    );
  }

  Future<void> _loadApprovalPendingCount() async {
    if (!_canViewPaymentApprovalPage) {
      if (!mounted) return;
      setState(() {
        _approvalPendingCount = 0;
      });
      return;
    }

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
    if (!_canViewPaymentVoucherPage) {
      if (!mounted) return;
      setState(() {
        _voucherPendingCount = 0;
      });
      return;
    }

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
    BedtimeLocalStorage.selectedProjectChangeNotifier.addListener(
      _handleSelectedProjectChanged,
    );
    BedtimeLocalStorage.paymentDataChangeNotifier.addListener(
      _handlePaymentDataChanged,
    );
    _loadAccessRights();
  }

  @override
  void dispose() {
    BedtimeLocalStorage.selectedProjectChangeNotifier.removeListener(
      _handleSelectedProjectChanged,
    );
    BedtimeLocalStorage.paymentDataChangeNotifier.removeListener(
      _handlePaymentDataChanged,
    );
    super.dispose();
  }

  void _handleSelectedProjectChanged() {
    if (!_accessRightsLoaded) return;
    unawaited(_loadApprovalPendingCount());
    unawaited(_loadVoucherPendingCount());
  }

  void _handlePaymentDataChanged() {
    if (!_accessRightsLoaded) return;
    unawaited(_loadApprovalPendingCount());
    unawaited(_loadVoucherPendingCount());
  }

  Widget _buildTabPage(int index) {
    switch (index) {
      case 0:
        return _canViewPaymentRequestPage
            ? const RequestPage()
            : const _NoRightsPage(
                message: "No permission to view request page",
              );
      case 1:
        return _canViewPaymentApprovalPage
            ? const ApprovalPage()
            : const _NoRightsPage(
                message: "No permission to view approval page",
              );
      case 2:
        return _canViewPaymentVoucherPage
            ? const VoucherPage()
            : const _NoRightsPage(
                message: "No permission to view voucher page",
              );
      case 3:
      default:
        return _canViewReportsPage
            ? const ReportsPage()
            : const _NoRightsPage(
                message: "No permission to view reports page",
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // MOST IMPORTANT
      backgroundColor: Colors.white,

      /// Body Pages
      body: !_accessRightsLoaded
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedIndex,
              children: List<Widget>.generate(4, (index) {
                if (!_initializedTabs.contains(index)) {
                  return const SizedBox.shrink();
                }
                return _buildTabPage(index);
              }),
            ),

      /// Floating Action Button
      floatingActionButton: !_accessRightsLoaded ||
              selectedIndex == 3 ||
              (selectedIndex == 0 && !_canAddPaymentRequest) ||
              (selectedIndex == 1 && !_canAddPaymentApproval) ||
              (selectedIndex == 2 && !_canAddPaymentVoucher)
          ? null
          : FloatingActionButton(
              backgroundColor: appPrimaryColor,
              shape: const CircleBorder(),
              onPressed: () async {
                if (selectedIndex == 1) {
                  if (!_canAddPaymentApproval) {
                    _showNoRightsMessage("No permission to add payment approval");
                    return;
                  }
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApprovalRequestedPage(),
                    ),
                  );
                  if (changed == true) {
                    BedtimeLocalStorage.notifyPaymentDataChanged();
                  }
                  await _reloadApprovalList();
                  await _reloadVoucherList();
                  return;
                }
                if (selectedIndex == 2) {
                  if (!_canAddPaymentVoucher) {
                    _showNoRightsMessage("No permission to add payment voucher");
                    return;
                  }
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoucherApprovalRequestsPage(),
                    ),
                  );
                  if (changed == true) {
                    BedtimeLocalStorage.notifyPaymentDataChanged();
                  }
                  await _reloadVoucherList();
                  await _reloadApprovalList();
                  return;
                }
                if (selectedIndex == 0 && !_canAddPaymentRequest) {
                  _showNoRightsMessage("No permission to add payment request");
                  return;
                }
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateRequestPage(),
                  ),
                );
                if (created == true) {
                  BedtimeLocalStorage.notifyPaymentDataChanged();
                }
                await _reloadApprovalList();
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
            if (!_accessRightsLoaded) return;
            if (index == 0 && !_canViewPaymentRequestPage) {
              _showNoRightsMessage("No permission to view request page");
              return;
            }
            if (index == 1 && !_canViewPaymentApprovalPage) {
              _showNoRightsMessage("No permission to view approval page");
              return;
            }
            if (index == 2 && !_canViewPaymentVoucherPage) {
              _showNoRightsMessage("No permission to view voucher page");
              return;
            }
            if (index == 3 && !_canViewReportsPage) {
              _showNoRightsMessage("No permission to view reports page");
              return;
            }
            setState(() {
              selectedIndex = index;
              _initializedTabs.add(index);
            });
            if (index == 1) {
              unawaited(_loadApprovalPendingCount());
            } else if (index == 2) {
              unawaited(_loadVoucherPendingCount());
            }
          },
        ),
      ),
    );
  }
}

class _NoRightsPage extends StatelessWidget {
  final String message;

  const _NoRightsPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF5F5F5F),
          fontWeight: FontWeight.w500,
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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return Container(
      height: isTablet ? 78 : 70,
      padding: EdgeInsets.symmetric(horizontal: 6),

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
          Expanded(
            flex: selectedIndex == 0 ? 2 : 1,
            child: Center(
              child: _NavItem(
                assetIcon: "assets/icons/request_icon.png",
                text: "Request",
                isSelected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
          ),
          Expanded(
            flex: selectedIndex == 1 ? 2 : 1,
            child: Center(
              child: _NavItem(
                assetIcon: "assets/icons/approval_icon.png",
                text: "Approval",
                isSelected: selectedIndex == 1,
                showDot: showApprovalDot,
                onTap: () => onChanged(1),
              ),
            ),
          ),
          Expanded(
            flex: selectedIndex == 2 ? 2 : 1,
            child: Center(
              child: _NavItem(
                assetIcon: "assets/icons/voucher_icon.png",
                text: "Voucher",
                isSelected: selectedIndex == 2,
                showDot: showVoucherDot,
                onTap: () => onChanged(2),
              ),
            ),
          ),
          Expanded(
            flex: selectedIndex == 3 ? 2 : 1,
            child: Center(
              child: _NavItem(
                assetIcon: "assets/icons/reports_icon.png",
                text: "Reports",
                isSelected: selectedIndex == 3,
                onTap: () => onChanged(3),
              ),
            ),
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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? (isTablet ? 34 : 18) : (isTablet ? 16 : 10),
          vertical: isSelected ? 14 : 12,
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
          mainAxisSize: MainAxisSize.min,
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
