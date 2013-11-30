#   Stage 1: Variables
ifeq ($(yaamake_stage),1)
# =======================


define newline


endef

# Board defaults
# ---------------

# Execute python script and evaluate parameters into makefile variables
# Notice that $(shell) doesn't return newlines, so those are escaped to #-chars and back
$(eval $(subst #,$(newline),$(shell '$(YAAMAKE)/lib/boards_defines.py' BOARD '$(BOARD)' '$(YAAMAKE)/makefile.d/boards.list' | tr '\n' '#')))


# Add macro ARDUINO_<arduino_board> if it is defined
DEFS += $(if $(ARDUINO_BOARD),-DARDUINO_$(ARDUINO_BOARD),)



#   Stage 2: targets
else ifeq ($(yaamake_stage),2)
# ============================


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
	@'$(YAAMAKE)/lib/boards_list.py' BOARD BOARD_NAME '$(YAAMAKE)/makefile.d/boards.list'


# Stages end
endif
