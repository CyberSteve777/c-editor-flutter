import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';

CPluginManifest _manifest({
  required String id,
  String name = 'Plugin',
  String version = '1.0.0',
  String author = '',
  List<String> authors = const [],
  List<String> contributors = const [],
  String? icon,
  String? website,
  String? issues,
  String? source,
  String? discord,
  List<CPluginIncompatibility> incompatibleWith = const [],
}) {
  return CPluginManifest(
    format: CPluginManifest.expectedFormat,
    formatVersion: CPluginManifest.supportedFormatVersion,
    id: id,
    name: name,
    version: version,
    author: author,
    authors: authors,
    contributors: contributors,
    icon: icon,
    website: website,
    issues: issues,
    source: source,
    discord: discord,
    incompatibleWith: incompatibleWith,
    entryLibrary: 'package:test/main.dart',
    entryFunction: 'initialize',
  );
}

void main() {
  group('CPluginManifest.fromJson', () {
    test('parses authors, contributors, icon, and links', () {
      final manifest = CPluginManifest.fromJson({
        'format': 'cplugin',
        'formatVersion': 1,
        'id': 'com.example.rich',
        'version': '2.0.0',
        'authors': ['Alice', 'Bob'],
        'contributors': ['Carol'],
        'icon': 'icon.png',
        'website': 'https://example.com',
        'issues': 'https://example.com/issues',
        'source': 'https://github.com/example/rich',
        'discord': 'https://discord.gg/example',
        'entry': {
          'library': 'package:rich/main.dart',
          'function': 'initialize',
        },
      });

      expect(manifest.name, isEmpty);
      expect(manifest.description, isEmpty);
      expect(manifest.authors, ['Alice', 'Bob']);
      expect(manifest.contributors, ['Carol']);
      expect(manifest.icon, 'icon.png');
      expect(manifest.website, 'https://example.com');
      expect(manifest.issues, 'https://example.com/issues');
      expect(manifest.source, 'https://github.com/example/rich');
      expect(manifest.discord, 'https://discord.gg/example');
      expect(manifest.resolvedAuthors, ['Alice', 'Bob']);
    });

    test('legacy name and description still parse', () {
      final manifest = CPluginManifest.fromJson({
        'format': 'cplugin',
        'formatVersion': 1,
        'id': 'com.example.legacy_named',
        'name': 'Legacy Name',
        'description': 'Legacy description',
        'version': '1.0.0',
        'entry': {
          'library': 'package:legacy/main.dart',
          'function': 'initialize',
        },
      });
      expect(manifest.name, 'Legacy Name');
      expect(manifest.description, 'Legacy description');
    });

    test('legacy author string still works via resolvedAuthors', () {
      final manifest = CPluginManifest.fromJson({
        'format': 'cplugin',
        'formatVersion': 1,
        'id': 'com.example.legacy',
        'version': '1.0.0',
        'author': 'OldAuthor',
        'entry': {
          'library': 'package:legacy/main.dart',
          'function': 'initialize',
        },
      });

      expect(manifest.author, 'OldAuthor');
      expect(manifest.authors, isEmpty);
      expect(manifest.resolvedAuthors, ['OldAuthor']);
      expect(manifest.authorsDisplay, 'OldAuthor');
    });
  });

  group('CPluginIncompatibility.matchesVersion', () {
    test('>=2.0.0 matches 2.1.0 and does not match 1.9.0', () {
      const rule = CPluginIncompatibility(id: 'other', version: '>=2.0.0');
      expect(rule.matchesVersion('2.1.0'), isTrue);
      expect(rule.matchesVersion('1.9.0'), isFalse);
    });
  });

  group('findPluginConflictMessage', () {
    test('reports when candidate declares incompatibility', () {
      final candidate = _manifest(
        id: 'a',
        name: 'A',
        version: '1.0.0',
        incompatibleWith: const [
          CPluginIncompatibility(id: 'b', version: '>=2.0.0'),
        ],
      );
      final installed = _manifest(id: 'b', name: 'B', version: '2.1.0');

      final message = findPluginConflictMessage(candidate, [installed]);
      expect(message, contains('Incompatible with B (b) v2.1.0'));
    });

    test('reports when installed plugin declares incompatibility', () {
      final candidate = _manifest(id: 'b', name: 'B', version: '2.1.0');
      final installed = _manifest(
        id: 'a',
        name: 'A',
        version: '1.0.0',
        incompatibleWith: const [
          CPluginIncompatibility(id: 'b', version: '>=2.0.0'),
        ],
      );

      final message = findPluginConflictMessage(candidate, [installed]);
      expect(message, contains('Conflicts with A (a) v1.0.0'));
    });

    test('returns null when versions do not match constraint', () {
      final candidate = _manifest(
        id: 'a',
        incompatibleWith: const [
          CPluginIncompatibility(id: 'b', version: '>=2.0.0'),
        ],
      );
      final installed = _manifest(id: 'b', version: '1.9.0');

      expect(findPluginConflictMessage(candidate, [installed]), isNull);
      expect(findPluginConflictMessage(installed, [candidate]), isNull);
    });
  });
}
