import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import your pages
import 'package:graduation_project_depi/calculator_page.dart';
import 'package:graduation_project_depi/profile_screen.dart';
import 'package:graduation_project_depi/views/analytics_page.dart' as analytics_placeholder;
import 'package:graduation_project_depi/views/history_page.dart' as history_placeholder;

// Import your controllers
import 'package:graduation_project_depi/controllers/profile_controller.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;

  // Register pages. Keep real widgets here.
  late final List<Widget> _pages = [
    const CalculatorPage(),
    history_placeholder.HistoryPage(),
    analytics_placeholder.AnalyticsPage(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Set initial index
    _selectedIndex = widget.initialIndex;

    // Register ProfileController
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack to preserve state of each tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black12, offset: Offset(0, -3))],
        ),
        child: SafeArea(
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF1976D2),
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
