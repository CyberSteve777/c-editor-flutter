#!/usr/bin/env python3
"""Merge custom stage preset name/source keys into assets/l10n/resource_*.json."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESETS_PATH = ROOT / "assets/resources/CustomStagePresets.json"
ARB_DIR = ROOT / "assets/l10n"

# Russian preset strings (app_ru.arb still uses English placeholders).
RU_OVERRIDES: dict[str, str] = {
    "customStagePreset_bigWaveNight": "Большая ночная волна",
    "customStagePreset_mixtapeSummerNight": "Рок-летняя ночь",
    "customStagePreset_oneSidedAtlantis": "Односторонний Атлантис",
    "customStagePreset_futureLawn": "Будущее",
    "customStagePreset_roofNight": "Крыша (ночь)",
    "customStagePreset_snowModern": "Современная снежная",
    "customStagePreset_poolDaylight": "Бассейн (день)",
    "customStagePreset_renai": "Ренессанс",
    "customStagePreset_steam": "Пар",
    "customStagePreset_lostVolcano": "Потерянный вулкан",
    "customStagePreset_summerDaylight": "Летний день",
    "customStagePreset_newYearNight": "Новый год (ночь)",
    "customStagePreset_autumnLate": "Поздняя осень",
    "customStagePresetSource_memoryLaneS25Week6Boss": "Из босс-уровня 6-й недели 25 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS26HardLevel1": "Из 1-го уровня сложного режима 26 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS28Week3Original5_8": "Из оригинальных уровней 5–8 3-й недели 28 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS28Level5": "Из 5-го уровня 28 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS27Level61": "Из 61-го уровня 27 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS29Level57": "Из 57-го уровня 29 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS31Level20": "Из 20-го уровня 31 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS30Level31": "Из 31-го уровня 30 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS31Level9": "Из 9-го уровня 31 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS30Boss6": "Из 6-го босс-уровня 30 сезона «Путешествие в прошлое»",
    "customStagePresetSource_minigameGame33": "Из мини-игры, уровень 33",
    "customStagePresetSource_memoryLaneS30Hard1": "Из 1-го уровня сложного режима 30 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS28Level13": "Из 13-го уровня 28 сезона «Путешествие в прошлое»",
}


def load_json(path: Path) -> dict[str, str]:
    with path.open(encoding="utf-8") as f:
        return {str(k): str(v) for k, v in json.load(f).items()}


def save_json(path: Path, data: dict[str, str]) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(dict(sorted(data.items())), f, ensure_ascii=False, indent=2)
        f.write("\n")


def preset_keys() -> set[str]:
    presets = json.loads(PRESETS_PATH.read_text(encoding="utf-8"))
    keys: set[str] = set()
    for preset in presets:
        keys.add(preset["nameKey"])
        keys.add(preset["sourceKey"])
    return keys


def main() -> None:
    keys = preset_keys()
    for locale in ("en", "zh", "ru"):
        arb = load_json(ARB_DIR / f"app_{locale}.arb")
        resource_path = ARB_DIR / f"resource_{locale}.json"
        resource = load_json(resource_path)
        added = 0
        for key in sorted(keys):
            if key not in arb:
                raise KeyError(f"Missing {key} in app_{locale}.arb")
            value = RU_OVERRIDES.get(key, arb[key]) if locale == "ru" else arb[key]
            if resource.get(key) != value:
                resource[key] = value
                added += 1
        save_json(resource_path, resource)
        print(f"resource_{locale}.json: {len(resource)} keys ({added} preset entries updated)")


if __name__ == "__main__":
    main()
