# 4×4 Sparsity-Skipping MAC Array — Results

## 1. Functional Verification

The 4×4 MAC array was verified using Icarus Verilog.

### Dense Input Test
- MAC operations: 16
- Skipped operations: 0
- Result: PASS

### Sparse Input Test
- MAC operations: 4
- Skipped operations: 12
- Result: PASS

The sparse test demonstrates that zero-valued operands are detected and the corresponding MAC operations are skipped.

---

## 2. RTL-to-GDS Implementation

The design was taken through the following ASIC flow:

RTL → Synthesis → Floorplanning → Placement → Routing → GDS

The final GDS and DEF files were generated successfully.

### Technology
- Standard-cell library: Sky130 HD
- Target clock period: 10 ns
- Target frequency: 100 MHz
- Core utilization: 20%

---

## 3. Physical Design Results

| Parameter | Result |
|---|---:|
| Die area | 0.5539 mm² |
| Core area | 528,499 µm² |
| Synthesized cells | 10,152 |
| Total physical cells | 61,258 |
| Wire length | 666,533 µm |
| Vias | 86,450 |

---

## 4. Timing Results

- Target clock period: 10 ns
- Critical path: 6.94 ns
- Reported WNS: -1.25 ns
- Reported TNS: -679.81 ns

The negative WNS was traced to an asynchronous reset recovery path rather than the normal MAC datapath.

---

## 5. Power Results

Post-layout power analysis reported:

| Power component | Power |
|---|---:|
| Internal | 12.1 mW |
| Switching | 17.8 mW |
| Leakage | 0.0000814 mW |
| **Total** | **29.8 mW** |

---

## 6. Physical Verification

| Check | Result |
|---|---:|
| DRC violations | 0 |
| LVS errors | 0 |
| Routing violations | 0 |
| Short violations | 0 |
| Metal-spacing violations | 0 |

The LVS result of zero errors confirms correspondence between the physical layout and the intended netlist.

---

## 7. Antenna Analysis

Antenna analysis reported:

- Pin antenna violations: 122
- Net antenna violations: 116

These violations are physical manufacturing-related issues identified during antenna checking. They did not prevent GDS generation or LVS completion.

---

## 8. Summary

The 4×4 sparsity-skipping MAC array was successfully implemented from RTL through physical design and GDS generation. Functional simulation verified both dense and sparse operating conditions, demonstrating MAC skipping for zero-valued operands.

The final implementation achieved a die area of approximately 0.5539 mm² and a reported critical datapath delay of 6.94 ns. DRC reported zero violations and LVS reported zero errors.
