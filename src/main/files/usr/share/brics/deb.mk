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
	@echo "[install]\t\tInstalling $(APP_NAME)-$(VERSION).deb into /usr/local/brics/repo/deb..." \
		&& sudo mkdir -p /usr/local/brics/repo/deb \
		&& sudo cp target/deb/$(APP_NAME)-$(VERSION).deb /usr/local/brics/repo/deb/ \
		&& cd /usr/local/brics/repo \
		&& sudo dpkg-scanpackages deb /dev/null \
			| gzip \
			| sudo tee deb/Packages.gz >/dev/null \
		&& echo "[install]\t\tRunning aptitude to install ${APP_NAME} to latest version..." \
		&& sudo aptitude --quiet=2 update \
		&& sudo aptitude -y -q reinstall $(APP_NAME) --allow-untrusted


ifdef DEB_DEPENDS
initialise::
	@echo "[initialise]:\t\tInstalling deb dependencies: ${DEB_DEPENDS}" \
	&& sudo aptitude --quiet=2 update \
	&& sudo aptitude -y -q install ${DEB_DEPENDS}

comma:= ,
empty:=
space:= $(empty) $(empty)

DEBIAN_DEPS := $(subst $(space),$(comma),$(DEB_DEPENDS))

prepare-package::
	@echo "[prepare-package]:\tAdding Depends: ${DEBIAN_DEPS}" \
	&& echo "Depends: ${DEBIAN_DEPS}" >>target/$(PACKAGING)/$(APP_NAME)-$(VERSION)/DEBIAN/control
else
validate::
	@echo "[validate]:\t\tNot installing any dependencies as DEB_DEPENDS is not set."
endif

ifdef APT_REPO_PATH
deploy::
	@echo "[deploy]:\t\tCopying $(APP_NAME)-$(VERSION).deb to location given in APT_REPO_PATH" \
	&& scp target/deb/$(APP_NAME)-$(VERSION).deb ${APT_REPO_PATH}
else
deploy::
	@echo "[deploy]:\t\tNot deploying deb package as APT_REPO_PATH is not set."
endif

# End of "if PACKAGING is deb"
endif
