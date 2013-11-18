# Board defaults
# ---------------

# Awk csv parsers for boards.list
define boards_get_defines
BEGIN { FPAT = "([^[:space:]]+)|(\"[^\"]+\")" }
NR == 1 {
    f = 0;
    for (i = 1; i <= NF; ++i) {
        if ($$i == col) f = i;
        h[i] = $$i;
    }
    if (f == 0) exit 1;
}
NR > 1 {
    if ($$f == row) {
        for (i = 1; i <= NF; ++i) if (i != f) {
			gsub("\"", "", $$i);
			print h[i] " ?= " $$i;
		}
        exit 0;
    }
}
endef
define boards_get_colpair
BEGIN {
	FPAT = "([^[:space:]]+)|(\"[^\"]+\")";
    f1 = 0; f2 = 0;
	m = 0; n = 1;
}
NR == 1 {
    for (i = 1; i <= NF; ++i)
        if ($$i == col1) f1 = i;
		else if ($$i == col2) f2 = i;
    if (f1 == 0 || f2 == 0) exit 1;
}
NR > 1 && /^\s*[^#]/ {
	gsub("\"", "", $$f1); gsub("\"", "", $$f2);
	len = length($$f1); if (len > m) m = len;
	c1[n] = $$f1; c2[n] = $$f2;
	++n;
}
END {
	for (i = 1; i < n; ++i)
		printf "  %-" m "s - %s\n", c1[i], c2[i];
}
endef
define newline


endef

# Execute awk command with above code and evaluate parameters into makefile variables
# Notice that $(shell) doesn't return newlines, so those are escaped to #-chars and back
$(eval $(subst #,$(newline),$(shell awk -v col=BOARD -v 'row=$(BOARD)' -- '$(boards_get_defines)' '$(YAAMAKE)/makefile.d/boards.list' | tr '\n' '#')))


# Add macro ARDUINO_<arduino_board> if it is defined
DEFS += $(if $(ARDUINO_BOARD),-DARDUINO_$(ARDUINO_BOARD),)


.PHONY: info
info:
	@echo "BOARD: $(BOARD)"
	@echo "BOARD_NAME: $(BOARD_NAME)"
	@echo "MCU: $(MCU)"
	@echo "F_CLOCK: $(F_CLOCK)"
	@echo "F_CPU: $(F_CPU)"


.PHONY: boards_list
boards_list:
	@echo "To use board, add 'BOARD = board_name' in Makefile"
	@echo
	@echo "all known boards:"
	@awk -v col1=BOARD -v col2=BOARD_NAME -- '$(subst $(newline),,$(boards_get_colpair))' '$(YAAMAKE)/makefile.d/boards.list'
