#!/usr/bin/env python3
"""Sync custom stage preset name/source keys in assets/l10n/resource_*.json."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESETS_PATH = ROOT / "assets/resources/CustomStagePresets.json"
L10N_DIR = ROOT / "assets/l10n"

RU_OVERRIDES: dict[str, str] = {
    "customStagePreset_bigWaveNight": "Большая ночная волна",
    "customStagePreset_mixtapeSummerNight": "Рок-летняя ночь",
    "customStagePreset_oneSidedAtlantis": "Односторонний Атлантис",
    "customStagePreset_lostVolcano": "Потерянный вулкан",
    "customStagePresetSource_memoryLaneS25Week6Boss": "Из босс-уровня 6-й недели 25 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS26HardLevel1": "Из 1-го уровня сложного режима 26 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS28Week3Original5_8": "Из оригинальных уровней 5–8 3-й недели 28 сезона «Путешествие в прошлое»",
    "customStagePresetSource_memoryLaneS30Week5Boss": "Из босс-уровня 5-й недели 30 сезона «Путешествие в прошлое»",
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


def is_preset_l10n_key(key: str) -> bool:
    return key.startswith("customStagePreset_") or key.startswith(
        "customStagePresetSource_"
    )


def main() -> None:
    keys = preset_keys()
    en_source = load_json(L10N_DIR / "resource_en.json")
    zh_source = load_json(L10N_DIR / "resource_zh.json")

    for locale in ("en", "zh", "ru"):
        resource_path = L10N_DIR / f"resource_{locale}.json"
        resource = load_json(resource_path)

        removed = [k for k in resource if is_preset_l10n_key(k) and k not in keys]
        for key in removed:
            del resource[key]

        added = 0
        for key in sorted(keys):
            if locale == "ru":
                value = RU_OVERRIDES.get(key, en_source.get(key, key))
            elif locale == "zh":
                value = zh_source.get(key, en_source.get(key, key))
            else:
                value = en_source.get(key, key)
            if key not in en_source and locale == "en":
                raise KeyError(f"Missing {key} in resource_en.json — add English text first")
            if resource.get(key) != value:
                resource[key] = value
                added += 1

        save_json(resource_path, resource)
        removed_note = f", {len(removed)} orphaned removed" if removed else ""
        print(
            f"resource_{locale}.json: {len(resource)} keys "
            f"({added} preset entries updated{removed_note})"
        )


if __name__ == "__main__":
    main()
