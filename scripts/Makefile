# ==============================================================================
#  Async FIFO UVM Verification Makefile
# ==============================================================================

# ------------------------------------------------------------------------------
#  Directories
# ------------------------------------------------------------------------------
ROOT_DIR  = ..
RTL_DIR   = $(ROOT_DIR)/rtl
DV_DIR    = $(ROOT_DIR)/dv
AGENTS    = $(DV_DIR)/agents
ENV       = $(DV_DIR)/env
SEQS      = $(DV_DIR)/sequences
TESTS     = $(DV_DIR)/tests
TOP       = $(DV_DIR)/tb_top

# ------------------------------------------------------------------------------
#  Simulation Variables
# ------------------------------------------------------------------------------
TESTNAME  ?= fifo_base_test
SEED      ?= random
VERBOSITY ?= UVM_MEDIUM

# Includes for compilation
INCDIRS   = +incdir+$(RTL_DIR) \
            +incdir+$(AGENTS)/write_agent \
            +incdir+$(AGENTS)/read_agent \
            +incdir+$(ENV) \
            +incdir+$(SEQS) \
            +incdir+$(TESTS) \
            +incdir+$(TOP)

# ------------------------------------------------------------------------------
#  Tool Selection (Uncomment your simulator)
# ------------------------------------------------------------------------------

# --- SYNOPSYS VCS ---
# SIM_TOOL = vcs
# COMP_OPTS = -sverilog -ntb_opts uvm +v2k -timescale=1ns/1ps -debug_access+all -full64
# RUN_OPTS  = -l simulation.log +UVM_TESTNAME=$(TESTNAME) +UVM_VERBOSITY=$(VERBOSITY) +ntb_random_seed=$(SEED)

# --- SIEMENS QUESTASIM ---
SIM_TOOL = vsim
COMP_OPTS = -sv -timescale 1ns/1ps +acc
RUN_OPTS  = -c -do "run -all; exit" +UVM_TESTNAME=$(TESTNAME) +UVM_VERBOSITY=$(VERBOSITY) -l simulation.log

# ------------------------------------------------------------------------------
#  Targets
# ------------------------------------------------------------------------------

all: clean compile run

# 1. Compile Step
compile:
	@echo "============================================="
	@echo " Compiling RTL and TB..."
	@echo "============================================="
ifeq ($(SIM_TOOL), vcs)
	vcs $(COMP_OPTS) $(INCDIRS) \
	$(RTL_DIR)/*.sv \
	$(TOP)/fifo_if.sv \
	$(TOP)/tb_top.sv
else
	vlib work
	vlog $(COMP_OPTS) $(INCDIRS) \
	$(RTL_DIR)/*.sv \
	$(TOP)/fifo_if.sv \
	$(TOP)/tb_top.sv
endif

# 2. Run Step
run:
	@echo "============================================="
	@echo " Running Test: $(TESTNAME)"
	@echo "============================================="
ifeq ($(SIM_TOOL), vcs)
	./simv $(RUN_OPTS)
else
	vsim tb_top $(RUN_OPTS)
endif

# 3. View Waves
waves:
ifeq ($(SIM_TOOL), vcs)
	dve -vpd vcdplus.vpd &
else
	vsim -view vsim.wlf &
endif

# 4. Clean Step
clean:
	rm -rf work mti_lib transcript *~ *.log *.vstf *.wlf *.vpd *.ddc simv* csrc *.key
	@echo "Cleaned simulation artifacts."

help:
	@echo "Usage:"
	@echo "  make run TEST=fifo_full_test   # Run specific test"
	@echo "  make waves                     # Open waveform viewer"
	@echo "  make clean                     # Delete temp files"