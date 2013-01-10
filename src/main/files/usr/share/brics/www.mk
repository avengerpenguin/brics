validate::
	$(call dircheck,src/main/www,a web project)

compile::
	@test -d src/main/www \
	&& echo "[compile]\t\tCopying src/main/www to target/classes for testing/verification before packaging." \
	&& rsync -a --delete --exclude *.pyc src/main/www/* target/classes \
	|| true

prepare-package::
	@test -d src/main/www \
	&& echo "[prepare-package]\t\tCopying src/main/www to packaging dir." \
	&& mkdir -p target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/var/www \
	&& rsync -a --delete --exclude *.pyc src/main/www/* target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/var/www/ \
	|| true
