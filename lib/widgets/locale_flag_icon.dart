import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

/// Country flag for a supported app [languageCode] (`en`, `zh`, `ru`).
class LocaleFlagIcon extends StatelessWidget {
  const LocaleFlagIcon(
    this.languageCode, {
    super.key,
    this.width = 32,
    this.height = 22,
  });

  final String languageCode;
  final double width;
  final double height;

  String get _countryCode => switch (languageCode) {
        'en' => 'US',
        'zh' => 'CN',
        'ru' => 'RU',
        _ => languageCode.toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CountryFlag.fromCountryCode(
          _countryCode,
          theme: ImageTheme(
            width: width,
            height: height,
            shape: RoundedRectangle(4),
          ),
        ),
      ),
    );
  }
}
