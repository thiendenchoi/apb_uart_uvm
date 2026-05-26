class apb_seq_write_tx_data_reg extends apb_seq_base;
  `uvm_object_utils(apb_seq_write_tx_data_reg)

  rand bit [7:0] tx_data;

  constraint cfg_reg_const {
    soft tx_data == 8'd0;
  }

  extern function new(string name = "apb_seq_write_tx_data_reg");
  extern task     body();

  virtual task pre_start();
    super.pre_start();
    $display("@ %-3d: %0s", $time, get_sequence_path());
  endtask
endclass

function apb_seq_write_tx_data_reg::new(string name = "apb_seq_write_tx_data_reg");
  super.new(name);
endfunction

task apb_seq_write_tx_data_reg::body();
  $display("@%15t   Entering apb_seq_write_tx_data_reg: tx_data = %b", $time, tx_data);
  reg_id   = apb_uart_regs.get_reg_by_name("reg_tx_data_reg");
  field_id = reg_id.get_field_by_name("tx_data");
  value    = tx_data << field_id.get_lsb_pos();
  write_reg ("reg_tx_data_reg", value, status, UVM_FRONTDOOR);
  $display("@%15t   Exiting apb_seq_write_tx_data_reg", $time);
endtask