import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // ★ Import necesario para LatLng

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final userService = UserService();

  String? role;
  double? lat;
  double? lng;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    nameCtrl.clear();
    emailCtrl.clear();
    passCtrl.clear();
    addressCtrl.clear();
    role = null;
    lat = null;
    lng = null;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(20),

        // ───────────── SELECCIÓN DE ROL ─────────────
        child: role == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "¿Cómo deseas registrarte?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () => setState(() => role = "cliente"),
                    child: const Text("Registrarme como Cliente"),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => setState(() => role = "owner"),
                    child: const Text("Registrarme como Owner"),
                  ),
                ],
              )

            // ───────────── FORMULARIO ─────────────
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Nombre
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: role == "owner"
                            ? "Nombre del Foodtruck"
                            : "Nombre",
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Completa este campo" : null,
                    ),

                    const SizedBox(height: 15),

                    // Email
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Ingresa un email";
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return "Email inválido";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // Contraseña
                    TextFormField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Contraseña"),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Ingresa una contraseña";
                        if (v.length < 6) return "Mínimo 6 caracteres";
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ╔═══════════════════════════════════════╗
                    // ║       DIRECCIÓN SOLO PARA OWNER       ║
                    // ╚═══════════════════════════════════════╝
                    if (role == "owner") ...[
                      TextFormField(
                        controller: addressCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Dirección (seleccionar en mapa)",
                        ),
                        validator: (v) {
                          if (role == "owner" &&
                              (v == null || v.trim().isEmpty)) {
                            return "Selecciona una dirección";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.map),
                        label: const Text("Seleccionar en mapa"),
                        onPressed: () async {
                          final pos = await Navigator.pushNamed(context, "/map");

                          if (pos is! LatLng) return;

                          setState(() {
                            lat = pos.latitude;
                            lng = pos.longitude;
                            addressCtrl.text =
                                "Lat: ${pos.latitude}, Lng: ${pos.longitude}";
                          });
                        },
                      ),

                      const SizedBox(height: 25),
                    ],

                    // Botón registrar
                    ElevatedButton(
                      child: const Text("Registrarme"),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final error = await userService.registerUser(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                          role: role!,
                          address: role == "owner" ? addressCtrl.text.trim() : "",
                          lat: lat,
                          lng: lng,
                        );

                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registro exitoso")),
                        );

                        Navigator.pop(context);
                      },
                    ),

                    TextButton(
                      onPressed: () => setState(() => role = null),
                      child: const Text("Cambiar tipo de registro"),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
