import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class CustomGoogleMap extends StatefulWidget {
  final Function(String locationName, double latitude, double longitude) onLocationPicked;

  CustomGoogleMap({Key? key, required this.onLocationPicked}) : super(key: key);

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late GoogleMapController mapController;
  CameraPosition _initialLocation = const CameraPosition(target: LatLng(9.9252, 78.1198), zoom: 0);
  loc.Location location = loc.Location();
  LatLng? selectedPosition;
  var selectedLocation;
  double _currentZoom = 12.0;
  double _minZoom = 4.0;
  double _maxZoom = 20.0;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (selectedPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('selected_marker'),
          position: selectedPosition!,
          infoWindow: InfoWindow(title: selectedLocation),
        ),
      );
    }
    return markers;
  }

  //To get the selected location name
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks.first;
      String locationName = '${place.street}, ${place.locality}, ${place.country}';
      return locationName;
    } catch (e) {
      print('Error: $e');
      return 'Unknown location';
    }
  }

  //To get current location
  void _initLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
  }

  _showAlertBox(locationName,latitude,longitude){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm this location?'),
          content: Text('Are you sure you want to confirm this location \n$locationName'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                widget.onLocationPicked(locationName,latitude,longitude);
                Navigator.of(context).pop();
                // Navigator.pop(context, {'locationName': locationName, 'lat': latitude,'lan':longitude});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height-100;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Select location'),
      // ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: h,
                width: w,
                child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  initialCameraPosition: _initialLocation,
                  onMapCreated: (GoogleMapController controller) async {
                    mapController = controller;
                    // location.onLocationChanged.listen((loc.LocationData currentLocation) async {
                    //   mapController.animateCamera(
                    //     CameraUpdate.newLatLng(LatLng(
                    //       currentLocation.latitude!,
                    //       currentLocation.longitude!,
                    //     )),
                    //   );
                    // });
                  },
                  onTap: (LatLng position) async {
                    String locationName = await getLocationName(position.latitude, position.longitude);
                    setState(() {
                      selectedPosition = position;
                      selectedLocation = locationName;
                    });
                    _showAlertBox(locationName,position.latitude,position.longitude);
                  },
                  markers: _buildMarkers(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
