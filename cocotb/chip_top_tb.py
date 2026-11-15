# SPDX-FileCopyrightText: © 2025 LibreLane Template Contributors
# SPDX-License-Identifier: Apache-2.0

import os
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sim = os.getenv("SIM", "icarus")
pdk_root = os.getenv("PDK_ROOT", Path("~/.ciel").expanduser())
pdk = os.getenv("PDK", "ihp-sg13g2")
scl = os.getenv("SCL", "sg13g2_stdcell")
gl = os.getenv("GL", False)

hdl_toplevel = "chip_top"

async def set_defaults(dut):
    dut.input_PAD.value = 0

async def enable_power(dut):
    dut.VDD.value = 1
    dut.VSS.value = 0

async def start_clock(clock, freq=50):
    """Start the clock @ freq MHz"""
    c = Clock(clock, 1 / freq * 1000, "ns")
    cocotb.start_soon(c.start())


async def reset(reset, active_low=True, time_ns=1000):
    """Reset dut"""
    cocotb.log.info("Reset asserted...")

    reset.value = not active_low
    await Timer(time_ns, "ns")
    reset.value = active_low

    cocotb.log.info("Reset deasserted.")


async def start_up(dut):
    """Startup sequence"""
    await set_defaults(dut)
    if gl:
        await enable_power(dut)
    await start_clock(dut.clk_PAD)
    await reset(dut.rst_n_PAD)


@cocotb.test()
async def test_systolic_array(dut):
    """Verify systolic_array_4x4 LOAD -> COMPUTE -> READ flow."""
    logger = logging.getLogger("systolic_tb")
    await start_up(dut)
    await ClockCycles(dut.clk_PAD, 2)
    assert int(dut.output_PAD.value) == 0, f"Expected 0 after reset, got {dut.output_PAD.value}"

    # LOAD weights = 1 (ctrl_in = 2'b01, data_in = 1)
    dut.input_PAD.value = (0b01 << 8) | 1
    await ClockCycles(dut.clk_PAD, 5)

    # COMPUTE with activation = 2 (ctrl_in = 2'b10, data_in = 2)
    dut.input_PAD.value = (0b10 << 8) | 2
    await ClockCycles(dut.clk_PAD, 14)

    # READ & latch c_col0..c_col3 (ctrl_in = 2'b11)
    dut.input_PAD.value = (0b11 << 8) | 0
    await ClockCycles(dut.clk_PAD, 2)

    cols = []
    for col in range(4):
        dut.input_PAD.value = (0b11 << 8) | col
        await ClockCycles(dut.clk_PAD, 1)
        cols.append(int(dut.output_PAD.value))

    logger.info(f"Systolic READ cols[0..3] = {cols}")
    assert any(v != 0 for v in cols), f"Expected non-zero MAC output, got {cols}"


def chip_top_runner():

    proj_path = Path(__file__).resolve().parent

    sources = []
    defines = {}
    includes = []

    if gl:
        # SCL models
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"{scl}.v")
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"sg13g2_udp.v")

        # We use the unpowered netlist
        sources.append(proj_path / f"../final/nl/{hdl_toplevel}.nl.v")

        defines = {"USE_POWER_PINS": False}
    else:
        sources.append(proj_path / "../src/chip_top.sv")
        sources.append(proj_path / "../src/chip_core.sv")
        sources.append(proj_path / "../src/pe.v")
        sources.append(proj_path / "../src/systolic_array_4x4.v")

    sources += [
        # IO pad models
        Path(pdk_root) / pdk / "libs.ref/sg13g2_io/verilog/sg13g2_io.v",
        
        # Bondpads
        proj_path / "../ip/bondpad_70x70/vh/bondpad_70x70.v",
        proj_path / "../ip/bondpad_70x70_novias/vh/bondpad_70x70_novias.v",
        
        # SRAM models
        Path(pdk_root) / pdk / "libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_1024x32_c2_bm_bist.v",
        Path(pdk_root) / pdk / "libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_core_behavioral_bm_bist.v",
    ]

    build_args = []

    if sim == "icarus":
        # For debugging
        # build_args = ["-Winfloop", "-pfileline=1"]
        pass

    if sim == "verilator":
        build_args = ["--timing", "--trace", "--trace-fst", "--trace-structs"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        defines=defines,
        always=True,
        includes=includes,
        build_args=build_args,
        waves=True,
    )

    plusargs = []

    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module="chip_top_tb,",
        plusargs=plusargs,
        waves=True,
    )


if __name__ == "__main__":
    chip_top_runner()
