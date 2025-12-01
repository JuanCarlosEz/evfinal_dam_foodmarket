import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'owner_orders_screen.dart'; // 🔥 AGREGA ESTA IMPORTACIÓN

class PlatosFoodtruckScreen extends StatefulWidget {
  final String ownerId; // se recibe desde login
  const PlatosFoodtruckScreen({super.key, required this.ownerId});

  @override
  State<PlatosFoodtruckScreen> createState() => _PlatosFoodtruckScreenState();
}

class _PlatosFoodtruckScreenState extends State<PlatosFoodtruckScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────────────────────────────
  // Crear / Editar Plato
  // ────────────────────────────────
  void abrirFormulario({String? platoId, Map<String, dynamic>? data}) {
    final nameCtrl = TextEditingController(text: data?["nombre"] ?? "");
    final priceCtrl =
        TextEditingController(text: data?["precio"]?.toString() ?? "");
    final descCtrl = TextEditingController(text: data?["descripcion"] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(platoId == null ? "Agregar Plato" : "Editar Plato"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: "Nombre del plato"),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Precio"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nameCtrl.text.trim();
              final precio = double.tryParse(priceCtrl.text.trim());
              final descripcion = descCtrl.text.trim();

              if (nombre.isEmpty || precio == null) return;

              final data = {
                "nombre": nombre,
                "precio": precio,
                "descripcion": descripcion,
                "updatedAt": DateTime.now(),
              };

              final ref = _db
                  .collection("users")
                  .doc(widget.ownerId)
                  .collection("platos");

              if (platoId == null) {
                await ref.add(data); // agregar
              } else {
                await ref.doc(platoId).update(data); // editar
              }

              Navigator.pop(context);
            },
            child: Text(platoId == null ? "Guardar" : "Actualizar"),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────
  // Eliminar Plato
  // ────────────────────────────────
  void eliminarPlato(String platoId) {
    _db
        .collection("users")
        .doc(widget.ownerId)
        .collection("platos")
        .doc(platoId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Platos"),

        // 🔥🔥🔥 BOTÓN PARA VER PEDIDOS 🔥🔥🔥
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: "Ver pedidos",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OwnerOrdersScreen(ownerId: widget.ownerId),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: _db
            .collection("users")
            .doc(widget.ownerId)
            .collection("platos")
            .orderBy("nombre")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No tienes platos aún. Agrega uno!"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final plato = docs[i].data();
              final id = docs[i].id;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(plato["nombre"]),
                  subtitle: Text(
                    "S/. ${plato["precio"].toStringAsFixed(2)}\n${plato["descripcion"]}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            abrirFormulario(platoId: id, data: plato),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => eliminarPlato(id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
