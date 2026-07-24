import 'dart:convert';

import 'package:http/http.dart' as http;

/// One downloadable `dynamic.rsb.smf` (or similar) from a GitHub release.
class DynamicReleaseOption {
  const DynamicReleaseOption({
    required this.tagName,
    required this.name,
    required this.downloadUrl,
    required this.assetName,
    required this.sizeBytes,
    required this.publishedAt,
    required this.isLatest,
  });

  final String tagName;
  final String name;
  final String downloadUrl;
  final String assetName;
  final int sizeBytes;
  final DateTime? publishedAt;
  final bool isLatest;
}

/// Fetches release options from Archiver2c/pvz2c-dynamic.
class Pvz2cDynamicReleases {
  Pvz2cDynamicReleases({http.Client? client})
    : _client = client ?? http.Client();

  static const repoApi =
      'https://api.github.com/repos/Archiver2c/pvz2c-dynamic/releases';

  final http.Client _client;

  static const _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'C-Editor',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  Future<List<DynamicReleaseOption>> list({int perPage = 30}) async {
    final uri = Uri.parse(repoApi).replace(
      queryParameters: {'per_page': '$perPage'},
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'GitHub releases failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected GitHub releases payload');
    }

    final options = <DynamicReleaseOption>[];
    for (final raw in decoded) {
      if (raw is! Map) continue;
      if (raw['draft'] == true) continue;
      final tag = raw['tag_name']?.toString() ?? '';
      if (tag.isEmpty) continue;
      final name = (raw['name']?.toString().trim().isNotEmpty == true)
          ? raw['name'].toString()
          : tag;
      final publishedRaw = raw['published_at']?.toString();
      final publishedAt = publishedRaw == null
          ? null
          : DateTime.tryParse(publishedRaw);
      final assets = raw['assets'];
      if (assets is! List) continue;

      for (final asset in assets) {
        if (asset is! Map) continue;
        final assetName = asset['name']?.toString() ?? '';
        if (!assetName.toLowerCase().endsWith('.rsb.smf')) continue;
        final url = asset['browser_download_url']?.toString() ?? '';
        if (url.isEmpty) continue;
        final size = asset['size'];
        options.add(
          DynamicReleaseOption(
            tagName: tag,
            name: name,
            downloadUrl: url,
            assetName: assetName,
            sizeBytes: size is int ? size : int.tryParse('$size') ?? 0,
            publishedAt: publishedAt,
            isLatest: options.isEmpty,
          ),
        );
        break; // one smf asset per release
      }
    }
    return options;
  }

  void close() => _client.close();
}
