(in-package #:fca)

(def-suite :fca)
(in-suite :fca)

(declaim (ftype (function (fixnum) (or fixnum null)) prime?))
(defun prime? (n)
  (declare (optimize speed (safety 0)))
  (cond
    ((< n 2) nil)
    ((< n 4) n)
    ((evenp n) nil)
    ((< n 9) n)
    ((zerop (rem n 3)) nil)
    (t (iter (declare (type fixnum i))
             (for i from 5 to (floor (sqrt n)) by 6)
             (never (or (zerop (rem n i))
                        (zerop (rem n (+ i 2)))))
             (finally (return n))))))

(defmethod relation (g1 (m1 (eql 'even)))
  (evenp g1))
(defmethod relation (g1 (m1 (eql 'odd)))
  (oddp g1))
(defmethod relation (g1 (m1 (eql 'prime)))
  (prime? g1))

(defvar g '(1 2 3 4 5))
(defvar m '(even odd prime))

(test phi-psi-mapping
  (is (set-equal '(even prime) (phi-mapping '(2)         m 'relation)))
  (is (set-equal '(3 5)        (psi-mapping '(odd prime) g 'relation)))
  (is (set-equal '(1 3 5)          (g-closure '(1)        g m 'relation)))
  (is (set-equal '(even odd prime) (m-closure '(even odd) m g 'relation))))

(test rule-based-closure
  (is (set-equal '(1 2) (funcall (rule-based-closure '(((1) . (2)))) '(1)))))

(test next-closure
  (is (set-equal '(even) (next-closure nil m (rcurry 'm-closure m g 'relation)))))
