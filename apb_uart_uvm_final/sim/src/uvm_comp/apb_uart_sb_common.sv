localparam bit [11:0] TX_DATA_ADDR = 12'h000; // 0x0
localparam bit [11:0] RX_DATA_ADDR = 12'h004; // 0x4
localparam bit [11:0] CFG_ADDR     = 12'h008; // 0x8
localparam bit [11:0] CTRL_ADDR    = 12'h00C; // 0xC
localparam bit [11:0] SS_ADDR      = 12'h010; // 0x10

function automatic byte unsigned apb_get_byte_from_wdata(apb_item t);
  return t.pwdata[7:0];
endfunction

function automatic byte unsigned apb_get_byte_from_rdata(apb_item t);
  return t.prdata[7:0];
endfunction
