`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/01 15:41:04
// Design Name: 
// Module Name: uart_send
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


module uart_send(
    input              clk,    //系统时钟
 
    input              sys_rst_n,    //系统复位，低电平有效
                                     
    input              uart_en,      //发送使能信号
    input    [7:0]     uart_din,     //待发送数据
                                     
    output             uart_tx_busy, //发送忙状态标志 
    output   reg       uart_txd      //UART发送端口   
    );
    
    
     //parameter define
    parameter CLK_FREQ = 200_000_000;   //系统时钟频率
    parameter UART_BPS = 115200;        //串口波特率
    
    parameter BPS_CNT = CLK_FREQ /UART_BPS ;  //为得到指定波特率，时钟需要计的数
                                              //需要对系统时钟计数BPS_CNT次
    
    //  reg define ，对发送使能信号打2拍的目的是获得上升沿
    reg           uart_en_d0;
    reg           uart_en_d1;
    
    reg   [15:0]  clk_cnt;      //系统时钟计数器 
    reg   [3:0]   tx_cnt;       //发送数据计数器 
    reg           tx_flag;      //发送过程标志信号 
    reg   [7:0]   tx_data;      //寄存发送数据  
    
    //wire define 
    wire en_flag;
    
    assign uart_tx_busy = tx_flag ;
    
    //对发送使能信号打两拍，目的是找上升沿
    assign en_flag =uart_en_d0 &(!uart_en_d1 );
          
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            uart_en_d0 <= 1'b0;
            uart_en_d1 <= 1'b0;
        end
        else begin
            uart_en_d0 <= uart_en ;
            uart_en_d1 <= uart_en_d0 ;
        end    
    end 
     
    //对发送使能信号以及发送数据计数器进行判断，    
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            tx_flag  <= 1'b0;
            tx_data <=7'd0;
         end   
        else if(en_flag ==1'b1 & tx_cnt ==4'd0 )begin                      //判断数据是否可以发送
            tx_flag  <= 1'b1  ;
            tx_data <= uart_din  ;
         end
        else if((tx_cnt == 4'd9)&&(clk_cnt ==BPS_CNT -(BPS_CNT/16 )))begin   //判断数据是否发送完成
            tx_flag <= 1'b0 ;
            tx_data <= 8'd0 ;
         end
        else begin  
            tx_flag <=tx_flag ;
            tx_data <=tx_data ;
         end
    end
    
    //对时钟进行计数
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )
            clk_cnt <=16'b0;
        else if(tx_flag )begin 
            if(clk_cnt < (BPS_CNT-1) )   //这减1是因为clk_cnt的变化只有在下一个上升沿才能检测到
                clk_cnt <= clk_cnt +1;
            else
                clk_cnt <= 16'b0;
        end
        else 
            clk_cnt <= 16'b0;    
    end
    
    //根据时钟计数值，更改发送数据标志位
    always @(posedge clk or negedge sys_rst_n )begin 
       if(!sys_rst_n )
            tx_cnt <= 4'd0;
       else if(tx_flag )begin
            if(clk_cnt  ==(BPS_CNT -1))       
                if(tx_cnt < 4'd9)
                    tx_cnt <= tx_cnt +1'b1;
                else begin 
                    tx_cnt <= tx_cnt;
                end 
            end
        else
            tx_cnt <= 4'd0;
    end 
    //发送数据
    always @(posedge clk or negedge sys_rst_n )begin
        if(!sys_rst_n )
            uart_txd <= 1'd1;
        else if(tx_flag )
                case (tx_cnt )
                    4'd0: uart_txd <= 1'd0;
                    4'd1: uart_txd <= tx_data[0]  ;        //寄存数据位最低位
                    4'd2: uart_txd <= tx_data[1] ;
                    4'd3: uart_txd <= tx_data[2] ;
                    4'd4: uart_txd <= tx_data[3] ;
                    4'd5: uart_txd <= tx_data[4] ;
                    4'd6: uart_txd <= tx_data[5] ;
                    4'd7: uart_txd <= tx_data[6] ;
                    4'd8: uart_txd <= tx_data[7] ;       //寄存数据位最高位
                    4'd9: uart_txd <= 1'b1 ;       //寄存数据位最高位
                    default:; 
                endcase 
         else 
            uart_txd <=1'd1;                   
    end
    
endmodule
