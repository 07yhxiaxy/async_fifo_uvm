// rtl/rptr_empty.sv
module rptr_empty #(
  parameter ADDRSIZE = 4
) (
  input  logic                r_clk,
  input  logic                r_rst_n,
  input  logic                r_en,
  input  logic [ADDRSIZE:0]   rq2_wptr, // Write pointer (synced to r_clk)
  output logic                r_empty,
  output logic [ADDRSIZE-1:0] r_addr,   // Memory address to read from
  output logic [ADDRSIZE:0]   r_gray_ptr // Gray pointer to send to Write Domain
);

  logic [ADDRSIZE:0] r_bin;
  logic [ADDRSIZE:0] r_bin_next, r_gray_next;

  // 1. GRAY STYLE POINTER REGISTERS
  always_ff @(posedge r_clk or negedge r_rst_n) begin
    if (!r_rst_n) begin
      r_bin      <= 0;
      r_gray_ptr <= 0;
    end else begin
      r_bin      <= r_bin_next;
      r_gray_ptr <= r_gray_next;
    end
  end

  // 2. MEMORY READ ADDRESS
  assign r_addr = r_bin[ADDRSIZE-1:0];

  // 3. NEXT STATE LOGIC
  assign r_bin_next = r_bin + (r_en & ~r_empty);
  
  // 4. BINARY TO GRAY CONVERSION
  assign r_gray_next = (r_bin_next >> 1) ^ r_bin_next;

  // 5. EMPTY FLAG GENERATION
  // Empty when Gray Pointers are EXACTLY equal
  assign r_empty = (r_gray_next == rq2_wptr);

endmodule