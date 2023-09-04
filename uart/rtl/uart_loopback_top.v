`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/02 11:16:11
// Design Name: 
// Module Name: uart_loopback_top
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


module uart_loopback_top(
        input              sys_clk_p,    //系统时钟
        input              sys_clk_n,    
//        input              clk,                                
        input              key,          //利用的按键来做系统复位按键，但他默认是低电平，按下是高电平，
                                         //所以取反后作为系统复位，低电平有效
        input              uart_rxd,     //uart 接收端口 
        output             uart_txd      //uart 发送端口
    );
    
    parameter CLK_FREQ = 200_000_000;   //定义系统时钟频率 
    parameter UART_BPS = 115200;        //定义串口波特率 
    
    wire        uart_recv_done;         //UART接收完成 
    wire  [7:0] uart_recv_data;         //UART接收数据 
    wire        uart_send_en;           //UART发送使能 
    wire  [7:0] uart_send_data;         //UART发送数据 
    wire        uart_tx_busy;           //UART发送忙状态标志 
    wire		clk;		            //系统时钟	
    wire        sys_rst_n;              //系统复位 
    //clk
    IBUFGDS	refclk_ibuf	(.I(sys_clk_p),.IB(sys_clk_n),.O(clk));//将差分时钟缓冲，输出200M单端时钟 
    assign sys_rst_n = ~key ;
    uart_recv #(
        .CLK_FREQ  (CLK_FREQ ),
        .UART_BPS  (UART_BPS )
    )  u_uart_recv(
        .clk   (clk ),
        
        .sys_rst_n   (sys_rst_n ),
        
        .uart_rx    (uart_rxd ),
        .uart_done   (uart_recv_done ),
        .uart_data   (uart_recv_data )
    );
    
    uart_send #(
        .CLK_FREQ    (CLK_FREQ ),
        .UART_BPS    (UART_BPS )
    )  u_uart_send(
        .clk   (clk ),
        
        .sys_rst_n   (sys_rst_n ),
        
        .uart_en     (uart_send_en ),
        .uart_din    (uart_send_data ),
        .uart_tx_busy (uart_tx_busy ),
        .uart_txd     (uart_txd )
    );
    
    uart_loop u_uart_loop(
        .clk   (clk ),
        
        .sys_rst_n        (sys_rst_n ),
        
        .recv_data        (uart_recv_data ),
        .recv_done        (uart_recv_done ),
        
        .tx_busy          (uart_tx_busy ),
        .send_en          (uart_send_en ),
        .send_data        (uart_send_data )
        
    );
endmodule
