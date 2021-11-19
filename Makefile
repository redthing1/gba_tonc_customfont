PATH := $(DEVKITARM)/bin:$(PATH)

TITLE		:= TestRom

#  Project settings

NAME		:= $(TITLE)
SOURCE_DIR 	:= src
LIB_DIR    	:= lib
TOOLS_DIR	:= ../tools
SPECS      := -specs=gba.specs

# Compilation settings

CROSS	?= arm-none-eabi-
AS	:= $(CROSS)as
CC	:= $(CROSS)gcc
LD	:= $(CROSS)gcc
OBJCOPY	:= $(CROSS)objcopy

ARCH	:= -mthumb-interwork -mthumb

INCFLAGS := -I$(DEVKITPRO)/libtonc/include -I$(DEVKITPRO)/libgba/include -I$(SOURCE_DIR) -I$(DATA_DIR) -I$(SOURCE_DIR)/arduino/lib/wasm3
LIBFLAGS := -L$(DEVKITPRO)/libtonc/lib -ltonc -L$(DEVKITPRO)/libgba/lib -lmm
ASFLAGS	:= -mthumb-interwork
CFLAGS	:= $(ARCH) -Wall -Werror -Wno-error=unused-variable -fno-strict-aliasing -mcpu=arm7tdmi -mtune=arm7tdmi $(INCFLAGS) $(LIBFLAGS)
LDFLAGS	:= $(ARCH) $(SPECS) $(LIBFLAGS) -Wl,-Map,$(TITLE).map


ifeq ($(DEBUG),1)
	CFLAGS += -O2 -g -DDEBUG
	DUSK_MKFLAGS += DEBUG=1
else
	# non-debug
	CFLAGS += -O2 -fomit-frame-pointer -ffast-math
endif

.PHONY : build clean

# Find and predetermine all relevant source files

APP_MAIN_SOURCE := $(shell find $(SOURCE_DIR) -name '*main.c')
APP_MAIN_OBJECT := $(APP_MAIN_SOURCE:%.c=%.o)
APP_SOURCES_C     := $(shell find $(SOURCE_DIR) -name '*.c' ! -name "*main.c"  ! -name "*.test.c")
APP_SOURCES_S     := $(shell find $(SOURCE_DIR) -name '*.s')
APP_OBJECTS_C     := $(APP_SOURCES_C:%.c=%.o)
APP_OBJECTS_S     := $(APP_SOURCES_S:%.s=%.o)
APP_OBJECTS		  := $(APP_OBJECTS_C) $(APP_OBJECTS_S)

# Built commands and dependencies

build: $(NAME).gba

no-content: $(NAME)-code.gba

# GBA ROM Build

$(NAME).gba : $(NAME)-code.gba $(NAME).gbfs
	cat $^ > $(NAME).gba

$(NAME)-code.gba : $(NAME).elf
	$(OBJCOPY) -v -O binary $< $@
	-@gbafix $@ -t$(NAME)
	padbin 256 $@

$(NAME).elf : $(APP_OBJECTS) $(APP_MAIN_OBJECT)
	$(LD) $^ $(LDFLAGS) -o $@

$(APP_OBJECTS_C) : %.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(APP_OBJECTS_S) : %.o : %.s
	$(CC) $(CFLAGS) -c $< -o $@

$(APP_MAIN_OBJECT) : $(APP_MAIN_SOURCE)
	$(CC) $(CFLAGS) -c $< -o $@

$(NAME).gbfs:
	touch $@ $(shell find $(DATA_DIR) -name '*.bin')

clean:
	@rm -fv *.gba
	@rm -fv *.elf
	@rm -fv *.sav
	@rm -fv *.gbfs
	@rm -rf $(APP_OBJECTS)
	@rm -rf $(APP_MAIN_OBJECT)
