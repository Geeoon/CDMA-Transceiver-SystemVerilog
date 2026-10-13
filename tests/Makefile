HDL_DIR := ../rtl
BUILD_DIR := ./build
TB_DIR := ./testbenches
WAVEFORM_DIR := ./waveforms

HDL_FILES := $(shell find $(HDL_DIR) -name '*.sv' -or -name '*.v' -or -name '*.svh')
TB_FILES := $(shell find $(TB_DIR) -name '*.sv' -or -name '*.v')

# Names of testbenches, derived from testbench filenames (foo_tb.sv -> foo_tb)
TB_NAMES := $(basename $(notdir $(TB_FILES)))

VERILATOR_BUILD_DIR := $(BUILD_DIR)/verilator
VERILATOR_FLAGS := --binary -j 0 --trace --no-stop-fail --assert

# One .vcd target per discovered testbench
WAVEFORMS := $(addprefix $(WAVEFORM_DIR)/,$(addsuffix .vcd,$(TB_NAMES)))

all: $(WAVEFORMS)

# Verilator: pattern rule, one build dir per testbench so runs don't clobber each other
$(WAVEFORM_DIR)/%.vcd: $(HDL_FILES) $(TB_FILES)
	mkdir -p $(VERILATOR_BUILD_DIR)/$* $(WAVEFORM_DIR)
	verilator $(VERILATOR_FLAGS) -Mdir $(VERILATOR_BUILD_DIR)/$* --top-module $* $(HDL_FILES) $(TB_FILES)
	$(VERILATOR_BUILD_DIR)/$*/V$*

.PHONY: clean all
clean:
	rm -rf $(BUILD_DIR) $(WAVEFORM_DIR)

FORCE: ;
