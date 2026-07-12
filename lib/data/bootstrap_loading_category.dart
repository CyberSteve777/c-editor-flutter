import 'package:c_editor/l10n/app_localizations.dart';

/// High-level bootstrap phases shown on the startup loading screen.
enum BootstrapLoadingCategory {
  localization,
  stages,
  audio,
  gridItems,
  zomboss,
  reference,
  zombies,
  plants,
  fish,
  images;

  String localized(AppLocalizations l10n) {
    return switch (this) {
      BootstrapLoadingCategory.localization =>
        l10n.startupLoadingLocalization,
      BootstrapLoadingCategory.stages => l10n.startupLoadingStages,
      BootstrapLoadingCategory.audio => l10n.startupLoadingAudio,
      BootstrapLoadingCategory.gridItems => l10n.startupLoadingGridItems,
      BootstrapLoadingCategory.zomboss => l10n.startupLoadingZomboss,
      BootstrapLoadingCategory.reference => l10n.startupLoadingReference,
      BootstrapLoadingCategory.zombies => l10n.startupLoadingZombies,
      BootstrapLoadingCategory.plants => l10n.startupLoadingPlants,
      BootstrapLoadingCategory.fish => l10n.startupLoadingFish,
      BootstrapLoadingCategory.images => l10n.startupLoadingImages,
    };
  }

  String loadingLabel(AppLocalizations l10n) {
    return l10n.startupLoadingCategoryProgress(localized(l10n));
  }
}

typedef BootstrapProgressCallback = void Function(
  double progress,
  BootstrapLoadingCategory? category,
);
