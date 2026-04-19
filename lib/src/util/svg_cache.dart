// lib/src/util/svg_cache.dart
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

/// Lazy, process-wide cache for SVG asset loads to avoid jank from the first
/// paint of each unique asset.
///
/// Call [preload] for asset paths you know you'll need; subsequent
/// [SvgPicture.asset] calls hit the flutter_svg cache rather than hitting the
/// asset bundle.
class SvgCache {
  SvgCache._();

  static final Set<String> _preloaded = <String>{};

  /// Preloads every path in [paths] from the bundle associated with [package].
  /// No-op for paths already preloaded in this process.
  static Future<void> preload(
    Iterable<String> paths, {
    String? package,
  }) async {
    for (final p in paths) {
      final key = '${package ?? ''}:$p';
      if (_preloaded.contains(key)) continue;
      try {
        await rootBundle.loadString(
          package != null ? 'packages/$package/$p' : p,
        );
        _preloaded.add(key);
      } catch (_) {
        // swallow: flutter_svg will error loudly at render time if it matters
      }
    }
  }

  /// Clears the internal preload set. Useful for tests.
  @visibleForTesting
  static void resetForTests() => _preloaded.clear();
}
