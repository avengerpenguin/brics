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

ifeq ($(PACKAGING),deb)
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
		&& echo "----\n$$control_file\n----" \
		&& echo "$$control_file" >target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/control

dpkg_cmd=dpkg-deb --build $(APP_NAME)-$(VERSION)
package::
	@echo "[package]\t\tRunning: ${dpkg_cmd}" \
		&& cd target/$(PACKAGING) \
		&& ${dpkg_cmd}
endif
