set ::env(DESIGN_NAME) "mac_array_4x4"

set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/mac_array_4x4.v \
    $::env(DESIGN_DIR)/pe.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10.0"

set ::env(FP_CORE_UTIL) 20
set ::env(PL_TARGET_DENSITY) 0.50
