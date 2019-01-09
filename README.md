# racket-route-match
URL route-matching library for Racket 

racket-route-match is a library for matching URL routes. It uses the same routing syntax as used by popular Ruby web frameworks like Ruby on Rails and Sinatra.

## Usage
```racket
(require racket-route-match)
(require net/url) ; optional
(require web-server/servlet) ; optional, for web-servers

(route-match 
  "/blog/:name/page/:page" "/blog/racket/page/2") 
; => '((:name . "racket") (:page . "2"))

(route-match 
  "/blog/:name/page/:page" "https://racket-lang.org/blog/racket/page/2") 
; => '((:name . "racket") (:page . "2"))

(route-match 
  "/blog/:name/page/:page" (string->url "/blog/racket/page/2")) 
; => '((:name . "racket") (:page . "2"))
```
with wildcards
```racket

(route-match 
  "/blog/*/page/:page" "/blog/racket/page/2")
; => '((:page . "2"))

(route-match 
  "/blog/:name/page*/:page" "/blog/racket/page-super/2")
; => '((:name . "racket") (:page . "2"))
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
; => '((:name . "racket") (:page . "2"))

```

 For additional performance, you can choose to pre-compile a route:
```racket
(define user-route (route-compile "/blog/:name/page/:page"))
(route-match user-route "/blog/racket/page/2") ; => '((:name . "racket") (:page . "2"))
```

When compiling a route, you can specify a map of regular expressions to use for different keywords. This allows more specific routing:
```racket
(define user-route (route-compile "/blog/:name/page/:page" ':page #px"\\d+"))
(route-match user-route "/blog/racket/page/2") ; => '((:name . "racket") (:page . "2"))
```

Note that regular expression escape sequences (like \d) need to be double-escaped when placed inline in a string.
