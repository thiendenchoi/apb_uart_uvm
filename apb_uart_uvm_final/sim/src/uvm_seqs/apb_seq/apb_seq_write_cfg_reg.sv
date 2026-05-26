class apb_seq_write_cfg_reg extends apb_seq_base;
  `uvm_object_utils(apb_seq_write_cfg_reg)

  rand bit [1:0] data_bit_num;
  rand bit       stop_bit_num;
  rand bit       parity_en;
  rand bit       parity_type;

  constraint cfg_reg_const {
    soft data_bit_num == 2'b0;
    soft stop_bit_num == 1'b0;
    soft parity_en    == 1'b0;
    soft parity_type  == 1'b0;
  }

  extern function new(string name = "apb_seq_write_cfg_reg");
  extern task     body();

  virtual task pre_start();
    super.pre_start();
    $display("@ %-3d: %0s", $time, get_sequence_path());
  endtask
endclass

  function apb_seq_write_cfg_reg::new(string name = "apb_seq_write_cfg_reg");
    super.new(name);
  endfunction

  task apb_seq_write_cfg_reg::body();
    $display("@%15t   Entering apb_seq_write_cfg_reg: data_bit_num =%b, stop_bit_num =%b, parity_en = %b", $time, data_bit_num, stop_bit_num, parity_en);
    reg_id    = apb_uart_regs.get_reg_by_name("reg_cfg_reg");
    field_id  = reg_id.get_field_by_name("data_bit_num");
    value     = data_bit_num << field_id.get_lsb_pos();
    field_id  = reg_id.get_field_by_name("stop_bit_num");
    value    += stop_bit_num << field_id.get_lsb_pos();
    field_id  = reg_id.get_field_by_name("parity_en");
    value    += parity_en << field_id.get_lsb_pos();
    field_id  = reg_id.get_field_by_name("parity_type");
    value    += parity_type << field_id.get_lsb_pos();
    write_reg ("reg_cfg_reg", value, status, UVM_FRONTDOOR);
    $display("@%15t   Exiting apb_seq_write_cfg_reg", $time);
  endtask