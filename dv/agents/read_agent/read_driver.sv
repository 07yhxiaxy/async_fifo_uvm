// dv/agents/read_agent/read_driver.sv
class read_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(read_driver);

    virtual fifo_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase build_phase);
        super.build_phase(build_phase);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not set for: " ~ get_full_name(".vif"))
        end
    endfunction

    task run_phase(uvm_phase phase);
        // Initialize signals
        vif.r_drv_cb.r_en <= 0;

        forever begin
            // 1. Get request from sequence
            seq_item_port.get_next_item(req);

            // 2. Wait for random delay (Simulates a slow consumer)
            repeat(req.delay)@(posedge vif.r_drv_cb);

            // 3. Drive Read Enable
            // adding this while loop because if the FIFO is empty, 
            // we shouldn't consume the sequence item yet. We must wait.
            while (vif.r_drv_cb.r_empty == 1) begin
                @(vif.r_drv_cb); 
            end
            // Only read if FIFO isn't empty
            vif.r_drv_cb.r_en <= 1;

            // Reset enable after 1 cycle;
            @(vif.r_drv_cb);
            vif.r_drv_cb.r_en <= 0;

            // 5. Complete handshake
            seq_item_port.item_done();
        end
    endtask

endclass