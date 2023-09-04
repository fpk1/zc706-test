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
    input              clk,   //ϵͳʱ��  
    input              sys_rst_n,   //ϵͳ��λ���͵�ƽ��Ч
    input              uart_rx,     //UART���ն˿�

    output reg         uart_done,   //����һ֡������ɱ�־
    output reg  [7:0]  uart_data    //���ܵ�����
    );
    //parameter define
    parameter CLK_FREQ = 200_000_000;   //ϵͳʱ��Ƶ��
    parameter UART_BPS = 115200;        //���ڲ�����
    
    parameter BPS_CNT = CLK_FREQ /UART_BPS ;  //Ϊ�õ�ָ�������ʣ�ʱ����Ҫ�Ƶ���
                                              //��Ҫ��ϵͳʱ������BPS_CNT��
    reg        uart_rxd_d0;
    reg        uart_rxd_d1;
    
    reg [15:0] clk_cnt;              //ϵͳʱ�Ӽ�����
    reg [3:0]  rx_cnt;               //�������ݼ����� 
    reg        rx_flag;              //���ܹ��̱�־�ź�  
    reg [7:0]  rxdata;               //�������ݼĴ���
    wire       start_flag;
//������ն˿��½��أ���ʼλ�����õ�һ��ʱ�����ڵ������ź�  
assign start_flag = uart_rxd_d1 & (~uart_rxd_d0 );  
    
    //��UART���ն˿ڵ������ӳ�����ʱ������
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
    
   //�������ź�start_flag����ʱ��������չ��� 
    always @(posedge clk or negedge sys_rst_n )begin
        if(!sys_rst_n )begin
            rx_flag <= 0;
        end
        else if(start_flag )           //��⵽��ʼλ
            rx_flag <=1'b1;            //������ܹ��̣���־λrx_flag����
        else if((rx_cnt == 4'd9)&&(clk_cnt ==BPS_CNT /2))     //������ֹͣλ�м�ʱ��ֹͣ���ܹ���
            rx_flag <= 1'b0;           //���ܹ��̽�������־λrx_flag����
        else
            rx_flag <= rx_flag;     
            
    end
    
    //������չ��̺�����ϵͳʱ�Ӽ�����
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin
            clk_cnt =16'b0;
        end
        else if(rx_flag )begin            //���ڽ��չ���
            if(clk_cnt ==BPS_CNT -1) 
                clk_cnt <=16'b0;          //��ϵͳʱ�Ӽ����ﵽһ�����������ں�����
            else
                clk_cnt <= clk_cnt +1;      
        end 
        else
                clk_cnt <= 16'b0;        //���չ��̽���������������
    end
    
    //������չ��̺������������ݼ�����
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            rx_cnt <=4'b0;
        end
        else if(rx_flag )begin               //���ڽ��չ���
            if(clk_cnt ==   BPS_CNT -1)      //ϵͳʱ�Ӽ�����һ������������ʱ���������ݼ�������1
                rx_cnt <= rx_cnt +1'b1;
            else 
                rx_cnt <=rx_cnt ;        
        end
        else
            rx_cnt <=4'b0;                   //���չ��̽���������������
    end
    
    //���ݽ������ݼ��������Ĵ�uart���ն˿�����
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            rxdata <=8'd0;
        end
        else if(rx_flag)                                   //ϵͳ���ڽ��չ���
            if(clk_cnt == BPS_CNT/2)begin                  //�ж�ϵͳʱ�Ӽ����������Ƿ�����λ�м�
                case (rx_cnt )
                    4'd1: rxdata[0] <=uart_rxd_d1 ;        //�Ĵ�����λ���λ
                    4'd2: rxdata[1] <=uart_rxd_d1 ;
                    4'd3: rxdata[2] <=uart_rxd_d1 ;
                    4'd4: rxdata[3] <=uart_rxd_d1 ;
                    4'd5: rxdata[4] <=uart_rxd_d1 ;
                    4'd6: rxdata[5] <=uart_rxd_d1 ;
                    4'd7: rxdata[6] <=uart_rxd_d1 ;
                    4'd8: rxdata[7] <=uart_rxd_d1 ;       //�Ĵ�����λ���λ
                    default:; 
                 endcase                
            end
            else
                rxdata <= rxdata ;
         else 
         rxdata = 8'd0;
    end
   
   //���ݽ�����Ϻ������־�źŲ��Ĵ�������յ������� 
   always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            uart_data <=8'd0;
            uart_done <=1'd0;
        end 
        else if(rx_cnt == 4'd9)begin    //�������ݼ�����������ֹͣλ
            uart_data <= rxdata ;       //�Ĵ�������յ�������
            uart_done <= 1'd1;          //����������ɱ�־λ����
        end 
        else begin 
            uart_data <= 8'd0;
            uart_done <=1'd0;
        end 
   end 
endmodule
