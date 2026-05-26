class apb_seq_write_ctrl_reg extends apb_seq_base;
  `uvm_object_utils(apb_seq_write_ctrl_reg)

  rand bit start_tx;

  constraint cfg_reg_const {
    soft start_tx == 1'b0;
  }

  extern function new(string name = "apb_seq_write_ctrl_reg");
  extern task     body();

  virtual task pre_start();
    super.pre_start();
    $display("@ %-3d: %0s", $time, get_sequence_path());
  endtask
endclass

function apb_seq_write_ctrl_reg::new(string name = "apb_seq_write_ctrl_reg");
  super.new(name);
endfunction

task apb_seq_write_ctrl_reg::body();
  $display("@%15t   Entering apb_seq_write_ctrl_reg: start_tx = %b", $time, start_tx);
  reg_id   = apb_uart_regs.get_reg_by_name("reg_ctrl_reg");
  field_id = reg_id.get_field_by_name("start_tx");
  value    = start_tx << field_id.get_lsb_pos();
  write_reg ("reg_ctrl_reg", value, status, UVM_FRONTDOOR);
  $display("@%15t   Exiting apb_seq_write_ctrl_reg", $time);
endtask