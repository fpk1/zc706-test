`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/02 10:41:13
// Design Name: 
// Module Name: uart_loop
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


module uart_loop(
    input              clk,    //系统时钟    
                                        
    input              sys_rst_n,    //系统复位，低电平有效
    
    input              recv_done,    //接收一帧数据完成标志
    input    [7:0]     recv_data,    //接收的数据 
    
    input              tx_busy,      //发送忙状态标志 
    output   reg       send_en,      //发送使能信号 
    output   reg [7:0] send_data     //待发送的数据
       
    );
   
    reg  recv_done_d0;
    reg  recv_done_d1;
    reg  tx_ready;
   
    wire recv_done_flag;
   
	
    //捕获recv_done 上升沿，得到一个时钟周期的脉冲信号
    assign recv_done_flag = (~recv_done_d1 ) & recv_done_d0 ;
    
    //对发送使能信号recv_done打两拍 
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            recv_done_d0 <= 1'b0;
            recv_done_d1 <= 1'b0;
        end
        else begin 
            recv_done_d0 <= recv_done ;
            recv_done_d1 <= recv_done_d0 ;
         end
    end
    
    //判断接收完成信号，并在串口发送模块空闲时给出发送使能信号 
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            tx_ready <= 1'b0;
            send_en <= 1'b0;
            send_data <= 8'd0;
        end 
        else begin 
            if(recv_done_flag )begin         //检测串口接收到数据
                tx_ready <= 1'b1;            //准备启动发送过程 
                send_en  <= 1'b0;
                send_data <= recv_data;      //寄存串口接收的数据
            end
            else if(tx_ready && (~tx_busy ))begin   //检测串口发送模块空闲 
                tx_ready <= 1'b0;                   //准备过程结束 
                send_en <= 1'b1;                    //拉高发送使能信号
            end 
        end 
    end 
	
	
endmodule
