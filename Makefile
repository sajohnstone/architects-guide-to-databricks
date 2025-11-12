# Makefile for building the Databricks Well-Architected Book

# Book metadata
TITLE := An Architects Guide to Databricks
AUTHOR := Stu Johnstone
DATE := $(shell date +%Y-%m-%d)

# Source files (all markdown in ./book)
SOURCES := $(wildcard ./book/*.md)

# Output directory
OUTDIR := ./output
PDF := $(OUTDIR)/$(shell echo $(TITLE) | sed "s/[^a-zA-Z0-9]/_/g").pdf
HTML := $(OUTDIR)/$(shell echo $(TITLE) | sed "s/[^a-zA-Z0-9]/_/g").html
EPUB := $(OUTDIR)/$(shell echo $(TITLE) | sed "s/[^a-zA-Z0-9]/_/g").epub

# PDF engine
PDF_ENGINE := xelatex

.PHONY: all pdf html epub clean

all: pdf html epub

pdf: $(PDF)

$(PDF): $(SOURCES)
	pandoc $^ -o $@ --toc --metadata title="$(TITLE)" --metadata author="$(AUTHOR)" --metadata date="$(DATE)" --pdf-engine=$(PDF_ENGINE)

html: $(HTML)

$(HTML): $(SOURCES)
	pandoc $^ -o $@ --toc --metadata title="$(TITLE)" --metadata author="$(AUTHOR)" --metadata date="$(DATE)"

epub: $(EPUB)

$(EPUB): $(SOURCES)
	pandoc $^ -o $@ --toc --metadata title="$(TITLE)" --metadata author="$(AUTHOR)" --metadata date="$(DATE)" --epub-cover-image=./images/cover.png

clean:
	rm -f $(PDF) $(HTML) $(EPUB)