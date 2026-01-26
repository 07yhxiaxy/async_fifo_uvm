// dv/env/fifo_coverage.sv
class fifo_coverage extends uvm_subscriber #(fifo_seq_item);
  `uvm_component_utils(fifo_coverage)

  bit w_en, r_en;

  covergroup fifo_cg;
    // Did we see single writes and back-to-back bursts?
    cp_write: coverpoint w_en {
      bins single = (0 => 1 => 0);
      bins burst  = (1 [* 2:10]); 
    }
    // Did we see single reads and back-to-back bursts?
    cp_read: coverpoint r_en {
      bins single = (0 => 1 => 0);
      bins burst  = (1 [* 2:10]);
    }
    // Did we stress the memory dual-port nature?
    cross cp_write, cp_read; 
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    fifo_cg = new();
  endfunction

  function void write(fifo_seq_item t);
    w_en = t.w_en;
    r_en = t.r_en;
    fifo_cg.sample();
  endfunction
endclass
