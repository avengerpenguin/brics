ifeq ($(wildcard src/main/www/manage.py),) 

else

define DJANGO_INIT_SCRIPT
#! /bin/sh
### BEGIN INIT INFO
# Provides:          FastCGI servers for Django
# Required-Start:    networking
# Required-Stop:     networking
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Django FastCGI
#

DJANGO_SITE="${APP_NAME}"
SITE_PATH=/var/www/${APP_NAME}
RUNFILES_PATH=$$SITE_PATH/tmp
HOST=127.0.0.1
PORT_START=3001
RUN_AS=www-data

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Django FastCGI"
NAME=$$0
SCRIPTNAME=/etc/init.d/$$NAME

#
#       Function that starts the daemon/service.
#
d_start()
{
    # Starting all Django FastCGI processes
    echo -n ", $$DJANGO_SITE"
    if [ -f $$RUNFILES_PATH/$$DJANGO_SITE.pid ]; then
        echo -n " already running"
    else
       start-stop-daemon --start --quiet \
                       --pidfile $$RUNFILES_PATH/$$DJANGO_SITE.pid \
                       --chuid $$RUN_AS --exec /usr/bin/env -- python \
                       $$SITE_PATH/$$DJANGO_SITE/manage.py runfcgi \
                       host=$$HOST port=$$PORT \
                       pidfile=$$RUNFILES_PATH/$$DJANGO_SITE.pid
    fi
}

#
#       Function that stops the daemon/service.
#
d_stop() {
    # Killing all Django FastCGI processes running
    echo -n ", $DJANGO_SITE"
    start-stop-daemon --stop --quiet --pidfile $$RUNFILES_PATH/$$SITE.pid \
                          || echo -n " not running"
    if [ -f $$RUNFILES_PATH/$$DJANGO_SITE.pid ]; then
        rm $$RUNFILES_PATH/$$DJANGO_SITE.pid
    fi
}

ACTION="$$1"
case "$$ACTION" in
    start)
        echo -n "Starting $$DESC: $$NAME"
        d_start
        echo "."
        ;;

    stop)
        echo -n "Stopping $$DESC: $$NAME"
        d_stop
        echo "."
        ;;

    restart|force-reload)
        echo -n "Restarting $$DESC: $$NAME"
        d_stop
        sleep 1
        d_start
        echo "."
        ;;

    *)
        echo "Usage: $$NAME {start|stop|restart|force-reload}" >&2
        exit 3
        ;;
esac

exit 0
endef
export DJANGO_INIT_SCRIPT

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

prepare-package::
	@echo "[prepare-package]\tCreating init script:" \
	&& echo "$$DJANGO_INIT_SCRIPT" | tee target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/etc/init.d/${APP_NAME}


endif
