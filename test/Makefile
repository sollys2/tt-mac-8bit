# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.v

# Common Verilog sources for MAC tests
COMMON_VERILOG_SOURCES = ../src/project.v ../src/nibble_interface.v ../src/MAC_simple.v ../src/components/input_registers.v ../src/components/change_detector.v ../src/components/pipeline_registers.v ../src/components/accumulator_16p1bit.v

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS 		+= -I$(SRC_DIR)

# Default test: MAC tests
test_mac:
	$(MAKE) VERILOG_SOURCES="$(COMMON_VERILOG_SOURCES) tb_mac_simple.v" TOPLEVEL=tb_mac_simple MODULE=test_mac sim

# Default target
all: test_mac

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# Backward compatibility - default to MAC test for make without target
ifndef MAKECMDGOALS
VERILOG_SOURCES = $(COMMON_VERILOG_SOURCES) tb_mac_simple.v
TOPLEVEL = tb_mac_simple
MODULE = test_mac
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
