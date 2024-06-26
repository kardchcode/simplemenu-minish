# Software Name
TARGET = simplemenu
PLATFORM = OD-BETA
#PLATFORM = RFW
#PLATFORM = OD
#PLATFORM = OD-BETA
#PLATFORM = NPG
#PLATFORM = RFW
#PLATFORM = BITTBOY

# Compiler
ifeq ($(PLATFORM), BITTBOY)
	CC = /opt/bittboy-toolchain/bin/arm-buildroot-linux-musleabi-gcc
	LINKER = /opt/bittboy-toolchain/bin/arm-buildroot-linux-musleabi-gcc
	CFLAGS = -DTARGET_BITTBOY -Ofast -fdata-sections -ffunction-sections -fno-PIC -flto -Wall -Wextra
	LIBS += -lSDL -lasound -lSDL_image -lpng -ljpeg -lSDL_ttf -lfreetype -lz -lbz2
else ifeq ($(PLATFORM), RFW)
	CC = /opt/rg300-toolchain/usr/bin/mipsel-linux-gcc
	LINKER = /opt/rg300-toolchain/usr/bin/mipsel-linux-gcc
	CFLAGS = -DTARGET_RFW -DUSE_GZIP -O2 -fdata-sections -ffunction-sections -fno-PIC -flto -Wall -Wextra
	LIBS += -lSDL -lSDL_sound -lSDL_image -lSDL_ttf -lopk -lz
else ifeq ($(PLATFORM), OD)
	CC = /opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-gcc
	LINKER = /opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-gcc
	CFLAGS = -DTARGET_OD -DUSE_GZIP -Ofast -fdata-sections -ffunction-sections -fno-PIC -flto -Wall -Wextra -std=gnu99
	LIBS += -lSDL -lSDL_sound -lSDL_image -lSDL_ttf -lshake -lpthread -lopk -lz
else ifeq ($(PLATFORM), OD-BETA)
	CC = ~/git/RG350_buildroot/output/host/usr/bin/mipsel-gcw0-linux-uclibc-gcc
	LINKER = ~/git/RG350_buildroot/output/host/usr/bin/mipsel-gcw0-linux-uclibc-gcc
	CFLAGS = -DTARGET_OD_BETA -DUSE_GZIP -Ofast -fdata-sections -ffunction-sections -fno-PIC -flto -Wall -Wextra 
	LIBS += -lSDL -lSDL_sound -lSDL_image -lSDL_ttf -lshake -lpthread -lopk -lz	
else ifeq ($(PLATFORM), NPG)
	CC = /opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-gcc
	LINKER = /opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-gcc
	CFLAGS = -DTARGET_NPG -DUSE_GZIP -Ofast -fdata-sections -ffunction-sections -fno-PIC -flto -Wall -std=gnu99
	LIBS += -lSDL -lSDL_sound -lSDL_image -lSDL_ttf -lpthread -lopk -lz -lbz2	
else
	TARGET = simplemenu-x86
	CC = gcc
	LINKER   = gcc
	CFLAGS = -DTARGET_PC -DUSE_GZIP -Ofast -fdata-sections -ffunction-sections -fPIC -flto -Wall -Wextra -std=gnu99
	LIBS += -lSDL -lasound -lSDL_image -lSDL_ttf -lpthread -lopk -lini -lz 	
endif

# You can use Ofast too but it can be more prone to bugs, careful.
CFLAGS +=  -I.
LDFLAGS = -Wl,--start-group $(LIBS) -Wl,--end-group -Wl,--as-needed -Wl,--gc-sections -flto

DEBUG=NO

ifeq ($(DEBUG), NO)
	CFLAGS +=  -DDEBUG -g3
else
	LDFLAGS	+=  -s -lm
endif

SRCDIR   = src/logic
OBJDIR   = src/obj
BINDIR   = output
SOURCES  := $(wildcard $(SRCDIR)/*.c)

ifeq ($(PLATFORM), BITTBOY)
	SOURCES := $(filter-out src/logic/control_od.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/control_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_od.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_rfw.c, $(SOURCES))	
else ifeq ($(PLATFORM), RFW)
	SOURCES := $(filter-out src/logic/control_od.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/control_bittboy.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_od.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_bittboy.c, $(SOURCES))		
else ifeq ($(PLATFORM), OD)  
	SOURCES := $(filter-out src/logic/control_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/control_bittboy.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_bittboy.c, $(SOURCES))
else ifeq ($(PLATFORM), OD-BETA)  
	SOURCES := $(filter-out src/logic/control_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/control_bittboy.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_bittboy.c, $(SOURCES))	
else ifeq ($(PLATFORM), NPG)  
	SOURCES := $(filter-out src/logic/control_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/control_bittboy.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_bittboy.c, $(SOURCES))	
else
	SOURCES := $(filter-out src/logic/control_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/control_bittboy.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_rfw.c, $(SOURCES))
	SOURCES := $(filter-out src/logic/system_logic_bittboy.c, $(SOURCES))	
endif 

OBJECTS := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

rm       = rm -f
	
$(BINDIR)/$(TARGET): $(OBJECTS)
	@$(LINKER) $(OBJECTS) $(LDFLAGS) -o $@
	@echo "Linking complete!"

$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.c
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

.PHONY: clean
clean:
	@$(rm) $(OBJECTS)
	@echo "Cleanup complete!"

.PHONY: remove
remove: clean
	@$(rm) $(BINDIR)/$(TARGET)
	@echo "Executable removed!"