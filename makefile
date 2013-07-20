APP_NAME = brics
VERSION ?= 0.2.0
PACKAGING ?= deb
DESCRIPTION = "Building blocks for a standardised Make build system."

BRICS_PATH ?= src/main/files/usr/share/brics
include $(BRICS_PATH)/main.mk

