(local mod {})

(fn mod.t [key]
  `(vim.api.nvim_replace_termcodes ,key true true true))

(fn mod.alias [term]
  "Define a local with the same name as the last property"
  (local pattern ".*%.(.*)")
  (local head
         (-> term (. 1)
             (string.match pattern)
             (sym)))
  `(local (unquote head) ,term))

mod
