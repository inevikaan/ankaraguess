import 'dart:math';

import '../model/geo_point.dart';

class ScoreCalculator {
  static const double _earthRadiusMeters = 6371000;

  static double distanceMeters(GeoPoint from, GeoPoint to) {
    final double lat1 = _toRadians(from.latitude);
    final double lon1 = _toRadians(from.longitude);
    final double lat2 = _toRadians(to.latitude);
    final double lon2 = _toRadians(to.longitude);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a =
        pow(sin(dLat / 2), 2).toDouble() +
        cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2).toDouble();
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  static int calculate({
    required double distanceMeters,
    required int remainingSeconds,
    required int maxGuessSeconds,
  }) {
    final double base = (1000 - (distanceMeters / 5)).clamp(0, 1000);
    final int timeBonus = remainingSeconds.clamp(0, maxGuessSeconds) * 20;
    return base.round() + timeBonus;
  }

  static double _toRadians(double degree) => degree * pi / 180;
}
