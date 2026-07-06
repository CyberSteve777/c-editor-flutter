import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the platform browser or another external handler.
///
/// On Android 11+, [canLaunchUrl] returns false without matching
/// `<queries>` entries in AndroidManifest.xml, so this tries [launchUrl]
/// directly and reports success from its return value.
Future<bool> launchExternalUrl(
  String url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return launchUrl(uri, mode: mode);
}
