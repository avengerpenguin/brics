APP_NAME = brics
VERSION ?= 0.1.1
PACKAGING ?= deb
DESCRIPTION = "Building blocks for a standardised Make build system."

BRICS_PATH ?= src/main/files/usr/share/brics
include $(BRICS_PATH)/main.mk

