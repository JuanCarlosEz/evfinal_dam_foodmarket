import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ───────────────────────────────────────────────
  // REGISTRO DE USUARIO
  // ───────────────────────────────────────────────
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,       // cliente | owner
    String? address,            // solo owner
    double? lat,                // solo owner
    double? lng,                // solo owner
  }) async {
    try {
      // Validar si el email ya existe
      final userQuery = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return "El correo ya está registrado";
      }

      // Armar datos base
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'createdAt': DateTime.now(),
      };

      // Si el rol es OWNER, guardar ubicación y dirección
      if (role == "owner") {
        data['address'] = address ?? "";
        data['lat'] = lat;
        data['lng'] = lng;
      }

      // Guardar datos
      await _db.collection('users').add(data);

      return null; // Éxito
    } catch (e) {
      return e.toString();
    }
  }

  // ───────────────────────────────────────────────
  // LOGIN SIN AUTH (FIRESTORE)
  // ───────────────────────────────────────────────
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (result.docs.isEmpty) return null;

      final data = result.docs.first.data();
      final id = result.docs.first.id;

      // Devolver en el formato que tu login_screen espera:
      return {
        "data": data, // datos del usuario
        "id": id,     // ID del documento
      };

    } catch (e) {
      return null;
    }
  }
}
