import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerOrdersScreen extends StatelessWidget {
  final String ownerId;

  const OwnerOrdersScreen({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos Recibidos")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(ownerId)
            .collection("pedidos")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay pedidos aún."));
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (_, i) {
              final p = pedidos[i].data() as Map<String, dynamic>;
              final id = pedidos[i].id;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Pedido ID: $id"),

                  subtitle: Text(
                    "Plato: ${p["plato"]}\n"
                    "Cantidad: ${p["cantidad"]}\n"
                    "Precio unitario: S/. ${p["precioUnitario"]}\n"
                    "Total: S/. ${p["total"]}\n"
                    "Hora de recojo: ${p["horaRecojo"]}\n"
                    "Descripción: ${p["descripcion"]}",
                  ),

                  // 🔥 BOTÓN PARA CONFIRMAR PEDIDO
                  trailing: ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(ownerId)
                          .collection("pedidos")
                          .doc(id)
                          .update({
                        "estado": "confirmado",
                      });
                    },
                    child: const Text("Confirmar"),
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
