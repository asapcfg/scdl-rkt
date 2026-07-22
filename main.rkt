#lang racket

(require racket/cmdline
	 "core.rkt")

(define output-path (make-parameter #f))
(define song-url
  (command-line
    #:program "scdl"
    #:once-each
    [("-o" "--output") path
		       "output file path (default: ./song.mp3)"
		       (output-path path)]
    [("-v" "--version")
	"show version of sdcl"
     	(displayln "sdcl-rkt/1.1.0 by asapcfg")
	(exit 0)]
    #:args (url)
    url))
(download-song song-url (output-path))
