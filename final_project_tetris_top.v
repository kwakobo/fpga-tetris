`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:06:58 11/19/2016 
// Design Name: 
// Module Name:    final_project_tetris_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module final_project_tetris_top(ClkPort, BtnL, BtnU, BtnR, BtnD, BtnC, Sw0,
										  LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
										  vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b,
										  St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar);

input ClkPort;
input BtnL, BtnU, BtnD, BtnR, BtnC;
input Sw0;
output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;

wire Start, Ack, Reset, board_clk, clk;
wire LeftPB, RightPB, DownPB, UpPB;
wire inDisplayArea;
wire [9:0] CounterX;
wire [9:0] CounterY;
reg vga_r, vga_g, vga_b;
wire tetris_r, tetris_g, tetris_b;
reg [19:0] y_grid;
reg [9:0] x_grid;
wire DBBtnL, DBBtnU, DBBtnD, DBBtnR, DBBtnC;

assign Reset = Sw0;

ee201_debouncer dbL(.CLK(clk), .RESET(Reset), .PB(BtnL), .SCEN(DBBtnL));
ee201_debouncer dbU(.CLK(clk), .RESET(Reset), .PB(BtnU), .SCEN(DBBtnU));
ee201_debouncer dbD(.CLK(clk), .RESET(Reset), .PB(BtnD), .SCEN(DBBtnD));
ee201_debouncer dbR(.CLK(clk), .RESET(Reset), .PB(BtnR), .SCEN(DBBtnR));
ee201_debouncer dbC(.CLK(clk), .RESET(Reset), .PB(BtnC), .SCEN(DBBtnC));



BUF BUF1 (board_clk, ClkPort);

reg [27:0]DIV_CLK;
always @ (posedge board_clk, posedge Reset)  
begin : CLOCK_DIVIDER
	if (Reset)
		DIV_CLK <= 0;
	else
		DIV_CLK <= DIV_CLK + 1'b1;
end

assign clk = DIV_CLK[1];

assign {St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
hvsync_generator syncgen(.clk(clk), .reset(Reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));

final_project_tetris tetris(.START(DBBtnC), .ACK(DBBtnC), .RESET(Reset), .CLK(clk), .Left(DBBtnL), .Right(DBBtnR), .DownS(DBBtnD), .DownF(DBBtnU),
									 .CounterX(CounterX), .CounterY(CounterY), .R(tetris_r), .G(tetris_g), .B(tetris_b),
									 .Qinit(LD0), .Qswap(LD1), .Qcheck(LD2), .Qfall(LD3), .Qmove_l(LD4), .Qmove_r(LD5), .Qmove_ds(LD6), .Qdone(LD7));

/* Board setup */
wire boardGridYLimitX = (CounterX >= 214) & (CounterX <= 424);
wire boardGridYLimitY = (CounterY >= 29) & (CounterY <= 449);

wire boardGridY = ((CounterY == 29) | (CounterY == 50) | (CounterY == 71) | (CounterY == 92) | (CounterY == 113) | (CounterY == 134) | (CounterY == 155) | 
					  (CounterY == 176) | (CounterY == 197) | (CounterY == 218) | (CounterY == 239) | (CounterY == 260) | (CounterY == 281) | (CounterY == 302) |
					  (CounterY == 323) | (CounterY == 344) | (CounterY == 365) | (CounterY == 386) | (CounterY == 407) | (CounterY == 428) | (CounterY == 449)) & boardGridYLimitX;

wire boardGridX = ((CounterX == 214) | (CounterX == 235) | (CounterX == 256) | (CounterX == 277) | (CounterX == 298) | (CounterX == 319) | (CounterX == 340) | 
						(CounterX == 361) | (CounterX == 382) | (CounterX == 403) | (CounterX == 424)) & boardGridYLimitY;

wire nextGridLimitX = (CounterX >= 445) & (CounterX <= 529);
wire nextGridLimitY = (CounterY >= 29) & (CounterY <= 113);

wire nextGridY = ((CounterY == 29) | (CounterY == 50) | (CounterY == 71) | (CounterY == 92) | (CounterY == 113)) & nextGridLimitX;
wire nextGridX = ((CounterX == 445) | (CounterX == 466) | (CounterX == 487) | (CounterX == 508) | (CounterX == 529)) & nextGridLimitY;

wire R = tetris_r;
wire G = boardGridY | boardGridX | nextGridY | nextGridX | tetris_g;
wire B = boardGridY | boardGridX | nextGridY | nextGridX | tetris_b;

always @(posedge clk)
begin
	vga_r <= R & inDisplayArea;
	vga_g <= G & inDisplayArea;
	vga_b <= B & inDisplayArea;
end

endmodule
