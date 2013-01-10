ifeq ($(wildcard src/main/www/manage.py),) 

else
 
DJANGO_TEST_DB ?= /tmp/$(APP_NAME).db

test::
	@echo "[test]\t\t\tRunning Django tests..." \
	&& echo "[test]\t\t\tPurging old ${DJANGO_TEST_DB} just in case..." \
	&& rm -f ${DJANGO_TEST_DB} \
	&& cd target/classes \
	&& echo "[test]\t\t\tRunning syncdb using settings.test..." \
	&& python manage.py syncdb --noinput \
		--settings=$(APP_NAME).settings.test \
	&& python manage.py test --settings=${APP_NAME}.settings.test

validate::
	@echo "[validate]\t\tRunning pep8 checks against Django sources..." \
	&& pep8 src/main/www \
	|| echo "[validate]\t\tWARNING: PEP8 errors found."

validate::
	@echo "[validate]\t\tRunning Django lint checks..." \
	&& django-lint src/main/www/${APP_NAME} \
	|| echo "[validate]\t\tWARNING: Django lint errors found."

endif
