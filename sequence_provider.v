module sequence_provider (
    input wire clk,
    input wire rst,
    input wire next_sequence,
    output reg [19:0] sequence_out
);

    // Define some test cases of 5-digit decimal numbers
    reg [19:0] test_sequences [0:2];  // 3 sequences of 5 digits each
    integer i;

    // Initialize test sequences
    initial begin
        test_sequences[0] = 20'd12345;  // 5-digit number: 12345
        test_sequences[1] = 20'd67890;  // 5-digit number: 67890
        test_sequences[2] = 20'd54321;  // 5-digit number: 54321
    end

    // Pointer to the current test case in the sequence array
    reg [1:0] seq_idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sequence_out <= 20'd0;  // Reset sequence to 0
            seq_idx <= 2'b00;       // Start from the first test case
        end else if (next_sequence) begin
            // Select the next sequence based on the test case index
            sequence_out <= test_sequences[seq_idx];
            
            // Cycle through the test cases
            if (seq_idx == 2'b10) begin
                seq_idx <= 2'b00; // Loop back to the first test case
            end else begin
                seq_idx <= seq_idx + 1;
            end
        end
    end

endmodule
