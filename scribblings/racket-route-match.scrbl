#lang scribble/manual
@require[@for-label[racket-route-match
                    racket/base]]

@title{racket-route-match}
@author{junker}

@defmodule[racket-route-match]

URL route-matching library for Racket 

Example of usage:

@racketblock[
(require racket-route-match)
(require net/url) ; optional
(require web-server/servlet) ; optional, for web-servers

(route-match 
  "/blog/:name/page/:page" "/blog/racket/page/2") 
; => '((name . "racket") (page . "2"))

(route-match 
  "/blog/:name/page/:page" "https://racket-lang.org/blog/racket/page/2") 
; => '((name . "racket") (page . "2"))

(route-match 
  "/blog/:name/page/:page" (string->url "/blog/racket/page/2")) 
; => '((name . "racket") (page . "2"))
```
with wildcards
```racket

(route-match 
  "/blog/*/page/:page" "/blog/racket/page/2")
; => '((page . "2"))

(route-match 
  "/blog/:name/page*/:page" "/blog/racket/page-super/2")
; => '((name . "racket") (page . "2"))

(route-match 
  "/blog/:name/**/:page" "/blog/racket/super/buper/page/2")
; => '((name . "racket") (page . "2"))
```

with request from web-server
```racket
; example request from web-server/servlet
(define req 
  (make-request #"GET" 
    (string->url "/blog/racket/page/2") 
     empty (delay empty) #f "1.2.3.4" 80 "4.3.2.1"))) 

(route-match 
  "/blog/:name/page/:page" (request-uri req)) 
; => '((name . "racket") (page . "2"))


; For additional performance, you can choose to pre-compile a route:
(define user-route (route-compile "/blog/:name/page/:page"))
(route-match user-route "/blog/racket/page/2") 
; => '((name . "racket") (page . "2"))

; When compiling a route, you can specify a map of regular expressions to use for different keywords. This allows more specific routing:
(define user-route (route-compile "/blog/:name/page/:page" 'page #px"\\d+"))
(route-match user-route "/blog/racket/page/2") ; => '((name . "racket") (page . "2"))
]

@table-of-contents[]

@section{route-match}

Matches route with URL

@racketblock[
 (define (route-match route request)
]

route - string with params (eg. "/blog/:name/page/:page" )
request - url for compare (eg. "/blog/racket/page/2")

@section{route-compile}

Compiles route for additional performance

@racketblock[
 (define (route-compile route . constraints)
]

route - string with params (eg. "/blog/:name/page/:page" )
constraints - condition regexp for params (eg. 'page #px"\\d+") 