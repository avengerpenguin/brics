# Some defaults that might not have been set by local makefile
APP_NAME ?= "APP_NAME"
VERSION ?= "0.0.0"
#PACKAGING ?= deb

define dircheck
	@test -d $1 \
	&& echo "[validate]\t\tFound $1; assuming this is $2." \
	|| echo "[validate]\t\tCannot find $1; assuming this is not $2."
endef

pre-clean::
clean:: pre-clean
	@echo "[clean]\t\t\tRemoving target dir..." && rm -rf target
post-clean:: clean

validate::
initialize:: validate
	@echo "[initialize]\t\tCreating target/classes for processed and compiled sources." && mkdir -p target/classes
generate-sources:: initialize
process-sources:: generate-sources
generate-resources:: process-sources
process-resources:: generate-resources
compile:: process-resources
process-classes:: compile
generate-test-sources:: process-classes
process-test-sources:: generate-test-sources
generate-test-resources:: process-test-sources
process-test-resources:: generate-test-resources
test-compile:: process-test-resources
process-test-classes:: test-compile
test:: process-test-classes
prepare-package:: test
package:: prepare-package
pre-integration-test:: package
integration-test:: pre-integration-test harvest
post-integration-test:: integration-test
verify:: post-integration-test
install:: verify
deploy:: install

pre-site::
site:: pre-site
post-site:: site
site-deploy:: post-site
