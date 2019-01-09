#lang racket

(require rackunit)
(require net/url)
(require "main.rkt")

(test-case "main"
	(check-equal? 
		(route-match "/blog/name/page/page" "/blog/name/page/page")
		'())

	(check-true 
		(void? (route-match "/blog/name/page/page" "/another/route")))

	(check-equal? 
		(route-match "/blog/:name/page/:page" "/blog/racket/page/2")
		'((:name . "racket") (:page . "2")))

	(check-equal? 
		(route-match "/blog/:name/page/:page" "blog/racket/page/2")
		'((:name . "racket") (:page . "2")))

	(check-equal? 
		(route-match "blog/:name/page/:page" "/blog/racket/page/2")
		'((:name . "racket") (:page . "2")))


	(check-equal? 
		(route-match "/blog/:name/page/:page" "https://racket-lang.org/blog/racket/page/2")
		'((:name . "racket") (:page . "2")))


	(check-equal? 
		(route-match "/blog/:name/page/:page" (string->url "/blog/racket/page/2"))
		'((:name . "racket") (:page . "2")))
		
	(define user-route (route-compile "/blog/:name/page/:page"))

	(check-equal? 
		(route-match user-route (string->url "/blog/racket/page/2"))
		'((:name . "racket") (:page . "2")))

	
	(define user-route2 (route-compile "/blog/:name/page/:page" ':page #px"\\d+"))

	(check-equal? 
		(route-match user-route2 (string->url "/blog/racket/page/2"))
		'((:name . "racket") (:page . "2")))

	(check-not-equal? 
		(route-match user-route2 (string->url "/blog/racket/page/qwe"))
		'((:name . "racket") (:page . "qwe"))))

	