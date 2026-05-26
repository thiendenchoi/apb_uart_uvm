class apb_uart_test_simple extends apb_uart_test_base;

  `uvm_component_utils(apb_uart_test_simple)

  uart_tx_seq               tx_seq;
  uart_rx_seq               rx_seq;
  apb_seq_read_cfg_reg      seq_r_cfg;
  apb_seq_read_ctrl_reg     seq_r_ctrl;
  apb_seq_read_stt_reg      seq_r_stt;
  apb_seq_read_rx_data_reg  seq_r_rx_data;
  apb_seq_read_tx_data_reg  seq_r_tx_data;
  apb_seq_write_cfg_reg     seq_w_cfg;
  apb_seq_write_ctrl_reg    seq_w_ctrl;
  apb_seq_write_tx_data_reg seq_w_tx_data;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    tx_seq = uart_tx_seq::type_id::create("tx_seq",this);
    rx_seq = uart_rx_seq::type_id::create("rx_seq",this);
    phase.raise_objection(this);
    
    m_apb_uart_env.m_uart_config.data_bit_num  = DATA_8_BIT;
    m_apb_uart_env.m_uart_config.parity_bit_en = PARITY_DIS;
    m_apb_uart_env.m_uart_config.stop_bit_num  = STOP_2_BIT;

    seq_r_cfg  = apb_seq_read_cfg_reg::type_id::create("seq_r_cfg");
    seq_r_ctrl = apb_seq_read_ctrl_reg::type_id::create("seq_r_ctrl");
    seq_r_stt  = apb_seq_read_stt_reg::type_id::create("seq_r_stt");
    seq_r_rx_data = apb_seq_read_rx_data_reg::type_id::create("seq_r_rx_data");
    seq_r_tx_data = apb_seq_read_tx_data_reg::type_id::create("seq_r_tx_data");

    seq_r_cfg.start(m_apb_uart_env.m_apb_agent.sequencer);
    seq_r_ctrl.start(m_apb_uart_env.m_apb_agent.sequencer);
    seq_r_stt.start(m_apb_uart_env.m_apb_agent.sequencer);

    fork
      rx_seq.start(m_apb_uart_env.m_uart_rx_agent.rx_sequencer);
      begin
        #1;
        seq_w_cfg = apb_seq_write_cfg_reg::type_id::create("seq_w_cfg");
        void'(seq_w_cfg.randomize() with{stop_bit_num == 1'b1; parity_en == 1'b0; data_bit_num == 2'b11;});
        seq_w_cfg.start(m_apb_uart_env.m_apb_agent.sequencer);

        seq_w_tx_data = apb_seq_write_tx_data_reg::type_id::create("seq_w_tx_data");
        seq_w_tx_data.tx_data = 8'h55;
        seq_w_tx_data.start(m_apb_uart_env.m_apb_agent.sequencer);

        seq_w_ctrl = apb_seq_write_ctrl_reg::type_id::create("seq_w_ctrl");
        seq_w_ctrl.start_tx = 1'h1;
        seq_w_ctrl.start(m_apb_uart_env.m_apb_agent.sequencer);
      end
      begin
        tx_seq.data_in = 8'h55;
        tx_seq.start(m_apb_uart_env.m_uart_tx_agent.tx_sequencer);
      end
    join

    repeat (50) begin
      seq_r_stt.start(m_apb_uart_env.m_apb_agent.sequencer);
      #1;
    end

    seq_r_rx_data.start(m_apb_uart_env.m_apb_agent.sequencer);

    m_apb_uart_env.m_uart_config.data_bit_num  = DATA_8_BIT;
    m_apb_uart_env.m_uart_config.parity_bit_en = PARITY_EN;
    m_apb_uart_env.m_uart_config.parity_bit_type = PARITY_ODD;
    m_apb_uart_env.m_uart_config.stop_bit_num  = STOP_1_BIT;

    fork
      rx_seq.start(m_apb_uart_env.m_uart_rx_agent.rx_sequencer);
      begin
        #1;
        void'(seq_w_cfg.randomize() with{stop_bit_num == 1'b0; parity_en == 1'b1; parity_type == 1'b0; data_bit_num == 2'b11;});
        seq_w_cfg.start(m_apb_uart_env.m_apb_agent.sequencer);

        seq_w_tx_data.tx_data  = 8'h55;
        seq_w_tx_data.start(m_apb_uart_env.m_apb_agent.sequencer);

        seq_w_ctrl.start_tx = 1'b1;
        seq_w_ctrl.start(m_apb_uart_env.m_apb_agent.sequencer);
      end
      begin
        tx_seq.data_in = 8'h55;
        tx_seq.start(m_apb_uart_env.m_uart_tx_agent.tx_sequencer);
      end
    join

    repeat (50) begin
      seq_r_stt.start(m_apb_uart_env.m_apb_agent.sequencer);
      #1;
    end
    seq_r_rx_data.start(m_apb_uart_env.m_apb_agent.sequencer);
    seq_r_stt.start(m_apb_uart_env.m_apb_agent.sequencer);

    phase.drop_objection(this);
  endtask : run_phase

endclass