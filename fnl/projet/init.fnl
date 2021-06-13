(require-macros :projet.macros)

(local lume (require :lume))
(local toml (require :toml))

(local lpeg (require :lpeg))

(local cmd vim.cmd)
(local v vim.fn)

(fn ins [...]
  (print (.. ((require :fennelview) ...) "\n"))
  ...)

(global projet {})

(local bmap (partial vim.api.nvim_buf_set_keymap 0))

(fn map-blank [str]
  "Map empty strings to nil, everything else is passed through."
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

(fn find-config []
  (local opts ".;")
  (or (map-blank (v.findfile :projet.toml opts))
      (map-blank (v.findfile :.projet.toml opts))))

(fn read-config [file]
  (-> (with-open [fd (io.open file :r)]
        (fd:read :a))
      (toml.parse)))

(fn get-linkfile [link matches]
  (string.format link.pattern matches))

(fn set-links [config filename]
  (fn pred [rule]
    (set vim.b.projet.rule rule)
    (local pat (assert rule.pattern))
    ;; Trim a ./ prefix off the filename
    (local filename (or (string.match filename "%./(.*)") filename))
    (local matches [(string.match filename pat)])
    (when (-> (length matches) (> 0))
      (each [_ link (ipairs (assert rule.links))]
        ;; Define commands for each link
        (local linkfile (get-linkfile link (unpack matches)))
        ;; TODO check if commmand exists
        (vim.cmd (.. "command! -buffer A" (.. " :e " linkfile)))
        (vim.cmd (.. "command! -buffer A" link.name (.. " :e " linkfile)))
        ;; TODO check if mapping exists
        (bmap :n :<leader>pa :<cmd>A<cr> {}))))

  (lume.match config.rules pred))

(fn projet.status []
  (-> vim.b.projet (vim.inspect) (print)))

;; Callbacks
(set projet.callbacks {})

(fn projet.callbacks.detect []
  (local file (find-config))
  (when file
    (local config (read-config file))
    (set vim.b.projet {:buf {: file : config}})
    (set-links config (v.bufname))))

(fn projet.init []
  (vim.cmd "command! ProjetStatus :call v:lua.projet.status()")
  (augroup :projet
           [:au!
            {:event [:BufEnter :BufReadPost :BufNewFile]
             :pat "*"
             :cmd "call v:lua.projet.callbacks.detect()"}]))

projet

