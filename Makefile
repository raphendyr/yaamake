TARGET = yaamake
PREFIX = $(if $(DESTDIR),$(DESTDIR)/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
PREFIX_INT = $(if $(DESTDIR),/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/$(TARGET)
LIBDIR_INT = $(PREFIX_INT)/lib/$(TARGET)
VERSION := $(shell cat VERSION)
RELEASE := $(shell git describe --match 'v*')
TEENSY := vendor/teensy/teensy_loader_cli/teensy_loader_cli

.DEFAULT_GOAL := build


TARGET_SEDS += -e 's/@@RELEASE@@/$(RELEASE)/g'

$(TARGET): $(TARGET).template.sh
	sed -e 's#@@LIBDIR@@#$(shell pwd)#g' $(TARGET_SEDS) $< > $@
	chmod +x $@

$(TARGET)_install: $(TARGET).template.sh
	sed -e 's#@@LIBDIR@@#$(LIBDIR_INT)#g' $(TARGET_SEDS) $< > $@
	chmod +x $@

ifeq ($(NO_TEENSY),)
$(TEENSY): $(TEENSY).c
	$(if $(wildcard /usr/include/usb.h),,$(warning No /usr/include/usb.h, you probably need libusb-dev for the next thing to work))
	@echo "Executing makefile for $(notdir $(TEENSY))"
	cd $(dir $(TEENSY)); $(MAKE) OS=LINUX

.PHONY: TEENSY_install
TEENSY_install: $(TEENSY)
	install -Dd $(LIBDIR)/$(dir $(TEENSY))
	cp -r $(dir $(TEENSY))/* $(LIBDIR)/$(dir $(TEENSY))
	chmod +x $(LIBDIR)/$(TEENSY)

.PHONY: TEENSY_clean
TEENSY_clean:
	cd $(dir $(TEENSY)); $(MAKE) clean

build: $(TEENSY)
install: TEENSY_install
clean: TEENSY_clean
endif

.PHONY: build
build: $(TARGET)

.PHONY: clean
clean:

.PHONY: distclean
distclean:
	-rm -f $(TARGET)
	-rm -f $(TARGET)_install

.PHONY: install
install: $(TARGET)_install
	# Install library components
	install -D -d $(LIBDIR)/$(VERSION)/makefile.d
	install -m 644 -T makefile.ext $(LIBDIR)/$(VERSION)/makefile.ext
	install -m 644 -D -t $(LIBDIR)/$(VERSION)/makefile.d $(shell find makefile.d -iname '*.mk')
	install -m 644 -D -t $(LIBDIR)/$(VERSION)/makefile.d makefile.d/boards.list

	# Install binary components
	install -D $(TARGET)_install $(BINDIR)/$(TARGET)

.PHONY: uninstall
uninstall:
	# Uninstall library components
	-rm -rf "$(LIBDIR)"
	# uninstall inary components
	-rm -f "$(BINDIR)/$(TARGET)"
	@echo "Uninstaled all versions of yaamake under $(PREFIX)"


.PHONY: test
test:
	@for d in tests/*; do \
		echo -n "$${d##*/}: " && ( \
			cd $$d && \
			make >/dev/null 2>&1 && echo ok || echo fail ; \
			make clean >/dev/null 2>&1 || true ; \
		); done
