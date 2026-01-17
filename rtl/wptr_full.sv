// rtl/wptr_full.sv
module wptr_full #(
  parameter ADDRSIZE = 4
) (
    input  logic                w_clk,
    input  logic                w_rst_n,
    input  logic                w_en,
    input  logic [ADDRSIZE:0]   wq2_rptr, // Read pointer (synced to w_clk)
    output logic                w_full,
    output logic [ADDRSIZE-1:0] w_addr,   // Memory address
    output logic [ADDRSIZE:0]   w_gray_ptr // Gray pointer to send to Read Domain
);

    logic [ADDRSIZE:0] w_bin;
    logic [ADDRSIZE:0] w_bin_next, w_gray_next;

    // 1. BINARY AND GRAY POINTER REGISTERS
    always_ff @(posedge w_clk or negedge w_rst_n) begin
        if (!w_rst_n) begin
            w_bin      <= 0;
            w_gray_ptr <= 0;
        end else begin
            w_bin      <= w_bin_next;
            w_gray_ptr <= w_gray_next;
        end
    end

    // 2. MEMORY WRITE ADDRESS GENERATION
    assign w_addr = w_bin[ADDRSIZE-1:0];

    // 3. BINARY NEXT-STATE LOGIC
    assign w_bin_next = w_bin + (w_en & ~w_full);

    // 4. BINARY TO GRAY CONVERSION
    // (Shift binary right by 1 and XOR with itself)
    assign w_gray_next = (w_bin_next >> 1) ^ w_bin_next;

    // 5. FULL FLAG GENERATION
    // Full condition in Gray Code:
    // MSB must be DIFFERENT (wrapped around)
    // 2nd MSB must be DIFFERENT (mirror image quadrant)
    // All other bits must MATCH
    assign w_full = (w_gray_next == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]});

endmodule