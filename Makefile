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

# Extra RTL files needed by each unit test.
# Example: adder_32bit instantiates full_adder.
UNIT_DEPS_adder_32bit := $(RTL_DIR)/full_adder.sv
UNIT_DEPS_subtractor_32bit := $(RTL_DIR)/full_adder.sv $(RTL_DIR)/adder_32bit.sv
UNIT_DEPS_alu := \
	$(RTL_DIR)/full_adder.sv \
	$(RTL_DIR)/adder_32bit.sv \
	$(RTL_DIR)/subtractor_32bit.sv \
	$(RTL_DIR)/and_32bit.sv \
	$(RTL_DIR)/or_32bit.sv \
	$(RTL_DIR)/xor_32bit.sv \
	$(RTL_DIR)/sll_32bit.sv \
	$(RTL_DIR)/srl_32bit.sv \
	$(RTL_DIR)/sra_32bit.sv \
	$(RTL_DIR)/slt_32bit.sv \
	$(RTL_DIR)/sltu_32bit.sv \

	
UNIT_DEPS_lsu := \
	$(RTL_DIR)/memory.sv
UNIT_DEPS_imem := $(RTL_DIR)/memory.sv
UNIT_DEPS := $(UNIT_DEPS_$(UNIT))
UNIT_SRCS := $(UNIT_DEPS) $(UNIT_RTL)

# ----------------------------------------------------------
# Full CPU RTL Sources
# Add new modules here as the project grows
# ----------------------------------------------------------

RTL_SRCS := \
	$(RTL_DIR)/full_adder.sv \
	$(RTL_DIR)/adder_32bit.sv \
	$(RTL_DIR)/subtractor_32bit.sv \
	$(RTL_DIR)/and_32bit.sv \
	$(RTL_DIR)/or_32bit.sv \
	$(RTL_DIR)/xor_32bit.sv \
	$(RTL_DIR)/sll_32bit.sv \
	$(RTL_DIR)/srl_32bit.sv \
	$(RTL_DIR)/sra_32bit.sv \
	$(RTL_DIR)/slt_32bit.sv \
	$(RTL_DIR)/sltu_32bit.sv \
	$(RTL_DIR)/alu.sv \
	$(RTL_DIR)/immgen.sv \
	$(RTL_DIR)/regfile.sv \
	$(RTL_DIR)/brc.sv \
	$(RTL_DIR)/memory.sv \
	$(RTL_DIR)/lsu.sv \
	$(RTL_DIR)/pc_plus4.sv \
	$(RTL_DIR)/pc.sv \
	$(RTL_DIR)/mux2_32bit.sv \
	$(RTL_DIR)/mux4_32bit.sv \
	$(RTL_DIR)/imem.sv \

LINT_UNITS := \
	full_adder \
	adder_32bit \
	subtractor_32bit \
	and_32bit \
	or_32bit \
	xor_32bit\
	sll_32bit \
	srl_32bit \
	sra_32bit \
	slt_32bit \
	sltu_32bit \
	alu \
	immgen \
	regfile \
	brc	\
	memory \
	lsu	\
	pc_plus4 \
	pc \
	mux2_32bit \
	mux4_32bit \
	imem 												

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
	@echo "make unit UNIT=adder_32bit  - Compile and run one unit test"
	@echo "make wave UNIT=full_adder   - Run unit test and open waveform"
	@echo "make lint                   - Run Verilator RTL lint"
	@echo "make lint-unit UNIT=<name>  - Run Verilator lint for one unit"
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
		$(UNIT_SRCS) \
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
	@for unit in $(LINT_UNITS); do \
		$(MAKE) lint-unit UNIT=$$unit || exit 1; \
	done

.PHONY: lint-unit

lint-unit:
	@echo ""
	@echo "========== RTL Unit Lint: $(UNIT) =========="
	$(VERILATOR) --lint-only --Wall --top-module $(UNIT) $(UNIT_SRCS)

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
