derive_pll_clocks
derive_clock_uncertainty

set clk_sys   {*|pll|pll_inst|altera_pll_i|*[0].*|divclk}
set clk_vid   {*|pll|pll_inst|altera_pll_i|*[2].*|divclk}

set_false_path -from [get_clocks $clk_sys]   -to [get_clocks $clk_vid]
set_false_path -from [get_clocks $clk_vid]   -to [get_clocks $clk_sys]

set_multicycle_path -to {*Hq2x*} -setup 4
set_multicycle_path -to {*Hq2x*} -hold 3

set_false_path -to [get_registers {emu:emu|P3DO:p3do|MADAM:madam|MATH_M[*]}]
