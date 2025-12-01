import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodTruckMenuScreen extends StatelessWidget {
  final String ownerId;

  const FoodTruckMenuScreen({super.key, required this.ownerId});

  // ───────────────────────────────────────────────
  // GUARDAR VALORACIÓN DEL FOODTRUCK
  // ───────────────────────────────────────────────
  void abrirDialogoValoracion(BuildContext context) {
    double rating = 3;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Valorar FoodTruck"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Selecciona una puntuación"),
                const SizedBox(height: 10),

                // ⭐⭐⭐⭐⭐
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() => rating = i + 1);
                      },
                    );
                  }),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),

          ElevatedButton(
            onPressed: () async {
              // Guarda la valoración
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(ownerId)
                  .collection("valoraciones")
                  .add({
                "rating": rating,
                "fecha": DateTime.now(),
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("¡Gracias por tu valoración!")),
              );
            },
            child: const Text("Enviar"),
          )
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // FORMULARIO DE PRE‑ORDEN
  // ───────────────────────────────────────────────
  void abrirPreOrdenForm(
    BuildContext context,
    Map<String, dynamic> plato,
  ) {
    final cantidadCtrl = TextEditingController(text: "1");
    TimeOfDay? horaRecojo;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pre‑ordenar: ${plato["nombre"]}"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Precio: S/. ${plato["precio"]}",
                      style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 10),

                  // Cantidad
                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Cantidad",
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Seleccionar hora
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 10),
                      Text(
                        horaRecojo == null
                            ? "Seleccione hora de recojo"
                            : "Hora: ${horaRecojo!.format(context)}",
                      ),
                      TextButton(
                        child: const Text("Elegir"),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => horaRecojo = picked);
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Confirmar pedido"),
            onPressed: () async {
              final cantidad = int.tryParse(cantidadCtrl.text.trim());

              if (cantidad == null || cantidad <= 0) return;
              if (horaRecojo == null) return;

              final pedido = {
                "plato": plato["nombre"],
                "precioUnitario": plato["precio"],
                "cantidad": cantidad,
                "total": plato["precio"] * cantidad,
                "descripcion": plato["descripcion"],
                "horaRecojo": "${horaRecojo!.hour}:${horaRecojo!.minute}",
                "createdAt": DateTime.now(),
              };

              // Guardar en Firestore → pedidos del dueño
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(ownerId)
                  .collection("pedidos")
                  .add(pedido);

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // BUILD PRINCIPAL
  // ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú del FoodTruck"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () => abrirDialogoValoracion(context),
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(ownerId)
            .collection("platos")
            .orderBy("nombre")
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Este FoodTruck aún no ha registrado platos",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final platos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: platos.length,
            itemBuilder: (context, index) {
              final plato = platos[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.fastfood,
                      size: 35, color: Colors.red),
                  title: Text(
                    plato["nombre"] ?? "Sin nombre",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "S/ ${plato["precio"]?.toStringAsFixed(2) ?? "--"}\n${plato["descripcion"] ?? ""}",
                  ),

                  // AL TOCAR → PRE‑ORDENAR
                  onTap: () => abrirPreOrdenForm(context, plato),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
