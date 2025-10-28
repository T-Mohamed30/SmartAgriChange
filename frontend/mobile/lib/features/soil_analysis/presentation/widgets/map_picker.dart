import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';

class MapPicker extends StatefulWidget {
  final Function(double latitude, double longitude) onLocationSelected;
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  latlong.LatLng? _selectedLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLatitude != null && widget.initialLongitude != null
        ? latlong.LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : null;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle denied permission
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle permanently denied permission
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_selectedLocation == null) {
        setState(() {
          _selectedLocation = latlong.LatLng(
            position.latitude,
            position.longitude,
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Default to a fallback location if GPS fails
      if (_selectedLocation == null) {
        setState(() {
          _selectedLocation = const latlong.LatLng(0, 0); // Default location
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTap(latlong.LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    widget.onLocationSelected(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Sélectionnez un emplacement sur la carte',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _selectedLocation ?? const latlong.LatLng(0, 0),
              initialZoom: 15.0,
              onTap: (tapPosition, point) => _onTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smartagrichange_mobile',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (_selectedLocation != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(
              'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}\n'
              'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }
}
