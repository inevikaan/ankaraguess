import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, this.scale = 1});

  static const List<String> _candidateAssetPaths = <String>[
    'assets/images/ankara_guess_logo.png',
    'assets/images/logo.png',
    'assets/images/ankara_logo.png',
  ];

  final double scale;

  String? _resolveLogoPath(AssetManifest manifest) {
    final List<String> allAssets = manifest.listAssets();

    for (final String candidate in _candidateAssetPaths) {
      if (allAssets.contains(candidate)) {
        return candidate;
      }
    }

    final Iterable<String> imageAssets = allAssets.where((String asset) {
      final bool inImagesFolder = asset.startsWith('assets/images/');
      final bool supportedType =
          asset.endsWith('.png') ||
          asset.endsWith('.jpg') ||
          asset.endsWith('.jpeg');
      return inImagesFolder && supportedType;
    });

    return imageAssets.isEmpty ? null : imageAssets.first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetManifest>(
      future: AssetManifest.loadFromAssetBundle(rootBundle),
      builder: (BuildContext context, AsyncSnapshot<AssetManifest> snapshot) {
        final AssetManifest? manifest = snapshot.data;
        if (manifest == null) {
          return _FallbackLogo(scale: scale);
        }
        final String? logoPath = _resolveLogoPath(manifest);
        if (logoPath == null) {
          return _FallbackLogo(scale: scale);
        }
        return Image.asset(logoPath, width: 520 * scale, fit: BoxFit.contain);
      },
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * scale),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF1AC7F0),
            AppPalette.cyan,
            Color(0xFF6DE9FF),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.cyan.withValues(alpha: 0.4),
            blurRadius: 18 * scale,
            spreadRadius: 2 * scale,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22 * scale),
          color: AppPalette.navy,
        ),
        child: Text(
          'AnkaraGuess',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 44 * scale,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: AppPalette.cyanSoft,
            shadows: <Shadow>[
              Shadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
