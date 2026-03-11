import 'geo_point.dart';

class GameRound {
  const GameRound({
    required this.id,
    required this.district,
    required this.location,
  });

  final String id;
  final String district;
  final GeoPoint location;
}
