(cond 	((atom '(1 2 3)) 555)
		((atom (+ 2 3 4)) 666)
		((atom (+ 5 6 7)) 777))

(eq 5 5)

(defparameter hey 1)

(defparameter hey (+ hey 1))
(defparameter hey (+ hey 1))
(defparameter hey (+ hey 1))
(defparameter hey (+ hey 1))

(defparameter *hello* (lambda (x) (+ x x)))

(*hello* 5)

(+ 2 2 2)

(+ 2 2 (+ 4 5 6) (- 5 5 5))

(- 5 5 11)

(atom 5)

(defparameter hello (quote (hey hey hey)))

(cons hello (quote (2 3 4 5 6 7)))

(apply (quote +)  (quote (5 5 5 5)))
(apply (quote +)  '(5 5 5 5))


(funcall (quote +)  5 5 55 5)

(funcall (lambda (x y z a b) (- x y z a b)) 5 5 5 5 5)

(+ 1)

(atom (+ 1 2 3))

(atom (quote (5 5)))

(funcall (quote +) 1 2 3 4 5 6)


(quote (+ 2 3 4))
'(+ 2 3 4)

(car (quote (4 5 6 7)))
(car '('a 4 5 6 7))

(car '((quote a) 4 5 6 7))

'+
(quote +)

(funcall '+ 1 2 3 4 5 6)
(apply '+ '(5 5 5 5))

(quote (1 2 3 (quote (4 5 6)) (quote (7 8 9))))
'(1 2 3 '(4 5 6) '(7 8 9))


(defparameter *eq-test* '(1 2 3))
(defparameter *eq-test-copy* *eq-test*)
(eq *eq-test* *eq-test-copy*)

;; All the above are working. Cool!

// These still need to work...

(defparameter rest 'cdr)

(rest '(1 2 3))

rest

a

'5

5

(funcall (lambda (x) ((quote (x arg))) 5 8 9 10))
