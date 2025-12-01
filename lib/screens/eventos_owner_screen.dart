import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventosOwnerScreen extends StatefulWidget {
  final String ownerId;

  const EventosOwnerScreen({super.key, required this.ownerId});

  @override
  State<EventosOwnerScreen> createState() => _EventosOwnerScreenState();
}

class _EventosOwnerScreenState extends State<EventosOwnerScreen> {
  final tituloCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();
  final cupoCtrl = TextEditingController();

  DateTime? fechaEvento;

  Future<void> publicarEvento() async {
    if (tituloCtrl.text.isEmpty ||
        fechaEvento == null ||
        cupoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos obligatorios")),
      );
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.ownerId)
        .collection("eventos");

    await ref.add({
      "titulo": tituloCtrl.text.trim(),
      "descripcion": descCtrl.text.trim(),
      "lugar": lugarCtrl.text.trim(),
      "fecha": fechaEvento,
      "cupoTotal": int.parse(cupoCtrl.text.trim()),
      "cupoDisponible": int.parse(cupoCtrl.text.trim()),
      "ownerId": widget.ownerId,
      "creado": DateTime.now(),
    });

    // 👉 Limpia campos y refresca pantalla
    setState(() {
      tituloCtrl.clear();
      descCtrl.clear();
      lugarCtrl.clear();
      cupoCtrl.clear();
      fechaEvento = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento publicado correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Evento / Feria")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: tituloCtrl,
                    decoration:
                        const InputDecoration(labelText: "Título del evento"),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration:
                        const InputDecoration(labelText: "Descripción"),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: lugarCtrl,
                    decoration: const InputDecoration(labelText: "Lugar"),
                  ),
                  TextField(
                    controller: cupoCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Cupos disponibles"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(
                      fechaEvento == null
                          ? "Seleccionar fecha"
                          : "Fecha: ${fechaEvento!.day}/${fechaEvento!.month}/${fechaEvento!.year}",
                    ),
                    onPressed: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (fecha != null) {
                        setState(() => fechaEvento = fecha);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: publicarEvento,
                    child: const Text("Publicar Evento"),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Eventos Registrados",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // 📌 STREAMBUILDER PARA VER EVENTOS EN TIEMPO REAL
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.ownerId)
                    .collection("eventos")
                    .orderBy("fecha")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error al cargar eventos");
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final eventos = snapshot.data!.docs;

                  if (eventos.isEmpty) {
                    return const Text("Aún no has registrado eventos.");
                  }

                  return ListView.builder(
                    itemCount: eventos.length,
                    itemBuilder: (_, index) {
                      final data = eventos[index].data() as Map<String, dynamic>;

                      final fecha = (data["fecha"] as Timestamp).toDate();

                      return Card(
                        child: ListTile(
                          title: Text(data["titulo"]),
                          subtitle: Text(
                            "${data["lugar"]} • ${fecha.day}/${fecha.month}/${fecha.year}\nCupos: ${data["cupoDisponible"]}/${data["cupoTotal"]}",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
