all:
	Rscript -e "library(knitr); knit2html('parallel-basics.Rmd')"

clean:
	rm -f parallel-basics.{md,html}
