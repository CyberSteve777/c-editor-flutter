import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:c_editor/data/app_links.dart';
import 'package:c_editor/data/app_properties.dart';
import 'package:c_editor/l10n/app_localizations.dart';

String _usageTextForPlatform(BuildContext context, AppLocalizations l10n) {
  final p = Theme.of(context).platform;
  final isDesktop =
      p == TargetPlatform.windows ||
      p == TargetPlatform.macOS ||
      p == TargetPlatform.linux;
  return isDesktop ? l10n.usageTextDesktop : l10n.usageTextMobile;
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<AppLinks> _linksFuture = AppLinks.load();
  late final Future<AppProperties> _propertiesFuture = AppProperties.load();
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.softwareIntro,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: FutureBuilder<AppLinks>(
        future: _linksFuture,
        builder: (context, linksSnapshot) {
          final links = linksSnapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.cEditor,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.pvzEditorSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                _InfoCard(
                  title: l10n.introSection,
                  child: Text(
                    l10n.introText,
                    style: TextStyle(
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _InfoCard(
                  title: l10n.featuresSection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bullet(l10n.feature1),
                      _Bullet(l10n.feature2),
                      _Bullet(l10n.feature3),
                      _Bullet(l10n.feature4),
                    ],
                  ),
                ),
                _InfoCard(
                  title: l10n.usageSection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _usageTextForPlatform(context, l10n),
                        style: TextStyle(
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (links != null &&
                          l10n.usageRecommendedLevelsLabel.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _LinkRow(
                          label: l10n.usageRecommendedLevelsLabel,
                          url: links.recommendedLevels,
                          onSurface: theme.colorScheme.onSurface,
                          linkColor: theme.colorScheme.primary,
                        ),
                      ],
                      if (links != null &&
                          l10n.discordInviteLabel.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _LinkRow(
                          label: l10n.discordInviteLabel,
                          url: links.discordInvite,
                          onSurface: theme.colorScheme.onSurface,
                          linkColor: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                _InfoCard(
                  title: l10n.creditsSection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bullet(l10n.authorLabel),
                      Text(
                        l10n.authorName,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      _Bullet(l10n.thanksLabel),
                      Text(
                        l10n.thanksNames,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      if (links != null) ...[
                        _LinkRow(
                          label: l10n.sourceLabel,
                          url: links.source,
                          onSurface: theme.colorScheme.onSurface,
                          linkColor: theme.colorScheme.primary,
                        ),
                        _LinkRow(
                          label: l10n.issuesLabel,
                          url: links.issues,
                          onSurface: theme.colorScheme.onSurface,
                          linkColor: theme.colorScheme.primary,
                        ),
                        _Bullet('${l10n.discordLabel} ${l10n.comingSoon}'),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        l10n.zEditorAcknowledgment,
                        style: TextStyle(
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.zEditorCreditsSubsection,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Bullet(l10n.zEditorAuthorLabel),
                      Text(
                        l10n.zEditorAuthorName,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      _Bullet(l10n.zEditorThanksLabel),
                      Text(
                        l10n.zEditorThanksNames,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      _Bullet(l10n.zEditorQqGroupLabel),
                      Text(
                        l10n.zEditorQqGroupNumber,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.tagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<(PackageInfo, AppProperties)>(
                  future: Future.wait([_packageInfoFuture, _propertiesFuture])
                      .then(
                        (results) => (
                          results[0] as PackageInfo,
                          results[1] as AppProperties,
                        ),
                      ),
                  builder: (context, snapshot) {
                    final packageInfo = snapshot.data?.$1;
                    final properties = snapshot.data?.$2;
                    final editorVersion =
                        packageInfo?.version.isNotEmpty == true
                        ? packageInfo!.version
                        : '0.0.0';
                    final gameVersion =
                        properties?.supportedGameVersion ?? '0.0.0';
                    final versionStyle = theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    );
                    return Column(
                      children: [
                        Text(
                          l10n.editorVersion(editorVersion),
                          textAlign: TextAlign.center,
                          style: versionStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.supportedGameVersion(gameVersion),
                          textAlign: TextAlign.center,
                          style: versionStyle,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.url,
    required this.onSurface,
    required this.linkColor,
  });

  final String label;
  final String url;
  final Color onSurface;
  final Color linkColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontWeight: FontWeight.bold, color: linkColor),
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '$label ',
                  style: TextStyle(height: 1.5, color: onSurface),
                ),
                InkWell(
                  onTap: () => _openUrl(url),
                  child: Text(
                    url,
                    style: TextStyle(
                      height: 1.5,
                      color: linkColor,
                      decoration: TextDecoration.underline,
                      decorationColor: linkColor,
                    ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(height: 1.5, color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
