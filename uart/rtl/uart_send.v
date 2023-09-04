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
    input              clk,    //ϵͳʱ��
 
    input              sys_rst_n,    //ϵͳ��λ���͵�ƽ��Ч
                                     
    input              uart_en,      //����ʹ���ź�
    input    [7:0]     uart_din,     //����������
                                     
    output             uart_tx_busy, //����æ״̬��־ 
    output   reg       uart_txd      //UART���Ͷ˿�   
    );
    
    
     //parameter define
    parameter CLK_FREQ = 200_000_000;   //ϵͳʱ��Ƶ��
    parameter UART_BPS = 115200;        //���ڲ�����
    
    parameter BPS_CNT = CLK_FREQ /UART_BPS ;  //Ϊ�õ�ָ�������ʣ�ʱ����Ҫ�Ƶ���
                                              //��Ҫ��ϵͳʱ�Ӽ���BPS_CNT��
    
    //  reg define ���Է���ʹ���źŴ�2�ĵ�Ŀ���ǻ��������
    reg           uart_en_d0;
    reg           uart_en_d1;
    
    reg   [15:0]  clk_cnt;      //ϵͳʱ�Ӽ����� 
    reg   [3:0]   tx_cnt;       //�������ݼ����� 
    reg           tx_flag;      //���͹��̱�־�ź� 
    reg   [7:0]   tx_data;      //�Ĵ淢������  
    
    //wire define 
    wire en_flag;
    
    assign uart_tx_busy = tx_flag ;
    
    //�Է���ʹ���źŴ����ģ�Ŀ������������
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
     
    //�Է���ʹ���ź��Լ��������ݼ����������жϣ�    
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            tx_flag  <= 1'b0;
            tx_data <=7'd0;
         end   
        else if(en_flag ==1'b1 & tx_cnt ==4'd0 )begin                      //�ж������Ƿ���Է���
            tx_flag  <= 1'b1  ;
            tx_data <= uart_din  ;
         end
        else if((tx_cnt == 4'd9)&&(clk_cnt ==BPS_CNT -(BPS_CNT/16 )))begin   //�ж������Ƿ������
            tx_flag <= 1'b0 ;
            tx_data <= 8'd0 ;
         end
        else begin  
            tx_flag <=tx_flag ;
            tx_data <=tx_data ;
         end
    end
    
    //��ʱ�ӽ��м���
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )
            clk_cnt <=16'b0;
        else if(tx_flag )begin 
            if(clk_cnt < (BPS_CNT-1) )   //���1����Ϊclk_cnt�ı仯ֻ������һ�������ز��ܼ�⵽
                clk_cnt <= clk_cnt +1;
            else
                clk_cnt <= 16'b0;
        end
        else 
            clk_cnt <= 16'b0;    
    end
    
    //����ʱ�Ӽ���ֵ�����ķ������ݱ�־λ
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
    //��������
    always @(posedge clk or negedge sys_rst_n )begin
        if(!sys_rst_n )
            uart_txd <= 1'd1;
        else if(tx_flag )
                case (tx_cnt )
                    4'd0: uart_txd <= 1'd0;
                    4'd1: uart_txd <= tx_data[0]  ;        //�Ĵ�����λ���λ
                    4'd2: uart_txd <= tx_data[1] ;
                    4'd3: uart_txd <= tx_data[2] ;
                    4'd4: uart_txd <= tx_data[3] ;
                    4'd5: uart_txd <= tx_data[4] ;
                    4'd6: uart_txd <= tx_data[5] ;
                    4'd7: uart_txd <= tx_data[6] ;
                    4'd8: uart_txd <= tx_data[7] ;       //�Ĵ�����λ���λ
                    4'd9: uart_txd <= 1'b1 ;       //�Ĵ�����λ���λ
                    default:; 
                endcase 
         else 
            uart_txd <=1'd1;                   
    end
    
endmodule
