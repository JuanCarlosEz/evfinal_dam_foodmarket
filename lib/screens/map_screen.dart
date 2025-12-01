import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng selected = const LatLng(-12.0464, -77.0428); // Lima por defecto
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 🔥 detecta ubicación al iniciar
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el GPS está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Obtiene ubicación actual
    Position position = await Geolocator.getCurrentPosition();

    LatLng current = LatLng(position.latitude, position.longitude);

    setState(() {
      selected = current;
    });

    // Mueve la cámara si el mapa ya está listo
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(current, 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar dirección")),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: false, // lo reemplazamos con uno personalizado

        onMapCreated: (controller) {
          mapController = controller;
        },

        initialCameraPosition: CameraPosition(
          target: selected,
          zoom: 15,
        ),

        onTap: (pos) {
          setState(() {
            selected = pos;
          });
        },

        markers: {
          Marker(
            markerId: const MarkerId("selected"),
            position: selected,
          )
        },
      ),

      // 🔥 Botón para guardar ubicación
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 🔵 Botón para ir a mi ubicación
          FloatingActionButton(
            heroTag: "location_btn",
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 15),

          // ✔ Botón para guardar
          FloatingActionButton.extended(
            heroTag: "save_btn",
            onPressed: () {
              Navigator.pop(context, selected);
            },
            label: const Text("Guardar ubicación"),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
