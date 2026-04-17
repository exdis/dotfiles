MODULE_NAME = fff-module

# --- Auto-detect Emacs include path ---
EMACS_PREFIX := $(shell emacs --batch --eval '(let ((d (expand-file-name ".." data-directory))) (princ (substring d 0 (string-match "/share/emacs" d))))' 2>/dev/null)
EMACS_INCLUDE := $(shell \
  for d in "$(EMACS_PREFIX)/include" $(EMACS_PREFIX)/share/emacs/*/src \
           /Applications/Emacs.app/Contents/Resources/include; do \
    [ -f "$$d/emacs-module.h" ] && echo "$$d" && exit 0; \
  done)
ifeq ($(EMACS_INCLUDE),)
  $(error Cannot find emacs-module.h. Set EMACS_INCLUDE manually)
endif

# --- Auto-detect fff-c library ---
# Walk up from this Makefile's directory to find fff.nvim repo
FFF_REPO := $(shell \
  d="$$(cd "$$(dirname "$(lastword $(MAKEFILE_LIST))")" && pwd)"; \
  while [ "$$d" != "/" ]; do \
    for candidate in "$$d/fff.nvim" "$$d/dev/fff.nvim"; do \
      [ -f "$$candidate/Cargo.toml" ] && echo "$$candidate" && exit 0; \
    done; \
    d="$$(dirname "$$d")"; \
  done)
ifeq ($(FFF_REPO),)
  $(error Cannot find fff.nvim repo. Set FFF_LIB_DIR manually)
endif
FFF_LIB_DIR ?= $(FFF_REPO)/target/release

# --- Platform detection ---
UNAME := $(shell uname -s)

CC = cc
CFLAGS = -O2 -Wall -Wextra \
         -I$(EMACS_INCLUDE) -I. \
         -fPIC

ifeq ($(UNAME),Darwin)
  LDFLAGS = -L$(FFF_LIB_DIR) -lfff_c \
            -Wl,-rpath,@loader_path \
            -Wl,-rpath,$(FFF_LIB_DIR)
else
  LDFLAGS = -L$(FFF_LIB_DIR) -lfff_c \
            -Wl,-rpath,$(FFF_LIB_DIR)
endif

TARGET = $(MODULE_NAME).so

.PHONY: all clean info

all: $(TARGET)

$(TARGET): fff-module.c fff.h
	$(CC) $(CFLAGS) -shared -o $@ fff-module.c $(LDFLAGS)

clean:
	rm -f $(TARGET)

info:
	@echo "EMACS_INCLUDE = $(EMACS_INCLUDE)"
	@echo "FFF_REPO      = $(FFF_REPO)"
	@echo "FFF_LIB_DIR   = $(FFF_LIB_DIR)"
	@echo "UNAME         = $(UNAME)"
