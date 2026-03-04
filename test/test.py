# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


def pack_input(data, load=0, start=0):
    """Pack signals into ui_in"""
    return (start << 7) | (load << 6) | (data & 0x3F)


@cocotb.test()
async def test_project(dut):

    dut._log.info("Starting 3x3 Matrix Multiplier Test")

    # 100 kHz clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # -------------------------
    # Test Matrices
    # -------------------------

    # Matrix A
    A = [
        1, 2, 3,
        4, 5, 6,
        7, 8, 9
    ]

    # Matrix B
    B = [
        9, 8, 7,
        6, 5, 4,
        3, 2, 1
    ]

    # Expected C = A x B
    C_expected = [
        30, 24, 18,
        84, 69, 54,
        138,114, 90
    ]

    # -------------------------
    # LOAD MATRICES
    # -------------------------
    dut._log.info("Loading matrices...")

    for val in A + B:
        dut.ui_in.value = pack_input(val, load=1, start=0)
        await ClockCycles(dut.clk, 1)

    # Deassert load
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    # -------------------------
    # START COMPUTATION
    # -------------------------
    dut._log.info("Starting computation...")

    dut.ui_in.value = pack_input(0, load=0, start=1)
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0

    # -------------------------
    # WAIT FOR DONE
    # -------------------------
    dut._log.info("Waiting for done...")

    while True:
        val = dut.uo_out.value
    
        # Wait until signal has no X/Z
        if val.is_resolvable:
            if (val.to_unsigned() >> 4) & 1:
                break
    
        await RisingEdge(dut.clk)

    dut._log.info("Computation complete!")

    # -------------------------
    # READ RESULTS
    # -------------------------

    results = []

    for i in range(9):
        await ClockCycles(dut.clk, 1)
        val = dut.uo_out.value
        result = val.to_unsigned() & 0xF
        results.append(result)

    # Since output is 4-bit nibble, we only check lower 4 bits
    for i in range(9):
        assert (C_expected[i] & 0xF) == results[i], \
            f"Mismatch at index {i}: Expected {C_expected[i] & 0xF}, got {results[i]}"

    dut._log.info("All tests passed!")
