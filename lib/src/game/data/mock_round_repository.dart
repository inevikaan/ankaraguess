import 'dart:math';

import '../model/game_round.dart';
import '../model/geo_point.dart';

class MockRoundRepository {
  const MockRoundRepository();

  static const double _metersPerLatDegree = 111320;

  static const List<_DistrictZone> _districtZones = <_DistrictZone>[
    _DistrictZone(
      id: 'cankaya',
      name: 'Çankaya',
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9208,
          longitude: 32.8541,
          radiusMeters: 1500,
        ),
        _SettlementCluster(
          latitude: 39.9067,
          longitude: 32.8617,
          radiusMeters: 1400,
        ),
        _SettlementCluster(
          latitude: 39.8838,
          longitude: 32.8513,
          radiusMeters: 1700,
        ),
      ],
    ),
    _DistrictZone(
      id: 'kecioren',
      name: 'Keçiören',
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9854,
          longitude: 32.8653,
          radiusMeters: 1800,
        ),
        _SettlementCluster(
          latitude: 39.9720,
          longitude: 32.8430,
          radiusMeters: 1400,
        ),
      ],
    ),
    _DistrictZone(
      id: 'mamak',
      name: 'Mamak',
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9204,
          longitude: 32.9200,
          radiusMeters: 1700,
        ),
        _SettlementCluster(
          latitude: 39.9330,
          longitude: 32.9570,
          radiusMeters: 1600,
        ),
      ],
    ),
    _DistrictZone(
      id: 'yenimahalle',
      name: 'Yenimahalle',
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9740,
          longitude: 32.7309,
          radiusMeters: 1900,
        ),
        _SettlementCluster(
          latitude: 39.9630,
          longitude: 32.8070,
          radiusMeters: 1400,
        ),
      ],
    ),
    _DistrictZone(
      id: 'etimesgut',
      name: 'Etimesgut',
      minLevel: 2,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9772,
          longitude: 32.6274,
          radiusMeters: 1900,
        ),
        _SettlementCluster(
          latitude: 39.9520,
          longitude: 32.6750,
          radiusMeters: 1500,
        ),
      ],
    ),
    _DistrictZone(
      id: 'altindag',
      name: 'Altındağ',
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9438,
          longitude: 32.8560,
          radiusMeters: 1400,
        ),
        _SettlementCluster(
          latitude: 39.9600,
          longitude: 32.8880,
          radiusMeters: 1400,
        ),
      ],
    ),
    _DistrictZone(
      id: 'golbasi',
      name: 'Gölbaşı',
      minLevel: 2,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.7904,
          longitude: 32.8072,
          radiusMeters: 2200,
        ),
        _SettlementCluster(
          latitude: 39.8480,
          longitude: 32.7340,
          radiusMeters: 1700,
        ),
      ],
    ),
    _DistrictZone(
      id: 'sincan',
      name: 'Sincan',
      minLevel: 2,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9723,
          longitude: 32.5828,
          radiusMeters: 2200,
        ),
      ],
    ),
    _DistrictZone(
      id: 'pursaklar',
      name: 'Pursaklar',
      minLevel: 2,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 40.0390,
          longitude: 32.9020,
          radiusMeters: 1700,
        ),
      ],
    ),
    _DistrictZone(
      id: 'akyurt',
      name: 'Akyurt',
      minLevel: 3,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 40.1300,
          longitude: 33.0850,
          radiusMeters: 1400,
        ),
      ],
    ),
    _DistrictZone(
      id: 'kazan',
      name: 'Kahramankazan',
      minLevel: 3,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 40.2030,
          longitude: 32.6830,
          radiusMeters: 1700,
        ),
      ],
    ),
    _DistrictZone(
      id: 'cubuk',
      name: 'Çubuk',
      minLevel: 4,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 40.2360,
          longitude: 33.0320,
          radiusMeters: 1800,
        ),
      ],
    ),
    _DistrictZone(
      id: 'elmadag',
      name: 'Elmadağ',
      minLevel: 2,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.9200,
          longitude: 33.2300,
          radiusMeters: 1500,
        ),
      ],
    ),
    _DistrictZone(
      id: 'polatli',
      name: 'Polatlı',
      minLevel: 4,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 39.5840,
          longitude: 32.1470,
          radiusMeters: 2100,
        ),
      ],
    ),
    _DistrictZone(
      id: 'beypazari',
      name: 'Beypazarı',
      minLevel: 5,
      clusters: <_SettlementCluster>[
        _SettlementCluster(
          latitude: 40.1670,
          longitude: 31.9220,
          radiusMeters: 1700,
        ),
      ],
    ),
  ];

  int unlockedDistrictCount(int level) {
    return _districtZones.where((zone) => zone.minLevel <= level).length;
  }

  List<GameRound> pickRounds({
    int count = 5,
    int playerLevel = 1,
    double radiusMultiplier = 1,
  }) {
    final Random random = Random();
    final List<_DistrictZone> unlockedDistricts = _districtZones
        .where((zone) => zone.minLevel <= playerLevel)
        .toList();

    final List<_DistrictZone> sourceDistricts = unlockedDistricts.isEmpty
        ? List<_DistrictZone>.from(_districtZones)
        : unlockedDistricts;
    final List<_DistrictZone> shuffledDistricts = List<_DistrictZone>.from(
      sourceDistricts,
    )..shuffle(random);

    final int safeCount = count.clamp(1, shuffledDistricts.length);
    return List<GameRound>.generate(safeCount, (int index) {
      final _DistrictZone district = shuffledDistricts[index];
      final _SettlementCluster cluster =
          district.clusters[random.nextInt(district.clusters.length)];
      final GeoPoint randomPoint = _randomPointInCluster(
        cluster,
        random,
        radiusMultiplier: radiusMultiplier,
      );

      return GameRound(
        id: '${district.id}_${random.nextInt(1000000)}',
        district: district.name,
        location: randomPoint,
      );
    });
  }

  GeoPoint _randomPointInCluster(
    _SettlementCluster cluster,
    Random random, {
    required double radiusMultiplier,
  }) {
    final double adjustedRadius = (cluster.radiusMeters * radiusMultiplier)
        .clamp(450, 2600);
    // sqrt() keeps spatial density uniform inside the circle area.
    final double distanceMeters = sqrt(random.nextDouble()) * adjustedRadius;
    final double angle = random.nextDouble() * 2 * pi;

    final double deltaLat = (distanceMeters * cos(angle)) / _metersPerLatDegree;
    final double metersPerLonDegree =
        _metersPerLatDegree * cos(cluster.latitude * pi / 180);
    final double safeMetersPerLonDegree = metersPerLonDegree.abs() < 1
        ? 1
        : metersPerLonDegree;
    final double deltaLon =
        (distanceMeters * sin(angle)) / safeMetersPerLonDegree;

    return GeoPoint(
      latitude: cluster.latitude + deltaLat,
      longitude: cluster.longitude + deltaLon,
    );
  }
}

class _DistrictZone {
  const _DistrictZone({
    required this.id,
    required this.name,
    this.minLevel = 1,
    required this.clusters,
  });

  final String id;
  final String name;
  final int minLevel;
  final List<_SettlementCluster> clusters;
}

class _SettlementCluster {
  const _SettlementCluster({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final double latitude;
  final double longitude;
  final double radiusMeters;
}
