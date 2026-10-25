;; ---------------------------------------------------------------------------
;; PureV10 -- transaction 24 (MANUAL, not generated)
;; Label : STOAICO contribution -- 4200.0 v-USD
;;
;; RUN THIS AFTER transaction 23 (the repair). Without it, this call aborts
;; with the exact same "Key distribution-round not found in object" tx23 exists
;; to fix -- A_Stake reads a distribution-round unconditionally.
;;
;; Replays the owner's own real transaction
;; (explorer.stoachain.com/transactions/mJhPVaPs_0mCgc5tT7cAs1S41WbRdeHvAziy4B5QC9M)
;; -- same patron, same account, same amount. Verified against real live chain
;; content (STOAICO upgraded + repaired, exactly as tx21 + tx23 above would
;; leave it) before this file was written: it clears the distribution-round bug
;; cleanly and reaches ordinary signature-authorization territory, which is the
;; correct and expected next check once this is actually signed and sent.
;;
;; THIS FILE IS NOT GENERATED, same reasoning as tx23 -- see that file's header.
;; `_purev10.py` only manages files matching `NN_deploy.pact`; this is not one.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

(ouronet-ns.STOAICO.A_Stake
  "Ѻ.ÔlзюĞÞýжůúìЮRПы3эérДÏõÀЬâùèCχżÖtDlÅgБ6яğèιмgnŸŒćçнÎэnÅ5tĐηψìãŮĘΘe¢ЬA₳ΔЛ¢ρЦκĎвÈбe7ÖJΔÏ3șφûηnŤäčúμ£ЧλíĆC₱ëż₳χдYιΔäđAąoĞъØ∇hůτNÔRxgŹŹЫĐ7FςЭ8ΣσвhD3жâó¥ышΨψşψžźëÅôщc"
  "Ѻ.ìѺďΘčμЮÚşŁì92lźřWмPòíFùЛgßCÊȚδğďŘTπΠrπмЮ6ŁYŘэHóęÀSăλьПO€ЮrØòш2ΓεîțůOÂŁŻДÍ¥ôWxí4ïçдå₿ЙÒεЗzÝăÚÆπБцìcÕyьΘæěЖù₱фщđÝKÚßzUÉÍЬŒΠYvVŻUЫýčWŘвůćCČΦú2ãбşèуÓçË€ïmôrýмúüÄЬáó"
  4200.0
)
