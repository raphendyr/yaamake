TARGET = yaamake
PREFIX = $(if $(DESTDIR),$(DESTDIR)/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
PREFIX_INT = $(if $(DESTDIR),/usr,$(if $(filter root,$(USER)),/usr/local,$(HOME)/.local))
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/$(TARGET)
LIBDIR_INT = $(PREFIX_INT)/lib/$(TARGET)

.DEFAULT_GOAL := $(TARGET)

$(TARGET): $(TARGET).template.sh
	sed -e 's#@@LIBDIR@@#$(shell pwd)#g' $< > $@
	chmod +x $@

$(TARGET)_install: $(TARGET).template.sh
	sed -e 's#@@LIBDIR@@#$(LIBDIR_INT)#g' $< > $@
	chmod +x $@

.PHONY: clean
clean:
	@echo Nothing to do

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
