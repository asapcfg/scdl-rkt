#lang racket

(require net/url
	 net/uri-codec
	 json
	 racket/port
	 racket/system
	 racket/format)

(provide download-song)

(define uagent "User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/132.0.0.0")
(define (http-get-string url-string)
  (define u (string->url url-string))
  (define in (get-pure-port u (list uagent) #:redirections 5))
  (define text (port->string in))
  (close-input-port in)
  text)

(define (http-get-bytes url-string)
  (define u (string->url url-string))
  (define in (get-pure-port u (list uagent) #:redirections 5))
  (define data (port->bytes in))
  (close-input-port in)
  data)

(define (fci) ;; fci - find client ID. (c) asapcfg
  (define html (http-get-string "https://soundcloud.com"))
  (define fci-su ;; fci-su - fci script urls
    (regexp-match* #px"https://a-v2\\.sndcdn\\.com/assets/[^\"]+\\.js" html))
  (when (null? fci-su)
    (error 'fci "no js found :("))
  (let loop ([urls fci-su])
    (cond
      [(null? urls)
       (error 'fci "got js, no client_id")]
      [else
	(define js-text (http-get-string (car urls)))
	(define m (regexp-match #px"client_id:\"([a-zA-Z0-9]{32})\"" js-text))
	(if m
	  (cadr m)
	  (loop (cdr urls)))])))
(define (resolver song-url client-id)
  (define api-url
    (string-append
      "https://api-v2.soundcloud.com/resolve?url="
      (uri-encode song-url)
      "&client_id=" client-id))
  (string->jsexpr (http-get-string api-url)))
(define (getaux song-json)
  (define media (hash-ref song-json 'media))
  (hash-ref media 'transcodings))
(define (tc transcodings)
  (hash-ref (hash-ref transcodings 'format) 'protocol))
(define (final transcodings)
  (or (findf (lambda (t) (string=? (tc t) "progressive")) transcodings)
  (findf (lambda (t) (string=? (tc t) "hls")) transcodings)
  (error 'final "no hls/progressive transcodings :(")))

; 1.1.0 title support
(define (mimeo transcodings)
  (hash-ref (hash-ref transcodings 'format) 'mime-type ""))
(define (mimext mime)
  (cond
    [(regexp-match? #px"mp4" mime) "m4a"]
    [(regexp-match? #px"mpeg" mime) "mp3"]
    [(regexp-match? #px"ogg" mime) "ogg"]
    [else "mp3"]))
(define (sanitar name)
  (string-trim (regexp-replace* #px"[/\\\\:*?\"<>|]" name "_")))
(define (defname title mime)
  (string-append (sanitar title) "." (mimext mime)))

(define (gsu transcoding client-id) ; gsu - get stream url (c) asapcfg
  (define meta-url (hash-ref transcoding 'url))
  (define full-url (string-append meta-url "?client_id=" client-id))
  (define response (string->jsexpr (http-get-string full-url)))
  (hash-ref response 'url))

(define (dl-progressive stream-url out-path)
  (define data (http-get-bytes stream-url))
  (call-with-output-file out-path
			 (lambda (out-port) (write-bytes data out-port))
			 #:exists 'replace))
(define (dl-hls m3u8 out-path)
  (define ffmpeg-path (find-executable-path "ffmpeg"))
  (unless ffmpeg-path
    (error 'dl-hls "ffmpeg not found"))
  (define ok? (system* ffmpeg-path
    "-y"
    "-i" m3u8
    "-c" "copy"
    out-path))
  (unless ok?
    (error 'dl-hls "ffmpeg eror")))

(define (download-song song-url out-path)
	(printf "starting fci...\n")
	(define client-id (fci))

	(printf "searching song...\n")
	(define song-json (resolver song-url client-id))
	(define title (hash-ref song-json 'title "(no name)"))
	(printf "song: ~a\n" title)
	
	(define transcoding (final (getaux song-json)))
	(define protocol (tc transcoding))
	(printf "trancoding: ~a\n" protocol)
	(define  out-path (defname title (mimeo transcoding)))
	
	(define stream-url (gsu transcoding client-id))
	(cond
	  [(string=? protocol "progressive")
	   (printf "using progressive transcoding...\n")
	   (dl-progressive stream-url out-path)]
	  [else
	    (printf "using ffmpeg...\n")
	    (dl-hls stream-url out-path)])

	(printf "song is ~a\n" out-path))
