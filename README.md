# scdl-rkt
<img width="500" height="280" alt="image" src="https://github.com/user-attachments/assets/0d4d0009-310a-48c4-99aa-7d482596053a" />

*scdl (soundcloud downloader)* - an alternative to the python slop in GitHub, written in Lisp (the Racket dialect).

## usage

`scdl <URL>`

## dependencies

```
racket (only to compile)
ffmpeg (required)
```

## how to build

```sh
make # compiles the scdl-rkt as 'scdl'. can be changed by passing OUTPUT=
make install # moves binary to /usr/local/bin.
make desktop # creates /usr/share/applications/scdl.desktop. (recommended, but not required)
```
