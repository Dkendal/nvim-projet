(local helpers {})

(fn helpers.desc [str ...]
   `(describe ,str (fn [] ,...)))

(fn helpers.it [str ...]
   `(test ,str (fn [] ,...)))

helpers
