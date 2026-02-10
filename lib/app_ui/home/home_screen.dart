part of 'package:bedtime_stories/utils/lib_files.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> tabs = ["Request", "Approval", "Voucher", "Reports"];

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
          Center(child: Text("Approval Page")),
          Center(child: Text("Voucher Page")),
          Center(child: Text("Reports Page")),
        ],
      ),

      /// Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: appPrimaryColor,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),

      /// Bottom Navigation
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.transparent, //  No white strip
          child: _BottomNavBar(
            selectedIndex: selectedIndex,
            onChanged: (index) {
              setState(() => selectedIndex = index);
            },
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const _BottomNavBar({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      margin: const EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: 14, 
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), 
        border: Border.all(color: appPrimaryColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
            onTap: () => onChanged(1),
          ),
          _NavItem(
            assetIcon: "assets/icons/voucher_icon.png",
            text: "Voucher",
            isSelected: selectedIndex == 2,
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
  final VoidCallback onTap;

  const _NavItem({
    required this.assetIcon,
    required this.text,
    required this.isSelected,
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
                  colors: [
                    Color(0xFF04BBD0),
                    Color(0xFF79A2F4),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            ImageIcon(
              AssetImage(assetIcon),
              size: 22,
              color: isSelected ? Colors.white : appPrimaryColor,
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
