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
        input              sys_clk_p,    //ϵͳʱ��
        input              sys_clk_n,    
//        input              clk,                                
        input              key,          //���õİ�������ϵͳ��λ����������Ĭ���ǵ͵�ƽ�������Ǹߵ�ƽ��
                                         //����ȡ������Ϊϵͳ��λ���͵�ƽ��Ч
        input              uart_rxd,     //uart ���ն˿� 
        output             uart_txd      //uart ���Ͷ˿�
    );
    
    parameter CLK_FREQ = 200_000_000;   //����ϵͳʱ��Ƶ�� 
    parameter UART_BPS = 115200;        //���崮�ڲ����� 
    
    wire        uart_recv_done;         //UART������� 
    wire  [7:0] uart_recv_data;         //UART�������� 
    wire        uart_send_en;           //UART����ʹ�� 
    wire  [7:0] uart_send_data;         //UART�������� 
    wire        uart_tx_busy;           //UART����æ״̬��־ 
    wire		clk;		            //ϵͳʱ��	
    wire        sys_rst_n;              //ϵͳ��λ 
    //clk
    IBUFGDS	refclk_ibuf	(.I(sys_clk_p),.IB(sys_clk_n),.O(clk));//�����ʱ�ӻ��壬���200M����ʱ�� 
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
