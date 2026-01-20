// dv/agents/write_agent/write_driver.sv
class write_driver extends uvm_driver #(fifo_seq_item);
  `uvm_component_utils(write_driver)

  virtual fifo_if vif; // Handle to the interface

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase: Get interface from Config DB
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not set for: " ~ get_full_name(".vif"));
  endfunction

  // Run Phase: The Main Loop
  task run_phase(uvm_phase phase);
    // Reset Initialization
    vif.w_drv_cb.w_en <= 0;
    
    forever begin
      // 1. Get next item from Sequencer
      seq_item_port.get_next_item(req);
      
      // 2. Wait for optional random delay
      repeat(req.delay) @(vif.w_drv_cb);

      // 3. Drive the signals using Clocking Block
      @(vif.w_drv_cb); // Wait for clock edge
      
      // Only drive if not full (Simple flow control)
      if (!vif.w_drv_cb.w_full) begin
        vif.w_drv_cb.w_en <= 1;
        vif.w_drv_cb.wdata <= req.data;
      end else begin
        vif.w_drv_cb.w_en <= 0;
      end

      // 4. Reset signals after one cycle (Pulse)
      @(vif.w_drv_cb);
      vif.w_drv_cb.w_en <= 0;

      // 5. Done
      seq_item_port.item_done();
    end
  endtask

endclass