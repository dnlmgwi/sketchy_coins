import 'package:geodesy/geodesy.dart';

class LocationService {
  late Geodesy geodesy;

  LocationService({required Geodesy geodesy});

  List<LatLng> findPointsInRange({
    required List<LatLng> pointsToCheck,
    required int distance,
    required LatLng point,
  }) {
    //Determine The Search Area
    //Search for Points Between Those GeoPoints
    //Query The Database
    //Find The Users Who Were Recently Scanned Around Me
    /// Get a list of points within a distance in meters from a given point
    var geofencedPoints = geodesy.pointsInRange(point, <LatLng>[], distance);
    return geofencedPoints;
  }
}
