import 'package:flutter/material.dart';
import 'manageBarbers.dart';
import 'manageBookings.dart';
import 'manageService.dart'; // Tambahkan jika ingin mengatur layanan

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  // Daftar halaman
  static const List<Widget> _widgetOptions = <Widget>[
    ManageBarbersPage(),
    ManageBookingsPage(),
    ManageServicesPage(),
  ];

  // Mengubah halaman saat item BottomNavigationBar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Admin Dashboard')),
        automaticallyImplyLeading: false,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Manage Barbers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Manage Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Manage Services',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}