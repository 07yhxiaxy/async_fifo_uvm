// dv/sequences/fifo_base_seq.sv

// ------------------------------------------------------------------
// 1. Write Sequence: Pushes 'num_items' into the FIFO
// ------------------------------------------------------------------
class fifo_write_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_write_seq)

  rand int num_items; // How many packets to send

  constraint c_items { num_items inside {[50:100]}; }

  function new(string name="fifo_write_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item req;
    `uvm_info("SEQ", $sformatf("Starting Write Sequence: %0d items", num_items), UVM_LOW)

    repeat(num_items) begin
      req = fifo_seq_item::type_id::create("req");
      
      start_item(req);
      
      // Randomize the item
      if (!req.randomize()) begin
        `uvm_fatal("SEQ", "Randomization failed")
      end
      
      finish_item(req); // Driver takes it here
    end
    
    `uvm_info("SEQ", "Write Sequence Complete", UVM_LOW)
  endtask
endclass

// ------------------------------------------------------------------
// 2. Read Sequence: Pops 'num_items' from the FIFO
// ------------------------------------------------------------------
class fifo_read_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_read_seq)

  rand int num_items;

  constraint c_items { num_items inside {[50:100]}; }

  function new(string name="fifo_read_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item req;
    `uvm_info("SEQ", $sformatf("Starting Read Sequence: %0d items", num_items), UVM_LOW)

    repeat(num_items) begin
      req = fifo_seq_item::type_id::create("req");
      
      start_item(req);
      if (!req.randomize()) `uvm_fatal("SEQ", "Randomization failed");
      finish_item(req); 
    end
    
    `uvm_info("SEQ", "Read Sequence Complete", UVM_LOW)
  endtask
endclass