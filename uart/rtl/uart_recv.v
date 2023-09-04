`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/31 17:29:42
// Design Name: 
// Module Name: uart
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


module uart_recv(
    input              clk,   //系统时钟  
    input              sys_rst_n,   //系统复位，低电平有效
    input              uart_rx,     //UART接收端口

    output reg         uart_done,   //接收一帧数据完成标志
    output reg  [7:0]  uart_data    //接受的数据
    );
    //parameter define
    parameter CLK_FREQ = 200_000_000;   //系统时钟频率
    parameter UART_BPS = 115200;        //串口波特率
    
    parameter BPS_CNT = CLK_FREQ /UART_BPS ;  //为得到指定波特率，时钟需要计的数
                                              //需要对系统时钟奇数BPS_CNT次
    reg        uart_rxd_d0;
    reg        uart_rxd_d1;
    
    reg [15:0] clk_cnt;              //系统时钟计数器
    reg [3:0]  rx_cnt;               //接受数据计数器 
    reg        rx_flag;              //接受过程标志信号  
    reg [7:0]  rxdata;               //接受数据寄存器
    wire       start_flag;
//捕获接收端口下降沿（起始位），得到一个时钟周期的脉冲信号  
assign start_flag = uart_rxd_d1 & (~uart_rxd_d0 );  
    
    //对UART接收端口的数据延迟两个时钟周期
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            uart_rxd_d0 <= 1'b0;
            uart_rxd_d1 <= 1'b0;
        end
        else begin
            uart_rxd_d0 <=uart_rx;
            uart_rxd_d1 <=uart_rxd_d0;
        end      
    end 
    
   //当脉冲信号start_flag到达时，进入接收过程 
    always @(posedge clk or negedge sys_rst_n )begin
        if(!sys_rst_n )begin
            rx_flag <= 0;
        end
        else if(start_flag )           //检测到起始位
            rx_flag <=1'b1;            //进入接受过程，标志位rx_flag拉高
        else if((rx_cnt == 4'd9)&&(clk_cnt ==BPS_CNT /2))     //计数到停止位中间时，停止接受过程
            rx_flag <= 1'b0;           //接受过程结束，标志位rx_flag拉低
        else
            rx_flag <= rx_flag;     
            
    end
    
    //进入接收过程后，启动系统时钟计数器
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin
            clk_cnt =16'b0;
        end
        else if(rx_flag )begin            //处于接收过程
            if(clk_cnt ==BPS_CNT -1) 
                clk_cnt <=16'b0;          //对系统时钟计数达到一个波特率周期后清理
            else
                clk_cnt <= clk_cnt +1;      
        end 
        else
                clk_cnt <= 16'b0;        //接收过程结束，计数器清零
    end
    
    //进入接收过程后，启动接收数据计数器
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            rx_cnt <=4'b0;
        end
        else if(rx_flag )begin               //处于接收过程
            if(clk_cnt ==   BPS_CNT -1)      //系统时钟计数达一个波特率周期时，接收数据计数器加1
                rx_cnt <= rx_cnt +1'b1;
            else 
                rx_cnt <=rx_cnt ;        
        end
        else
            rx_cnt <=4'b0;                   //接收过程结束，计数器清零
    end
    
    //根据接收数据计数器来寄存uart接收端口数据
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            rxdata <=8'd0;
        end
        else if(rx_flag)                                   //系统处于接收过程
            if(clk_cnt == BPS_CNT/2)begin                  //判断系统时钟计数器计数是否到数据位中间
                case (rx_cnt )
                    4'd1: rxdata[0] <=uart_rxd_d1 ;        //寄存数据位最低位
                    4'd2: rxdata[1] <=uart_rxd_d1 ;
                    4'd3: rxdata[2] <=uart_rxd_d1 ;
                    4'd4: rxdata[3] <=uart_rxd_d1 ;
                    4'd5: rxdata[4] <=uart_rxd_d1 ;
                    4'd6: rxdata[5] <=uart_rxd_d1 ;
                    4'd7: rxdata[6] <=uart_rxd_d1 ;
                    4'd8: rxdata[7] <=uart_rxd_d1 ;       //寄存数据位最高位
                    default:; 
                 endcase                
            end
            else
                rxdata <= rxdata ;
         else 
         rxdata = 8'd0;
    end
   
   //数据接收完毕后给出标志信号并寄存输出接收到的数据 
   always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            uart_data <=8'd0;
            uart_done <=1'd0;
        end 
        else if(rx_cnt == 4'd9)begin    //接收数据计数器计数到停止位
            uart_data <= rxdata ;       //寄存输出接收到的数据
            uart_done <= 1'd1;          //并将接收完成标志位拉高
        end 
        else begin 
            uart_data <= 8'd0;
            uart_done <=1'd0;
        end 
   end 
endmodule
