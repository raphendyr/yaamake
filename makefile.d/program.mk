# programming help
program_help:
	$(HELP_TITTLE) programming
	$(HELP_DESC) "This section is used to flash your code into your board/mcu"
	$(HELP_ATTRS)
	$(HELP_ATTR) PROGRAMMER "select programming device (arduino,stk500v2,teensy,etc)"
	$(HELP_ATTR) AVRDUDE "Location of avrdude program"
	$(HELP_ATTR) AVRDUDE_PORT "avrdude programmer connection port"
	$(HELP_ATTR) AVRDUDE_FLAGS "Flags for avrdude backend (use +=)"
	$(HELP_ATTR) TEENSY "Location of teensy_loader_cli (one is build if not specified by user)"
	$(HELP_ATTR) TEENSY_FLAGS "Flags for teensy backend (use +=)"
	$(HELP_TARGETS)
	$(HELP_TARGET) program_flash "flash your program (code) into device"
	$(HELP_TARGET) program "alias for program_flash"
	$(HELP_TARGET) program_eeprom "flash eeprom into your device"



ifeq ($(PROGRAMMER),teensy)
#--------- teensy ---------

TEENSY := $(call find_file,vendor/teensy/teensy_loader_cli/teensy_loader_cli)
TEENSY_FLAGS = -v -w -mmcu=$(MCU)

$(TEENSY):
	$(error Yaamake was propably build without teensy support, so get teensy_loader_cli and point TEENSY to it)


program_flash: $(TARGET).hex $(TEENSY)
	$(call require,MCU TARGET)
	$(TEENSY) $(TEENSY_FLAGS) $<



else
#--------- avrdude ---------

AVRDUDE ?= avrdude

AVRDUDE_PORT ?= usb

AVRDUDE_FLAGS = -p $(MCU) -P $(PROGRAMMER_PORT) -c $(PROGRAMMER)

.PHONY: program_flash
program_flash: $(TARGET).hex
	$(call require,AVRDUDE MCU TARGET PROGRAMMER PROGRAMMER_PORT)
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U flash:w:$<

.PHONY: program_eeprom
program_eeprom: $(TARGET).eep
	$(call require,AVRDUDE MCU TARGET PROGRAMMER PROGRAMMER_PORT)
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U eeprom:w:$<



endif

#--------- common ---------
.PHONY: program
program: program_flash
