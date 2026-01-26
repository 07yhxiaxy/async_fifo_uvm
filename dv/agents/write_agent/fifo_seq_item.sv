// dv/agents/write_agent/fifo_seq_item.sv
`ifndef FIFO_SEQ_ITEM_SV
`define FIFO_SEQ_ITEM_SV

class fifo_seq_item extends uvm_sequence_item;
  
  //----------------------------------------------------------------------------
  // Data Members
  //----------------------------------------------------------------------------
  rand bit [7:0] data;        // Payload
  rand int       delay;       // Cycles to wait before driving (Protocol delay)
  rand bit       w_en;        // Write Enable (For randomized control)
  rand bit       r_en;        // Read Enable

  //----------------------------------------------------------------------------
  // UVM Factory Registration
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(fifo_seq_item)
    `uvm_field_int(data,  UVM_ALL_ON)
    `uvm_field_int(delay, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(w_en,  UVM_ALL_ON)
    `uvm_field_int(r_en,  UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  
  // Constraint 1: Bursty Traffic Distribution
  // Industry logic: Real traffic isn't uniform. It comes in fast bursts (0 delay)
  // followed by idle times.
  constraint c_delay_dist { 
    delay dist { 
      0       := 60,  // 60% probability of Back-to-Back (Burst)
      [1:5]   := 30,  // 30% probability of Short Delay
      [6:20]  := 8,   // 8% probability of Medium Delay
      [21:50] := 2    // 2% probability of Long Idle
    }; 
  }

  // Constraint 2: Reasonable Data Range (Optional, good for debug)
  constraint c_data { data inside {[0:255]}; }

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "fifo_seq_item");
    super.new(name);
  endfunction

endclass

`endif