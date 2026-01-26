`ifndef FIFO_FULL_SEQ_SV
`define FIFO_FULL_SEQ_SV

// -------------------------------------------------------------------------
// Sequence: fifo_fill_burst_seq
// Purpose:  Write FAST (0 delay) to force FIFO Full condition.
//           Write more items than the FIFO depth (e.g., 20 items for depth 16)
//           to check if the "Full" flag protects the memory from overflow.
// -------------------------------------------------------------------------
class fifo_fill_burst_seq extends fifo_write_seq;
  `uvm_object_utils(fifo_fill_burst_seq)

  function new(string name="fifo_fill_burst_seq");
    super.new(name);
  endfunction

  // Override the body task to apply strict constraints
  task body();
    fifo_seq_item req;
    `uvm_info("SEQ", "Starting FIFO FILL BURST Sequence...", UVM_LOW)

    // Example: If FIFO depth is 16, we write 20 times.
    // The last 4 writes should be dropped by the DUT (and handled by Monitor).
    repeat(20) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      
      // CONSTRAINT:
      // 1. delay == 0 (Write as fast as possible)
      // 2. w_en == 1  (Always write)
      if (!req.randomize() with { 
          delay == 0; 
          w_en  == 1; 
      }) begin
        `uvm_fatal("SEQ", "Randomization failed in fill_burst_seq");
      end
      
      finish_item(req);
    end
    `uvm_info("SEQ", "FIFO FILL BURST Sequence Complete", UVM_LOW)
  endtask

endclass

`endif