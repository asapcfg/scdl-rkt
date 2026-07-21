CC := raco
MAIN := main.rkt
EXE := scdl

.PHONY: all build clean check

all: check
	$(CC) exe -o $(EXE) $(MAIN)

check:
	@command -v $(CC) >/dev/null 2>&1 || (echo "no raco/racket" && exit 1)
	@command -v ffmpeg >/dev/null 2>&1 || (echo "no ffmpeg" && exit 1)

build: check
	$(CC) exe -o $(EXE) $(MAIN)

clean:
	rm -f $(EXE)

