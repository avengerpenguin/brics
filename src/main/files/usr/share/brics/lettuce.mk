harvest:
	rm -f /tmp/$(APP_NAME).db
	cd src/main/www ; \
	python manage.py syncdb --noinput --settings=$(APP_NAME).settings.harvest ; \
	python manage.py loaddata doyoulikeit/fixtures/harvest/initial_data.json \
	  --settings=$(APP_NAME).settings.harvest ; \
	python manage.py harvest $(HARVEST_APPS) --settings=$(APP_NAME).settings.test
