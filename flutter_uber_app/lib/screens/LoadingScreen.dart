import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_uber_app/utils/Colors.dart';
import 'package:uuid/uuid.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  GoogleMapController mapController;
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  LatLng _initialPosition;
  LatLng _lastPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _lastPosition = _initialPosition;
      locationController.text = placemark[0].name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialPosition == null
          ? Container(
              alignment: Alignment.center,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Stack(
              children: [
                _getMapView(),
                Positioned(
                  top: 50.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      cursorColor: black,
                      controller: locationController,
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, bottom: 10),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.location_on,
                            color: black,
                          ),
                        ),
                        hintText: "Pick up",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 105.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      cursorColor: black,
                      controller: destinationController,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) {
                        // appState.sendRequest(value);
                      },
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(
                            left: 20,
                            bottom: 10,
                          ),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.local_taxi,
                            color: black,
                          ),
                        ),
                        hintText: "Destination",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  _onAddMarkerPressed() {
    var uuid = Uuid();
    _markers.add(
      Marker(
          markerId: MarkerId(uuid.v4()),
          position: _lastPosition,
          infoWindow: InfoWindow(
            title: "Save location",
            snippet: "Good Place",
          ),
          icon: BitmapDescriptor.defaultMarker),
    );
  }

  _getMapView() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 5,
      ),
      onMapCreated: onCreated,
      myLocationEnabled: true,
      mapType: MapType.normal,
      compassEnabled: true,
      markers: _markers,
      onCameraMove: _OnCameraMove,
    );
  }

  void _OnCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
