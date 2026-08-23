import 'package:flutter/material.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/dashboard/presentation/explore.dart';
import 'package:local_markerplace/dashboard/presentation/feed.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Add more pages here later — just extend this list + the nav items below
  final List<Widget> _pages = [const FeedPage(), const ExplorePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.indicativeBlueColor500,
        unselectedItemColor: AppColor.neutralGreyColor500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
        ],
      ),
    );
  }
}
