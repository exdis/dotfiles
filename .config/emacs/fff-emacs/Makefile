EMACS_INCLUDE = /Applications/Emacs.app/Contents/Resources/include
FFF_LIB_DIR   = /Users/dkolesnikov/dev/fff.nvim/target/release
MODULE_NAME   = fff-module

CC = cc
CFLAGS = -O2 -Wall -Wextra \
         -I$(EMACS_INCLUDE) -I. \
         -fPIC

LDFLAGS = -L$(FFF_LIB_DIR) -lfff_c \
          -Wl,-rpath,$(FFF_LIB_DIR)

# macOS uses .dylib for dynamic modules but Emacs expects .so
TARGET = $(MODULE_NAME).so

.PHONY: all clean

all: $(TARGET)

$(TARGET): fff-module.c fff.h
	$(CC) $(CFLAGS) -shared -o $@ fff-module.c $(LDFLAGS)

clean:
	rm -f $(TARGET)
