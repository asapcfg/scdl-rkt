CC := raco
MAIN := main.rkt
OUTPUT := scdl
INSTALL_OUTPUT := /usr/local/bin
DESKTOP_OUTPUT := /usr/local/applications


.PHONY: all build clean check

all: check
	$(CC) exe -o $(OUTPUT) $(MAIN)

check:
	@command -v $(CC) >/dev/null 2>&1 || (echo "no raco/racket" && exit 1)
	@command -v ffmpeg >/dev/null 2>&1 || (echo "no ffmpeg" && exit 1)

build: check
	$(CC) exe -o $(OUTPUT) $(MAIN)

clean:
	rm -f $(OUTPUT)

install:
	cp $(OUTPUT) $(INSTALL_OUTPUT)/

desktop:
	cp etc/scdl.desktop $(DESKTOP_OUTPUT)/

