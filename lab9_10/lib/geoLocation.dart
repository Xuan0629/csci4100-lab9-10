import 'package:latlong2/latlong.dart';


class GeoLocation {
  String name;
  String address;
  LatLng latlng;

  GeoLocation({required this.name, required this.address, required this.latlng});
}
