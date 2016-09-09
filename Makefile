MAIN = flock

all: make-pdf latex-move-pdf make-code
all-clean: make-pdf latex-move-pdf make-code build-clean

make-image: build-prepare image-make
make-pdf: build-prepare image-make markdown latex
make-code: code-prepare code-make


# build preparation and cleanup
build-prepare:
	mkdir -p build
build-clean:
	rm -fR build


# c-code commands
code-make:
	gsl -a -script:gsl/fsm_c.gsl flock_fsm.xml code

code-prepare:
	mkdir -p code


# latex commands - have to run pdflatex twice for references to work
latex: latex-prehook-images latex-make latex-make-toc

latex-make: 
	pdflatex -output-directory=build -aux-directory=build $(MAIN).tex
	
latex-make-toc: 
	pdflatex -output-directory=build -aux-directory=build $(MAIN).tex

latex-prehook-images:
	cp build/*.png .

latex-move-pdf:
	mv build/$(MAIN).pdf .


# markdown commands
markdown: pandoc

pandoc:
	pandoc --from=markdown --output=build/$(MAIN).tex --to=latex \
	       --standalone --highlight-style haddock --variable=geometry:a4paper \
	       --filter pandoc-crossref \
	       --number-sections -M autoSectionLabels:true -M secPrefix:section \
	       --biblio=$(MAIN).bib --csl=acm-sig-proceedings.csl \
	       $(MAIN).md


# image generation
image-make: generate-dotfile generate-image

generate-dotfile:
	gsl -a -script:gsl/fsm_dot.gsl flock_fsm.xml build

generate-image:
	dot -Tpng build/flock_fsm.dot -o build/flock_fsm.png
