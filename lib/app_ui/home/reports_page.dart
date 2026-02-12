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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BedtimeGradientAppBar(onProjectTap: _openProjectSelectionSheet),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
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
            ),
            SizedBox(height: 10),
            _ReportCard(
              iconPath: "assets/icons/voucher_report.png",
              title: "Voucher Report",
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

  const _ReportCard({
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
