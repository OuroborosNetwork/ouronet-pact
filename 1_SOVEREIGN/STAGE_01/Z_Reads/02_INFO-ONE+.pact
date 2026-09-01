(interface InfoOneV1
    @doc "Exposes Functions from Information One Module"
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UC|GasPrice:decimal (full-price:decimal trigger:bool))
    ;;
    ;;
    ;;  [SIP|URC] Functions
    ;;
    (defun SIP|URC_Small:decimal ())
    (defun SIP|URC_Medium ())
    (defun SIP|URC_Big:decimal ())
    (defun SIP|URC_Biggest ())
    (defun SIP|URC_UpdatePendingBranding:decimal (m:decimal))
    (defun SIP|URC_Burn:decimal (id:string account:string))
    (defun SIP|URC_Issue:decimal (name:[string]))
    (defun SIP|URC_Mint:decimal (id:string account:string origin:bool))
    ;;
    ;;
    ;;  [SKP|URC] Functions
    ;;
    (defun SKP|URC_UpgradeBranding (months:integer))
    (defun SKP|URC_Issue (name:[string] dptf-or-dpof:bool))
    (defun SKP|URC_ToggleFeeLock (id:string toggle:bool fee-unlocks:integer))
    ;;
    ;;
    ;;  [INFO] Functions
    ;;
    (defun URC_DPTF|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string))
    (defun URC_DPTF|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer))
    (defun URC_DPTF|Burn:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string amount:decimal))
    (defun URC_DPTF|Control:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun URC_DPTF|DeployAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string))
    (defun URC_DPTF|DonateFees:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun URC_DPTF|Issue:object{OuronetInfoV1.ClientInfo} (patron:string account:string name:[string]))
    (defun URC_DPTF|Mint:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string amount:decimal origin:bool))
    (defun URC_DPTF|ResetFeeTarget:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun URC_DPTF|RotateOwnership:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-owner:string))
    (defun URC_DPTF|SetFee:object{OuronetInfoV1.ClientInfo} (patron:string id:string fee:decimal))
    (defun URC_DPTF|SetFeeTarget:object{OuronetInfoV1.ClientInfo} (patron:string id:string target:string))
    (defun URC_DPTF|SetMinMove:object{OuronetInfoV1.ClientInfo} (patron:string id:string min-move-value:decimal))
    (defun URC_DPTF|ToggleFee:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool))
    (defun URC_DPTF|ToggleFeeLock:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool fee-unlocks:integer))
    (defun URC_DPTF|ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPTF|TogglePause:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool))
    (defun URC_DPTF|ToggleReservation:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool))
    (defun URC_DPTF|ToggleTransferRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPTF|Wipe:object{OuronetInfoV1.ClientInfo} (patron:string id:string atbw:string))
    (defun URC_DPTF|WipeSlim:object{OuronetInfoV1.ClientInfo} (patron:string id:string atbw:string amtbw:decimal))
    (defun URC_DPTF|ToggleBurnRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPTF|ToggleMintRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPTF|ToggleFeeExemptionRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPTF|Transmute:object{OuronetInfoV1.ClientInfo} (patron:string id:string transmuter:string transmute-amount:decimal))
    (defun URC_DPTF|ClearDispo:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun URC_DPTF|Transfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver:string transfer-amount:decimal))
    (defun URC_DPTF|MultiTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal]))
    (defun URC_DPTF|BulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun URC_DPTF|MultiBulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))
    ;;
    (defun URC_DPOF|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string))
    (defun URC_DPOF|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer))
    (defun URC_DPOF|AddQuantity:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonce:integer account:string amount:decimal))
    (defun URC_DPOF|Burn:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonce:integer account:string amount:decimal))
    (defun URC_DPOF|Control:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun URC_DPOF|DeployAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string))
    (defun URC_DPOF|Issue:object{OuronetInfoV1.ClientInfo} (patron:string account:string name:[string]))
    (defun URC_DPOF|Mint:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string amount:decimal))
    (defun URC_DPOF|RotateOwnership:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-owner:string))
    (defun URC_DPOF|MoveCreateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string receiver:string))
    (defun URC_DPOF|ToggleAddQuantityRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPOF|ToggleBurnRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPOF|ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPOF|TogglePause:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool))
    (defun URC_DPOF|ToggleTransferRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun URC_DPOF|Transfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces:[integer] sender:string receiver:string method:bool))
    (defun URC_DPOF|Transmit:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool))
    (defun URC_DPOF|BulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool))
    (defun URC_DPOF|WipeSlim:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer amount:decimal))
    (defun URC_DPOF|WipePure:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV1.RemovableNonces}))
    (defun URC_DPOF|WipeHeavy:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string))
    (defun URC_DPOF|WipeClean:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonces:[integer]))
    ;;
    (defun URC_VST|CreateFrozenLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string))
    (defun URC_VST|CreateReservationLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string))
    (defun URC_VST|CreateVestingLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string))
    (defun URC_VST|CreateSleepingLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string))
    (defun URC_VST|CreateHibernatingLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string))
    (defun URC_VST|Freeze:object{OuronetInfoV1.ClientInfo} (patron:string freezer:string freeze-output:string dptf:string amount:decimal))
    (defun URC_VST|RepurposeFrozen:object{OuronetInfoV1.ClientInfo} (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string))
    (defun URC_VST|ToggleTransferRoleFrozenDPTF:object{OuronetInfoV1.ClientInfo} (patron:string s-dptf:string target:string toggle:bool))
    (defun URC_VST|Reserve:object{OuronetInfoV1.ClientInfo} (patron:string reserver:string dptf:string amount:decimal))
    (defun URC_VST|Unreserve:object{OuronetInfoV1.ClientInfo} (patron:string unreserver:string r-dptf:string amount:decimal))
    (defun URC_VST|RepurposeReserved:object{OuronetInfoV1.ClientInfo} (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string))
    (defun URC_VST|ToggleTransferRoleReservedDPTF:object{OuronetInfoV1.ClientInfo} (patron:string s-dptf:string target:string toggle:bool))
    (defun URC_VST|Vest:object{OuronetInfoV1.ClientInfo} (patron:string vester:string target-account:string dptf:string amount:decimal offset:integer seconds:integer milestones:integer))
    (defun URC_VST|Unvest:object{OuronetInfoV1.ClientInfo} (patron:string unvester:string dpof:string nonce:integer))
    (defun URC_VST|RepurposeVested:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun URC_VST|Sleep:object{OuronetInfoV1.ClientInfo} (patron:string sleeper:string target-account:string dptf:string amount:decimal seconds:integer))
    (defun URC_VST|Unsleep:object{OuronetInfoV1.ClientInfo} (patron:string unsleeper:string dpof:string nonce:integer))
    (defun URC_VST|Merge:object{OuronetInfoV1.ClientInfo} (patron:string merger:string dpof:string nonces:[integer]))
    (defun URC_VST|RepurposeMerge:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string))
    (defun URC_VST|RepurposeSleeping:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun URC_VST|ToggleTransferRoleSleepingDPOF:object{OuronetInfoV1.ClientInfo} (patron:string s-dpof:string target:string toggle:bool))
    (defun URC_VST|Hibernate:object{OuronetInfoV1.ClientInfo} (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer))
    (defun URC_VST|Awake:object{OuronetInfoV1.ClientInfo} (patron:string awaker:string dpof:string nonce:integer))
    (defun URC_VST|Slumber:object{OuronetInfoV1.ClientInfo} (patron:string merger:string dpof:string nonces:[integer]))
    (defun URC_VST|RepurposeSlumber:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string))
    (defun URC_VST|RepurposeHibernating:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun URC_VST|ToggleTransferRoleHibernatingDPOF:object{OuronetInfoV1.ClientInfo} (patron:string s-dpof:string target:string toggle:bool))
    ;;
    (defun URC_ATS|Coil:object{OuronetInfoV1.ClientInfo} (patron:string coiler:string ats:string rt:string amount:decimal))
    (defun URC_ATS|Constrict:object{OuronetInfoV1.ClientInfo} (patron:string constricter:string ats:string rt:string amount:decimal dayz:integer))
    (defun URC_ATS|Curl:object{OuronetInfoV1.ClientInfo} (patron:string curler:string ats1:string ats2:string rt:string amount:decimal))
    (defun URC_ATS|Brumate:object{OuronetInfoV1.ClientInfo} (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer))
    (defun URC_ATS|ColdRecovery:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string ats:string ra:decimal))
    (defun URC_ATS|Cull:object{OuronetInfoV1.ClientInfo} (patron:string culler:string ats:string))
    (defun URC_ATS|DirectRecovery:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string ats:string ra:decimal))
    (defun URC_ATS|RotateOwnership:object{OuronetInfoV1.ClientInfo} (patron:string ats:string new-owner:string))
    (defun URC_ATS|Control:object{OuronetInfoV1.ClientInfo} (patron:string ats:string can-change-owner:bool syphoning:bool hibernate:bool))
    (defun URC_ATS|UpdateRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string ats:string royalty:decimal))
    (defun URC_ATS|UpdateSyphon:object{OuronetInfoV1.ClientInfo} (patron:string ats:string syphon:decimal))
    (defun URC_ATS|SetHibernationFees:object{OuronetInfoV1.ClientInfo} (patron:string ats:string peak:decimal decay:decimal))
    (defun URC_ATS|ToggleParameterLock:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool))
    (defun URC_ATS|AddSecondary:object{OuronetInfoV1.ClientInfo} (patron:string ats:string reward-token:string rt-nfr:bool))
    (defun URC_ATS|ControlColdRecoveryFees:object{OuronetInfoV1.ClientInfo} (patron:string ats:string c-nfr:bool c-fr:bool))
    (defun URC_ATS|SetColdRecoveryFees:object{OuronetInfoV1.ClientInfo} (patron:string ats:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]]))
    (defun URC_ATS|SetColdRecoveryDuration:object{OuronetInfoV1.ClientInfo} (patron:string ats:string soft-or-hard:bool base:integer growth:integer))
    (defun URC_ATS|ToggleElite:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool))
    (defun URC_ATS|ToggleUpgrade:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool))
    (defun URC_ATS|SwitchColdRecovery:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool))
    (defun URC_ATS|ControlHotRecoveryFee:object{OuronetInfoV1.ClientInfo} (patron:string ats:string h-fr:bool))
    (defun URC_ATS|SetHotRecoveryFee:object{OuronetInfoV1.ClientInfo} (patron:string ats:string promile:decimal decay:integer))
    (defun URC_ATS|SwitchHotRecovery:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool))
    (defun URC_ATS|SetDirectRecoveryFee:object{OuronetInfoV1.ClientInfo} (patron:string ats:string promile:decimal))
    (defun URC_ATS|SwitchDirectRecovery:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool))
    (defun URC_ATS|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string))
    (defun URC_ATS|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer))
    (defun URC_ATS|Issue:object{OuronetInfoV1.ClientInfo} (patron:string account:string ats:[string]))
    (defun URC_ATS|Fuel:object{OuronetInfoV1.ClientInfo} (patron:string fueler:string ats:string reward-token:string amount:decimal))
    (defun URC_ATS|HotRecovery:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string ats:string ra:decimal))
    (defun URC_ATS|KickStart:object{OuronetInfoV1.ClientInfo} (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun URC_ATS|Redeem:object{OuronetInfoV1.ClientInfo} (patron:string redeemer:string id:string nonce:integer))
    (defun URC_ATS|Reverse:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string id:string nonce:integer))
    (defun URC_ATS|Syphon:object{OuronetInfoV1.ClientInfo} (patron:string syphon-target:string ats:string syphon-amounts:[decimal]))
    (defun URC_ATS|WithdrawRoyalties:object{OuronetInfoV1.ClientInfo} (patron:string ats:string target:string))
    (defun URC_ATS|VestedCoil:object{OuronetInfoV1.ClientInfo} (patron:string coiler-vester:string ats:string coil-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer))
    (defun URC_ATS|VestedCurl:object{OuronetInfoV1.ClientInfo} (patron:string curler-vester:string ats1:string ats2:string curl-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer))
    (defun URC_ATS|HOT-RBT|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string))
    (defun URC_ATS|HOT-RBT|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer))
    (defun URC_ATS|HOT-RBT|Repurpose:object{OuronetInfoV1.ClientInfo} (patron:string hot-rbt:string nonce:integer repurpose-to:string))
    (defun URC_ATS|AddHotRBT:object{OuronetInfoV1.ClientInfo} (patron:string ats:string hot-rbt:string))
    (defun URC_ATS|RemoveSecondary:object{OuronetInfoV1.ClientInfo} (patron:string remover:string ats:string reward-token:string))
    ;;
    (defun URC_SWP|ChangeOwnership:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string new-owner:string))
    (defun URC_SWP|ModifyCanChangeOwner:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string new-boolean:bool))
    (defun URC_SWP|ModifyWeights:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string new-weights:[decimal]))
    (defun URC_SWP|ToggleAddLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string toggle:bool))
    (defun URC_SWP|ToggleSwapCapability:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string toggle:bool))
    (defun URC_SWP|EnableFrozenLP:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string))
    (defun URC_SWP|EnableSleepingLP:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string))
    (defun URC_SWP|UpdateAmplifier:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string amp:decimal))
    (defun URC_SWP|UpdateFee:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string new-fee:decimal lp-or-special:bool))
    (defun URC_SWP|UpdateSpecialFeeTargets:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string targets:[string]))
    (defun URC_SWP|ToggleFeeLock:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string toggle:bool))
    (defun URC_SWP|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string))
    (defun URC_SWP|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer))
    (defun URC_SWP|UpdatePendingBrandingLPs:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string entity-pos:integer))
    (defun URC_SWP|UpgradeBrandingLPs:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string entity-pos:integer months:integer))
    (defun URC_SWP|AddLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URC_SWP|AddStandardLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URC_SWP|AddIcedLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URC_SWP|AddGlacialLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun URC_SWP|AddFrozenLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun URC_SWP|AddSleepingLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
    (defun URC_SWP|RemoveLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string lp-amount:decimal))
    (defun URC_SWP|Fuel:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun URC_SWP|Firestarter:object{OuronetInfoV1.ClientInfo} (firestarter:string))
    (defun URC_SWP|IssueStable:object{OuronetInfoV1.ClientInfo} (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun URC_SWP|IssueStandard:object{OuronetInfoV1.ClientInfo} (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool))
    (defun URC_SWP|IssueWeighted:object{OuronetInfoV1.ClientInfo} (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    (defun URC_SWP|IssueStablePool:object{OuronetInfoV1.ClientInfo} (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun URC_SWP|IssueStandardPool:object{OuronetInfoV1.ClientInfo} (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool))
    (defun URC_SWP|IssueWeightedPool:object{OuronetInfoV1.ClientInfo} (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    ;;
    ;;  [DALOS-INFO]  (relocated from the now-tombstoned INFO-ZERO; DALOS client-op previews wrapping IGNIS's DALOS|URCi_*)
    ;;
    (defun URC_DALOS|ControlSmartAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun URC_DALOS|DeploySmartAccount:object{OuronetInfoV1.ClientInfo} (account:string))
    (defun URC_DALOS|DeployStandardAccount:object{OuronetInfoV1.ClientInfo} (account:string))
    (defun URC_DALOS|RotateGovernor:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun URC_DALOS|RotateGuard:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun URC_DALOS|RotateStoa:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun URC_DALOS|RotateSovereign:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun URC_DALOS|UpdateEliteAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string))
    (defun URC_DALOS|UpdateEliteAccountSquared:object{OuronetInfoV1.ClientInfo} (patron:string sender:string receiver:string))
)
;;LIQUID|INFO_UnwrapStoa
;;LIQUID|INFO_WrapStoa
;;LIQUID|INFO_UnwrapUrStoa
(module INFO-ONE GOV
    ;;
    (implements InfoOneV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_INFO|DPTF      (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|INFO|DPTF_ADMIN)))
    (defcap GOV|INFO|DPTF_ADMIN ()  (enforce-guard GOV|MD_INFO|DPTF))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    ;;{P3}
    ;;{P4}
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    (defschema HibernatedNoncesView
        nonce:integer
        nonce-supply:decimal
        mint-time:time
        release-time:time
        hibernating-fee-promile:decimal
        remainder:decimal
        hibernating-fee:decimal
    )
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defun GOV|SWP|SC_NAME ()       (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|SWP|SC_NAME)))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    (defconst SWP|SC_NAME           (GOV|SWP|SC_NAME))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    ;;{C2}
    ;;{C3}
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC|GasPrice:decimal (full-price:decimal trigger:bool)
        (if trigger 0.0 full-price)
    )
    (defun UCX_ToggleAddOrSwapIfp:decimal (swpair:string toggle:bool)
        @doc "Ignis preview for <SwapperV3.C_ToggleAddOrSwap> (Talos <SWP|C_ToggleAddLiquidity> / <SWP|C_ToggleSwapCapability>)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp0:decimal (UC|GasPrice (* 5.0 biggest) trigger))
            )
            (if toggle
                (let
                    (
                        (pt-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                        (amp:decimal (ref-SWP::UR_Amplifier swpair))
                        (ptts:[string]
                            (if (= amp -1.0)
                                (drop 1 pt-ids)
                                pt-ids
                            )
                        )
                        (lp-id:string (ref-SWP::UR_TokenLP swpair))
                        (lp-burn-role:bool (ref-DPTF::UR_AccountRoleBurn lp-id swp-sc))
                        (lp-mint-role:bool (ref-DPTF::UR_AccountRoleMint lp-id swp-sc))
                        (ifp-burn:decimal (if lp-burn-role 0.0 (SIP|URC_Big)))
                        (ifp-mint:decimal (if lp-mint-role 0.0 (SIP|URC_Big)))
                        (ifp-fee:decimal
                            (fold
                                (lambda
                                    (acc:decimal idx:integer)
                                    (let
                                        (
                                            (pt:string (at idx ptts))
                                        )
                                        (if (ref-DPTF::UR_AccountRoleFeeExemption pt swp-sc)
                                            acc
                                            (+ acc (SIP|URC_Big))
                                        )
                                    )
                                )
                                0.0
                                (enumerate 0 (- (length ptts) 1))
                            )
                        )
                    )
                    (+ ifp0 ifp-burn ifp-mint ifp-fee)
                )
                ifp0
            )
        )
    )
    (defun UCX_AddLiquidity:object{OuronetInfoV1.ClientInfo} 
        (
            patron:string account:string swpair:string input-amounts:[decimal]
            asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
        )
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (ld:object{SwapperLiquidityV1.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
                ;;
                ;;Compute Liquidity Addition Data
                (clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC|STOA-PID_CLAD account swpair ld asymmetric-collection gaseous-collection stoa-pid)
                )
                (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                (ifp1:decimal 
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator 
                        (at "perfect-ignis-fee" (at "clad-op" clad))
                    )
                )
                (ifp2:decimal
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                        (ref-TFT::URCi_TransferCumulator 
                            (at "type" (ref-TFT::URC_TransferClasses lp-id swp-sc account native-lp-transfer-amount))
                            lp-id 
                            swp-sc 
                            account
                        )
                    )
                )
                (ifp:decimal (+ ifp1 ifp2))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (UCXX_AddLiquidityClientInfo patron ifp swpair (ref-DALOS::UR_IgnisID) clad asymmetric-collection false false)
        )
    )
    (defun UCXX_AddLiquidityClientInfo
        (
            patron:string ifp:decimal swpair:string ignis-id:string 
            clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
            asymmetric-collection:bool iz-for-sleeping:bool iz-for-frozen:bool
        )
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (primary:decimal (at "primary-lp" clad))
                (secondary:decimal (at "secondary-lp" clad))
                (sum:decimal (+ primary secondary))
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount patron))
                (discount-percent:string (format "{}%" [(* 100.0 (- 1.0 ignis-discount))]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Adding Liquidity with the following Parameters and {} costs:" [ignis-id])
                    (format "Fees are discounted by {} - your IGNIS discount, Taxes are paid in Full." [discount-percent])
                    (format "{}" [(at "gaseous-text" clad)])
                    (format "{}" [(at "deficit-text" clad)])
                    (format "{}" [(at "special-text" clad)])
                    (format "{}" [(at "lqboost-text" clad)])
                    (format "{}" [(at "fueling-text" clad)])
                ]
                [
                    (if (not asymmetric-collection)
                        (if iz-for-frozen
                            (format "Succesfully added Liquidity and generated {} Frozen LP." [secondary])
                            (format "Succesfully added Liquidity and generated {} Native LP and {} Frozen LP." [primary secondary])
                        )
                        (if iz-for-sleeping
                            (format "Succesfully added Liquidity and generated {} Sleeping LP" [primary])
                            (format "Succesfully added Liquidity and generated {} Native LP" [primary])
                        )
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    (defun UCX_Swap:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                (ref-SWPU:module{SwapperUsageV2} SWPU)
                ;;
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (input-positions:[integer] (ref-SWPI::URC_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                ;;
                ;;Do Swap Computation and Unwrap Object Data
                (dtso:object{UtilitySwpV1.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W)
                )
                (lp-fuel:[decimal] (at "lp-fuel" dtso))
                (o-id-special:decimal (at "o-id-special" dtso))
                (o-id-liquid:decimal (at "o-id-liquid" dtso))
                (o-id-netto:decimal (at "o-id-netto" dtso))
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator input-ids account swp-sc input-amounts)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (if (!= o-id-special 0.0)
                        (let
                            (
                                (o-prec:integer (at output-position X-prec))
                                (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                (fsft:list (ref-SWPU::UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                (f-targets:[string] (at 0 fsft))
                                (f-amounts:[decimal] (at 1 fsft))
                                (retained:decimal (at 2 fsft))
                                (adjusted-netto:decimal (+ o-id-netto retained))
                            )
                            (if (!= (length f-targets) 0)
                                (ref-TFT::URCi_MultiBulkTransferCumulator 
                                    [output-id] 
                                    swp-sc
                                    [(+ [account] f-targets)] 
                                    [(+ [adjusted-netto] f-amounts)]
                                )
                                (ref-TFT::URCi_TransferCumulator 
                                    (at "type" (ref-TFT::URC_TransferClasses output-id swp-sc account adjusted-netto))
                                    output-id 
                                    swp-sc 
                                    account
                                )
                            )
                        )
                        (ref-TFT::URCi_TransferCumulator 
                            (at "type" (ref-TFT::URC_TransferClasses output-id swp-sc account o-id-netto))
                            output-id 
                            swp-sc 
                            account
                        )
                    )
                )
                (ifp2:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico2))
                    (ifp3:decimal
                        (if (!= o-id-liquid 0.0)
                            (SIP|URC_Burn sstoa swp-sc)
                            0.0
                        )
                    )
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3]))
                (lp-strings:[string] (UC_LpFuelToLpStrings pool-tokens lp-fuel))
                (o-id-netto-str:string (UC_TrimDecimalTrailingZeros o-id-netto))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Swaps {} with amounts {} to the Output-Token {}" [input-ids input-amounts output-id])
                    (format "From Input, {} go to LP Providers" [lp-strings])
                    (format "{} from Raw Output to Special Targets: {}" [output-id (UC_TrimDecimalTrailingZeros o-id-special)])
                    (format "{} from Raw Output to Liquid Boost: {}" [output-id (UC_TrimDecimalTrailingZeros o-id-liquid)])
                    (format "{} Output: {}" [output-id o-id-netto-str])
                ]
                [
                    (format "Succesfully swapped {} {} to {} {}" [input-amounts input-ids o-id-netto-str output-id])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun UC_LpFuelToLpStrings:[string] (input-ids:[string] lp-fuel:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (l1:integer (length input-ids))
                (l2:integer (length lp-fuel))
            )
            (enforce (= l1 l2) "Invalid Input Data for making LP Strings")
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (if (!= (at idx lp-fuel) 0.0) 
                        (ref-U|LST::UC_AppL acc 
                            (format "{} {}" 
                                [
                                    (UC_TrimDecimalTrailingZeros (at idx lp-fuel))
                                    (at idx input-ids)
                                ]
                            )
                        )
                        acc
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    (defun UC_TrimDecimalTrailingZeros:string (number:decimal)
        @doc "Trims trailing zeros from a decimal number"
        (let* 
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (number-as-string:string (format "{}" [number]))
                (split-nas:[string] (ref-U|LST::UC_SplitString "." number-as-string))
                (integer-part:string (at 0 split-nas))
                (decimal-part:string (at 1 split-nas))
                (ldp:integer (length decimal-part))
                ;;
                (trimmed-decimal-part:string
                    (fold
                        (lambda
                            (acc:string idx:integer)
                            (if (= (take -1 acc) "0")
                                (drop -1 acc)
                                acc
                            )    
                        )
                        decimal-part
                        (enumerate 0 (- ldp 1))
                    )
                )
                (resulted-string:string
                    (if (= trimmed-decimal-part "")
                        (+ integer-part ".0")
                        (concat [integer-part "." trimmed-decimal-part])
                    )
                )
            )
            resulted-string
        )
    )
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    ;;
    ;;  [SIP|URC] - Simple Ignis Price >> dependent on a single trigger
    ;;
    (defun SIP|URC_Small:decimal ()
        @doc "<DPTF|C_Control> \
            \ <DPTF|C_DeployAccount> \
            \ <DPTF|C_SetFee> \
            \ <DPTF|C_SetFeeTarget> \
            \ <DPTF|C_SetMinMove> \
            \ <DPTF|C_ToggleFee> \
            \ <DPTF|C_ToggleFeeLock> \
            \ <DPOF|C_AddQuantity> \
            \ <DPOF|C_Burn> \
            \ <DPOF|C_DeployAccount>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|small")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Medium ()
        @doc "<DPTF|C_TogglePause> \
            \ <DPTF|C_ToggleReservation>\
            \ <DPOF|C_Control> \
            \ <DPOF|C_Mint>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|medium")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Big:decimal ()
        @doc "<DPTF|C_RotateOwnership>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|big")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Biggest ()
        @doc "<DPTF|C_ToggleFreezeAccount> \
            \ <DPOF|C_ToggleFreezeAccount> \
            \ <DPTF|C_ToggleTransferRole> \
            \ <DPTF|C_Wipe> \
            \ <DPTF|C_WipePartial> \
            \ <SwapperV3.C_ChangeOwnership> (Talos <SWP|C_ChangeOwnership>) \
            \ <SwapperV3.C_ModifyCanChangeOwner> (Talos <SWP|C_ModifyCanChangeOwner>) \
            \ <SwapperV3.C_ModifyWeights> (Talos <SWP|C_ModifyWeights>)"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|biggest")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_UpdatePendingBranding:decimal (m:decimal)
        @doc "<DPTF|C_UpdatePendingBranding> >> m = 1"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (* m (ref-DALOS::UR_UsagePrice "ignis|branding"))
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Burn:decimal (id:string account:string)
        @doc "<DPTF|C_Burn>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|small")
                (ref-IGNIS::URC_ZeroGAS id account)
            )
        )
    )
    (defun SIP|URC_Issue:decimal (name:[string])
        @doc "<DPTF|C_Issue"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (* (dec (length name)) (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Mint:decimal (id:string account:string origin:bool)
        @doc "<DPTF|C_Mint>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (if origin (ref-DALOS::UR_UsagePrice "ignis|biggest") (ref-DALOS::UR_UsagePrice "ignis|small"))
                (ref-IGNIS::URC_ZeroGAS id account)
            )
        )
    )
    ;;
    ;;  [SKP|URC] - Simple Stoa Price 
    ;;
    (defun SKP|URC_UpgradeBranding (months:integer)
        @doc "<DPTF|C_UpgradeBranding>"
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (blue:decimal (ref-DALOS::UR_UsagePrice "blue"))
            )
            (* (dec months) blue)
        )
    )
    (defun SKP|URC_Issue (name:[string] dptf-or-dpof:bool)
        @doc "<DPTF|C_Issue> \
            \ <DPOF|C_Issue>"                
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (l1:integer (length name))
                (dptf:decimal (ref-DALOS::UR_UsagePrice "dptf"))
                (dpof:decimal (ref-DALOS::UR_UsagePrice "dpmf"))
                (kfp:decimal (if dptf-or-dpof dptf dpof))
            )
            (UC|GasPrice
                (* (dec l1) kfp)
                (ref-IGNIS::URC_IsNativeGasZero)
            )
        )
    )
    (defun SKP|URC_ToggleFeeLock (id:string toggle:bool fee-unlocks:integer)
        @doc "<DPTF|ToggleFeeLock>"
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV1} U|DPTF)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (prices:[decimal]
                    (if toggle
                        [0.0 0.0]
                        (ref-U|DPTF::UC_UnlockPrice fee-unlocks)
                    )
                )
            )
            (UC|GasPrice
                (at 1 prices)
                (ref-IGNIS::URC_IsNativeGasZero)
            )
        )
    )
    ;;
    ;;  [INFO] - Informational URC Functions
    ;;
    ;;  [DPTF]
    (defun URC_DPTF|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Update Pending Branding for {} DPTF" [entity-id])]
                [(format "Pending Branding for DPTF {} updated succesfully" [entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_UpdatePendingBranding entity-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPTF|UpgradeBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string months:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrade Branding for {} DPTF for {} month(s)" [entity-id months])]
                [(format "DPTF {} succesfully upgraded for {} months(s)!" [entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-DPTF::URCi_UpgradeBranding months))
                []
            )
        )
    )
    (defun URC_DPTF|Burn:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Burn {} {} on Account {}" [amount id sa])]
                [(format "Succesfully burned {} {} on Account {}" [amount id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Burn id account)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]
            )
        )
    )
    (defun URC_DPTF|Control:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Control DPTF {} Boolean Properties" [id])]
                [(format "Succesfully controlled Properties of {}" [id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Control id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPTF|DeployAccount:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Deploys a new {} DPTF Account." [id])
                    (format "Deploys Token {} on the Ouronet Account {}" [id sa])
                ]
                [(format "DPTF {} added to {} Ouronet Account succesfully!" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_DeployAccount account)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPTF|DonateFees:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|DALOS|SC_NAME)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Donates {} collected Fees" [id])
                    (format "Collection Location: Ouronet Gas Station: {}" [sa])
                ]
                [(format "Fee Collection succesfully set to {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_SetFeeTarget id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPTF|Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string name:[string])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Issues {} DPTF(s)" [name])
                    (format "Also issues DPTF Accounts on {} Account" [sa])
                ]
                [(format "DPTF Issuance of {} succesfully completed" [name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-DPTF::URCi_IssueGas (length name)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-DPTF::URCi_IssueStoa (length name)))
                []
            )
        )
    )
    (defun URC_DPTF|Mint:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string amount:decimal origin:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if origin
                        (format "Operation: Premine {} {} on Account {}" [amount id sa])
                        (format "Operation: Mint {} {} on Account {}" [amount id sa])
                    )
                ]
                [
                    (if origin
                        (format "Succesfully premined {} {} on Account {}" [amount id sa])
                        (format "Succesfully minted {} {} on Account {}" [amount id sa])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint id account origin)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]
            )
        )
    )
    (defun URC_DPTF|ResetFeeTarget:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Resets Collection of Fees for {}" [id])
                    (format "Collection Location: Ouroboros Smart Ouronet Account {}" [sa])
                ]
                [(format "Fee Collection succesfully set to {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_SetFeeTarget id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPTF|RotateOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string new-owner:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-owner))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Changes Ownership for {} to {}" [id sa])]
                [(format "ID {} Ownership succesfully set to {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_RotateOwnership id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPTF|SetFee:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string fee:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets fee for {} to {} Promille" [id fee])]
                [(format "Fee Promille succesfully set to {} Promille for {}" [fee id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_SetFee id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [fee]
            )
        )
    )
    (defun URC_DPTF|SetFeeTarget:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string target:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets fee target for {} to {} " [id sa])]
                [(format "Fee Target succesfully set for {} to {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_SetFeeTarget id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [target]
            )
        )
    )
    (defun URC_DPTF|SetMinMove:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string min-move-value:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets MinMove Value target for {} to {} " [id min-move-value])]
                [(format "MinMove Value succesfully set for {} to {}" [id min-move-value])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_SetMinMove id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [min-move-value]
            )
        )
    )
    (defun URC_DPTF|ToggleFee:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Activates Fee Collection for {}" [id])
                        (format "Operation: Deactivates Fee Collection for {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "Fee Collection activated succesfully for {}" [id])
                        (format "Fee Collection deactivated succesfully for {}" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFee id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|ToggleFeeLock:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool fee-unlocks:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Locks Fee Settings for {}" [id])
                        (format "Operation: Unlocks Fee Collection for {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "Fee Settings succesfully locked for {}" [id])
                        (format "Fee Settings succesfully unlocked  for {}" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFeeLock id toggle)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-DPTF::URCi_ToggleFeeLockStoa id toggle))
                [toggle]
            )
        )
    )
    (defun URC_DPTF|ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Freezes ID {} on Account" [id sa])
                        (format "Operation: Unfreezes ID {} on Account" [id sa])
                    )
                ]
                [
                    (if toggle
                        (format "Account {} succesfully frozen for {}" [sa id])
                        (format "Account {} succesfuly unfrozen for {}" [sa id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFreezeAccount id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|TogglePause:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Pauses ID {}" [id])
                        (format "Operation: Unpauses ID {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "ID {} succesfully pauses" [id])
                        (format "ID {} succesfully unpauses" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_TogglePause id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|ToggleReservation:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Opens Reservations for {}" [id])
                        (format "Operation: Closes Reservations for {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "Reservations succesfully opened for {}" [id])
                        (format "Reservations succesfully closed for {}" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleReservation id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|ToggleTransferRole:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Adds Transfer Role for {} to {}" [id sa])
                        (format "Operation: Removes Transfer Role for {} to {}" [id sa])
                    )
                ]
                [
                    (if toggle
                        (format "Transfer Role succesfuly added for {} to {}" [id sa])
                        (format "Transfer Role succesfuly removed for {} to {}" [id sa])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleTransferRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|Wipe:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string atbw:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wipes all {} from account {}" [id sa])]
                [(format "Succesfully wiped all {} from account {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Wipe id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [atbw]
            )
        )
    )
    (defun URC_DPTF|WipeSlim:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string atbw:string amtbw:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wipes {} {} from account {}" [amtbw id sa])]
                [(format "Succesfully wiped {} {} from account {}" [amtbw id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_WipeSlim id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [atbw amtbw]
            )
        )
    )
    (defun URC_DPTF|Transfer:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string sender:string receiver:string transfer-amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses id sender receiver transfer-amount)))
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_TransferCumulator what-type id sender receiver)
                )
                (receiver-amount:decimal (ref-TFT::URC_ReceiverAmount id sender receiver transfer-amount))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                ;;
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (dispo-check:bool (fold (and) true [(= id ea) (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Attempts to transfer {} {} from {} to {}" [transfer-amount id sa-s sa-r])
                        (format "This operation cannot execute for {} when {} {} Supply is Negative (current supply {})" [ea sa-s ouro sender-ouro-supply])
                        (format "In order to transfer {}, an {} supply of at least 0.0 is required." [ea ouro])
                    ]
                    [
                        (format "Operation: Transfers {} {} from {} to {}" [transfer-amount id sa-s sa-r])
                        (if (= receiver-amount transfer-amount)
                            (format "Receiver will receiver the full amount of {} {}" [transfer-amount id])
                            (format "Due to Fee Settings, Receiver will receive only {} {}" [receiver-amount id])
                        )
                    ]
                )
                [
                    (if (= receiver-amount transfer-amount)
                        (format "Succesfully transfered {} {} from {} to {}, moving the Full Amount to the Receiver" [transfer-amount id sa-s sa-r])
                        (format "Succesfully transfered {} {} from {} to {}, moving only {} to the Receiver due to DPTF Fee Settings" [transfer-amount id sa-s sa-r receiver-amount])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount receiver-amount)]
            )
        )
    )
    (defun URC_DPTF|MultiTransfer:object{OuronetInfoV1.ClientInfo}
        (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator id-lst sender receiver transfer-amount-lst)
                )
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                ;;
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (has-ea:bool (contains ea id-lst))
                (dispo-check:bool (fold (and) true [has-ea (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Transfers {} DPTFs as a Multi-Transfer" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "Transfer cannot execute, as moving {} requires at least 0.0 {} Balance on {}" [ea ouro sa-s])
                        (format "To proceed, either remove {} from the list, or bring the {} Balance on {} to at least 0.0" [ea ouro sa-s])
                    ]
                    [
                        (format "Operation: Transfers {} DPTFs as a Multi-Transfer" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "Amounts are in their order: {}" [transfer-amount-lst])
                        (format "Movement occurs from {} to {}" [sa-s sa-r])
                    ]
                )
                
                [(format "Succesfully multi-transfered {} DPTFs from {} to {}" [(length id-lst) sa-s sa-r])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [id-lst transfer-amount-lst]
            )
        )
    )
    (defun URC_DPTF|BulkTransfer:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_BulkTransferCumulator id sender receiver-lst transfer-amount-lst)
                )
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (dispo-check:bool (fold (and) true [(= id ea) (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Transfers {} DPTF in Bulk" [id])
                        (format "Operation cannot execute, as moving {} requires at least 0.0 {} Balance on {}" [ea ouro sa-s])
                        (format "To proceed, bring the {} Balance on {} to at least 0.0" [ouro sa-s])
                    ]
                    [
                        (format "Operation: Transfers {} DPTF in Bulk" [id])
                        (format "Bulk Transfer means from one Sender, {} to multiple receivers" [sa-s])
                    ]
                )
                [(format "Succesfully bulk-transfered {} DPTF from {} to {} Receivers" [id sa-s (length receiver-lst)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [receiver-lst transfer-amount-lst]
            )
        )
    )
    (defun URC_DPTF|MultiBulkTransfer:object{OuronetInfoV1.ClientInfo}
        (patron:string id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_MultiBulkTransferCumulator id-lst sender receiver-array transfer-amount-array)
                )
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (has-ea:bool (contains ea id-lst))
                (dispo-check:bool (fold (and) true [has-ea (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Transfers {} DPTFs in MultiBulk at once" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "MultiBulkTransfer cannot execute, as moving {} requires at least 0.0 {} Balance on {}" [ea ouro sa-s])
                        (format "To proceed, either remove {} from the list, or bring the {} Balance on {} to at least 0.0" [ea ouro sa-s])
                    ]
                    [
                        (format "Operation: Transfers {} DPTFs in Bulk at once" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "Transfer occurs from Sender, {} to multiple receivers, specific for each DPTF" [sa-s])
                        (format "Bulk Transfer DPTFs are {}" [id-lst])
                    ]
                )
                [(format "Succesfully multi-bulk-transfered {} DPTFs from Sender {} to {} Individual Receiver Lists" [(length id-lst) sa-s (length receiver-array)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [id-lst receiver-array transfer-amount-array]
            )
        )
    )
    (defun URC_DPTF|ClearDispo:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (a-id:string (ref-DALOS::UR_AurynID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ouro-a:decimal (ref-DPTF::UR_AccountSupply ouro-id account))
                (ouro-amount:decimal (abs ouro-a))
            )
            (enforce (< ouro-a 0.0) "Dispo Clear requires Negative OURO")
            (let
                (
                    ;;
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardToken ouro-id)))
                    (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardToken a-id)))
                    (auryndex-value:decimal (ref-ATS::URC_Index auryndex))
                    (elite-auryndex-value:decimal (ref-ATS::URC_Index elite-auryndex))
                    ;;
                    (a-prec:integer (ref-DPTF::UR_Decimals a-id))
                    (ea-prec:integer (ref-DPTF::UR_Decimals ea-id))
                    ;;
                    (burn-auryn-amount:decimal (floor (/ ouro-amount auryndex-value) a-prec))
                    (burn-elite-auryn-amount:decimal (floor (/ burn-auryn-amount elite-auryndex-value) ea-prec))
                    (total-ea:decimal (floor (* burn-elite-auryn-amount 2.5) ea-prec))
                    ;;
                    (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_ClearDispo account)))
                )
                (ref-I|OURONET::OI|UDC_ClientInfo
                    [
                        (format "Operation: Clear the Negative Dispo of {} {} by leveraging EliteAuryn Supply" [ouro-amount ouro-id])
                        (format "{} {} is used to cover the Debt" [burn-elite-auryn-amount ea-id])
                        (format "{} {} is used as extra cost for the operation set to increase the {} Index" [(- total-ea burn-elite-auryn-amount) ea-id elite-auryndex])
                    ]
                    [(format "Succesfully cleared negative {} using {} {}" [ouro-id total-ea ea-id])]
                    (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                    (ref-I|OURONET::OI|UDC_NoStoaCosts)
                    []
                )
            )
        )
    )
    (defun URC_DPTF|ToggleBurnRole:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Burn Role for {} to {}" [id sa]) (format "Operation: Removes Burn Role for {} to {}" [id sa]))]
                [(if toggle (format "Burn Role succesfuly added for {} to {}" [id sa]) (format "Burn Role succesfuly removed for {} to {}" [id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleBurnRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|ToggleMintRole:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Mint Role for {} to {}" [id sa]) (format "Operation: Removes Mint Role for {} to {}" [id sa]))]
                [(if toggle (format "Mint Role succesfuly added for {} to {}" [id sa]) (format "Mint Role succesfuly removed for {} to {}" [id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleMintRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|ToggleFeeExemptionRole:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Fee-Exemption Role for {} to {}" [id sa]) (format "Operation: Removes Fee-Exemption Role for {} to {}" [id sa]))]
                [(if toggle (format "Fee-Exemption Role succesfuly added for {} to {}" [id sa]) (format "Fee-Exemption Role succesfuly removed for {} to {}" [id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFeeExemptionRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPTF|Transmute:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string transmuter:string transmute-amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount transmuter))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Transmutes {} {} on Account {}" [transmute-amount id sa])]
                [(format "Succesfully transmuted {} {} on Account {}" [transmute-amount id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transmute id transmuter)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount transmute-amount)]
            )
        )
    )
    ;;  [DPOF]
    (defun URC_DPOF|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Update Pending Branding for {} DPOF" [entity-id])]
                [(format "Pending Branding for DPOF {} updated succesfully" [entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_UpdatePendingBranding entity-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPOF|UpgradeBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string months:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrade Branding for {} DPOF for {} month(s)" [entity-id months])]
                [(format "DPOF {} succesfully upgraded for {} months(s)!" [entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-DPOF::URCi_UpgradeBranding months))
                []
            )
        )
    )
    (defun URC_DPOF|AddQuantity:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string nonce:integer account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds {} to DPOF {} Nonce {} on Account {}" [amount id nonce sa])]
                [(format "Succesfully increased DPOF {} nonce {} quantity on Account {} by {}" [id nonce sa amount])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_AddQuantity id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]
            )
        )
    )
    (defun URC_DPOF|Burn:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string nonce:integer account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Burns {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])]
                [(format "Succesfully burned {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_Burn id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]
            )
        )
    )
    (defun URC_DPOF|Control:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Controls DPOF {} Boolean Properties" [id])]
                [(format "Succesfully controlled DPOF {} Boolean Properties" [id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_Control id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;; NOTE: the former DPOF|INFO_Create was an orphan preview — DPOF has no C_Create client
    ;; op (create-without-quantity is not a gas-funded path; Mint creates+adds in one op).
    ;; Dropped in the URCi rehaul; re-add alongside a real client op if one is ever introduced.
    (defun URC_DPOF|DeployAccount:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Deploy a DPOF Account for DPOF {} on Ouronet Account {}" [id sa])]
                [(format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_DeployAccount account)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPOF|Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string name:[string])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Issues {} DPOF(s)" [name])
                    (format "Also issues DPTF Accounts on {} Account" [sa])
                ]
                [(format "DPOF Issuance of {} succesfully completed" [name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-DPOF::URCi_IssueGas (length name)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-DPOF::URCi_IssueStoa (length name)))
                []
            )
        )
    )
    (defun URC_DPOF|Mint:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_Mint id)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Mint {} {} on Account {}, on a new Nonce" [amount id sa])]
                [(format "Succesfully minted {} {} on Account {}, on a new Nonce" [amount id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount)]
            )
        )
    )
    ;; ---- DPOF entity-completion: ownership/role toggles (1:1 URCi) ----
    (defun URC_DPOF|RotateOwnership:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-owner:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-owner))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Changes Ownership for DPOF {} to {}" [id sa])]
                [(format "DPOF {} Ownership succesfully set to {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_RotateOwnership id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPOF|MoveCreateRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string receiver:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Moves the Create-Role of DPOF {} to {}" [id sa])]
                [(format "Create-Role of DPOF {} succesfully moved to {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCreateRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPOF|ToggleAddQuantityRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Add-Quantity Role for {} to {}" [id sa]) (format "Operation: Removes Add-Quantity Role for {} to {}" [id sa]))]
                [(if toggle (format "Add-Quantity Role added for {} to {}" [id sa]) (format "Add-Quantity Role removed for {} to {}" [id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_ToggleAddQuantityRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPOF|ToggleBurnRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Burn Role for {} to {}" [id sa]) (format "Operation: Removes Burn Role for {} to {}" [id sa]))]
                [(if toggle (format "Burn Role added for {} to {}" [id sa]) (format "Burn Role removed for {} to {}" [id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_ToggleBurnRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPOF|ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Freezes DPOF {} on Account {}" [id sa]) (format "Operation: Unfreezes DPOF {} on Account {}" [id sa]))]
                [(if toggle (format "Account {} succesfully frozen for {}" [sa id]) (format "Account {} succesfully unfrozen for {}" [sa id]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_ToggleFreezeAccount id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPOF|TogglePause:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Pauses DPOF {}" [id]) (format "Operation: Unpauses DPOF {}" [id]))]
                [(if toggle (format "DPOF {} succesfully paused" [id]) (format "DPOF {} succesfully unpaused" [id]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_TogglePause id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_DPOF|ToggleTransferRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Transfer Role for {} to {}" [id sa]) (format "Operation: Removes Transfer Role for {} to {}" [id sa]))]
                [(if toggle (format "Transfer Role added for {} to {}" [id sa]) (format "Transfer Role removed for {} to {}" [id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_ToggleTransferRole id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    ;; ---- DPOF entity-completion: transfer family (URCi_MoveCumulator: transmit=ignis|small, transfer=ignis|smallest per nonce) ----
    (defun URC_DPOF|Transfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces:[integer] sender:string receiver:string method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Transfers DPOF {} Nonces {} from {} to {}" [id nonces sa-s sa-r])]
                [(format "Succesfully transferred DPOF {} Nonces {} from {} to {}" [id nonces sa-s sa-r])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator id nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [nonces]
            )
        )
    )
    (defun URC_DPOF|Transmit:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Transmits DPOF {} Nonces {} Amounts {} from {} to {}" [id nonces amounts sa-s sa-r])]
                [(format "Succesfully transmitted DPOF {} Nonces {} from {} to {}" [id nonces sa-s sa-r])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator id nonces true)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [nonces amounts]
            )
        )
    )
    (defun URC_DPOF|BulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (all-nonces:[integer] (fold (+) [] nonces-array))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Bulk-transfers DPOF {} from {} to {} Receivers" [id sa-s (length receiver-lst)])]
                [(format "Succesfully bulk-transferred DPOF {} from {} to {} Receivers" [id sa-s (length receiver-lst)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator id all-nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [receiver-lst]
            )
        )
    )
    ;; ---- DPOF entity-completion: wipe family (WipeSlim flat; Pure/Heavy/Clean per-nonce via URCi_WipeCumulator) ----
    (defun URC_DPOF|WipeSlim:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonce:integer amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wipes {} of DPOF {} Nonce {} from Account {}" [amount id nonce sa])]
                [(format "Succesfully wiped {} of DPOF {} Nonce {} from Account {}" [amount id nonce sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_WipeSlim id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]
            )
        )
    )
    (defun URC_DPOF|WipePure:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV1.RemovableNonces})
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Pure-wipes DPOF {} on Account {} (pre-read removable nonces)" [id sa])]
                [(format "Succesfully pure-wiped DPOF {} on Account {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_WipeCumulator id removable-nonces-obj)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPOF|WipeHeavy:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Heavy-wipes all viable DPOF {} Nonces from Account {}" [id sa])]
                [(format "Succesfully heavy-wiped DPOF {} from Account {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_WipeCumulator id (ref-DPOF::URDC_WipePure account id))))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DPOF|WipeClean:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string nonces:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Clean-wipes DPOF {} Nonces {} from Account {}" [id nonces sa])]
                [(format "Succesfully clean-wiped DPOF {} Nonces {} from Account {}" [id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_WipeCumulator id (ref-DPOF::UDC_RemovableNonces nonces (ref-DPOF::UR_NoncesSupplies id nonces)))))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [nonces]
            )
        )
    )
    ;;  [VST]
    (defun URC_VST|Hibernate:object{OuronetInfoV1.ClientInfo}
        (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Hibernate hibernator target-account dptf amount dayz)))
                (sa-hibernator:string (ref-I|OURONET::OI|UC_ShortAccount hibernator))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Hibernates {} {} for {} Days" [amount dptf dayz])
                ]
                [
                    (format "Sucesfully hibernated {} {} on Account {} for a Duration of {} days." [amount dptf sa-hibernator dayz])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount) dayz]
            )
        )
    )
    (defun URC_VST|Awake:object{OuronetInfoV1.ClientInfo}
        (patron:string awaker:string dpof:string nonce:integer)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-VST:module{VestingV1} VST)
                ;;
                (dptf-id:string (ref-DPOF::UR_Hibernation dpof))
                (precision:integer (ref-DPOF::UR_Decimals dpof))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof nonce))
                ;;
                (mint-time:time (at "mint-time" (at 0 meta-data-chain)))
                (release-time:time (at "release-date" (at 0 meta-data-chain)))
                (hibernating-period:decimal (diff-time release-time mint-time))
                ;;
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time mint-time))
                ;;
                (hibernating-fee-promile:decimal
                    (if (>= elapsed-time hibernating-period)
                        0.0
                        (floor (- 800.0 (* 800.0 (/ elapsed-time hibernating-period))) 4)
                    )
                )
                (remainder:decimal
                    (if (= hibernating-fee-promile 0.0)
                        nonce-supply
                        (at 0 (ref-U|ATS::UC_PromilleSplit hibernating-fee-promile nonce-supply precision))
                    )
                )
                (hibernating-fee:decimal (- nonce-supply remainder))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Awake awaker dpof nonce)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Awakens {} Nonce {}, returning its underlying DPTF, {}." [dpof nonce dptf-id])
                    (format "The maximum awakening fee of 800‰ (promille) is currently at {}‰." [hibernating-fee-promile])
                    (if (= hibernating-fee 0.0)
                        (format "This will release {} DPTF Tokens, with no awakening fee." [remainder])  
                        (format "This will release {} DPTF Tokens, while witholding {} as awakening fee." [remainder hibernating-fee])
                    )
                ]
                [
                    (format "Succesfully awakend {} Nonce {} returning {} {}." [dpof nonce dptf-id remainder])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|Slumber:object{OuronetInfoV1.ClientInfo}
        (patron:string merger:string dpof:string nonces:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-VST:module{VestingV1} VST)
                ;;
                (dptf:string (ref-DPOF::UR_Hibernation dpof))
                (sm:string (ref-I|OURONET::OI|UC_ShortAccount merger))
                ;;
                (nonces-supplies:[decimal] (ref-DPOF::UR_NoncesSupplies dpof nonces))
                (how-many:decimal (dec (length nonces)))
                ;;
                (stu:[decimal] (ref-VST::URC_SecondsToUnlock dpof nonces))
                (compute-merge-all:[decimal] (ref-VST::UC_MergeAll nonces-supplies stu))
                ;;
                (free-amount:decimal (at 0 compute-merge-all))
                (locked-amount:decimal (at 1 compute-merge-all))
                (weigthed-locked-amount-in-seconds:integer (floor (at 2 compute-merge-all)))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_MergeNonces dpof merger nonces 3)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Slumbers {} {} Nonces {}, merging and awakening then." [how-many dpof nonces])
                    (format "Awakening happens automatically for all nonces at {}% fee" [0.0])
                    (if (!= free-amount 0.0)
                        (format "Released Amount will be {}!" [free-amount])
                        "There will be no release amount, as none of the selected Nonces are ripe!"
                    )
                    (if (!= locked-amount 0.0)
                        (let
                            (
                                (ref-U|VST:module{UtilityVstV1} U|VST)
                                (release-date:time (at 0 (ref-U|VST::UC_MakeVestingDateList 0 weigthed-locked-amount-in-seconds 1)))
                            )
                            (format "An amount of {} due for release at {} still remains locked!" [locked-amount release-date])
                        )
                        "There will be no locked amount, as all selected Nonces are ripe!"
                    )
                ]
                [
                    (format "Succesfully merged Hibernated DPOF {} Nonces {} to Account {}" [dpof nonces sm])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;; ---- Special-link creation (IGNIS only; STOA auto-fuel is protocol, not a patron charge) ----
    (defun URC_VST|CreateFrozenLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_CreateSpecialTrueFungibleLink dptf)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates the Frozen Special-DPTF link for {}" [dptf])]
                [(format "Frozen Special-DPTF link for {} created succesfully" [dptf])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|CreateReservationLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_CreateSpecialTrueFungibleLink dptf)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates the Reservation Special-DPTF link for {}" [dptf])]
                [(format "Reservation Special-DPTF link for {} created succesfully" [dptf])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|CreateVestingLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_CreateSpecialOrtoFungibleLink dptf 1)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates the Vesting Special-DPOF link for {}" [dptf])]
                [(format "Vesting Special-DPOF link for {} created succesfully" [dptf])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|CreateSleepingLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_CreateSpecialOrtoFungibleLink dptf 2)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates the Sleeping Special-DPOF link for {}" [dptf])]
                [(format "Sleeping Special-DPOF link for {} created succesfully" [dptf])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|CreateHibernatingLink:object{OuronetInfoV1.ClientInfo} (patron:string dptf:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_CreateSpecialOrtoFungibleLink dptf 3)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates the Hibernating Special-DPOF link for {}" [dptf])]
                [(format "Hibernating Special-DPOF link for {} created succesfully" [dptf])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;; ---- Frozen family ----
    (defun URC_VST|Freeze:object{OuronetInfoV1.ClientInfo} (patron:string freezer:string freeze-output:string dptf:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Freeze freezer freeze-output dptf amount)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount freezer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Freezes {} {} on Account {}" [amount dptf sa])]
                [(format "Succesfully froze {} {} on Account {}" [amount dptf sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount)]
            )
        )
    )
    (defun URC_VST|RepurposeFrozen:object{OuronetInfoV1.ClientInfo} (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_RepurposeTrueFungible dptf-to-repurpose repurpose-from repurpose-to)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes Frozen {} from {} to {}" [dptf-to-repurpose repurpose-from repurpose-to])]
                [(format "Frozen {} repurposed from {} to {} succesfully" [dptf-to-repurpose repurpose-from repurpose-to])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|ToggleTransferRoleFrozenDPTF:object{OuronetInfoV1.ClientInfo} (patron:string s-dptf:string target:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_ToggleTransferRoleFrozenDPTF s-dptf)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Transfer Role for Frozen {} to {}" [s-dptf sa]) (format "Operation: Removes Transfer Role for Frozen {} to {}" [s-dptf sa]))]
                [(if toggle (format "Transfer Role for Frozen {} added to {}" [s-dptf sa]) (format "Transfer Role for Frozen {} removed from {}" [s-dptf sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    ;; ---- Reserved family ----
    (defun URC_VST|Reserve:object{OuronetInfoV1.ClientInfo} (patron:string reserver:string dptf:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Reserve reserver dptf amount)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount reserver))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Reserves {} {} on Account {}" [amount dptf sa])]
                [(format "Succesfully reserved {} {} on Account {}" [amount dptf sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount)]
            )
        )
    )
    (defun URC_VST|Unreserve:object{OuronetInfoV1.ClientInfo} (patron:string unreserver:string r-dptf:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Unreserve unreserver r-dptf amount)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount unreserver))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Unreserves {} {} on Account {}" [amount r-dptf sa])]
                [(format "Succesfully unreserved {} {} on Account {}" [amount r-dptf sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount)]
            )
        )
    )
    (defun URC_VST|RepurposeReserved:object{OuronetInfoV1.ClientInfo} (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_RepurposeTrueFungible dptf-to-repurpose repurpose-from repurpose-to)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes Reserved {} from {} to {}" [dptf-to-repurpose repurpose-from repurpose-to])]
                [(format "Reserved {} repurposed from {} to {} succesfully" [dptf-to-repurpose repurpose-from repurpose-to])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|ToggleTransferRoleReservedDPTF:object{OuronetInfoV1.ClientInfo} (patron:string s-dptf:string target:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_ToggleTransferRoleReservedDPTF s-dptf)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Transfer Role for Reserved {} to {}" [s-dptf sa]) (format "Operation: Removes Transfer Role for Reserved {} to {}" [s-dptf sa]))]
                [(if toggle (format "Transfer Role for Reserved {} added to {}" [s-dptf sa]) (format "Transfer Role for Reserved {} removed from {}" [s-dptf sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    ;; ---- Vested family ----
    (defun URC_VST|Vest:object{OuronetInfoV1.ClientInfo} (patron:string vester:string target-account:string dptf:string amount:decimal offset:integer seconds:integer milestones:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Vest vester target-account dptf amount offset seconds milestones)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Vests {} {} to {} across {} milestone(s)" [amount dptf sa milestones])]
                [(format "Succesfully vested {} {} to {} across {} milestone(s)" [amount dptf sa milestones])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount) milestones]
            )
        )
    )
    (defun URC_VST|Unvest:object{OuronetInfoV1.ClientInfo} (patron:string unvester:string dpof:string nonce:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Unvest unvester dpof nonce)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Unvests {} Nonce {}, releasing its matured underlying DPTF" [dpof nonce])]
                [(format "Succesfully unvested {} Nonce {}" [dpof nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|RepurposeVested:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_RepurposeOrtoFungible dpof-to-repurpose nonce repurpose-from repurpose-to)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes Vested {} Nonce {} from {} to {}" [dpof-to-repurpose nonce repurpose-from repurpose-to])]
                [(format "Vested {} Nonce {} repurposed from {} to {} succesfully" [dpof-to-repurpose nonce repurpose-from repurpose-to])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;; ---- Sleeping family ----
    (defun URC_VST|Sleep:object{OuronetInfoV1.ClientInfo} (patron:string sleeper:string target-account:string dptf:string amount:decimal seconds:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Sleep sleeper target-account dptf amount seconds)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sleeps {} {} to {} for {} second(s)" [amount dptf sa seconds])]
                [(format "Succesfully slept {} {} to {} for {} second(s)" [amount dptf sa seconds])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount) seconds]
            )
        )
    )
    (defun URC_VST|Unsleep:object{OuronetInfoV1.ClientInfo} (patron:string unsleeper:string dpof:string nonce:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Unsleep unsleeper dpof nonce)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Unsleeps {} Nonce {}, returning its underlying DPTF" [dpof nonce])]
                [(format "Succesfully unslept {} Nonce {}" [dpof nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|Merge:object{OuronetInfoV1.ClientInfo} (patron:string merger:string dpof:string nonces:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_MergeNonces dpof merger nonces 2)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount merger))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Merges Sleeping {} Nonces {} on Account {}" [dpof nonces sa])]
                [(format "Succesfully merged Sleeping {} Nonces {} on Account {}" [dpof nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|RepurposeMerge:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_MergeNonces dpof-to-repurpose repurpose-to nonces 2)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes-merges Sleeping {} Nonces {} from {} to {}" [dpof-to-repurpose nonces repurpose-from repurpose-to])]
                [(format "Sleeping {} Nonces {} repurpose-merged from {} to {} succesfully" [dpof-to-repurpose nonces repurpose-from repurpose-to])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|RepurposeSleeping:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_RepurposeOrtoFungible dpof-to-repurpose nonce repurpose-from repurpose-to)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes Sleeping {} Nonce {} from {} to {}" [dpof-to-repurpose nonce repurpose-from repurpose-to])]
                [(format "Sleeping {} Nonce {} repurposed from {} to {} succesfully" [dpof-to-repurpose nonce repurpose-from repurpose-to])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|ToggleTransferRoleSleepingDPOF:object{OuronetInfoV1.ClientInfo} (patron:string s-dpof:string target:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_ToggleTransferRoleSleepingDPOF s-dpof)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Transfer Role for Sleeping {} to {}" [s-dpof sa]) (format "Operation: Removes Transfer Role for Sleeping {} to {}" [s-dpof sa]))]
                [(if toggle (format "Transfer Role for Sleeping {} added to {}" [s-dpof sa]) (format "Transfer Role for Sleeping {} removed from {}" [s-dpof sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    ;; ---- Hibernating family (Hibernate/Awake/Slumber above) ----
    (defun URC_VST|RepurposeSlumber:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_MergeNonces dpof-to-repurpose repurpose-to nonces 3)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes-slumbers Hibernating {} Nonces {} from {} to {}" [dpof-to-repurpose nonces repurpose-from repurpose-to])]
                [(format "Hibernating {} Nonces {} repurpose-slumbered from {} to {} succesfully" [dpof-to-repurpose nonces repurpose-from repurpose-to])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|RepurposeHibernating:object{OuronetInfoV1.ClientInfo} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_RepurposeOrtoFungible dpof-to-repurpose nonce repurpose-from repurpose-to)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes Hibernating {} Nonce {} from {} to {}" [dpof-to-repurpose nonce repurpose-from repurpose-to])]
                [(format "Hibernating {} Nonce {} repurposed from {} to {} succesfully" [dpof-to-repurpose nonce repurpose-from repurpose-to])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_VST|ToggleTransferRoleHibernatingDPOF:object{OuronetInfoV1.ClientInfo} (patron:string s-dpof:string target:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-VST:module{VestingV1} VST)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_ToggleTransferRoleHibernatingDPOF s-dpof)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds Transfer Role for Hibernating {} to {}" [s-dpof sa]) (format "Operation: Removes Transfer Role for Hibernating {} to {}" [s-dpof sa]))]
                [(if toggle (format "Transfer Role for Hibernating {} added to {}" [s-dpof sa]) (format "Transfer Role for Hibernating {} removed from {}" [s-dpof sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun VST|INFO-HibernatedNoncesDisplay:[object{HibernatedNoncesView}]
        (account:string dpof:string)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (owned-nonces:[integer] (sort (ref-DPOF::URD_AccountNonces account dpof)))
                (l:integer (length owned-nonces))
            )
            (map
                (lambda
                    (idx:integer)
                    (VST|INFO-HibernatedNonceDisplay dpof (at idx owned-nonces))
                )
                (enumerate 0 (- l 1))
            )
        )
    )
    (defun VST|INFO-HibernatedNonceDisplay:object{HibernatedNoncesView}
        (dpof:string nonce:integer)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (precision:integer (ref-DPOF::UR_Decimals dpof))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof nonce))
                ;;
                (mint-time:time (at "mint-time" (at 0 meta-data-chain)))
                (release-time:time (at "release-date" (at 0 meta-data-chain)))
                (hibernating-period:decimal (diff-time release-time mint-time))
                ;;
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time mint-time))
                ;;
                (hibernating-fee-promile:decimal
                    (if (>= elapsed-time hibernating-period)
                        0.0
                        (floor (- 800.0 (* 800.0 (/ elapsed-time hibernating-period))) 4)
                    )
                )
                (remainder:decimal 
                    (if (= hibernating-fee-promile 0.0)
                        nonce-supply
                        (at 0 (ref-U|ATS::UC_PromilleSplit hibernating-fee-promile nonce-supply precision))
                    )
                )
                (hibernating-fee:decimal (- nonce-supply remainder))
            )
            (UDC_HibernatedNoncesView
                nonce nonce-supply mint-time release-time hibernating-fee-promile remainder hibernating-fee
            )
        )
    )
    ;;  [ATS]
    (defun URC_ATS|Coil:object{OuronetInfoV1.ClientInfo}
        (patron:string coiler:string ats:string rt:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                ;;
                (coil-data:object{AutostakeV2.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                )
                (royalty-fee:decimal (at "royalty-fee" coil-data))
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Coil coiler ats rt amount)))
                (sa-coiler:string (ref-I|OURONET::OI|UC_ShortAccount coiler))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats])
                    (if (= royalty-fee 0.0)
                        (format "Deposit will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the Autostake Pool." [royalty-fee rt])
                    )
                    (format "Coil will generate {} {} as final output." [c-rbt-amount c-rbt])
                ]
                [
                    (format "Succesfully coiled {} {} on ATS-Pair {} generating {} {} on {} Account." [amount rt ats c-rbt-amount c-rbt sa-coiler])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt-amount)]
            )
        )
    )
    (defun URC_ATS|Constrict:object{OuronetInfoV1.ClientInfo}
        (patron:string constricter:string ats:string rt:string amount:decimal dayz:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-VST:module{VestingV1} VST)
                ;;
                (coil-data:object{AutostakeV2.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats rt amount dayz)
                )
                (royalty-fee:decimal (at "royalty-fee" coil-data))
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (peak:decimal (ref-ATS::UR_PeakHibernatePromile ats))
                (decay:decimal (ref-ATS::UR_HibernateDecay ats))
                (v2:decimal (- peak (* (dec dayz) decay)))
                (fee-promile:decimal
                    (if (<= v2 0.0)
                        0.0
                        v2
                    )
                )
                (hibernate-entry-percent:string (format "{}%" [(/ fee-promile 10.0)]))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Constrict constricter ats rt amount dayz)))
                (sa-constricter:string (ref-I|OURONET::OI|UC_ShortAccount constricter))
                (ht:string (ref-DPTF::UR_Hibernation c-rbt))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats])
                    (if (= royalty-fee 0.0)
                        (format "Deposit will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the Autostake Pool." [royalty-fee rt])
                    )
                    (format "Constricting for {} Days will incurr a hibernation fee of {} on the Input {} after Royalty" [dayz hibernate-entry-percent c-rbt])
                    (format "Constricting will generate {} {} as final output." [c-rbt-amount ht])
                ]
                [
                    (format "Succesfully constricted {} {} on ATS-Pair {} generating {} {} on {} Account." [amount rt ats c-rbt-amount ht sa-constricter])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt-amount)]
            )
        )
    )
    (defun URC_ATS|Curl:object{OuronetInfoV1.ClientInfo}
        (patron:string curler:string ats1:string ats2:string rt:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                ;;
                ;;<ats1>
                (coil1-data:object{AutostakeV2.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                )
                (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                ;;
                ;;<ats2>
                (coil2-data:object{AutostakeV2.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                )
                (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Curl curler ats1 ats2 rt amount)))
                (sa-curler:string (ref-I|OURONET::OI|UC_ShortAccount curler))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats1])
                    (if (= royalty1-fee 0.0)
                        (format "Deposit in the first Autostake Pool will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the First Autostake Pool." [royalty1-fee rt])
                    )
                    (format "An Intermediary Output of {} {} will be generated" [c-rbt1-amount c-rbt1])
                    ;;<ATS2>
                    (format "The Output {} will then be further autostaked on the second ATS-Pair, the {}." [c-rbt1 ats2])
                    (if (= royalty2-fee 0.0)
                        (format "Deposit in the second Autostake Pool will be executed without any {} Royalty." [c-rbt1])
                        (format "{} {} will be retained as Royalty on the Second Autostake Pool." [royalty2-fee c-rbt1])
                    )
                    (format "Curl will generate {} {} as final output." [c-rbt2-amount c-rbt2])
                ]
                [
                    (format "Succesfully curled {} {} on ATS-Pairs {} and {} generating {} {} on {} Account." [amount rt ats1 ats2 c-rbt2-amount c-rbt2 sa-curler])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt2-amount)]
            )
        )
    )
    (defun URC_ATS|Brumate:object{OuronetInfoV1.ClientInfo}
        (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-VST:module{VestingV1} VST)
                ;;
                ;;<ats1>
                (coil1-data:object{AutostakeV2.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                )
                (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                ;;
                ;;<ats2>
                (coil2-data:object{AutostakeV2.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats2 c-rbt1 c-rbt1-amount dayz)
                )
                (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                (peak:decimal (ref-ATS::UR_PeakHibernatePromile ats2))
                (decay:decimal (ref-ATS::UR_HibernateDecay ats2))
                (v2:decimal (- peak (* (dec dayz) decay)))
                (fee-promile:decimal
                    (if (<= v2 0.0)
                        0.0
                        v2
                    )
                )
                (hibernate-entry-percent:string (format "{}%" [(/ fee-promile 10.0)]))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_Brumate brumator ats1 ats2 rt amount dayz)))
                (sa-brumator:string (ref-I|OURONET::OI|UC_ShortAccount brumator))
                (ht:string (ref-DPTF::UR_Hibernation c-rbt2))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats1])
                    (if (= royalty1-fee 0.0)
                        (format "Deposit in the first Autostake Pool will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the First Autostake Pool." [royalty1-fee rt])
                    )
                    (format "An Intermediary Output of {} {} will be generated" [c-rbt1-amount c-rbt1])
                    ;;<ATS2>
                    (format "The Output {} will then be further autostaked on the second ATS-Pair, the {}." [c-rbt1 ats2])
                    (if (= royalty2-fee 0.0)
                        (format "Deposit in the second Autostake Pool will be executed without any {} Royalty." [c-rbt1])
                        (format "{} {} will be retained as Royalty on the Second Autostake Pool." [royalty2-fee c-rbt1])
                    )
                    (format "Brumating for {} Days will incurr a hibernation fee of {} on the Input {} after Royalty" [dayz hibernate-entry-percent c-rbt1])
                    (format "Brumating will generate {} {} as final output." [c-rbt2-amount ht])
                ]
                [
                    (format "Succesfully brumated {} {} on ATS-Pairs {} and {} generating {} {} on {} Account." [amount rt ats1 ats2 c-rbt2-amount ht sa-brumator])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt2-amount)]
            )
        )
    )
    (defun URC_ATS|ColdRecovery:object{OuronetInfoV1.ClientInfo}
        (patron:string recoverer:string ats:string ra:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (index-name:string (ref-ATS::UR_IndexName ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (c-fr:bool (ref-ATS::UR_ColdRecoveryFeeRedirection ats))
                (elite:bool (ref-ATS::UR_EliteMode ats))
                ;;
                (c-rbt-precision:integer (ref-DPTF::UR_Decimals c-rbt))
                (usable-cold-recovery-position:integer (ref-ATS::URC_WhichPosition ats ra recoverer))
                (fee-promile:decimal (ref-ATS::URC_ColdRecoveryFee ats ra usable-cold-recovery-position))
                (c-rbt-fee-split:[decimal] (ref-U|ATS::UC_PromilleSplit fee-promile ra c-rbt-precision))
                (c-rbt-remainder:decimal (at 0 c-rbt-fee-split))
                (c-rbt-fee:decimal (at 1 c-rbt-fee-split))
                ;;
                ;;Time Computation for Cold Recovery (display: recoverable-after hours)
                (major:integer (ref-DALOS::UR_Elite-Tier-Major recoverer))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor recoverer))
                (position:integer
                    (if (= major 0)
                        0
                        (+ (* (- major 1) 7) minor)
                    )
                )
                (crd:[integer] (ref-ATS::UR_ColdRecoveryDuration ats))
                (h:integer (at position crd))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_ColdRecovery recoverer ats ra)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Places {} {} into Cold Recovery" [ra c-rbt])
                    (if (= usable-cold-recovery-position -1)
                        (format "You have {} Recovery Slots" [250])
                        (if elite
                            (format "You have up to {} Recovery Slots" [7])
                            (format "You have {} Recovery Slots" [7])
                        )
                    )
                    (if (!= c-rbt-fee 0.0)
                        (format "{}\n{}\n{}"
                            [
                                (format "Cold Recovery will incurr a Cold-Recovery-Fee of {}‰ (promile)" [fee-promile])
                                (if c-fr
                                    (format "This Fee is collected by strengthening the {}" [index-name])
                                    (format "This Fee is collected by burning the Reward Tokens {}" [rt-lst])
                                )
                                (format "And Amounts to {} {}" [(ref-ATS::URC_RTSplitAmounts ats c-rbt-fee) rt-lst])
                            ]
                        )
                        (format "Cold Recovery will be executed {} Cold-Recovery-Fee" [0])
                    )
                    (format "{} {} will be recovarable after {} hour(s)" [(ref-ATS::URC_RTSplitAmounts ats c-rbt-remainder) rt-lst h])
                ]
                [
                    (format "Succesfully placed {} {} ATS-Pair RBT into Cold Recovery" [ra ats])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount ra)]
            )
        )
    )
    (defun URC_ATS|Cull:object{OuronetInfoV1.ClientInfo}
        (patron:string culler:string ats:string)
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV1} U|DEC)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                ;;
                (c0:[decimal] (at "summed-culled-values" (ref-ATSU::URC_MultiCull ats culler)))
                (c1:[decimal] (ref-ATSU::URC_SingleCull ats culler 1))
                (c2:[decimal] (ref-ATSU::URC_SingleCull ats culler 2))
                (c3:[decimal] (ref-ATSU::URC_SingleCull ats culler 3))
                (c4:[decimal] (ref-ATSU::URC_SingleCull ats culler 4))
                (c5:[decimal] (ref-ATSU::URC_SingleCull ats culler 5))
                (c6:[decimal] (ref-ATSU::URC_SingleCull ats culler 6))
                (c7:[decimal] (ref-ATSU::URC_SingleCull ats culler 7))
                (ca:[[decimal]] [c0 c1 c2 c3 c4 c5 c6 c7])
                (cw:[decimal] (ref-U|DEC::UC_AddHybridArray ca))
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (how-many-tokens:integer (length rt-lst))
                (empty:[decimal] (make-list how-many-tokens 0.0))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Cull culler ats)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Culls the Cold Recovery Positions, recovering RTs")
                    (if (= cw empty)
                        "Currently no RTs can be collected"
                        (format "Currently RTs {} can be recovered with amounts of: {}" [rt-lst cw])
                    )
                ]
                [
                    (format "Succesfully Culled {} RT(s) Tokens with amounts of {} from ATS-Pair {}" [how-many-tokens cw ats])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(map (ref-I|OURONET::OI|UC_FormatTokenAmount) cw)]
            )
        )
    )
    (defun URC_ATS|DirectRecovery:object{OuronetInfoV1.ClientInfo}
        (patron:string recoverer:string ats:string ra:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (fee:decimal (ref-ATS::UR_DirectRecoveryFee ats))
                (c-rbt-remainder:decimal
                    (if (= fee 0.0)
                        ra
                        (at 0 (ref-U|ATS::UC_PromilleSplit fee ra (ref-DPTF::UR_Decimals c-rbt)))
                    )
                )
                (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                (release-amounts:[decimal] (ref-ATS::URC_RTSplitAmounts ats c-rbt-remainder))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_DirectRecovery recoverer ats ra)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Directly Recovers {} {}" [ra c-rbt])
                    (if (= fee 0.0)
                        "Direct Recovery will be executed without any Direct-Recovery Fee"
                        (format "Direct Recovery will be executed with {}‰ (promile) Direct Recovery Fee" [fee])
                    )
                    (format "Direct Recovery will yield {} {} Tokens" [release-amounts reward-tokens])
                ]
                [
                    (format "Succesfully recovered directly {} RBT Token on ATS-Pair" [ra ats])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(map (ref-I|OURONET::OI|UC_FormatTokenAmount) release-amounts)]
            )
        )
    )
    ;; ---- ATS entity-completion: pool config ops (1:1 ATS URCi, IGNIS) ----
    (defun URC_ATS|RotateOwnership:object{OuronetInfoV1.ClientInfo} (patron:string ats:string new-owner:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS) (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-owner)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Changes Ownership of ATS-Pair {} to {}" [ats sa])]
                [(format "ATS-Pair {} Ownership succesfully set to {}" [ats sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_RotateOwnership ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|Control:object{OuronetInfoV1.ClientInfo} (patron:string ats:string can-change-owner:bool syphoning:bool hibernate:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Controls Boolean Properties of ATS-Pair {}" [ats])]
                [(format "Succesfully controlled Properties of ATS-Pair {}" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_Control ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|UpdateRoyalty:object{OuronetInfoV1.ClientInfo} (patron:string ats:string royalty:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets Royalty of ATS-Pair {} to {}" [ats royalty])]
                [(format "Royalty of ATS-Pair {} succesfully set to {}" [ats royalty])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_UpdateRoyalty ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [royalty])))
    (defun URC_ATS|UpdateSyphon:object{OuronetInfoV1.ClientInfo} (patron:string ats:string syphon:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets Syphon of ATS-Pair {} to {}" [ats syphon])]
                [(format "Syphon of ATS-Pair {} succesfully set to {}" [ats syphon])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_UpdateSyphon ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [syphon])))
    (defun URC_ATS|SetHibernationFees:object{OuronetInfoV1.ClientInfo} (patron:string ats:string peak:decimal decay:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets Hibernation Fees of ATS-Pair {} (peak {}, decay {})" [ats peak decay])]
                [(format "Hibernation Fees of ATS-Pair {} succesfully set" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SetHibernationFees ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [peak decay])))
    (defun URC_ATS|ToggleParameterLock:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Locks Parameters of ATS-Pair {}" [ats]) (format "Operation: Unlocks Parameters of ATS-Pair {}" [ats]))]
                [(if toggle (format "Parameters of ATS-Pair {} succesfully locked" [ats]) (format "Parameters of ATS-Pair {} succesfully unlocked" [ats]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_ToggleParameterLock ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_ATS|AddSecondary:object{OuronetInfoV1.ClientInfo} (patron:string ats:string reward-token:string rt-nfr:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Secondary Reward-Token {} to ATS-Pair {}" [reward-token ats])]
                [(format "Secondary Reward-Token {} succesfully added to ATS-Pair {}" [reward-token ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_AddSecondary ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|ControlColdRecoveryFees:object{OuronetInfoV1.ClientInfo} (patron:string ats:string c-nfr:bool c-fr:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Controls Cold-Recovery Fee flags of ATS-Pair {}" [ats])]
                [(format "Cold-Recovery Fee flags of ATS-Pair {} succesfully controlled" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_ControlColdRecoveryFees ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|SetColdRecoveryFees:object{OuronetInfoV1.ClientInfo} (patron:string ats:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets the {} Cold-Recovery Fee positions of ATS-Pair {}" [fee-positions ats])]
                [(format "Cold-Recovery Fees of ATS-Pair {} succesfully set" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SetColdRecoveryFees ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|SetColdRecoveryDuration:object{OuronetInfoV1.ClientInfo} (patron:string ats:string soft-or-hard:bool base:integer growth:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets Cold-Recovery Duration of ATS-Pair {} (base {}, growth {})" [ats base growth])]
                [(format "Cold-Recovery Duration of ATS-Pair {} succesfully set" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SetColdRecoveryDuration ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|ToggleElite:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Enables Elite Mode on ATS-Pair {}" [ats]) (format "Operation: Disables Elite Mode on ATS-Pair {}" [ats]))]
                [(if toggle (format "Elite Mode enabled on ATS-Pair {}" [ats]) (format "Elite Mode disabled on ATS-Pair {}" [ats]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_ToggleElite ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_ATS|ToggleUpgrade:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Enables Upgradeability on ATS-Pair {}" [ats]) (format "Operation: Disables Upgradeability on ATS-Pair {}" [ats]))]
                [(if toggle (format "Upgradeability enabled on ATS-Pair {}" [ats]) (format "Upgradeability disabled on ATS-Pair {}" [ats]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_ToggleUpgrade ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_ATS|SwitchColdRecovery:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Enables Cold-Recovery on ATS-Pair {}" [ats]) (format "Operation: Disables Cold-Recovery on ATS-Pair {}" [ats]))]
                [(if toggle (format "Cold-Recovery enabled on ATS-Pair {}" [ats]) (format "Cold-Recovery disabled on ATS-Pair {}" [ats]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SwitchColdRecovery ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_ATS|ControlHotRecoveryFee:object{OuronetInfoV1.ClientInfo} (patron:string ats:string h-fr:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Controls Hot-Recovery Fee flag of ATS-Pair {}" [ats])]
                [(format "Hot-Recovery Fee flag of ATS-Pair {} succesfully controlled" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_ControlHotRecoveryFee ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|SetHotRecoveryFee:object{OuronetInfoV1.ClientInfo} (patron:string ats:string promile:decimal decay:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets Hot-Recovery Fee of ATS-Pair {} ({}‰, decay {})" [ats promile decay])]
                [(format "Hot-Recovery Fee of ATS-Pair {} succesfully set" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SetHotRecoveryFees ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [promile])))
    (defun URC_ATS|SwitchHotRecovery:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Enables Hot-Recovery on ATS-Pair {}" [ats]) (format "Operation: Disables Hot-Recovery on ATS-Pair {}" [ats]))]
                [(if toggle (format "Hot-Recovery enabled on ATS-Pair {}" [ats]) (format "Hot-Recovery disabled on ATS-Pair {}" [ats]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SwitchHotRecovery ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_ATS|SetDirectRecoveryFee:object{OuronetInfoV1.ClientInfo} (patron:string ats:string promile:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets Direct-Recovery Fee of ATS-Pair {} to {}‰" [ats promile])]
                [(format "Direct-Recovery Fee of ATS-Pair {} succesfully set to {}‰" [ats promile])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SetDirectRecoveryFee ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [promile])))
    (defun URC_ATS|SwitchDirectRecovery:object{OuronetInfoV1.ClientInfo} (patron:string ats:string toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Enables Direct-Recovery on ATS-Pair {}" [ats]) (format "Operation: Disables Direct-Recovery on ATS-Pair {}" [ats]))]
                [(if toggle (format "Direct-Recovery enabled on ATS-Pair {}" [ats]) (format "Direct-Recovery disabled on ATS-Pair {}" [ats]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_SwitchDirectRecovery ats)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_ATS|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates Pending Branding for ATS-Pair {}" [entity-id])]
                [(format "Pending Branding for ATS-Pair {} updated succesfully" [entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_UpdatePendingBranding entity-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrades Branding for ATS-Pair {} for {} month(s)" [entity-id months])]
                [(format "ATS-Pair {} succesfully upgraded for {} month(s)!" [entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ATS::URCi_UpgradeBranding months)) [])))
    (defun URC_ATS|Issue:object{OuronetInfoV1.ClientInfo} (patron:string account:string ats:[string])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues {} ATS-Pair(s) on Account {}" [(length ats) sa])]
                [(format "ATS-Pair Issuance of {} succesfully completed" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-ATS::URCi_IssueGas (length ats)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ATS::URCi_IssueStoa (length ats))) [])))
    ;; ---- ATS entity-completion: staking / recovery ops (1:1 ATSU URCi, IGNIS) ----
    (defun URC_ATS|Fuel:object{OuronetInfoV1.ClientInfo} (patron:string fueler:string ats:string reward-token:string amount:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU) (sa:string (ref-I|OURONET::OI|UC_ShortAccount fueler)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} {} into ATS-Pair {}" [amount reward-token ats])]
                [(format "Succesfully fueled {} {} into ATS-Pair {} from Account {}" [amount reward-token ats sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Fuel fueler ats reward-token amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [(ref-I|OURONET::OI|UC_FormatTokenAmount amount)])))
    (defun URC_ATS|HotRecovery:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string ats:string ra:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Places {} into Hot Recovery on ATS-Pair {}" [ra ats])]
                [(format "Succesfully placed {} into Hot Recovery on ATS-Pair {}" [ra ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_HotRecovery recoverer ats ra)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [(ref-I|OURONET::OI|UC_FormatTokenAmount ra)])))
    (defun URC_ATS|KickStart:object{OuronetInfoV1.ClientInfo} (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: KickStarts ATS-Pair {} with RT amounts {} for {} RBT" [ats rt-amounts rbt-request-amount])]
                [(format "Succesfully kickstarted ATS-Pair {}" [ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_KickStart kickstarter ats rt-amounts rbt-request-amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [(ref-I|OURONET::OI|UC_FormatTokenAmount rbt-request-amount)])))
    (defun URC_ATS|Redeem:object{OuronetInfoV1.ClientInfo} (patron:string redeemer:string id:string nonce:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Redeems {} Nonce {} on its ATS-Pair" [id nonce])]
                [(format "Succesfully redeemed {} Nonce {}" [id nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Redeem redeemer id nonce)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|Reverse:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string id:string nonce:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Reverses (Recovers) {} Nonce {}" [id nonce])]
                [(format "Succesfully reversed {} Nonce {}" [id nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Recover recoverer id nonce)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|Syphon:object{OuronetInfoV1.ClientInfo} (patron:string syphon-target:string ats:string syphon-amounts:[decimal])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU) (sa:string (ref-I|OURONET::OI|UC_ShortAccount syphon-target)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Syphons {} from ATS-Pair {} to {}" [syphon-amounts ats sa])]
                [(format "Succesfully syphoned from ATS-Pair {} to {}" [ats sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Syphon syphon-target ats syphon-amounts)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [syphon-amounts])))
    (defun URC_ATS|WithdrawRoyalties:object{OuronetInfoV1.ClientInfo} (patron:string ats:string target:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU) (sa:string (ref-I|OURONET::OI|UC_ShortAccount target)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Withdraws accrued Royalties of ATS-Pair {} to {}" [ats sa])]
                [(format "Succesfully withdrew Royalties of ATS-Pair {} to {}" [ats sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_WithdrawRoyalties ats target)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    ;; ---- ATS entity-completion: composite / hot-rbt ops (reuse existing readers) ----
    (defun URC_ATS|VestedCoil:object{OuronetInfoV1.ClientInfo}
        (patron:string coiler-vester:string ats:string coil-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ref-VST:module{VestingV1} VST)
                ;;
                (coil-data:object{AutostakeV2.CoilData} (ref-ATS::URC_RewardBearingTokenAmounts ats coil-token amount))
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [ (ref-ATSU::URCi_Coil coiler-vester ats coil-token amount)
                          (ref-VST::URCi_Vest coiler-vester target-account c-rbt c-rbt-amount offset duration milestones) ] []))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Coils {} {} on ATS-Pair {} and Vests the {} output to {} across {} milestone(s)" [amount coil-token ats c-rbt sa milestones])]
                [(format "Succesfully coiled and vested {} {} generating {} {} to {}" [amount coil-token c-rbt-amount c-rbt sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt-amount) milestones])))
    (defun URC_ATS|VestedCurl:object{OuronetInfoV1.ClientInfo}
        (patron:string curler-vester:string ats1:string ats2:string curl-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ref-VST:module{VestingV1} VST)
                ;;
                (coil1-data:object{AutostakeV2.CoilData} (ref-ATS::URC_RewardBearingTokenAmounts ats1 curl-token amount))
                (coil2-data:object{AutostakeV2.CoilData} (ref-ATS::URC_RewardBearingTokenAmounts ats2 (at "rbt-id" coil1-data) (at "rbt-amount" coil1-data)))
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [ (ref-ATSU::URCi_Curl curler-vester ats1 ats2 curl-token amount)
                          (ref-VST::URCi_Vest curler-vester target-account c-rbt2 c-rbt2-amount offset duration milestones) ] []))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Curls {} {} across ATS-Pairs {} and {} and Vests the {} output to {} across {} milestone(s)" [amount curl-token ats1 ats2 c-rbt2 sa milestones])]
                [(format "Succesfully curled and vested {} {} generating {} {} to {}" [amount curl-token c-rbt2-amount c-rbt2 sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt2-amount) milestones])))
    (defun URC_ATS|HOT-RBT|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates Pending Branding for Hot-RBT {}" [entity-id])]
                [(format "Pending Branding for Hot-RBT {} updated succesfully" [entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_UpdatePendingBranding entity-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|HOT-RBT|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrades Branding for Hot-RBT {} for {} month(s)" [entity-id months])]
                [(format "Hot-RBT {} succesfully upgraded for {} month(s)!" [entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-DPOF::URCi_UpgradeBranding months)) [])))
    (defun URC_ATS|HOT-RBT|Repurpose:object{OuronetInfoV1.ClientInfo} (patron:string hot-rbt:string nonce:integer repurpose-to:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF) (ref-VST:module{VestingV1} VST)
              (nonce-holder:string (ref-DPOF::UR_NonceHolder hot-rbt nonce)) (sa:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Repurposes Hot-RBT {} Nonce {} to {}" [hot-rbt nonce sa])]
                [(format "Hot-RBT {} Nonce {} succesfully repurposed to {}" [hot-rbt nonce sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-VST::URCi_RepurposeOrtoFungible hot-rbt nonce nonce-holder repurpose-to)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|AddHotRBT:object{OuronetInfoV1.ClientInfo} (patron:string ats:string hot-rbt:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATS:module{AutostakeV2} ATS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Hot-RBT {} to ATS-Pair {}" [hot-rbt ats])]
                [(format "Hot-RBT {} succesfully added to ATS-Pair {}" [hot-rbt ats])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATS::URCi_AddHotRBT ats hot-rbt)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_ATS|RemoveSecondary:object{OuronetInfoV1.ClientInfo} (patron:string remover:string ats:string reward-token:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-ATSU:module{AutostakeUsageV1} ATSU) (sa:string (ref-I|OURONET::OI|UC_ShortAccount remover)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Removes Secondary Reward-Token {} from ATS-Pair {}" [reward-token ats])]
                [(format "Secondary Reward-Token {} succesfully removed from ATS-Pair {} (balance returned to {})" [reward-token ats sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_RemoveSecondary remover ats reward-token)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    ;; [LIQUID]
    (defun LIQUID|INFO_UnwrapUrStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string unwrapper:string amount:decimal)
        (let
            (
                (ref-urcoin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                ;;
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount unwrapper))
                ;;
                (trial (try false (ref-urcoin::UR_UR|Balance (ref-DALOS::UR_AccountStoa unwrapper))))
                (iz-target-unregistered (= (typeof trial) "bool"))
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-urstoa-id:string (ref-DALOS::UR_UrStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-urstoa-id unwrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_TransferCumulator what-type w-urstoa-id unwrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Burn w-urstoa-id lq-sc))
                (ifp:decimal (+ ifp1 ifp2))
                (final-ifp:decimal
                    (if iz-target-unregistered
                        (+ ifp (* 5.0 (ref-DALOS::UR_UsagePrice "ignis|biggest")))
                        ifp
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Unwraps {} UrStoa to the Payment Key of the Unwrapper {}" [amount uw])]
                [(format "Succesfully unwrapped {} UrStoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron final-ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun LIQUID|INFO_WrapUrStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string wrapper:string amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS) 
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount wrapper))
                ;;
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-urstoa-id:string (ref-DALOS::UR_UrStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-urstoa-id wrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_TransferCumulator what-type w-urstoa-id wrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Mint w-urstoa-id lq-sc false))
                (ifp:decimal (+ ifp1 ifp2))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wraps {} UrStoa to the Payment Key of the Wrapper {}" [amount uw])]
                [(format "Succesfully wrapped {} UrStoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun LIQUID|INFO_UnwrapStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string unwrapper:string amount:decimal)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                ;;
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount unwrapper))
                ;;
                (trial (try false (ref-coin::get-balance (ref-DALOS::UR_AccountStoa unwrapper))))
                (iz-target-unregistered (= (typeof trial) "bool"))
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-stoa-id unwrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_TransferCumulator what-type w-stoa-id unwrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Burn w-stoa-id lq-sc))
                (ifp:decimal (+ ifp1 ifp2))
                (final-ifp:decimal
                    (if iz-target-unregistered
                        (+ ifp (* 5.0 (ref-DALOS::UR_UsagePrice "ignis|biggest")))
                        ifp
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Unwraps {} Stoa to the Payment Key of the Unwrapper {}" [amount uw])]
                [(format "Succesfully unwrapped {} Stoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron final-ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun LIQUID|INFO_WrapStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string wrapper:string amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS) 
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount wrapper))
                ;;
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-stoa-id wrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::URCi_TransferCumulator what-type w-stoa-id wrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Mint w-stoa-id lq-sc false))
                (ifp:decimal (+ ifp1 ifp2))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wraps {} Stoa to the Payment Key of the Wrapper {}" [amount uw])]
                [(format "Succesfully wrapped {} Stoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    (defun ORBR|INFO_Compress:object{OuronetInfoV1.ClientInfo}
        (client:string ignis-amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
                (ignis-to-ouro:[decimal] (ref-ORBR::URC_Compress ignis-amount))
                (ouro-remainder-amount:decimal (at 0 ignis-to-ouro))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Compresses {} Ignis GAS generating Ouroboros on {} with 98.5% efficiency; 1.5% is lost as Compression Fee" [ignis-amount sa])
                    "Only whole Ignis GAS Amounts greater than or equal to 1.0 can be used for Compression"
                    "Output depends on Ouroboros Price. A price of less than 1.00$ is treated as 1.00$ for Compression Math."
                ]
                [(format "Succesfully compressed {} Ignis GAS generating {} Ouroboros on {}" [ignis-amount ouro-remainder-amount sa])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun ORBR|INFO_Sublimate:object{OuronetInfoV1.ClientInfo}
        (client:string target:string ouro-amount:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                (sa1:string (ref-I|OURONET::OI|UC_ShortAccount client))
                (sa2:string (ref-I|OURONET::OI|UC_ShortAccount target))
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (ref-ORBR::URC_Sublimate ouro-remainder-amount))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if (= client target)
                        (format "Operation: Sublimates {} Ouroboros from {} for self usage, generating IGNIS with 99.0% efficiency; 1.0% is lost as Sublimation Fee" [ouro-amount sa1])
                        (format "Operation: Sublimates {} Ouroboros from {}, generating IGNIS on {} with 99.0% efficiency; 1.0% is lost as Sublimation Fee." [ouro-amount sa1 sa2])
                    )
                    "Only Ouroboros Amounts greater than or equal to 1.0 can be used for Sublimation"
                    "Output depends on Ouroboros Price. A price of less than 1.00$ is treated as 1.00$ for Sublimation Math."
                ]
                [
                    (if (= client target)
                        (format "Succesfully sublimated {} Ouro for self usage, generating {} Ignis GAS on {}" [ouro-amount ignis-amount sa1])
                        (format "Succesfully sublimated {} Ouro from {} to {}, generating {} Ignis GAS" [ouro-amount sa1 sa2 ignis-amount])
                    )
                   
                ]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;  [SWP]
    (defun URC_SWP|ChangeOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string new-owner:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SWP:module{SwapperV3} SWP)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-owner))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Changes Ownership of SWP-Pair {} to {}" [swpair sa])]
                [(format "Succesfully changed ownership of SWP-Pair {} to {}" [swpair sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_ChangeOwnership swpair)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_SWP|ModifyCanChangeOwner:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string new-boolean:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SWP:module{SwapperV3} SWP)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Modifies <can-change-owner> of SWP-Pair {} to {}" [swpair new-boolean])]
                [(format "Succesfully updated <can-change-owner> of SWP-Pair {} to {}" [swpair new-boolean])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_ModifyCanChangeOwner swpair)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_SWP|ModifyWeights:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string new-weights:[decimal])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SWP:module{SwapperV3} SWP)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Modifies weights of SWP-Pair {} to {}" [swpair new-weights])]
                [(format "Succesfully updated SWP-Pair {} weights to {}" [swpair new-weights])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_ModifyWeights swpair)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_SWP|ToggleAddLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_ToggleAddLiquidity swpair toggle)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Enables adding liquidity for SWP-Pair {}" [swpair])
                        (format "Operation: Disables adding liquidity for SWP-Pair {}" [swpair])
                    )
                ]
                [
                    (if toggle
                        (format "Succesfully enabled adding liquidity for SWP-Pair {}" [swpair])
                        (format "Succesfully disabled adding liquidity for SWP-Pair {}" [swpair])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_SWP|ToggleSwapCapability:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SWPU:module{SwapperUsageV2} SWPU)
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPU::URCi_ToggleSwapCapability swpair toggle)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Enables swapping for SWP-Pair {}" [swpair])
                        (format "Operation: Disables swapping for SWP-Pair {}" [swpair])
                    )
                ]
                [
                    (if toggle
                        (format "Succesfully enabled swapping for SWP-Pair {}" [swpair])
                        (format "Succesfully disabled swapping for SWP-Pair {}" [swpair])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [toggle]
            )
        )
    )
    (defun URC_SWP|EnableFrozenLP:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                ;;
                (kfp-issue:decimal (ref-DALOS::UR_UsagePrice "dptf"))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_EnableFrozenLP patron swpair)))
                (kfp:decimal
                    (if is-stoa-zero
                        0.0
                        (if (= current-frozen-link BAR)
                            kfp-issue 0.0
                        )
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Enables the Frozen LP Functionality for the SWP-Pair {} " [swpair])
                    (if (= current-frozen-link BAR)
                        (format "Also Issues a Frozen Link for the LP {}" [lp-id])
                        (format "Doesnt Issue a Frozen Link for the LP {} as it already exists with {}" 
                            [lp-id current-frozen-link]
                        )
                    )
                ]
                [
                    (if (= current-frozen-link BAR)
                        (format 
                            "Succesfully Issued Frozen LP and enabled Frozen LP Functionality on SWP-Pair {}" 
                            [swpair]
                        )
                        (format 
                            "Succesfully enabled Frozen LP Functionality on SWP-Pair {}, without issuing a Frozen LP, as it allready exists with id {}" 
                            [swpair current-frozen-link]
                        )
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron kfp)
                []
            )
        )
    )
    (defun URC_SWP|EnableSleepingLP:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                ;;
                (kfp-issue:decimal (ref-DALOS::UR_UsagePrice "dpmf"))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_EnableSleepingLP patron swpair)))
                (kfp:decimal
                    (if is-stoa-zero
                        0.0
                        (if (= current-sleeping-link BAR)
                            kfp-issue 0.0
                        )
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Enables the Sleeping LP Functionality for the SWP-Pair {} " [swpair])
                    (if (= current-sleeping-link BAR)
                        (format "Also Issues a Sleeping Link for the LP {}" [lp-id])
                        (format "Doesnt Issue a Sleeping Link for the LP {} as it already exists with {}" 
                            [lp-id current-sleeping-link]
                        )
                    )
                ]
                [
                    (if (= current-sleeping-link BAR)
                        (format 
                            "Succesfully Issued Sleeping LP and enabled Sleeping LP Functionality on SWP-Pair {}" 
                            [swpair]
                        )
                        (format 
                            "Succesfully enabled Sleeping LP Functionality on SWP-Pair {}, without issuing a Sleeping LP, as it allready exists with id {}" 
                            [swpair current-sleeping-link]
                        )
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron kfp)
                []
            )
        )
    )
    (defun URC_SWP|UpdateAmplifier:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string amp:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWP:module{SwapperV3} SWP))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates Amplifier of SWP-Pair {} to {}" [swpair amp])]
                [(format "Amplifier of SWP-Pair {} succesfully set to {}" [swpair amp])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_UpdateAmplifier swpair)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [amp])))
    (defun URC_SWP|UpdateFee:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string new-fee:decimal lp-or-special:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWP:module{SwapperV3} SWP))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates {} Fee of SWP-Pair {} to {}" [(if lp-or-special "LP" "Special") swpair new-fee])]
                [(format "Fee of SWP-Pair {} succesfully set to {}" [swpair new-fee])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_UpdateFee swpair)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [new-fee])))
    (defun URC_SWP|UpdateSpecialFeeTargets:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string targets:[string])
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWP:module{SwapperV3} SWP))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates Special-Fee targets of SWP-Pair {} to {}" [swpair targets])]
                [(format "Special-Fee targets of SWP-Pair {} succesfully updated" [swpair])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_UpdateSpecialFeeTargets swpair)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [targets])))
    (defun URC_SWP|ToggleFeeLock:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string toggle:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWP:module{SwapperV3} SWP))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Locks Fee Settings of SWP-Pair {}" [swpair]) (format "Operation: Unlocks Fee Settings of SWP-Pair {}" [swpair]))]
                [(if toggle (format "Fee Settings of SWP-Pair {} succesfully locked" [swpair]) (format "Fee Settings of SWP-Pair {} succesfully unlocked" [swpair]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_ToggleFeeLock swpair toggle)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])))
    (defun URC_SWP|UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWP:module{SwapperV3} SWP))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates Pending Branding for SWP-Pair {}" [entity-id])]
                [(format "Pending Branding for SWP-Pair {} updated succesfully" [entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWP::URCi_UpdatePendingBranding entity-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_SWP|UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWP:module{SwapperV3} SWP))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrades Branding for SWP-Pair {} for {} month(s)" [entity-id months])]
                [(format "SWP-Pair {} succesfully upgraded for {} month(s)!" [entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-SWP::URCi_UpgradeBranding months)) [])))
    (defun URC_SWP|UpdatePendingBrandingLPs:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string entity-pos:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates Pending LP-Branding for SWP-Pair {} entity-position {}" [swpair entity-pos])]
                [(format "Pending LP-Branding for SWP-Pair {} entity-position {} updated" [swpair entity-pos])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_UpdatePendingBrandingLPs swpair entity-pos)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])))
    (defun URC_SWP|UpgradeBrandingLPs:object{OuronetInfoV1.ClientInfo} (patron:string swpair:string entity-pos:integer months:integer)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrades LP-Branding for SWP-Pair {} entity-position {} for {} month(s)" [swpair entity-pos months])]
                [(format "LP-Branding for SWP-Pair {} entity-position {} upgraded for {} month(s)!" [swpair entity-pos months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-SWPLC::URCi_UpgradeBrandingLPs months)) [])))
    (defun URC_SWP|Fuel:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                ;;
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_Fuel account swpair input-amounts true)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Fuels SWP-Pair {} " [swpair])
                    (format "Fueling with {} {} without issuing LP Tokens, increases LP Value" [input-amounts pool-tokens])
                    "WARNING: Spent tokens can never be recovered, permanently increasing LP Value"
                ]
                [(format "Succesfully fueled SWP-Pair {} with Token Amounts {}" [swpair input-amounts])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_SWP|Firestarter:object{OuronetInfoV1.ClientInfo}
        (firestarter:string)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                ;;
                (input-ids:[string] [wstoa-id])
                (input-amounts:[decimal] [10.0])
                (output-id:string ouro-id)
                ;;
                (swpair:string (ref-SWP::UR_PrimordialPool))
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
                ;;
                (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                
                (input-positions:[integer] (ref-SWPI::URC_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                (dtso:object{UtilitySwpV1.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez firestarter pool-type dsid fees A X X-prec input-positions output-position W)
                )
                (gained-ouro:decimal (at "o-id-netto" dtso))
                ;;
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 gained-ouro ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (ref-ORBR::URC_Sublimate ouro-remainder-amount))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Uses 10 Native Stoa as Fuel to create Ignis GAS"]
                [(format "Succesfully used 10 Stoa to generate {} IGNIS with no IGNIS Costs" [ignis-amount])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;; ---- SWP entity-completion: issue ops (all share SWPI|URCi_Issue [IGNIS] + dptf+swp [STOA]) ----
    (defun URC_SWP|IssueStable:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS) (ref-SWPI:module{SwapperIssueV3} SWPI) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a Stable SWP-Pair with {} pool-tokens on Account {}" [(length pool-tokens) sa])]
                [(format "Stable SWP-Pair issued succesfully on Account {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPI::URCi_Issue account pool-tokens)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (+ (ref-DALOS::UR_UsagePrice "dptf") (ref-DALOS::UR_UsagePrice "swp"))) [])))
    (defun URC_SWP|IssueStandard:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS) (ref-SWPI:module{SwapperIssueV3} SWPI) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a Standard SWP-Pair with {} pool-tokens on Account {}" [(length pool-tokens) sa])]
                [(format "Standard SWP-Pair issued succesfully on Account {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPI::URCi_Issue account pool-tokens)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (+ (ref-DALOS::UR_UsagePrice "dptf") (ref-DALOS::UR_UsagePrice "swp"))) [])))
    (defun URC_SWP|IssueWeighted:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS) (ref-SWPI:module{SwapperIssueV3} SWPI) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a Weighted SWP-Pair with {} pool-tokens on Account {}" [(length pool-tokens) sa])]
                [(format "Weighted SWP-Pair issued succesfully on Account {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPI::URCi_Issue account pool-tokens)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (+ (ref-DALOS::UR_UsagePrice "dptf") (ref-DALOS::UR_UsagePrice "swp"))) [])))
    (defun URC_SWP|IssueStablePool:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS) (ref-SWPI:module{SwapperIssueV3} SWPI) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a Stable SWP-Pair (multistep) with {} pool-tokens on Account {}" [(length pool-tokens) sa])]
                [(format "Stable SWP-Pair issued succesfully on Account {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPI::URCi_Issue account pool-tokens)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (+ (ref-DALOS::UR_UsagePrice "dptf") (ref-DALOS::UR_UsagePrice "swp"))) [])))
    (defun URC_SWP|IssueStandardPool:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS) (ref-SWPI:module{SwapperIssueV3} SWPI) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a Standard SWP-Pair (multistep) with {} pool-tokens on Account {}" [(length pool-tokens) sa])]
                [(format "Standard SWP-Pair issued succesfully on Account {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPI::URCi_Issue account pool-tokens)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (+ (ref-DALOS::UR_UsagePrice "dptf") (ref-DALOS::UR_UsagePrice "swp"))) [])))
    (defun URC_SWP|IssueWeightedPool:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS) (ref-SWPI:module{SwapperIssueV3} SWPI) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a Weighted SWP-Pair (multistep) with {} pool-tokens on Account {}" [(length pool-tokens) sa])]
                [(format "Weighted SWP-Pair issued succesfully on Account {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPI::URCi_Issue account pool-tokens)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (+ (ref-DALOS::UR_UsagePrice "dptf") (ref-DALOS::UR_UsagePrice "swp"))) [])))
    (defun SWP|INFO_SinglePoolSwap:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-id:string input-amount:decimal output-id:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData [input-id] [input-amount] output-id)
                )
            )
            (UCX_Swap patron account swpair dsid)
        )
    )
    (defun SWP|INFO_MultiPoolSwap:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
            )
            (UCX_Swap patron account swpair dsid)
        )
    )
    ;;
    (defun URC_SWP|AddLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Standard (native-LP) Liquidity to SWP-Pair {} with amounts {}" [swpair input-amounts])]
                [(format "Succesfully added Standard Liquidity to SWP-Pair {} from Account {}" [swpair sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_AddStandardLiquidity account swpair input-amounts stoa-pid)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [input-amounts])))
    (defun URC_SWP|AddStandardLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Standard (native-LP) Liquidity to SWP-Pair {} with amounts {} (multistep)" [swpair input-amounts])]
                [(format "Succesfully added Standard Liquidity to SWP-Pair {} from Account {}" [swpair sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_AddStandardLiquidity account swpair input-amounts stoa-pid)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [input-amounts])))
    (defun URC_SWP|AddIcedLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Iced Liquidity to SWP-Pair {} with amounts {}" [swpair input-amounts])]
                [(format "Succesfully added Iced Liquidity to SWP-Pair {} from Account {}" [swpair sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_AddIcedLiquidity account swpair input-amounts stoa-pid)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [input-amounts])))
    (defun URC_SWP|AddGlacialLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Glacial Liquidity to SWP-Pair {} with amounts {}" [swpair input-amounts])]
                [(format "Succesfully added Glacial Liquidity to SWP-Pair {} from Account {}" [swpair sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_AddGlacialLiquidity account swpair input-amounts stoa-pid)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [input-amounts])))
    (defun URC_SWP|AddFrozenLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Frozen Liquidity ({} {}) to SWP-Pair {}" [input-amount frozen-dptf swpair])]
                [(format "Succesfully added Frozen Liquidity to SWP-Pair {} from Account {}" [swpair sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_AddFrozenLiquidity account swpair frozen-dptf input-amount stoa-pid)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [(ref-I|OURONET::OI|UC_FormatTokenAmount input-amount)])))
    (defun URC_SWP|AddSleepingLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS) (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) (sa:string (ref-I|OURONET::OI|UC_ShortAccount account)))
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds Sleeping Liquidity ({} Nonce {}) to SWP-Pair {}" [sleeping-dpof nonce swpair])]
                [(format "Succesfully added Sleeping Liquidity to SWP-Pair {} from Account {}" [swpair sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_AddSleepingLiquidity account swpair sleeping-dpof nonce stoa-pid)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonce])))
    (defun URC_SWP|RemoveLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string lp-amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                ;;
                (pool-token-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (pt-output-amounts:[decimal] (ref-SWPL::URC_LpBreakAmounts swpair lp-amount))
                ;;
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_RemoveLiquidity account swpair lp-amount)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Removes Liquidity on SWP-Pair {}" [swpair])
                    (format "Unfolding {} {} (LP-Tokens)." [lp-amount lp-id])
                    (format "This generates {} {}" [pt-output-amounts pool-token-ids])
                ]
                [(format "Removed {} LP Tokens from SWP-Pair {}, yielding {} of all Pool Tokens" [lp-amount swpair pt-output-amounts])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    (defun UDC_HibernatedNoncesView:object{HibernatedNoncesView}
        (n:integer a:decimal b:time c:time d:decimal e:decimal f:decimal)
        {"nonce"                    : n
        ,"nonce-supply"             : a
        ,"mint-time"                : b
        ,"release-time"             : c
        ,"hibernating-fee-promile"  : d
        ,"remainder"                : e
        ,"hibernating-fee"          : f}
    )
    ;;{F4}  [CAP]
    ;;
    ;;<======================>
    ;;[DALOS-INFO] — relocated from INFO-ZERO (Phase 1.2). Pure presentation; wrap IGNIS's DALOS|URCi_*.
    ;;<======================>
    (defun URC_DALOS|ControlSmartAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_ControlSmartAccount account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Execute Smart Account Control."]
                [(format "Smart Ouronet Account {} controlled succesfully" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DALOS|DeploySmartAccount:object{OuronetInfoV1.ClientInfo} (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                (kfp:decimal (ref-IGNIS::DALOS|URCi_DeploySmartAccount))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Deploy a Smart Ouronet Account."]
                [(format "Smart Ouronet Account {} deployed succesfully" [sa])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (if is-stoa-zero (ref-I|OURONET::OI|UDC_NoStoaCosts) (ref-I|OURONET::OI|UDC_FullStoaCosts kfp))
                []
            )
        )
    )
    (defun URC_DALOS|DeployStandardAccount:object{OuronetInfoV1.ClientInfo} (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                (kfp:decimal (ref-IGNIS::DALOS|URCi_DeployStandardAccount))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Deploy a Standard Ouronet Account."]
                [(format "Standard Ouronet Account {} deployed succesfully" [sa])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (if is-stoa-zero (ref-I|OURONET::OI|UDC_NoStoaCosts) (ref-I|OURONET::OI|UDC_FullStoaCosts kfp))
                []
            )
        )
    )
    (defun URC_DALOS|RotateGovernor:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateGovernor account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Governor-Guard of an Ouronet Account."]
                [(format "Ouronet Account {} Governor-Guard rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DALOS|RotateGuard:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateGuard account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Primary-Guard of an Ouronet Account."]
                [(format "Ouronet Account {} Primary-Guard rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DALOS|RotateStoa:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateStoa account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Attached STOA-Address of an Ouronet Account."]
                [(format "Ouronet Account {} Attached Stoa-Address rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DALOS|RotateSovereign:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_RotateSovereign account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Rotate the Sovereign of a Smart Ouronet Account."]
                [(format "Smart Ouronet Account {} Sovereign rotated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DALOS|UpdateEliteAccount:object{OuronetInfoV1.ClientInfo} (patron:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_UpdateEliteAccount patron)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Update Elite Account Data for a single Ouronet Account"]
                [(format "Elite Account Data for {} updated succesfully!" [sa])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_DALOS|UpdateEliteAccountSquared:object{OuronetInfoV1.ClientInfo} (patron:string sender:string receiver:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-IGNIS::DALOS|URCi_UpdateEliteAccountSquared patron)))
                (sa1:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa2:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Update Elite Account Data for a two Ouronet Accounts"]
                [(format "Elite Account Data for {} and {} updated succesfully!" [sa1 sa2])]
                (if is-ignis-zero (ref-I|OURONET::OI|UDC_NoIgnisCosts) (ref-I|OURONET::OI|UDC_IgnisCosts patron ifp))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;
)