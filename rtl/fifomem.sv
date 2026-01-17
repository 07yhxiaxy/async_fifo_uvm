// rtl/fifomem.sv
module fifomem #(
  parameter DATASIZE = 8, // Width of data (e.g., 8 bits)
  parameter ADDRSIZE = 4  // Depth (2^4 = 16 words)
) (
  input  logic                w_en,
  input  logic                w_full,
  input  logic                w_clk,
  input  logic [ADDRSIZE-1:0] w_addr, 
  input  logic [ADDRSIZE-1:0] r_addr,
  input  logic [DATASIZE-1:0] w_data,
  output logic [DATASIZE-1:0] r_data
);

    // Define the memory array
    logic [DATASIZE : 0] mem [0 : (1<<ADDRSIZE) - 1];

    // Write Logic
    always_ff @(posedge w_clk) begin
        if (w_en && !w_full) begin
            mem[w_addr] <= w_data;
        end
    end

    // Read Logic (Asynchronous Read / Combinational)
    // This allows data to be ready immediately when address changes
    assign r_data = mem[r_addr];

endmodule