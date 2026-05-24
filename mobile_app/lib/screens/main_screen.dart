import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_view.dart';
import 'students_view.dart';
import 'projects_view.dart';
import 'assignments_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      DashboardView(onNavigate: _onTabTapped),
      const StudentsView(),
      const ProjectsView(),
      const AssignmentsView(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.tertiaryContainer,
              child: Icon(Icons.person, color: AppTheme.tertiary),
            ),
            const SizedBox(width: 12),
            const Text(
              'Student Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.tertiary),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.outlineVariant, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.surfaceContainerHigh,
          elevation: 0,
          selectedItemColor: AppTheme.tertiary,
          unselectedItemColor: AppTheme.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_tree_outlined),
              activeIcon: Icon(Icons.account_tree),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_outlined),
              activeIcon: Icon(Icons.assignment_turned_in),
              label: 'Assignments',
            ),
          ],
        ),
      ),
    );
  }
}
