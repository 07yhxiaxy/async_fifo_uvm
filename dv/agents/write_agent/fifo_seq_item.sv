// dv/agents/write_agent/fifo_seq_item.sv
class fifo_seq_item extends uvm_sequence_item;
  
  // 1. Data Members (Randomized)
  rand bit [7:0] data;
  rand bit       w_en;
  rand bit       r_en;
  rand int       delay; // Delay before driving this packet

  // 2. UVM Factory Registration
  `uvm_object_utils_begin(fifo_seq_item)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(w_en, UVM_ALL_ON)
    `uvm_field_int(r_en, UVM_ALL_ON)
    `uvm_field_int(delay, UVM_ALL_ON)
  `uvm_object_utils_end

  // 3. Constraints
  constraint c_delay { delay inside {[0:5]}; } // Skew distribution towards fast burst

  // 4. Constructor
  function new(string name = "fifo_seq_item");
    super.new(name);
  endfunction

endclass