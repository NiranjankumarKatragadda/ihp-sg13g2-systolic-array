# 4x4 Systolic Array MAC Accelerator: RTL-to-GDSII on IHP SG13G2 (130nm BiCMOS)

[[https://img.shields.io/badge/PDK-IHP%20SG13G2%20130nm-darkblue]](https://github.com/IHP-GmbH/IHP-Open-PDK)
[[https://img.shields.io/badge/Flow-LibreLane%20v3.0.4-green]](https://github.com/librelane/librelane)
[[https://img.shields.io/badge/Signoff-0%20DRC%20%7C%20Clean%20LVS-success]](#physical-design--ppa-scorecard)
[[https://img.shields.io/badge/Timing-100MHz%20Met-orange]](#physical-design--ppa-scorecard)
[[https://img.shields.io/badge/License-Apache%202.0-blue.svg]](LICENSE)

An automated RTL-to-GDSII physical design implementation of a **4×4 Systolic Array Matrix-Multiply-Accumulate (MAC) Accelerator** targeting the European open-source **IHP SG13G2 130nm BiCMOS** technology node using LibreLane, OpenROAD, and OpenSTA.

---

## 📌 Architecture Overview

The accelerator consists of a 2D mesh of 16 processing elements (PEs) optimized for real-time matrix multiplication workloads:
* **Processing Element (PE):** 8-bit signed integer multiplier with 32-bit accumulation registers and dual-buffered weight registers.
* **Data Flow:** Weight-stationary systolic architecture with skewing registers on row inputs and column inputs.
* **Verification:** Full functional and protocol compliance verified via Cocotb (`cocotb/chip_top_tb.py`).

---

## 📊 Physical Design & PPA Scorecard

| Parameter | Specification / Result | Status |
| :--- | :--- | :--- |
| **Technology Node** | IHP SG13G2 (130nm BiCMOS) | Verified |
| **PDK Release** | Open-source IHP-Open-PDK | Qualified |
| **Flow Toolchain** | LibreLane v3.0.4 / OpenROAD / OpenSTA | Automated |
| **Standard Cell Count** | 4,385 cells | Placed |
| **Target Clock Frequency** | 100 MHz (Clock Period: 10.0 ns) | Met |
| **Worst Negative Slack (Setup)** | +5.10 ns (Clean positive slack) | **PASS** |
| **Worst Negative Slack (Hold)** | +0.22 ns (No hold violations) | **PASS** |
| **Clock Skew** | < 85 ps | **PASS** |
| **Design Rule Check (DRC)** | 0 violations (KLayout sign-off rule deck) | **CLEAN** |
| **Layout vs. Schematic (LVS)** | Clean Netgen LVS (Matched ports, devices, nets) | **CLEAN** |
| **Antenna Violations** | 0 violations | **CLEAN** |

---

## 🖼️ Hardened GDSII Layout

[img/chip_top.png]

---

## 📁 Repository Directory Structure

```text
├── final/
│   ├── gds/                  # Final sign-off GDSII stream
│   ├── spef/                 # Extracted RC parasitic files
│   ├── metrics.csv           # Consolidated PPA metrics table
│   └── metrics.json          # Machine-readable sign-off log
├── src/
│   ├── chip_top.sv           # Top-level padframe and bondpad integration
│   ├── chip_core.sv          # Core logic wrapper
│   ├── systolic_array_4x4.v  # 4x4 matrix processing mesh
│   └── pe.v                  # Processing Element MAC unit
├── librelane/
│   ├── config.yaml           # LibreLane flow configuration
│   ├── chip_top.sdc          # Multi-corner timing constraints
│   └── pdn_cfg.tcl           # Power grid and ring synthesis script
└── cocotb/
    └── chip_top_tb.py        # Python verification testbench
