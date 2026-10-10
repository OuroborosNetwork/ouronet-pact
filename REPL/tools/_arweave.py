#!/usr/bin/env python3
"""
_arweave.py -- the IPFS -> Arweave URI migration round (Deploy/4_Arweave/).

THIS IS A DATA ROUND, NOT A MODULE ROUND, and that is the first thing to
understand about it. `_purev2..v5.py` emit `(module ...)` bodies, strip
`create-table`, and check dot-pin ordering; NONE of that applies here. Nothing
is redeployed. What ships is ~N transactions of `DPNF|C_UpdateNonces` calls that
rewrite the `uri-primary` / `uri-secondary` fields of already-minted nonce rows.
So this tool is a sibling of `Deploy/3_Assets/`, not of `Deploy/PureVn/`, and it
is numbered in that family.

WHY `C_UpdateNonces` AND NOT `C_UpdateNonceURI`
  `C_UpdateNonceURI` is the entrypoint whose NAME matches the task, and it is the
  wrong one at this scale. Measured, 2026-10-08, `env-gasmodel "table"` against
  the `CNF-98c486052a51` fixture:

      DPNF|C_UpdateNonceURI    8,600 gas/nonce   17.0 IGNIS/nonce  (tier-...setup, flat per call)
      DPNF|C_UpdateNonces      2,334 gas/nonce    1.0 IGNIS/nonce  (tier-smallest, x count)

  3.7x the gas and 17x the IGNIS, because the single-field op pays the whole
  capability + Talos + IGNIS-collection overhead once PER NONCE while the bulk op
  pays it once per CALL. Over the round that is the difference between ~79
  transactions / ~265,000 IGNIS and ~22 / ~15,600. `URCi_UpdateNonces` is
  `count * UC_IgnisLeg "tier-smallest"` = `count * 1.0`; `URCi_UpdateNonceField`
  is a flat 17.0 and is charged per invocation.

  The cost of the bulk op is that it takes a WHOLE `DPDC|NonceData` row, not a URI
  field -- so a naive use of it retypes `name` / `description` / `meta-data` /
  royalties by hand and silently destroys whatever it gets wrong. It is used here
  through a READ-OVERLAY instead: the emitted lambda reads the live row with
  `UR_NativeNonceData` and replaces exactly the two URI keys, so every other field
  is carried across by the chain rather than by this tool. Verified in the same
  measurement -- `name` survived a bulk URI write unchanged.

WHAT IS OUT OF SCOPE, AND THE ONE THAT IS NOT A CHOICE
  1. THE RGB BUNNY -- excluded by owner instruction, and it needs no migration:
     KBN set-class 1 ("Bunny RGB Set") has been on Arweave since 2026-10-02
     (`O8Qy9Lv4...` / `C0PgEGQd...`, baked into `KBunnies.A_BunnyRGBSet`). It is
     also the only in-family row addressed as a SET-CLASS (`nost=false`) rather
     than a nonce, so excluding it drops a shape as well as a row.
  2. MINTED NFT SET INSTANCES -- excluded BY THE CHAIN, not by us.
     `DPDC-N.UEV_NotSetInstance` (DPDC Audit #12Hc) enforces, for `son=false` and
     `nost=true`, that `UR_NonceClass id son nonce` is 0. A nonce that is a minted
     Set instance therefore CANNOT have its URI changed by any entrypoint in the
     module, now or ever -- the composition record is deliberately frozen at Make.
     Every batch this tool emits carries a precondition read for exactly this, and
     `--check` refuses a plan that cannot state the expected answer.

THE LINK GRAMMAR IS RE-DERIVED FROM THE MINTER SOURCES, NOT TRUSTED
  The migration has to address the right nonces, and the only offline evidence
  that it does is that the OLD link this tool computes for a nonce equals the link
  the minter would have written there. So the four `UC_*Link` grammars are ported
  below, byte for byte including their padding quirks, and `--check` recomputes
  the gateway constant out of the sources rather than hardcoding it.

  Porting them surfaced a defect that predates this round -- see PADDING_ANOMALY.
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "4_Arweave")
LINKS = os.path.join(DEPLOY, "links", "LINKS.json")
SNAPSHOT = os.path.join(DEPLOY, "links", "CHAIN-URIS.json")
MULTIPACT = os.path.join(DEPLOY, "ROUND.multipact.json")
MULTIPACT_FIXTURE = os.path.join(DEPLOY, "links", "SAMPLE.multipact.json")
# OuronetUI's reader TESTS against a copy of the fixture. A copy with nothing holding it in
# sync is the failure mode this whole round kept finding: the format changes here, the copy
# stays, and the reader's tests go on passing against a format that no longer exists. Checked
# when the sibling checkout is present, skipped when it is not -- the gate must not require
# another repository to exist, but it should notice when it does and has drifted.
UI_FIXTURE_COPY = os.path.join(
    ROOT, "..", "..", "daimons", "OuronetUI",
    "src", "lib", "__tests__", "fixtures", "SAMPLE.multipact.json")
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_arweave.py"

CITIZEN = os.path.join(ROOT, "2_CITIZEN")
BSD = os.path.join(CITIZEN, "2_BloodshedMinter")
NSFR = os.path.join(CITIZEN, "3_NosferatuMinter", "01_NOSFERATU.pact")
KBN = os.path.join(CITIZEN, "4_BunniesMinter", "02_KBunnies.pact")

# ---------------------------------------------------------------------------
# BUDGET -- every number below is MEASURED, and the measurement is reproducible
# ---------------------------------------------------------------------------
# Swept N = 1, 8, 64, 192 of `DPNF|C_UpdateNonces` with the read-overlay lambda,
# `env-gasmodel "table"`, against the `CNF-98c486052a51` fixture (2026-10-08):
#
#     N=1   9,512      N=8   19,403      N=64   98,237      N=192  278,428
#
# which is linear to within 12 gas over a 192x range:
#
#     gas(N) = 8,104 + 1,408 N
#
# Repeated with the fixture's nonce 3 inflated to a realistic Bloodshed row
# (name "Bloodshed Legendary #12345", its description, and a 9-key meta-data
# object): N=64 cost 107,895, i.e. +151 gas per row. The read-overlay reads the
# WHOLE row, so its cost tracks row size, and Bloodshed is 12,928 of the 15,586
# rows in scope. The fat figure is therefore the one used.
GAS_FIXED = 8_104
GAS_PER_NONCE = 1_559          # 1,408 thin + 151 for a realistic metadata row
# StoaChain's per-transaction limit is 2.00M. A data round is exec-dominated, not
# size-dominated: 893 rows is ~148 KB, and `95,225 x (KB/256)^7` charges about
# 1,000 gas for that -- four orders of magnitude under the exec cost. So the cap
# that binds is exec, and this budget leaves 30% for the fact that GAS_PER_NONCE
# is an average.
#
# IF THE WALLET'S SIMULATION DISAGREES, CHANGE THIS ONE NUMBER AND RE-RUN --write.
# It is the only thing that sets the batch size.
# THE BUDGET IS A TOTAL, AND THE TOTAL HAS TWO PARTS. Owner instruction 2026-10-08:
# cap each transaction at about 1.8M gas. Budgeting 1.8M of EXEC would overshoot,
# because a transaction is also charged for its SIZE, and that charge grows as the
# SEVENTH POWER of the bytes (StoicSyntax §10.2 / CLAUDE.md, calibrated from the
# wallet's deploy editor: 3x256KB = ~285,675 total, 1x768KB = ~202,525,154):
#
#     gas_size(S) ~= 95_225 * (S_KB / 256) ** 7
#
# HONEST ABOUT THE MODEL: those calibration points are for MODULE DEPLOY payloads.
# Whether chainweb charges a non-deploy `exec` payload by the same curve is NOT
# something this repository has measured, so the figure is used as a CONSERVATIVE
# reserve rather than a fact -- it can only make batches smaller than necessary. The
# emitted-file check below is what actually holds the line, and it is fatal.
GAS_TOTAL_CAP = 1_800_000
GAS_SIZE_K = 95_225
GAS_SIZE_REF_KB = 256.0
GAS_SIZE_EXP = 7
# Measured over the 2026-10-08 emission: 892 rows -> 200,062 bytes and 440 rows ->
# 102,604 bytes give 215.6 bytes/row on a ~7,750-byte header. Rounded UP to 240,
# because the placeholder manifest txid is 38 characters and a real Arweave txid is
# 43 -- two links a row, so real links are ~10 bytes/row FATTER than what the
# planner currently sees. A budget calibrated on the draft would be wrong on the
# only emission that gets signed.
BYTES_PER_ROW = 240
HEADER_RESERVE = 9_000


def gas_size(nbytes):
    """The size component of a transaction's gas, per the seventh-power rule."""
    return GAS_SIZE_K * ((nbytes / 1024.0) / GAS_SIZE_REF_KB) ** GAS_SIZE_EXP


def gas_total(rows, nbytes):
    """Exec + size, which is what the 2.00M block limit and the 1.8M cap apply to."""
    return GAS_FIXED + GAS_PER_NONCE * rows + gas_size(nbytes)


MAXBYTES = 320_000

IGNIS_PER_NONCE = 1.0   # URCi_UpdateNonces = count * UC_IgnisLeg "tier-smallest"

# ---------------------------------------------------------------------------
# THE GATEWAY CONSTANT -- read out of the sources, never hardcoded
# ---------------------------------------------------------------------------
GW_RE = re.compile(r'"(https://ipfs\.io/ipfs/[A-Za-z0-9]+/)"')


def read(path):
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def snapshot():
    """links/CHAIN-URIS.json -- the recorded live URIs, and the source of truth.

    WHY A SNAPSHOT AND NOT THE MINTER ARITHMETIC. This tool used to DERIVE each old
    link by porting the `UC_*Link` functions. Measured against mainnet on 2026-10-08
    that port was wrong on 13,060 of 15,548 rows -- 84%:

      * every DHB `uri-secondary` is `.png` on chain; the port hardcoded `.jpg`
        (12,928 rows), and
      * the `padding anomaly` the port faithfully reproduced DOES NOT EXIST. The
        chain holds `E_48.jpg` / `R_72.jpg` / `C_144.jpg`; the port produced
        `E_048` / `R_072` / `C_00144` (132 rows) and this tool's own README advised
        uploading those names BOTH ways to accommodate a defect that was its own.

    A derived old link that disagrees with the row is the worst available failure:
    the plan stays self-consistent, every structural check passes, and the migration
    writes an Arweave URL for a file that is not the one the nonce actually shows.
    Reading the row removes the entire class -- and removes the un-checkable
    `sequential assumption` about nonce = base + position with it, because a
    snapshot is keyed by the nonce the chain reported.
    """
    if not os.path.exists(SNAPSHOT):
        raise SystemExit(
            "_arweave: links/CHAIN-URIS.json is missing. It is the source of truth "
            "for every old link; regenerate with `python3 REPL/tools/_arweave.py "
            "--record` (needs mainnet access).")
    with open(SNAPSHOT, "r", encoding="utf-8") as fh:
        return json.load(fh)


def gateway():
    """The IPFS prefix every in-scope link starts with, taken from the sources.

    Three files declare it independently (`Bloodshed.IPFS` via 01_BSD-L, plus a
    local `let` in each of NOSFERATU and KBunnies). They agree today. If they ever
    stop agreeing, the migration is addressing two different trees and must be
    re-planned, so disagreement is fatal rather than resolved by precedence.
    """
    found = {}
    for path in (os.path.join(BSD, "01_BSD-L.pact"), NSFR, KBN):
        hits = set(GW_RE.findall(read(path)))
        if len(hits) != 1:
            raise SystemExit(
                f"_arweave: {os.path.relpath(path, ROOT)} declares {len(hits)} IPFS "
                f"gateway constants, expected exactly 1: {sorted(hits)}")
        found[os.path.relpath(path, ROOT)] = hits.pop()
    if len(set(found.values())) != 1:
        raise SystemExit(
            "_arweave: the minters disagree about the IPFS gateway, so no single "
            "migration can be correct:\n  " +
            "\n  ".join(f"{k} -> {v}" for k, v in found.items()))
    gw = next(iter(found.values()))
    # CROSS-CHECK, not a source. The snapshot carries the gateway the CHAIN uses; the
    # minters carry the one their code builds. They must agree -- if they do not, the
    # rows were written by something other than the code in this tree and the whole
    # inventory is suspect.
    snap_gw = snapshot().get("gateway")
    if snap_gw and snap_gw != gw:
        raise SystemExit(
            "_arweave: the minter sources and the recorded chain disagree about the "
            "IPFS gateway:\n  minters -> %s\n  chain   -> %s" % (gw, snap_gw))
    return gw


# ---------------------------------------------------------------------------
# LINK GRAMMAR -- ported from the UC_*Link functions, padding quirks included
# ---------------------------------------------------------------------------
def _t(big):
    """`(if small-or-big "512x512" "FULL")`.

    The Pact parameter is named `small-or-big` and TRUE selects the 512x512, which
    reads backwards and is the kind of thing a port gets wrong silently. Primary =
    true = 512x512, secondary = false = FULL -- the convention every minter follows
    and that Deploy/3_Assets/01_step1.pact states for the Set nonce.
    """
    return "512x512" if big else "FULL"


def kbn_link(gw, nonce, big):
    """KBunnies.UC_IpfsLink -- `{gw}{type}/06_DemiBunnies/{nnnn}.jpg`."""
    n, s = nonce, str(nonce)
    pad = ("000" + s) if n < 10 else ("00" + s) if n < 100 else ("0" + s) if n < 1000 else s
    return f"{gw}{_t(big)}/06_DemiBunnies/{pad}.jpg"


DHN_FOLDER = {"Legendary": "1_Legendary", "Epic": "2_Epic",
              "Rare": "3_Rare", "Common": "4_Common"}
DHN_LETTER = {"Legendary": "L_", "Epic": "E_", "Rare": "R_", "Common": "C_"}


def dhn_link(gw, rarity, position, big):
    """NOSFERATU.UC_IpfsLink + UC_PaddedNumber."""
    n, s = position, str(position)
    pad = ("00" + s) if n < 100 and n < 10 else ("0" + s) if n < 100 else s
    return (f"{gw}{_t(big)}/04_Nosferatu/{DHN_FOLDER[rarity]}/"
            f"{DHN_LETTER[rarity]}{pad}.jpg")


def dhb_legendary(gw, position, big):
    """BSD-L.UC_LegendaryLink -- 8 shared images, `mod 8` with 0 meaning 8."""
    p = position % 8
    img = "L_" + ("8" if p == 0 else str(p)) + ".jpg"
    return f"{gw}{_t(big)}/07_Bloodshed/1_Legendary/{img}"


def _bsd_shared(gw, position, big, modulus, letter, folder, wide):
    """BSD-E / BSD-R / BSD-C.UC_*Link -- shared images, `mod <modulus>`.

    PADDING_ANOMALY, found 2026-10-08 while porting this. All three pad on `p`
    but format `v`, and those differ in exactly the wrap case:

        (v:string (format "{}" [(if (= p 0) 48 p)]))      ;; v = "48" when p = 0
        (padded-num:string (if (< p 10) (+ "0" v) v))      ;; p = 0 < 10 -> "048"

    So a position at an exact multiple of the modulus asks for `E_048.jpg`,
    `R_072.jpg` or `C_00144.jpg` -- a three/five-character name in a two/three-
    character scheme. Legendary escapes it only because its wrap value is
    special-cased as the literal string "8".

    That is 32 + 44 + 56 = 132 Bloodshed nonces, and whether their links resolve
    today depends on filenames in a tree this repository cannot see. It is NOT
    silently normalised here: this function reproduces the quirk, so the `old`
    link in the plan is what the chain actually holds, and `--check`'s
    old-link cross-check keeps meaning what it says. Choosing the NEW name is the
    owner's call and belongs in LINKS.json, which is keyed by old link.
    """
    p = position % modulus
    v = str(modulus if p == 0 else p)
    if wide:
        pad = ("00" + v) if p < 10 else ("0" + v) if p < 100 else v
    else:
        pad = ("0" + v) if p < 10 else v
    return f"{gw}{_t(big)}/07_Bloodshed/{folder}/{letter}{pad}.jpg"


def dhb_epic(gw, position, big):
    return _bsd_shared(gw, position, big, 48, "E_", "2_Epic", False)


def dhb_rare(gw, position, big):
    return _bsd_shared(gw, position, big, 72, "R_", "3_Rare", False)


def dhb_common(gw, position, big):
    return _bsd_shared(gw, position, big, 144, "C_", "4_Common", True)


def dhb_set(gw, position, big):
    """BSD-SETS.UC_SetLink -- the 38 set-class definitions, `nost=false`."""
    s = str(position)
    pad = ("0" + s) if position < 10 else s
    return f"{gw}{_t(big)}/07_Bloodshed/5_Sets/{pad}.jpg"


# ---------------------------------------------------------------------------
# INVENTORY
# ---------------------------------------------------------------------------
# A lane is a contiguous run of nonces sharing one link grammar. `base` is the
# nonce of the lane's position 1: the collections are minted SEQUENTIALLY from the
# collection's own nonce counter, so nonce = base + position.
#
# THE SEQUENTIAL ASSUMPTION IS NOT CHECKABLE OFFLINE AND IS NOT ASSUMED SILENTLY.
# NOSFERATU's own `UC_Nonces` @doc records the hazard in full: the ladders agree
# with the mint only if the collection held ZERO nonces when the ladder began, and
# nothing enforces that. Every emitted batch therefore opens with a /local read
# that pins a sampled nonce's CURRENT uri-primary against the old link this tool
# computed for it. If the collection was offset, that read disagrees and the batch
# must not be signed.
LANES = [
    # id-key      lane         base   count  grammar
    ("KBN", "bunnies",            0,   1120, "kbn"),
    ("DHN", "Legendary",          0,    100, "dhn"),
    ("DHN", "Epic",             100,    200, "dhn"),
    ("DHN", "Rare",             300,    400, "dhn"),
    ("DHN", "Common",           700,    800, "dhn"),
    ("DHB", "Legendary",          0,    160, "dhb-l"),
    ("DHB", "Epic",             160,   1536, "dhb-e"),
    ("DHB", "Rare",            1696,   3168, "dhb-r"),
    ("DHB", "Common",          4864,   8064, "dhb-c"),
]
# The 38 Bloodshed SET-CLASS definitions are a different shape -- `nost=false`,
# addressed by set-class rather than nonce -- and so are planned separately.
DHB_SETS = 38

# THE REAL COLLECTION IDS, read off the chain on 2026-10-08 with
#     (keys ouronet-ns.DPDC.DPSF|T|Properties) / (keys ..DPNF|T|Properties)
# and confirmed by UR_Name/UR_Ticker/UR_NoncesUsed per id. They were PLACEHOLDERS
# (`KBN_COLLECTION_ID`) until then, and the guessed key was wrong in a way a
# placeholder hides: the bunnies collection is **SBN / DemiBunnies**, not `KBN`.
# `KBN` is the MINTER module's name, not the collection's.
#
# `son` is the DPDC fungibility discriminator and it selects BOTH the Talos module
# and the entrypoint family, so it is not cosmetic:
#   son=false -> ouronet-ns.TS02-C2.DPNF|C_UpdateNonces
#   son=true  -> ouronet-ns.TS02-C1.DPSF|C_UpdateNonces      (a DIFFERENT module)
COLLECTIONS = {
    "SBN":  {"id": "SBN-SUVEHxb9UQ6_",  "name": "DemiBunnies",                 "son": False},
    "DHN":  {"id": "DHN-SUVEHxb9UQ6_",  "name": "DemiourgosHoldingsNosferatu", "son": False},
    "DHB":  {"id": "DHB-SUVEHxb9UQ6_",  "name": "DemiourgosHoldingsBloodshed", "son": False},
    "DHCD": {"id": "DHCD-SUVEHxb9UQ6_", "name": "CodingDivision",              "son": True},
    "DHOC": {"id": "DHOC-SUVEHxb9UQ6_", "name": "OuronetCustodians",           "son": True},
    "DHWC": {"id": "DHWC-SUVEHxb9UQ6_", "name": "WonderCoach",                 "son": True},
    "EDH":  {"id": "E|DH-SUVEHxb9UQ6_",  "name": "Equity^DemiourgosHoldings",   "son": True},
}
# ORDER IS THE SHIP ORDER. Nonce batches per collection, then DHB's set-classes.
COLL_ORDER = ["SBN", "DHN", "DHB", "DHCD", "DHOC", "DHWC", "EDH"]

# DELIBERATELY OUT OF SCOPE, each for a reason that was MEASURED rather than assumed.
# RETRACTED 2026-10-08, same day it was written. The equity entry here claimed the
# collection was "STRUCTURALLY IMMUTABLE" and that claim was WRONG -- see
# EQUITY_RETRACTION below. It is now a full member of COLL_ORDER.
EXCLUDED = {
"SBN-SUVEHxb9UQ6_#1121": (
        "DemiBunnies nonce 1121 is the `Bunny RGB Set` instance (UR_NonceClass = 1) "
        "and has been on Arweave since 2026-10-02 -- nothing to migrate."),
    "DHB-SUVEHxb9UQ6_#12929-12991": (
        "63 minted Bloodshed NFT Set INSTANCES (UR_NonceClass 1..33). UEV_NotSetInstance "
        "refuses direct edits to a minted instance's NonceData permanently, and one of "
        "them in a batch ABORTS THE WHOLE TRANSACTION. The 38 set-class DEFINITIONS are "
        "in scope and shipped separately via DPNF|C_UpdateSetNonces."),
}

GRAMMAR = {
    "kbn":   lambda gw, lane, pos, big: kbn_link(gw, pos, big),
    "dhn":   lambda gw, lane, pos, big: dhn_link(gw, lane, pos, big),
    "dhb-l": lambda gw, lane, pos, big: dhb_legendary(gw, pos, big),
    "dhb-e": lambda gw, lane, pos, big: dhb_epic(gw, pos, big),
    "dhb-r": lambda gw, lane, pos, big: dhb_rare(gw, pos, big),
    "dhb-c": lambda gw, lane, pos, big: dhb_common(gw, pos, big),
}


def _rows_from_snapshot(kind):
    """(collection-key, kind, nonce, nonce, old-primary, old-secondary) from the chain.

    The tuple keeps the 6-field shape the emitter and `distinct_files` already use;
    what changed is where fields 4 and 5 come from. `lane` is now the literal kind
    rather than a rarity, because a lane only ever existed to pick a grammar and there
    is no grammar any more.
    """
    snap = snapshot()
    gw = snap["gateway"]
    files = snap["files"]
    out = []
    for key in COLL_ORDER:
        cid = COLLECTIONS[key]["id"]
        block = snap["collections"].get(cid)
        if block is None:
            raise SystemExit("_arweave: CHAIN-URIS.json has no block for %s -- "
                             "re-record the snapshot" % cid)
        rows = block.get(kind)
        if not rows:
            continue
        for n in sorted(rows, key=int):
            a, b = rows[n]
            out.append((key, kind, int(n), int(n), gw + files[a], gw + files[b]))
    return out


def inventory(gw=None):
    """Every in-scope NONCE row, read from the recorded chain snapshot."""
    return _rows_from_snapshot("nonce")


def set_inventory(gw=None):
    """Every in-scope SET-CLASS row (DHB's 38 definitions), from the snapshot."""
    return _rows_from_snapshot("set")


def distinct_files(rows):
    """The set of IPFS URLs the round has to find an Arweave counterpart for.

    Far smaller than the row count, because Bloodshed's images are shared by
    `mod 8/48/72/144`: 12,928 Bloodshed rows point at 272 files. LINKS.json is
    therefore keyed by OLD LINK, not by nonce -- one entry serves every row that
    shares the image, and a per-nonce keying would ask for the same string 47
    times and offer 47 chances to disagree with itself.
    """
    s = set()
    for _, _, _, _, a, b in rows:
        s.add(a)
        s.add(b)
    return s


# ---------------------------------------------------------------------------
# EQUITY_RETRACTION -- a wrong conclusion, and the reasoning error behind it
# ---------------------------------------------------------------------------
# On 2026-10-08 this tool declared the equity collection out of scope as
# "structurally immutable", on two measurements that were both CORRECT:
#
#   * `11_EQUITY+.pact` exposes two client functions and neither touches a URI;
#   * `UR_OwnerKonto "E|DH-..." true` IS the DPDC smart account, so
#     `C_MoveRecreateRole` -- which enforces `UEV_ExecutorIsCollectionOwner` --
#     can never be executed for it by any signer.
#
# The conclusion drawn from them was wrong, because it answered a question nobody
# asked. `DPDC-N|C>SET-DATA` does NOT check collection ownership. It checks
# `UEV_RoleNftRecreateON` -- the ROLE -- plus the signer's own account ownership.
# So "the role cannot be MOVED" had been treated as "the role is not HELD", and
# those are different sentences. Measured:
#
#   UR_CreatorKonto == UR_Verum6 == the recreate-role holder, on ALL SEVEN
#   collections, one single account.
#
# The role was already exactly where it needed to be. Proven by simulating an
# equity update signed as the creator: it stops at `UEV_StandardAccOwn` -- the
# keyset -- meaning every check including the role gate passed.
#
# TWO CONSEQUENCES, and the second one mattered more than the first:
#
#   1. The equity collection is in scope. +8 nonces / 16 links, no module change.
#   2. THE ROLE-MOVE TRANSACTIONS WERE NOT MERELY UNNECESSARY, THEY WERE A TRAP.
#      `00_PREREQUISITE_roles.pact` moved the role FROM the creator TO the owner.
#      Run it and then sign the batches as the creator -- which is what the
#      creator-signed round does -- and every batch FAILS, because 00 had just
#      taken the role away from the signer. The round now signs as the creator and
#      moves nothing.
#
# The owner route still exists and still works (move the role, sign as owner). It
# is strictly worse: two extra transactions, a one-way transfer of the authority to
# rewrite any nonce's entire data, and a restore step that needs a value the move
# destroys. Signing as the creator needs none of it.


# ---------------------------------------------------------------------------
# LINK RESOLUTION
# ---------------------------------------------------------------------------
# A link map is DRAFT until its values are real. The placeholder used to prove the
# emitted shape passes every check in this tool -- coverage, budget, stale diff --
# because all of those are about structure and a fake txid is structurally perfect.
# So 20 files can look signed-and-ready while every link in them is a lie. These
# markers are what make that state loud, in the transaction files themselves.
DRAFT_MARKERS = ("REPLACE", "SHAPE_TEST", "NOT_A_REAL", "PENDING", "EXAMPLE",
                 "TODO", "XXX", "<", ">")


def is_draft(resolver):
    """True when any resolved link still carries a placeholder marker."""
    if resolver is None:
        return True
    return any(any(m in v for m in DRAFT_MARKERS) for v in resolver.values())


def load_links(gw, files):
    """links/LINKS.json -> (resolver, mode, missing, unknown).

    `resolver` maps an OLD ipfs url to its NEW arweave url. An absent file is NOT
    an error: the round has to be plannable and checkable before the links exist,
    and the gate has to stay green in the meantime. The resolver is None then.
    """
    if not os.path.exists(LINKS):
        return None, None, sorted(files), []
    with open(LINKS, "r", encoding="utf-8") as fh:
        spec = json.load(fh)
    mode = spec.get("mode")
    overrides = spec.get("overrides", {})
    if mode == "manifest":
        base = spec.get("manifest")
        if not base or not base.endswith("/"):
            raise SystemExit("_arweave: manifest mode needs a `manifest` base URL "
                             "ending in '/'")
        table = {f: base + f[len(gw):] for f in files}
    elif mode == "explicit":
        table = dict(spec.get("explicit", {}))
    else:
        raise SystemExit("_arweave: LINKS.json `mode` must be manifest|explicit, "
                         "got %r" % (mode,))
    unknown = sorted(set(overrides) - set(files))
    table.update({k: v for k, v in overrides.items() if k in files})
    missing = sorted(f for f in files if f not in table)
    unknown += sorted(set(table) - set(files))
    return table, mode, missing, sorted(set(unknown))


# ---------------------------------------------------------------------------
# BATCHING
# ---------------------------------------------------------------------------
def rows_per_tx():
    """The largest batch whose ESTIMATED total gas stays inside GAS_TOTAL_CAP.

    Solved rather than divided, because the size term is non-linear: dividing the
    cap by the per-row exec cost ignores it entirely and overshoots.
    """
    n = 1
    while gas_total(n + 1, HEADER_RESERVE + BYTES_PER_ROW * (n + 1)) <= GAS_TOTAL_CAP:
        n += 1
    return n


def batches(rows, sets):
    """Split into transactions.

    A batch never spans two collections -- different id and different executor, so
    one call cannot address both -- and never mixes nonces with set-classes, which
    differ in `nost` and in the Talos entrypoint. Within one collection a batch
    DOES span lanes, same id and same shape, and that is what keeps the round at
    18 transactions rather than one per lane.
    """
    cap = rows_per_tx()
    out = []
    for cid in COLL_ORDER:
        mine = [r for r in rows if r[0] == cid]
        for i in range(0, len(mine), cap):
            out.append(("nonce", cid, mine[i:i + cap]))
    # SET-CLASS batches are per collection too. This used to be hardcoded to DHB,
    # which was true while the round held only the three NFT collections; three of
    # the six carry set-classes (DHB 38, DHWC 4, DHCD 1) and a hardcoded `"DHB"`
    # would have emitted DHWC's and DHCD's set rows against BLOODSHED's id.
    for cid in COLL_ORDER:
        mine = [r for r in sets if r[0] == cid]
        for i in range(0, len(mine), cap):
            out.append(("set", cid, mine[i:i + cap]))
    return out


# ---------------------------------------------------------------------------
# EMIT
# ---------------------------------------------------------------------------
def pact_int_list(xs, per_line=20, indent=12):
    pad = " " * indent
    lines, cur = [], []
    for x in xs:
        cur.append(str(x))
        if len(cur) == per_line:
            lines.append(pad + " ".join(cur))
            cur = []
    if cur:
        lines.append(pad + " ".join(cur))
    return "\n".join(lines)


def emit(kind, cid, batch, resolver, idx, total, gw, draft):
    """One transaction file: a commented header plus the generated body."""
    coll = COLLECTIONS[cid]
    ids = [r[2] for r in batch]
    son = str(coll["son"]).lower()

    lanes = []
    for r in batch:
        if not lanes or lanes[-1][0] != r[1]:
            lanes.append([r[1], r[2], r[2]])
        else:
            lanes[-1][2] = r[2]
    lane_txt = ", ".join("%s %d-%d" % (ln, lo, hi) for ln, lo, hi in lanes)

    est = GAS_FIXED + GAS_PER_NONCE * len(batch)
    unit = "set-class" if kind == "set" else "nonce"
    var = "set-classes" if kind == "set" else "nonces"
    # FUNGIBILITY DISPATCH. `DPNF|` was hardcoded while the round held only
    # non-fungible collections. Three of the six are SEMI-fungible, and for those
    # the entrypoint lives in a DIFFERENT TALOS MODULE -- TS02-C1, not TS02-C2 --
    # so getting this from `son` rather than from a constant is what makes the
    # SFT batches callable at all.
    fam = "DPSF" if coll["son"] else "DPNF"
    talos = "TS02-C1" if coll["son"] else "TS02-C2"
    entry = "%s|C_UpdateSetNonces" % fam if kind == "set" else "%s|C_UpdateNonces" % fam
    reader = ("ouronet-ns.DPDC-S.UR_SetNonceData" if kind == "set"
              else "ouronet-ns.DPDC.UR_NativeNonceData")
    short = reader.split(".")[-1]
    place = coll["id"]
    s_id, s_old = batch[0][2], batch[0][4]

    if resolver is None:
        pairs = [("ARWEAVE_LINK_512_PENDING", "ARWEAVE_LINK_FULL_PENDING")
                 for _ in batch]
    else:
        pairs = [(resolver[r[4]], resolver[r[5]]) for r in batch]
    H = []
    A = H.append
    if draft:
        A(";; " + "#" * 89)
        A(";; ##   DRAFT -- DO NOT SIGN THIS FILE.")
        A(";; ##")
        A(";; ##   links/LINKS.json still carries placeholder values, so the Arweave URLs")
        A(";; ##   below are NOT REAL. Every structural check in _arweave.py passes on this")
        A(";; ##   file -- coverage, budget, the byte-for-byte stale diff -- because all of")
        A(";; ##   them are about SHAPE, and a placeholder is shape-perfect. Nothing except")
        A(";; ##   this banner distinguishes a drafted round from a finished one.")
        A(";; ##")
        A(";; ##   Replace the link map, re-run `_arweave.py --write`, and this banner")
        A(";; ##   disappears on its own. If you can still read it, the links are fake.")
        A(";; " + "#" * 89)
        A(";;")
    A(";; " + "=" * 89)
    A(";; OURONET IPFS -> ARWEAVE URI MIGRATION -- TRANSACTION %d OF %d" % (idx, total))
    A(";; %s :: %s" % (coll["name"], lane_txt))
    A(";; " + "=" * 89)
    A(";; ESTIMATED GAS {:,}  ({:.1%} of a 2,000,000 block)".format(est, est / 2_000_000))
    A(";;   = {:,} fixed + {:,} x {:,} -- the N-sweep in REPL/tools/_arweave.py".format(
        GAS_FIXED, len(batch), GAS_PER_NONCE))
    A(";; IGNIS {:,.0f}  ({:,} x 1.0; URCi_UpdateNonces = count x tier-smallest)".format(
        len(batch) * IGNIS_PER_NONCE, len(batch)))
    A(";; " + "=" * 89)
    A(";;")
    A(";; WHAT THIS DOES")
    A(";;   Rewrites `uri-primary` (512x512) and `uri-secondary` (FULL) on {:,} {}s of".format(
        len(batch), unit))
    A(";;   %s, from the IPFS gateway to Arweave." % coll["name"])
    A(";;")
    A(";;   NOTHING ELSE ON THE ROW IS TOUCHED, and that is structural rather than careful:")
    A(";;   the lambda READS the live row with %s and overlays" % short)
    A(";;   exactly those two keys, so `name`, `description`, `meta-data`, `asset-type` and")
    A(";;   both royalties are carried across BY THE CHAIN rather than retyped here. That is")
    A(";;   the whole reason this round drives the BULK entrypoint through a read-overlay")
    A(";;   instead of calling the single-field `C_UpdateNonceURI` once per %s." % unit)
    A(";;")
    A(";;   This file is GENERATED. Edit REPL/tools/_arweave.py and re-run --write.")
    A(";;")
    A(";; " + "-" * 89)
    A(";; READ THIS BEFORE SIGNING -- THREE PRECONDITIONS")
    A(";; " + "-" * 89)
    A(";;")
    A(";; (1) THE EXECUTOR MUST HOLD role-RECREATE.")
    A(";;     Not role-set-new-uri, and not role-update. All three exist on a DPDC account")
    A(";;     and all three are separately held:")
    A(";;")
    A(";;       C_UpdateNonceURI  -> DPDC-N|C>SET-URI  -> UEV_RoleSetNewUriON  -> R-SetUri")
    A(";;       C_UpdateNonces    -> DPDC-N|C>SET-DATA -> UEV_RoleNftRecreateON -> R-Recreate")
    A(";;")
    A(";;     This round drives the second one, so R-Recreate is what gates it. Read:")
    A(";;")
    A(';;         (ouronet-ns.DPDC.UR_CA|R-Recreate "%s" %s "OWNER_KONTO")' % (place, son))
    A(";;")
    A(";;       true  -> proceed.")
    A(";;       false -> move it first (`DPNF|C_MoveRecreateRole`; it is move-only, there is")
    A(";;                no toggle). Do NOT switch to C_UpdateNonceURI to dodge this:")
    A(";;                measured, that is 6x the gas and 17x the IGNIS across the round.")
    A(";;")
    A(";;     `UEV_RoleNftRecreateON` and `UEV_RoleNftUpdateON` emit the BYTE-IDENTICAL")
    A(";;     refusal -- \"... Element Data cannot be Updated while using the ... Account\" --")
    A(";;     so if this is wrong, the error message will not tell you which role is")
    A(";;     missing. That is why the read above names the role explicitly.")
    A(";;")
    A(";; (2) THE LADDER MUST LINE UP WITH THE MINT, and nothing on chain enforces that.")
    A(";;     The links below are addressed by position using the minter's own arithmetic,")
    A(";;     which matches the mint only if the collection held ZERO %ss when the" % unit)
    A(";;     populate ladder began -- the exact hazard NOSFERATU's `UC_Nonces` @doc records.")
    A(";;     If the collection was offset, every batch rewrites the NEIGHBOURS of what it")
    A(";;     means to, and does it silently, because every row gets a plausible link.")
    A(";;")
    A(";;     The read that settles it, for this batch's first %s:" % unit)
    A(";;")
    A(';;         (at "image" (at "uri-primary"')
    A(";;             (%s \"%s\" %s %d)))" % (reader, place, son, s_id))
    A(";;")
    A(";;     MUST return EXACTLY:")
    A(";;         %s" % s_old)
    A(";;")
    A(";;     A different link means the ladder is offset: STOP, and re-plan the round.")
    A(";;     Do not sign this file or any later one.")
    A(";;")
    A(";; (3) NO %s IN THIS BATCH MAY BE A MINTED NFT SET INSTANCE." % unit.upper())
    A(";;     `DPDC-N.UEV_NotSetInstance` (DPDC Audit #12Hc) refuses a data change on any NFT")
    A(";;     nonce whose `UR_NonceClass` is non-zero -- a Set instance's composition record is")
    A(";;     frozen at Make, deliberately and permanently. Such a row CANNOT be migrated by")
    A(";;     any entrypoint in the module, now or ever.")
    A(";;")
    A(";;     ONE of them ABORTS THE WHOLE TRANSACTION, because `C_UpdateNonces` writes the")
    A(";;     batch under a single capability. Spot-check:")
    A(";;")
    A(';;         (ouronet-ns.DPDC.UR_NonceClass "%s" %s %d)   ;; expect 0' % (place, son, s_id))
    A(";;")
    A(";;     If any are Sets, delete them from BOTH lists below -- keeping the two lists the")
    A(";;     same length is what keeps link i paired with %s i -- and record them as" % unit)
    A(";;     permanently on IPFS.")
    A(";;")
    A(";; " + "-" * 89)
    A(";; SIGNING")
    A(";; " + "-" * 89)
    A(";;   The collection OWNER (holder of role-update) signs; the patron pays. No admin key")
    A(";;   and no namespace write: this round deploys nothing.")
    A(";;")
    A(";; " + "-" * 89)
    A(";; RESUMING -- which matters, because this round is %d signed transactions" % total)
    A(";; " + "-" * 89)
    A(";;   Every file is INDEPENDENT and IDEMPOTENT: re-running one rewrites the same rows")
    A(";;   with the same strings. There is no cursor and no ordering requirement between")
    A(";;   files, so a failure needs no unwinding -- fix and re-send that one file.")
    A(";;")
    A(";;   To find out whether THIS file already landed, run precondition 2's read: an")
    A(";;   Arweave link means it did.")
    A(";;")
    A(";;   The dotted `ouronet-ns.MODULE.function` calls below are CORRECT and must not be")
    A(";;   'fixed' to `::`. The dot rule is about calls made from INSIDE a module, where a")
    A(";;   dot pins the callee's hash at the caller's deploy time; a signed transaction has")
    A(";;   no deploy time to pin. Deploy/3_Assets uses dots throughout, for this reason.")
    A(";; " + "=" * 89)
    A("")
    A('(namespace "ouronet-ns")')
    A("")
    A(MARK)

    return "\n".join(H) + "\n" + emit_code(
        place, var, entry, reader, son, ids, pairs, talos) + "\n"


def emit_code(place, var, entry, reader, son, ids, pairs, talos="TS02-C2"):
    """THE generated body -- the only place in the tool where it is spelled.

    `--selftest` renders this same function against the REPL's CNF fixture and
    EXECUTES it, so what the gate proves is what the owner signs. A self-test that
    re-spelled the body would only prove that a COPY of it parses, which is the
    failure mode `readUnwrap`/`unwrap` already cost this project once.
    """
    link_lines = "\n".join('              ["%s" "%s"]' % (a, b) for a, b in pairs)
    B = []
    C = B.append
    C("(let")
    C("    (")
    C('        (patron:string "PATRON_KONTO")')
    C('        (executor:string "OWNER_KONTO")')
    C('        (id:string "%s")' % place)
    C("        (%s:[integer]" % var)
    C("            [")
    C(pact_int_list(ids))
    C("            ]")
    C("        )")
    C("        (links:[[string]]")
    C("            [")
    C(link_lines)
    C("            ]")
    C("        )")
    C("    )")
    C("    (ouronet-ns.%s.%s patron executor id %s true" % (talos, entry, var))
    C("        (map")
    C("            (lambda (i:integer)")
    C("                (+")
    C('                    { "uri-primary"   : (ouronet-ns.DPDC-UDC.UDC_URI|Data '
      '(at 0 (at i links)) "|" "|" "|" "|" "|" "|")')
    C('                    , "uri-secondary" : (ouronet-ns.DPDC-UDC.UDC_URI|Data '
      '(at 1 (at i links)) "|" "|" "|" "|" "|" "|") }')
    C('                    (remove "uri-secondary"')
    C('                        (remove "uri-primary"')
    C("                            (%s id %s (at i %s))" % (reader, son, var))
    C("                        )")
    C("                    )")
    C("                )")
    C("            )")
    C("            (enumerate 0 (- (length links) 1))")
    C("        )")
    C("    )")
    C(")")
    return "\n".join(B)


SELFTEST = os.path.join(ROOT, "REPL", "Stage_02", "[6.1.10]_ARWEAVE-SHAPE.repl")


def fee_caps(usage):
    """The derived STOA fee-cap `env-sigs` block, for a given usage price key.

    Issuing a collection costs real STOA, so the patron needs KDA fuel granted in
    THIS transaction -- `env-sigs` does not carry across one. The amounts are DERIVED
    from `URC_SplitSTOAPrices` over the live usage price rather than written down, so
    a price change cannot silently underfund the fixture.

    Factored out when ARW-SHAPE-03 needed the same thing for `dpsf`: the SFT twin
    first tried to invent a simpler cap naming a constant that does not exist, which
    cost a whole-file load failure.
    """
    k = "6fa1d9c3e5078a54038159c9a6bd7182301e16d6f280615eddb18b8bd2d6c263"
    return [
        "(let",
        "    (",
        "        (ref-DALOS:module{OuronetDalosV2} DALOS)",
        "        (owner:string KST.ANHD)",
        '        (price:decimal (ref-DALOS::UR_UsagePrice "%s"))' % usage,
        "        (split:[decimal] (ref-DALOS::URC_SplitSTOAPrices owner price))",
        "        (t0:decimal (at 0 split))",
        "        (t1:decimal (at 1 split))",
        "        (t2:decimal (at 2 split))",
        "        (t3:decimal (at 3 split))",
        "    )",
        "    (env-sigs",
        "        [",
        '            { "key": "PK_AncientHodler", "caps": [] }',
        '            { "key": "%s",' % k,
        '              "caps":',
        "                [",
        '                    (coin.TRANSFER "k:%s"' % k,
        '                        "k:50d6c59b21e5e6e55baecaa75a1007de37576bde12d8230dc82459cc01b9484b" t2)',
        '                    (coin.TRANSFER "k:%s"' % k,
        '                        "k:0cb30c0121ff919266121a99ff9359871818932211df94dae4137c29bc0e8f7e" t0)',
        '                    (coin.TRANSFER "k:%s"' % k,
        '                        "c:XM-pkmuB5XUQlp87ZYSbfKt8qzmHY6O2EHAzMRVBt3k" t3)',
        '                    (coin.TRANSFER "k:%s"' % k,
        '                        "c:iQQFWj6gWtpGEzhM_O5ekW1QtnQQy55R8BRPGhj_0FU" t1)',
        "                ]",
        "            }",
        "        ]",
        "    )",
        ")",
    ]


def selftest_repl():
    """Render the REAL generated body against the REPL's CNF fixture and assert.

    This exists because the round is 20 transactions the owner signs by hand, and
    the only thing standing between a typo in `emit_code` and twenty unusable
    files is whether the emitted shape has ever been EXECUTED. It is rendered from
    `emit_code`, not retyped, so a change to the generator either keeps this green
    or breaks it.

    What it pins, beyond "it parses":
      - both URI slots land, and land in the RIGHT slot (primary != secondary);
      - `name`, `description`, `meta-data` and both royalties SURVIVE -- the read-
        overlay's whole justification, and the one claim a parse check cannot make;
      - `asset-type` survives too, which the single-field op would have rewritten;
      - a sibling nonce outside the batch is untouched.
    """
    # ITS OWN COLLECTION, under a ticker nothing else uses.
    #
    # The first version of this read `CNF-98c486052a51` out of [6.1.4] and compared
    # the migrated row against an untouched sibling, on the reasoning that every CNF
    # nonce was minted from one `nd`. That is true at mint and FALSE by the time this
    # suite runs: [6.1.4] exercises `C_UpdateNonceIgnisRoyalty` and friends, so nonce
    # 3 carried `ignis` 2.0 against nonce 8's 0.0 and the assertion failed on the
    # fixture rather than on the code.
    #
    # It is the cross-suite-fixture trap the PureV4 round already paid for once
    # (`<<TX-SCORE-15>>` read [6.1.1]'s collection and was green in 1 of 8 gate
    # entrypoints). A fixture you do not own is a bet on load order AND on every
    # other suite's writes. This one issues ARWQ, mints 8 nonces with values chosen
    # here, and therefore asserts against literals it controls.
    ids = list(range(1, 8))
    pairs = [("https://arweave.net/SELFTEST/512x512/%04d.jpg" % i,
              "https://arweave.net/SELFTEST/FULL/%04d.jpg" % i) for i in ids]
    code = emit_code("ARWQ-98c486052a51", "nonces", "DPNF|C_UpdateNonces",
                     "ouronet-ns.DPDC.UR_NativeNonceData", "false", ids, pairs)
    # The fixture substitutions -- exactly the placeholders a signer fills in.
    code = code.replace('(patron:string "PATRON_KONTO")',
                        "(patron:string KST.ANHD)")
    code = code.replace('(executor:string "OWNER_KONTO")',
                        '(executor:string (ouronet-ns.DPDC.UR_OwnerKonto '
                        '"ARWQ-98c486052a51" false))')
    # The ARW-SHAPE-02 body: the same generator, one nonce, the batch's control row.
    code2 = emit_code("ARWQ-98c486052a51", "nonces", "DPNF|C_UpdateNonces",
                      "ouronet-ns.DPDC.UR_NativeNonceData", "false", [8],
                      [("https://arweave.net/SELFTEST/512x512/0008.jpg",
                        "https://arweave.net/SELFTEST/FULL/0008.jpg")])
    code2 = code2.replace('(patron:string "PATRON_KONTO")',
                          "(patron:string KST.ANHD)")
    code2 = code2.replace('(executor:string "OWNER_KONTO")',
                          '(executor:string (ouronet-ns.DPDC.UR_OwnerKonto '
                          '"ARWQ-98c486052a51" false))')
    L = []
    A = L.append
    A(";;")
    A(";; REPL/Stage_02/[6.1.10]_ARWEAVE-SHAPE.repl -- the Deploy/4_Arweave emitted shape")
    A(";;   Legend (terminal observability): <(...)> echoes; (expect ...) lines print.")
    A(";;   Source: GENERATED by REPL/tools/_arweave.py --selftest. Do not hand-edit --")
    A(";;           the body in group 03 is rendered by `emit_code`, the SAME function")
    A(";;           that writes Deploy/4_Arweave/*.pact, so this suite proves the shape")
    A(";;           the owner actually signs rather than a retyped copy of it.")
    A(";;   Fixture: ITS OWN collection (ARWQ). Depends on no other suite -- see the note")
    A(";;           in _arweave.py:selftest_repl about why that matters here.")
    A(";;   REPL tests: ARW-SHAPE-01")
    A(";;")
    A('(print "")')
    A('(print "================================================================")')
    A('(print "FILE  REPL/Stage_02/[6.1.10]_ARWEAVE-SHAPE.repl  (Arweave URI migration shape)")')
    A('(print "================================================================")')
    A('(print "")')
    A(";;")
    A('(begin-tx "ARW-SHAPE-00 - own fixture: issue ARWQ and mint 8 nonces")')
    A('(env-gasmodel "table")(env-gaslimit 10000000)(env-gas 0)')
    A('(namespace "ouronet-ns")')
    A(";;==== ARW-SHAPE-00 · 01 · env-sigs (STOA fee caps) ====")
    A('(print "--- [ARW-SHAPE-00 · 01 · env-sigs (STOA fee caps)] ---")')
    A(";;  Issuing a collection costs 250 STOA, so the patron needs KDA fuel granted in")
    A(";;  THIS transaction -- `env-sigs` does not carry across one. The first version of")
    A(";;  this suite omitted the block and died in `coin.transfer` inside")
    A(";;  `IGNIS.XB_MoveDalosFuel`, which reads as an IGNIS defect and is a missing")
    A(";;  signature.")
    A(";;")
    A(";;  Lifted from [6.1.4]_DPDC-NF TX-NF-001 · 01, where the same issue is paid for.")
    A(";;  The amounts are DERIVED (`URC_SplitSTOAPrices` over the live `dpnf` usage price)")
    A(";;  rather than written down, so a price change does not silently underfund this.")
    A('(let')
    A('    (')
    A('        (ref-DALOS:module{OuronetDalosV2} DALOS)')
    A('        (owner:string KST.ANHD)')
    A('        (dpnf-price:decimal (ref-DALOS::UR_UsagePrice "dpnf"))')
    A('        (split-dpnf:[decimal] (ref-DALOS::URC_SplitSTOAPrices owner dpnf-price))')
    A('        (t0:decimal (at 0 split-dpnf))')
    A('        (t1:decimal (at 1 split-dpnf))')
    A('        (t2:decimal (at 2 split-dpnf))')
    A('        (t3:decimal (at 3 split-dpnf))')
    A('    )')
    A('    (env-sigs')
    A('        [')
    A('            { "key": "PK_AncientHodler", "caps": [] }')
    A('            { "key": "6fa1d9c3e5078a54038159c9a6bd7182301e16d6f280615eddb18b8bd2d6c263",')
    A('              "caps":')
    A('                [')
    A('                    (coin.TRANSFER "k:6fa1d9c3e5078a54038159c9a6bd7182301e16d6f280615eddb18b8bd2d6c263"')
    A('                        "k:50d6c59b21e5e6e55baecaa75a1007de37576bde12d8230dc82459cc01b9484b" t2)')
    A('                    (coin.TRANSFER "k:6fa1d9c3e5078a54038159c9a6bd7182301e16d6f280615eddb18b8bd2d6c263"')
    A('                        "k:0cb30c0121ff919266121a99ff9359871818932211df94dae4137c29bc0e8f7e" t0)')
    A('                    (coin.TRANSFER "k:6fa1d9c3e5078a54038159c9a6bd7182301e16d6f280615eddb18b8bd2d6c263"')
    A('                        "c:XM-pkmuB5XUQlp87ZYSbfKt8qzmHY6O2EHAzMRVBt3k" t3)')
    A('                    (coin.TRANSFER "k:6fa1d9c3e5078a54038159c9a6bd7182301e16d6f280615eddb18b8bd2d6c263"')
    A('                        "c:iQQFWj6gWtpGEzhM_O5ekW1QtnQQy55R8BRPGhj_0FU" t1)')
    A('                ]')
    A('            }')
    A('        ]')
    A('    )')
    A(')')
    A(";;==== ARW-SHAPE-00 · 02 · issue + mint with KNOWN field values ====")
    A('(print "--- [ARW-SHAPE-00 · 02 · issue + mint] ---")')
    A(";;  Every non-URI field gets a value named HERE, so the assertions in ARW-SHAPE-01")
    A(";;  compare against something this file controls. The two URI slots start on IPFS,")
    A(";;  which is also what makes the migration observable rather than assumed.")
    A("(let")
    A("    (")
    A("        (ref-DPDC:module{DpdcV2} DPDC)")
    A("        (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)")
    A("        (ref-TS02-C2:module{TalosStageTwo_ClientTwoV2} TS02-C2)")
    A("        (owner:string KST.ANHD)")
    A("        (b:string \"|\")")
    A("    )")
    A("    (map print")
    A("        [")
    A('            (format "<(DPNF|C_Issue ArweaveShapeQ/ARWQ)> => [{}]"')
    A('                [(ref-TS02-C2::DPNF|C_Issue owner owner owner "ArweaveShapeQ" "ARWQ"')
    A("                    true true true true true true true true)])")
    A("        ]")
    A("    )")
    A("    (let")
    A("        (")
    A('            (id:string "ARWQ-98c486052a51")')
    A("            (nd:object{DpdcUdcV2.DPDC|NonceData}")
    A("                (ref-DPDC-UDC::UDC_NonceData")
    A("                    5.0")
    A("                    7.0")
    A('                    "ARW-NAME"')
    A('                    "ARW-DESC"')
    A("                    (ref-DPDC-UDC::UDC_NonceMetaData 42.0 [0]")
    A('                        { "Rarity" : "ARW-RARITY" })')
    A("                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)")
    A('                    (ref-DPDC-UDC::UDC_URI|Data "ipfs://old-primary"   b b b b b b)')
    A('                    (ref-DPDC-UDC::UDC_URI|Data "ipfs://old-secondary" b b b b b b)')
    A("                    (ref-DPDC-UDC::UDC_ZeroURI|Data)")
    A("                )")
    A("            )")
    A("        )")
    A("        (map print")
    A("            [")
    A('                (format "<(DPNF|C_Create 8 ARWQ nonces)> => [{}]"')
    A("                    [(ref-TS02-C2::DPNF|C_Create owner")
    A("                        (ref-DPDC::UR_Verum5 id false) id (make-list 8 nd))])")
    A('                (expect "<<ARW-SHAPE-00>> ARWQ has 8 native nonces" 8')
    A("                    (ref-DPDC::UR_NoncesUsed id false))")
    A(";;  The role the BULK entrypoint actually needs: role-RECREATE, via")
    A(";;  DPDC-N|C>SET-DATA -> UEV_RoleNftRecreateON. Asserted here because the first")
    A(";;  draft of this round named role-update in all 20 emitted headers, and the")
    A(";;  mistake was INVISIBLE: the fixture owner holds every role, so an assertion on")
    A(";;  the wrong one passed and the body succeeded anyway. ARW-SHAPE-02 below is what")
    A(";;  actually distinguishes them.")
    A('                (expect "<<ARW-SHAPE-00>> owner holds role-recreate (gates the bulk op)"')
    A("                    true (ref-DPDC::UR_CA|R-Recreate id false")
    A("                        (ref-DPDC::UR_OwnerKonto id false)))")
    A('                (expect "<<ARW-SHAPE-00>> owner ALSO holds role-update -- which is why an assertion on it proves nothing"')
    A('                    true (ref-DPDC::UR_CA|R-Update id false')
    A("                        (ref-DPDC::UR_OwnerKonto id false)))")
    A(";;  And every nonce is a plain nonce, not a Set instance -- the condition")
    A(";;  UEV_NotSetInstance enforces, and the one precondition in every emitted file")
    A(";;  that cannot be checked offline.")
    A('                (expect "<<ARW-SHAPE-00>> nonce 3 is not a Set instance" 0')
    A("                    (ref-DPDC::UR_NonceClass id false 3))")
    A('                ""')
    A("            ]")
    A("        )")
    A("    )")
    A(")")
    A('(print "===^^^===")')
    A("(commit-tx)")
    A("")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A(";;|| NEXT                   >")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A("")
    A('(begin-tx "ARW-SHAPE-01 - the emitted DPNF|C_UpdateNonces read-overlay body")')
    A('(env-gasmodel "table")(env-gaslimit 10000000)(env-gas 0)')
    A('(namespace "ouronet-ns")')
    A(";;==== ARW-SHAPE-01 · 01 · env-sigs (caps) ====")
    A('(print "--- [ARW-SHAPE-01 · 01 · env-sigs (caps)] ---")')
    A('(env-sigs [{ "key": "PK_AncientHodler", "caps": [] }])')
    A(";;==== ARW-SHAPE-01 · 02 · pre-state ====")
    A('(print "--- [ARW-SHAPE-01 · 02 · pre-state] ---")')
    A("(let")
    A("    (")
    A("        (nd:object{DpdcUdcV2.DPDC|NonceData}")
    A('            (ouronet-ns.DPDC.UR_NativeNonceData "ARWQ-98c486052a51" false 3))')
    A("    )")
    A("    (map print")
    A("        [")
    A('            (format "<(pre uri-primary)> => [{}]" [(at "image" (at "uri-primary" nd))])')
    A(";;  Non-vacuity: the slot really is on IPFS before the body runs, so the")
    A(";;  assertions below measure a CHANGE rather than agreeing with a coincidence.")
    A('            (expect "<<ARW-SHAPE-01>> pre-state: uri-primary is still the IPFS link"')
    A('                "ipfs://old-primary" (at "image" (at "uri-primary" nd)))')
    A("        ]")
    A("    )")
    A('    ""')
    A(")")
    A(";;==== ARW-SHAPE-01 · 03 · THE EMITTED BODY, rendered by emit_code ====")
    A('(print "--- [ARW-SHAPE-01 · 03 · the emitted body] ---")')
    A(code)
    A(";;==== ARW-SHAPE-01 · 04 · assertions ====")
    A('(print "--- [ARW-SHAPE-01 · 04 · assertions] ---")')
    A("(let")
    A("    (")
    A("        (nd:object{DpdcUdcV2.DPDC|NonceData}")
    A('            (ouronet-ns.DPDC.UR_NativeNonceData "ARWQ-98c486052a51" false 3))')
    A("        (sib:object{DpdcUdcV2.DPDC|NonceData}")
    A('            (ouronet-ns.DPDC.UR_NativeNonceData "ARWQ-98c486052a51" false 8))')
    A("    )")
    A("    (map print")
    A("        [")
    A(";;  The two slots land, and they land in the RIGHT one. Primary is the 512x512 and")
    A(";;  secondary the FULL -- the convention every minter follows, and the exact thing")
    A(";;  the Bunny RGB Set got wrong by reading one binding twice (fixed 2026-10-02).")
    A('            (expect "<<ARW-SHAPE-01>> uri-primary is the 512x512 arweave link"')
    A('                "https://arweave.net/SELFTEST/512x512/0003.jpg"')
    A('                (at "image" (at "uri-primary" nd)))')
    A('            (expect "<<ARW-SHAPE-01>> uri-secondary is the FULL arweave link"')
    A('                "https://arweave.net/SELFTEST/FULL/0003.jpg"')
    A('                (at "image" (at "uri-secondary" nd)))')
    A('            (expect "<<ARW-SHAPE-01>> the two slots differ"')
    A("                false")
    A('                (= (at "image" (at "uri-primary" nd))')
    A('                   (at "image" (at "uri-secondary" nd))))')
    A(";;  THE READ-OVERLAY'S WHOLE JUSTIFICATION. `C_UpdateNonces` takes a FULL row, so a")
    A(";;  version of this that retyped the row by hand would pass every assertion above")
    A(";;  while silently blanking everything below -- across 15,586 rows, with no way to")
    A(";;  recover the originals. These are the ones that tell an overlay from a rewrite.")
    A('            (expect "<<ARW-SHAPE-01>> name survives the URI write"')
    A('                "ARW-NAME" (at "name" nd))')
    A('            (expect "<<ARW-SHAPE-01>> description survives"')
    A('                "ARW-DESC" (at "description" nd))')
    A('            (expect "<<ARW-SHAPE-01>> meta-data survives"')
    A('                "ARW-RARITY" (at "Rarity" (at "meta-data" (at "meta-data" nd))))')
    A(";;  `score` rides inside meta-data and is what AQP-SCORE reads for a per-nonce")
    A(";;  score definition. Losing it would silently rescore staked collectables.")
    A('            (expect "<<ARW-SHAPE-01>> meta-data score survives"')
    A('                42.0 (at "score" (at "meta-data" nd)))')
    A('            (expect "<<ARW-SHAPE-01>> royalty survives"')
    A("                5.0 (at \"royalty\" nd))")
    A(";;  `ignis` is the one that would actually hurt. Per DPDC Audit #26M its sibling")
    A(";;  `royalty` has NO on-chain consumer yet, while `ignis` IS read by DPDC-T's")
    A(";;  transfer pricing -- so a rewrite that dropped it would silently reprice every")
    A(";;  transfer of all 15,586 migrated nonces. (The field is `ignis`; `ignis-royalty`")
    A(";;  is what the first draft of this line guessed, and it does not exist.)")
    A('            (expect "<<ARW-SHAPE-01>> ignis survives -- DPDC-T prices transfers on it"')
    A("                7.0 (at \"ignis\" nd))")
    A(";;  asset-type too -- which the single-field C_UpdateNonceURI would have OVERWRITTEN")
    A(";;  from its own `ay` argument. Choosing the bulk op preserved it for free.")
    A('            (expect "<<ARW-SHAPE-01>> asset-type image flag survives"')
    A('                true (at "image" (at "asset-type" nd)))')
    A(";;  And the slot the round does NOT write stays as it was.")
    A('            (expect "<<ARW-SHAPE-01>> uri-tertiary is left alone"')
    A('                (at "uri-tertiary" sib) (at "uri-tertiary" nd))')
    A(";;  The control is nonce 8: INSIDE the fixture (which holds 8) but OUTSIDE the batch")
    A(";;  (which covers 1..7). A control outside the fixture proves nothing -- it aborts on")
    A(";;  a missing row instead, which is how this assertion was first written.")
    A('            (expect "<<ARW-SHAPE-01>> nonce 8, outside the batch, is still on IPFS"')
    A('                "ipfs://old-primary" (at "image" (at "uri-primary" sib)))')
    A("        ]")
    A("    )")
    A('    ""')
    A(")")
    A('(print "===^^^===")')
    A("(commit-tx)")
    A("")
    A("")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A(";;|| NEXT                   >")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A("")
    A('(begin-tx "ARW-SHAPE-02 - WHICH role gates the bulk op: recreate, not update")')
    A('(env-gasmodel "table")(env-gaslimit 10000000)(env-gas 0)')
    A('(namespace "ouronet-ns")')
    A(";;==== ARW-SHAPE-02 · 01 · env-sigs (caps) ====")
    A('(print "--- [ARW-SHAPE-02 · 01 · env-sigs (caps)] ---")')
    A('(env-sigs [{ "key": "PK_AncientHodler", "caps": [] }])')
    A(";;==== ARW-SHAPE-02 · 02 · revoke role-update, keep role-recreate ====")
    A('(print "--- [ARW-SHAPE-02 · 02 · revoke role-update] ---")')
    A(";;  THE ONLY THING THAT CAN TELL THE TWO ROLES APART.")
    A(";;")
    A(";;  `UEV_RoleNftRecreateON` and `UEV_RoleNftUpdateON` emit the byte-identical")
    A(";;  refusal string, so a failing call cannot say which role it wanted. And the")
    A(";;  fixture owner holds BOTH, so any positive test passes under either reading --")
    A(";;  which is exactly how 20 emitted files came to name role-update.")
    A(";;")
    A(";;  So: turn role-update OFF, leave role-recreate ON, and run the same body. If it")
    A(";;  succeeds, role-update is provably NOT the gate. role-recreate has no toggle")
    A(";;  (`DPNF|C_MoveRecreateRole` is move-only), which is why the test is built this")
    A(";;  way round rather than the other.")
    A("(let")
    A("    (")
    A("        (ref-DPDC:module{DpdcV2} DPDC)")
    A("        (ref-TS02-C2:module{TalosStageTwo_ClientTwoV2} TS02-C2)")
    A('        (id:string "ARWQ-98c486052a51")')
    A("        (owner:string KST.ANHD)")
    A("    )")
    A("    (map print")
    A("        [")
    A('            (format "<(DPNF|C_ToggleUpdateRole off)> => [{}]"')
    A("                [(ref-TS02-C2::DPNF|C_ToggleUpdateRole owner owner owner id false)])")
    A('            (expect "<<ARW-SHAPE-02>> role-update is now OFF" false')
    A("                (ref-DPDC::UR_CA|R-Update id false owner))")
    A('            (expect "<<ARW-SHAPE-02>> role-recreate is still ON" true')
    A("                (ref-DPDC::UR_CA|R-Recreate id false owner))")
    A("        ]")
    A("    )")
    A('    ""')
    A(")")
    A(";;==== ARW-SHAPE-02 · 03 · the same body, on nonce 8, with role-update revoked ====")
    A('(print "--- [ARW-SHAPE-02 · 03 · the body still works] ---")')
    A(code2)
    A(";;==== ARW-SHAPE-02 · 04 · the verdict ====")
    A('(print "--- [ARW-SHAPE-02 · 04 · the verdict] ---")')
    A("(map print")
    A("    [")
    A('        (expect "<<ARW-SHAPE-02>> the bulk op SUCCEEDED without role-update, so role-update is NOT the gate"')
    A('            "https://arweave.net/SELFTEST/512x512/0008.jpg"')
    A('            (at "image" (at "uri-primary"')
    A('                (ouronet-ns.DPDC.UR_NativeNonceData "ARWQ-98c486052a51" false 8))))')
    A("    ]")
    A(")")
    A('(print "===^^^===")')
    A("(commit-tx)")
    A("")

    # -----------------------------------------------------------------------
    # ARW-SHAPE-03 -- THE SEMI-FUNGIBLE HALF OF THE ROUND
    # -----------------------------------------------------------------------
    # Three of the six collections are SFT, and for those the entrypoint is in a
    # DIFFERENT TALOS MODULE (TS02-C1.DPSF|*, not TS02-C2.DPNF|*). `--simulate`
    # proves those bodies RESOLVE against mainnet, but it stops at the role gate and
    # never writes, so what it cannot show is that the overlay LANDS. That is what
    # ARW-SHAPE-04 below does, through TS02-C1, on a fixture minted here.
    #
    # WHAT THIS DOES *NOT* COVER, stated plainly rather than implied: the SET-CLASS
    # path (`C_UpdateSetNonces`, 3 of the 25 migration files, 43 rows). It needs a
    # set-class fixture, and the risk it would cover is settled by READING instead,
    # conclusively:
    #
    #   BOTH Talos wrappers call the SAME core function, and `nost` picks the table.
    #     DPNF|C_UpdateNonces    -> C_UpdateNonces .. nonces      nos TRUE  ..
    #     DPNF|C_UpdateSetNonces -> C_UpdateNonces .. set-classes  nos FALSE ..
    #
    # So "does the set write reach the row `UR_SetNonceData` reads" is not a separate
    # code path that could disagree -- it is one function and one flag, and the
    # emitter pairs `kind == "set"` with exactly that reader. The same flag is why
    # `UEV_NotSetInstance` (`(if (and nost (not son)) ...)`) is OFF for the set path,
    # which is what makes a set-class DEFINITION editable while a minted INSTANCE is
    # not. Writing a fixture to re-demonstrate a branch of one `if` would be weaker
    # evidence than the `if`.
    #
    # The collection id cannot be hardcoded the way ARWQ's is: it is minted here, so
    # the body is rendered against a placeholder and the placeholder is rebound to a
    # name looked up BY TICKER. That keeps the rendered body the same shape the
    # emitter produces while leaving the id discoverable.
    A("")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A(";;|| NEXT                   >")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A("")
    A('(begin-tx "ARW-SHAPE-03 - the SFT half: DPSF via TS02-C1, nonce row AND set row")')
    A('(env-gasmodel "table")(env-gaslimit 10000000)(env-gas 0)')
    A('(namespace "ouronet-ns")')
    A(";;==== ARW-SHAPE-03 · 01 · env-sigs (STOA fee caps) ====")
    A('(print "--- [ARW-SHAPE-03 · 01 · env-sigs (STOA fee caps)] ---")')
    # THE SAME DERIVED BLOCK AS ARW-SHAPE-00, over the `dpsf` usage price.
    # The first version of this transaction invented its own one-line cap --
    #   (coin.TRANSFER KST.ANHD (ouronet-ns.STOA.GOV|STOA|SC_NAME) 1000.0)
    # -- and `GOV|STOA|SC_NAME` DOES NOT EXIST on the STOA module, so the whole
    # file failed to LOAD. That is why the gate reported a dozen unrelated suites
    # BROKEN at the same assertion count: ZALL loads this file, the load aborted,
    # and every suite after it in the same process went with it. A load error in
    # one suite is not a local failure.
    for line in fee_caps("dpsf"):
        A(line)
    A(";;==== ARW-SHAPE-03 · 02 · issue an SFT collection with a set-class ====")
    A('(print "--- [ARW-SHAPE-03 · 02 · issue SFT ARWS] ---")')
    A("(let")
    A("    (")
    A("        (ref-DPDC:module{DpdcV2} DPDC)")
    A("        (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)")
    A("        (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)")
    A("        (owner:string KST.ANHD)")
    A('        (b:string "|")')
    A("    )")
    A("    (map print")
    A("        [")
    A('            (format "<(DPSF|C_Issue ArweaveShapeS/ARWS)> => [{}]"')
    A('                [(ref-TS02-C1::DPSF|C_Issue owner owner owner "ArweaveShapeS" "ARWS"')
    A("                    true true true true true true true true)])")
    A("        ]")
    A("    )")
    A("    (let")
    A("        (")
    A(";;  LOOKED UP BY TICKER, not hardcoded: this collection is minted in this")
    A(";;  transaction, so its id suffix is not knowable when this file is generated.")
    A("            (id:string")
    A("                (at 0")
    A("                    (filter")
    A("                        (lambda (i:string)")
    A('                            (= "ARWS" (ref-DPDC::UR_Ticker i true)))')
    A("                        (ref-DPDC::URH_OwnedCollectables owner true)")
    A("                    )")
    A("                )")
    A("            )")
    A("            (nd:object{DpdcUdcV2.DPDC|NonceData}")
    A("                (ref-DPDC-UDC::UDC_NonceData")
    A("                    5.0 7.0")
    A('                    "ARWS-NAME" "ARWS-DESC"')
    A("                    (ref-DPDC-UDC::UDC_NonceMetaData 42.0 [0]")
    A('                        { "Rarity" : "ARWS-RARITY" })')
    A("                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)")
    A('                    (ref-DPDC-UDC::UDC_URI|Data "ipfs://sft-old-primary"   b b b b b b)')
    A('                    (ref-DPDC-UDC::UDC_URI|Data "ipfs://sft-old-secondary" b b b b b b)')
    A("                    (ref-DPDC-UDC::UDC_ZeroURI|Data)")
    A("                )")
    A("            )")
    A("        )")
    A("        (map print")
    A("            [")
    A('                (format "<(DPSF|C_Create 2 ARWS nonces)> => [{}]"')
    A("                    [(ref-TS02-C1::DPSF|C_Create owner")
    A("                        (ref-DPDC::UR_Verum5 id true) id [100 100]")
    A("                        [nd nd])])")
    A('                (expect "<<ARW-SHAPE-03>> ARWS has 2 native nonces" 2')
    A("                    (ref-DPDC::UR_NoncesUsed id true))")
    A('                (expect "<<ARW-SHAPE-03>> pre-state: nonce 1 uri-primary is on IPFS"')
    A('                    "ipfs://sft-old-primary"')
    A('                    (at "image" (at "uri-primary"')
    A("                        (ref-DPDC::UR_NativeNonceData id true 1))))")
    A('                (format "<(SFT collection id)> => [{}]" [id])')
    A('                ""')
    A("            ]")
    A("        )")
    A("    )")
    A(")")
    A('(print "===^^^===")')
    A("(commit-tx)")
    A("")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A(";;|| NEXT                   >")
    A(";;||>>>>>>>>>>>>>>>>>>>>>>>>>")
    A("")
    A('(begin-tx "ARW-SHAPE-04 - the emitted DPSF nonce body, rendered by emit_code")')
    A('(env-gasmodel "table")(env-gaslimit 10000000)(env-gas 0)')
    A('(namespace "ouronet-ns")')
    A(";;==== ARW-SHAPE-04 · 01 · env-sigs (caps) ====")
    A('(print "--- [ARW-SHAPE-04 · 01 · env-sigs (caps)] ---")')
    A('(env-sigs [{ "key": "PK_AncientHodler", "caps": [] }])')
    A(";;==== ARW-SHAPE-04 · 02 · THE EMITTED SFT BODY (son=true -> TS02-C1) ====")
    A('(print "--- [ARW-SHAPE-04 · 02 · the emitted SFT body] ---")')
    sft = emit_code("ARWS-PLACEHOLDER", "nonces", "DPSF|C_UpdateNonces",
                    "ouronet-ns.DPDC.UR_NativeNonceData", "true", [1, 2],
                    [("https://arweave.net/SELFTEST/512x512/s1.jpg",
                      "https://arweave.net/SELFTEST/FULL/s1.jpg"),
                     ("https://arweave.net/SELFTEST/512x512/s2.jpg",
                      "https://arweave.net/SELFTEST/FULL/s2.jpg")],
                    "TS02-C1")
    sft = sft.replace('(patron:string "PATRON_KONTO")', "(patron:string KST.ANHD)")
    sft = sft.replace(
        '(executor:string "OWNER_KONTO")',
        "(executor:string (ouronet-ns.DPDC.UR_OwnerKonto SFT-ID true))")
    sft = sft.replace('(id:string "ARWS-PLACEHOLDER")', "(id:string SFT-ID)")
    A(SFT_ID_LET)
    for line in sft.splitlines():
        A("    " + line if line.strip() else line)
    A(")")
    A(";;==== ARW-SHAPE-04 · 03 · the nonce row really changed ====")
    A('(print "--- [ARW-SHAPE-04 · 03 · verdict] ---")')
    A(SFT_ID_LET)
    A("    (map print")
    A("        [")
    A('            (expect "<<ARW-SHAPE-04>> DPSF|C_UpdateNonces overlaid uri-primary on the NONCE row"')
    A('                "https://arweave.net/SELFTEST/512x512/s1.jpg"')
    A('                (at "image" (at "uri-primary"')
    A("                    (ouronet-ns.DPDC.UR_NativeNonceData SFT-ID true 1))))")
    A('            (expect "<<ARW-SHAPE-04>> and uri-secondary, which is the slot the .png census is about"')
    A('                "https://arweave.net/SELFTEST/FULL/s2.jpg"')
    A('                (at "image" (at "uri-secondary"')
    A("                    (ouronet-ns.DPDC.UR_NativeNonceData SFT-ID true 2))))")
    A(";;  CARRY-ACROSS: the read-overlay must leave every non-URI field alone. This is")
    A(";;  the whole justification for taking a full row and replacing two keys rather")
    A(";;  than retyping the row in the transaction.")
    A('            (expect "<<ARW-SHAPE-04>> name carried across untouched" "ARWS-NAME"')
    A("                (at \"name\" (ouronet-ns.DPDC.UR_NativeNonceData SFT-ID true 1)))")
    A('            (expect "<<ARW-SHAPE-04>> ignis royalty carried across untouched" 7.0')
    A("                (at \"ignis\" (ouronet-ns.DPDC.UR_NativeNonceData SFT-ID true 1)))")
    A('            ""')
    A("        ]")
    A("    )")
    A(")")
    A('(print "===^^^===")')
    A("(commit-tx)")
    A("")
    A('(print "=== END FILE [6.1.10]_ARWEAVE-SHAPE.repl (emitted shape executes) ===")')
    return "\n".join(L) + "\n"


def filename(kind, cid, batch, idx):
    lo, hi = batch[0][2], batch[-1][2]
    tag = "sets" if kind == "set" else "n"
    return "%02d_%s_%s%05d-%05d.pact" % (idx, cid, tag, lo, hi)


SFT_ID_LET = """\
(let
    (
;;  Rebound by TICKER each time, because a `let` cannot outlive its transaction and
;;  the suffix is not knowable when this file is generated.
        (SFT-ID:string
            (at 0
                (filter
                    (lambda (i:string) (= "ARWS" (ouronet-ns.DPDC.UR_Ticker i true)))
                    (ouronet-ns.DPDC.URH_OwnedCollectables KST.ANHD true)
                )
            )
        )
    )"""


ROLE_MOVE_DOC = """\
MEASURED ON MAINNET 2026-10-08 and the single finding that most changes this round:
the collection OWNER DOES NOT HOLD `role-nft-recreate` on ANY of the six collections.
`UR_CA|R-Recreate <id> <son> <owner>` reads false everywhere, and `DPDC-N|C>SET-DATA`
opens with `UEV_RoleNftRecreateON`, which ENFORCES it -- so every batch in this round
would have aborted on its first capability, before writing anything.

The role is a SINGLETON currently held by one non-owner account, the same one on all
six collections (read via `UR_Verum6`). `C_MoveRecreateRole` moves it: the owner signs
as `executor` and names itself as `executee`.

EVERY PRECONDITION WAS CHECKED LIVE RATHER THAN ASSUMED:
  UEV_CanAddSpecialRoleON   -> UR_CanAddSpecialRole         true on all 6
  UEV_AccountRecreateState  -> old (UR_Verum6) HAS the role true on all 6
  UEV_AccountRecreateState  -> executee must NOT have it    true on all 6
  CAP_Owner                 -> the owner's signature

WHY NOT MOVE `role-set-new-uri` INSTEAD. That is the gate on `C_UpdateNonceURI`
(`UEV_RoleSetNewUriON`), the other URI-writing entrypoint. The owner lacks it too on
five of six (DHWC is the exception), so it needs the same prerequisite -- and then
costs 8,600 gas / 17.0 IGNIS per row against 1,559 / 1.0. Over 15,640 rows that is
about 267,000 IGNIS more for the same result.

ONE EXECUTOR, SIX COLLECTIONS. This file binds a single `executor` and makes six
calls with it, while `UEV_ExecutorIsCollectionOwner` checks the executor against EACH
collection's own owner. That is sound only because all six currently share one owner --
verified live, and `--simulate` is FATAL if that ever stops being true. Nothing offline
can check it, because the owner lives on chain.

THE POSTURE CHANGE IS REAL AND IS NOT LEFT AS A NOTE. `role-nft-recreate` is the
authority to rewrite ANY nonce's entire data. This hands it to the signing key, and it
is a MOVE, not a loan -- nothing puts it back. `99_AFTER_roles-restore.pact` puts it
back, and it ships as part of the round for that reason."""


def emit_roles(restore, total):
    """The prerequisite (and the restore) role-move transaction."""
    A = []
    a = A.append
    which = "99" if restore else "00"
    a(";; =========================================================================================")
    if restore:
        a(";; OURONET IPFS -> ARWEAVE URI MIGRATION -- TRANSACTION 99  (AFTER THE ROUND)")
        a(";; MOVE `role-nft-recreate` BACK OFF THE OWNER, ON ALL SIX COLLECTIONS")
    else:
        a(";; OURONET IPFS -> ARWEAVE URI MIGRATION -- TRANSACTION 00  (PREREQUISITE)")
        a(";; MOVE `role-nft-recreate` TO THE COLLECTION OWNER, ON ALL SIX COLLECTIONS")
    a(";; =========================================================================================")
    a(";;")
    for line in ROLE_MOVE_DOC.splitlines():
        a(";;   " + line if line else ";;")
    a(";;")
    a(";; =========================================================================================")
    if restore:
        a(";; RUN THIS ONLY AFTER ALL %d MIGRATION TRANSACTIONS HAVE CONFIRMED." % total)
        a(";; Set ROLE_HOLDER_KONTO to the account `UR_Verum6` named BEFORE transaction 00 --")
        a(";; read it and keep it, because transaction 00 overwrites it and this file cannot")
        a(";; recover a value the chain no longer holds:")
        a(";;")
        for key in COLL_ORDER:
            c = COLLECTIONS[key]
            a(';;     (ouronet-ns.DPDC.UR_Verum6 "%s" %s)'
              % (c["id"], str(c["son"]).lower()))
    else:
        a(";; VERIFY FIRST (every line must answer `false`; a `true` means this file has")
        a(";; already run, and re-running it ABORTS on UEV_AccountRecreateState):")
        a(";;")
        for key in COLL_ORDER:
            c = COLLECTIONS[key]
            a(';;     (ouronet-ns.DPDC.UR_CA|R-Recreate "%s" %s'
              % (c["id"], str(c["son"]).lower()))
            a(';;         (ouronet-ns.DPDC.UR_OwnerKonto "%s" %s))'
              % (c["id"], str(c["son"]).lower()))
    a(";; =========================================================================================")
    a("")
    a("(let")
    a("    (")
    a('        (patron:string "PATRON_KONTO")')
    a('        (executor:string "OWNER_KONTO")')
    if restore:
        a('        (executee:string "ROLE_HOLDER_KONTO")')
    else:
        a('        (executee:string "OWNER_KONTO")')
    a("    )")
    a("    [")
    for key in COLL_ORDER:
        c = COLLECTIONS[key]
        talos = "TS02-C1" if c["son"] else "TS02-C2"
        fam = "DPSF" if c["son"] else "DPNF"
        a("        (ouronet-ns.%s.%s|C_MoveRecreateRole patron executor executee"
          % (talos, fam))
        a('            "%s")        ;; %s' % (c["id"], c["name"]))
    a("    ]")
    a(")")
    return "\n".join(a_ for a_ in A) + "\n"


def write_multipact(emitted, bs, draft):
    """`Deploy/4_Arweave/ROUND.multipact.json` -- the whole round as ONE file.

    ONE PARALLEL GROUP, and that is a claim about this round rather than a
    default. Every file here is idempotent (re-running one rewrites the same rows
    with the same strings) and they touch DISJOINT nonces, so there is no order to
    preserve and nothing to unwind on a failure -- fix that one file and re-send
    it. A module deploy round is the opposite and would be one SEQUENTIAL group.

    The signer hint is carried because it is the single thing most likely to be
    got wrong: `UR_CreatorKonto`, not the collection owner. Signing as the owner
    fails every transaction at `UEV_RoleNftRecreateON`.
    """
    import _multipact as MP
    by_name = {filename(k, c, b, i): b
               for i, (k, c, b) in enumerate(bs, start=1)}
    txs = []
    for name in sorted(emitted):
        batch = by_name.get(name)
        if batch is None:
            continue
        code = emitted[name]
        cid = next(k for k in COLL_ORDER if "_%s_" % k in name)
        txs.append(MP.transaction(
            name[:-6], code,
            label="%s - %d rows" % (COLLECTIONS[cid]["name"], len(batch)),
            gas_limit=GAS_TOTAL_CAP,
            est_gas=gas_total(len(batch), len(code.encode()))))
    grp = MP.group(
        "IPFS -> Arweave URI migration", "parallel", txs,
        note="every transaction is idempotent and touches disjoint nonces, so "
             "order does not matter and a failure needs no unwinding")
    doc = MP.manifest(
        name="Ouronet IPFS -> Arweave URI migration (round 4)",
        source="python3 REPL/tools/_arweave.py --multipact",
        groups=[grp], draft=draft,
        signer={"role": "UR_CreatorKonto",
                "note": "Sign as the account holding role-nft-recreate -- the "
                        "CREATOR, identical on all 7 collections. NOT the "
                        "collection owner, which lacks the role and would fail "
                        "every transaction at UEV_RoleNftRecreateON."},
        defaults={"gasLimit": GAS_TOTAL_CAP})
    with open(MULTIPACT, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1)
    return doc


def write_multipact_fixture_doc():
    """A TINY committed manifest, so a reader can be tested without the real one.

    `ROUND.multipact.json` is 3.5 MB and is NOT committed: it is a byte-for-byte
    re-packaging of the 23 `.pact` files beside it, which `--check` already diffs,
    so it carries no state of its own and committing it would duplicate 3.5 MB of
    already-checked content.

    But a reader's TESTS cannot depend on a file that is not in the repository.
    This fixture is small enough to commit and exercises every structural feature
    a reader has to handle: two groups, BOTH modes, a multi-line body, and
    `draft: false` so the execute path is reachable in a test. A reader validated
    only against a draft would never exercise the branch that actually sends.
    """
    import _multipact as MP
    g1 = MP.group(
        "interfaces (order matters)", "sequential",
        [MP.transaction("01_iface", '(namespace "ouronet-ns")\n(interface DemoV1\n'
                        '    (defun UC_Demo:integer (x:integer))\n)',
                        label="DemoV1 interface", gas_limit=150_000, est_gas=120_000)],
        note="a deploy round is sequential: a module may only call what already exists")
    g2 = MP.group(
        "data batches (order does not matter)", "parallel",
        [MP.transaction("02_batch_a", "(let\n    (\n        (n:integer 1)\n    )\n    n\n)",
                        label="batch A", gas_limit=1_800_000, est_gas=900_000),
         MP.transaction("03_batch_b", "(let\n    (\n        (n:integer 2)\n    )\n    n\n)",
                        label="batch B", gas_limit=1_800_000, est_gas=900_000)],
        note="idempotent and disjoint, so they may fire together")
    return MP.manifest(
        name="Multipact format fixture (not a real round)",
        source="python3 REPL/tools/_arweave.py --multipact-fixture",
        groups=[g1, g2], draft=False,
        signer={"role": "UR_CreatorKonto", "note": "fixture only -- do not sign"},
        defaults={"gasLimit": 1_800_000},
        # PINNED, not today(). A generated artefact whose content changes with the
        # calendar is STALE every day after it is written, and the diff below would
        # report drift for no reason.
        created="2026-10-08")


def write_multipact_fixture():
    doc = write_multipact_fixture_doc()
    with open(MULTIPACT_FIXTURE, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1)
    return doc


def build(gw, resolver):
    draft = is_draft(resolver)
    rows, sets = inventory(gw), set_inventory(gw)
    bs = batches(rows, sets)
    out = {}
    # NO ROLE FILES. They were emitted until 2026-10-08 and REMOVING them is a fix,
    # not a simplification: `00` moved `role-nft-recreate` from the CREATOR to the
    # OWNER, and this round signs as the creator -- so running 00 first would have
    # taken the role away from the signer and failed all 26 batches. See
    # EQUITY_RETRACTION. `emit_roles` is kept, unreferenced by `build`, because the
    # owner route remains a valid (worse) fallback and the reasoning is worth having.
    for i, (kind, cid, batch) in enumerate(bs, start=1):
        out[filename(kind, cid, batch, i)] = emit(
            kind, cid, batch, resolver, i, len(bs), gw, draft)
    return out, bs


# ---------------------------------------------------------------------------
# --record -- THE ONLY PART OF THIS TOOL THAT TOUCHES THE NETWORK
# ---------------------------------------------------------------------------
# Kept apart from everything else on purpose. `_gate.py` must run offline, so the
# gate checks the RECORDED snapshot and never the chain; this is the deliberate,
# dated act that refreshes it -- the same split `_registrylive.py --record` uses
# for the module registry, and for the same reason.
NODE = ("https://node2.stoachain.com/chainweb/0.0/stoa/chain/0/pact/api/v1/local"
        "?preflight=false&signatureVerification=false")
READERS = {"nonce": "ouronet-ns.DPDC.UR_NativeNonceData",
           "set":   "ouronet-ns.DPDC-S.UR_SetNonceData"}
# Measured 2026-10-08: 400 rows/read answers in well under a second at ~40k gas.
RECORD_BATCH = 400


def _rpc(code):
    import base64, hashlib, time, urllib.request
    cmd = json.dumps({
        "networkId": "stoa", "payload": {"exec": {"data": {}, "code": code}},
        "signers": [], "meta": {"gasLimit": 10_000_000, "chainId": "0",
                                "gasPrice": 1e-8, "sender": "", "ttl": 600,
                                "creationTime": int(time.time()) - 60},
        "nonce": str(time.time())}, separators=(",", ":"))
    digest = hashlib.blake2b(cmd.encode(), digest_size=32).digest()
    body = json.dumps({"cmd": cmd,
                       "hash": base64.urlsafe_b64encode(digest).decode().rstrip("="),
                       "sigs": []}).encode()
    req = urllib.request.Request(NODE, data=body,
                                 headers={"Content-Type": "application/json"})
    res = json.loads(urllib.request.urlopen(req, timeout=120).read())["result"]
    if res["status"] != "success":
        raise SystemExit("_arweave --record: chain read failed: %s"
                         % str(res.get("error"))[:400])
    return res["data"]


def record():
    """Read every in-scope row's live URIs and write links/CHAIN-URIS.json.

    SCOPE IS READ FROM THE CHAIN TOO. `UR_NoncesUsed` gives the count, and the tail
    of it is EXCLUDED by `UR_NonceClass != 0` rather than by a remembered number --
    that is what keeps the 63 Bloodshed set instances and DemiBunnies 1121 out of
    the round without hardcoding `12928` and `1120`, which is exactly the sort of
    constant that goes stale the next time something is minted.
    """
    gw_from_src = None
    files, order = {}, []

    def idx(url):
        if not url.startswith(gw_from_src):
            raise SystemExit("_arweave --record: %s does not start with the gateway %s"
                             % (url, gw_from_src))
        suf = url[len(gw_from_src):]
        if suf not in files:
            files[suf] = len(order)
            order.append(suf)
        return files[suf]

    skipped = []
    found = {}
    for path in (os.path.join(BSD, "01_BSD-L.pact"), NSFR, KBN):
        hits = set(GW_RE.findall(read(path)))
        found.update({h: 1 for h in hits})
    if len(found) != 1:
        raise SystemExit("_arweave --record: the minters declare %d gateways: %s"
                         % (len(found), sorted(found)))
    gw_from_src = next(iter(found))

    out = {}
    for key in COLL_ORDER:
        coll = COLLECTIONS[key]
        cid, son = coll["id"], str(coll["son"]).lower()
        used = _rpc('(ouronet-ns.DPDC.UR_NoncesUsed "%s" %s)' % (cid, son))
        used = int(used["int"] if isinstance(used, dict) else used)
        # THE SET-INSTANCE FILTER APPLIES TO NFTs ONLY, and that asymmetry is the
        # contract's, not a convenience. UEV_NotSetInstance is
        #     (if (and nost (not son)) <enforce class = 0> true)
        # and the Talos nonce path passes nost=TRUE (TS02-C2.DPNF|C_UpdateNonces ->
        # C_UpdateNonces .. false nonces nos TRUE ..). So for son=false the guard is
        # live and a minted set instance in a batch aborts the whole transaction;
        # for son=true it short-circuits and the row is editable -- which 10_DPDC-N
        # states outright: "SFT Sets are unaffected: an SFT set-class has exactly one
        # shared nonce ... so its data legitimately stays editable."
        #
        # Filtering SFTs the same way would have silently DROPPED work: DHCD nonce 11
        # and DHWC 31-34 are set-instance nonces carrying live IPFS links, and
        # UR_NativeNonceData (UR_NonceElement) is a DIFFERENT ROW from UR_SetNonceData
        # (UR_Set) even when both currently hold the same string -- measured. Migrating
        # only the set row would leave the nonce row on IPFS.
        if coll["son"]:
            plain = list(range(1, used + 1))
        else:
            classes = []
            for s in range(1, used + 1, RECORD_BATCH):
                ns = list(range(s, min(s + RECORD_BATCH, used + 1)))
                classes += _rpc('(map (lambda (n) (ouronet-ns.DPDC.UR_NonceClass "%s" %s n)) [%s])'
                                % (cid, son, " ".join(map(str, ns))))
            plain = [n for n, c in zip(range(1, used + 1), classes)
                     if int(c["int"] if isinstance(c, dict) else c) == 0]
        block = {"name": coll["name"], "son": coll["son"]}
        for kind, keys in (("nonce", plain), ("set", _set_classes(cid, son))):
            if not keys:
                continue
            rows = {}
            for s in range(0, len(keys), RECORD_BATCH):
                chunk = keys[s:s + RECORD_BATCH]
                data = _rpc('(map (lambda (n) (let ((d (%s "%s" %s n)))'
                            ' [(at "image" (at "uri-primary" d))'
                            '  (at "image" (at "uri-secondary" d))'
                            '  (at "image" (at "uri-tertiary" d))])) [%s])'
                            % (READERS[kind], cid, son, " ".join(map(str, chunk))))
                for n, trip in zip(chunk, data):
                    if trip[2] != "|":
                        raise SystemExit(
                            "_arweave --record: %s %s %s has a NON-BAR uri-tertiary (%r). "
                            "The emitter overlays only primary and secondary, so a third "
                            "populated slot means the round would silently leave a link "
                            "behind." % (cid, kind, n, trip[2]))
                    # SCOPE IS DECIDED BY THE GATEWAY, not by an exclusion list. A row
                    # already on Arweave is DONE, not an error -- DemiBunnies set-class 1
                    # ("Bunny RGB Set") was migrated on 2026-10-02 and must be skipped
                    # rather than crash the recorder or be migrated twice.
                    on = [t.startswith(gw_from_src) for t in trip[:2]]
                    if not any(on):
                        skipped.append((cid, kind, n, trip[0]))
                        continue
                    if not all(on):
                        raise SystemExit(
                            "_arweave --record: %s %s %s is HALF migrated -- primary=%r "
                            "secondary=%r. One slot is on the IPFS gateway and the other "
                            "is not, so neither 'in scope' nor 'done' is true of this row "
                            "and a batch would overwrite the finished half."
                            % (cid, kind, n, trip[0], trip[1]))
                    rows[str(n)] = [idx(trip[0]), idx(trip[1])]
            block[kind] = rows
            print("  %-5s %-5s %6d rows (of %d used)" % (key, kind, len(rows), used),
                  flush=True)
        out[cid] = block

    doc = {"_README": "GENERATED by `python3 REPL/tools/_arweave.py --record`. "
                      "Do not hand-edit.",
           "_provenance": _provenance(order, skipped),
           "gateway": gw_from_src,
           "files": order,
           "malformed": sorted(f for f in order
                               if not (f.startswith("512x512/") or f.startswith("FULL/"))),
           "collections": out}
    with open(SNAPSHOT, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1)
    print("_arweave: wrote %s  (%d distinct files, %d malformed)"
          % (os.path.relpath(SNAPSHOT, ROOT), len(order), len(doc["malformed"])))
    if skipped:
        print("  already off the IPFS gateway, so out of scope (%d):" % len(skipped))
        for cid, kind, n, url in skipped:
            print("    %s %s %s -> %s" % (cid, kind, n, url[:72]))
    return 0


def _set_classes(cid, son):
    """DHB's set-class DEFINITIONS -- `nost=false`, a separate address space."""
    n = _rpc('(ouronet-ns.DPDC.UR_SetClassesUsed "%s" %s)' % (cid, son))
    return list(range(1, int(n["int"] if isinstance(n, dict) else n) + 1))


def _provenance(order, skipped=()):
    skips = ["%s %s %s -> %s" % t for t in skipped]
    return {
        "recorded": _today(),
        "source": "mainnet StoaChain chain 0 /local via node2.stoachain.com",
        "readers": READERS,
        "why_the_chain_and_not_the_minters":
            "The chain is the SOURCE OF TRUTH for old links. This replaced a port of the "
            "UC_*Link functions that measured WRONG on 13,060 of 15,548 rows (84%): every "
            "DHB secondary slot is .png on chain while the port hardcoded .jpg, and the "
            "'padding anomaly' the port reproduced (E_048/R_072/C_00144) DOES NOT EXIST on "
            "chain -- those rows read E_48/R_72/C_144. A derived old link that disagrees "
            "with the row migrates the WRONG file, and nothing downstream can notice "
            "because the plan stays self-consistent.",
        "scope_is_derived":
            "In-scope nonces are those with UR_NonceClass = 0, asked per nonce rather than "
            "taken from a remembered count. That is what excludes the 63 Bloodshed set "
            "INSTANCES (UEV_NotSetInstance refuses them permanently, and one in a batch "
            "aborts the whole transaction) and DemiBunnies 1121.",
        "slots_measured":
            "Only uri-primary.image and uri-secondary.image carry links; --record is FATAL "
            "on a non-BAR uri-tertiary.image rather than silently leaving it behind.",
        "distinct_files": len(order),
        "out_of_scope_already_migrated": skips,
    }


def _today():
    import datetime
    return datetime.date.today().isoformat()


# ---------------------------------------------------------------------------
# --simulate -- PRE-FLIGHT EVERY EMITTED FILE AGAINST THE LIVE CHAIN
# ---------------------------------------------------------------------------
# Network, like --record, so it is NOT in the gate. It exists because the gate is
# necessarily blind to the only questions that matter on the day: are the collection
# ids still right, is the snapshot still current, does every module reference and
# arity still resolve, and is the role actually in place yet.
#
# Each file is sent to /local UNSIGNED with the real accounts substituted. Unsigned
# means it cannot write, so the useful signal is WHERE it stops:
#
#   "Keyset failure" on the signer's own guard -> everything before the signature
#                                                 resolved. The file is sound and the
#                                                 only thing missing is the signature.
#   UEV_RoleNftRecreateON                      -> the signer does not hold the
#                                                 recreate role. With the creator as
#                                                 signer this should NEVER appear; if
#                                                 it does, the role has moved.
#   anything else                              -> a REAL defect. Do not sign.
#
# A wrong collection id, a stale snapshot nonce, a renamed entrypoint or a bad arity
# all surface here as "anything else", and none of them can surface offline.
SIM_OK_MARKERS = ("Keyset failure",)
SIM_ROLE_MARKERS = ("UEV_RoleNftRecreateON", "cannot be Updated while using")


def simulate(emitted):
    """Send every emitted body to /local unsigned and classify where it stops."""
    # THE CREATOR, NOT THE OWNER. `DPDC-N|C>SET-DATA` gates on
    # `UEV_RoleNftRecreateON` plus the signer's own account ownership, and never on
    # collection ownership -- so the account that matters is whoever HOLDS the
    # recreate role. Measured: that is `UR_CreatorKonto`, identical on all seven
    # collections, and `UR_Verum6` agrees. Simulating as the OWNER was what produced
    # 25 misleading `NEEDS-00` verdicts and a two-transaction role dance that would
    # have broken the round. See EQUITY_RETRACTION.
    owners = {}
    for key in COLL_ORDER:
        c = COLLECTIONS[key]
        owners[key] = _rpc('(ouronet-ns.DPDC.UR_CreatorKonto "%s" %s)'
                           % (c["id"], str(c["son"]).lower()))
    distinct = {o for o in owners.values()}
    print("recreate-role holders across %d collections: %d distinct"
          % (len(COLL_ORDER), len(distinct)))
    # ONE SIGNER FOR THE WHOLE ROUND is a fact worth asserting rather than assuming.
    # Every emitted file binds its own `executor`, so divergence would not break a
    # transaction -- but it WOULD mean the round needs more than one signer, and a
    # consecutive run through one unlocked wallet silently assumes it does not.
    if len(distinct) != 1:
        print("_arweave --simulate: WARNING -- the %d collections have %d distinct "
              "recreate-role holders, so this round needs more than one signer. "
              "Group the files per signer before a consecutive run."
              % (len(COLL_ORDER), len(distinct)))
        for key in COLL_ORDER:
            print("    %-6s %s" % (key, owners[key][:40]))

    worst = 0
    print("\n%-34s%-14s%s" % ("file", "verdict", "where it stopped"))
    print("-" * 100)
    for name, text in sorted(emitted.items()):
        key = next((k for k in COLL_ORDER if "_%s_" % k in name), None)
        if key is None:
            print("%-34s%-14s%s" % (name, "SKIP", "not a collection batch"))
            continue
        owner = owners[key]
        # ensure_ascii=False IS LOAD-BEARING. Ouronet account ids are non-ASCII
        # (`\u047a.\u00e9X\u00f8d...`), and a default json.dumps escapes them to
        # \uXXXX, which Pact rejects outright: "String literal parsing error: Invalid
        # escape sequence". The first run of this mode reported FAIL on all 27 files
        # for that reason alone -- a defect in the CHECKER that looked exactly like a
        # defect in everything it checked.
        q = json.dumps(owner, ensure_ascii=False)
        body = text[text.index("\n(let"):] if "\n(let" in text else text
        code = body.replace('"PATRON_KONTO"', q).replace('"OWNER_KONTO"', q)
        code = code.replace('"ROLE_HOLDER_KONTO"', q)
        try:
            _rpc(code)
            verdict, detail, rank = "SIGNED?!", "succeeded unsigned -- investigate", 2
        except SystemExit as exc:
            msg = str(exc)
            if any(m in msg for m in SIM_OK_MARKERS):
                verdict, detail, rank = "OK", "stops at the signature", 0
            elif any(m in msg for m in SIM_ROLE_MARKERS):
                verdict, detail, rank = "NEEDS-00", "stops at the recreate role gate", 0
            else:
                verdict, detail, rank = "FAIL", msg.split("message':")[-1][:72], 2
        worst = max(worst, rank)
        print("%-34s%-14s%s" % (name, verdict, detail))
    print("-" * 100)
    if worst:
        print("_arweave --simulate: at least one file did NOT resolve. DO NOT SIGN.")
    else:
        print("_arweave --simulate: every file resolves against the live chain and "
              "stops at the SIGNATURE -- nothing is waiting on a role move. Sign as "
              "the recreate-role holder (UR_CreatorKonto), not the collection owner.")
    return 1 if worst else 0


def main():
    args = sys.argv[1:]
    if "--record" in args:
        return record()
    gw = gateway()
    rows = inventory(gw)
    sets = set_inventory(gw)
    files = distinct_files(rows + sets)
    resolver, mode, missing, unknown = load_links(gw, files)
    n = len(rows) + len(sets)

    if "--inventory" in args:
        print("IPFS gateway (from sources): %s\n" % gw)
        per = {}
        for cid, lane, nonce, pos, a, b in rows:
            per.setdefault((cid, lane), []).append(nonce)
        for cid, lane, nonce, pos, a, b in sets:
            per.setdefault((cid, "set-class"), []).append(nonce)
        print("%-30s%-11s%7s%4s  %-14s" % ("collection", "kind", "rows", "son", "range"))
        print("-" * 68)
        for (cid, lane), ns in per.items():
            print("%-30s%-11s%7d%4s  %d..%d"
                  % (COLLECTIONS[cid]["name"], lane, len(ns),
                     "T" if COLLECTIONS[cid]["son"] else "F", min(ns), max(ns)))
        print("-" * 68)
        print("%-28s%8d rows" % ("TOTAL", n))
        print("\ndistinct IPFS files needing an Arweave counterpart: %d" % len(files))
        print("  (far fewer than rows: Bloodshed shares images by mod 8/48/72/144)")
        print("\nexec gas  {:>14,}   @{:,}/row".format(n * GAS_PER_NONCE, GAS_PER_NONCE))
        print("IGNIS     {:>14,.0f}   @{}/row".format(n * IGNIS_PER_NONCE, IGNIS_PER_NONCE))
        print("batches   {:>14}   at {} rows/tx ({:,} gas budget)".format(
            len(batches(rows, sets)), rows_per_tx(), GAS_TOTAL_CAP))
        return 0

    if "--files" in args:
        for f in sorted(files):
            print(f)
        return 0

    if "--selftest" in args:
        with open(SELFTEST, "w", encoding="utf-8") as fh:
            fh.write(selftest_repl())
        print("_arweave: wrote %s" % os.path.relpath(SELFTEST, ROOT))
        return 0

    if ("--plan" in args or "--write" in args or "--check" in args
            or "--simulate" in args
            or ("--multipact" in args and "--multipact-fixture" not in args)):
        emitted, bs = build(gw, resolver)

    if "--multipact-fixture" in args:
        import _multipact as MP
        doc = write_multipact_fixture()
        print("_arweave: wrote %s" % os.path.relpath(MULTIPACT_FIXTURE, ROOT))
        print(MP.summary(doc))
        return 0

    if "--multipact" in args:
        import _multipact as MP
        doc = write_multipact(emitted, bs, is_draft(resolver))
        print("_arweave: wrote %s" % os.path.relpath(MULTIPACT, ROOT))
        print()
        print(MP.summary(doc))
        print()
        if doc["draft"]:
            print("  DRAFT: the link map still holds placeholders, so this manifest "
                  "carries\n  `draft: true` and the UI reader must REFUSE to execute "
                  "it. Replace\n  links/LINKS.json, re-run --write then --multipact.")
        return 0

    if "--simulate" in args:
        return simulate(emitted)

    if "--plan" in args:
        print("links/LINKS.json: %s"
              % ("ABSENT -- every link in every body is a placeholder"
                 if resolver is None else "%s mode" % mode))
        if resolver is not None and missing:
            print("  %d of %d files still unmapped" % (len(missing), len(files)))
        print()
        print("%-34s%7s%11s%11s  contents"
              % ("file", "rows", "bytes", "~gas tot"))
        print("-" * 98)
        tg = 0
        # ZIP BY NAME, NOT BY POSITION. `emitted` also holds the two role files, which
        # are not batches -- zipping it against `bs` positionally shifted every row by
        # one and printed `00_PREREQUISITE_roles.pact` as "892 rows, DemiBunnies".
        by_name = {filename(k, c, b, i): (k, c, b)
                   for i, (k, c, b) in enumerate(bs, start=1)}
        for name, text in emitted.items():
            nbytes = "{:,}".format(len(text.encode()))
            if name not in by_name:
                print("%-34s%7s%11s%11s  %s"
                      % (name, "-", nbytes, "-",
                         "role move (prerequisite)" if name.startswith("00")
                         else "role move (restore, after the round)"))
                continue
            kind, cid, batch = by_name[name]
            # THE TOTAL, not the exec term. The column is headed `~gas` and is the
            # number the 1.8M cap applies to, so showing exec alone understated every
            # row by the size charge -- which is the part that is non-linear and the
            # only reason the batch size is 1,078 rather than 1,149.
            g = gas_total(len(batch), len(text.encode()))
            tg += g
            print("%-34s%7d%11s%11s  %s: %s"
                  % (name, len(batch), nbytes, "{:,.0f}".format(g),
                     COLLECTIONS[cid]["name"], kind))
        print("-" * 98)
        print("%-34s%7d%11s%11s  %d transactions, worst %s of the %s cap"
              % ("total", n,
                 "{:,}".format(sum(len(t.encode()) for t in emitted.values())),
                 "{:,.0f}".format(tg), len(emitted),
                 "{:,.0f}".format(max(
                     gas_total(len(b), len(emitted[filename(k, c, b, i)].encode()))
                     for i, (k, c, b) in enumerate(bs, start=1))),
                 "{:,}".format(GAS_TOTAL_CAP)))
        return 0

    if "--write" in args:
        os.makedirs(DEPLOY, exist_ok=True)
        for stale in os.listdir(DEPLOY):
            if stale.endswith(".pact") and stale not in emitted:
                os.remove(os.path.join(DEPLOY, stale))
        for name, text in emitted.items():
            with open(os.path.join(DEPLOY, name), "w", encoding="utf-8") as fh:
                fh.write(text)
        print("_arweave: wrote %d transactions to %s/"
              % (len(emitted), os.path.relpath(DEPLOY, ROOT)))
        if is_draft(resolver):
            print("  DRAFT: the link map is absent or still holds placeholders, so every")
            print("  emitted file carries a DO-NOT-SIGN banner. Replace links/LINKS.json")
            print("  and re-run --write; the banner removes itself.")
        return 0

    if "--check" in args:
        bad = 0
        # Keyed by (collection, nonce): a bare nonce list collides across
        # collections, because KBN nonce 1 and DHN nonce 1 are different rows. The
        # first version of this check did exactly that and reported a duplicate on
        # a correct plan.
        covered = [(r[0], r[2]) for r in rows]
        if len(covered) != len(set(covered)):
            dupes = sorted({c for c in covered if covered.count(c) > 1})[:3]
            print("_arweave: CHECK a row is covered twice, e.g. %s" % (dupes,))
            bad += 1
        # CONTIGUITY, per collection and per kind. Hardcoding ("KBN","DHN","DHB") here
        # is how three live collections stayed unchecked while they were also
        # unplanned -- the list and the plan were two statements of the same thing and
        # only one of them was wrong. It is derived from COLL_ORDER now.
        for cid in COLL_ORDER:
            for kind, src in (("nonce", rows), ("set", sets)):
                ns = sorted(r[2] for r in src if r[0] == cid)
                if ns and ns != list(range(1, len(ns) + 1)):
                    print("_arweave: CHECK %s %s coverage is not contiguous 1..%d "
                          "(got %d..%d with %d rows)"
                          % (cid, kind, len(ns), ns[0], ns[-1], len(ns)))
                    bad += 1

        # THE EXCLUSIONS, each asserted against the PLAN rather than remembered.
        snap = snapshot()
        # 1] INVERTED 2026-10-08. This pair used to assert the equity collection was
        #    ABSENT, encoding the conclusion EQUITY_RETRACTION withdraws. The useful
        #    assertion is the opposite one: equity IS in scope, and a future edit must
        #    not quietly drop it again -- which is exactly how it came to be missing
        #    the first time.
        if not any(COLLECTIONS[k]["id"].startswith("E|") for k in COLL_ORDER):
            print("_arweave: CHECK no equity (E|) collection is in COLL_ORDER. It IS "
                  "migratable -- the recreate role sits on the creator, not the owner "
                  "(see EQUITY_RETRACTION). Do not re-exclude it without new evidence.")
            bad += 1
        if not any(cid.startswith("E|") for cid in snap["collections"]):
            print("_arweave: CHECK the snapshot holds no equity (E|) collection -- "
                  "re-record it")
            bad += 1
        # 2] Nothing already off the IPFS gateway may be planned -- that is the
        #    already-migrated RGB bunny, and re-migrating it would overwrite a good
        #    Arweave link with a guess. `files` is checked against the gateway below;
        #    this asserts the snapshot did the scoping rather than trusting it.
        for f in snap["files"]:
            if f.startswith(("http://", "https://", "ar://")):
                print("_arweave: CHECK snapshot file %r is an absolute URL -- the "
                      "snapshot stores gateway-relative suffixes, so this row was not "
                      "scoped by --record" % f[:60])
                bad += 1
        # 3] Frozen NFT set instances must stay out. The snapshot is keyed by nonce and
        #    --record filters on UR_NonceClass for son=false, so what is checkable here
        #    is that no NFT collection plans a nonce beyond its class-0 run.
        for key in COLL_ORDER:
            if COLLECTIONS[key]["son"]:
                continue
            ns = [r[2] for r in rows if r[0] == key]
            block = snap["collections"].get(COLLECTIONS[key]["id"], {})
            recorded = {int(n) for n in block.get("nonce", {})}
            extra = sorted(set(ns) - recorded)
            if extra:
                print("_arweave: CHECK %s plans %d nonce(s) the snapshot did not record, "
                      "e.g. %s -- a minted Set instance in a batch aborts the whole "
                      "transaction" % (key, len(extra), extra[:3]))
                bad += 1
        for f in files:
            if not f.startswith(gw):
                print("_arweave: CHECK a planned old link does not start with the "
                      "gateway read from the sources: %s" % f)
                bad += 1
        for name, text in emitted.items():
            if len(text.encode()) > MAXBYTES:
                print("_arweave: CHECK %s is %d bytes, over the %d cap"
                      % (name, len(text.encode()), MAXBYTES))
                bad += 1
        # THE BUDGET IS CHECKED ON THE EMITTED BYTES, NOT ON THE PLANNER'S ESTIMATE.
        # `_deploybundle` learned this the hard way: the planner budgets on a proxy,
        # the header grows, two transactions go over, and the only thing that notices
        # is a line in a passing run. So this reads the file that would be signed and
        # is FATAL -- a proxy that is checked against the real thing is fine, a proxy
        # whose check is advisory is not a budget.
        by_name_g = {filename(k, c, b, i): b
                     for i, (k, c, b) in enumerate(bs, start=1)}
        for name, text in emitted.items():
            batch = by_name_g.get(name)
            if batch is None:
                continue
            nbytes = len(text.encode())
            tot = gas_total(len(batch), nbytes)
            if tot > GAS_TOTAL_CAP:
                print("_arweave: CHECK %s is %s rows / %s bytes = %s gas total "
                      "(exec %s + size %s), over the %s cap"
                      % (name, len(batch), "{:,}".format(nbytes),
                         "{:,.0f}".format(tot),
                         "{:,}".format(GAS_FIXED + GAS_PER_NONCE * len(batch)),
                         "{:,.0f}".format(gas_size(nbytes)),
                         "{:,}".format(GAS_TOTAL_CAP)))
                bad += 1
        if unknown:
            print("_arweave: CHECK LINKS.json names %d file(s) not in scope, e.g. %s"
                  % (len(unknown), unknown[0]))
            bad += 1
        # THE COMMITTED FIXTURE IS A GENERATED ARTEFACT, so it is diffed like every
        # other one ("Generated artefacts are gate-enforced" -- CLAUDE.md). It is
        # the thing OuronetUI's reader TESTS against, so a hand-edit here would
        # quietly change what the reader is proven to accept, in the other repo,
        # with nothing in this one objecting. `ROUND.multipact.json` needs no such
        # check: it is not committed and is fully determined by the .pact files
        # diffed below.
        if os.path.exists(MULTIPACT_FIXTURE):
            want = json.dumps(write_multipact_fixture_doc(), indent=1)
            if read(MULTIPACT_FIXTURE) != want:
                print("_arweave: CHECK links/SAMPLE.multipact.json is STALE or "
                      "hand-edited -- regenerate with --multipact-fixture")
                bad += 1
        else:
            print("_arweave: CHECK links/SAMPLE.multipact.json is MISSING -- it is "
                  "the fixture OuronetUI's multipact reader tests against")
            bad += 1
        if os.path.exists(UI_FIXTURE_COPY):
            if read(UI_FIXTURE_COPY) != read(MULTIPACT_FIXTURE):
                print("_arweave: CHECK OuronetUI's copy of SAMPLE.multipact.json has "
                      "DRIFTED from this one (%s). The reader's tests are passing "
                      "against a format this repository no longer emits."
                      % os.path.relpath(os.path.normpath(UI_FIXTURE_COPY), ROOT))
                bad += 1

        on_disk = (set(f for f in os.listdir(DEPLOY) if f.endswith(".pact"))
                   if os.path.isdir(DEPLOY) else set())
        if on_disk:
            for name in sorted(on_disk - set(emitted)):
                print("_arweave: CHECK ORPHAN %s -- not in the plan" % name)
                bad += 1
            for name, text in emitted.items():
                if name not in on_disk:
                    print("_arweave: CHECK MISSING %s" % name)
                    bad += 1
                elif read(os.path.join(DEPLOY, name)) != text:
                    print("_arweave: CHECK STALE %s -- regenerate with --write" % name)
                    bad += 1
        if bad:
            return 1
        if resolver is None:
            print("_arweave: clean -- {:,} rows planned over {} transactions, "
                  "{:,} Arweave URLs PENDING (links/LINKS.json absent)".format(
                      n, len(emitted), len(files)))
        elif missing:
            print("_arweave: clean -- plan consistent, but {:,} of {:,} Arweave URLs "
                  "are still unmapped".format(len(missing), len(files)))
        elif is_draft(resolver):
            print("_arweave: clean -- {:,} rows, {} transactions, all {:,} links mapped "
                  "({} mode)".format(n, len(emitted), len(files), mode))
            print("_arweave: DRAFT -- links/LINKS.json still holds placeholder values, so "
                  "every\n  emitted transaction carries a DO-NOT-SIGN banner. Structure is "
                  "checked;\n  the links are not real.")
        else:
            print("_arweave: clean -- {:,} rows, {} transactions, all {:,} links "
                  "resolved ({} mode) -- NO draft markers, this round is signable"
                  .format(n, len(emitted), len(files), mode))
        return 0

    print(__doc__.strip().splitlines()[0])
    print("\nusage: _arweave.py [--inventory | --files | --plan | --write | --check]")
    print("\n  --inventory   every in-scope row, by collection and lane, with the budget")
    print("  --files       the distinct IPFS URLs, one per line -- LINKS.json's key list")
    print("  --plan        the emitted transaction table")
    print("  --write       emit Deploy/4_Arweave/*.pact")
    print("  --check       gate mode: coverage, exclusions, budget, and the STALE diff")
    if resolver is None:
        print("\nlinks/LINKS.json is ABSENT -- {:,} Arweave URLs still needed.".format(
            len(files)))
        print("Run --files for the key list; links/LINKS.schema.json for the shape.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
