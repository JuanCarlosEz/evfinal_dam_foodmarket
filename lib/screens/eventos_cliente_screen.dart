import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventosClienteScreen extends StatelessWidget {
  final String clienteId;

  const EventosClienteScreen({
    super.key,
    required this.clienteId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eventos disponibles")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup("eventos")
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final eventos = snap.data!.docs;

          if (eventos.isEmpty) {
            return const Center(child: Text("No hay eventos disponibles"));
          }

          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (_, i) {
              final e = eventos[i].data() as Map<String, dynamic>;
              final ownerId = eventos[i].reference.parent.parent!.id;
              final eventoId = eventos[i].id;

              return Card(
                child: ListTile(
                  title: Text(e["titulo"]),
                  subtitle: Text(
                    "${e["descripcion"]}\n"
                    "Lugar: ${e["lugar"]}\n"
                    "Cupos: ${e["cupoDisponible"]}/${e["cupoTotal"]}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final ref = FirebaseFirestore.instance
                          .collection("users")
                          .doc(ownerId)
                          .collection("eventos")
                          .doc(eventoId);

                      final doc = await ref.get();
                      final cupo = doc["cupoDisponible"];

                      if (cupo > 0) {
                        await ref.collection("inscritos").doc(clienteId).set({
                          "fechaRegistro": DateTime.now(),
                        });
                        await ref.update({"cupoDisponible": cupo - 1});
                      }
                    },
                    child: const Text("Unirme"),
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
