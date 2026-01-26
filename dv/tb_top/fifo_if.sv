// dv/tb_top/fifo_if.sv
interface fifo_if (input logic w_clk, input logic r_clk, input logic rst_n);

  // 1. Signals
  logic        w_en;
  logic        w_full;
  logic [7:0]  wdata;
  
  logic        r_en;
  logic        r_empty;
  logic [7:0]  rdata;

  // 2. Write Driver Clocking Block (Active)
  clocking w_drv_cb @(posedge w_clk);
    default input #1step output #1ns;
    output w_en, wdata;
    input  w_full;   // Driver needs to see Full to stop driving
  endclocking

  // 3. Write Monitor Clocking Block (Passive)
  clocking w_mon_cb @(posedge w_clk);
    default input #1step output #1ns;
    input w_en, wdata, w_full;
  endclocking

  // 4. Read Driver Clocking Block (Active)
  clocking r_drv_cb @(posedge r_clk);
    default input #1step output #1ns;
    output r_en;
    input  r_empty, rdata;
  endclocking

  // 5. Read Monitor Clocking Block (Passive)
  clocking r_mon_cb @(posedge r_clk);
    default input #1step output #1ns;
    input r_en, r_empty, rdata;
  endclocking

  // 6. Modports (Optional but good for linting)
  modport W_DRV (clocking w_drv_cb);
  modport W_MON (clocking w_mon_cb);
  modport R_DRV (clocking r_drv_cb);
  modport R_MON (clocking r_mon_cb);

  // 7. SVA (SystemVerilog Assertions)
  // Ensure we never write to a full FIFO (Protocol Check)
  property p_no_overflow;
    @(posedge w_clk) disable iff (!rst_n)
    (w_en && w_full) |-> ##1 $stable(w_full); 
  endproperty

  // Ensure we never read from an empty FIFO (Protocol Check)
  property p_no_underflow;
    @(posedge r_clk) disable iff (!rst_n)
    (r_en && r_empty) |-> ##1 $stable(r_empty);
  endproperty

  // Reset Check: Flags must be correct immediately after reset
  property p_reset_check;
    @(posedge w_clk) !rst_n |-> (w_full == 0 && r_empty == 1);
  endproperty

  ASSERT_OVERFLOW: assert property (p_no_overflow) else `uvm_error("SVA", "Write to FULL FIFO detected!");
  ASSERT_UNDERFLOW: assert property (p_no_underflow) else `uvm_error("SVA", "Read from EMPTY FIFO detected!");
  ASSERT_RESET:    assert property (p_reset_check) else `uvm_fatal("SVA", "Reset values incorrect!");

endinterface
