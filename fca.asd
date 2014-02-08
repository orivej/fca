(asdf:defsystem fca
  :depends-on (alexandria
               hu.dwim.defclass-star iterate log4cl
               fiveam)
  :serial t
  :components ((:file "fca")))

(asdf:defsstem fca-test
  :depends-on (fca)
  :serial t
  :components ((:file "test")))
