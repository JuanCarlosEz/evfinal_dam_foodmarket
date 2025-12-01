import 'package:flutter/material.dart';
import 'foodtruck_screen.dart';
import 'eventos_cliente_screen.dart';

class ClientNavbar extends StatefulWidget {
  final String clienteId;

  const ClientNavbar({super.key, required this.clienteId});

  @override
  State<ClientNavbar> createState() => _ClientNavbarState();
}

class _ClientNavbarState extends State<ClientNavbar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FoodTruckScreen(),
      EventosClienteScreen(clienteId: widget.clienteId),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Foodtrucks",
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
