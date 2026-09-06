#!/usr/bin/env python3
"""#76 — deterrence worksheet: per client/admin op, approx COMPUTE (module-internal transitive
weighted primitive cost) + the OWNER-DECIDED deter factors (2026-09-05 batch). DPMF excluded.

v2 (IGNIS rehaul substage 2) — cost model per owner decisions 2026-09-05
(memories/2026-09-05-ignis-pricing-feedback.md):
  - Option-A size buckets: per-table size class from its defschema field weights
    (bool/integer/decimal/time=1, string/guard=2, object/list/other=4):
    S<=5pts -> w x1/r x1;  M 6-12 -> w x2/r x2;  L 13-24 -> w x3/r x5;  XL 25+ -> w x5/r x9
    (read mults calibrated against measured gas, substage 6).
  - insert/write = 3 x write-bucket of the target table.
  - read = 1 x read-bucket;  scan (select/keys/fold-db) = 1 x read-bucket.
  - update = ceil(fields-in-update-literal / 4), min 1 (per-call-site field counting;
    divisor CALIBRATED in substage 6: measured 5-field/1-field = 2.08x, ceil(/2) predicted 3.0x).
  - xcall = 2 per genuine inter-module hop; the Talos->core entry hop is excluded BY
    CONSTRUCTION (analysis roots at the core entrypoint; 3_Talos + TS02-CPAD wrappers are
    out of scope — they delegate + collect, their cost IS the wrapped core op).
  - qualified op names (`STOA-PID|C_*`, `C_2|*`, ...) now matched (v1 regex gap dropped the
    5 SWPLC single-tx add-liquidity ops).
  - deter applies ONLY to the IG|TX(1) base unit, never the component sum.
  - OWNER_DECISIONS encodes the approved 2026-09-05 pricing batch; this same table feeds the
    substage-3 IGNIS defconst generation. 1 ignis = 1 USD/EUR cent (hard peg).
"""
import re, glob, math, importlib.util
from collections import Counter
spec=importlib.util.spec_from_file_location('lf','REPL/_letfix.py'); lf=importlib.util.module_from_spec(spec); spec.loader.exec_module(lf)
IG_TX,IG_INS,IG_UPD_FLDDIV,IG_X = 1,3,4,2  # write base 3 x bucket; update = ceil(flds/4); xcall 2
PREFQ=re.compile(r'^(?:[A-Za-z0-9-]+\|)?(C{1,2}p?_|A{1,2}p?_)')
ADMINQ=re.compile(r'^(?:[A-Za-z0-9-]+\|)?A{1,2}p?_')

ALLPACT=[m for m in glob.glob('1_SOVEREIGN/**/*.pact',recursive=True)+glob.glob('2_CITIZEN/**/*.pact',recursive=True)]

# ---- current flat GAS| charges (de-facto deterrents already in code) ----
GAS={}
for f in ALLPACT:
    for m in re.finditer(r'\(defconst (GAS\|[A-Za-z0-9-]+)(?::decimal)?\s+([0-9.]+)', open(f).read()):
        GAS[m.group(1)]=float(m.group(2))
def cur_flat(txt):
    vs=[GAS[g] for g in set(re.findall(r'GAS\|[A-Za-z0-9-]+',txt)) if g in GAS]
    return max(vs) if vs else None

# ---- Option-A size buckets: schema points -> per-table (write-mult, read-mult) ----
def _field_pts(t):
    if re.match(r'^(bool|integer|decimal|time)$',t): return 1
    if re.match(r'^(string|guard)$',t): return 2
    return 4  # object{...}, [lists], keysets, unknown -> heavy
def _bucket(pts):
    # (write-mult, read-mult). Read mults CALIBRATED vs measured Pact gas in substage 6
    # (REPL/Kursan/IGNIS-bucket-calibration.repl): M/L/XL vs S measured 2.4/5.4/9.4, so the
    # original 1/1/2/3 was far too flat. Writes measured 1.72/3.28/5.36 vs 2/3/5 => unchanged.
    if pts<=5:  return (1,1)
    if pts<=12: return (2,2)
    if pts<=24: return (3,5)
    return (5,9)
SCHEMA_PTS={}
for f in ALLPACT:
    s=open(f).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
    for k in range(len(toks)):
        if toks[k][0]=='(':
            j=k+1
            while j<len(toks) and toks[j][0]=='ws': j+=1
            if j<len(toks) and toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]]=='defschema':
                jj=j+1
                while toks[jj][0]=='ws': jj+=1
                nm=s[toks[jj][1]:toks[jj][2]]
                body=s[toks[jj][2]:toks[match[k]][1]]
                body=re.sub(r'@doc\s+"(?:[^"\\]|\\.)*"','',body,flags=re.S)  # strip doc strings
                pts=0
                for fm in re.finditer(r'^\s*([A-Za-z0-9|_-]+):(\S+)',body,flags=re.M):
                    pts+=_field_pts(fm.group(2).rstrip(')'))
                SCHEMA_PTS[nm]=max(SCHEMA_PTS.get(nm,0),pts)  # collisions -> max (conservative)
T2M={}
for f in ALLPACT:
    for m in re.finditer(r'\(deftable\s+([A-Za-z0-9|_-]+):\{(?:[A-Za-z0-9_-]+\.)?([A-Za-z0-9|_-]+)\}',open(f).read()):
        T2M[m.group(1)]=_bucket(SCHEMA_PTS.get(m.group(2),6))  # unknown schema -> M

def _update_fields(txt,start):
    """Count fields in the object literal of an (update ...) call site."""
    i=txt.find('{',start)
    if i<0: return 1
    depth=0; n=0; j=i; instr=False
    while j<len(txt):
        c=txt[j]
        if instr:
            if c=='"' and txt[j-1]!='\\': instr=False
        elif c=='"': instr=True
        elif c=='{': depth+=1
        elif c=='}':
            depth-=1
            if depth==0: break
        elif c==':' and depth==1: n+=1
        j+=1
    return max(1,n)

def prim_costs(txt):
    ins=upd=r=sc=x=0; cost=0
    for m in re.finditer(r'\((?:insert|write)\s+([A-Za-z0-9|_-]+)',txt):
        ins+=1; cost+=IG_INS*T2M.get(m.group(1),(1,1))[0]
    for m in re.finditer(r'\(update\s+([A-Za-z0-9|_-]+)',txt):
        upd+=1; cost+=max(1,math.ceil(_update_fields(txt,m.end())/IG_UPD_FLDDIV))
    for m in re.finditer(r'\((?:read|with-read|with-default-read)\s+([A-Za-z0-9|_-]+)',txt):
        r+=1; cost+=T2M.get(m.group(1),(1,1))[1]
    for m in re.finditer(r'\((?:select|keys|fold-db)\s+([A-Za-z0-9|_-]+)',txt):
        sc+=1; cost+=T2M.get(m.group(1),(1,1))[1]
    x=len(re.findall(r'ref-[A-Za-z0-9|-]+::',txt)); cost+=IG_X*x
    return ins,upd,r,sc,x,cost

ISSUE=re.compile(r'^(?:[A-Za-z0-9-]+\|)?(C{1,2}p?_|A{1,2}p?_)(Issue|Create|Deploy|Open|Define|Mint|Make|New)')
USAGE=re.compile(r'(Stake|Unstake|Collect|Inject|Transfer|Fuel|Retrieve|Coil|Curl|Vacate|Sweep|Fix|Drain|Flush|Unstale|Bulk|Swap|Liquidity|Compress|Wrap|Deposit|Withdraw|Brumate|Constrict|Syphon|WipeSlice)')
def role(n): return 'ISSUE' if ISSUE.match(n) else ('USAGE' if USAGE.search(n) else 'SETUP')

COLS={'op':'#8250df','role':'#57606a','ins':'#cf222e','upd':'#e36209','r':'#0969da',
      's':'#1f883d','x':'#8b5cf6','comp':'#0b7285','cur':'#9a6700','deter':'#bf3989','fin':'#116329'}
def col(v,c): return f'<span style="color:{c}">{v}</span>'
def num(v,c): return col(f'{v:g}',c) if v else '·'

# ---- OWNER DECISIONS (2026-09-05 batch, memories/2026-09-05-ignis-pricing-feedback.md) ----
# (module-file, op) -> dict(deter=float|None|('SPLIT',sft,nft), why=str, role=str?, note=str?)
# deter=None => IGNIS-EXEMPT. This table is the substage-3 defconst input.
_ISS='ISSUANCE GATE — {} (1 ignis = 1 cent) → {} ignis base + components'
WIPE_NOTE=' [+5 ignis per nonce wiped — owner directive: wipe scales with nonce count (substage-5 constant)]'
VAR_NOTE=' [VARIABLE-SCALE: components reflect one run shape, not fixed — {}]'
OWNER={
 ('02_IGNIS.pact','C_TransferDalosFuel'):dict(deter=None,why='IGNIS-EXEMPT — basically a coin.transfer execution'),
 ('05_DPTF.pact','C_Issue'):dict(deter=1000.0,why=_ISS.format('true fungible = $10','1000')),
 ('06_DPOF.pact','C_Issue'):dict(deter=1000.0,why=_ISS.format('ortofungible = $10','1000')),
 ('04_DPDC-I.pact','C_IssueDigitalCollection'):dict(deter=('SPLIT',2000.0,2500.0),
    why='ISSUANCE GATE — son:bool splits SFT $20/2000ig vs NFT $25/2500ig (1 ignis = 1 cent)'),
 ('08_ATS.pact','C_Issue'):dict(deter=4000.0,why=_ISS.format('autostake pair = $40','4000')),
 ('16_SWPI.pact','C_Issue'):dict(deter=5000.0,why=_ISS.format('swap pair = $50','5000')),
 ('20_MTX-SWP.pact','C_IssueStablePool'):dict(deter=5000.0,why=_ISS.format('swap pair = $50','5000')),
 ('20_MTX-SWP.pact','C_IssueStandardPool'):dict(deter=5000.0,why=_ISS.format('swap pair = $50','5000')),
 ('20_MTX-SWP.pact','C_IssueWeightedPool'):dict(deter=5000.0,why=_ISS.format('swap pair = $50','5000')),
 ('11_EQUITY+.pact','C_IssueShareholderCollection'):dict(deter=10000.0,why=_ISS.format('shareholder collection = $100','10000')),
 ('11_VST.pact','C_CreateFrozenLink'):dict(deter=1000.0,why='ISSUANCE GATE — ties to ortofungible issuance cost ($10/1000ig, owner directive)'),
 ('11_VST.pact','C_CreateHibernatingLink'):dict(deter=1000.0,why='ISSUANCE GATE — ties to ortofungible issuance cost ($10/1000ig, owner directive)'),
 ('11_VST.pact','C_CreateReservationLink'):dict(deter=1000.0,why='ISSUANCE GATE — ties to ortofungible issuance cost ($10/1000ig, owner directive)'),
 ('11_VST.pact','C_CreateSleepingLink'):dict(deter=1000.0,why='ISSUANCE GATE — ties to ortofungible issuance cost ($10/1000ig, owner directive)'),
 ('11_VST.pact','C_CreateVestingLink'):dict(deter=1000.0,why='ISSUANCE GATE — ties to ortofungible issuance cost ($10/1000ig, owner directive)'),
 ('01_ANK.pact','C_IssueTrueFungibleAnchor'):dict(deter=500.0,why='ISSUANCE GATE — anchor = half its asset type (true fungible 1000ig/2)'),
 ('01_ANK.pact','C_IssueSemiFungibleAnchor'):dict(deter=1000.0,why='ISSUANCE GATE — anchor = half its asset type (semifungible 2000ig/2)'),
 ('01_ANK.pact','C_IssueNonFungibleAnchor'):dict(deter=1250.0,why='ISSUANCE GATE — anchor = half its asset type (nonfungible 2500ig/2)'),
 ('01_ANK.pact','C_IssueNonFungibleSetAnchor'):dict(deter=1250.0,why='ISSUANCE GATE — same tier as NonFungibleAnchor (owner 2026-09-05: no separate Set tier)'),
 ('01_ANK.pact','C_RevokeAnchor'):dict(deter=100.0,why='owner-priced deterrent for anchor revocation'),
 ('01_ANK.pact','C_RevokeBoostClass'):dict(deter=500.0,why='owner-priced deterrent for boost-class revocation'),
 ('02_SCORE.pact','C_CombineTripletScoreModel'):dict(deter=100.0,why='owner-priced deterrent for combining a triplet score model'),
 ('03_AQP.pact','C_AddScore'):dict(deter=200.0,why='owner-priced deterrent for adding a score to a pool'),
 ('03_AQP.pact','C_DisablePoolStake'):dict(deter=50.0,why='owner-priced deterrent — pool-stake toggle'),
 ('03_AQP.pact','C_EnablePoolStake'):dict(deter=50.0,why='owner-priced deterrent — pool-stake toggle'),
 ('03_AQP.pact','C_RevokeScore'):dict(deter=250.0,why='owner-priced deterrent for revoking a score from a pool'),
 ('05_FVT.pact','CC_UnstaleMyScores'):dict(deter=100.0,why='owner-priced deterrent — heavy unstale scan over caller\'s scores'),
 ('05_FVT.pact','C_SetCommonDenominator'):dict(deter=100.0,why='owner-priced deterrent — FVT split-mode/denominator setup'),
 ('05_FVT.pact','C_SetMosaic'):dict(deter=100.0,why='owner-priced deterrent — FVT split-mode/denominator setup'),
 ('05_FVT.pact','C_SetQualitySplit'):dict(deter=100.0,why='owner-priced deterrent — FVT split-mode/denominator setup'),
 ('05_FVT.pact','C_SetSplitMode'):dict(deter=100.0,why='owner-priced deterrent — FVT split-mode/denominator setup'),
 ('05_FVT.pact','C_ToggleRewardLink'):dict(deter=50.0,why='owner-priced deterrent — FVT reward/score-entity link toggle'),
 ('05_FVT.pact','C_ToggleScoreEntityLink'):dict(deter=50.0,why='owner-priced deterrent — FVT reward/score-entity link toggle'),
 ('09_DPDC-F.pact','C_EnableNonceFragmentation'):dict(deter=100.0,role='ISSUE',
    why='ISSUANCE GATE — this (not MakeFragments) is the issue op; +$1(=100ig)/nonce defined as fragmented (substage-5 constant)'),
 ('09_DPDC-F.pact','C_MakeFragments'):dict(deter=1.0,role='USAGE',why='USAGE, not issuance — the issue gate is C_EnableNonceFragmentation (owner directive)'),
 ('09_DPDC-F.pact','C_MergeFragments'):dict(deter=1.0,role='USAGE',why='USAGE, not setup — pairs with C_MakeFragments (owner directive)'),
 ('08_DSA.pact','C_AdmitAgency'):dict(deter=2000.0,role='ISSUE',why=_ISS.format('agency on a delegation vault = $20','2000')),
 ('08_DSA.pact','C_DefineDelegationVault'):dict(deter=5000.0,role='ISSUE',
    why=_ISS.format('delegation vault = $50','5000')),
}
# rationale suffixes (kept out of OWNER so generic deter rules still apply)
NOTES={}
for _op in ('C_WipeClean','C_WipeHeavy','C_WipePure','C_WipeSlim','Cp_WipeSlice'):
    NOTES[('06_DPOF.pact',_op)]=WIPE_NOTE
for _op in ('C_WipeClean','C_WipeDirty','C_WipeHeavy','C_WipePure','C_WipeSlim','C_WipeNonce','Cp_WipeSlice'):
    NOTES[('06_DPDC-MNG.pact',_op)]=WIPE_NOTE
NOTES[('09_TFT.pact','C_MultiTransfer')]=VAR_NOTE.format('scales with receiver-list size')
NOTES[('09_TFT.pact','C_MultiBulkTransfer')]=VAR_NOTE.format('scales with receiver-list size')
NOTES[('19_SWPU.pact','C_SmartSwap')]=VAR_NOTE.format('scales with hop count + special targets')
NOTES[('19_SWPU.pact','CC_SmartSwap')]=VAR_NOTE.format('scales with hop count + special targets')
NOTES[('07_DPDC-T.pact','C_Transfer')]=VAR_NOTE.format('scales with nonce count moved + ignis royalty to collection creator')
NOTES[('07_DPDC-T.pact','C_BulkTransfer')]=VAR_NOTE.format('scales with nonce count moved + ignis royalty to collection creator')

FEE =re.compile(r'(Fee|Price|Promile|Tax|Charge|Ratio|Rate|Cost)')
AUTH=re.compile(r'(Authority|Agency|Oracle|Guard|Rotate|Admin|Sovereign|Operator|Role|Owner|Auth|Validity|Custodian|Delegat)')
def suggest_deter(n,rl,cur,mod):
    ow=OWNER.get((mod,n))
    if ow is not None: return ow['deter'],ow['why']
    # ALL genuinely admin-gated A_/AA_/Ap_ ops are fully FREE (owner 2026-09-05).
    # (The 7 DSA mistagged A_ fns were renamed to C_ in rehaul substage 4 — no exception left.)
    if ADMINQ.match(n):
        if re.search(r'Deploy(Smart|Standard)Account',n):
            return None,'IGNIS-EXEMPT — admin account deploy: fully FREE (no STOA, no IGNIS)'
        return None,'IGNIS-EXEMPT — admin function (Ouronet Admin only): fully FREE (no STOA, no IGNIS)'
    if 'Firestarter' in n:
        return None,'IGNIS-EXEMPT — SWP firestarter (bootstraps ignis), no IGNIS cost'
    # The collection machinery is never itself billed (owner 2026-09-05): C_Collect is the IGNIS
    # collector, and the STOA|C_Collect* variants are the native-STOA collectors. Verified in
    # source: none of them builds an OutputCumulator, so they are gasless in code too.
    if mod=='02_IGNIS.pact' and re.match(r'^(?:STOA\|)?C_Collect', n):
        return None,'IGNIS-EXEMPT — the collection machinery itself (collectors are never billed)'
    if mod=='13_OUROBOROS.pact' and n in ('C_Compress','C_Sublimate','C_SublimateV2'):
        return None,'IGNIS-EXEMPT — makes/breaks ignis'
    if re.search(r'Deploy(Smart|Standard)Account',n):
        return None,'IGNIS-EXEMPT — user account deploy: STOA-priced, no IGNIS finish cost'
    if n=='C_DeployAccount':
        return 50.0,'explicit token-account creation — IGNIS deterrent vs on-purpose spam (auto-creation inside a transfer is FREE)'
    if re.match(r'^(?:[A-Za-z0-9-]+\|)?C_(Add\w*Liquidity|RemoveLiquidity)$',n):
        return 1000.0,'LP add/remove churn — very big deterrent'
    if rl=='ISSUE':
        if cur is not None: return cur,f'issuance — honor current flat GAS| ({cur:g})'
        return 50.0,'token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent'
    if rl=='USAGE': return 1.0,'legit activity — pure compute, no deterrent'
    if FEE.search(n):  return 25.0,'economic-parameter change (fee/price/rate)'
    if AUTH.search(n): return 10.0,'role/authority/guard setup'
    return 5.0,'management/config/property change — slightly expensive'

def analyze(path):
    s=open(path).read(); toks=lf.tokenize(s); match=lf.match_parens(toks)
    ms=len(toks)
    for k in range(len(toks)):
        if toks[k][0]=='atom' and s[toks[k][1]:toks[k][2]]=='module': ms=k; break
    defs={}
    for k in range(ms,len(toks)):
        if toks[k][0]=='(':
            j=k+1
            while j<len(toks) and toks[j][0]=='ws': j+=1
            if j<len(toks) and toks[j][0]=='atom' and s[toks[j][1]:toks[j][2]] in ('defun','defpact'):
                jj=j+1
                while toks[jj][0]=='ws': jj+=1
                nm=s[toks[jj][1]:toks[jj][2]].split(':',1)[0]; ct=match[k]
                defs[nm]=s[toks[k][1]:toks[ct][2]]
    callees={}
    for nm,body in defs.items():
        callees[nm]=set(a for a in re.findall(r'\(([A-Za-z0-9_|<>+-]+)',body) if a in defs and a!=nm)
    _m={}
    def reach(nm,seen):
        if nm in _m: return _m[nm]
        if nm in seen: return set()
        seen=seen|{nm}; acc={nm}
        for c in callees[nm]: acc|=reach(c,seen)
        _m[nm]=acc; return acc
    rows=[]
    mod=path.split('/')[-1]
    for nm in defs:
        if not PREFQ.match(nm): continue
        txt=' '.join(defs[n] for n in reach(nm,set()))
        ins,upd,r,sc,x,comp=prim_costs(txt)
        cur=cur_flat(txt)
        ow=OWNER.get((mod,nm))
        rl=(ow.get('role') if ow else None) or role(nm)
        d,why=suggest_deter(nm,rl,cur,mod)
        why+=NOTES.get((mod,nm),'')
        rows.append((nm,rl,ins,upd,r,sc,x,comp,cur,d,why))
    return rows

# Scope: ALL sovereign CORE (minus historic DPMF stub, minus 3_Talos wrappers — they delegate
# + collect, their cost IS the wrapped core op) + ONLY the DPAD/launchpad citizens (they own a
# Talos aggregator so they price like sovereign; their own 99_TS02-CPAD excluded likewise).
SOV=[m for m in glob.glob('1_SOVEREIGN/**/*.pact',recursive=True)
     if '00_DPMF' not in m and '/3_Talos/' not in m]
CIT=[m for m in glob.glob('2_CITIZEN/7_Launchpad/**/*.pact',recursive=True)
     if 'TS02-CPAD' not in m]
MODS=sorted(SOV+CIT)

def main():
    print("# IGNIS deterrence worksheet (#76) — OWNER-DECIDED (2026-09-05 batch), regenerable\n")
    print("FINAL = deter·IG|TX(1) + components, where components =")
    print("[ 3·wbucket per insert/write + ceil(update-fields/2) per update + rbucket per read/scan + 2 per xcall ]")
    print("(module-internal transitive; cross-module callee internals not summed, so delegating ops read low).")
    print("Buckets from the target table's defschema points (bool/int/dec/time=1, string/guard=2, object/list=4):")
    print("S<=5 → w×1/r×1 · M 6-12 → w×2/r×1 · L 13-24 → w×3/r×2 · XL 25+ → w×5/r×3.")
    print("Talos-origin hop excluded by construction (analysis roots at the core entrypoint); xcall=2/hop.")
    print("Deter applies ONLY to the IG|TX(1) base, never the component sum. 1 ignis = 1 USD/EUR cent.")
    print("Generated by REPL/_ignis_deter_worksheet.py — OWNER_DECISIONS in-script = the approved batch")
    print("(memories/2026-09-05-ignis-pricing-feedback.md) and the substage-3 IGNIS defconst input.\n")
    print("COLUMN COLOURS — each COLUMN is a single colour, applied to the TEXT (renders in VS Code")
    print("preview / Obsidian / Typora; GitHub shows plain text). Key:\n")
    print(f"{col('op',COLS['op'])} · {col('role',COLS['role'])} · {col('ins/wr',COLS['ins'])} · "
          f"{col('upd',COLS['upd'])} · {col('reads',COLS['r'])} · {col('scans',COLS['s'])} · "
          f"{col('xcalls',COLS['x'])} · {col('components',COLS['comp'])} · {col('cur GAS|',COLS['cur'])} · "
          f"{col('deter',COLS['deter'])} · {col('final',COLS['fin'])}\n")
    print("S1 CONSTRAINT — auto account-creation inside a transfer (recipient has no account yet) is")
    print("IGNIS-FREE: it is subsumed in the transfer (deter 1), never billed as a separate op. Only the")
    print("explicit C_DeployAccount entrypoint (deliberate token-account creation) carries an IGNIS deterrent.")
    print("Account-deploy count (confirmed 2026-09-05): DALOS has exactly 2 admin-free A_Deploy*Account +")
    print("2 user STOA-priced C_Deploy*Account; per-token C_DeployAccount is a different, 50x-priced concept.\n")
    print("OWNER DECISIONS APPLIED (2026-09-05): all genuinely admin-gated A_/AA_/Ap_ = exempt;")
    print("C_TransferDalosFuel exempt; issuance $ tiers (TF/OF $10, SFT $20, NFT $25, ATS pair $40,")
    print("SWP pair $50, ShareholderCollection $100, DSA vault $50 / agency $20, anchors = half their")
    print("asset type); fragmentation gate moved to C_EnableNonceFragmentation; wipe +5ig/nonce;")
    print("DSA A_→C_ rename DONE (substage 4) — only 2 genuine GOV fns remain A_ in DSA.\n")
    tot=0; deterred=0
    tiers=Counter()
    for p in MODS:
        rows=analyze(p)
        if not rows: continue
        print(f"\n## {p.split('/')[-1]}\n")
        print("| op | role | ins/wr | upd | R | S | X | components | cur GAS\\| | **deter** | final | rationale |")
        print("|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|")
        for nm,rl,ins,upd,r,sc,x,comp,cur,d,why in sorted(rows,key=lambda z:z[0].lower()):
            tot+=1
            if isinstance(d,tuple) and d[0]=='SPLIT':
                key='split'; deterred+=1
                dstr=col(f'{d[1]:g}x/{d[2]:g}x',COLS['deter'])
                finstr=col(f'{d[1]+comp:g} (SFT) / {d[2]+comp:g} (NFT)',COLS['fin'])
            elif d is None:
                key='exempt'; tiers[key]+=0
                dstr=col('exempt',COLS['deter']); finstr=col('0',COLS['fin'])
            else:
                key=d; deterred+=(d!=1.0)
                dstr=col(f'{d:g}x',COLS['deter']); finstr=col(f'{d*IG_TX+comp:g}',COLS['fin'])
            tiers[key]+=1
            curc=col(f'{cur:g}',COLS['cur']) if cur is not None else '·'
            print(f"| {col(nm,COLS['op'])} | {col(rl,COLS['role'])} | {num(ins,COLS['ins'])} | {num(upd,COLS['upd'])} "
                  f"| {num(r,COLS['r'])} | {num(sc,COLS['s'])} | {num(x,COLS['x'])} | {col(comp,COLS['comp'])} "
                  f"| {curc} | {dstr} | {finstr} | {why} |")
    print(f"\n---\n## Deter tier distribution (owner-decided)\n")
    print("Deter is a multiplier on IG|TX: `25x` = 25·IG|TX added on top of the compute components.\n")
    print("| deter | ops | meaning |")
    print("|------:|----:|---------|")
    labels={'exempt':'IGNIS-exempt (ALL admin fns + account deploys + ignis machinery + DalosFuel transfer)',
            'split':'son:bool split issuance (SFT/NFT)',
            1.0:'activity — no deterrent',5.0:'config/property change',10.0:'role/authority/guard setup',
            25.0:'fee/price/rate change',50.0:'small deterrent (toggles, links, token-account deploy, legacy issuance)',
            100.0:'owner-priced 100x',200.0:'AddScore',250.0:'RevokeScore',400.0:'issuance (current flat)',
            500.0:'owner-priced 500x / legacy flat',1000.0:'issuance $10 / LP churn / SF-anchor',
            1250.0:'NF-anchor (half of $25)',2000.0:'agency $20',2500.0:'NFT issuance $25 (split)',
            4000.0:'ATS pair $40',5000.0:'SWP pair $50 / DSA vault $50',10000.0:'ShareholderCollection $100'}
    def _tkey(z): return -2 if z=='exempt' else (-1 if z=='split' else z)
    for d in sorted(tiers,key=_tkey):
        dd=d if isinstance(d,str) else f'{d:g}x'
        print(f"| {dd} | {tiers[d]} | {labels.get(d,'')} |")
    print(f"\n{tot} ops · {deterred} with deter>1 (rest default 1 or exempt). Regenerate: python3 REPL/_ignis_deter_worksheet.py > OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md")


if __name__ == "__main__":
    main()
