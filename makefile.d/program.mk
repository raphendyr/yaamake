#   Stage: Variables
ifeq ($(yaamake_stage),v)
# =======================

# Teensy
TEENSY := $(call find_file,vendor/teensy/teensy_loader_cli/teensy_loader_cli)
TEENSY_FLAGS = -v -w -mmcu=$(MCU)

# Avrdude
AVRDUDE ?= avrdude
PROGRAMMER_PORT ?= $(PORT)
PROGRAMMER_BAUD ?= $(BAUD)
AVRDUDE_FLAGS = -p $(MCU) \
  $(if $(PROGRAMMER_PORT),-P $(PROGRAMMER_PORT),)\
  $(if $(PROGRAMMER_BAUD),-b $(PROGRAMMER_BAUD),)\
  -c $(PROGRAMMER)



#   Stage: targets
else ifeq ($(yaamake_stage),t)
# ============================


# programming help
program_help:
	$(HELP_TITTLE) programming
	$(HELP_DESC) "This section is used to flash your code into your board/mcu"
	$(HELP_ATTRS)
	$(HELP_ATTR) PROGRAMMER "select programming device (arduino,stk500v2,teensy,etc)"
	$(HELP_ATTR) PROGRAMMER_PORT "avrdude programmer connection port (Default is PORT)"
	$(HELP_ATTR) PROGRAMMER_BAUD "avrdude programmer connection baud (Default is BAUD)"
	$(HELP_ATTR) AVRDUDE "Location of avrdude program"
	$(HELP_ATTR) AVRDUDE_FLAGS "Flags for avrdude backend (use +=)"
	$(HELP_ATTR) TEENSY "Location of teensy_loader_cli (one is build if not specified by user)"
	$(HELP_ATTR) TEENSY_FLAGS "Flags for teensy backend (use +=)"
	$(HELP_TARGETS)
	$(HELP_TARGET) program_flash "flash your program (code) into device"
	$(HELP_TARGET) program "alias for program_flash"
	$(HELP_TARGET) program_eeprom "flash eeprom into your device"



ifeq ($(PROGRAMMER),teensy)
#--------- teensy ---------

$(TEENSY):
	$(error Yaamake was probably built without teensy support, so get teensy_loader_cli and point TEENSY to it)

.PHONY: program_flash
program_flash: $(TARGET).hex $(TEENSY)
	$(call require,MCU TARGET)
	$(TEENSY) $(TEENSY_FLAGS) $<


else
#--------- avrdude ---------

.PHONY: program_flash
program_flash: $(TARGET).hex
	$(call require,AVRDUDE MCU TARGET PROGRAMMER PROGRAMMER_PORT)
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U flash:w:$<

.PHONY: program_eeprom
program_eeprom: $(TARGET).eep
	$(call require,AVRDUDE MCU TARGET PROGRAMMER PROGRAMMER_PORT)
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U eeprom:w:$<


endif

# Alias program -> program_Flash
.PHONY: program
program: program_flash


# Stages end
endif
