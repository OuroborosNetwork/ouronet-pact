#!/usr/bin/env python3
"""Embed module-owned interfaces from 0_Interfaces into module .pact files."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# ── Stage 01 ────────────────────────────────────────────────────────────────

STAGE01_CORE_IFACE = ROOT / "1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact"
STAGE01_TALOS_IFACE = ROOT / "1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact"
STAGE01_CORE = ROOT / "1_SOVEREIGN/STAGE_01/2_Core"
STAGE01_TALOS = ROOT / "1_SOVEREIGN/STAGE_01/3_Talos"

KEEP_S01_CORE = {
    "OuronetPolicyV1",
    "IgnisCollectorV1",
    "IgnisCollectorV2",
    "OuronetInfoV1",
    "BrandingV1",
    "BrandingUsagePrimaryV1",
    "BrandingUsageTertiaryV1",
    "DpofUdcV1",
    "AutostakeV1",
    "SwapperV2",
    "PythiaV1",
    "PythiaV2",
}

S01_CORE_MAP: dict[str, str] = {
    "OuronetDalosV1": "01_DALOS.pact",
    "DalosInfoV1": "03_INFO-ZERO.pact",
    "DemiourgosPactTrueFungibleV1": "05_DPTF.pact",
    "DemiourgosPactOrtoFungibleV1": "06_DPOF.pact",
    "DemiourgosPactOrtoFungibleV2": "06_DPOF.pact",
    "EliteV1": "07_ELITE.pact",
    "AutostakeV2": "08_ATS.pact",
    "AutostakeComputerV1": "08_ATS.pact",
    "TrueFungibleTransferV1": "09_TFT.pact",
    "AutostakeUsageV1": "10_ATSU.pact",
    "VestingV1": "11_VST.pact",
    "StoaLiquidStakingV1": "12_LIQUID.pact",
    "OuroborosV1": "13_OUROBOROS.pact",
    "SwapTracerV1": "14_SWPT.pact",
    "SwapperV3": "15_SWP.pact",
    "SwapperIssueV3": "16_SWPI.pact",
    "SwapperLiquidityV1": "17_SWPL.pact",
    "BrandingUsageSecondaryV1": "18_SWPLC.pact",
    "SwapperLiquidityClientV1": "18_SWPLC.pact",
    "SwapperUsageV2": "19_SWPU.pact",
    "SwapperMtxV3": "20_MTX-SWP.pact",
    "DemiourgosPactMetaFungibleV6": "00_DPMF.pact",
}

KEEP_S01_TALOS = {
    "TalosStageOne_ClientFourV1",
    "TalosStageOne_ClientFourV2",
    "TalosStageOne_ClientFourV3",
}

S01_TALOS_MAP: dict[str, str] = {
    "TalosStageOne_AdminV1": "01_TS01-A.pact",
    "TalosStageOne_ClientOneV1": "02_TS01-C1.pact",
    "TalosStageOne_ClientOneV2": "02_TS01-C1.pact",
    "TalosStageOne_ClientTwoV1": "03_TS01-C2.pact",
    "TalosStageOne_ClientThreeV3": "04_TS01-C3.pact",
    "TalosStageOne_ClientPactsV3": "05_TS01-P.pact",
}

S01_CORE_HEADER = """;; Stage 01 Core Interface Registry — SHARED + HISTORICAL only.
;; Module-owned latest interfaces live in each 2_Core/*.pact file (deploy with module).
;;
"""

S01_TALOS_HEADER = """;; Stage 01 Talos Interface Registry — HISTORICAL ClientFour V1–V3 only.
;; Latest Talos client interfaces live in each 3_Talos/*.pact file (deploy with module).
;;
"""

# ── Stage 02 ────────────────────────────────────────────────────────────────

STAGE02_CORE_IFACE = ROOT / "1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact"
STAGE02_TALOS_IFACE = ROOT / "1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact"
STAGE02_CORE = ROOT / "1_SOVEREIGN/STAGE_02/2_Core"
STAGE02_TALOS = ROOT / "1_SOVEREIGN/STAGE_02/3_Talos"

# DpdcUdcV1 schemas referenced by every DPDC slice interface signature
KEEP_S02_CORE = {"DpdcUdcV1"}

S02_CORE_MAP: dict[str, str] = {
    "DpdcV1": "01_DPDC/02_DPDC.pact",
    "DpdcCreateV1": "01_DPDC/03_DPDC-C.pact",
    "DpdcIssueV1": "01_DPDC/04_DPDC-I.pact",
    "DpdcRolesV1": "01_DPDC/05_DPDC-R.pact",
    "DpdcManagementV1": "01_DPDC/06_DPDC-MNG.pact",
    "DpdcTransferV1": "01_DPDC/07_DPDC-T.pact",
    "DpdcTransferV2": "01_DPDC/07_DPDC-T.pact",
    "DpdcSetsV1": "01_DPDC/08_DPDC-S.pact",
    "DpdcFragmentsV1": "01_DPDC/09_DPDC-F.pact",
    "DpdcNonceV1": "01_DPDC/10_DPDC-N.pact",
}

KEEP_S02_TALOS: set[str] = set()

S02_TALOS_MAP: dict[str, str] = {
    "TalosStageTwo_DemiPadV1": "03_TS02-DPAD.pact",
    "TalosStageTwo_ClientOneV1": "01_TS02-C1.pact",
    "TalosStageTwo_ClientOneV2": "01_TS02-C1.pact",
    "TalosStageTwo_ClientTwoV1": "02_TS02-C2.pact",
    "TalosStageTwo_ClientTwoV2": "02_TS02-C2.pact",
    "TalosStageTwo_ClientThreeV1": "04_TS02-C3.pact",
}

S02_CORE_HEADER = """;; Stage 02 Core Interface Registry — SHARED schemas only.
;; DpdcUdcV1 types are referenced by all DPDC slice interfaces — keep here.
;; Module-owned latest interfaces live in 2_Core/**/*.pact (deploy with module).
;;
"""

S02_TALOS_HEADER = """;; Stage 02 Talos Interface Registry — HISTORICAL only (none yet).
;; Latest Talos Stage Two client interfaces live in each 3_Talos/*.pact file.
;;
"""


def parse_interfaces(text: str) -> tuple[list[str], dict[str, str]]:
    """Return (ordered names, {interface_name: full_s_expression})."""
    result: dict[str, str] = {}
    order: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        m = re.search(r"\(interface\s+([A-Za-z0-9_|+-]+)", text[i:])
        if not m:
            break
        start = i + m.start()
        name = m.group(1)
        depth = 0
        j = start
        while j < n:
            c = text[j]
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    j += 1
                    break
            j += 1
        block = text[start:j].rstrip()
        result[name] = block
        order.append(name)
        i = j
    return order, result


def module_has_interface(path: Path, name: str) -> bool:
    if not path.exists():
        return False
    return f"(interface {name}" in path.read_text(encoding="utf-8")


def prepend_interfaces(
    module_path: Path,
    blocks: list[str],
    registry_rel: str,
) -> None:
    content = module_path.read_text(encoding="utf-8")
    m = re.search(r"^\(module\s", content, re.MULTILINE)
    if not m:
        print(f"  SKIP {module_path.name}: no (module …) found")
        return
    prefix = content[: m.start()]
    rest = content[m.start() :]
    header_lines: list[str] = []
    if prefix.strip():
        header_lines.append(prefix.rstrip("\n"))
    header_lines.extend(
        [
            ";; Deploy: load THIS file — interface(s) + module ship together.",
            f";; History/shared registry: {registry_rel}",
            ";;",
        ]
    )
    for block in blocks:
        header_lines.append(block)
        header_lines.append(";;")
    new_content = "\n".join(header_lines) + "\n" + rest
    module_path.write_text(new_content, encoding="utf-8")
    print(f"  prepended {len(blocks)} interface(s) -> {module_path.relative_to(ROOT)}")


def rebuild_registry(
    order: list[str],
    parsed: dict[str, str],
    keep_names: set[str],
    header: str,
) -> str:
    ordered = [parsed[name] for name in order if name in keep_names]
    body = "\n".join(ordered)
    if body:
        return header.rstrip() + "\n" + body + "\n"
    return header.rstrip() + "\n"


def migrate_stage(
    label: str,
    iface_path: Path,
    core_dir: Path,
    talos_dir: Path,
    core_map: dict[str, str],
    talos_map: dict[str, str],
    keep_core: set[str],
    keep_talos: set[str],
    core_header: str,
    talos_header: str,
    core_registry_rel: str,
    talos_registry_rel: str,
    dry_run: bool,
    do_core: bool,
    do_talos: bool,
) -> None:
    if do_core and iface_path.exists():
        print(f"=== {label} Core ===")
        text = iface_path.read_text(encoding="utf-8")
        order, parsed = parse_interfaces(text)
        print(f"  interfaces parsed: {len(parsed)}")

        by_module: dict[str, list[str]] = {}
        for iname in order:
            mfile = core_map.get(iname)
            if mfile:
                by_module.setdefault(mfile, []).append(iname)

        for mfile in sorted(by_module.keys()):
            path = core_dir / mfile
            names = by_module[mfile]
            blocks = [parsed[n] for n in names]
            missing = [n for n in names if not module_has_interface(path, n)]
            if not missing:
                print(f"  already embedded: {mfile}")
                continue
            if dry_run:
                print(f"  would prepend to {mfile}: {', '.join(missing)}")
                continue
            prepend_interfaces(path, blocks, core_registry_rel)

        if not dry_run:
            iface_path.write_text(
                rebuild_registry(order, parsed, keep_core, core_header),
                encoding="utf-8",
            )
            print(f"  wrote slim {iface_path.name} ({len(keep_core)} kept)")

    talos_iface = talos_dir.parent / "0_Interfaces" / "03_Talos.pact"
    if do_talos and talos_iface.exists():
        print(f"=== {label} Talos ===")
        text = talos_iface.read_text(encoding="utf-8")
        order, parsed = parse_interfaces(text)
        print(f"  interfaces parsed: {len(parsed)}")

        by_module: dict[str, list[str]] = {}
        for iname in order:
            mfile = talos_map.get(iname)
            if mfile:
                by_module.setdefault(mfile, []).append(iname)

        for mfile in sorted(by_module.keys()):
            path = talos_dir / mfile
            names = by_module[mfile]
            blocks = [parsed[n] for n in names]
            missing = [n for n in names if not module_has_interface(path, n)]
            if not missing:
                print(f"  already embedded: {mfile}")
                continue
            if dry_run:
                print(f"  would prepend to {mfile}: {', '.join(missing)}")
                continue
            prepend_interfaces(path, blocks, talos_registry_rel)

        if not dry_run:
            talos_iface.write_text(
                rebuild_registry(order, parsed, keep_talos, talos_header),
                encoding="utf-8",
            )
            print(f"  wrote slim {talos_iface.name} ({len(keep_talos)} kept)")


def main() -> None:
    dry = "--dry-run" in sys.argv
    stages = sys.argv[1:]
    if not stages or stages[0].startswith("--"):
        stages = ["s01", "s02"]

    if "s01" in stages:
        migrate_stage(
            "Stage 01",
            STAGE01_CORE_IFACE,
            STAGE01_CORE,
            STAGE01_TALOS,
            S01_CORE_MAP,
            S01_TALOS_MAP,
            KEEP_S01_CORE,
            KEEP_S01_TALOS,
            S01_CORE_HEADER,
            S01_TALOS_HEADER,
            "1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact",
            "1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact",
            dry,
            do_core=True,
            do_talos=True,
        )

    if "s02" in stages:
        migrate_stage(
            "Stage 02",
            STAGE02_CORE_IFACE,
            STAGE02_CORE,
            STAGE02_TALOS,
            S02_CORE_MAP,
            S02_TALOS_MAP,
            KEEP_S02_CORE,
            KEEP_S02_TALOS,
            S02_CORE_HEADER,
            S02_TALOS_HEADER,
            "1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact",
            "1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact",
            dry,
            do_core=True,
            do_talos=True,
        )


if __name__ == "__main__":
    main()
