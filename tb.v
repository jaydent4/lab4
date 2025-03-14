`timescale 1ns / 1ps

module memorization_game_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg [3:0] keypad_col;  // Columns input to simulate key press
    wire [3:0] keypad_row; // Rows output from memorization_game
    wire [6:0] segments;
    wire [3:0] digit_sel;
    wire hsync;
    wire vsync;
    wire [11:0] rgb;

    // Instantiate the memorization_game module
    memorization_game uut (
        .clk(clk),
        .rst(rst),
        .keypad_row(keypad_row),
        .keypad_col(keypad_col),
        .segments(segments),
        .digit_sel(digit_sel),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

    // Clock generation
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, memorization_game_tb);
    end

    // Initial block to apply resets and simulate key presses
    initial begin
        // Initialize inputs
        rst = 0;
        keypad_col = 4'b1111;  // No key pressed initially

        // Apply reset
        #10 rst = 1;  // Apply reset for 10ns
        #10 rst = 0;  // Release reset

        // Test case: Simulate pressing "12345"
        
        // Press key "1" (Row 0, Column 0) - Easy difficulty

        keypad_col = 4'b1110;
        #1000
        // #20; 
        // while (keypad_row != 4'b0111) #2; // Wait for Row 0 to be active
        // keypad_col = 4'b0111; // Column 0 for Key "1"
        // #10 keypad_col = 4'b1111; // Release key
        // #20;
        
        // #20;
        // while (keypad_row != 4'b1110) #2; // F
        // keypad_col = 4'b1101;
        // #10 keypad_col = 4'b1111;
        // #20

        // // Press key "2" (Row 0, Column 1) - Medium difficulty
        // #20; 
        // while (keypad_row != 4'b0111) #5; // Wait for Row 0 to be active
        // #100 keypad_col = 4'b1101; // Column 1 for Key "2"
        // #10 keypad_col = 4'b1111; // Release key
        // #20;

        // // Press key "3" (Row 0, Column 2) - Hard difficulty
        // #20;
        // while (keypad_row != 4'b0111) #5; // Wait for Row 0 to be active
        // #100 keypad_col = 4'b1011; // Column 2 for Key "3"
        // #10 keypad_col = 4'b1111; // Release key
        // #20;

        // // Press key "4" (Row 1, Column 0) - Start game or another action
        // #20; 
        // while (keypad_row != 4'b1011) #5; // Wait for Row 1 to be active
        // #100 keypad_col = 4'b1110; // Column 0 for Key "4"
        // #10 keypad_col = 4'b1111; // Release key
        // #20;

        // // Press key "5" (Row 1, Column 1) - Another action in the game
        // #20; 
        // while (keypad_row != 4'b1011) #5; // Wait for Row 1 to be active
        // #100 keypad_col = 4'b1101; // Column 1 for Key "5"
        // #10 keypad_col = 4'b1111; // Release key
        // #20;

        // End simulation
        $finish;
    end

    // Monitoring outputs
    initial begin
        $monitor("Time: %0t, Game State: %b, Score: %d, Segments: %b", 
                 $time, uut.game_state, uut.score, segments);
    end

endmodule
