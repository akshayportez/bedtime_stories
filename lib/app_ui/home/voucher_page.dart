part of 'package:bedtime_stories/utils/lib_files.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  late final BedtimePaymentRequestBloc _voucherBloc;
  bool _isRouteObserverSubscribed = false;
  int _projectId = 0;
  int _userActionId = 0;
  String _dFrom = "";
  String _dTo = "";

  @override
  void initState() {
    super.initState();
    _voucherBloc = BedtimePaymentRequestBloc(
      context.read<BedtimePaymentRequestBloc>().repository,
    );
    _loadVouchers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isRouteObserverSubscribed) return;
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute as ModalRoute<void>);
      _isRouteObserverSubscribed = true;
    }
  }

  @override
  void didPopNext() {
    _loadVouchers();
  }

  @override
  void dispose() {
    if (_isRouteObserverSubscribed) {
      routeObserver.unsubscribe(this);
    }
    _voucherBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userData = await BedtimeLocalStorage.getUserData();
    final userIdValue = userData["userId"];
    _projectId = projectId;
    _userActionId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? "") ?? 0;

    if (!mounted) return;

    _voucherBloc.add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: projectId,
        userActionId: _userActionId,
        search: "",
        statusFilter: "Paid",
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
            await _loadVouchers();
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
        _voucherBloc.add(
          BedtimePaymentRequestSearchRequested(
            companyId: 1,
            projectId: _projectId,
            userActionId: _userActionId,
            search: value.trim(),
            statusFilter: "Paid",
            dFrom: _dFrom,
            dTo: _dTo,
          ),
        );
      });
      return;
    }

    _voucherBloc.add(
      BedtimePaymentRequestSearchRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: value.trim(),
        statusFilter: "Paid",
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
          initialStatus: "Paid",
          initialDate: _dFrom.isEmpty ? null : DateTime.tryParse(_dFrom),
          onApply: (selectedDate, _) async {
            if (selectedDate == null) {
              _dFrom = "";
              _dTo = "";
            } else {
              final formatted = _formatDate(selectedDate);
              _dFrom = formatted;
              _dTo = formatted;
            }
            if (mounted) setState(() {});
            await _loadVouchers();
          },
        );
      },
    );
  }

  bool _isPaid(String status) => status.trim().toLowerCase() == "paid";

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
              "Voucher",
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
              child: BlocBuilder<BedtimePaymentRequestBloc, BedtimePaymentRequestState>(
                bloc: _voucherBloc,
                builder: (context, state) {
                  if (state is BedtimePaymentRequestLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BedtimePaymentRequestFailure) {
                    return Center(child: Text(state.message));
                  }

                  if (state is BedtimePaymentRequestLoaded) {
                    final vouchers = state.requests.where((r) => _isPaid(r.cStatus)).toList();
                    if (vouchers.isEmpty) {
                      return const Center(child: Text("No vouchers found"));
                    }

                    final bottomInset = MediaQuery.of(context).padding.bottom;
                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 16 + bottomInset + 96),
                      itemCount: vouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = vouchers[index];
                        return _VoucherCard(
                          request: voucher,
                          voucherNo: (voucher.cVoucherNo ?? "").isEmpty
                              ? voucher.cRequestNo
                              : (voucher.cVoucherNo ?? ""),
                          dateTime: voucher.cVoucherDateTime ?? voucher.cRequestDateTime ?? "",
                          name: voucher.cAccountName,
                          category: voucher.cCategoryName,
                          section: voucher.cSectionName,
                          amount: _formatAmount(voucher.nPayableAmount),
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

class _VoucherCard extends StatelessWidget {
  final BedtimePaymentRequest request;
  final String voucherNo;
  final String dateTime;
  final String name;
  final String category;
  final String section;
  final String amount;

  const _VoucherCard({
    required this.request,
    required this.voucherNo,
    required this.dateTime,
    required this.name,
    required this.category,
    required this.section,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VoucherViewPage(request: request),
          ),
        );
      },
      child: Container(
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
                    children: [
                      Text(
                        "Vou No : $voucherNo",
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
                      const Text(
                        "Section",
                        style: TextStyle(
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF256DFB),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DDEA),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "Cheque",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A7388),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
