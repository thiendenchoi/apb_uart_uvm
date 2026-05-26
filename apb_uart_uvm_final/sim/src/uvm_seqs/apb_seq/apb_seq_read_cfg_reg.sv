class apb_seq_read_cfg_reg extends apb_seq_base;
  `uvm_object_utils(apb_seq_read_cfg_reg)

  extern function new(string name="apb_seq_read_cfg_reg");
  extern task body();

  virtual task pre_start();
    super.pre_start();
    $display("@ %-3d: %0s", $time, get_sequence_path());
  endtask
endclass

function apb_seq_read_cfg_reg::new(string name="apb_seq_read_cfg_reg");
  super.new(name);
endfunction

task apb_seq_read_cfg_reg::body();
  $display("@%15t   Entering apb_seq_read_cfg_reg", $time);
  //Read reg
  read_reg("reg_cfg_reg", value, status, UVM_FRONTDOOR);
  $display("@%15t   Exiting apb_seq_read_cfg_reg with: data_bit_num: %b, stop_bit_num: %b, parity_en: %b, parity_type: %b", $time, value[1:0], value[2], value[3], value[4]);

endtask