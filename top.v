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
//  Top-level module integrating VGA controller, keypad, 5-digit text input, and ASCII display.
// Dependencies: 
//  vga_controller, keypad, five_digit_text, ascii_test
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top(
    input clk,            // Clock input
    input rst,            // Reset input
    inout [7:0] JA,       // Keypad input/output
    output hsync,         // VGA horizontal sync
    output vsync,         // VGA vertical sync
    output [11:0] rgb     // VGA color output
    );
    
    // Signals for VGA
    wire [9:0] x, y;          // VGA coordinates
    wire video_on, p_tick;    // Video signal and pixel tick
    reg [11:0] rgb_reg;       // RGB color register (to latch the color value)
    wire [11:0] rgb_next;     // RGB color output from ascii_test
    
    // Signals for Keypad
    wire [3:0] key;           // Current key pressed
    wire key_pressed;
    
    // Wire for num_string (the 5-digit number)
    wire [19:0] num_string;    // 5-digit input in a 20-bit register

    // Instantiate the VGA controller
    vga_controller vga(
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .p_tick(p_tick),
        .x(x),
        .y(y)
    );
    
    // Instantiate the Keypad controller
    keypad keypad(
        .clk(clk),
        .col(JA[3:0]),       // Column signals from keypad
        .row(JA[7:4]),       // Row signals from keypad
        .key_pressed(key_pressed),
        .key(key)          // Current key pressed
    );
    
    // Instantiate the 5-digit text input storage module
    five_digit_text fdt(
        .clk(clk),
        .key(key),
        .key_pressed(key_pressed),
        .num_string(num_string)
    );
    
    // Instantiate the ASCII display module
    ascii_test ascii_test(
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .show_number(1),      // Display the number on screen
        .num_string(num_string),
        .rgb(rgb_next)        // Output color for the current pixel
    );
    
    // Latch the RGB value from the ASCII display module when the pixel tick is active
    always @(posedge clk) begin
        if (p_tick) begin
            rgb_reg <= rgb_next;  // Update RGB register on each pixel tick
        end
    end
    
    // Output the RGB value to the VGA output
    assign rgb = rgb_reg;

endmodule
