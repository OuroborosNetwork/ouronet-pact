(module stoic-predicates "stoa-ns.stoa_master_one"

    @doc "Collection of custom keyset predicates for Stoa chain / Ouronet accounts"

    ;─────────────────────────────────────────────────────────────
    ;  Basic threshold predicates (ignore total count)
    ;─────────────────────────────────────────────────────────────

    (defun keys-1:bool (total:integer signed:integer)
        @doc "At least 1 signature (equivalent to keys-any)"
        (> signed 0)
    )
    (defun keys-3:bool (total:integer signed:integer)
        @doc "At least 3 signatures"
        (>= signed 3)
    )
    (defun keys-4:bool (total:integer signed:integer)
        @doc "At least 4 signatures"
        (>= signed 4)
    )

    ;─────────────────────────────────────────────────────────────
    ;  Percentage-based predicates
    ;─────────────────────────────────────────────────────────────

    (defun at-least-51pct:bool (total:integer signed:integer)
        @doc "Simple majority (> 50%)"
        (> signed (/ total 2))
    )
    (defun at-least-60pct:bool (total:integer signed:integer)
        @doc "≥ 60% of keys must sign"
        (>= (* signed 100) (* total 60))
    )
    (defun at-least-66pct:bool (total:integer signed:integer)
        @doc "≥ 2/3 (supermajority)"
        (>= (* signed 3) (* total 2))
    )
    (defun at-least-75pct:bool (total:integer signed:integer)
        @doc "≥ 75% of keys must sign"
        (>= (* signed 100) (* total 75))
    )
    (defun at-least-90pct:bool (total:integer signed:integer)
        @doc "Very high threshold (near unanimity)"
        (>= (* signed 10) (* total 9))
    )

    ;─────────────────────────────────────────────────────────────
    ;  Strict m-of-n predicates (check both count and threshold)
    ;─────────────────────────────────────────────────────────────

    (defun keys-2-of-3:bool (total:integer signed:integer)
        @doc "Exactly 3 keys, at least 2 must sign"
        (and (= total 3) (>= signed 2))
    )
    (defun keys-3-of-5:bool (total:integer signed:integer)
        @doc "Exactly 5 keys, at least 3 must sign"
        (and (= total 5) (>= signed 3))
    )
    (defun keys-4-of-7:bool (total:integer signed:integer)
        @doc "Exactly 7 keys, at least 4 must sign"
        (and (= total 7) (>= signed 4))
    )
    (defun keys-5-of-9:bool (total:integer signed:integer)
        @doc "Exactly 9 keys, at least 5 must sign"
        (and (= total 9) (>= signed 5))
    )

    ;─────────────────────────────────────────────────────────────
    ;  Tolerance / fault-tolerant predicates
    ;─────────────────────────────────────────────────────────────

    (defun all-but-one:bool (total:integer signed:integer)
        @doc "All keys except at most one must sign"
        (>= signed (- total 1))
    )
    (defun all-but-two:bool (total:integer signed:integer)
        @doc "All keys except at most two must sign"
        (>= signed (- total 2))
    )

)