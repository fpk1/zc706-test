`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/02 20:14:49
// Design Name: 
// Module Name: tb_rcv
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


module tb_rcv(

    );
    //输入
reg sys_clk;
reg sys_rst_n;
reg en;
//输出
reg [7:0] data;

wire data1;

wire busy;
//信号初始化
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b1;
    en = 1'b0;
    data = 8'd0;
    #200
    sys_rst_n = 1'b0;
    #200
    sys_rst_n = 1'b1;
    #200
    data = 8'b10101010;
    #200
    en = 1'b1;
end
//生成时钟
always #1 sys_clk = ~sys_clk ;

uart_send  u_uart_send(
    .clk            (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .uart_en        (en),
    .uart_din       (data),
    .uart_tx_busy   (busy),
    .uart_txd       (data1)
);
endmodule
