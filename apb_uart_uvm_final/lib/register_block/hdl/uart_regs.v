module uart_regs
#(
  parameter ADDR_WIDTH=5,
  parameter DATA_WIDTH=32
)
(

  // FIELD OUTPUT PORTS
  output reg   [7:0] tx_data_reg_tx_data_reg ,
  output reg         parity_type_reg_cfg_reg ,
  output reg         parity_en_reg_cfg_reg   ,
  output reg         stop_bit_num_reg_cfg_reg,
  output reg   [1:0] data_bit_num_reg_cfg_reg,
  output reg         start_tx_reg_ctrl_reg   ,

  // FIELD INPUT PORTS
  input wire   [7:0] rx_data_reg_rx_data_reg_ip ,
  input wire         parity_error_reg_stt_reg_ip,
  input wire         rx_done_reg_stt_reg_ip     ,
  input wire         tx_done_reg_stt_reg_ip     ,

  // GENERIC BUS PORTS
  input  wire                  clock   , // Register Bus Clock
  input  wire                  reset   , // Register Bus Reset
  input  wire [ADDR_WIDTH-1:0] waddr   , // Write Address-Bus
  input  wire [ADDR_WIDTH-1:0] raddr   , // Read Address-Bus
  input  wire [DATA_WIDTH-1:0] wdata   , // Write Data-Bus
  output reg  [DATA_WIDTH-1:0] rdata   , // Read Data-Bus
  input  wire                  rstrobe , // Read-Strobe
  input  wire                  wstrobe , // Write-Strobe
  output reg                   raddrerr, // Read-Address-Error
  output reg                   waddrerr, // Write-Address-Error
  output reg                   wack    , // Write Acknowledge
  output reg                   rack      // Read Acknowledge
);

  // READ/WRITE ENABLE SIGNALS
  reg  wen_reg_tx_data_reg;
  reg  wen_reg_cfg_reg    ;
  reg  wen_reg_ctrl_reg   ;

  // MUX INPUTS FOR EACH INSTANCE WITH READ ACCESS
  wire [DATA_WIDTH-1:0] rmux_reg_tx_data_reg;
  wire [DATA_WIDTH-1:0] rmux_reg_rx_data_reg;
  wire [DATA_WIDTH-1:0] rmux_reg_cfg_reg    ;
  wire [DATA_WIDTH-1:0] rmux_reg_ctrl_reg   ;
  wire [DATA_WIDTH-1:0] rmux_reg_stt_reg    ;

  // FLIP-FLOP SIGNALS
  reg  [7:0] rx_data_reg_rx_data_reg_local ;
  reg        parity_error_reg_stt_reg_local;
  reg        rx_done_reg_stt_reg_local     ;
  reg        tx_done_reg_stt_reg_local     ;

  // DEFAULT VALUE FOR READ DATA BUS
  localparam DEF_RDATA_VAL = 32'h00000000;

  // ADDRESS PARAMETERS
  localparam REG_TX_DATA_REG_ADDR = 5'h00;
  localparam REG_RX_DATA_REG_ADDR = 5'h04;
  localparam REG_CFG_REG_ADDR = 5'h08;
  localparam REG_CTRL_REG_ADDR = 5'h0C;
  localparam REG_STT_REG_ADDR = 5'h10;

  //----------------------------------------------------------------------
  //                    WRITE ADDRESS DECODE
  //----------------------------------------------------------------------
  always @ ( * )
  begin : write_enable
    wen_reg_tx_data_reg = 1'b0;
    wen_reg_cfg_reg = 1'b0;
    wen_reg_ctrl_reg = 1'b0;
    waddrerr = 1'b0;
    wack = 1'b0;

    if (wstrobe)
    begin
      case (waddr)
        REG_TX_DATA_REG_ADDR:
        begin
          wen_reg_tx_data_reg = 1'b1;
        end
        REG_CFG_REG_ADDR:
        begin
          wen_reg_cfg_reg = 1'b1;
        end
        REG_CTRL_REG_ADDR:
        begin
          wen_reg_ctrl_reg = 1'b1;
        end
        default:
        begin
          waddrerr = 1'b1;
        end
      endcase
      wack = 1'b1;
    end
  end


  //------------------------------------------------------------
  // Register: tx_data_reg
  //   TX data register
  //   SW Access     : read-write
  //   Address Offset: 0x0
  //   HW Access     : read-write
  // 
  // Instance: reg_tx_data_reg
  //   TX data register
  //   Address Offset: 0x0
  //   Reset Value   : 
  // 
  // Fields:
  //   31:8  rfu (SW:read-write, HW:read-write) (RESERVED) 
  //   7:0  tx_data (SW:read-write, HW:read-only)

  //------------------------------------------------------------
  //   Field: rfu (reserved)                          
  //   Width: 24             , Offset: 8              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  //   Reserved for Future Use
  //

  //------------------------------------------------------------
  //   Field: tx_data                                
  //   Width: 8              , Offset: 0             
  //   SW Access: read-write , HW Access: read-only  
  //------------------------------------------------------------
  //   Parallel data from the host which is converted to serial data sent to peripheral device
  //
  always @ (posedge clock or negedge reset)
  begin : reg_tx_data_reg_tx_data_reg_tx_data_reg
    // Reset
    if ( !reset )
      tx_data_reg_tx_data_reg <= 8'h00;
    // SW:read-write
    else if (wen_reg_tx_data_reg)
      tx_data_reg_tx_data_reg <= wdata[7:0];
  end


  //------------------------------------------------------------
  // Register: rx_data_reg
  //   RX data register
  //   SW Access     : read-write
  //   Address Offset: 0x4
  //   HW Access     : read-write
  // 
  // Instance: reg_rx_data_reg
  //   RX data register
  //   Address Offset: 0x4
  //   Reset Value   : 
  // 
  // Fields:
  //   31:8  rfu (SW:read-write, HW:read-write) (RESERVED) 
  //   7:0  rx_data (SW:read-only, HW:write-only)

  //------------------------------------------------------------
  //   Field: rfu (reserved)                          
  //   Width: 24             , Offset: 8              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  //   Reserved for Future Use
  //

  //------------------------------------------------------------
  //   Field: rx_data                                
  //   Width: 8             , Offset: 0              
  //   SW Access: read-only , HW Access: write-only  
  //------------------------------------------------------------
  //   Parallel data archived after serial-to-parallel coversation on data received on peripheral device
  //
  always @ (posedge clock or negedge reset)
  begin : reg_rx_data_reg_rx_data_reg_rx_data_reg_local
    // Reset
    if ( !reset )
      rx_data_reg_rx_data_reg_local <= 8'h00;
    // HW:write-only
    else
      rx_data_reg_rx_data_reg_local <= rx_data_reg_rx_data_reg_ip;
  end


  //------------------------------------------------------------
  // Register: cfg_reg
  //   uart frame configuration
  //   SW Access     : read-write
  //   Address Offset: 0x8
  //   HW Access     : read-write
  // 
  // Instance: reg_cfg_reg
  //   uart frame configuration
  //   Address Offset: 0x8
  //   Reset Value   : 
  // 
  // Fields:
  //   31:5  rfu (SW:read-write, HW:read-write) (RESERVED) 
  //     4  parity_type (SW:read-write, HW:read-only)
  //     3  parity_en (SW:read-write, HW:read-only)
  //     2  stop_bit_num (SW:read-write, HW:read-only)
  //   1:0  data_bit_num (SW:read-write, HW:read-only)

  //------------------------------------------------------------
  //   Field: rfu (reserved)                          
  //   Width: 27             , Offset: 5              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  //   Reserved for Future Use
  //

  //------------------------------------------------------------
  //   Field: parity_type                            
  //   Width: 1              , Offset: 4             
  //   SW Access: read-write , HW Access: read-only  
  //------------------------------------------------------------
  //   parity_type
  //
  always @ (posedge clock or negedge reset)
  begin : reg_cfg_reg_parity_type_reg_cfg_reg
    // Reset
    if ( !reset )
      parity_type_reg_cfg_reg <= 1'b0;
    // SW:read-write
    else if (wen_reg_cfg_reg)
      parity_type_reg_cfg_reg <= wdata[4];
  end

  //------------------------------------------------------------
  //   Field: parity_en                              
  //   Width: 1              , Offset: 3             
  //   SW Access: read-write , HW Access: read-only  
  //------------------------------------------------------------
  //   parity_en
  //
  always @ (posedge clock or negedge reset)
  begin : reg_cfg_reg_parity_en_reg_cfg_reg
    // Reset
    if ( !reset )
      parity_en_reg_cfg_reg <= 1'b0;
    // SW:read-write
    else if (wen_reg_cfg_reg)
      parity_en_reg_cfg_reg <= wdata[3];
  end

  //------------------------------------------------------------
  //   Field: stop_bit_num                           
  //   Width: 1              , Offset: 2             
  //   SW Access: read-write , HW Access: read-only  
  //------------------------------------------------------------
  //   The number of stop bits
  //
  always @ (posedge clock or negedge reset)
  begin : reg_cfg_reg_stop_bit_num_reg_cfg_reg
    // Reset
    if ( !reset )
      stop_bit_num_reg_cfg_reg <= 1'b0;
    // SW:read-write
    else if (wen_reg_cfg_reg)
      stop_bit_num_reg_cfg_reg <= wdata[2];
  end

  //------------------------------------------------------------
  //   Field: data_bit_num                           
  //   Width: 2              , Offset: 0             
  //   SW Access: read-write , HW Access: read-only  
  //------------------------------------------------------------
  //   The number of data bits
  //   2’b00: 5 bits
  //   2’b01: 6 bits
  //   2’b10: 7 bits
  //   2’b11: 8 bits
  //
  always @ (posedge clock or negedge reset)
  begin : reg_cfg_reg_data_bit_num_reg_cfg_reg
    // Reset
    if ( !reset )
      data_bit_num_reg_cfg_reg <= 2'b11;
    // SW:read-write
    else if (wen_reg_cfg_reg)
      data_bit_num_reg_cfg_reg <= wdata[1:0];
  end


  //------------------------------------------------------------
  // Register: ctrl_reg
  //   Operation Control Register
  //   SW Access     : read-write
  //   Address Offset: 0xC
  //   HW Access     : read-write
  // 
  // Instance: reg_ctrl_reg
  //   Operation Control Register
  //   Address Offset: 0xC
  //   Reset Value   : 
  // 
  // Fields:
  //   31:1  rfu (SW:read-write, HW:read-write) (RESERVED) 
  //     0  start_tx (SW:read-write, HW:read-only)

  //------------------------------------------------------------
  //   Field: rfu (reserved)                          
  //   Width: 31             , Offset: 1              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  //   Reserved for Future Use
  //

  //------------------------------------------------------------
  //   Field: start_tx                               
  //   Width: 1              , Offset: 0             
  //   SW Access: read-write , HW Access: read-only  
  //------------------------------------------------------------
  //   Set to start coverting parallel data received from the host to serial data sent to peripheral device
  //
  always @ (posedge clock or negedge reset)
  begin : reg_ctrl_reg_start_tx_reg_ctrl_reg
    // Reset
    if ( !reset )
      start_tx_reg_ctrl_reg <= 1'b0;
    // SW:read-write
    else if (wen_reg_ctrl_reg)
      start_tx_reg_ctrl_reg <= wdata[0];
  end


  //------------------------------------------------------------
  // Register: stt_reg
  //   status register
  //   SW Access     : read-write
  //   Address Offset: 0x10
  //   HW Access     : read-write
  // 
  // Instance: reg_stt_reg
  //   status register
  //   Address Offset: 0x10
  //   Reset Value   : 
  // 
  // Fields:
  //   31:3  rfu (SW:read-write, HW:read-write) (RESERVED) 
  //     2  parity_error (SW:read-only, HW:write-only)
  //     1  rx_done (SW:read-only, HW:write-only)
  //     0  tx_done (SW:read-only, HW:write-only)

  //------------------------------------------------------------
  //   Field: rfu (reserved)                          
  //   Width: 29             , Offset: 3              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  //   Reserved for Future Use
  //

  //------------------------------------------------------------
  //   Field: parity_error                           
  //   Width: 1             , Offset: 2              
  //   SW Access: read-only , HW Access: write-only  
  //------------------------------------------------------------
  //   A parity error occurs when the parity of the received character does not match the calculated parity
  //
  always @ (posedge clock or negedge reset)
  begin : reg_stt_reg_parity_error_reg_stt_reg_local
    // Reset
    if ( !reset )
      parity_error_reg_stt_reg_local <= 1'b0;
    // HW:write-only
    else
      parity_error_reg_stt_reg_local <= parity_error_reg_stt_reg_ip;
  end

  //------------------------------------------------------------
  //   Field: rx_done                                
  //   Width: 1             , Offset: 1              
  //   SW Access: read-only , HW Access: write-only  
  //------------------------------------------------------------
  //   Set to indicate that previous serial-to-parallel conversion on data received from the host is completed
  //
  always @ (posedge clock or negedge reset)
  begin : reg_stt_reg_rx_done_reg_stt_reg_local
    // Reset
    if ( !reset )
      rx_done_reg_stt_reg_local <= 1'b0;
    // HW:write-only
    else
      rx_done_reg_stt_reg_local <= rx_done_reg_stt_reg_ip;
  end

  //------------------------------------------------------------
  //   Field: tx_done                                
  //   Width: 1             , Offset: 0              
  //   SW Access: read-only , HW Access: write-only  
  //------------------------------------------------------------
  //   Set to indicate that previous parallel-to-serial conversion on data received from the host is completed
  //
  always @ (posedge clock or negedge reset)
  begin : reg_stt_reg_tx_done_reg_stt_reg_local
    // Reset
    if ( !reset )
      tx_done_reg_stt_reg_local <= 1'b0;
    // HW:write-only
    else
      tx_done_reg_stt_reg_local <= tx_done_reg_stt_reg_ip;
  end


  //----------------------------------------------------------------------
  //                    READ BUS MULTIPLEXER
  //----------------------------------------------------------------------
  assign rmux_reg_tx_data_reg[31:8] = DEF_RDATA_VAL[31:8]; // Default read value for RESERVED field - rfu
  assign rmux_reg_tx_data_reg[7:0] = tx_data_reg_tx_data_reg;

  assign rmux_reg_rx_data_reg[31:8] = DEF_RDATA_VAL[31:8]; // Default read value for RESERVED field - rfu
  assign rmux_reg_rx_data_reg[7:0] = rx_data_reg_rx_data_reg_local;

  assign rmux_reg_cfg_reg[31:5] = DEF_RDATA_VAL[31:5]; // Default read value for RESERVED field - rfu
  assign rmux_reg_cfg_reg[4] = parity_type_reg_cfg_reg;
  assign rmux_reg_cfg_reg[3] = parity_en_reg_cfg_reg;
  assign rmux_reg_cfg_reg[2] = stop_bit_num_reg_cfg_reg;
  assign rmux_reg_cfg_reg[1:0] = data_bit_num_reg_cfg_reg;

  assign rmux_reg_ctrl_reg[31:1] = DEF_RDATA_VAL[31:1]; // Default read value for RESERVED field - rfu
  assign rmux_reg_ctrl_reg[0] = start_tx_reg_ctrl_reg;

  assign rmux_reg_stt_reg[31:3] = DEF_RDATA_VAL[31:3]; // Default read value for RESERVED field - rfu
  assign rmux_reg_stt_reg[2] = parity_error_reg_stt_reg_local;
  assign rmux_reg_stt_reg[1] = rx_done_reg_stt_reg_local;
  assign rmux_reg_stt_reg[0] = tx_done_reg_stt_reg_local;

  // PUT REGISTER VALUE ON READ DATA BUS
  always @ ( * )
  begin : read_bus_mux
    raddrerr = 1'b0;
    rdata = DEF_RDATA_VAL;
    if (rstrobe )
    begin
      case (raddr)
        REG_TX_DATA_REG_ADDR:
        begin
          rdata = rmux_reg_tx_data_reg;
        end
        REG_RX_DATA_REG_ADDR:
        begin
          rdata = rmux_reg_rx_data_reg;
        end
        REG_CFG_REG_ADDR:
        begin
          rdata = rmux_reg_cfg_reg;
        end
        REG_CTRL_REG_ADDR:
        begin
          rdata = rmux_reg_ctrl_reg;
        end
        REG_STT_REG_ADDR:
        begin
          rdata = rmux_reg_stt_reg;
        end
        default:
        begin
          raddrerr = 1'b1;
        end
      endcase
    end
    rack = rstrobe;
  end
endmodule

