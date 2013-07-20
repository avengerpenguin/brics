define APACHE_POSTINST
#!/bin/sh

set -e

. /usr/share/debconf/confmodule

create_apache_config() {
	echo '<VirtualHost *:80>' >/etc/apache2/sites-available/${APP_NAME}

	db_get ${APP_NAME}/hostname && hostname="$$RET"
	ret=$$(echo $$RET | tr 'A-Z' 'a-z')

	if [ "$$ret" != "none" ] && [ -n "$$ret" ] ; then
		echo "  ServerName $$ret" >>/etc/apache2/sites-available/${APP_NAME}
	else
		echo "  Alias /${APP_NAME} /var/www/${APP_NAME}" >>/etc/apache2/sites-available/${APP_NAME}
    fi

    cat >>/etc/apache2/sites-available/${APP_NAME} << @@EOF@@
  DocumentRoot /var/www/${APP_NAME}

  ErrorLog /var/log/apache2/aptable.error.log
  CustomLog /var/log/apache2/aptable.access.log combined

  LogLevel warn

  ServerSignature Off

</VirtualHost>
@@EOF@@

}

case "$$1" in
  configure)
	create_apache_config
    a2ensite ${APP_NAME}
    /etc/init.d/apache2 reload
  ;;
  esac
endef
export APACHE_POSTINST

define APACHE_POSTRM
#!/bin/sh

set -e

case "$$1" in
  remove|purge)
    a2dissite ${APP_NAME}
    /etc/init.d/apache2 reload
  ;;
  esac
endef
export APACHE_POSTRM

define APACHE_DEBCONF
Template: ${APP_NAME}/hostname
Type: string
Default: none
Description: Vhost name for Apache
	Please enter the hostname to use for your APT repo.
	This will be use as the Vhost ServerName in Apache.
	You may leave this as "none" and an alias /${APP_NAME}
	will be created instead.

endef
export APACHE_DEBCONF

ifeq ($(PACKAGING),deb)
prepare-package::
	@test -d src/main/www \
	&& echo "[prepare-package]\t\tPackaging is deb and src/main/www exists -- putting Apache post{inst,rm} scripts in DEBIAN." \
	&& mkdir -p target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN \
	&& echo "$$APACHE_POSTINST" >target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/postinst \
	&& echo "$$APACHE_POSTRM" >target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/postrm \
	&& echo "$$APACHE_DEBCONF" >>target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/templates \
	&& echo "db_input high ${APP_NAME}/hostname || true\ndb_go" \
		>>target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/config \
	&& chmod 755 \
		target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/postinst \
		target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/postrm \
	|| true
endif
