NAME    = ximera
SHELL   = bash
PWD     = $(shell pwd)
VERS    = $(shell ltxfileinfo -v $(NAME).dtx|sed -e 's/^v//')
LOCAL   = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE   = $(shell kpsewhich --var-value TEXMFHOME)
INPUTS  = $(wildcard src/*.dtx) $(wildcard src/interactives/*.dtx) $(NAME).dtx
OUTPUTS = ximera.cls xourse.cls ximera.4ht xourse.4ht ximera.cfg

# based on
#
#   https://stackoverflow.com/questions/2973445/gnu-makefile-rule-generating-a-few-targets-from-a-single-source-file
#
# I use a silly pattern rule to convince GNU make that multiple
# outputs are created with a single invocation

all:	$(NAME).pdf $(OUTPUTS)
	test -e README.txt && mv README.txt README || exit 0

$(NAME)%pdf ximera%cls xourse%cls ximera%4ht xourse%4ht ximera%cfg: $(INPUTS)
	pdflatex -shell-escape -recorder -interaction=batchmode $(NAME).dtx >/dev/null
	if [ -f $(NAME).glo ]; then makeindex -q -s gglo.ist -o $(NAME).gls $(NAME).glo; fi
	if [ -f $(NAME).idx ]; then makeindex -q -s gind.ist -o $(NAME).ind $(NAME).idx; fi
	pdflatex --recorder --interaction=nonstopmode $(NAME).dtx > /dev/null
	pdflatex --recorder --interaction=nonstopmode $(NAME).dtx > /dev/null

clean:
	rm -f $(NAME).{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out}

distclean: clean
	rm -f ximera.pdf README $(OUTPUTS)

# BADBAD: The code below still needs to be fixed


ctan: all
	mkdir -p ./ctan/ximera/src/interactives/ # create a directory structure
	touch ./ctan/ximera.zip
	rm ./ctan/ximera.zip # remove old zip file
	cp ximera.dtx  ./ctan/ximera/ # copy files 
	cp ximera.pdf ./ctan/ximera/
	cp ximera.ins ./ctan/ximera/
	cp ./src/*.dtx ./ctan/ximera/src # only copy the dtx files!
	cp ./src/interactives/*.dtx ./ctan/ximera/src/interactives/ # only copy the dtx files!
	cp LICENSE ./ctan/ximera/
	cp README ./ctan/ximera/
	zip -r ./ctan/ximera.zip ./ctan/ximera

inst: all
	mkdir -p $(UTREE)/{tex,source,doc}/latexn/$(NAME)
	cp $(NAME).dtx $(UTREE)/source/latex/$(NAME)
	cp $(NAME).cls $(UTREE)/tex/latex/$(NAME)
	cp $(NAME).pdf $(UTREE)/doc/latex/$(NAME)

install: all
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).dtx $(LOCAL)/source/latex/$(NAME)
	sudo cp $(NAME).cls $(LOCAL)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(LOCAL)/doc/latex/$(NAME)

zip: all
	ln -sf . $(NAME)
	zip -Drq $(PWD)/$(NAME)-$(VERS).zip $(NAME)/{README,$(NAME).{pdf,dtx}}
	rm $(NAME)
