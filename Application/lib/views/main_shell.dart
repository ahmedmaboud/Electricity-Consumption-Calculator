import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/analytics_page_controller.dart';
import 'package:graduation_project_depi/views/analytics_page.dart';

// Pages
import 'package:graduation_project_depi/views/calculator_page.dart';
import 'package:graduation_project_depi/views/history_page.dart';
import 'package:graduation_project_depi/views/profile_screen.dart';


// Controllers
import 'package:graduation_project_depi/controllers/profile_controller.dart';
import 'package:graduation_project_depi/controllers/calculator_page_controller.dart';


class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;
  late final List<Widget> _pages; // initialized in initState

  @override
  void initState() {
    super.initState();

    // Set initial index
    _selectedIndex = widget.initialIndex;

    // Register controllers in the correct order:
    // 1) Calculator first (producer of readings)
    if (!Get.isRegistered<CalculatorPageController>()) {
      Get.put(CalculatorPageController());
    }

    // 2) Analytics second (consumes calculator data)
    if (!Get.isRegistered<AnalyticsController>()) {
      Get.put(AnalyticsController());
    }

    // 3) Profile (or others)
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    // Now it's safe to create pages that may call Get.find in their field initializers.
    _pages = <Widget>[
      const CalculatorPage(),               // index 0
      HistoryPage(),    // index 1
      AnalyticsView(),       // index 2  <-- added Analytics page here
      const ProfileScreen(),                // index 3
    ];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

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
