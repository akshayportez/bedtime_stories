part of 'package:bedtime_stories/utils/lib_files.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: BedtimeGradientAppBar(
        onProjectTap: () {
          Navigator.pushNamed(context, "/projectSelection");
        },
      ),
      body: Padding(
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
                  child: _RequestSearchBar(controller: searchController),
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
                  child: Center(
                    child: Image.asset(
                      "assets/icons/filter.png",
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// Request Cards List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: const [
                  _RequestCard(
                    reqNo: "SOD458",
                    dateTime: "Mar 10 , 2025  12 : 20 am",
                    name: "Mammootty",
                    category: "Actor",
                    section: "Travel",
                    amount: "4500.00",
                    status: "Requested",
                    statusColor: Color(0xFFF6B504),
                  ),
                  _RequestCard(
                    reqNo: "SOD457",
                    dateTime: "Mar 10 , 2025  12 : 20 am",
                    name: "Mohanlal",
                    category: "Actor",
                    section: "Travel",
                    amount: "5785.00",
                    status: "Approved",
                    statusColor: Color(0xFF0792CE),
                  ),
                  _RequestCard(
                    reqNo: "SOD456",
                    dateTime: "Mar 10 , 2025  12 : 20 am",
                    name: "Mohanlal",
                    category: "Actor",
                    section: "Food",
                    amount: "258.00",
                    status: "Paid",
                    statusColor: Color(0xFF07CE07),
                  ),
                  _RequestCard(
                    reqNo: "SOD455",
                    dateTime: "Mar 10 , 2025  12 : 20 am",
                    name: "Mohanlal",
                    category: "Actor",
                    section: "Food",
                    amount: "987.00",
                    status: "Rejected",
                    statusColor: Color(0xFFFB5F38),
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

class _RequestSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _RequestSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: "Search",
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF5F5F5F),
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF5F5F5F),
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

                /// Amount Text
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
