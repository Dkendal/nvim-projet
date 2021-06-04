(local template {})

(local lpeg (require :lpeg))
(local inspect (require :inspect))

(lpeg.locale lpeg)

; (ins (lpeg.match G ""))
; (ins (lpeg.match G :foo/bar.fnl))
; (ins (lpeg.match G "{}"))
; (ins (lpeg.match G "{1}{2}"))
; (ins (lpeg.match G "{1}"))
; (ins (lpeg.match G "{ 1 | hello | world }"))
; (ins (lpeg.match G "spec/{$1}_spec.fnl"))

(fn template.eval [str binding opts]
  (var cursor 1)

  (fn bind []
    (set cursor (+ cursor 1))
    (. binding (- cursor 1)))

  (fn red [acc mod]
    (local func (assert (. opts mod) (.. mod " not defined")))
    (func acc))

  (local grammar ;
         (let [P lpeg.P
               S lpeg.S
               R lpeg.R
               V lpeg.V
               C lpeg.C
               empty (P "")
               ws lpeg.space
               space (^ lpeg.space 0)
               open (* (P "{") space)
               close (* space (P "}"))
               pipe (P "|")
               parans (+ open close)
               nonparans (- 1 parans)
               text (^ nonparans 1)
               S (V :S)
               Body (V :Body)
               Mod (V :Mod)
               Template (V :Template)]
           (P {1 (-> (* Template) (lpeg.Ct))
               :Template (* open Body close)
               :Body (lpeg.Cf (* (-> empty (/ bind))
                                 (^ (* Mod (^ (* pipe Mod) 0)) -1))
                              red)
               :Mod (* space (C (^ (- 1 (+ pipe close ws)) 1)) space)
               ;;
               })))
  (lpeg.match grammar str))

template

