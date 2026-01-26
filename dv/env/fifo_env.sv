// dv/env/fifo_env.sv
class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  // Components
  write_agent    w_agent;
  read_agent     r_agent;
  fifo_scoreboard scb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Build Agents and Scoreboard
    w_agent = write_agent::type_id::create("w_agent", this);
    r_agent = read_agent::type_id::create("r_agent", this);
    scb     = fifo_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    // Connect Agents to Scoreboard
    // w_agent.monitor_port --> scb.write_export
    w_agent.monitor_port.connect(scb.write_export);
    
    // r_agent.monitor_port --> scb.read_export
    r_agent.monitor_port.connect(scb.read_export);
  endfunction

endclass