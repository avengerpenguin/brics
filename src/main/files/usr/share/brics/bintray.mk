ifneq ($(and $(BINTRAY_USER),$(BINTRAY_KEY),$(BINTRAY_REPO)),)

BINTRAY_API := https://api.bintray.com
BINTRAY_CURL := curl -u${BINTRAY_USER}:${BINTRAY_KEY} -H Content-Type:application/json -H Accept:application/json
BINTRAY_PACKAGE_DATA := "{\"name\":\"$(APP_NAME)\",\"licenses\":[\"GPL-3.0\"]}"

ARTEFACT_FILE := $(APP_NAME)-$(VERSION).$(PACKAGING)
ARTEFACT_PATH := target/$(PACKAGING)/$(ARTEFACT_FILE)

deploy::
	@echo "[deploy]:\t\tChecking if package exists on Bintray..." \
	&& echo test $(shell $(BINTRAY_CURL) --write-out %{http_code} --silent --output /dev/null \
		-X GET $(BINTRAY_API)/packages/$(BINTRAY_USER)/$(BINTRAY_REPO)/$(APP_NAME)) == 200 \
	|| echo "[deploy]:\t\tPackage does not exist; creating..." \
		&& $(BINTRAY_CURL) -X POST -d $(BINTRAY_PACKAGE_DATA) \
			$(BINTRAY_API)/packages/$(BINTRAY_USER)/$(BINTRAY_REPO) && echo

	@echo "[deploy]:\t\tUploading artefact to Bintray..." \
	&& ${BINTRAY_CURL} -T $(ARTEFACT_PATH) -H X-Bintray-Package:${APP_NAME} -H X-Bintray-Version:${VERSION} \
		${BINTRAY_API}/content/${BINTRAY_USER}/${BINTRAY_REPO}/${ARTEFACT_FILE}\;publish=1 \
	&& echo

endif
