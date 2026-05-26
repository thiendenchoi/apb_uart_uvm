package uart_regs_pkg;

   import uvm_pkg::*;

   `include "uvm_macros.svh"

   /* DEFINE REGISTER CLASSES */



   //--------------------------------------------------------------------
   // Class: cfg_reg
   // 
   // uart frame configuration
   //--------------------------------------------------------------------

   class cfg_reg extends uvm_reg;
      `uvm_object_utils(cfg_reg)

      uvm_reg_field rfu; // Reserved for Future Use
      rand uvm_reg_field parity_type; // parity_type
      rand uvm_reg_field parity_en; // parity_en
      rand uvm_reg_field stop_bit_num; // The number of stop bits
      rand uvm_reg_field data_bit_num; // The number of data bits
                                       // 2’b00: 5 bits
                                       // 2’b01: 6 bits
                                       // 2’b10: 7 bits
                                       // 2’b11: 8 bits


      // Function: coverage
      // 
      covergroup cg_vals;
         parity_type	 : coverpoint parity_type.value[0];
         parity_en	 : coverpoint parity_en.value[0];
         stop_bit_num	 : coverpoint stop_bit_num.value[0];
         data_bit_num	 : coverpoint data_bit_num.value[1:0];
      endgroup



      // Function: new
      // 
      function new(string name = "cfg_reg");
         super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
         add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
         if(has_coverage(UVM_CVR_FIELD_VALS))
            cg_vals = new();
      endfunction


      // Function: sample_values
      // 
      virtual function void sample_values();
         super.sample_values();
         if (get_coverage(UVM_CVR_FIELD_VALS))
            cg_vals.sample();
      endfunction


      // Function: build
      // 
      virtual function void build();
         rfu = uvm_reg_field::type_id::create("rfu");
         parity_type = uvm_reg_field::type_id::create("parity_type");
         parity_en = uvm_reg_field::type_id::create("parity_en");
         stop_bit_num = uvm_reg_field::type_id::create("stop_bit_num");
         data_bit_num = uvm_reg_field::type_id::create("data_bit_num");

         rfu.configure(this, 27, 5, "RW", 0, 27'b000000000000000000000000000, 1, 0, 0);
         parity_type.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 0);
         parity_en.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 0);
         stop_bit_num.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
         data_bit_num.configure(this, 2, 0, "RW", 0, 2'b11, 1, 1, 0);
      endfunction
   endclass



   //--------------------------------------------------------------------
   // Class: ctrl_reg
   // 
   // Operation Control Register
   //--------------------------------------------------------------------

   class ctrl_reg extends uvm_reg;
      `uvm_object_utils(ctrl_reg)

      uvm_reg_field rfu; // Reserved for Future Use
      rand uvm_reg_field start_tx; // Set to start coverting parallel data received from the host to serial data sent to peripheral device


      // Function: coverage
      // 
      covergroup cg_vals;
         start_tx	 : coverpoint start_tx.value[0];
      endgroup



      // Function: new
      // 
      function new(string name = "ctrl_reg");
         super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
         add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
         if(has_coverage(UVM_CVR_FIELD_VALS))
            cg_vals = new();
      endfunction


      // Function: sample_values
      // 
      virtual function void sample_values();
         super.sample_values();
         if (get_coverage(UVM_CVR_FIELD_VALS))
            cg_vals.sample();
      endfunction


      // Function: build
      // 
      virtual function void build();
         rfu = uvm_reg_field::type_id::create("rfu");
         start_tx = uvm_reg_field::type_id::create("start_tx");

         rfu.configure(this, 31, 1, "RW", 0, 31'b0000000000000000000000000000000, 1, 0, 0);
         start_tx.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
      endfunction
   endclass



   //--------------------------------------------------------------------
   // Class: rx_data_reg
   // 
   // RX data register
   //--------------------------------------------------------------------

   class rx_data_reg extends uvm_reg;
      `uvm_object_utils(rx_data_reg)

      uvm_reg_field rfu; // Reserved for Future Use
      uvm_reg_field rx_data; // Parallel data archived after serial-to-parallel coversation on data received on peripheral device


      // Function: coverage
      // 
      covergroup cg_vals;
         rx_data	 : coverpoint rx_data.value[7:0];
      endgroup



      // Function: new
      // 
      function new(string name = "rx_data_reg");
         super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
         add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
         if(has_coverage(UVM_CVR_FIELD_VALS))
            cg_vals = new();
      endfunction


      // Function: sample_values
      // 
      virtual function void sample_values();
         super.sample_values();
         if (get_coverage(UVM_CVR_FIELD_VALS))
            cg_vals.sample();
      endfunction


      // Function: build
      // 
      virtual function void build();
         rfu = uvm_reg_field::type_id::create("rfu");
         rx_data = uvm_reg_field::type_id::create("rx_data");

         rfu.configure(this, 24, 8, "RW", 0, 24'h000000, 1, 0, 1);
         rx_data.configure(this, 8, 0, "RO", 0, 8'h00, 1, 0, 1);
      endfunction
   endclass



   //--------------------------------------------------------------------
   // Class: stt_reg
   // 
   // status register
   //--------------------------------------------------------------------

   class stt_reg extends uvm_reg;
      `uvm_object_utils(stt_reg)

      uvm_reg_field rfu; // Reserved for Future Use
      uvm_reg_field parity_error; // A parity error occurs when the parity of the received character does not match the calculated parity
      uvm_reg_field rx_done; // Set to indicate that previous serial-to-parallel conversion on data received from the host is completed
      uvm_reg_field tx_done; // Set to indicate that previous parallel-to-serial conversion on data received from the host is completed


      // Function: coverage
      // 
      covergroup cg_vals;
         parity_error	 : coverpoint parity_error.value[0];
         rx_done	 : coverpoint rx_done.value[0];
         tx_done	 : coverpoint tx_done.value[0];
      endgroup



      // Function: new
      // 
      function new(string name = "stt_reg");
         super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
         add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
         if(has_coverage(UVM_CVR_FIELD_VALS))
            cg_vals = new();
      endfunction


      // Function: sample_values
      // 
      virtual function void sample_values();
         super.sample_values();
         if (get_coverage(UVM_CVR_FIELD_VALS))
            cg_vals.sample();
      endfunction


      // Function: build
      // 
      virtual function void build();
         rfu = uvm_reg_field::type_id::create("rfu");
         parity_error = uvm_reg_field::type_id::create("parity_error");
         rx_done = uvm_reg_field::type_id::create("rx_done");
         tx_done = uvm_reg_field::type_id::create("tx_done");

         rfu.configure(this, 29, 3, "RW", 0, 29'b00000000000000000000000000000, 1, 0, 0);
         parity_error.configure(this, 1, 2, "RO", 0, 1'b0, 1, 0, 0);
         rx_done.configure(this, 1, 1, "RO", 0, 1'b0, 1, 0, 0);
         tx_done.configure(this, 1, 0, "RO", 0, 1'b0, 1, 0, 0);
      endfunction
   endclass



   //--------------------------------------------------------------------
   // Class: tx_data_reg
   // 
   // TX data register
   //--------------------------------------------------------------------

   class tx_data_reg extends uvm_reg;
      `uvm_object_utils(tx_data_reg)

      uvm_reg_field rfu; // Reserved for Future Use
      rand uvm_reg_field tx_data; // Parallel data from the host which is converted to serial data sent to peripheral device


      // Function: coverage
      // 
      covergroup cg_vals;
         tx_data	 : coverpoint tx_data.value[7:0];
      endgroup



      // Function: new
      // 
      function new(string name = "tx_data_reg");
         super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
         add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
         if(has_coverage(UVM_CVR_FIELD_VALS))
            cg_vals = new();
      endfunction


      // Function: sample_values
      // 
      virtual function void sample_values();
         super.sample_values();
         if (get_coverage(UVM_CVR_FIELD_VALS))
            cg_vals.sample();
      endfunction


      // Function: build
      // 
      virtual function void build();
         rfu = uvm_reg_field::type_id::create("rfu");
         tx_data = uvm_reg_field::type_id::create("tx_data");

         rfu.configure(this, 24, 8, "RW", 0, 24'h000000, 1, 0, 1);
         tx_data.configure(this, 8, 0, "RW", 0, 8'h00, 1, 1, 1);
      endfunction
   endclass




   /* BLOCKS */



   //--------------------------------------------------------------------
   // Class: uart_regs
   // 
   //--------------------------------------------------------------------

   class uart_regs extends uvm_reg_block;
      `uvm_object_utils(uart_regs)

      rand tx_data_reg reg_tx_data_reg; // TX data register
      rand rx_data_reg reg_rx_data_reg; // RX data register
      rand cfg_reg reg_cfg_reg; // uart frame configuration
      rand ctrl_reg reg_ctrl_reg; // Operation Control Register
      rand stt_reg reg_stt_reg; // status register

      uvm_reg_map map; 


      // Function: new
      // 
      function new(string name = "uart_regs");
         super.new(name, build_coverage(UVM_CVR_ALL));
      endfunction


      // Function: build
      // 
      virtual function void build();
         reg_tx_data_reg = tx_data_reg::type_id::create("reg_tx_data_reg");
         reg_tx_data_reg.configure(this, null, "");
         reg_tx_data_reg.add_hdl_path_slice("tx_data_reg_tx_data", 0, 8);
         reg_tx_data_reg.build();

         reg_rx_data_reg = rx_data_reg::type_id::create("reg_rx_data_reg");
         reg_rx_data_reg.configure(this, null, "");
         reg_rx_data_reg.add_hdl_path_slice("rx_data_reg_rx_data", 0, 8);
         reg_rx_data_reg.build();

         reg_cfg_reg = cfg_reg::type_id::create("reg_cfg_reg");
         reg_cfg_reg.configure(this, null, "");
         reg_cfg_reg.add_hdl_path_slice("cfg_reg_parity_type", 4, 1);
         reg_cfg_reg.add_hdl_path_slice("cfg_reg_parity_en", 3, 1);
         reg_cfg_reg.add_hdl_path_slice("cfg_reg_stop_bit_num", 2, 1);
         reg_cfg_reg.add_hdl_path_slice("cfg_reg_data_bit_num", 0, 2);
         reg_cfg_reg.build();

         reg_ctrl_reg = ctrl_reg::type_id::create("reg_ctrl_reg");
         reg_ctrl_reg.configure(this, null, "");
         reg_ctrl_reg.add_hdl_path_slice("ctrl_reg_start_tx", 0, 1);
         reg_ctrl_reg.build();

         reg_stt_reg = stt_reg::type_id::create("reg_stt_reg");
         reg_stt_reg.configure(this, null, "");
         reg_stt_reg.add_hdl_path_slice("stt_reg_parity_error", 2, 1);
         reg_stt_reg.add_hdl_path_slice("stt_reg_rx_done", 1, 1);
         reg_stt_reg.add_hdl_path_slice("stt_reg_tx_done", 0, 1);
         reg_stt_reg.build();

         map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);
         default_map = map;

         map.add_reg(reg_tx_data_reg, 'h0, "RW");
         map.add_reg(reg_rx_data_reg, 'h4, "RW");
         map.add_reg(reg_cfg_reg, 'h8, "RW");
         map.add_reg(reg_ctrl_reg, 'hc, "RW");
         map.add_reg(reg_stt_reg, 'h10, "RW");

         lock_model();
      endfunction
   endclass


endpackage
