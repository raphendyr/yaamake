TARGET = yaamake
PREFIX = $(if $(DESTDIR),$(DESTDIR)/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
PREFIX_INT = $(if $(DESTDIR),/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/$(TARGET)
LIBDIR_INT = $(PREFIX_INT)/lib/$(TARGET)
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

.PHONY: $(TEEENSY)_clean
$(TEENSY)_clean:
	cd $(dir $(TEENSY)); make clean

install: $(TEENSY)
build: $(TEENSY)
clean: $(TEENSY)_clean
else
$(TEENSY):
	$(error No information how to build $(TEENSY))
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
	install -D -d $(LIBDIR)/makefile.d
	install -T makefile.ext $(LIBDIR)/makefile.ext
	install -D -t $(LIBDIR)/makefile.d $(shell find makefile.d -iname '*.mk')
ifeq ($(NO_TEENSY),)
	install -Dd $(LIBDIR)/$(dir $(TEENSY))
	cp -r $(dir $(TEENSY)) $(LIBDIR)/$(dir $(TEENSY))
	chmod +x $(LIBDIR)/$(TEENSY)
endif
	# Install binary components
	install -D $(TARGET)_install $(BINDIR)/$(TARGET)


.PHONY: uninstall
uninstall:
	# Uninstall library components
	-rm -f $(LIBDIR)/makefile.ext
	-rm -rf $(LIBDIR)/makefile.d
	-rmdir $(LIBDIR)
	# uninstall inary components
	-rm -f $(BINDIR)/$(TARGET)


.PHONY: test
test:
	@for d in tests/*; do \
		echo -n "$${d##*/}: " && ( \
			cd $$d && \
			make >/dev/null 2>&1 && echo ok || echo fail ; \
			make clean >/dev/null 2>&1 || true ; \
		); done
