class apb_seq_read_stt_reg extends apb_seq_base;
  `uvm_object_utils(apb_seq_read_stt_reg)

  extern function new(string name="apb_seq_read_stt_reg");
  extern task body();

  virtual task pre_start();
    super.pre_start();
    $display("@ %-3d: %0s", $time, get_sequence_path());
  endtask
endclass

function apb_seq_read_stt_reg::new(string name="apb_seq_read_stt_reg");
  super.new(name);
endfunction

task apb_seq_read_stt_reg::body();
  $display("@%15t   Entering apb_seq_read_stt_reg", $time);
  //Read reg
  read_reg("reg_stt_reg", value, status, UVM_FRONTDOOR);
  $display("@%15t   Exiting apb_seq_read_stt_reg with: tx_done: %b, rx_done: %b, parity_error: %b", $time, value[0], value[1], value[2]);

endtask