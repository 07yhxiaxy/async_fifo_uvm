`ifndef FIFO_EMPTY_SEQ_SV
`define FIFO_EMPTY_SEQ_SV

// -------------------------------------------------------------------------
// Sequence: fifo_drain_burst_seq
// Purpose:  Read FAST (0 delay) to force FIFO Empty condition.
//           Tries to read even when empty to check Underflow protection.
// -------------------------------------------------------------------------
class fifo_drain_burst_seq extends fifo_read_seq;
  `uvm_object_utils(fifo_drain_burst_seq)

  function new(string name="fifo_drain_burst_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item req;
    `uvm_info("SEQ", "Starting FIFO DRAIN BURST Sequence...", UVM_LOW)

    repeat(20) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      
      // Force immediate reads
      if (!req.randomize() with { 
          delay == 0; 
          r_en  == 1; 
      }) `uvm_fatal("SEQ", "Rand failed");
      
      finish_item(req);
    end
    `uvm_info("SEQ", "FIFO DRAIN BURST Sequence Complete", UVM_LOW)
  endtask

endclass

`endif