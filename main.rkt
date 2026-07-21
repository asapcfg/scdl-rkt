#lang racket

(require racket/cmdline
	 "core.rkt")

(define output-path (make-parameter "song.mp3"))
(define song-url
  (command-line
    #:program "scdl"
    #:once-each
    [("-o" "--output") path
		       "output file path (default: ./song.mp3)"
		       (output-path path)]
    [("-v" "--version")
     	(displayln "sdcl-rkt/1.0.0 by asapcfg")]
    #:args (url)
    url))
(download-song song-url (output-path))
