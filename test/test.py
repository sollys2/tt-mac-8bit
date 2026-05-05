# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge
import csv
import os

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 0

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.



@cocotb.test()
async def test_with_vectors(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Test project behavior")
    
    vector_file = os.path.join(os.path.dirname(__file__), "vectors.csv")

    with open(vector_file, "r") as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader):
            # Apply input values to the DUT
            a = int(row['a'])
            b = int(row['b'])

            # Pack input bits into full input bus
            dut.ui_in.value = (b << 1) | a

            # Wait for the result to settle
            await ClockCycles(dut.clk, 2)

            # Check the output
            expected = int(row['out'])
            actual = int(dut.uo_out[0].value)
            
            dut._log.info(f"Vector {i}: a={dut.ui_in.value}, b={dut.ui_in.value}, Got out={actual}, expecting out={expected}")
            assert actual == expected, f"Vector {i}: {row} => Got out={actual}, expected {expected}"
