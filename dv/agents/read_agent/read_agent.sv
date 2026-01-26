// dv/agents/read_agent/read_agent.sv
class read_agent extends uvm_agent;
    `uvm_component_utils(read_agent)

    read_driver drv;
    read_monitor mon;
    read_sequencer seqr;

    uvm_analysis_port #(fifo_seq_item) monitor_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Build monitor
        mon = read_monitor::type_id::new("mon", this);

        // Only build driver/sequencer if active
        if(get_is_active()==UVM_ACTIVE) begin
            drv = read_driver::type_id::new("drv", this);
            seqr = read_sequencer::type_id::new("seqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        // Connect monitor port to agent port
        mon.item_collected_port.connect(this.monitor_port);

        // Connect driver to sequencer
        if (get_is_active()==UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction

endclass