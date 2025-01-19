import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCard extends StatefulWidget {
  const MapCard({Key? key}) : super(key: key);

  @override
  _MapCardState createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(-6.2088, 106.8456); // Jakarta coordinates

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('jakarta'),
                  position: _center,
                  infoWindow: const InfoWindow(
                    title: 'Jakarta',
                    snippet: 'Capital of Indonesia',
                  ),
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}