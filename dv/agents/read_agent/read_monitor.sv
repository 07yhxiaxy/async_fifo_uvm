// dv/agents/read_agent/read_monitor.sv
class read_monitor extends uvm_monitor;
    `uvm_component_utils(read_monitor);

    virtual fifo_if vif;
    uvm_analysis_port #(fifo_seq_item) item_collected_port;
    fifo_seq_item trans_collected;

    function new(string name, uvm_component parent);
        super.new(parent);
        item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
        end
    endfunction

    task run_phase(uvm_phase run_phase);
        forever begin
            // A. Wait for read clock edge
            @(vif.r_mon_cb);
            
            // Ignor reset signal
            if (vif.rst_n === 0) continue;

            // Else Capture the transaction when r_enable high ans r_empty is 0
            if (vif.r_mon_cb.r_en === 1 && vif.r_mon_cb.r_empty === 0) begin
                trans_collected = fifo_seq_item::type_id::create("trans_collected");

                // Sample the data from the interface
                trans_collected.data = vif.r_mon_cb.rdata;
                trans_collected.r_en = vif.r_mon_cb.r_en;

                `uvm_info("MON", $sformatf("Read Data Captured: 0x%0h", trans_collected.data), UVM_HIGH);

                // Send to Scoreboard
                item_collected_port.write(trans_collected);
            end
        end
    endtask

endclass