module ascii_test(
    input clk,
    input video_on,
    input [9:0] x, y,
    input [15:0] num_string, // 4-digit input (e.g., 1234)
    output reg [11:0] rgb
);

    // Signal Declarations
    wire [10:0] rom_addr;
    wire [6:0] ascii_char;
    wire [3:0] char_row;
    wire [2:0] bit_addr;
    wire [7:0] rom_data;
    wire ascii_bit, ascii_bit_on;

    // Instantiate ASCII ROM
    ascii_rom rom(.clk(clk), .addr(rom_addr), .data(rom_data));

    // Extract individual digits from the 4-digit number
    wire [6:0] num_ascii[3:0];
    assign num_ascii[3] = 7'h30 + (num_string[15:12]); // 1st digit
    assign num_ascii[2] = 7'h30 + (num_string[11:8]);  // 2nd digit
    assign num_ascii[1] = 7'h30 + (num_string[7:4]);   // 3rd digit
    assign num_ascii[0] = 7'h30 + (num_string[3:0]);   // 4th digit

    // Character Selection (limit to 4-digit display)
    wire [1:0] char_index = (x[7:3] < 4) ? x[7:3] : 0;
    assign ascii_char = num_ascii[char_index];

    // ASCII ROM Interface
    assign rom_addr = {ascii_char, char_row};
    assign ascii_bit = rom_data[~bit_addr];

    // Pixel Mapping
    assign char_row = y[3:0];
    assign bit_addr = x[2:0];

    // Display region (top-left)
    assign ascii_bit_on = ((x >= 50 && x < 130) && (y >= 20 && y < 40)) ? ascii_bit : 1'b0;

    // Color Output
    always @*
        if (~video_on)
            rgb = 12'h000;   // Black screen when video is off
        else if (ascii_bit_on)
            rgb = 12'h00F;   // Blue numbers
        else
            rgb = 12'hFFF;   // White background

endmodule