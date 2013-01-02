pre-clean::
clean:: pre-clean
	rm -rf target
post-clean:: clean

validate::
initialize:: validate
	mkdir -p target/classes
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
