OUTDIR = .build
SRCDIR = src

MAKEMODPRINT = ★ \e[32mMAKEMOD\e[0m $<
COMPILEPRINT = ★ \e[32mCOMPILE\e[0m $<
LINKPRINT = ★ \e[32mLINK\e[0m $^
CLEANPRINT = ★ \e[32mCLEAN\e[0m

GIT_VER = $(shell git describe --always --dirty)

# ################################################################# #
# Configure phony & default targets
# ################################################################# #
.PHONY: all run
all: $(OUTDIR)/build_$(GIT_VER)

# ################################################################# #
# Set compiler flags & command
# ################################################################# #
COMPILER = gfortran -ffree-line-length-512 -fimplicit-none
ifdef static
	COMPILER := $(COMPILER) -static -static-libgfortran
endif
WARNING_FLAGS =	-Wall -Wextra -Wconversion-extra
COMPILE_FLAGS = -g -O3 -J$(OUTDIR) -DGIT_VER=\"$(GIT_VER)\"
INCLUDE_FLAGS =
LIBRARY_FLAGS =
DEBUG_FLAGS   = #-fbounds-check

COMPILE.f90 = $(COMPILER) -c $(WARNING_FLAGS) $(COMPILE_FLAGS) $(INCLUDE_FLAGS) $(DEBUG_FLAGS)
LINK.f90 = $(COMPILER) -flto $(WARNING_FLAGS) $(COMPILE_FLAGS) $(LIBRARY_FLAGS)
MAKEMOD.f90 = $(COMPILER) -c -fsyntax-only $(INCLUDE_FLAGS)

# ################################################################# #
# Set source code directories
# ################################################################# #
SRC = $(shell find ./$(SRCDIR) -name "*.f90" | cut -sd / -f 3-)

# ################################################################# #
# MODULE DEPENDENCIES DEFINITIONS
# ################################################################# #
$(OUTDIR)/main.o: $(OUTDIR)/brain.o $(OUTDIR)/world.o $(OUTDIR)/colony.o $(OUTDIR)/world_io.o $(OUTDIR)/time_evo.o
$(OUTDIR)/brain.o: $(OUTDIR)/world.o $(OUTDIR)/random.o
$(OUTDIR)/colony.o: $(OUTDIR)/brain.o
$(OUTDIR)/time_evo.o: $(OUTDIR)/colony.o $(OUTDIR)/brain.o $(OUTDIR)/world.o
$(OUTDIR)/world_io.o: $(OUTDIR)/world.o $(OUTDIR)/colony.o $(OUTDIR)/gif_module.o
$(OUTDIR)/world.o:


# ################################################################# #
# Define object file targets, and rules by language
# ################################################################# #
OBJECTS = $(addprefix $(OUTDIR)/,$(SRC:.f90=.o))

$(OBJECTS): $(OUTDIR)/%.o: $(SRCDIR)/%.f90
	@echo -e "$(COMPILEPRINT)"
	@mkdir -p $(@D)
	@$(COMPILE.f90) $< -o $@

# ################################################################# #
# Define binary/hex targets
# ################################################################# #
$(OUTDIR)/build_$(GIT_VER): $(OBJECTS)
	@echo -e "$(LINKPRINT)"
	@mkdir -p $(@D)
	@$(LINK.f90) $^ -o $@
	@cp $@ $(OUTDIR)/build_latest
	@echo -e "==> $@"

# ################################################################# #
# Define cleanup target
# ################################################################# #
clean:
	@echo -e "$(CLEANPRINT) $(OUTDIR)"
	@rm -fr $(OUTDIR)
