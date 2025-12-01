import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'foodtruck_menu_screen.dart';

class FoodTruckScreen extends StatefulWidget {
  const FoodTruckScreen({super.key});

  @override
  State<FoodTruckScreen> createState() => _FoodTruckScreenState();
}

class _FoodTruckScreenState extends State<FoodTruckScreen> {
  GoogleMapController? mapController;
  Position? userPosition;

  // Lista de owners ordenados por distancia
  List<Map<String, dynamic>> ownersOrdenados = [];

  // ─────────────────────────────────────────────
  // Solicitar permisos + obtener ubicación
  // ─────────────────────────────────────────────
  Future<void> obtenerUbicacion() async {
    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.deniedForever ||
        permiso == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Necesitas permitir el acceso a ubicación."),
        ),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() => userPosition = pos);
  }

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

  // ─────────────────────────────────────────────
  // Calcular distancia entre user y owner
  // ─────────────────────────────────────────────
  double distancia(double lat, double lng) {
    if (userPosition == null) return 999999999;

    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      lat,
      lng,
    );
  }

  // ─────────────────────────────────────────────
  // Mostrar MAPA + LISTA ordenada por distancia
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FoodTrucks Cercanos"),
        centerTitle: true,
      ),

      body: userPosition == null
          ? const Center(child: CircularProgressIndicator())

          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("role", isEqualTo: "owner")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final owners = snapshot.data!.docs;

                // Convertir a lista y agregar distancia
                ownersOrdenados = owners.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;

                  // 🔥 CORRECCIÓN AQUÍ
                  final double lat = double.tryParse(d["lat"].toString()) ?? 0;
                  final double lng = double.tryParse(d["lng"].toString()) ?? 0;

                  final dist = distancia(lat, lng);

                  return {
                    "id": doc.id,
                    "name": d["name"],
                    "email": d["email"],
                    "lat": lat,
                    "lng": lng,
                    "distancia": dist,
                  };
                }).toList();

                // Ordenar por distancia (más cerca primero)
                ownersOrdenados.sort((a, b) =>
                    a["distancia"].compareTo(b["distancia"]));

                // Crear marcadores del mapa
                final markers = ownersOrdenados.map((owner) {
                  return Marker(
                    markerId: MarkerId(owner["id"]),
                    position: LatLng(owner["lat"], owner["lng"]),
                    infoWindow: InfoWindow(
                      title: owner["name"],
                      snippet:
                          "${(owner["distancia"] / 1000).toStringAsFixed(2)} km",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FoodTruckMenuScreen(ownerId: owner["id"]),
                          ),
                        );
                      },
                    ),
                    onTap: () => mostrarFicha(owner),
                  );
                }).toSet();

                return Column(
                  children: [
                    // MAPA
                    SizedBox(
                      height: 350,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(userPosition!.latitude,
                              userPosition!.longitude),
                          zoom: 14,
                        ),
                        myLocationEnabled: true,
                        markers: markers,
                        onMapCreated: (c) => mapController = c,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // LISTA ORDENADA (cercanos primero)
                    Expanded(
                      child: ListView.builder(
                        itemCount: ownersOrdenados.length,
                        itemBuilder: (_, i) {
                          final o = ownersOrdenados[i];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.store, size: 35),
                              title: Text(o["name"]),
                              subtitle: Text(
                                "Distancia: ${(o["distancia"] / 1000).toStringAsFixed(2)} km",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FoodTruckMenuScreen(
                                        ownerId: o["id"]),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // ─────────────────────────────────────────────
  // FICHA INFERIOR DEL FOODTRUCK (BottomSheet)
  // ─────────────────────────────────────────────
  void mostrarFicha(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["name"],
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(data["email"]),
              const SizedBox(height: 10),
              Text(
                "Distancia: ${(data["distancia"] / 1000).toStringAsFixed(2)} km",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                icon: const Icon(Icons.restaurant_menu),
                label: const Text("Ver Menú"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodTruckMenuScreen(ownerId: data["id"]),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
