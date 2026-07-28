import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Progress for a plugin download: [received] / [total] (total may be null).
typedef PluginDownloadProgress = void Function(int received, int? total);

/// Downloads plugin bytes from an HTTP(S) URL with optional progress.
class PluginDownloader {
  PluginDownloader({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Uint8List> download(
    Uri uri, {
    PluginDownloadProgress? onProgress,
  }) async {
    final request = http.Request('GET', uri);
    final response = await _client.send(request);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Download failed with HTTP ${response.statusCode}',
      );
    }

    final total = response.contentLength;
    final builder = BytesBuilder(copy: false);
    var received = 0;

    await for (final chunk in response.stream) {
      builder.add(chunk);
      received += chunk.length;
      onProgress?.call(received, total);
    }

    return builder.takeBytes();
  }

  void close() => _client.close();
}
