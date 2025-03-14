module random_generator_20bit (
    input  wire         clk,
    input  wire         rst,
    input  wire [19:0]  seed,       // 20-bit seed
    output reg  [19:0]  random_num  // 5 nibbles, each in [0..9]
);

    // 20-bit LFSR register
    reg  [19:0] lfsr;
    wire        feedback;

    // Example polynomial for 20 bits: x^20 + x^17 + 1 (many others possible)
    // You can also try x^20 + x^19 + 1, etc.
    // Just make sure it's a primitive polynomial for good LFSR properties.
    assign feedback = lfsr[19] ^ lfsr[16];

    // Temporary wires for each nibble
    reg [3:0] nib0, nib1, nib2, nib3, nib4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize
            lfsr       <= seed;
            random_num <= 20'd0;
        end else begin
            // Shift in feedback
            lfsr <= {lfsr[18:0], feedback};

            // ------------------------------------------------------------
            // Extract 5 nibbles from the new LFSR state
            // ------------------------------------------------------------
            nib0 = lfsr[ 3: 0]; // bits [3:0]
            nib1 = lfsr[ 7: 4]; // bits [7:4]
            nib2 = lfsr[11: 8]; // bits [11:8]
            nib3 = lfsr[15:12]; // bits [15:12]
            nib4 = lfsr[19:16]; // bits [19:16]

            // ------------------------------------------------------------
            // Wrap each nibble so it becomes < 10
            //  - If >= 10, subtract 6.
            //    0..9 map to 0..9 one-to-one
            //    10..15 map to 4..9 (doubling the odds of digits 4..9)
            // ------------------------------------------------------------
            if (nib0 >= 10) nib0 = nib0 - 6;
            if (nib1 >= 10) nib1 = nib1 - 6;
            if (nib2 >= 10) nib2 = nib2 - 6;
            if (nib3 >= 10) nib3 = nib3 - 6;
            if (nib4 >= 10) nib4 = nib4 - 6;

            // ------------------------------------------------------------
            // Combine back into 20 bits
            // nib4 is the most significant digit,
            // nib0 is the least significant digit.
            // ------------------------------------------------------------
            random_num <= { nib4, nib3, nib2, nib1, nib0 };
        end
    end

endmodule

