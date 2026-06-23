#!/usr/bin/env python3
"""Verify assets/l10n/ integrity: ARB parity, resource JSON parity, coverage."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "assets/l10n"
LOCALES = ("en", "zh", "ru")


def load_arb_keys(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k for k in data if not k.startswith("@")}


def load_resource(path: Path) -> dict[str, str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {str(k): str(v) for k, v in data.items()}


def main() -> int:
    issues: list[str] = []
    warnings: list[str] = []

    # --- ARB key parity ---
    arb_keys = {loc: load_arb_keys(L10N / f"app_{loc}.arb") for loc in LOCALES}
    en_arb = arb_keys["en"]
    print("ARB files:")
    for loc in LOCALES:
        print(f"  app_{loc}.arb: {len(arb_keys[loc])} keys")
    for loc in ("zh", "ru"):
        missing = sorted(en_arb - arb_keys[loc])
        extra = sorted(arb_keys[loc] - en_arb)
        if missing:
            issues.append(f"ARB missing in app_{loc}.arb ({len(missing)}): {missing[:10]}{'...' if len(missing) > 10 else ''}")
        if extra:
            issues.append(f"ARB extra in app_{loc}.arb ({len(extra)}): {extra[:10]}{'...' if len(extra) > 10 else ''}")
    if not issues:
        print("  All ARB files have identical keys.")

    # --- Resource JSON parity ---
    resources = {loc: load_resource(L10N / f"resource_{loc}.json") for loc in LOCALES}
    en_res_keys = set(resources["en"])
    print("\nResource JSON:")
    for loc in LOCALES:
        print(f"  resource_{loc}.json: {len(resources[loc])} keys")
    for loc in ("zh", "ru"):
        loc_keys = set(resources[loc])
        missing = sorted(en_res_keys - loc_keys)
        extra = sorted(loc_keys - en_res_keys)
        if missing:
            issues.append(f"Resource missing in resource_{loc}.json ({len(missing)}): {missing[:10]}{'...' if len(missing) > 10 else ''}")
        if extra:
            issues.append(f"Resource extra in resource_{loc}.json ({len(extra)}): {extra[:10]}{'...' if len(extra) > 10 else ''}")
    if not any("Resource" in i for i in issues):
        print("  All resource JSON files have identical keys.")

    # --- Empty values ---
    for loc in LOCALES:
        empty_arb = sorted(k for k, v in json.loads((L10N / f"app_{loc}.arb").read_text(encoding="utf-8")).items()
                            if not k.startswith("@") and (v is None or str(v).strip() == ""))
        empty_res = sorted(k for k, v in resources[loc].items() if not v.strip())
        if empty_arb:
            issues.append(f"Empty ARB values in app_{loc}.arb: {empty_arb[:5]}")
        if empty_res:
            issues.append(f"Empty resource values in resource_{loc}.json: {empty_res[:5]}")

    # --- Custom stage preset coverage ---
    presets_path = ROOT / "assets/resources/CustomStagePresets.json"
    if presets_path.exists():
        presets = json.loads(presets_path.read_text(encoding="utf-8"))
        preset_keys: set[str] = set()
        for preset in presets:
            preset_keys.add(preset["nameKey"])
            preset_keys.add(preset["sourceKey"])
        print(f"\nCustom stage presets: {len(presets)} presets, {len(preset_keys)} l10n keys")
        for loc in LOCALES:
            missing = sorted(preset_keys - set(resources[loc]))
            if missing:
                issues.append(f"Preset keys missing in resource_{loc}.json: {missing}")
            arb_missing = sorted(preset_keys - arb_keys[loc])
            if arb_missing:
                issues.append(f"Preset keys missing in app_{loc}.arb: {arb_missing}")
        # Sync check: resource should match arb (except ru overrides from generator)
        for key in sorted(preset_keys):
            for loc in ("en", "zh"):
                if resources[loc].get(key) != arb_keys[loc] and key in arb_keys[loc]:
                    arb_val = json.loads((L10N / f"app_{loc}.arb").read_text(encoding="utf-8"))[key]
                    if resources[loc].get(key) != arb_val:
                        warnings.append(f"resource_{loc}.json preset {key} differs from ARB")

    # --- Stage name keys from Stages_new.json ---
    stages_new = ROOT / "assets/resources/Stages_new.json"
    if stages_new.exists():
        stage_data = json.loads(stages_new.read_text(encoding="utf-8"))
        stage_keys: set[str] = set()
        for section in stage_data:
            for impl in section.get("implementations") or []:
                nk = impl.get("nameKey")
                if nk:
                    stage_keys.add(nk)
        print(f"\nStage name keys (Stages_new.json): {len(stage_keys)}")
        for loc in LOCALES:
            missing = sorted(stage_keys - set(resources[loc]))
            if missing:
                issues.append(f"Stage name keys missing in resource_{loc}.json ({len(missing)}): {missing[:5]}...")

    # --- Plants / Zombies name keys ---
    for resource_file, prefix in (("Plants.json", "plant_"), ("Zombies.json", "zombie_")):
        path = ROOT / "assets/resources" / resource_file
        if not path.exists():
            continue
        items = json.loads(path.read_text(encoding="utf-8"))
        name_keys = {item["name"] for item in items if isinstance(item.get("name"), str) and item["name"].startswith(prefix)}
        missing_by_loc = {}
        for loc in LOCALES:
            missing = sorted(name_keys - set(resources[loc]))
            if missing:
                missing_by_loc[loc] = len(missing)
        if missing_by_loc:
            issues.append(f"{resource_file} name keys missing in resources: {missing_by_loc}")
        else:
            print(f"{resource_file}: all {len(name_keys)} name keys present in resource JSON")

    # --- Star challenge coverage ---
    repo = ROOT / "lib/data/repository/challenge_repository.dart"
    if repo.exists():
        classes = re.findall(r"objClass: '([^']+)'", repo.read_text(encoding="utf-8"))
        sc_issues = []
        for loc in LOCALES:
            missing_title = [c for c in classes if f"starChallenge_{c}_title" not in resources[loc]]
            missing_desc = [c for c in classes if f"starChallenge_{c}_desc" not in resources[loc]]
            if missing_title or missing_desc:
                sc_issues.append(f"{loc}: title={len(missing_title)} desc={len(missing_desc)}")
        if sc_issues:
            issues.extend(sc_issues)
        else:
            print(f"Star challenges: all {len(classes)} covered in resource JSON")

    # --- report.txt ---
    report = ROOT / "report.txt"
    if report.exists():
        content = report.read_text(encoding="utf-8").strip()
        untranslated = 0
        if content:
            try:
                parsed = json.loads(content)
                if isinstance(parsed, dict):
                    untranslated = sum(len(v) for v in parsed.values() if isinstance(v, list))
            except json.JSONDecodeError:
                untranslated = len(content.splitlines())
        if untranslated:
            warnings.append(f"report.txt lists {untranslated} untranslated ARB message(s)")
        else:
            print("\nreport.txt: no untranslated ARB messages")

    print("\n" + "=" * 60)
    if warnings:
        print(f"Warnings ({len(warnings)}):")
        for w in warnings:
            print(f"  - {w}")
    if issues:
        print(f"ISSUES ({len(issues)}):")
        for i in issues:
            print(f"  - {i}")
        return 1
    print("OK: assets/l10n/ integrity check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
