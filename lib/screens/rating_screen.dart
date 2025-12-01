import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingScreen extends StatefulWidget {
  final String ownerId;
  final String clienteId;

  const RatingScreen({
    super.key,
    required this.ownerId,
    required this.clienteId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double rating = 0;
  final comentarioCtrl = TextEditingController();

  bool yaValoro = false;
  double ratingAnterior = 0;
  String comentarioAnterior = "";

  @override
  void initState() {
    super.initState();
    verificarValoracion();
  }

  // ─────────────────────────────────────────────
  // VERIFICAR SI EL CLIENTE YA VALORÓ
  // ─────────────────────────────────────────────
  Future<void> verificarValoracion() async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.ownerId)
        .collection("valoraciones")
        .where("clienteId", isEqualTo: widget.clienteId);

    final snap = await ref.get();

    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      setState(() {
        yaValoro = true;
        ratingAnterior = data["rating"];
        comentarioAnterior = data["comentario"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Valorar FoodTruck")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: yaValoro
            ? _buildYaValoro()      // Mostrar mensaje si ya valoró
            : _buildFormulario(),  // Mostrar formulario si NO valoró
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FORMULARIO NORMAL (si NO valoró)
  // ─────────────────────────────────────────────
  Widget _buildFormulario() {
    return Column(
      children: [
        const Text("Puntúa este FoodTruck", style: TextStyle(fontSize: 18)),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(
                i < rating ? Icons.star : Icons.star_border,
                size: 32,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() => rating = i + 1.0);
              },
            );
          }),
        ),

        TextField(
          controller: comentarioCtrl,
          decoration: const InputDecoration(
            labelText: "Comentario (opcional)",
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: rating == 0 ? null : guardarValoracion,
          child: const Text("Enviar valoración"),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MENSAJE PARA EVITAR VALORAR DOS VECES
  // ─────────────────────────────────────────────
  Widget _buildYaValoro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 10),
        const Text(
          "Ya valoraste este FoodTruck",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Text("Tu puntuación:", style: TextStyle(fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return Icon(
              i < ratingAnterior ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 30,
            );
          }),
        ),

        const SizedBox(height: 10),
        Text(
          "Tu comentario:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          comentarioAnterior.isEmpty ? "Sin comentario" : comentarioAnterior,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Regresar"),
        )
      ],
    );
  }

  // ─────────────────────────────────────────────
  // GUARDAR VALORACIÓN
  // ─────────────────────────────────────────────
  Future<void> guardarValoracion() async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.ownerId)
        .collection("valoraciones");

    // Guardar una valoración
    await ref.add({
      "rating": rating,
      "comentario": comentarioCtrl.text.trim(),
      "clienteId": widget.clienteId,
      "fecha": DateTime.now(),
    });

    // Actualizar promedio
    await actualizarPromedio();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("¡Gracias por tu valoración!")),
    );
  }

  // ─────────────────────────────────────────────
  // ACTUALIZAR PROMEDIO
  // ─────────────────────────────────────────────
  Future<void> actualizarPromedio() async {
    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.ownerId)
        .collection("valoraciones")
        .get();

    double suma = 0;
    for (var d in snap.docs) {
      suma += d["rating"];
    }

    double promedio = suma / snap.docs.length;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.ownerId)
        .update({
      "ratingPromedio": promedio,
      "totalValoraciones": snap.docs.length,
    });
  }
}
