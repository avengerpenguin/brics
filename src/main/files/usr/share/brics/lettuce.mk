# Override this to test any additional Django apps with features therein
# Defaults to looking for an app with the same name as the overall project
HARVEST_APPS ?= $(APP_NAME)

DJANGO_TEST_DB ?= /tmp/$(APP_NAME).db

harvest:
	@echo "[integration-test]: Purging old ${DJANGO_TEST_DB} just in case..." \
	&& rm -f ${DJANGO_TEST_DB} \
	cd src/main/www \
	&& echo "[integration-test] Running syncdb using settings.harvest..." \
	&& python manage.py syncdb --noinput --settings=$(APP_NAME).settings.harvest \
	&& echo "[integration-test] Loading fixtures..."
	&& python manage.py loaddata doyoulikeit/fixtures/harvest/initial_data.json \
	  --settings=$(APP_NAME).settings.harvest \
	&& echo "[integration-test] Running harvest..."
	&& python manage.py harvest $(HARVEST_APPS) --settings=$(APP_NAME).settings.harvest
