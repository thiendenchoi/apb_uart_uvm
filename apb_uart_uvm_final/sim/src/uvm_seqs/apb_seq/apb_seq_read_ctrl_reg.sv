class apb_seq_read_ctrl_reg extends apb_seq_base;
  `uvm_object_utils(apb_seq_read_ctrl_reg)

  extern function new(string name="apb_seq_read_ctrl_reg");
  extern task body();

  virtual task pre_start();
    super.pre_start();
    $display("@ %-3d: %0s", $time, get_sequence_path());
  endtask
endclass

function apb_seq_read_ctrl_reg::new(string name="apb_seq_read_ctrl_reg");
  super.new(name);
endfunction

task apb_seq_read_ctrl_reg::body();
  $display("@%15t   Entering apb_seq_read_ctrl_reg", $time);
  //Read reg
  read_reg("reg_ctrl_reg", value, status, UVM_FRONTDOOR);
  $display("@%15t   Exiting apb_seq_read_ctrl_reg with: start_tx: %b", $time, value[0]);

endtask