import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profiles_screen.dart';

class FarmerLayout extends StatefulWidget {
  static const routeName = '/farmer-layout';

  const FarmerLayout({Key? key}) : super(key: key);

  @override
  State<FarmerLayout> createState() => _FarmerLayoutState();
}

class _FarmerLayoutState extends State<FarmerLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF2E603A),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFFE8F5E9),
            elevation: 20,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color(0xFF2E603A).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.dashboard),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? const Color(0xFF2E603A).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.inventory),
                ),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? const Color(0xFF2E603A).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.shopping_bag),
                ),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3
                        ? const Color(0xFF2E603A).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.person),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
