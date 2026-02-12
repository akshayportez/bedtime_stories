part of 'package:bedtime_stories/utils/lib_files.dart';

class VoucherApprovalRequestsPage extends StatefulWidget {
  const VoucherApprovalRequestsPage({super.key});

  @override
  State<VoucherApprovalRequestsPage> createState() =>
      _VoucherApprovalRequestsPageState();
}

class _VoucherApprovalRequestsPageState extends State<VoucherApprovalRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  late final BedtimePaymentRequestBloc _bloc;
  int _projectId = 0;
  int _userActionId = 0;

  @override
  void initState() {
    super.initState();
    _bloc = BedtimePaymentRequestBloc(
      context.read<BedtimePaymentRequestBloc>().repository,
    );
    _loadApprovedRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _loadApprovedRequests() async {
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userData = await BedtimeLocalStorage.getUserData();
    final userIdValue = userData["userId"];
    _projectId = projectId;
    _userActionId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? "") ?? 0;

    if (!mounted) return;
    _bloc.add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: "",
        statusFilter: "Approved",
      ),
    );
  }

  void _onSearchChanged(String value) {
    _bloc.add(
      BedtimePaymentRequestSearchRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: value.trim(),
        statusFilter: "Approved",
      ),
    );
  }

  bool _isApproved(String status) => status.trim().toLowerCase() == "approved";

  String _formatAmount(double amount) => amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Approved Request",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 18),
                ],
              ),
              const SizedBox(height: 12),
              _RequestSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<BedtimePaymentRequestBloc, BedtimePaymentRequestState>(
                  bloc: _bloc,
                  builder: (context, state) {
                    if (state is BedtimePaymentRequestLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is BedtimePaymentRequestFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is BedtimePaymentRequestLoaded) {
                      final approvedItems =
                          state.requests.where((r) => _isApproved(r.cStatus)).toList();
                      if (approvedItems.isEmpty) {
                        return const Center(child: Text("No approved requests found"));
                      }
                      return ListView.builder(
                        itemCount: approvedItems.length,
                        itemBuilder: (context, index) {
                          final item = approvedItems[index];
                          return GestureDetector(
                            onTap: () async {
                              final shouldReload = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VoucherApprovalRequestDetailPage(
                                    request: item,
                                  ),
                                ),
                              );
                              if (shouldReload == true) {
                                await _loadApprovedRequests();
                              }
                            },
                            child: _VoucherApprovalRequestCard(
                              approvedBy: item.cApprovedBy ?? "",
                              approvedDate: item.cApprovedDateTime ?? "-",
                              reqNo: item.cRequestNo,
                              requestDate: item.cRequestDateTime ?? "-",
                              accountName: item.cAccountName,
                              amount: _formatAmount(item.nPayableAmount),
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
      ),
    );
  }
}

class _VoucherApprovalRequestCard extends StatelessWidget {
  final String approvedBy;
  final String approvedDate;
  final String reqNo;
  final String requestDate;
  final String accountName;
  final String amount;

  const _VoucherApprovalRequestCard({
    required this.approvedBy,
    required this.approvedDate,
    required this.reqNo,
    required this.requestDate,
    required this.accountName,
    required this.amount,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Approved",
                      style: TextStyle(
                        color: Color(0xFF23B200),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      approvedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7C7C7C),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      "Approved by : ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        approvedBy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F7F7F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                  Container(height: 2, color: const Color(0xFFF3F7FC)),
                     const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      "Req No : $reqNo",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      requestDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7C7C7C),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFEAF2FF),
                      child: Text(
                        accountName.isNotEmpty ? accountName[0].toUpperCase() : "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F9FC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/icons/payment_animation.gif",
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                const Text(
                  "Payable Amt : ",
                  style: TextStyle(fontSize: 12, color: Color(0xFF7F7F7F)),
                ),
                Text(
                  "\u20B9$amount",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF256DFB),
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
