import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';

class PreviewBossEntry {
  const PreviewBossEntry({
    required this.item,
    required this.kind,
  });

  final PreviewItem item;
  final PreviewBossKind kind;
}

/// Boss icon + mech phase spawn zombies for preview composition.
class PreviewZombossExtras {
  const PreviewZombossExtras({
    required this.bosses,
    required this.spawnItems,
  });

  final List<PreviewBossEntry> bosses;
  final List<PreviewItem> spawnItems;

  List<PreviewItem> get bossItems => bosses.map((e) => e.item).toList();

  static Future<PreviewZombossExtras> collect(PvzLevelFile levelFile) async {
    await ZombossMechRepository.init();
    await ZombossBattleRepository.init();
    await ZombieRepository().init();

    final bosses = <PreviewBossEntry>[];
    final spawns = <PreviewItem>[];
    final seenBoss = <String>{};
    final seenSpawn = <String>{};

    void addBoss(String id, String asset, PreviewBossKind kind) {
      if (id.isEmpty || !seenBoss.add(id)) return;
      bosses.add(
        PreviewBossEntry(
          item: PreviewItem(id: id, assetPath: asset),
          kind: kind,
        ),
      );
    }

    void addSpawn(String id) {
      var clean = id.trim();
      clean = clean.replaceAll(RegExp(r'^(Zombie|Plant)'), '');
      if (clean.isEmpty || !seenSpawn.add(clean)) return;
      final info =
          ZombieRepository().getZombieById(clean) ??
          ZombieRepository().getZombieById(id.trim());
      final path = info?.iconAssetPath ?? 'assets/images/others/unknown.webp';
      spawns.add(PreviewItem(id: clean, assetPath: path));
    }

    final mech = readZombossBattleData(levelFile);
    if (mech != null && mech.zombossMechType.isNotEmpty) {
      final type = mech.zombossMechType;
      final base = ZombossMechRepository.findBaseForVariation(type);
      final icon = base?.icon;
      if (base != null && icon != null && icon.isNotEmpty) {
        addBoss(base.id, 'assets/images/zombies/$icon', PreviewBossKind.zombot);
      }

      final catalog = ZombossMechRepository.findCatalogForVariation(type);
      if (catalog != null) {
        final custom = ZombossMechRepository.findCustomPropertiesInLevel(
          levelFile: levelFile,
          catalog: catalog,
        );
        final props = custom?.objData is Map
            ? Map<String, dynamic>.from(custom!.objData as Map)
            : ZombossMechRepository.propertiesDataForVariation(
                type,
                catalog: catalog,
              );
        final stages = props?['Stages'];
        if (stages is List) {
          for (final stage in stages) {
            if (stage is! Map) continue;
            final actions = <String>[];
            final rawActions = stage['Actions'];
            if (rawActions is List) {
              for (final a in rawActions) {
                if (a != null && a.toString().isNotEmpty) {
                  actions.add(a.toString());
                }
              }
            }
            final retreat = stage['RetreatAction'];
            if (retreat != null && retreat.toString().isNotEmpty) {
              actions.add(retreat.toString());
            }
            for (final rtid in actions) {
              final resolved = ZombossMechActionUtils.resolveAction(
                rtid: rtid,
                catalog: catalog,
                levelFile: levelFile,
              );
              if (resolved == null) continue;
              for (final binding in resolved.zombieLists) {
                for (final z in binding.zombieIds) {
                  addSpawn(z);
                }
              }
            }
          }
        }
      }
    }

    final nonMech = readZombossLastStandData(levelFile);
    if (nonMech != null && nonMech.zombossTypeName.isNotEmpty) {
      final type = nonMech.zombossTypeName;
      final base = ZombossBattleRepository.findBaseForVariation(type);
      final icon = base?.icon;
      if (base != null && icon != null && icon.isNotEmpty) {
        addBoss(
          base.id,
          'assets/images/zombies/$icon',
          PreviewBossKind.zomboss,
        );
      }
    }

    return PreviewZombossExtras(bosses: bosses, spawnItems: spawns);
  }
}
