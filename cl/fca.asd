(asdf:defsystem fca
  :depends-on (alexandria
               hu.dwim.defclass-star iterate log4cl
               fiveam)
  :serial t
  :components ((:file "fca")))

(asdf:defsystem fca-test
  :depends-on (fca)
  :serial t
  :components ((:file "test")))

(defmethod asdf:perform ((op asdf:test-op) (system (eql (asdf:find-system :fca))))
  (asdf:load-system :fca-test)
  (funcall (intern (string '#:run!) :fiveam) :fca))
