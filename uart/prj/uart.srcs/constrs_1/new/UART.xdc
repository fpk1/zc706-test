create_clock -period 5.000 -name CLK [get_ports sys_clk_p]
set_property PACKAGE_PIN H9 [get_ports sys_clk_p]
set_property IOSTANDARD LVDS [get_ports sys_clk_p]

set_property PACKAGE_PIN AJ21 [get_ports uart_rxd]
set_property PACKAGE_PIN AB21 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS15 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS15 [get_ports uart_rxd]

set_property PACKAGE_PIN AK25 [get_ports key]
set_property IOSTANDARD LVCMOS15 [get_ports key]

