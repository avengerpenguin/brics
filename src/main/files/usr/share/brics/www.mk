compile::
	test -d src/main/www && rsync -a --delete --exclude *.pyc src/main/www/* target/classes || true
