import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/foodtruck_screen.dart';
import 'screens/map_screen.dart';
import 'screens/platosfoodtruck_screen.dart';
import 'screens/eventos_owner_screen.dart';
import 'screens/client_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),

        '/register': (_) => const RegisterScreen(),

        '/foodtruck': (_) => const FoodTruckScreen(),

        '/map': (_) => const MapScreen(),

        // --- RUTA DEL OWNER PARA GESTIONAR PLATOS ---
         // --- OWNER: GESTIÓN DE PLATOS ---
        '/platosfoodtruck': (context) {
          final ownerId =
              ModalRoute.of(context)!.settings.arguments as String;

          return PlatosFoodtruckScreen(ownerId: ownerId);
        },

        // --- OWNER: EVENTOS (cuando lo agreguemos) ---
        '/eventos_owner': (context) {
          final ownerId =
              ModalRoute.of(context)!.settings.arguments as String;

          return EventosOwnerScreen(ownerId: ownerId);
        },
        '/client': (context) {
  final clienteId = ModalRoute.of(context)!.settings.arguments as String;
  return ClientNavbar(clienteId: clienteId);
},

        // rutas temporales
        '/owner': (_) => const Scaffold(
              body: Center(child: Text("OWNER")),
            ),
        '/admin': (_) => const Scaffold(
              body: Center(child: Text("ADMIN")),
            ),
      },
    );
  }
}
