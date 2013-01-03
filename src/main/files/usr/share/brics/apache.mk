define APACHE_POSTINST
#!/bin/sh

set -e

case "$$1" in
  configure)
    a2ensite $(APP_NAME)
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
    a2dissite $(APP_NAME)
    /etc/init.d/apache2 reload
  ;;
  esac
endef
export APACHE_POSTRM

prepare-package::
ifeq ($(PACKAGING),deb)
	@test -d src/main/www \
	&& echo "[prepare-package] Packaging is deb and src/main/www exists -- putting Apache post{inst,rm} scripts in DEBIAN." \
	&& mkdir -p target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN \
	&& echo "$$APACHE_POSTINST" >target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/postinst \
	&& echo "$$APACHE_POSTRM" >target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/postrm \
	|| true
endif
