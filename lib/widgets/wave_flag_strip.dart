import 'package:flutter/material.dart';

/// Small fixed-size flag strip standing for the level's wave timeline: a
/// thin green bar divided into equal segments — one per wave (the
/// divisions are invisible) — with a red flag marker standing on each
/// flag wave.
///
/// Each flag sits partially in the bar: the bottom of the flag stands
/// inside the green strip while most of it rises above. Waves are laid
/// out right to left: wave 1 maps to the right edge of the strip and the
/// final wave (always a flag wave in the game) maps to the left edge,
/// where its flag sits flush against the border.
class WaveFlagStrip extends StatelessWidget {
  const WaveFlagStrip({
    super.key,
    required this.waveCount,
    required this.isFlagWave,
    this.width = 240,
    this.stripHeight = 6,
    this.flagSize = 14,
  });

  /// Total number of waves; the strip is divided into that many equal
  /// (invisible) segments.
  final int waveCount;

  /// Whether the wave (1-based) gets a visible flag marker.
  final bool Function(int waveNumber) isFlagWave;

  /// Fixed strip width.
  final double width;

  /// Height of the thin green bar; the flags stand in its lower part.
  final double stripHeight;

  /// Height of the flag icons; shrinks automatically when many flags
  /// share a short strip.
  final double flagSize;

  @override
  Widget build(BuildContext context) {
    if (waveCount <= 0) return const SizedBox.shrink();

    final flagWaves = <int>[
      for (var wave = 1; wave <= waveCount; wave++)
        if (isFlagWave(wave)) wave,
    ];
    var iconSize = flagSize;
    // Shrink the icons when many flags share a short strip so they never
    // overlap each other.
    if (flagWaves.isNotEmpty && flagWaves.length * iconSize > width) {
      iconSize = width / flagWaves.length;
    }

    // Left offset of a wave's flag: wave 1 flush against the right edge,
    // the final wave flush against the left edge.
    double iconLeft(int wave) {
      final fraction = waveCount <= 1
          ? 0.0
          : (waveCount - wave) / (waveCount - 1);
      return fraction * (width - iconSize);
    }

    return Semantics(
      label: 'Wave flag strip',
      // The Row wrapper keeps the fixed-width strip at the left even when
      // the parent stretches its children to the full available width,
      // without ever growing vertically itself.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: iconSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The thin green bar along the bottom of the widget.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: stripHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(stripHeight / 2),
                    ),
                  ),
                ),
                // Flags stand in the bar: their bottom sits inside the
                // green strip while the larger part rises above it.
                for (final wave in flagWaves)
                  Positioned(
                    left: iconLeft(wave),
                    bottom: 0,
                    child: Icon(
                      Icons.flag,
                      size: iconSize,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
