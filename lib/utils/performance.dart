import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

/// Adaptive performance configuration for varying display refresh rates.
/// Detects the device's display capabilities and provides optimized
/// animation parameters for 60Hz, 90Hz, and 120Hz+ displays.
///
/// Flutter automatically syncs to the display's vsync, so 120fps is
/// achieved natively. This utility helps tune animation *durations*
/// and provides runtime diagnostics.
class PerformanceConfig {
  PerformanceConfig._();

  static double? _cachedRefreshRate;

  // ─── Display Detection ──────────────────────────────────────

  /// The device's display refresh rate in Hz.
  /// Falls back to 60Hz if detection fails.
  static double get displayRefreshRate {
    if (_cachedRefreshRate != null) return _cachedRefreshRate!;
    try {
      final displays = ui.PlatformDispatcher.instance.displays;
      if (displays.isNotEmpty) {
        _cachedRefreshRate = displays.first.refreshRate;
      }
    } catch (_) {
      // Fallback for platforms that don't support Display API
    }
    _cachedRefreshRate ??= 60.0;
    return _cachedRefreshRate!;
  }

  /// Whether the device supports high refresh rate (>60Hz).
  static bool get isHighRefreshRate => displayRefreshRate > 60;

  /// Whether the device supports 120Hz or higher.
  static bool get isUltraHighRefreshRate => displayRefreshRate >= 120;

  // ─── Adaptive Animation Scaling ─────────────────────────────

  /// Scale a base [Duration] for the device's refresh rate.
  ///
  /// Higher refresh rates use slightly shorter durations for a snappier
  /// feel — there are more frames to render the same transition, so
  /// shorter durations still look smooth.
  ///
  /// - 120Hz+: 85% of base duration
  /// - 90Hz:   92% of base duration
  /// - 60Hz:   100% (unchanged)
  static Duration scaleDuration(Duration base) {
    final rate = displayRefreshRate;
    if (rate >= 120) {
      return base * 0.85;
    } else if (rate >= 90) {
      return base * 0.92;
    }
    return base;
  }

  /// Ideal frame interval in milliseconds for the current display.
  /// 60Hz → 16.67ms, 90Hz → 11.11ms, 120Hz → 8.33ms
  static double get frameIntervalMs => 1000.0 / displayRefreshRate;

  // ─── Diagnostics ────────────────────────────────────────────

  /// Log the detected refresh rate (debug builds only).
  static void logInfo() {
    debugPrint(
      '[PerformanceConfig] Display: ${displayRefreshRate.toStringAsFixed(0)}Hz, '
      'frame interval: ${frameIntervalMs.toStringAsFixed(2)}ms, '
      'high refresh: $isHighRefreshRate',
    );
  }
}
