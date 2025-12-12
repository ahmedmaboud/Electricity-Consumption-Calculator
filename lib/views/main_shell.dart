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
import 'package:graduation_project_depi/controllers/budget_controller.dart'; // Import BudgetController

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

    // --- REGISTER CONTROLLERS ---

    // 1. Budget 
    if (!Get.isRegistered<BudgetController>()) {
      Get.put(BudgetController());
    }

    // 2. Calculator 
    if (!Get.isRegistered<CalculatorPageController>()) {
      Get.put(CalculatorPageController());
    }

    // 3. Analytics 
    if (!Get.isRegistered<AnalyticsController>()) {
      Get.put(AnalyticsController());
    }

    // 4. Profile 
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    _pages = <Widget>[
      const CalculatorPage(), // index 0
      const HistoryPage(),    // index 1
      AnalyticsView(),        // index 2 
      const ProfileScreen(),  // index 3
    ];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black12,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: SafeArea(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).cardColor,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey,
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