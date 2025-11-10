# An Architect’s Guide to Databricks
## Designing Secure, Scalable, and Governed Lakehouse Platforms

This repository contains the source files for the *Databricks Well-Architected Book*. The book is written in Markdown and can be built into PDF, HTML, or ePub formats.

## Prerequisites

To build the book, you need **Pandoc** installed on your system.

### Install Pandoc

```bash
brew install pandoc
```

## Build the Book

All build commands assume you are in the root of the repository (same level as ./book).

### Build individual formats

```bash
make pdf
make html
make epub
```

## Notes

- The order of chapters is determined by the alphabetical order of the filenames. Prefix them with numbers (`01-`, `02-`, etc.) to control the sequence.
- The Makefile uses `xelatex` for PDF generation. Make sure it’s installed if you want PDF output.
- You can customize metadata (title, author, date) in the Makefile.