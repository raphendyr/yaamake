#   Stage: Variables
ifeq ($(yaamake_stage),v)
# =======================

# yaamake's serial communicator
COMMUNICATOR ?= $(if $(wildcard $(YAAMAKE)/utils/serialconsole),$(YAAMAKE)/utils/serialconsole,yaamake-serialconsole)
COMMUNICATOR_PORT ?= $(PORT)
COMMUNICATOR_BAUD ?= $(BAUD)
COMMUNICATOR_MODE ?= 8n1
COMMUNICATOR_FLAGS ?= $(if $(COLORS),--colors) --enquiry --no-escapes



#   Stage: targets
else ifeq ($(yaamake_stage),t)
# ============================


# communicator help
communicating_help:
	$(HELP_TITTLE) communicating
	$(HELP_DESC) "This section is used to communicate with your device"
	$(HELP_ATTRS)
	$(HELP_ATTR) COMMUNICATOR "Serial console program (default is yaamake-serialconsole)"
	$(HELP_ATTR) COMMUNICATOR_PORT "Serial port used in communication (Default is PORT)"
	$(HELP_ATTR) COMMUNICATOR_BAUD "Serial port baudrate (speed) (Default is BAUD)"
	$(HELP_ATTR) COMMUNICATOR_MODE "Serial port mode (Default is 8n1 (8 data bits, no parity, 1 stop bit))"
	$(HELP_ATTR) COMMUNICATOR_FLAGS "Extra flags given to communicator (default is --enquiry --no-escapes and --colors if COLORS)"
	$(HELP_TARGETS)
	$(HELP_TARGET) communicate "open serial connection to your device"
	$(HELP_TARGET) connect "alias for communicate"
	$(HELP_TARGET) listen "read data from your device"


# communicate
.PHONY: communicate
communicate:
	$(COMMUNICATOR) $(COMMUNICATOR_FLAGS) $(COMMUNICATOR_PORT) $(COMMUNICATOR_BAUD) $(if $(COMMUNICATOR_MODE),--mode=$(COMMUNICATOR_MODE),)

# Alias connect -> communicate
.PHONY: connect
connect: communicate

# Read only communication
.PHONY: listen
listen:
	$(COMMUNICATOR) --readonly $(COMMUNICATOR_FLAGS) $(COMMUNICATOR_PORT) $(COMMUNICATOR_BAUD) $(if $(COMMUNICATOR_MODE),--mode=$(COMMUNICATOR_MODE),)



# Stages end
endif
