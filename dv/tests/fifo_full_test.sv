`ifndef FIFO_FULL_TEST_SV
`define FIFO_FULL_TEST_SV

class fifo_full_test extends fifo_base_test;
  `uvm_component_utils(fifo_full_test)

  // Declare the specialized sequences
  fifo_fill_burst_seq  fill_seq;
  fifo_drain_burst_seq drain_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Override run_phase to orchestrate the specific scenario
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    // Create the sequences
    fill_seq  = fifo_fill_burst_seq::type_id::create("fill_seq");
    drain_seq = fifo_drain_burst_seq::type_id::create("drain_seq");

    `uvm_info("TEST", ">>> PHASE 1: FILL FIFO (Writer Fast, Reader Stopped) <<<", UVM_NONE)
    
    // Run ONLY the Write sequence. 
    // Since we don't start a Read sequence, the Read Agent is idle.
    fill_seq.start(env.w_agent.seqr);
    
    // Give time for the "Full" flag to settle and be observed
    #100ns;

    `uvm_info("TEST", ">>> PHASE 2: DRAIN FIFO (Writer Stopped, Reader Fast) <<<", UVM_NONE)
    
    // Now run ONLY the Read sequence to empty it out.
    // This validates that the data we stuffed in Phase 1 is actually correct 
    // and didn't get corrupted by the overflow attempts.
    drain_seq.start(env.r_agent.seqr);

    #100ns;
    phase.drop_objection(this);
  endtask

endclass

`endif