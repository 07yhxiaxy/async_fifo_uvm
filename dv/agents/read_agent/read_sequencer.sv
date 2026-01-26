// dv/agents/read_agent/read_sequencer.sv
class read_sequencer extends uvm_sequencer #(fifo_seq_item);
    `uvm_component_utils(read_sequencer);

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass