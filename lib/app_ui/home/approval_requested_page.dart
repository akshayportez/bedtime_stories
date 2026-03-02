part of 'package:bedtime_stories/utils/lib_files.dart';

class ApprovalRequestedPage extends StatefulWidget {
  const ApprovalRequestedPage({super.key});

  @override
  State<ApprovalRequestedPage> createState() => _ApprovalRequestedPageState();
}

class _ApprovalRequestedPageState extends State<ApprovalRequestedPage> {
  final TextEditingController _searchController = TextEditingController();
  int _projectId = 0;
  static const int _userActionId = 0;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    _projectId = await BedtimeLocalStorage.getSelectedProjectId();
    if (!mounted) return;

    context.read<BedtimePaymentRequestBloc>().add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: "",
        statusFilter: "Requested",
        // cStatus: "Requested",
      ),
    );
  }

  void _onSearchChanged(String value) {
    context.read<BedtimePaymentRequestBloc>().add(
      BedtimePaymentRequestSearchRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: value.trim(),
        statusFilter: "Requested",
        // cStatus: "Requested",
      ),
    );
  }

  bool _isRequestedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == "requested" || normalized == "reqested";
  }

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
                    "Request",
                    style: TextStyle(
                      fontSize: 24 / 1.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 18),
                ],
              ),
              const SizedBox(height: 14),
              _ApprovalRequestedSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is BedtimePaymentRequestFailure) {
                          return Center(child: Text(state.message));
                        }

                        if (state is BedtimePaymentRequestLoaded) {
                          final requestedItems = state.requests
                              .where((r) => _isRequestedStatus(r.cStatus))
                              .toList();

                          if (requestedItems.isEmpty) {
                            return const Center(
                              child: Text("No requests found"),
                            );
                          }

                          return ListView.builder(
                            itemCount: requestedItems.length,
                            itemBuilder: (context, index) {
                              final request = requestedItems[index];
                              return GestureDetector(
                                onTap: () async {
                                  final approved = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RejectApprovePage(request: request),
                                    ),
                                  );
                                  if (approved == true) {
                                    await _loadRequests();
                                  }
                                },
                                child: _ApprovalRequestedCard(
                                  reqNo: request.cRequestNo,
                                  dateTime: request.cRequestDateTime ?? "",
                                  requestedBy: request.cRequestedBy,
                                  name: request.cAccountName,
                                  category: request.cCategoryName,
                                  section: request.cSectionName,
                                  amount: _formatAmount(request.nPayableAmount),
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

class _ApprovalRequestedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ApprovalRequestedSearchBar({
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

class _ApprovalRequestedCard extends StatelessWidget {
  final String reqNo;
  final String dateTime;
  final String requestedBy;
  final String name;
  final String category;
  final String section;
  final String amount;

  const _ApprovalRequestedCard({
    required this.reqNo,
    required this.dateTime,
    required this.requestedBy,
    required this.name,
    required this.category,
    required this.section,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
