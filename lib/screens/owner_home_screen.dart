import 'package:flutter/material.dart';
import 'platosfoodtruck_screen.dart';
import 'eventos_owner_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  final String ownerId;

  const OwnerHomeScreen({super.key, required this.ownerId});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PlatosFoodtruckScreen(ownerId: widget.ownerId),
      EventosOwnerScreen(ownerId: widget.ownerId),
    ];

    return Scaffold(
      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Platos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Eventos",
          ),
        ],
      ),
    );
  }
}
