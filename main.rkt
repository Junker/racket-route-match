#lang racket
(require net/url)

(provide route-match route-compile)


(struct compiled-route (source regexp keys constraints absolute?))

(define (route-match route request)
	(let 
		([croute
			(cond
				[(compiled-route? route) route]
				[(string? route) (route-compile route)])]
		[path 
			(cond 
				[(url? request) (path->string (url->path request))]
				[(string? request) (path-string-add-leading-slash (if (url-string-absolute? request) (url-string-abs-to-rel request) request))])])
		

		(define regx (compiled-route-regexp croute))
		(define constraints (compiled-route-constraints croute))
		(define keys (compiled-route-keys croute))

		(define matches (regexp-match* regx path #:match-select cdr))


		(unless (empty? matches)
			(set! matches (car matches))

			(define constraints_match?
				(andmap (lambda (constraint)
					(let*
						([constraint_key (first constraint)]
						[constraint_regx (second constraint)]
						[key_idx (index-of keys constraint_key eq?)])
							(or (false? key_idx) (regexp-match? constraint_regx (list-ref matches key_idx)))))
					constraints))

			(when constraints_match? 
				(map cons keys matches)))))



(define (route-compile route . constraints)
	(define path 
		(path-string-add-leading-slash route))

	(unless (even? (length constraints))
		(raise-argument-error 'route-compile-constraints "wrong constraints argument" constraints))

	(compiled-route
		path 
		(path-string->regexp path) 
		(path-string-extract-keys path) 
		(list-splitparts constraints 2) 
		(url-string-absolute? path)))


;;;; PRIVATE

(define (path-string->regexp path)
	(regexp
		(string-append
			"^"
			(regexp-replace* #rx":[^/]+" (string-replace path "*" "[^/?]+") "([^/?]+)") 
			"(?:\\?|$)")))

(define (path-string-extract-keys path)
	(map string->symbol (regexp-match* #rx":([^/]+)" path #:match-select cadr)))

(define (url-string-absolute? url)
	(regexp-match? #rx"^https?:?//" url))

(define (path-string-add-leading-slash path)
	(cond
		[(eq? (string-ref path 0) #\/) path]
		[else (string-append "/" path)]))

(define (url-string-abs-to-rel url)
	(regexp-replace #rx"^https?://[^/]+" url ""))

(define (list-splitparts lst num)
  (letrec ((recurse
            (lambda (lst num acc)
              (if (null? lst)
                acc
                (recurse (drop lst num) num (append acc (list (take lst num))))))))
    (recurse lst num '())))
