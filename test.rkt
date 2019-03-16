#lang racket

(require rackunit)
(require net/url)
(require "main.rkt")

(test-case "main"
	(check-equal? 
		(route-match "/blog/name/page/page" "/blog/name/page/page")
		'())

	(check-false 
		(route-match "/blog/name/page/page" "/another/route"))

	(check-equal? 
		(route-match "/blog/:name/page/:page" "/blog/racket/page/2")
		'((name . "racket") (page . "2")))

	(check-equal? 
		(route-match "/blog/:name/page/:page" "blog/racket/page/2")
		'((name . "racket") (page . "2")))

	(check-equal? 
		(route-match "blog/:name/page/:page" "/blog/racket/page/2")
		'((name . "racket") (page . "2")))

	(check-equal? 
		(route-match "/blog/:name/*page/:page" "/blog/racket/super-page/2")
		'((name . "racket") (page . "2")))

	(check-equal? 
		(route-match "/blog/:name/**/:page" "/blog/racket/super/buper/page/2")
		'((name . "racket") (page . "2")))

	(check-equal? 
		(route-match "/blog/:name/**" "/blog/racket/super/buper/page/2")
		'((name . "racket")))

	(check-equal? 
		(route-match "/blog/*/page/:page" "/blog/racket/page/2")
		'((page . "2")))

	(check-equal? 
		(route-match "/blog/:name/page/:page" "https://racket-lang.org/blog/racket/page/2")
		'((name . "racket") (page . "2")))

	(check-exn exn:fail:contract? 
		(lambda ()
			(route-match "/blog/:name/page/:page" 123)
			'((name . "racket") (page . "2"))))

	(check-equal? 
		(route-match "/blog/:name/page/:page" (string->url "/blog/racket/page/2"))
		'((name . "racket") (page . "2")))
		
	(check-exn exn:fail:contract? 
		(lambda ()
			(route-compile 112233)))

	(define user-route (route-compile "/blog/:name/page/:page"))

	(check-equal? 
		(route-match user-route (string->url "/blog/racket/page/2"))
		'((name . "racket") (page . "2")))

	
	(define user-route2 (route-compile "/blog/:name/page/:page" 'page #px"\\d+"))

	(check-equal? 
		(route-match user-route2 (string->url "/blog/racket/page/2"))
		'((name . "racket") (page . "2")))

	(check-false 
		(route-match user-route2 (string->url "/blog/racket/page/qwe"))))
	