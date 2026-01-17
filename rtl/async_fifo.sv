// rtl/async_fifo.sv
module async_fifo #(
  parameter DSIZE = 8,
  parameter ASIZE = 4
)(
  input  logic             w_clk, w_rst_n,
  input  logic             w_en,
  input  logic [DSIZE-1:0] w_data,
  output logic             w_full,
  
  input  logic             r_clk, r_rst_n,
  input  logic             r_en,
  output logic [DSIZE-1:0] r_data,
  output logic             r_empty
);

  // Internal Signals
  logic [ASIZE-1:0] w_addr, r_addr;
  logic [ASIZE:0]   w_gray_ptr, r_gray_ptr;
  logic [ASIZE:0]   wq2_rptr, rq2_wptr; // Synced pointers

  // --------------------------------------------------------
  // 1. Synchronizers (Double Flop)
  // --------------------------------------------------------
  
  // Sync Read Pointer into Write Domain (rptr -> w_clk)
  logic [ASIZE:0] rptr_q1;
  always_ff @(posedge w_clk or negedge w_rst_n) begin
    if (!w_rst_n) {wq2_rptr, rptr_q1} <= 0;
    else          {wq2_rptr, rptr_q1} <= {rptr_q1, r_gray_ptr};
  end

  // Sync Write Pointer into Read Domain (wptr -> r_clk)
  logic [ASIZE:0] wptr_q1;
  always_ff @(posedge r_clk or negedge r_rst_n) begin
    if (!r_rst_n) {rq2_wptr, wptr_q1} <= 0;
    else          {rq2_wptr, wptr_q1} <= {wptr_q1, w_gray_ptr};
  end

  // --------------------------------------------------------
  // 2. Instantiate Sub-Modules
  // --------------------------------------------------------
  
  fifomem #(DSIZE, ASIZE) fifomem_inst (
    .w_en(w_en), .w_full(w_full), .w_clk(w_clk), 
    .w_addr(w_addr), .r_addr(r_addr), 
    .w_data(w_data), .r_data(r_data)
  );

  wptr_full #(ASIZE) wptr_inst (
    .w_clk(w_clk), .w_rst_n(w_rst_n), .w_en(w_en),
    .wq2_rptr(wq2_rptr),     // <-- The Read Pointer entering Write Logic
    .w_full(w_full), 
    .w_addr(w_addr), 
    .w_gray_ptr(w_gray_ptr)
  );

  rptr_empty #(ASIZE) rptr_inst (
    .r_clk(r_clk), .r_rst_n(r_rst_n), .r_en(r_en),
    .rq2_wptr(rq2_wptr),     // <-- The Write Pointer entering Read Logic
    .r_empty(r_empty), 
    .r_addr(r_addr), 
    .r_gray_ptr(r_gray_ptr)
  );

endmodule