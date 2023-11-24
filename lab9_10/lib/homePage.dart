import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;

import 'geolocation.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // List<GeoLocation> sampleLocations = [
  //   GeoLocation(
  //     name: 'Central Park',
  //     address: '5 Av to Central Park W, 59 St to 110 St',
  //     latlng: LatLng(40.785091, -73.968285),
  //   ),
  //   GeoLocation(
  //     name: 'Statue of Liberty',
  //     address: 'New York, NY 10004',
  //     latlng: LatLng(40.689247, -74.044502),
  //   ),
  //   // Add more sample locations as needed
  // ];
  List<GeoLocation> locations = [];
  final MapController mapController = MapController();
  List<Marker> markers = [];
  Polyline polyline = Polyline(points: [], strokeWidth: 4.0, color: Colors.blue);

  @override
  void initState() {
    super.initState();
    loadGpxData();
  }

  void zoomIn() {
    double currentZoom = mapController.zoom;
    mapController.move(mapController.center, currentZoom + 1);
  }

  void zoomOut() {
    double currentZoom = mapController.zoom;
    mapController.move(mapController.center, currentZoom - 1);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable it.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _addCurrentLocation() async {
    try {
      Position position = await _determinePosition();

      // Use geocoding to get the place name and address
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );
      Placemark place = placemarks[0];

      // Create a new GeoLocation object
      GeoLocation newLocation = GeoLocation(
        name: place.name ?? 'Unknown', // Fallback to 'Unknown' if name is null
        address: '${place.street}, ${place.locality}',
        latlng: LatLng(position.latitude, position.longitude),
      );

      // Add the new location to your list of locations and update the state
      setState(() {
        locations.add(newLocation);
        // Update markers and polyline
        _updateMapMarkersAndPolyline();
      });

      // Update the map view
      mapController.move(newLocation.latlng, mapController.zoom);

    } catch (e) {
      // Handle exceptions (e.g., user denied permission)
      print(e);
    }
  }

  void _updateMapMarkersAndPolyline() {
    markers = locations.map((location) => Marker(
      width: 80.0,
      height: 80.0,
      point: location.latlng,
      builder: (ctx) => Icon(Icons.location_on, color: Colors.red,),
    )).toList();

    polyline = Polyline(
      points: locations.map((location) => location.latlng).toList(),
      strokeWidth: 4.0,
      color: Colors.blue,
    );
  }

  Future<List<GeoLocation>> parseGpxFile(String filePath) async {
    final String fileContent = await rootBundle.loadString(filePath);
    final xmlDocument = xml.XmlDocument.parse(fileContent);
    List<GeoLocation> locations = [];

    // Find all trackpoint elements
    var trkpts = xmlDocument.findAllElements('trkpt');
    for (var trkpt in trkpts) {
      var lat = double.tryParse(trkpt.getAttribute('lat') ?? '');
      var lon = double.tryParse(trkpt.getAttribute('lon') ?? '');

      if (lat != null && lon != null) {
        locations.add(GeoLocation(
          name: 'Name not available',
          address: 'Address not available',
          latlng: LatLng(lat, lon),
        ));
      }
    }

    return locations;
  }

  void loadGpxData() async {
    List<GeoLocation> gpxLocations = await parseGpxFile('lib/cedar_valley.gpx');
    setState(() {
      locations.addAll(gpxLocations);
      // Update markers and polyline
      _updateMapMarkersAndPolyline();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the initial center
    LatLng initialCenter = locations.isNotEmpty
        ? locations.last.latlng
        : LatLng(43.94408,-78.89684); // Default center
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              zoomIn();
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              zoomOut();
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: initialCenter,
          zoom: 13.0,
          minZoom: 5.0,
          maxZoom: 20.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: locations.map((location) => Marker(
              width: 80.0,
              height: 80.0,
              point: location.latlng,
              builder: (ctx) => Icon(Icons.location_on, color: Colors.red,),
            )).toList(),
          ),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: locations.map((location) => location.latlng).toList(),
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _addCurrentLocation();
        },
        child: const Icon(Icons.add_location),
        tooltip: 'Add Location',
      ),
    );
  }
}