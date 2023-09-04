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
reg data1;
//输出
wire [7:0] data;
wire done;
//信号初始化
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b1;
    data1 = 1'b1;
    #200
    sys_rst_n = 1'b0;
    #200
    sys_rst_n = 1'b1;
    #200
    data1 = 1'b0;
    #3472
    data1 = 1'b1;
    #3472
    data1 = 1'b0;
    #3472
    data1 = 1'b1;
    #3472
    data1 = 1'b0;
    #3472
    data1 = 1'b1;
    #3472
    data1 = 1'b0;
    #3472
    data1 = 1'b1;
    #3472
    data1 = 1'b1;
end
//生成时钟
always #1 sys_clk = ~sys_clk ;

uart_recv  u_uart_recv(
    .clk     (sys_clk),
    .sys_rst_n (sys_rst_n),
    .uart_rx  (data1),
    .uart_done (done),
    .uart_data   (data)
);
endmodule
