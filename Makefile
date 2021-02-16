
REMOTE=origin

SOURCE=src/Main.elm
SCRIPT=flashback.js
TARGET=build/${SCRIPT}
DEPLOY=scripts/${SCRIPT}
LOCALIZE=./localize.sh


BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

.PHONY: update build pull push clean realclean

all: build

update:
	elm-package install

build:
	elm-make ${SOURCE} --output ${TARGET}
	mkdir -p scripts
	$(LOCALIZE) ${TARGET} ${DEPLOY}

pull:
	git fetch ${REMOTE}
	git merge ${REMOTE}/${BRANCH}

push:
	git push ${REMOTE} ${BRANCH}

clean:
	rm -rf build
	rm -rf elm-stuff/build-artifacts

realclean:
	rm -rf elm-stuff/

