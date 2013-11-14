TARGET = yaamake
PREFIX = $(if $(DESTDIR),$(DESTDIR)/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
PREFIX_INT = $(if $(DESTDIR),/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/$(TARGET)
LIBDIR_INT = $(PREFIX_INT)/lib/$(TARGET)
VERSION := $(shell cat VERSION)
TEENSY := vendor/teensy/teensy_loader_cli/teensy_loader_cli

.DEFAULT_GOAL := build


$(TARGET): $(TARGET).template.sh
	sed -e 's#@@LIBDIR@@#$(shell pwd)#g' $< > $@
	chmod +x $@

$(TARGET)_install: $(TARGET).template.sh
	sed -e 's#@@LIBDIR@@#$(LIBDIR_INT)#g' $< > $@
	chmod +x $@

ifeq ($(NO_TEENSY),)
$(TEENSY): $(TEENSY).c
	@if test ! -e /usr/include/usb.h; then echo "WARNING: no /usr/include/usb.h, you propably need libusb-dev for next thing to work"; fi
	@echo "Executing makefile for $(notdir $(TEENSY))"
	cd $(dir $(TEENSY)); make OS=LINUX

.PHONY: TEENSY_install
TEENSY_install: $(TEENSY)
	install -Dd $(LIBDIR)/$(dir $(TEENSY))
	cp -r $(dir $(TEENSY)) $(LIBDIR)/$(dir $(TEENSY))
	chmod +x $(LIBDIR)/$(TEENSY)

.PHONY: TEENSY_clean
TEENSY_clean:
	cd $(dir $(TEENSY)); make clean

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

.PHONY: install_lib
install_lib:
	# Install library components
	install -D -d $(LIBDIR)/$(VERSION)/makefile.d
	install -T makefile.ext $(LIBDIR)/$(VERSION)/makefile.ext
	install -D -t $(LIBDIR)/$(VERSION)/makefile.d $(shell find makefile.d -iname '*.mk')

.PHONY: install_bin
install_bin: $(TARGET)_install
	# Install binary components
	install -D $(TARGET)_install $(BINDIR)/$(TARGET)

.PHONY: install
install: install_lib install_bin

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
