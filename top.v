`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2025 10:42:20 AM
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
    input wire clk,            // System clock
    input wire rst,            // Reset signal (active high)
    output wire [3:0] keypad_row,  // Keypad row outputs
    input wire [3:0] keypad_col,   // Keypad column inputs
    output wire [6:0] segments,    // 7-segment display segments
    output wire [3:0] digit_sel,    // 7-segment display digit selector
    output hsync,         // VGA horizontal sync
    output vsync,         // VGA vertical sync
    output [11:0] rgb     // VGA color output
    );
    
    // Wire, register declarations
    // VGA
    wire [9:0] x, y;          // VGA coordinates
    wire video_on, p_tick;    // Video signal and pixel tick
    reg [11:0] rgb_reg;       // RGB color register (to latch the color value)
    wire [11:0] rgb_next;     // RGB color output from ascii_test
    
    // Keypad
    wire [3:0] keypad_value;
    wire key_pressed;
    
    // Seven Segment Display
    reg [13:0] display_value;
    
    // RNG
    wire [19:0] random_num;
    reg [19:0] random_seed; 
    
    // Game Parameters and Values
    // Game states
    localparam IDLE = 2'b00;             // Waiting for difficulty selection
    localparam DISPLAY_SEQUENCE = 2'b01; // Displaying the sequence
    localparam WAIT_INPUT = 2'b10;       // Waiting for player input
    localparam GAME_OVER = 2'b11;        // Game over, displaying score
    
    // Difficulty levels
    localparam EASY = 2'b00;
    localparam MEDIUM = 2'b01;
    localparam HARD = 2'b10;
    
    // Constants
    localparam MAX_SEQUENCE_LENGTH = 100; // Maximum possible sequence length TODO
    
    // Internal registers and wires
    reg [1:0] game_state;
    reg [1:0] difficulty;
    reg [13:0] score; // 0-9999
    reg [3:0] current_sequence [0:MAX_SEQUENCE_LENGTH-1];
    reg [6:0] sequence_length;
    reg [6:0] display_index;
    reg [6:0] input_index;
    reg [3:0] input_buffer;
    reg [31:0] timer_count;
    
    // Submodule instantiations
    keypad keypad (
        .clk(clk),
        .rst(rst),
        .row(keypad_row),
        .col(keypad_col),
        .value(keypad_value),
        .key_pressed(key_pressed)
    );
    
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
    
    ascii_display ascii_display(
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .show_number(1),     
        .num_string(num_string),
        .rgb(rgb_next)       
    );
    
    // Latch the RGB value from the ASCII display module when the pixel tick is active
    always @(posedge clk or posedge rst) begin
        if (p_tick) begin
            rgb_reg <= rgb_next;  // Update RGB register on each pixel tick
        end
    end
    
    // Output the RGB value to the VGA output
    assign rgb = rgb_reg;
    
    
    
endmodule
