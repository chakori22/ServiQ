import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/bloc/dashboard_bloc.dart';
import 'package:local_markerplace/dashboard/presentation/explore.dart';
import 'package:local_markerplace/dashboard/presentation/home.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardBloc(dashboardRepository: const DashboardRepository()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _selectedIndex = 0;

  // Add more pages here later — just extend this list + the nav items below
  final List<Widget> _pages = [const HomePage(), const ExplorePage()];

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
