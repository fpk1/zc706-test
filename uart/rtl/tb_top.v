`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/02 22:05:03
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top(

    );
    reg   clk;
    reg   sys_rst_n;
    reg   rx_data;
    wire   tx_data;
    
    initial begin 
        clk = 1'b0;
        sys_rst_n = 1'b1;
        rx_data = 1'b1;
        #200
        sys_rst_n = 1'b0;
        #200
        sys_rst_n = 1'b1;
        #200
        rx_data = 1'b0;
        #3472
        rx_data = 1'b1;
        #3472
        rx_data = 1'b0;
        #3472
        rx_data = 1'b1;
        #3472
        rx_data = 1'b0;
        #3472
        rx_data = 1'b1;
        #3472
        rx_data = 1'b0;
        #3472
        rx_data = 1'b1;
        #3472
        rx_data = 1'b1;
     end
//…˙≥… ±÷”
always #1 clk = ~clk ;
uart_loopback_top  u_uart_loopback_top(
    .clk         (clk),
    .sys_rst_n   (sys_rst_n ),
    .uart_rxd    (rx_data ),
    .uart_txd    (tx_data )

);
    
endmodule
