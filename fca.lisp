(defpackage #:fca
  (:use #:cl #:alexandria #:hu.dwim.defclass-star #:iterate
        #:fiveam))

(in-package #:fca)

;;; Formal context (objects G, attributes M, relation L)
;;; is modeled as (list, list, list of conses).
;;; I is a lambda implementing L.

(defun phi-mapping (g m i)
  "All M1 from full set M that satisfy I for all G1"
  (iter
    (for m1 in m)
    (when (iter (for g1 in g) (always (funcall i g1 m1)))
      (collect m1))))

(defun psi-mapping (m g i)
  "All G1 from full set G that satisfy I for all M1"
  (phi-mapping m g (lambda (m1 g1) (funcall i g1 m1))))

(defun g-closure (a g m i)
  "Closure from A ⊆ G onto G"
  (psi-mapping (phi-mapping a m i) g i))

(defun m-closure (b m g i)
  "Closure from B ⊆ M onto M"
  (phi-mapping (psi-mapping b g i) m i))

(defun next-closure (a m l)
  "Next closed set of closure L on A ⊆ M"
  (iter
    (for (m1 . mr) on m)
    (if (member m1 a)
        (setf a (remove m1 a))
        (let ((b (funcall l (list* m1 a))))
          (when (null (intersection mr (set-difference b a)))
            (return b))))))

(defun ask-y-or-n ()
  (iter
    (write-string "Y or N: ")
    (case (ignore-errors (char (read-line) 0))
      (#\y (return t))
      (#\n (return nil)))))

(defun user-confirm (from to)
  (let ((*print-case* :downcase))
    (if from
        (format t "If something is~{ ~a~}, is it~{ ~a~}? " from (set-difference to from))
        (format t "Is everything~{ ~a~}? " to)))
  (ask-y-or-n))

(defun user-extend (e)
  (format t "Counterexample: ")
  (list* (read) e))

(defun assoc-relation (l)
  (lambda (g1 m1)
    (member (cons g1 m1) l :test #'equal)))

(defun rule-based-closure (rules)
  (lambda (b)
    (log:i rules b)
    (iter
      (for changed = nil)
      (iter
        (for (p . q) in rules)
        (when (subsetp p b)
          (unless (subsetp q b)
            (setf b (union b q)
                  changed t))))
      (unless changed (return b)))))

(defun explore (e m i)
  "E ⊆ M; J is E → M
Initially E is NIL.
Change E.
Return values: implications L, (E, M, I)"
  (let (l)
    (iter
      (with a = nil) ; A enumerates closed sets of m-closure on M, E, I
      (iter
        (for ajj = (m-closure a m e i))
        (until (set-equal a ajj))
        (if (user-confirm a ajj)
            (return (push (cons a ajj) l))
            (setf e (user-extend e))))
      (while (setf a (next-closure a m (rule-based-closure l)))))
    (values l (list e m i))))
