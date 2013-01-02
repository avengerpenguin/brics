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
