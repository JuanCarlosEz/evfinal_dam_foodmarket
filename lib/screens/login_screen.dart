import 'package:flutter/material.dart';
import '../services/user_service.dart';

// PANTALLAS QUE USAMOS SEGÚN EL ROL
import 'owner_home_screen.dart';
import 'client_navbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailCtrl.clear();
      passCtrl.clear();
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  bool validarCampos() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || !email.contains("@") || !email.contains(".")) {
      mostrarMensaje("Ingresa un correo válido");
      return false;
    }

    if (pass.isEmpty) {
      mostrarMensaje("La contraseña no puede estar vacía");
      return false;
    }

    if (pass.length < 4) {
      mostrarMensaje("La contraseña debe tener mínimo 4 caracteres");
      return false;
    }

    return true;
  }

  void mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// EMAIL
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 15),

            /// PASSWORD
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 25),

            /// BOTÓN LOGIN
            ElevatedButton(
              child: const Text("Ingresar"),
              onPressed: () async {
                if (!validarCampos()) return;

                final userData = await userService.loginUser(
                  email: emailCtrl.text.trim(),
                  password: passCtrl.text.trim(),
                );

                if (userData == null) {
                  mostrarMensaje("Credenciales incorrectas");
                  return;
                }

                final user = userData["data"];
                final userId = userData["id"];

                // ==========================
                //       MANEJO DE ROLES
                // ==========================

                switch (user["role"]) {

                  case "owner":
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OwnerHomeScreen(ownerId: userId),
                      ),
                    );
                    break;

                  case "admin":
                    Navigator.pushReplacementNamed(context, "/admin");
                    break;

                  default: // CLIENTE
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientNavbar(clienteId: userId),
                      ),
                    );
                }
              },
            ),

            const SizedBox(height: 10),

            TextButton(
              child: const Text("Crear cuenta"),
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
            ),
          ],
        ),
      ),
    );
  }
}
