`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2024 19:24:17
// Design Name: 
// Module Name: audio_processing_system
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


module audio_array_processing(
    input clk_p,
    input clk_n,
    output [47:0]results,
    output [9:0]delay_results,
    output [9:0]angle
    );
    wire clk ;
    IBUFDS IBUFDS_inst (
    .O(clk), // Buffer output
    .I(clk_p), // Diff_p buffer input (connect directly
    .IB(clk_n) // Diff_n buffer input (connect directly to
    );
    
    reg [9:0]delay_counter=0;
    
    
    wire [9:0]addr_mem1_in;
    reg [9:0]addr_mem1_out=0;
    wire [15:0]dout_mem1;
    wire [15:0]din_mem1;
    blk_mem_gen_1 mem1(
    .clka(clk),
    .wea(1'b1),
    .addra(addr_mem1_in),
    .dina(din_mem1),
    
    .clkb(clk),
    .addrb(addr_mem1_out),
    .doutb(dout_mem1)
    );
    
    
    wire [9:0]addr_mem2_in;
    reg [10:0]addr_mem2_out=0;
    wire [15:0]dout_mem2;
    wire [15:0]din_mem2;
    
    blk_mem_gen_0 mem2(
    .clka(clk),
    .wea(1'b1),
    .addra(addr_mem2_in),
    .dina(din_mem2),
    
    .clkb(clk),
    .addrb(addr_mem2_out[9:0]),
    .doutb(dout_mem2)
    
    );
    
    reg [9:0]delay_result=0;
    assign delay_results = delay_result;
    reg [47:0]best_result=0;
    assign results=best_result;
    reg [47:0]temp_result=0;
    
    wire [31:0]mult_result;
    
    always@( posedge clk)
    
    if (delay_counter==10'b1111111111)
        begin
            delay_counter<=0;
            addr_mem2_out<=0;
            addr_mem1_out<=0;
            temp_result<=0;
        end
    else
        begin
            if (addr_mem1_out==10'b1111111111)
                begin
                if(temp_result>best_result)
                    begin
                        best_result<=temp_result;
                        delay_result<=delay_counter;
                        delay_counter<=delay_counter+1;
                        addr_mem1_out<=0;
                        addr_mem2_out<=delay_counter;
                        temp_result<=0;
                    end
                else
                    begin
                        best_result<=best_result;
                        delay_result<=delay_result;
                        delay_counter<=delay_counter+1;
                        addr_mem1_out<=0;
                        addr_mem2_out<=delay_counter;
                        temp_result<=0;
                    end
                end          
            else
                begin
                addr_mem1_out<=addr_mem1_out+1;
                addr_mem2_out<=addr_mem2_out+1;
                temp_result<=temp_result+mult_result;
                end
        end
       
       mult_gen_0 mult0(
       .CLK(clk),
       .A(dout_mem1),
       .B(dout_mem2),
       .P(mult_result)
       );
    
    parameter Rx_distance = 1024; //3.4cm
    
    
    blk_mem_gen_2 arcsin(
    .clka(clk),
    .addra(delay_result),
    .douta(angle)
    );
endmodule
