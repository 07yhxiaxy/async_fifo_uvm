// dv/tests/fifo_base_test.sv
class fifo_base_test extends uvm_test;
  `uvm_component_utils(fifo_base_test)

  fifo_env       env;
  fifo_write_seq w_seq;
  fifo_read_seq  r_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Build the environment
    env = fifo_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Create the sequences
    w_seq = fifo_write_seq::type_id::create("w_seq");
    r_seq = fifo_read_seq::type_id::create("r_seq");

    // Configure them (e.g., Send 100 packets)
    if(!w_seq.randomize() with { num_items == 100; }) `uvm_fatal("TEST", "Randomize failed");
    if(!r_seq.randomize() with { num_items == 100; }) `uvm_fatal("TEST", "Randomize failed");

    // ----------------------------------------------------------------
    // PARALLEL EXECUTION (The "Fork/Join" Interview Question)
    // ----------------------------------------------------------------
    fork
      w_seq.start(env.w_agent.seqr); // Start Writer on Write Agent
      r_seq.start(env.r_agent.seqr); // Start Reader on Read Agent
    join
    
    // Drain Time: Wait a bit after sequences verify the last few packets
    #100ns;
    
    phase.drop_objection(this);
  endtask

endclass