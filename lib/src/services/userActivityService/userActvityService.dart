import 'package:geodesy/geodesy.dart';

class UserActivityService {
  Geodesy geodesy = Geodesy();

  double pace(Duration time, num distanceMeters) {
    //Time between two scans < 30 Mins
    /// Pace = Time\Distanc
    /// per meter
    //Todo Only Calc Pace if time is less then 30min?
    return time.inMinutes / distanceMeters;
  }

  num distanceTraveledInMeters(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return geodesy.distanceBetweenTwoGeoPoints(
        LatLng(startLat, startLng), LatLng(endLat, endLng));
  }

  double calories({
    required int time,
    required double weight,
    required int MET,
  }) {
    //Activity Calories Burned Calculator per minute
    //Compendium of Physical Activities
    //know the MET value of a particular activity
    //Suggest Foods to suppliment the user based off Activites
    //The formula to use is: METs x 3.5 x (your body weight in kilograms) / 200 = calories burned per minute.
    return MET * 3.5 * (weight / 200);
  }
}
