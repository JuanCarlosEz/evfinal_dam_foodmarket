import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutScreen extends StatefulWidget {
  final String foodtruckId;
  final List<Map<String, dynamic>> carrito;
  final String clienteId;

  const CheckoutScreen({
    super.key,
    required this.foodtruckId,
    required this.carrito,
    required this.clienteId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  TimeOfDay? horaRecogida;

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var item in widget.carrito) {
      total += item["precio"] * item["cantidad"];
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar Pedido")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Platos seleccionados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: widget.carrito.map((item) {
                  return ListTile(
                    title: Text(item["nombre"]),
                    subtitle: Text(
                        "S/. ${item["precio"]}  x ${item["cantidad"]}"),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),
            Text("Total: S/. $total",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final tiempo = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                setState(() => horaRecogida = tiempo);
              },
              child: Text(horaRecogida == null
                  ? "Seleccionar hora de recogida"
                  : "Hora: ${horaRecogida!.format(context)}"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: horaRecogida == null ? null : guardarPedido,
              child: const Text("Confirmar Pedido"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> guardarPedido() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.clienteId)
        .collection("orders")
        .add({
      "foodtruckId": widget.foodtruckId,
      "platos": widget.carrito,
      "total": widget.carrito.fold<double>(
  0,
  (prev, item) => prev + (item["precio"] as double) * (item["cantidad"] as int),
),

      "horaRecogida": "${horaRecogida!.hour}:${horaRecogida!.minute}",
      "estado": "pendiente",
      "creadoEn": DateTime.now(),
    });

    Navigator.pop(context);
  }
}
