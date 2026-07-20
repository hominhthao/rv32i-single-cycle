# ==========================================================
# RV32I Single-Cycle CPU Makefile
# Author : Ho Minh Thao
# ==========================================================

# ----------------------------------------------------------
# Tools
# ----------------------------------------------------------

IVERILOG ?= iverilog
VVP      ?= vvp
VERILATOR ?= verilator
SURFER   ?= surfer
YOSYS    ?= yowasp-yosys

# ----------------------------------------------------------
# Directories
# ----------------------------------------------------------

RTL_DIR       := rtl
TB_UNIT_DIR   := tb/unit
TB_INT_DIR    := tb/integration
BUILD_DIR     := build
REPORT_DIR    := reports

# ----------------------------------------------------------
# Current Unit Under Test
# ----------------------------------------------------------

UNIT ?= full_adder

UNIT_TOP  := $(UNIT)_tb
UNIT_RTL  := $(RTL_DIR)/$(UNIT).sv
UNIT_TB   := $(TB_UNIT_DIR)/$(UNIT)_tb.sv
UNIT_SIM  := $(BUILD_DIR)/$(UNIT).vvp
UNIT_WAVE := $(BUILD_DIR)/$(UNIT).vcd

# ----------------------------------------------------------
# Full CPU RTL Sources
# Add new modules here as the project grows
# ----------------------------------------------------------

RTL_SRCS := \
	$(RTL_DIR)/full_adder.sv

# ----------------------------------------------------------
# Default Target
# ----------------------------------------------------------

.PHONY: all

all: lint unit

# ----------------------------------------------------------
# Help
# ----------------------------------------------------------

.PHONY: help

help:
	@echo ""
	@echo "========== RV32I Single-Cycle CPU =========="
	@echo "make unit UNIT=full_adder   - Compile and run one unit test"
	@echo "make wave UNIT=full_adder   - Run unit test and open waveform"
	@echo "make lint                   - Run Verilator RTL lint"
	@echo "make synth                  - Run Yosys synthesis"
	@echo "make clean                  - Remove generated files"
	@echo "make all                    - Lint and run default unit test"
	@echo ""

# ----------------------------------------------------------
# Build Directory
# ----------------------------------------------------------

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(REPORT_DIR):
	@mkdir -p $(REPORT_DIR)

# ----------------------------------------------------------
# Unit Simulation with Icarus Verilog
# ----------------------------------------------------------

.PHONY: unit

unit: $(BUILD_DIR)
	@echo ""
	@echo "========== Running unit test: $(UNIT) =========="
	$(IVERILOG) \
		-g2012 \
		-Wall \
		-s $(UNIT_TOP) \
		-o $(UNIT_SIM) \
		$(UNIT_RTL) \
		$(UNIT_TB)

	$(VVP) $(UNIT_SIM)

# ----------------------------------------------------------
# Waveform Viewer
# ----------------------------------------------------------

.PHONY: wave

wave: unit
	$(SURFER) $(UNIT_WAVE)

# ----------------------------------------------------------
# RTL Lint
# ----------------------------------------------------------

.PHONY: lint

lint:
	@echo ""
	@echo "========== RTL Lint =========="
	$(VERILATOR) --lint-only --Wall $(RTL_SRCS)

# ----------------------------------------------------------
# Open-source Synthesis
# ----------------------------------------------------------

.PHONY: synth

synth: $(REPORT_DIR)
	@echo ""
	@echo "========== RTL Synthesis =========="
	$(YOSYS) -p "\
		read_verilog -sv $(RTL_SRCS); \
		hierarchy -check -top full_adder; \
		proc; \
		opt; \
		check; \
		stat" \
		| tee $(REPORT_DIR)/synthesis_report.txt

# ----------------------------------------------------------
# Clean
# ----------------------------------------------------------

.PHONY: clean

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(REPORT_DIR)
	rm -rf obj_dir
	rm -f *.vcd
	rm -f *.fst