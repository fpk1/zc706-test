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
    input              clk,    //ϵͳʱ��    
                                        
    input              sys_rst_n,    //ϵͳ��λ���͵�ƽ��Ч
    
    input              recv_done,    //����һ֡������ɱ�־
    input    [7:0]     recv_data,    //���յ����� 
    
    input              tx_busy,      //����æ״̬��־ 
    output   reg       send_en,      //����ʹ���ź� 
    output   reg [7:0] send_data     //�����͵�����
       
    );
   
    reg  recv_done_d0;
    reg  recv_done_d1;
    reg  tx_ready;
   
    wire recv_done_flag;
   
	
    //����recv_done �����أ��õ�һ��ʱ�����ڵ������ź�
    assign recv_done_flag = (~recv_done_d1 ) & recv_done_d0 ;
    
    //�Է���ʹ���ź�recv_done������ 
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
    
    //�жϽ�������źţ����ڴ��ڷ���ģ�����ʱ��������ʹ���ź� 
    always @(posedge clk or negedge sys_rst_n )begin 
        if(!sys_rst_n )begin 
            tx_ready <= 1'b0;
            send_en <= 1'b0;
            send_data <= 8'd0;
        end 
        else begin 
            if(recv_done_flag )begin         //��⴮�ڽ��յ�����
                tx_ready <= 1'b1;            //׼���������͹��� 
                send_en  <= 1'b0;
                send_data <= recv_data;      //�Ĵ洮�ڽ��յ�����
            end
            else if(tx_ready && (~tx_busy ))begin   //��⴮�ڷ���ģ����� 
                tx_ready <= 1'b0;                   //׼�����̽��� 
                send_en <= 1'b1;                    //���߷���ʹ���ź�
            end 
        end 
    end 
	
	
endmodule
