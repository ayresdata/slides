CSS=templates/markdown/ayresStyle.css
TPL=templates/markdown/ayresTemplate.html
output_dir=output

all:
	@find 201* -name '*.md' -not -iname '*readme*' | while read slide ; do \
	  output=$(output_dir)/$$( echo $$slide | sed 's/.md$$//gi' ).html; \
	  install -m 775 -d $$( dirname $$output ); \
          [ -d "$$( dirname $$slide )/img" ] && \
	    cp -r "$$( dirname $$slide )/img" $(output_dir)/$$( dirname $$slide ); \
	  markdown-to-slides -s $(CSS) -l $(TPL) $$slide -o $$output; \
	done
