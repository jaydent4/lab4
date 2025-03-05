`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2025 05:18:44 AM
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rst,
    output hsync,
    output vsync,
    output [11:0] rgb
    );
    
    wire [9:0] x, y;
    wire video_on, p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    vga_controller vga(.clk(clk), .rst(rst), .hsync(hsync), .vsync(vsync), .video_on(video_on), .p_tick(p_tick), .x(x), .y(y));
    
    wire [15:0] num_string;
    assign num_string = 16'b0001001000110100;
    
    ascii_test(.clk(clk), .video_on(video_on), .x(x), .y(y), .num_string(num_string), .rgb(rgb_next));
    
    always @(posedge clk)
        if (p_tick)
            rgb_reg = rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule
