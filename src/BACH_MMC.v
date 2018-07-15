module BACH_MMC (
    input Clk,
    input Rstn,
    //D0 interface
    input [22:0]  d0_AvlAddress,
    output        d0_AvlWaitRequest,
    input [2:0]   d0_AvlBurstCount,
    input [3:0]   d0_AvlByteEnable,
    input         d0_AvlBeginBurstTransfer,
    input         d0_AvlRead,
    output [31:0] d0_AvlReadData,
    output        d0_AvlReadDataValid,
    input         d0_AvlWrite,
    input [31:0]  d0_AvlWriteData,
    //D1 interface
    input [22:0]  d1_AvlAddress,
    output        d1_AvlWaitRequest,
    input [2:0]   d1_AvlBurstCount,
    input [3:0]   d1_AvlByteEnable,
    input         d1_AvlBeginBurstTransfer,
    input         d1_AvlRead,
    output [31:0] d1_AvlReadData,
    output        d1_AvlReadDataValid,
    input         d1_AvlWrite,
    input [31:0]  d1_AvlWriteData,
    //D2 interface
    input [22:0]  d2_AvlAddress,
    output        d2_AvlWaitRequest,
    input [2:0]   d2_AvlBurstCount,
    input [3:0]   d2_AvlByteEnable,
    input         d2_AvlBeginBurstTransfer,
    input         d2_AvlRead,
    output [31:0] d2_AvlReadData,
    output        d2_AvlReadDataValid,
    input         d2_AvlWrite,
    input [31:0]  d2_AvlWriteData,
    //DI interface
    output [22:0] di_AvlAddress,
    input         di_AvlWaitRequest,
    output [2:0]  di_AvlBurstCount,
    output [3:0]  di_AvlByteEnable,
    output        di_AvlBeginBurstTransfer,
    output        di_AvlRead,
    input [31:0]  di_AvlReadData,
    input         di_AvlReadDataValid,
    output        di_AvlWrite,
    output [31:0] di_AvlWriteData(di_avl_writedata)
);

localparam STATE_IDLE   = 4'b0001;
localparam STATE_GRANT0 = 4'b0010;
localparam STATE_GRANT1 = 4'b0100;
localparam STATE_GRANT2 = 4'b1000;

reg [3:0] state, nxt_state;
reg [2:0] grant, req, tmo;

assign grant = state[3:1];
assign req = {

always@(*) 
begin
  case (state)
    STATE_IDLE: begin
      if (req[0])
        nxt_state = STATE_GRANT0;
      else if (req[1])
        nxt_state = STATE_GRANT1;
      else if (req[2])
        nxt_state = STATE_GRANT2;
      else
        nxt_state = STATE_IDLE;
    end
    STATE_GRANT0: begin
      if (req[0] & ~tmo[0])
        nxt_state = STATE_GRANT0;
      else if (req[1])
        nxt_state = STATE_GRANT1;
      else if (req[2])
        nxt_state = STATE_GRANT2;
      else
        nxt_state = STATE_IDLE;
    end
    STATE_GRANT1: begin
      if (req[1] & ~tmo[1])
        nxt_state = STATE_GRANT1;
      else if (req[2])
        nxt_state = STATE_GRANT2;
      else if (req[0])
        nxt_state = STATE_GRANT0;
      else
        nxt_state = STATE_IDLE;
    end
    STATE_GRANT2: begin
      if (req[2] & ~tmo[2])
        nxt_state = STATE_GRANT2;
      else if (req[0])
        nxt_state = STATE_GRANT0;
      else if (req[1])
        nxt_state = STATE_GRANT1;
      else
        nxt_state = STATE_IDLE;
    end
  endcase
end

always@(posedge Clk or negedge Rstn)
  if (!Rstn)
    state <= STATE_IDLE;
  else
    state <= nxt_state;

endmodule

