#ifndef _UART_REGS_H
#define _UART_REGS_H

#include <stdint.h>


/************************ DEFINE ACCESS RIGHTS ************************/
#define __RW volatile       /* read/write permissions */


/********************** DEFINE READ/WRITE MACROS **********************/
#define REGISTER_BLOCK_READ32(reg, mask, offset)\
     (((reg) & (mask)) >> (offset))
#define REGISTER_BLOCK_WRITE32(reg, mask, offset, data)\
     (((reg) & ~(mask)) | (((uint32_t)data << (offset))))


/********************** DEFINE HIERARCHY LEVELS ***********************/
/* uart_regs (Size: 0x14) */
typedef struct uart_regs_s
{
   /* TX data register */
   __RW uint32_t   reg_tx_data_reg;    /* 0x3:0x0   */
   /* RX data register */
   __RW uint32_t   reg_rx_data_reg;    /* 0x7:0x4   */
   /* uart frame configuration */
   __RW uint32_t   reg_cfg_reg;        /* 0xB:0x8   */
   /* Operation Control Register */
   __RW uint32_t   reg_ctrl_reg;       /* 0xF:0xC   */
   /* status register */
   __RW uint32_t   reg_stt_reg;        /* 0x13:0x10 */
} __RW uart_regs_s, *uart_regs_ptr;




/************************** DEFINE TOP BLOCK **************************/
#define UART_REGS__BASE 0x0
uart_regs_ptr uart_regs = UART_REGS__BASE;

/**************************** DEFINE FIELDS ***************************/

/*--------------------------------------------------------------------
 *  Register: tx_data_reg
 *    TX data register
 *    SW Access     : read-write
 *    HW Access     : read-write
 * 
 *  Fields:
 *       7:0  tx_data (SW:read-write, HW:read-only)            
 *       31:8 rfu     (SW:read-write, HW:read-write) (RESERVED)
 */
/*--------------------------------------------------------------------
 *    Field: tx_data
 *    Width: 8,              Offset: 0
 *    SW Access: read-write, HW Access: read-only
 *--------------------------------------------------------------------
 *  Parallel data from the host which is converted to serial data sent to peripheral device
 */
#define TX_DATA_REG__TX_DATA__MASK 0x000000FF
#define TX_DATA_REG__TX_DATA__OFFSET 0
#define TX_DATA_REG__TX_DATA__GET(reg)\
         REGISTER_BLOCK_READ32(reg, TX_DATA_REG__TX_DATA__MASK, TX_DATA_REG__TX_DATA__OFFSET)
#define TX_DATA_REG__TX_DATA__SET(reg, data)\
         REGISTER_BLOCK_WRITE32(reg, TX_DATA_REG__TX_DATA__MASK, TX_DATA_REG__TX_DATA__OFFSET, data)

/*--------------------------------------------------------------------
 *    Field: rfu (RESERVED)
 *    Width: 24,             Offset: 8
 *    SW Access: read-write, HW Access: read-write
 *--------------------------------------------------------------------
 *  Reserved for Future Use
 */
#define TX_DATA_REG__RFU__MASK 0xFFFFFF00
#define TX_DATA_REG__RFU__OFFSET 8

/*--------------------------------------------------------------------
 *  Register: rx_data_reg
 *    RX data register
 *    SW Access     : read-write
 *    HW Access     : read-write
 * 
 *  Fields:
 *       7:0  rx_data (SW:read-only,  HW:write-only)           
 *       31:8 rfu     (SW:read-write, HW:read-write) (RESERVED)
 */
/*--------------------------------------------------------------------
 *    Field: rx_data
 *    Width: 8,             Offset: 0
 *    SW Access: read-only, HW Access: write-only
 *--------------------------------------------------------------------
 *  Parallel data archived after serial-to-parallel coversation on data received on peripheral device
 */
#define RX_DATA_REG__RX_DATA__MASK 0x000000FF
#define RX_DATA_REG__RX_DATA__OFFSET 0
#define RX_DATA_REG__RX_DATA__GET(reg)\
         REGISTER_BLOCK_READ32(reg, RX_DATA_REG__RX_DATA__MASK, RX_DATA_REG__RX_DATA__OFFSET)

/*--------------------------------------------------------------------
 *    Field: rfu (RESERVED)
 *    Width: 24,             Offset: 8
 *    SW Access: read-write, HW Access: read-write
 *--------------------------------------------------------------------
 *  Reserved for Future Use
 */
#define RX_DATA_REG__RFU__MASK 0xFFFFFF00
#define RX_DATA_REG__RFU__OFFSET 8

/*--------------------------------------------------------------------
 *  Register: cfg_reg
 *    uart frame configuration
 *    SW Access     : read-write
 *    HW Access     : read-write
 * 
 *  Fields:
 *       1:0  data_bit_num (SW:read-write, HW:read-only)            
 *       2    stop_bit_num (SW:read-write, HW:read-only)            
 *       3    parity_en    (SW:read-write, HW:read-only)            
 *       4    parity_type  (SW:read-write, HW:read-only)            
 *       31:5 rfu          (SW:read-write, HW:read-write) (RESERVED)
 */
/*--------------------------------------------------------------------
 *    Field: data_bit_num
 *    Width: 2,              Offset: 0
 *    SW Access: read-write, HW Access: read-only
 *--------------------------------------------------------------------
 *  The number of data bits
 *  2’b00: 5 bits
 *  2’b01: 6 bits
 *  2’b10: 7 bits
 *  2’b11: 8 bits
 */
#define CFG_REG__DATA_BIT_NUM__MASK 0x00000003
#define CFG_REG__DATA_BIT_NUM__OFFSET 0
#define CFG_REG__DATA_BIT_NUM__GET(reg)\
         REGISTER_BLOCK_READ32(reg, CFG_REG__DATA_BIT_NUM__MASK, CFG_REG__DATA_BIT_NUM__OFFSET)
#define CFG_REG__DATA_BIT_NUM__SET(reg, data)\
         REGISTER_BLOCK_WRITE32(reg, CFG_REG__DATA_BIT_NUM__MASK, CFG_REG__DATA_BIT_NUM__OFFSET, data)

/*--------------------------------------------------------------------
 *    Field: stop_bit_num
 *    Width: 1,              Offset: 2
 *    SW Access: read-write, HW Access: read-only
 *--------------------------------------------------------------------
 *  The number of stop bits
 */
#define CFG_REG__STOP_BIT_NUM__MASK 0x00000004
#define CFG_REG__STOP_BIT_NUM__OFFSET 2
#define CFG_REG__STOP_BIT_NUM__GET(reg)\
         REGISTER_BLOCK_READ32(reg, CFG_REG__STOP_BIT_NUM__MASK, CFG_REG__STOP_BIT_NUM__OFFSET)
#define CFG_REG__STOP_BIT_NUM__SET(reg, data)\
         REGISTER_BLOCK_WRITE32(reg, CFG_REG__STOP_BIT_NUM__MASK, CFG_REG__STOP_BIT_NUM__OFFSET, data)

/*--------------------------------------------------------------------
 *    Field: parity_en
 *    Width: 1,              Offset: 3
 *    SW Access: read-write, HW Access: read-only
 *--------------------------------------------------------------------
 *  parity_en
 */
#define CFG_REG__PARITY_EN__MASK 0x00000008
#define CFG_REG__PARITY_EN__OFFSET 3
#define CFG_REG__PARITY_EN__GET(reg)\
         REGISTER_BLOCK_READ32(reg, CFG_REG__PARITY_EN__MASK, CFG_REG__PARITY_EN__OFFSET)
#define CFG_REG__PARITY_EN__SET(reg, data)\
         REGISTER_BLOCK_WRITE32(reg, CFG_REG__PARITY_EN__MASK, CFG_REG__PARITY_EN__OFFSET, data)

/*--------------------------------------------------------------------
 *    Field: parity_type
 *    Width: 1,              Offset: 4
 *    SW Access: read-write, HW Access: read-only
 *--------------------------------------------------------------------
 *  parity_type
 */
#define CFG_REG__PARITY_TYPE__MASK 0x00000010
#define CFG_REG__PARITY_TYPE__OFFSET 4
#define CFG_REG__PARITY_TYPE__GET(reg)\
         REGISTER_BLOCK_READ32(reg, CFG_REG__PARITY_TYPE__MASK, CFG_REG__PARITY_TYPE__OFFSET)
#define CFG_REG__PARITY_TYPE__SET(reg, data)\
         REGISTER_BLOCK_WRITE32(reg, CFG_REG__PARITY_TYPE__MASK, CFG_REG__PARITY_TYPE__OFFSET, data)

/*--------------------------------------------------------------------
 *    Field: rfu (RESERVED)
 *    Width: 27,             Offset: 5
 *    SW Access: read-write, HW Access: read-write
 *--------------------------------------------------------------------
 *  Reserved for Future Use
 */
#define CFG_REG__RFU__MASK 0xFFFFFFE0
#define CFG_REG__RFU__OFFSET 5

/*--------------------------------------------------------------------
 *  Register: ctrl_reg
 *    Operation Control Register
 *    SW Access     : read-write
 *    HW Access     : read-write
 * 
 *  Fields:
 *       0    start_tx (SW:read-write, HW:read-only)            
 *       31:1 rfu      (SW:read-write, HW:read-write) (RESERVED)
 */
/*--------------------------------------------------------------------
 *    Field: start_tx
 *    Width: 1,              Offset: 0
 *    SW Access: read-write, HW Access: read-only
 *--------------------------------------------------------------------
 *  Set to start coverting parallel data received from the host to serial data sent to peripheral device
 */
#define CTRL_REG__START_TX__MASK 0x00000001
#define CTRL_REG__START_TX__OFFSET 0
#define CTRL_REG__START_TX__GET(reg)\
         REGISTER_BLOCK_READ32(reg, CTRL_REG__START_TX__MASK, CTRL_REG__START_TX__OFFSET)
#define CTRL_REG__START_TX__SET(reg, data)\
         REGISTER_BLOCK_WRITE32(reg, CTRL_REG__START_TX__MASK, CTRL_REG__START_TX__OFFSET, data)

/*--------------------------------------------------------------------
 *    Field: rfu (RESERVED)
 *    Width: 31,             Offset: 1
 *    SW Access: read-write, HW Access: read-write
 *--------------------------------------------------------------------
 *  Reserved for Future Use
 */
#define CTRL_REG__RFU__MASK 0xFFFFFFFE
#define CTRL_REG__RFU__OFFSET 1

/*--------------------------------------------------------------------
 *  Register: stt_reg
 *    status register
 *    SW Access     : read-write
 *    HW Access     : read-write
 * 
 *  Fields:
 *       0    tx_done      (SW:read-only,  HW:write-only)           
 *       1    rx_done      (SW:read-only,  HW:write-only)           
 *       2    parity_error (SW:read-only,  HW:write-only)           
 *       31:3 rfu          (SW:read-write, HW:read-write) (RESERVED)
 */
/*--------------------------------------------------------------------
 *    Field: tx_done
 *    Width: 1,             Offset: 0
 *    SW Access: read-only, HW Access: write-only
 *--------------------------------------------------------------------
 *  Set to indicate that previous parallel-to-serial conversion on data received from the host is completed
 */
#define STT_REG__TX_DONE__MASK 0x00000001
#define STT_REG__TX_DONE__OFFSET 0
#define STT_REG__TX_DONE__GET(reg)\
         REGISTER_BLOCK_READ32(reg, STT_REG__TX_DONE__MASK, STT_REG__TX_DONE__OFFSET)

/*--------------------------------------------------------------------
 *    Field: rx_done
 *    Width: 1,             Offset: 1
 *    SW Access: read-only, HW Access: write-only
 *--------------------------------------------------------------------
 *  Set to indicate that previous serial-to-parallel conversion on data received from the host is completed
 */
#define STT_REG__RX_DONE__MASK 0x00000002
#define STT_REG__RX_DONE__OFFSET 1
#define STT_REG__RX_DONE__GET(reg)\
         REGISTER_BLOCK_READ32(reg, STT_REG__RX_DONE__MASK, STT_REG__RX_DONE__OFFSET)

/*--------------------------------------------------------------------
 *    Field: parity_error
 *    Width: 1,             Offset: 2
 *    SW Access: read-only, HW Access: write-only
 *--------------------------------------------------------------------
 *  A parity error occurs when the parity of the received character does not match the calculated parity
 */
#define STT_REG__PARITY_ERROR__MASK 0x00000004
#define STT_REG__PARITY_ERROR__OFFSET 2
#define STT_REG__PARITY_ERROR__GET(reg)\
         REGISTER_BLOCK_READ32(reg, STT_REG__PARITY_ERROR__MASK, STT_REG__PARITY_ERROR__OFFSET)

/*--------------------------------------------------------------------
 *    Field: rfu (RESERVED)
 *    Width: 29,             Offset: 3
 *    SW Access: read-write, HW Access: read-write
 *--------------------------------------------------------------------
 *  Reserved for Future Use
 */
#define STT_REG__RFU__MASK 0xFFFFFFF8
#define STT_REG__RFU__OFFSET 3



#endif
