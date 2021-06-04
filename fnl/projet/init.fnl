(require-macros :projet.macros)

(local lume (require :projet.rocks.lume))
(local toml (require :projet.rocks.toml))

(local lpeg (require :lpeg))

(alias vim.cmd)
(alias vim.inspect)
(local v vim.fn)

(local ins #(do
              (print (.. (inspect $...) "\n"))
              $...))

(global projet {})

; TODO parse mustache expressions
; (local G (let [P lpeg.P
;                S lpeg.S
;                R lpeg.R
;                V lpeg.V
;                Ct lpeg.Ct
;                C lpeg.C
;                Cg lpeg.Cg
;                Cs lpeg.Cs
;                Open (S "{")
;                Close (S "}")
;                Parens (-> Open (+ Close))
;                Text (- 1 Parens)
;                Expr (V :Expr)
;                Template (V :Template)]
;            (-> (P {1 Expr
;                    :Expr (-> Text (+ Template) (^ 0) (C) (Ct))
;                    :Template (-> Open (* (-> Text (^ 0) (C))) (* Close))})
;                (* -1))))

; (ins (lpeg.match G ""))
; (ins (lpeg.match G :foo/bar.fnl))
; (ins (lpeg.match G "{}"))
; (ins (lpeg.match G "{1}{2}"))
; (ins (lpeg.match G "{1}"))
; (ins (lpeg.match G "{ 1 | hello | world }"))
; (ins (lpeg.match G "spec/{$1}_spec.fnl"))

(local bmap (partial vim.api.nvim_buf_set_keymap 0))

(fn map-blank [str]
  (match str
    "" nil
    x x))

(fn au [opts]
  (local group (or opts.group ""))
  (local event (-> (assert opts.event ".event is required") (table.concat ",")))
  (local pat (assert opts.pat ".pat is required"))
  (local once (if opts.once :++once ""))
  (local nested (if opts.nested :++nested ""))
  (local cmd (assert opts.cmd ".cmd is required"))
  (-> [:au group event pat once nested cmd]
      (lume.reject #(= $1 ""))
      (table.concat " ")))

(fn augroup [groupname rules]
  (local rulestrings
         (lume.map rules #(if (-> $1 (type) (= :table)) (au $1) $1)))
  (-> [(.. "augroup " groupname) (table.concat rulestrings "\n") "augroup END"]
      (table.concat "\n")
      (vim.api.nvim_exec true)))

(fn read-config []
  (local file (or (map-blank (v.findfile :projet.toml))
                  (map-blank (v.findfile :.projet.toml))))
  (when file
    (-> (with-open [fd (io.open file :r)]
          (fd:read :a))
        (toml.parse))))

(fn set-links [config filename]
  (fn pred [rule]
    (local pat (assert rule.pattern))
    ;; Trim a ./ prefix off the filename
    (local filename (or (string.match filename "%./(.*)") filename))
    (local matches [(string.match filename pat)]) ; (ins filename) ; (ins matches)
    (when (-> (length matches) (> 0))
      (each [_ link (ipairs (assert rule.links))]
        ;; Define commands for each link
        (local linkfile (-> link.pattern (string.format (unpack matches))))
        ;; TODO check if commmand exists
        (vim.cmd (.. "command! -buffer A" (.. " :e " linkfile)))
        (vim.cmd (.. "command! -buffer A" link.name (.. " :e " linkfile)))
        ;; TODO check if mapping exists
        (bmap :n :<leader>pa :<cmd>A<cr> {}))))

  (lume.match config.rules pred))

;; Callbacks
(set projet.callbacks {})

(fn projet.callbacks.detect []
  (-?> (read-config)
       (set-links (v.bufname))))

(fn projet.init []
  (augroup :projet
           [:au!
            {:event [:BufEnter :BufReadPost :BufNewFile]
             :pat "*"
             :cmd "call v:lua.projet.callbacks.detect()"}]))

projet

