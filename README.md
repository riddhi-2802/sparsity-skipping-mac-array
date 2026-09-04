# Sparsity-Skipping MAC Array

A hardware implementation of a sparsity-aware Multiply-Accumulate (MAC) array designed to reduce unnecessary MAC operations by detecting zero-valued operands and skipping those operations.

The project demonstrates the complete RTL-to-GDS ASIC flow for a 4×4 MAC array using the Sky130 technology.

---

## Project Objective

Conventional MAC arrays perform multiplication and accumulation even when an operand is zero.

For sparse data:

    0 × X = 0

Performing the multiplication is unnecessary.

This project introduces a zero-detection and MAC/skip decision mechanism in each Processing Element (PE). When either the weight or activation is zero, the MAC operation is skipped.

The goal is to demonstrate how sparsity can reduce the number of active MAC operations in hardware.

---

## Architecture

The design consists of:

- 16 Processing Elements (PEs)
- 4×4 MAC array
- 8-bit signed weights
- 8-bit signed activations
- 32-bit accumulators
- Zero detection
- MAC/skip decision logic
- Independent accumulator for each PE

### Processing Element

Each PE receives a weight and activation and determines whether to perform a MAC operation.

If either input is zero:

    Weight = 0 OR Activation = 0
                    ↓
                Skip MAC

Otherwise:

    Weight ≠ 0 AND Activation ≠ 0
                    ↓
                Perform MAC
                    ↓
    Accumulator = Accumulator + Weight × Activation

---

## RTL-to-GDS Flow

The design was implemented through the following ASIC flow:

    RTL Design
        ↓
    Functional Simulation
        ↓
    Logic Synthesis
        ↓
    Floorplanning
        ↓
    Power Distribution Network
        ↓
    Placement
        ↓
    Clock Tree Synthesis
        ↓
    Routing
        ↓
    Physical Verification
        ↓
    GDSII

---

## Functional Verification

The 4×4 MAC array was verified using Icarus Verilog.

### Dense Test

All 16 PEs receive non-zero operands.

    MAC operations = 16
    Skipped        = 0

Result: PASS

### Sparse Test

Only 4 of the 16 PEs receive non-zero weights.

    MAC operations = 4
    Skipped        = 12

Result: PASS

### Multi-Level Sparsity Analysis

| Sparsity | MACs Performed | MACs Skipped | MAC Reduction |
|----------|----------------|--------------|---------------|
| 0%       | 16             | 0            | 0%            |
| 25%      | 12             | 4            | 25%           |
| 50%      | 8              | 8            | 50%           |
| 75%      | 4              | 12           | 75%           |
| 100%     | 0              | 16           | 100%          |

At 75% sparsity, 12 out of 16 potential MAC operations are skipped.

Note: MAC-operation reduction does not directly imply the same percentage reduction in total chip power or execution time.

---

## Physical Design Results

The 4×4 MAC array was implemented using the Sky130 HD standard-cell library.

| Parameter | Result |
|-----------|--------|
| Die Area | 0.5539 mm² |
| Core Area | 528,499 µm² |
| Synthesized Cells | 10,152 |
| Total Physical Cells | 61,258 |
| Wire Length | 666,533 µm |
| Vias | 86,450 |
| Target Clock Period | 10 ns |
| Target Frequency | 100 MHz |
| Critical Path | 6.94 ns |

---

## Power Results

Post-layout power analysis reported:

| Power Component | Value |
|------------------|-------|
| Internal Power | 12.1 mW |
| Switching Power | 17.8 mW |
| Leakage Power | 0.0000814 mW |
| Total Power | 29.8 mW |

---

## Physical Verification

| Check | Result |
|-------|--------|
| DRC Violations | 0 |
| LVS Errors | 0 |
| Routing Violations | 0 |
| Short Violations | 0 |
| Metal Spacing Violations | 0 |

The LVS result of zero errors confirms correspondence between the physical layout and the implemented netlist.

---

## Timing

The reported critical datapath delay is:

    6.94 ns

against a target clock period of:

    10 ns

The reported negative WNS of -1.25 ns was traced to an asynchronous reset recovery path rather than the normal MAC datapath.

---

## Antenna Analysis

Antenna analysis reported:

- Pin antenna violations: 122
- Net antenna violations: 116

These are physical manufacturing-related violations identified during antenna checking.

They did not prevent GDS generation or LVS completion and are documented as a limitation of the current physical implementation.

---

## Tools Used

- Verilog — RTL design
- Icarus Verilog — Functional simulation
- GTKWave — Waveform analysis
- Yosys — Logic synthesis
- OpenLane — RTL-to-GDS flow
- OpenROAD — Physical design
- Sky130 HD — Standard-cell technology
- Docker / WSL2 — ASIC tool environment
- Git / GitHub — Version control

---

## Repository Structure

    sparsity-skipping-mac-array/
    │
    ├── rtl/
    │   ├── pe.v
    │   └── mac_array_4x4.v
    │
    ├── tb/
    │   ├── tb_pe.v
    │   ├── tb_mac_array_4x4.v
    │   └── tb_sparsity_analysis.v
    │
    ├── synthesis/
    │   └── array/
    │       └── mac_array_4x4_synth.v
    │
    ├── openlane/
    │   └── mac_array_4x4/
    │       ├── config.tcl
    │       ├── mac_array_4x4.v
    │       └── pe.v
    │
    ├── gds/
    │   ├── pe.gds
    │   ├── pe.def
    │   ├── pe_gatelevel.v
    │   ├── mac_array_4x4.gds
    │   └── mac_array_4x4.def
    │
    ├── results/
    │   └── mac_array_4x4_results.md
    │
    └── README.md

---

## Key Result

The project demonstrates that a hardware MAC array can detect zero-valued operands and avoid unnecessary MAC operations.

For the tested 4×4 array:

    75% sparsity
          ↓
    12 / 16 MAC operations skipped
          ↓
    75% reduction in MAC operations

The design was successfully taken from RTL through physical implementation to GDSII, with 0 DRC violations and 0 LVS errors reported for the final run.

---

## Future Work

Possible extensions include:

- Larger MAC arrays
- Weight-stationary or output-stationary dataflows
- Dynamic sparsity patterns
- Clock/power gating
- Comparison with a conventional dense MAC array
- Optimization of antenna and reset-recovery violations
- Power comparison between dense and sparse workloads
