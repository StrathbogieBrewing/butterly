TARGET = butterfly
AVR_ARCHI = atmega169
CLK = 1000000L

SRC = $(wildcard *.c *.S *.s *.cpp)
OBJ = $(SRC:=.o)

CC = avr-gcc
CXX = avr-g++
GDB = avr-gdb
FLAGS = -g -std=gnu11 -Os -Wall -ffunction-sections -fdata-sections -mmcu=$(AVR_ARCHI) -DF_CPU=$(CLK) -c
CXXFLAGS = -fno-threadsafe-statics
ASMFLAGS = -x assembler-with-cpp
LFLAGS = -Os -mmcu=$(AVR_ARCHI) -Wl,--gc-sections,--relax -Wl,--start-group -lm -Wl,--end-group
AVR_ARCHI_SIZE_FLAGS = --mcu=$(AVR_ARCHI) -C -d
OBJCPY = avr-objcopy
OBJCPY_FLAGS = -O ihex -R .eeprom

all: $(OBJ)
	$(CC) $^ $(LFLAGS) -o $(TARGET).elf
	$(OBJCPY) $(OBJCPY_FLAGS) $(TARGET).elf $(TARGET).hex

%.s.o  : %.s
	$(CC) $(ASMFLAGS) $(CFLAGS) $^ -o $@

%.S.o  : %.S
	$(CC) $(FLAGS) $^ -o $@

%.cpp.o: %.cpp
	$(CXX) $(FLAGS) $(CXXFLAGS) $^ -o $@

%.c.o  : %.c
	$(CC) $(FLAGS) $^ -o $@

sim: all
	# GDB server will start on port 1234
	simavr -g -m $(AVR_ARCHI) $(TARGET).elf

sim_silent: all
	# GDB server will start on port 1234
	simavr -g -m $(AVR_ARCHI) $(TARGET).elf &

debug: sim_silent
	$(GDB) --tui -ex "target remote :1234;break main;continue" $(TARGET).elf

clean:
	rm *.o

clean-all:
	rm *.o $(TARGET).*

.PHONY: program
program: $(TARGET).hex
	avrdude -c avr109 -p m169 -P /dev/ttyUSB0  -b 9600 -U flash:w:$(TARGET).hex






# ###############################################################################
# # Makefile for the project test
# ###############################################################################
#
# ## General Flags
# PROJECT = butterfly
# MCU = atmega8
# TARGET = $(PROJECT).elf
#
# CC = avr-gcc
# CXX = avr-g++
#
# ## Options common to compile, link and assembly rules
# COMMON = -mmcu=$(MCU)
#
# ## Compile options common for all C compilation units.
# CFLAGS = $(COMMON)
# CFLAGS += -Wall -gdwarf-2 -std=gnu99 -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
# CFLAGS += -MD -MP -MT $(*F).o -MF $(@F).d
#
#
# ## Assembly specific flags
# ASMFLAGS = $(COMMON)
# ASMFLAGS += $(CFLAGS)
# ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2
#
# ## Linker flags
# LDFLAGS = $(COMMON)
# LDFLAGS +=  -Wl,-Map=$(PROJECT).map
#
#
# ## Objects that must be built in order to link
# # OBJECTS = test.o
# SRC = $(wildcard *.c *.S *.s *.cpp)
# OBJ = $(SRC:=.o)
#
# ## Build
# all: $(TARGET) $(PROJECT).hex $(PROJECT).lss size
#
# ## Compile
# test.o: test.c
# 	$(CC) $(INCLUDES) $(CFLAGS) -c  $<
#
# ##Link
# $(TARGET): $(OBJECTS)
# 	 $(CC) $(LDFLAGS) $(OBJECTS)  $(LIBDIRS) $(LIBS) -o $(TARGET)
#
# %.hex: $(TARGET)
# 	avr-objcopy -O ihex $< $@
#
# %.lss: $(TARGET)
# 	avr-objdump -h -S $< > $@
#
# size: ${TARGET}
# 	@echo
# 	@avr-size -C --mcu=${MCU} ${TARGET}
#
# ## Clean target
# .PHONY: clean
# clean:
# 	-rm -rf $(OBJECTS) $(PROJECT).elf $(PROJECT).hex  $(PROJECT).lss $(PROJECT).map $(OBJECTS).d
#
# # default LFUSE 1 MHZ Internal RC, No brown out
# # LFUSE = 0xE1
#
# # change HFUSE for 512 bytes of boot memory and move reset vector to boot memory
# # HFUSE = 0xDC
#
# ## AVRDude Programming Bootloader
# program: $(PROJECT).hex
# 	avrdude -C avrdude.conf -c avr109 -P usb -p m169 -e -U flash:w:test.hex
# 	# -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m
#
# # read data from eeprom using bootloader
# # avrdude -c avr109 -p m8 -P /dev/ttyUSB0 -C avrdude.conf -b 9600 -U eeprom:r:read.hex:i
