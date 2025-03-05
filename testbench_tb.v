// Testbench - memorization_game_tb.v
`timescale 1ns / 1ps

module memorization_game_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg [3:0] keypad_col;
    wire [3:0] keypad_row;
    wire [6:0] segments;
    wire [3:0] digit_sel;
    
    // DUT instantiation
    memorization_game dut (
        .clk(clk),
        .rst(rst),
        .keypad_row(keypad_row),
        .keypad_col(keypad_col),
        .segments(segments),
        .digit_sel(digit_sel)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end
    
    // Test stimulus
    initial begin
        // Initialize
        rst = 1;
        keypad_col = 4'b1111;
        
        // Reset
        #100;
        rst = 0;
        #100;
        
        // Test sequence - simulate key presses
        
        // Press 'A' (Easy difficulty)
        SimulateKeyPress(4'd10);  // A key - 3rd column, 1st row
        #1000000; // Wait for game to start
        
        // First sequence number should be displayed and then wait for input
        #5000000;
        
        // Assume the first number is 5 (just an example, will be random in actual implementation)
        // Press '5'
        SimulateKeyPress(4'd5);  // 5 key - 2nd column, 2nd row
        #500000;
        
        // Press 'D' to submit
        SimulateKeyPress(4'd13); // D key - 4th column, 4th row
        #1000000;
        
        // Game should now display two numbers
        #10000000;
        
        // Test incorrect input to trigger game over
        SimulateKeyPress(4'd9);  // 9 key - wrong input
        #500000;
        
        // Press 'D' to submit
        SimulateKeyPress(4'd13); // D key - 4th column, 4th row
        #1000000;
        
        // Game should now display score and wait for restart
        #5000000;
        
        // Press 'B' to restart with medium difficulty
        SimulateKeyPress(4'd11); // B key - 4th column, 2nd row
        
        // Let simulation run for a while
        #20000000;
        
        $finish;
    end
    
    // Task to simulate key press
    task SimulateKeyPress;
        input [3:0] key;
        begin
            case (key)
                // Row 1 (0111)
                4'd1: begin
                    wait (keypad_row == 4'b0111);
                    keypad_col = 4'b1110; // Column 1
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd2: begin
                    wait (keypad_row == 4'b0111);
                    keypad_col = 4'b1101; // Column 2
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd3: begin
                    wait (keypad_row == 4'b0111);
                    keypad_col = 4'b1011; // Column 3
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd10: begin // A key
                    wait (keypad_row == 4'b0111);
                    keypad_col = 4'b0111; // Column 4
                    #500000;
                    keypad_col = 4'b1111;
                end
                
                // Row 2 (1011)
                4'd4: begin
                    wait (keypad_row == 4'b1011);
                    keypad_col = 4'b1110; // Column 1
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd5: begin
                    wait (keypad_row == 4'b1011);
                    keypad_col = 4'b1101; // Column 2
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd6: begin
                    wait (keypad_row == 4'b1011);
                    keypad_col = 4'b1011; // Column 3
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd11: begin // B key
                    wait (keypad_row == 4'b1011);
                    keypad_col = 4'b0111; // Column 4
                    #500000;
                    keypad_col = 4'b1111;
                end
                
                // Row 3 (1101)
                4'd7: begin
                    wait (keypad_row == 4'b1101);
                    keypad_col = 4'b1110; // Column 1
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd8: begin
                    wait (keypad_row == 4'b1101);
                    keypad_col = 4'b1101; // Column 2
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd9: begin
                    wait (keypad_row == 4'b1101);
                    keypad_col = 4'b1011; // Column 3
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd12: begin // C key
                    wait (keypad_row == 4'b1101);
                    keypad_col = 4'b0111; // Column 4
                    #500000;
                    keypad_col = 4'b1111;
                end
                
                // Row 4 (1110)
                4'd14: begin // * key
                    wait (keypad_row == 4'b1110);
                    keypad_col = 4'b1110; // Column 1
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd0: begin
                    wait (keypad_row == 4'b1110);
                    keypad_col = 4'b1101; // Column 2
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd15: begin // # key
                    wait (keypad_row == 4'b1110);
                    keypad_col = 4'b1011; // Column 3
                    #500000;
                    keypad_col = 4'b1111;
                end
                4'd13: begin // D key
                    wait (keypad_row == 4'b1110);
                    keypad_col = 4'b0111; // Column 4
                    #500000;
                    keypad_col = 4'b1111;
                end
            endcase
        end
    endtask
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t, Digit Select=%b, Segments=%b", $time, digit_sel, segments);
    end

endmodule

