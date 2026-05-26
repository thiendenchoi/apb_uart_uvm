class apb_seq_base extends uvm_sequence;
  `uvm_object_utils(apb_seq_base)

  //  Register model
  uart_regs apb_uart_regs;
  uvm_reg reg_id;
  uvm_reg_field field_id;
  uvm_reg_map reg_map_q[$];
  uvm_reg reg_q[$];
  uvm_status_e status;
  uvm_reg_data_t value;

  function new(string name = "apb_seq_base");
    super.new(name);

    apb_uart_regs = null;
    reg_id = null;
    field_id = null;
    reg_map_q.delete ();
    reg_q.delete ();
    status = UVM_NOT_OK;
    value = '0;
  endfunction

  task pre_start();
    super.pre_start();
    if (!uvm_config_db#(uart_regs)::get(null, "*", "apb_uart_regs", apb_uart_regs))
      `uvm_fatal("reg sequence", "cannot find apb_uart_regs");
    apb_uart_regs.get_maps      (reg_map_q) ;
    apb_uart_regs.get_registers (reg_q)     ;
  endtask

  task write_reg  ( input   string       reg_name  = "",
                    input   logic [31:0] reg_vl    = "",
                    output  uvm_status_e status,
                    input   uvm_path_e   path      = UVM_FRONTDOOR
                  );

    while (1) begin
      reg_id = apb_uart_regs.get_reg_by_name(reg_name);
      reg_id.write(.status(status), .value(reg_vl), .path(path), .parent(this));
      reg_id.sample_values();
      if (status == UVM_NOT_OK) begin
        `uvm_warning("REG_SEQ_BASE", $sformatf("Can not write to %s register !", reg_name) ) ;
        // $finish();
        break;
      end
      else if (status == UVM_HAS_X) begin
        `uvm_warning("REG_SEQ_BASE", $sformatf("Write register %0s has x value", reg_name) )  ;
        break;
      end
      else if (status === UVM_IS_OK) begin
        break ;
      end
    end
  endtask

  task read_reg ( input   string                          reg_name  = "",
                  output  logic [31:0] reg_vl,
                  output  uvm_status_e                    status,
                  input   uvm_path_e                      path      = UVM_FRONTDOOR
                );
    while (1) begin
      reg_id = apb_uart_regs.get_reg_by_name(reg_name);
      reg_id.read(.status(status), .value(reg_vl), .path(path), .parent(this));
      reg_id.sample_values();
      `uvm_info("READ_REG", $sformatf("reg_vl = %h", reg_vl), UVM_DEBUG);

      if (status == UVM_NOT_OK) begin
        `uvm_error("REG_SEQ_BASE", $sformatf("Can not read from %s register !", reg_name) )  ;
        break;
        // $finish();
      end
      else if (status == UVM_HAS_X) begin
        `uvm_warning("REG_SEQ_BASE", $sformatf("Read register %0s has x value", reg_name) )  ;
        break;
      end
      else if (status === UVM_IS_OK)
        break ;
    end
  endtask

  task write_field  ( input   string                            reg_name    = "",
                      input   string                            field_name  = "",
                      input   logic [31:0]   field_vl    = "",
                      output  uvm_status_e                      status,
                      input   uvm_path_e                        path        = UVM_FRONTDOOR
                    );
    logic [31:0]  field_mask_tmp  = '0;

    while (1) begin
      while (1) begin
        reg_id = apb_uart_regs.get_reg_by_name(reg_name);
        reg_id.read(.status(status), .value(value), .path(path), .parent(this));

        if (status == UVM_NOT_OK) begin
          `uvm_error("REG_SEQ_BASE", $sformatf("Can not read from register %0s !", reg_name) )  ;
          // $finish();
          break;
        end
        else if (status == UVM_HAS_X) begin
          `uvm_warning("REG_SEQ_BASE", $sformatf("Write field %0s of %0s register has x value", field_name, reg_name) )  ;
          break;
        end
        else if (status === UVM_IS_OK)
          break ;
      end
      get_field_mask  ( .reg_name     (reg_name)  ,
                        .field_name   (field_name)  ,
                        .field_mask   (field_mask_tmp)
                      ) ;
      field_id  = reg_id.get_field_by_name(field_name)  ;
      value     = (value & field_mask_tmp) + (field_vl << field_id.get_lsb_pos());
      reg_id.write(.status(status), .value(value), .path(path), .parent(this));

      if (status == UVM_NOT_OK) begin
        `uvm_error("REG_SEQ_BASE", $sformatf("Can not write to %s field of %s register !", field_name, reg_name) )  ;
        break;
        // $finish();
      end
      else if (status == UVM_HAS_X) begin
        `uvm_warning("REG_SEQ_BASE", $sformatf("Write field %0s of %0s register has x value", field_name, reg_name) )  ;
        break;
      end
      else if (status === UVM_IS_OK)
        break ;
    end
  endtask

  task read_field ( input   string        reg_name    = "",
                    input   string        field_name  = "",
                    output  logic [31:0] field_vl,
                    output  uvm_status_e  status,
                    input   uvm_path_e    path        = UVM_FRONTDOOR
                  );
    logic [31:0]  reg_vl_tmp  = '0;

    while (1) begin
      reg_id = apb_uart_regs.get_reg_by_name(reg_name);
      reg_id.read(.status(status), .value(reg_vl_tmp), .path(path), .parent(this));
      extract_field (.reg_name (reg_name), .field_name (field_name), .reg_vl (reg_vl_tmp), .field_vl (field_vl));

      if (status == UVM_NOT_OK) begin
        `uvm_error("REG_SEQ_BASE", $sformatf("Can not read from %s field of %s register !", field_name, reg_name) )  ;
        // $finish();
        break;
      end
      else if (status == UVM_HAS_X) begin
        `uvm_warning("REG_SEQ_BASE", $sformatf("Read field %0s of %0s register has x value", field_name, reg_name) )  ;
        break;
      end
      else if (status === UVM_IS_OK)
        break ;
    end
  endtask

  task extract_field  ( input   string       reg_name    = ""  ,
                        input   string       field_name  = ""  ,
                        input   logic [31:0] reg_vl      = '0  ,
                        output  logic [31:0] field_vl
                      ) ;
    uvm_reg         reg_id_tmp            ;
    int             wid_tmp           = '0;
    int             lsb_tmp           = '0;
    uvm_reg_data_t  vl_tmp            = '0;
    uvm_reg_data_t  mask              = '0;

    get_field_bits_wid  ( .reg_name   (reg_name   ) ,
                          .field_name (field_name ) ,
                          .bits_wid   (wid_tmp)
                        ) ;
    get_field_lsb_pos   ( .reg_name   (reg_name   ) ,
                          .field_name (field_name ) ,
                          .lsb_pos    (lsb_tmp)
                        ) ;
    mask                = (1'b1 << wid_tmp) - 1 ;
    vl_tmp              = (reg_vl >> lsb_tmp) & mask  ;
    field_vl            = vl_tmp  ;
  endtask

  task get_field_bits_wid ( input   string  reg_name    = ""  ,
                            input   string  field_name  = ""  ,
                            output  int     bits_wid
                          ) ;
    uvm_reg         reg_id_tmp        ;
    uvm_reg_field   reg_field_id_tmp  ;

    reg_id_tmp        = apb_uart_regs.get_reg_by_name(reg_name)  ;
    reg_field_id_tmp  = reg_id_tmp.get_field_by_name(field_name)  ;
    bits_wid          = reg_field_id_tmp.get_n_bits()             ;
  endtask

  task get_field_lsb_pos  ( input   string  reg_name    = ""  ,
                            input   string  field_name  = ""  ,
                            output  int     lsb_pos
                          ) ;
    uvm_reg         reg_id_tmp        ;
    uvm_reg_field   reg_field_id_tmp  ;

    reg_id_tmp        = apb_uart_regs.get_reg_by_name(reg_name)      ;
    reg_field_id_tmp  = reg_id_tmp.get_field_by_name(field_name)  ;
    lsb_pos           = reg_field_id_tmp.get_lsb_pos()            ;
  endtask

  task get_field_mask ( input   string          reg_name    = ""  ,
                        input   string          field_name  = ""  ,
                        output  uvm_reg_data_t  field_mask
                      ) ;
    uvm_reg         reg_id_tmp        ;
    uvm_reg_field   reg_field_id_tmp  ;
    uvm_reg_data_t  field_mask_tmp    ;
    integer         bits_wid_tmp      ;
    integer         lsb_pos_tmp       ;

    field_mask_tmp    = '0  ;
    bits_wid_tmp      = '0  ;
    get_field_bits_wid (reg_name, field_name, bits_wid_tmp) ;
    get_field_lsb_pos  (reg_name, field_name, lsb_pos_tmp ) ;
    field_mask_tmp    = (1'b1 << bits_wid_tmp) - 1  ;
    field_mask_tmp    = field_mask_tmp << lsb_pos_tmp ;
    field_mask_tmp    = ~ field_mask_tmp;
    field_mask        = field_mask_tmp  ;
  endtask

endclass