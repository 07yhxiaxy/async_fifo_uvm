// dv/env/fifo_scoreboard.sv
class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  // 1. Analysis Exports (Inputs from Monitors)
  uvm_analysis_export #(fifo_seq_item) write_export;
  uvm_analysis_export #(fifo_seq_item) read_export;

  // 2. TLM FIFOs (Infinite Buffers to store packets)
  uvm_tlm_analysis_fifo #(fifo_seq_item) write_fifo;
  uvm_tlm_analysis_fifo #(fifo_seq_item) read_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Initialize Ports and FIFOs
    write_export = new("write_export", this);
    read_export  = new("read_export", this);
    write_fifo   = new("write_fifo", this);
    read_fifo    = new("read_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    // Connect the Exports to the internal FIFOs
    write_export.connect(write_fifo.analysis_export);
    read_export.connect(read_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_seq_item w_trans, r_trans;
    
    forever begin
      // A. Get a packet from the Read FIFO (Wait until something is read)
      read_fifo.get(r_trans);

      // B. Get the oldest packet from the Write FIFO (The Expected Data)
      // If the Read FIFO has data but Write FIFO is empty, that's a HUGE bug (Spurious Read).
      if (write_fifo.is_empty()) begin
        `uvm_error("SCB", "Read transaction received but Write FIFO is empty! (Data Underflow / Spurious Read)")
      end else begin
        write_fifo.get(w_trans); // Pop the expected data
        
        // C. The Comparison
        if (r_trans.data !== w_trans.data) begin
          `uvm_error("SCB", $sformatf("Mismatch! Expected: 0x%0h, Got: 0x%0h", w_trans.data, r_trans.data))
        end else begin
          `uvm_info("SCB", $sformatf("PASS: Data 0x%0h matched.", r_trans.data), UVM_HIGH)
        end
      end
    end
  endtask

endclass