APP_NAME = brics
VERSION ?= 0.0.1
PACKAGING ?= deb

BRICS_PATH ?= /usr/share/brics/
include $(BRICS_PATH)/*.mk
