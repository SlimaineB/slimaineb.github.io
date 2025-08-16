install:
	bundle install

serve:
	bundle exec jekyll serve

clean:
	bundle exec jekyll clean

commit:
	git add .
	git commit -m "Update documentation" || true
	git push 