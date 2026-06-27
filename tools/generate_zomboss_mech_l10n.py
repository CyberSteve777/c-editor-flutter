#!/usr/bin/env python3
"""Generate zomboss mech localization keys for assets/l10n/resource_*.json.

Key formats (per mech catalog ``id`` from ZombossMechs.json):
  {id}_variation_{variation}
  {id}_action_{objclass}
  {id}_action_impl_{alias}
  {id}_action_{objclass}_field_{fieldName}   (nested: Parent_Child)

Default values:
  variation — humanized variation id (strip zombossmech_ prefix)
  action — first implementation alias in the action group
  action_impl — implementation alias
  field — humanized field name (CamelCase → words)
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
MECHS_PATH = ROOT / "assets/resources/ZombossMechs.json"
RESOURCE_DIR = ROOT / "assets/l10n"


def humanize_identifier(name: str) -> str:
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", name)
    return re.sub(r"_+", " ", s).strip()


def variation_default(variation: str) -> str:
    v = variation
    if v.startswith("vacation_zombossmech_"):
        v = v[len("vacation_zombossmech_") :] + "_vacation"
    if v.startswith("zombossmech_"):
        v = v[len("zombossmech_") :]
    return humanize_identifier(v)


def iter_field_names(fields: list[dict[str, Any]], prefix: str = "") -> list[str]:
    names: list[str] = []
    for field in fields:
        name = field.get("name") or ""
        if not name or name.startswith("#"):
            continue
        full = f"{prefix}_{name}" if prefix else name
        names.append(full)
        if field.get("type") == "object":
            nested = field.get("fields")
            if isinstance(nested, list):
                names.extend(iter_field_names(nested, full))
    return names


def collect_entries(mechs: list[dict[str, Any]]) -> dict[str, str]:
    out: dict[str, str] = {}
    for mech in mechs:
        mech_id = mech.get("id") or ""
        if not mech_id:
            continue

        for variation in mech.get("variations") or []:
            v = str(variation)
            key = f"{mech_id}_variation_{v}"
            out.setdefault(key, variation_default(v))

        for action in mech.get("actions") or []:
            objclass = action.get("objclass") or ""
            if not objclass:
                continue
            action_key = f"{mech_id}_action_{objclass}"
            implementations = action.get("implementations") or {}
            if isinstance(implementations, dict) and implementations:
                default_action = next(iter(implementations.keys()))
            else:
                default_action = humanize_identifier(
                    objclass.removeprefix("Zomboss")
                    .removesuffix("ActionDefinition")
                    .removesuffix("ActionHandler")
                )
            out.setdefault(action_key, default_action)

            if isinstance(implementations, dict):
                for impl_alias in implementations:
                    impl_key = f"{mech_id}_action_impl_{impl_alias}"
                    out.setdefault(impl_key, str(impl_alias))

            for field_name in iter_field_names(action.get("fields") or []):
                field_key = f"{mech_id}_action_{objclass}_field_{field_name}"
                out.setdefault(field_key, humanize_identifier(field_name))

    return out


def load_json(path: Path) -> dict[str, str]:
    with path.open(encoding="utf-8") as f:
        data = json.load(f)
    return {str(k): str(v) for k, v in data.items()}


def save_json(path: Path, data: dict[str, str]) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def merge_resources(generated: dict[str, str]) -> None:
    en_path = RESOURCE_DIR / "resource_en.json"
    en_existing = load_json(en_path)

    added = 0
    for locale in ("en", "ru", "zh"):
        path = RESOURCE_DIR / f"resource_{locale}.json"
        existing = load_json(path)
        for key, default_en in generated.items():
            if key in existing:
                continue
            if locale == "en":
                existing[key] = default_en
            else:
                # Seed ru/zh from English until manually translated.
                existing[key] = en_existing.get(key, default_en)
            added += 1
        save_json(path, dict(sorted(existing.items(), key=lambda x: x[0].lower())))
        print(f"{path.name}: {len(existing)} keys total")

    print(f"Added {added // 3} new keys per locale ({added} writes)")


def main() -> None:
    with MECHS_PATH.open(encoding="utf-8") as f:
        mechs = json.load(f)
    if not isinstance(mechs, list):
        raise SystemExit("ZombossMechs.json must be a JSON array")

    generated = collect_entries(mechs)
    print(f"Generated {len(generated)} localization entries from {len(mechs)} mechs")

    out_path = ROOT / "tools" / "zomboss_mech_l10n_keys.json"
    with out_path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(generated, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"Wrote preview to {out_path.relative_to(ROOT)}")

    merge_resources(generated)


if __name__ == "__main__":
    main()
