#!/usr/bin/env python3
"""Generate:
1) assets/resources/ZombossMechs.json (mech zombosses, editable metadata)
2) assets/resources/Zombosses.json (non-mech zombosses, resource groups only)
"""

from __future__ import annotations

import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ZOMBOSSES_OLD_PATH = ROOT / "assets/resources/Zombosses_old.json"
ZOMBIE_TYPES_PATH = ROOT / "assets/reference/ZombieTypes.json"
PROPERTY_SHEETS_PATH = ROOT / "assets/reference/PropertySheets.json"
ZOMBIE_ACTIONS_PATH = ROOT / "assets/reference/ZombieActions.json"
MECHS_OUT_PATH = ROOT / "assets/resources/ZombossMechs.json"
NON_MECH_OUT_PATH = ROOT / "assets/resources/Zombosses.json"
ZOMBIE_ICONS_DIR = ROOT / "assets/images/zombies"

RTID_RE = re.compile(r"^RTID\(([^@]+)@")
ZOMBOSS_MECH_PREFIX = "zombossmech_"
UNKNOWN_ICON = "unknown.webp"

# Parameter names whose values are zombie type aliases in game data.
ZOMBIE_TYPE_PARAM_NAMES = {
    "SpawnZombieTypes",
    "SpawnZombieType",
    "SpawnDinoType",
    "ZombieNames",
    "ZombieName",
    "SpiderZombieName",
    "PortalZombieType",
}

QIN_EXTRA_GROUPS = [
    "PlantSeaderris",
    "ZombiePVZ1RobotZombossGroup",
    "PlantFlamelady",
    "FrostbiteIceBlockPlantGroup",
    "UI_MausoleumTunnel",
    "ZombossQinShiHuangGroup",
    "MausoleumAudio",
    "ZombossQinShiHuangAudio",
]

ACTION_TAGS = frozenset({"movement", "spawn", "attack", "special", "retreat"})

# Substrings in action implementation aliases that indicate a phase retreat action.
RETREAT_ALIAS_MARKERS = ("retreat", "coverup", "slowdive")

# One tag per action objclass (movement / spawn / attack / special / retreat).
ACTION_OBJCLASS_TAGS: dict[str, str] = {
    # movement — repositioning without leaving the active phase
    "ZombossWalkActionDefinition": "movement",
    "ZombossJumpActionDefinition": "movement",
    "ZombossBeachDiveActionDefinition": "movement",
    "ZombossRiftBeachDiveActionDefinition": "movement",
    "ZombossDarkWalkActionDefinition": "movement",
    "ZombossDinoWalkActionDefinition": "movement",
    "ZombossHydraWalkActionDefinition": "movement",
    "ZombossSkyCityWalkActionDefinition": "movement",
    "ZombossQigongWalkActionDefinition": "movement",
    "ZombossSteamJumpActionDefinition": "movement",
    "ZombossSteamRandomJumpActionDefinition": "movement",
    "ZombossQigongJumpActionDefinition": "movement",
    # retreat — leaving a battle phase (RetreatAction / cover-up / slow dive)
    "ZombossRenaiRetreatActionHandler": "retreat",
    "ZombossCoverUpActionDefinition": "retreat",
    "ZombossHelmLostActionDefinition": "retreat",
    "ZombossSteamRestActionDefinition": "retreat",
    # spawn — zombies, minions, or grid objects
    "ZombossSpawnActionDefinition": "spawn",
    "ZombossDarkSpawnActionDefinition": "spawn",
    "ZombossSummonActionDefinition": "spawn",
    "ZombossSpawnPortalActionDefinition": "spawn",
    "ZombossSpawnDinoActionDefinition": "spawn",
    "ZombossSpawnGlacierColumnActionDefinition": "spawn",
    "ZombossSpawnShieldActionDefinition": "spawn",
    "ZombossRobotSpawnNormalZombieActionDefinition": "spawn",
    "ZombossRobotAirDropZombieActionDefinition": "spawn",
    "ZombossSteamSpawnActionDefinition": "spawn",
    "ZombossSteamTrainSpawnActionDefinition": "spawn",
    "ZombossSkyCitySpawnActionDefinition": "spawn",
    "ZombossHydraSpawnActionDefinition": "spawn",
    "ZombossQigongSpawnActionDefinition": "spawn",
    "ZombossSummonDropActionDefinition": "spawn",
    "ZombossSummonStatueActionDefinition": "spawn",
    "ZombossDropZombieActionDefinition": "spawn",
    "ZombossDropSandbagActionDefinition": "attack",
    "ZombieDropZombiesOnBoardActionDefinition": "spawn",
    "ZombossEightiesDropSpeakerActionDefinition": "spawn",
    "ZombossSharkMinionAttackActionDefinition": "spawn",
    # attack — direct offense against plants (rush, projectiles, breath, etc.)
    "ZombossFireActionDefinition": "attack",
    "ZombossRushActionDefinition": "attack",
    "ZombossSteamRushActionDefinition": "attack",
    "ZombossDarkFireBreathActionDefinition": "attack",
    "ZombossDarkLobFireballsActionDefinition": "attack",
    "ZombossFanPullActionDefinition": "attack",
    "ZombossDinoLaserActionDefinition": "attack",
    "ZombossHydraLobFireballsActionDefinition": "attack",
    "ZombossHydraPullActionDefinition": "attack",
    "ZombossHydraSprayActionDefinition": "attack",
    "ZombossFreezingWindRowActionDefinition": "special",
    "ZombossImpCannonActionDefinition": "spawn",
    "ZombossSteamImpCannonActionDefinition": "spawn",
    "ZombossRobotSpitBallActionDefinition": "attack",
    "ZombossRobotThrowCarActionDefinition": "attack",
    "ZombossRobotTrampleActionDefinition": "attack",
    "ZombossSkyCityAttackNearByActionDefinition": "attack",
    "ZombossSkyCityBarrageActionDefinition": "attack",
    "ZombossSkyCityLineShootActionDefinition": "attack",
    "ZombossSkyCityRushDownActionDefinition": "attack",
    "ZombossSkyCitySandstormActionDefinition": "attack",
    "ZombossSkyCityThrowAircraftActionDefinition": "attack",
    "ZombossSteamFireActionDefinition": "attack",
    "ZombossSteamThrowActionDefinition": "attack",
    "ZombossQigongAttackActionDefinition": "attack",
    "ZombossQigongPullActionDefinition": "attack",
    "ZombossRenaiBarrageActionDefinition": "attack",
    "ZombossEightiesFireSpeakerRayActionDefinition": "attack",
    # special — mechanics that are not pure move / spawn / direct attack
    "ZombossEightiesSwapJamActionDefinition": "special",
    "ZombossCoverUpActionDefinition": "special",
    "ZombossRenaiHamletActionDefinition": "special",
    "ZombossRenaiRomioJulietActionDefinition": "special",
    "ZombossRenaiTheMerchantOfVeniceActionDefinition": "special",
    "ZombossQigongCureActionDefinition": "special",
    "ZombossQigongNirvanaActionDefinition": "special",
    "ZombossQigongSurgeActionDefinition": "special",
}


def is_excluded_teamboss(
    zombie_class: Any = None,
    type_name: Any = None,
    icon_key: Any = None,
) -> bool:
    """Team boss is a zomboss variant not supported by the editor."""
    if isinstance(zombie_class, str) and "TeamBoss" in zombie_class:
        return True
    if isinstance(type_name, str) and "teamboss" in type_name.lower():
        return True
    if isinstance(icon_key, str) and "teamboss" in icon_key.lower():
        return True
    return False


def is_retreat_action_alias(alias: str) -> bool:
    lower = alias.lower()
    return any(marker in lower for marker in RETREAT_ALIAS_MARKERS)


def implementations_are_retreat_only(
    implementations: dict[str, dict[str, Any]],
    retreat_aliases: set[str],
) -> bool:
    if not implementations:
        return False
    for alias in implementations:
        if alias in retreat_aliases or is_retreat_action_alias(alias):
            continue
        return False
    return True


def classify_action_tag(
    objclass: str,
    implementations: dict[str, dict[str, Any]] | None = None,
    retreat_aliases: set[str] | None = None,
) -> str:
    """Return movement | spawn | attack | special | retreat for a zomboss action group."""
    retreat_aliases = retreat_aliases or set()
    if implementations and implementations_are_retreat_only(
        implementations, retreat_aliases
    ):
        return "retreat"

    if objclass in ACTION_OBJCLASS_TAGS:
        return ACTION_OBJCLASS_TAGS[objclass]

    lower = objclass.lower()
    if objclass == "UnknownAction":
        return "special"

    # spawn before generic "drop" / "attack" substring checks on compound names
    spawn_markers = (
        "spawn",
        "summon",
        "portal",
        "airdrop",
        "dropzombie",
        "dropzombies",
        "dropsandbag",
    )
    if any(marker in lower for marker in spawn_markers):
        return "spawn"
    if "drop" in lower and "fire" not in lower:
        return "spawn"

    attack_markers = (
        "fire",
        "rush",
        "laser",
        "lob",
        "breath",
        "pull",
        "shoot",
        "barrage",
        "trample",
        "throw",
        "spit",
        "cannon",
        "wind",
        "spray",
        "attack",
        "ray",
        "sandstorm",
        "imp",
        "line",
    )
    if any(marker in lower for marker in attack_markers):
        return "attack"

    retreat_markers = ("retreat", "coverup", "helmlost", "steamrest")
    if any(marker in lower for marker in retreat_markers):
        return "retreat"

    movement_markers = ("walk", "jump", "dive", "rest", "idle")
    if any(marker in lower for marker in movement_markers):
        return "movement"

    return "special"


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def load_mech_seed() -> list[dict[str, Any]]:
    """Load icon/group seed data (legacy Zombosses_old.json or current ZombossMechs.json)."""
    if ZOMBOSSES_OLD_PATH.exists():
        data = load_json(ZOMBOSSES_OLD_PATH)
        if isinstance(data, list):
            return data

    if not MECHS_OUT_PATH.exists():
        raise FileNotFoundError(
            f"Neither {ZOMBOSSES_OLD_PATH} nor {MECHS_OUT_PATH} exists; "
            "cannot determine mech group icons."
        )

    existing = load_json(MECHS_OUT_PATH)
    if not isinstance(existing, list):
        raise ValueError(f"Expected array in {MECHS_OUT_PATH}")

    seed: list[dict[str, Any]] = []
    for entry in existing:
        if not isinstance(entry, dict):
            continue
        icon = entry.get("icon")
        variations = entry.get("variations")
        if not isinstance(icon, str) or not isinstance(variations, list) or not variations:
            continue
        icon_key = icon.rsplit(".", 1)[0]
        if is_excluded_teamboss(icon_key=icon_key):
            continue
        base_id = icon_key if icon_key in variations else str(variations[0])
        seed.append(
            {
                "id": base_id,
                "icon": icon,
                "defaultPhaseCount": entry.get("defaultPhaseCount", 3),
            }
        )
    return seed


def parse_rtid(value: Any) -> tuple[str | None, str | None]:
    if not isinstance(value, str):
        return None, None
    match = RTID_RE.match(value)
    if not match:
        return None, None
    alias = match.group(1)
    source = value.split("@", 1)[1].rstrip(")")
    return alias, source


def semantic_type(name: str, value: Any) -> str | None:
    if name in ZOMBIE_TYPE_PARAM_NAMES:
        if isinstance(value, list):
            return "List<zombieType>"
        if isinstance(value, str):
            return "zombieType"
    if name.endswith("ZombieTypes") or name.endswith("ZombieNames"):
        if isinstance(value, list):
            return "List<zombieType>"
        if isinstance(value, str):
            return "zombieType"
    return None


def primitive_type(value: Any) -> str:
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int) and not isinstance(value, bool):
        return "int"
    if isinstance(value, float):
        return "float"
    if isinstance(value, str):
        if value.startswith("RTID("):
            return "rtid"
        return "string"
    return "dynamic"


def list_element_type(items: list[Any]) -> str:
    if not items:
        return "dynamic"
    types = {primitive_type(item) for item in items}
    if len(types) == 1:
        return next(iter(types))
    if types.issubset({"int", "float"}):
        return "num"
    return "dynamic"


def describe_parameter(name: str, value: Any) -> dict[str, Any]:
    override = semantic_type(name, value)
    if override is not None:
        return {"name": name, "type": override, "default": value}

    if isinstance(value, list):
        return {
            "name": name,
            "type": f"List<{list_element_type(value)}>",
            "default": value,
        }

    if isinstance(value, dict):
        fields = [
            describe_parameter(field_name, field_value)
            for field_name, field_value in value.items()
            if not field_name.startswith("#")
        ]
        return {
            "name": name,
            "type": "object",
            "fields": fields,
            "default": value,
        }

    return {"name": name, "type": primitive_type(value), "default": value}


def parameters_from_objdata(objdata: dict[str, Any]) -> list[dict[str, Any]]:
    return [
        describe_parameter(key, value)
        for key, value in objdata.items()
        if not key.startswith("#")
    ]


def merge_fields_from_implementations(
    implementations: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    """Build field schema from union of keys across implementation objdata maps."""
    field_map: dict[str, dict[str, Any]] = {}
    for values in implementations.values():
        if not isinstance(values, dict):
            continue
        for key, value in values.items():
            if key.startswith("#"):
                continue
            spec = describe_parameter(key, value)
            if key not in field_map:
                field_map[key] = spec
    return [field_map[name] for name in sorted(field_map)]


def is_valid_action_implementation(objclass: str, values: dict[str, Any]) -> bool:
    """Reject known-broken action parameter sets from the game reference data."""
    if objclass == "ZombieDropZombiesOnBoardActionDefinition":
        # Legacy data uses "Count" instead of MinSpawn/MaxSpawn; the editor only
        # supports the MinSpawn/MaxSpawn form (see ZombieActions.json canonical defs).
        if "Count" in values or "count" in values:
            return False
        if "MinSpawn" not in values or "MaxSpawn" not in values:
            return False
    return True


def build_zombie_type_map(
    zombie_types_doc: dict[str, Any],
) -> tuple[dict[str, dict[str, Any]], dict[str, str]]:
    """Map TypeName -> info, and alias -> TypeName for alias/type mismatches."""
    result: dict[str, dict[str, Any]] = {}
    alias_to_type_name: dict[str, str] = {}
    for entry in zombie_types_doc.get("objects", []):
        if entry.get("objclass") != "ZombieType":
            continue
        objdata = entry.get("objdata") or {}
        type_name = objdata.get("TypeName")
        if not isinstance(type_name, str):
            continue
        aliases = [a for a in (entry.get("aliases") or []) if isinstance(a, str)]
        prop_alias, prop_source = parse_rtid(objdata.get("Properties"))
        result[type_name] = {
            "typeName": type_name,
            "aliases": aliases,
            "zombieClass": objdata.get("ZombieClass"),
            "propertiesAlias": prop_alias,
            "propertiesSource": prop_source,
            "resourceGroups": list(objdata.get("ResourceGroups") or []),
            "objdata": objdata,
        }
        for alias in aliases:
            alias_to_type_name[alias] = type_name
    return result, alias_to_type_name


def resolve_type_name(
    identifier: str,
    zombie_type_map: dict[str, dict[str, Any]],
    alias_to_type_name: dict[str, str],
) -> str | None:
    if identifier in zombie_type_map:
        return identifier
    return alias_to_type_name.get(identifier)


def type_matches_prefix(
    type_name: str,
    aliases: list[str],
    prefix: str,
) -> bool:
    if type_name.startswith(prefix):
        return True
    return any(alias.startswith(prefix) for alias in aliases)


def is_zomboss_mech_type(type_name: str, aliases: list[str]) -> bool:
    return type_matches_prefix(type_name, aliases, ZOMBOSS_MECH_PREFIX)


def build_property_sheet_map(property_sheets_doc: dict[str, Any]) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for entry in property_sheets_doc.get("objects", []):
        aliases = entry.get("aliases") or []
        objclass = entry.get("objclass")
        objdata = entry.get("objdata") or {}
        for alias in aliases:
            if isinstance(alias, str):
                result[alias] = {"objclass": objclass, "objdata": objdata}
    return result


def build_action_map(zombie_actions_doc: dict[str, dict[str, Any]]) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for entry in zombie_actions_doc.get("objects", []):
        aliases = entry.get("aliases") or []
        objclass = entry.get("objclass")
        objdata = entry.get("objdata") or {}
        if not aliases or not objclass:
            continue
        for alias in aliases:
            if isinstance(alias, str):
                result[alias] = {"objclass": objclass, "objdata": objdata}
    return result


def build_objclass_section(
    objclass: str,
    implementations: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    sorted_impls = dict(sorted(implementations.items()))
    return {
        "objclass": objclass,
        "fields": merge_fields_from_implementations(sorted_impls),
        "implementations": sorted_impls,
    }


def build_action_objclass_section(
    objclass: str,
    implementations: dict[str, dict[str, Any]],
    retreat_aliases: set[str],
) -> dict[str, Any]:
    section = build_objclass_section(objclass, implementations)
    section["tag"] = classify_action_tag(objclass, implementations, retreat_aliases)
    return section


def build_variations(
    icon_key: str,
    seed_ids: list[str],
    zombie_type_map: dict[str, dict[str, Any]],
    alias_to_type_name: dict[str, str],
) -> list[str]:
    variations: set[str] = set()
    for sid in seed_ids:
        resolved = resolve_type_name(sid, zombie_type_map, alias_to_type_name)
        if resolved:
            variations.add(resolved)
    for type_name, info in zombie_type_map.items():
        aliases = info.get("aliases") or []
        if type_matches_prefix(type_name, aliases, icon_key):
            variations.add(type_name)
    if icon_key == "zombossmech_pvz1_robot":
        variations.discard("zombossmech_pvz1_robot_1_vacation")
    return sorted(variations)


def filter_variations_for_class(
    variation_ids: list[str],
    zombie_class: str,
    zombie_type_map: dict[str, dict[str, Any]],
) -> list[str]:
    return sorted(
        vid
        for vid in variation_ids
        if zombie_type_map.get(vid, {}).get("zombieClass") == zombie_class
    )


def resolve_base_mech_id(icon_key: str, variation_ids: list[str]) -> str | None:
    if icon_key in variation_ids:
        return icon_key
    normal_id = f"{icon_key}_normal"
    if normal_id in variation_ids:
        return normal_id
    return variation_ids[0] if variation_ids else None


def pick_editable_instance(variation_ids: list[str], zombie_type_map: dict[str, dict[str, Any]]) -> str:
    candidates = sorted(
        vid
        for vid in variation_ids
        if zombie_type_map.get(vid, {}).get("propertiesSource") == "CurrentLevel"
    )
    if not candidates:
        return "none"
    memo = [v for v in candidates if v.endswith("_memo")]
    if memo:
        return memo[0]
    return candidates[0]


def resolve_editable_instance_props_name(
    editable_instance: str,
    zombie_type_map: dict[str, dict[str, Any]],
) -> str:
    """RTID alias from ZombieTypes Properties for the editable variation."""
    if editable_instance == "none":
        return ""
    info = zombie_type_map.get(editable_instance)
    if not info:
        return ""
    alias = info.get("propertiesAlias")
    return alias if isinstance(alias, str) else ""


def collect_property_implementations(
    variation_ids: list[str],
    zombie_type_map: dict[str, dict[str, Any]],
    property_sheet_map: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    implementations: list[dict[str, Any]] = []
    seen: set[str] = set()
    for variation_id in variation_ids:
        info = zombie_type_map.get(variation_id)
        if not info:
            continue
        prop_alias = info.get("propertiesAlias")
        if not isinstance(prop_alias, str):
            continue
        if info.get("propertiesSource") != "PropertySheets":
            continue
        if prop_alias in seen:
            continue
        sheet = property_sheet_map.get(prop_alias)
        if not sheet:
            continue
        seen.add(prop_alias)
        implementations.append(
            {
                "id": prop_alias,
                "objclass": sheet["objclass"],
                "values": sheet["objdata"],
            }
        )
    return implementations


def collect_stage_action_aliases(objdata: dict[str, Any]) -> list[str]:
    aliases: list[str] = []
    seen: set[str] = set()

    def add(value: Any) -> None:
        alias, source = parse_rtid(value)
        if not alias or alias in seen:
            return
        if source is not None and source != "ZombieActions":
            return
        seen.add(alias)
        aliases.append(alias)

    for stage in objdata.get("Stages") or []:
        if not isinstance(stage, dict):
            continue
        for action in stage.get("Actions") or []:
            add(action)
        add(stage.get("RetreatAction"))
    return aliases


def collect_referenced_action_aliases(
    property_implementations: list[dict[str, Any]],
) -> set[str]:
    referenced: set[str] = set()
    for prop_impl in property_implementations:
        for alias in collect_stage_action_aliases(prop_impl["values"]):
            referenced.add(alias)
    return referenced


def collect_retreat_action_aliases(
    property_implementations: list[dict[str, Any]],
) -> set[str]:
    """Action aliases referenced as stage RetreatAction RTIDs."""
    retreat: set[str] = set()
    for prop_impl in property_implementations:
        objdata = prop_impl.get("values")
        if not isinstance(objdata, dict):
            continue
        for stage in objdata.get("Stages") or []:
            if not isinstance(stage, dict):
                continue
            alias, source = parse_rtid(stage.get("RetreatAction"))
            if not alias:
                continue
            if source is not None and source != "ZombieActions":
                continue
            retreat.add(alias)
    return retreat


def build_actions_section(
    referenced_aliases: set[str],
    retreat_aliases: set[str],
    action_map: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    """Only action aliases referenced in this mech's property-sheet stages."""
    by_class: dict[str, dict[str, dict[str, Any]]] = defaultdict(dict)
    unknown: dict[str, dict[str, Any]] = {}

    for alias in sorted(referenced_aliases):
        action_def = action_map.get(alias)
        if not action_def:
            unknown[alias] = {}
            continue
        objclass = action_def["objclass"]
        values = action_def["objdata"]
        if not isinstance(values, dict):
            values = {}
        if not is_valid_action_implementation(objclass, values):
            continue
        by_class[objclass][alias] = values

    actions: list[dict[str, Any]] = []
    for objclass in sorted(by_class):
        implementations = by_class[objclass]
        if implementations:
            actions.append(
                build_action_objclass_section(
                    objclass, implementations, retreat_aliases
                )
            )

    if unknown:
        actions.append(
            build_action_objclass_section(
                "UnknownAction",
                dict(sorted(unknown.items())),
                retreat_aliases,
            )
        )

    return actions


def build_properties_section(
    property_implementations: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """Only property-sheet aliases linked to this mech's variations."""
    by_class: dict[str, dict[str, dict[str, Any]]] = defaultdict(dict)
    for impl in property_implementations:
        by_class[impl["objclass"]][impl["id"]] = impl["values"]

    return [
        build_objclass_section(objclass, dict(sorted(implementations.items())))
        for objclass, implementations in sorted(by_class.items())
        if implementations
    ]


def build_mech_output(
    zombosses_old: list[dict[str, Any]],
    zombie_type_map: dict[str, dict[str, Any]],
    alias_to_type_name: dict[str, str],
    property_sheet_map: dict[str, dict[str, Any]],
    action_map: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    grouped_by_icon: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for item in zombosses_old:
        zid = item.get("id")
        icon = item.get("icon")
        if not isinstance(zid, str) or not isinstance(icon, str):
            continue
        icon_key = icon.rsplit(".", 1)[0]
        if is_excluded_teamboss(icon_key=icon_key, type_name=zid):
            continue
        grouped_by_icon[icon_key].append(item)

    output: list[dict[str, Any]] = []
    for icon_key, members in sorted(grouped_by_icon.items()):
        if is_excluded_teamboss(icon_key=icon_key):
            continue
        seed_ids = [m["id"] for m in members if isinstance(m.get("id"), str)]
        variations = build_variations(
            icon_key, seed_ids, zombie_type_map, alias_to_type_name
        )
        base_id = resolve_base_mech_id(icon_key, variations)
        if base_id and base_id not in variations:
            variations.append(base_id)
        variations = sorted(set(variations))

        representative = base_id or (seed_ids[0] if seed_ids else icon_key)
        representative = (
            resolve_type_name(representative, zombie_type_map, alias_to_type_name)
            or representative
        )
        zombie_class = zombie_type_map.get(representative, {}).get("zombieClass")
        if not isinstance(zombie_class, str):
            zombie_class = icon_key
        if is_excluded_teamboss(zombie_class=zombie_class):
            continue

        # Include every zombossmech TypeName for this class (e.g. zombossmech_modern_beach).
        for type_name, info in zombie_type_map.items():
            aliases = info.get("aliases") or []
            if (
                is_zomboss_mech_type(type_name, aliases)
                and info.get("zombieClass") == zombie_class
            ):
                variations.append(type_name)
        variations = filter_variations_for_class(variations, zombie_class, zombie_type_map)
        editable = pick_editable_instance(variations, zombie_type_map)
        editable_props_name = resolve_editable_instance_props_name(
            editable, zombie_type_map
        )
        if editable != "none" and editable not in variations:
            variations.append(editable)
        variations = sorted(set(variations))

        default_phase_count = next(
            (
                int(m["defaultPhaseCount"])
                for m in members
                if m.get("id") == base_id and isinstance(m.get("defaultPhaseCount"), int)
            ),
            None,
        )
        if default_phase_count is None:
            default_phase_count = next(
                (
                    int(m["defaultPhaseCount"])
                    for m in members
                    if isinstance(m.get("defaultPhaseCount"), int)
                ),
                3,
            )

        property_impls = collect_property_implementations(
            variations, zombie_type_map, property_sheet_map
        )
        referenced_actions = collect_referenced_action_aliases(property_impls)
        retreat_actions = collect_retreat_action_aliases(property_impls)
        output.append(
            {
                "id": zombie_class,
                "icon": members[0]["icon"],
                "defaultPhaseCount": default_phase_count,
                "variations": variations,
                "actions": build_actions_section(
                    referenced_actions, retreat_actions, action_map
                ),
                "Properties": build_properties_section(property_impls),
                "editableInstance": editable,
                "editableInstancePropsName": editable_props_name,
            }
        )
    return output


def is_non_mech_zomboss(zombie_class: Any) -> bool:
    if not isinstance(zombie_class, str):
        return False
    if is_excluded_teamboss(zombie_class=zombie_class):
        return False
    return zombie_class.startswith("ZombieZomboss") and "Mech" not in zombie_class


def extra_groups_for_type(type_name: str, zombie_class: str) -> list[str]:
    groups: list[str] = []
    if type_name in {"zomboss_qinshihuang", "zomboss_qinshihuang_ghost"}:
        groups.extend(QIN_EXTRA_GROUPS)
    return groups


def load_zombie_icons() -> set[str]:
    if not ZOMBIE_ICONS_DIR.is_dir():
        return set()
    return {
        path.name
        for path in ZOMBIE_ICONS_DIR.iterdir()
        if path.is_file() and path.suffix.lower() == ".webp"
    }


def resolve_non_mech_icon(
    base_type_name: str,
    variations: list[str],
    available_icons: set[str],
) -> str:
    """Pick icon filename from assets/images/zombies/ for a non-mech zomboss group."""
    seen: set[str] = set()
    for name in (base_type_name, *variations):
        if not isinstance(name, str) or name in seen:
            continue
        seen.add(name)
        icon = f"{name}.webp"
        if icon in available_icons:
            return icon
    return UNKNOWN_ICON


def load_non_mech_overlays() -> dict[str, dict[str, Any]]:
    """Hand-maintained fields preserved across regeneration (e.g. auto-import modules)."""
    if not NON_MECH_OUT_PATH.exists():
        return {}
    data = load_json(NON_MECH_OUT_PATH)
    if not isinstance(data, list):
        return {}
    overlays: dict[str, dict[str, Any]] = {}
    for entry in data:
        if not isinstance(entry, dict):
            continue
        entry_id = entry.get("id")
        if not isinstance(entry_id, str):
            continue
        overlay: dict[str, Any] = {}
        modules = entry.get("modules")
        if isinstance(modules, list) and modules:
            overlay["modules"] = modules
        if overlay:
            overlays[entry_id] = overlay
    return overlays


def build_non_mech_output(
    zombie_type_map: dict[str, dict[str, Any]],
    available_icons: set[str],
    overlays: dict[str, dict[str, Any]] | None = None,
) -> list[dict[str, Any]]:
    by_class: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for info in zombie_type_map.values():
        zombie_class = info.get("zombieClass")
        type_name = info.get("typeName")
        if is_excluded_teamboss(zombie_class=zombie_class, type_name=type_name):
            continue
        if not is_non_mech_zomboss(zombie_class):
            continue
        by_class[zombie_class].append(info)

    output: list[dict[str, Any]] = []
    for zombie_class, infos in sorted(by_class.items()):
        variations = sorted({i["typeName"] for i in infos if isinstance(i.get("typeName"), str)})

        def _base_priority(type_name: str) -> tuple[int, int, str]:
            suffix_rank = 0
            lower = type_name.lower()
            if lower.endswith("_vacation"):
                suffix_rank = 3
            elif lower.endswith("_12th"):
                suffix_rank = 2
            elif lower.endswith("_hard"):
                suffix_rank = 1
            return (suffix_rank, len(type_name), type_name)

        base_info = sorted(
            (i for i in infos if isinstance(i.get("typeName"), str)),
            key=lambda i: _base_priority(i["typeName"]),
        )[0]

        groups: set[str] = set()
        for g in base_info.get("resourceGroups") or []:
            if isinstance(g, str):
                groups.add(g)
        base_type_name = base_info.get("typeName")
        if isinstance(base_type_name, str):
            for g in extra_groups_for_type(base_type_name, zombie_class):
                groups.add(g)

        if zombie_class in {"ZombieZombossQinShiHuang", "ZombieZombossQinShiHuangGhost"}:
            groups = set(QIN_EXTRA_GROUPS)

        entry: dict[str, Any] = {
            "id": zombie_class,
            "icon": resolve_non_mech_icon(
                base_type_name if isinstance(base_type_name, str) else "",
                variations,
                available_icons,
            ),
            "variations": variations,
            "resourceGroups": sorted(groups),
        }
        overlay = (overlays or {}).get(zombie_class)
        if overlay:
            entry.update(overlay)
        output.append(entry)
    return output


def verify_mech_output(mechs: list[dict[str, Any]], zombie_type_map: dict[str, dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for mech in mechs:
        mid = mech["id"]
        editable = mech["editableInstance"]
        zombie_class = mech["id"]
        for vid in mech["variations"]:
            if vid not in zombie_type_map:
                issues.append(f"{mid}: variation '{vid}' missing from ZombieTypes")
            elif zombie_type_map[vid].get("zombieClass") != zombie_class:
                issues.append(
                    f"{mid}: variation '{vid}' has class "
                    f"{zombie_type_map[vid].get('zombieClass')}, expected {zombie_class}"
                )
        props_name = mech.get("editableInstancePropsName", "")
        if editable != "none":
            info = zombie_type_map.get(editable)
            if info is None:
                issues.append(f"{mid}: editable '{editable}' missing from ZombieTypes")
            elif info.get("propertiesSource") != "CurrentLevel":
                issues.append(f"{mid}: editable '{editable}' is not @CurrentLevel")
            elif not props_name:
                issues.append(f"{mid}: editableInstancePropsName is empty")
            elif info.get("propertiesAlias") != props_name:
                issues.append(
                    f"{mid}: editableInstancePropsName '{props_name}' "
                    f"does not match ZombieTypes ({info.get('propertiesAlias')})"
                )
        elif props_name:
            issues.append(
                f"{mid}: editableInstancePropsName set but editableInstance is none"
            )
        for action_group in mech.get("actions") or []:
            objclass = action_group.get("objclass")
            implementations = action_group.get("implementations") or {}
            if not isinstance(implementations, dict):
                issues.append(f"{mid}: actions.implementations must be an object")
                continue
            for alias, values in implementations.items():
                if isinstance(values, dict) and not is_valid_action_implementation(
                    objclass, values
                ):
                    issues.append(
                        f"{mid}: invalid implementation '{alias}' for {objclass}"
                    )
            for field in action_group.get("fields") or []:
                if field.get("name") in {"Count", "count"}:
                    issues.append(f"{mid}: action fields contain invalid key 'Count'")
            tag = action_group.get("tag")
            if tag not in ACTION_TAGS:
                issues.append(
                    f"{mid}: action {objclass} has invalid or missing tag '{tag}'"
                )
    return issues


def main() -> None:
    zombosses_old = load_mech_seed()
    zombie_types_doc = load_json(ZOMBIE_TYPES_PATH)
    property_sheets_doc = load_json(PROPERTY_SHEETS_PATH)
    zombie_actions_doc = load_json(ZOMBIE_ACTIONS_PATH)

    zombie_type_map, alias_to_type_name = build_zombie_type_map(zombie_types_doc)
    property_sheet_map = build_property_sheet_map(property_sheets_doc)
    action_map = build_action_map(zombie_actions_doc)

    mech_out = build_mech_output(
        zombosses_old,
        zombie_type_map,
        alias_to_type_name,
        property_sheet_map,
        action_map,
    )
    issues = verify_mech_output(mech_out, zombie_type_map)
    if issues:
        print("Verification issues:")
        for i in issues:
            print(f"  - {i}")
        raise SystemExit(1)

    non_mech_overlays = load_non_mech_overlays()
    non_mech_out = build_non_mech_output(
        zombie_type_map, load_zombie_icons(), non_mech_overlays
    )

    with MECHS_OUT_PATH.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(mech_out, f, ensure_ascii=False, indent=4)
        f.write("\n")
    with NON_MECH_OUT_PATH.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(non_mech_out, f, ensure_ascii=False, indent=4)
        f.write("\n")

    editable_count = sum(1 for entry in mech_out if entry["editableInstance"] != "none")
    unknown_icon_count = sum(
        1 for entry in non_mech_out if entry.get("icon") == UNKNOWN_ICON
    )
    print(f"Wrote {len(mech_out)} mech groups to {MECHS_OUT_PATH}")
    print(f"Editable instances found: {editable_count}")
    print(f"Wrote {len(non_mech_out)} non-mech zomboss groups to {NON_MECH_OUT_PATH}")
    if unknown_icon_count:
        print(f"Non-mech zombosses without icons: {unknown_icon_count}")


if __name__ == "__main__":
    main()
