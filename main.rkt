#lang racket
(require net/url)

(provide route-match route-compile)


(struct compiled-route (source regexp keys constraints absolute?))

(define/contract (route-match route request)
	((or/c string? compiled-route?) (or/c url? string?) . -> . (or/c list? boolean?)) ;contract
	(let*  
		([croute
			(cond
				[(compiled-route? route) route]
				[(string? route) (route-compile route)])]
		[path 
			(cond 
				[(url? request) (path->string (url->path request))]
				[(string? request) (path-string-add-leading-slash (if (url-string-absolute? request) (url-string-abs-to-rel request) request))])]
		[regx (compiled-route-regexp croute)]
		[constraints (compiled-route-constraints croute)]
		[keys (compiled-route-keys croute)]
		[matches (regexp-match* regx path #:match-select cdr)])

		(let ([match? (if (empty? matches)
						#f
						(andmap (lambda (constraint)
								(let*
									([matches (car matches)]
									 [constraint_key (first constraint)]
									 [constraint_regx (second constraint)]
									 [key_idx (index-of keys constraint_key eq?)])
										(or (false? key_idx) (regexp-match? constraint_regx (list-ref matches key_idx)))))
							constraints))])
			(if match? 
				(map cons keys (car matches))
				#f))))



(define/contract (route-compile route [constraints '()])
	((string?) ((listof pair?)) . ->* . compiled-route?) ;contract

	(define path 
		(path-string-add-leading-slash route))

	(compiled-route
		path 
		(path-string->regexp path) 
		(path-string-extract-keys path) 
		constraints 
		(url-string-absolute? path)))


;;;; PRIVATE

(define (path-string->regexp path)
	(regexp
		(string-append
			"^"
			(regexp-replace* #rx":[^/]+" (string-replace (string-replace path "**" ".+?") "*" "[^/?]+") "([^/?]+)") 
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


