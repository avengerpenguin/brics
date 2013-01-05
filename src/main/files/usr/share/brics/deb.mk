# There's little point including anything from here unless deb packaging is in effect
ifeq ($(PACKAGING),deb)

PKG_DIR ?= target/$(PACKAGING)/$(APP_NAME)-$(VERSION)

define control_file
Package: ${APP_NAME}
Version: ${VERSION}
Section: misc
Priority: optional
Architecture: all
Maintainer: Unknown <unknown@example.com>
endef
export control_file

prepare-package:: 
	@echo "[prepare-package]\tCreating packaging dir: ${PKG_DIR}" \
		&& mkdir -p ${PKG_DIR}

	@test -d src/main/files \
		&& echo "[prepare-package]\tCopying files from src/main/files to ${PKG_DIR}..." \
		&& mkdir -p target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN \
		&& rsync -a --delete --exclude *.pyc --exclude .svn \
			src/main/files/* target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/ \
		|| true

	@echo "[prepare-package]\tCreating control file in DEBIAN with project settings:" \
		&& echo "\n------------------------\n$$control_file\n------------------------\n" \
		&& echo "$$control_file" >target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/control

dpkg_cmd=dpkg-deb --build $(APP_NAME)-$(VERSION)
package::
	@echo "[package]\t\tRunning: ${dpkg_cmd}" \
		&& cd target/$(PACKAGING) \
		&& ${dpkg_cmd}

install::
	@echo "[install]\t\t\tInstalling $(APP_NAME)-$(VERSION).deb into /usr/local/brics/repo/deb..." \
		&& sudo mkdir -p /usr/local/brics/repo/deb \
		&& sudo cp target/deb/$(APP_NAME)-$(VERSION).deb /usr/local/brics/repo/deb/ \
		&& sudo dpkg-scanpackages /usr/local/brics/repo/deb/ /dev/null \
			| gzip \
			| sudo tee /usr/local/brics/repo/deb/Packages.gz >/dev/null

endif
