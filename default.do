#!/usr/bin/env fennel --add-package-path ./lua_modules/share/lua/5.1/?.lua
; vim: ft=fennel:

(local inspect (require :inspect))
(local lume (require :lume))
(local sh os.execute)

(fn redo-ifchange [...]
  (sh (table.concat ["redo-ifchange" ...] " ")))

(fn warn [...] (io.stderr:write ...))
(fn ins [...] (warn (inspect ...)))

(match arg
  [:all]
  (do (redo-ifchange :deps))

  [:deps _ _]
  (do (redo-ifchange :lume.rocks))

  _
  (ins arg)) 
