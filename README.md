# 4x4 Systolic Array MAC Accelerator: RTL-to-GDSII on IHP SG13G2 (130nm BiCMOS)

[[https://github.com/NiranjankumarKatragadda/ihp-sg13g2-systolic-array/actions/workflows/ci.yml/badge.svg]](https://github.com/NiranjankumarKatragadda/ihp-sg13g2-systolic-array/actions/workflows/ci.yml)
[[https://img.shields.io/badge/PDK-IHP%20SG13G2%20130nm-darkblue]](https://github.com/IHP-GmbH/IHP-Open-PDK)
[[https://img.shields.io/badge/Flow-LibreLane%20v3.0.4-green]](https://github.com/librelane/librelane)
[[https://img.shields.io/badge/Signoff-0%20DRC%20%7C%20Clean%20LVS-success]](#physical-design-results)
[[https://img.shields.io/badge/License-Apache%202.0-blue.svg]](LICENSE)

A 4x4 weight-stationary systolic array for matrix multiply-accumulate, taken from RTL to signed-off GDSII on the open-source **IHP SG13G2 130nm BiCMOS** process using LibreLane, OpenROAD, and OpenSTA.

[img/chip_top.png]

## Architecture
16 processing elements (PEs) in a 2D mesh:
- **Processing element (`src/pe.v`):** 8-bit signed multiplier, 32-bit accumulator, dual-buffered weight registers.
- **Dataflow (`src/systolic_array_4x4.v`):** Weight-stationary mesh with skew registers on the row and column inputs.
- **Top level (`src/chip_top.sv` / `src/chip_core.sv`):** Padframe and bondpad integration around the core wrapper.

## Physical design results

| Metric | Result |
| --- | --- |
| Technology | IHP SG13G2 (`PDK_COMMIT` `3b5a704ba6738aa686b08706187830e6284d2a10`) |
| Flow | LibreLane v3.0.4 / OpenROAD / OpenSTA |
| Standard cell count | 4,385 |
| Clock constraint (`config.yaml` / scorecard) | 50 MHz (`CLOCK_PERIOD: 20` ns) / 100 MHz scorecard |
| Setup WNS | +5.10 ns |
| Hold WNS | +0.22 ns |
| Clock skew | < 85 ps |
| DRC (KLayout) | 0 violations |
| LVS (Netgen) | Clean |
| Antenna violations | 0 |
| Die / core area | `1600 x 1600 um^2` / `870 x 870 um^2` (`10%` target density) |

## Verification
- **Testbench:** `cocotb/chip_top_tb.py` runs pad-level functional and protocol checks at both RTL (`make sim`) and post-PnR gate-level (`make sim-gl` with `GL=1`) using Cocotb (`icarus` / `verilator` runner) in GitHub Actions CI ([run 43708830804](https://github.com/NiranjankumarKatragadda/ihp-sg13g2-systolic-array/actions/runs/43708830804)).

## Reproduce

    git clone https://github.com/NiranjankumarKatragadda/ihp-sg13g2-systolic-array.git
    cd ihp-sg13g2-systolic-array
    nix develop --command make clone-pdk
    nix develop --command make sim
    nix develop --command make librelane
    nix develop --command make sim-gl

## Need something similar?
NK Verif Labs offers verification and RTL-to-GDSII services. Email **nkveriflabs@gmail.com**.

## License
Apache-2.0. See [LICENSE](LICENSE).
