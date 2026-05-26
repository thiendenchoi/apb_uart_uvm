class apb_uart_test_read_parity_even extends apb_uart_test_base;
  `uvm_component_utils(apb_uart_test_read_parity_even)

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

  function new(string name="apb_uart_test_read_parity_even", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    tx_seq       = uart_tx_seq::type_id::create("tx_seq", this);
    rx_seq       = uart_rx_seq::type_id::create("rx_seq", this);

    seq_r_cfg     = apb_seq_read_cfg_reg::type_id::create("seq_r_cfg", this);
    seq_r_ctrl    = apb_seq_read_ctrl_reg::type_id::create("seq_r_ctrl", this);
    seq_r_stt     = apb_seq_read_stt_reg::type_id::create("seq_r_stt", this);
    seq_r_rx_data = apb_seq_read_rx_data_reg::type_id::create("seq_r_rx_data", this);
    seq_r_tx_data = apb_seq_read_tx_data_reg::type_id::create("seq_r_tx_data", this);

    seq_w_cfg     = apb_seq_write_cfg_reg::type_id::create("seq_w_cfg", this);
    seq_w_ctrl    = apb_seq_write_ctrl_reg::type_id::create("seq_w_ctrl", this);
    seq_w_tx_data = apb_seq_write_tx_data_reg::type_id::create("seq_w_tx_data", this);

    phase.raise_objection(this);
    `uvm_info("run_phase", "Starting apb_uart_test_read_parity_even (ONE ROUND)", UVM_LOW)

    // seq_r_cfg.start    (m_apb_uart_env.m_apb_agent.sequencer);
    // seq_r_ctrl.start   (m_apb_uart_env.m_apb_agent.sequencer);
    // seq_r_stt.start    (m_apb_uart_env.m_apb_agent.sequencer);
    // seq_r_rx_data.start(m_apb_uart_env.m_apb_agent.sequencer);
    // seq_r_tx_data.start(m_apb_uart_env.m_apb_agent.sequencer);

    m_apb_uart_env.m_uart_config.data_bit_num  = DATA_8_BIT;
    m_apb_uart_env.m_uart_config.parity_bit_en = PARITY_EN;
    m_apb_uart_env.m_uart_config.parity_bit_type = PARITY_EVEN; 
    m_apb_uart_env.m_uart_config.stop_bit_num  = STOP_1_BIT;

    assert(seq_w_cfg.randomize() with {
      data_bit_num == 2'b11; 
      parity_en    == 1'b1;
      parity_type  == 1'b1;
      stop_bit_num == 1'b0;  
    }) else `uvm_fatal("RAND", "seq_w_cfg randomize failed");
    seq_w_cfg.start(m_apb_uart_env.m_apb_agent.sequencer);

    tx_seq.data_in = 8'h55;
    tx_seq.start(m_apb_uart_env.m_uart_tx_agent.tx_sequencer);

    // seq_w_tx_data.tx_data = 8'h41;
    // seq_w_tx_data.start(m_apb_uart_env.m_apb_agent.sequencer);

    // seq_w_ctrl.start_tx = 1'b1;
    // seq_w_ctrl.start(m_apb_uart_env.m_apb_agent.sequencer);

    // rx_seq.data_reg = 8'h41;
    // rx_seq.start(m_apb_uart_env.m_uart_rx_agent.rx_sequencer);

    // #2ns;

    seq_r_rx_data = apb_seq_read_rx_data_reg::type_id::create("seq_r_rx_data_after", this);
    seq_r_rx_data.start(m_apb_uart_env.m_apb_agent.sequencer);

    seq_r_stt = apb_seq_read_stt_reg::type_id::create("seq_r_stt_after", this);
    seq_r_stt.start(m_apb_uart_env.m_apb_agent.sequencer);

    if(seq_r_stt.value[2] == 1)
      `uvm_error("READ", "PARITY ERROR")

    `uvm_info("run_phase", "Ending apb_uart_test_read_parity_even", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass
