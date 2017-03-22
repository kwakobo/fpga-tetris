`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Uselessness Inc.
// Engineer: Jason Kwak, Esther An
// 
// Create Date:    12:05:57 11/19/2016 
// Design Name: 
// Module Name:    final_project_tetris 
// Project Name: Tetris
// Target Devices: 
// Tool versions: 
// Description: Just some useless program to play tetris.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module final_project_tetris(START, ACK, RESET, CLK, Left, Right, DownS, DownF,
									 Qinit, Qswap, Qcheck, Qfall, Qmove_l, Qmove_r, Qmove_ds,
									 Qmove_df, Qdone, R, G, B, CounterX, CounterY);

input START, ACK, RESET, CLK, Left, Right, DownS, DownF, CounterX, CounterY;
output Qinit, Qswap, Qcheck, Qfall, Qmove_l, Qmove_r, Qmove_ds, Qmove_df, Qdone, R, G, B;

parameter integer down_speed = 5;

wire fall_timer;
reg [13:0] state;
reg [9:0] board [19:0];
reg [3:0] curr_x [3:0];
reg [4:0] curr_y [3:0];
/* 0: N
	1: E
	2: S
	3: W */
reg [1:0] orientation;
/* 0: I
	1: J
	2: L
	3: O
	4: S
	5: T
	6: Z */
reg [2:0] shape;
reg [2:0] next_block;
reg [27:0] counter;
reg [4:0] clearCurr;
reg [4:0] clearCounter;
reg countFlag;
reg counter_reset;
wire [9:0] CounterX;
wire [9:0] CounterY;
reg Red, Green, Blue;

localparam
INIT		= 14'b00000000000001,	// Initial state
SWAP		= 14'b00000000000010,	// Moves the next block to the current block
CHECK		= 14'b00000000000100,	// Checks if fall is valid
CLEAR		= 14'b00000000001000,	// Finds rows to clear
CLEARROW	= 14'b00000000010000,	// Clear a row
FALL		= 14'b00000000100000,	// Falling block
LISTEN	= 14'b00000001000000,	// Listen to push buttons
MOVE_L	= 14'b00000010000000,	// Move current block to the left
MOVE_R	= 14'b00000100000000,	// Move current block to the right
MOVE_DS	= 14'b00001000000000,	// Move current block down slowly
MOVE_DF	= 14'b00010000000000,	// Move current block down fast
ROTATE	= 14'b00100000000000,	// Rotates current block
ROTATEMU	= 14'b01000000000000,	// Move up after rotate
DONE		= 14'b10000000000000;	// Done state

assign {Qdone, Qmove_df, Qmove_ds, Qmove_r, Qmove_l, Qfall, Qcheck, Qswap, Qinit} = state;
assign fall_timer = (counter == 50000000);
assign R = Red;
assign G = Green;
assign B = Blue;

reg [3:0] counterXBlock;
reg [4:0] counterYBlock;
wire inRegion;

assign inRegion = (CounterX >= 214 & CounterX <= 424) & (CounterY >= 29 & CounterY <= 449);

always @(posedge CLK)
begin
	counterXBlock <= (CounterX - 213) / 21;
	counterYBlock <= (CounterY - 28) / 21;
end

wire currVGA;

assign currVGA = (counterXBlock == curr_x[0] & counterYBlock == curr_y[0]) |
					  (counterXBlock == curr_x[1] & counterYBlock == curr_y[1]) |
					  (counterXBlock == curr_x[2] & counterYBlock == curr_y[2]) |
					  (counterXBlock == curr_x[3] & counterYBlock == curr_y[3]);


always @(posedge CLK)
begin
	Red <= inRegion & (board[counterYBlock][counterXBlock]);
	Green <= inRegion & (board[counterYBlock][counterXBlock] | currVGA);
	Blue <= 0;
end

always @(posedge CLK, posedge RESET)
begin
	if (RESET)
	begin
		state <= INIT;
	end
	else
	begin
		case(state)
			INIT:
			begin
				if(START)
				begin
					state <= SWAP;
					board[0] <= 0;
					board[1] <= 0;
					board[2] <= 0;
					board[3] <= 0;
					board[4] <= 0;
					board[5] <= 0;
					board[6] <= 0;
					board[7] <= 0;
					board[8] <= 0;
					board[9] <= 0;
					board[10] <= 0;
					board[11] <= 0;
					board[12] <= 0;
					board[13] <= 0;
					board[14] <= 0;
					board[15] <= 0;
					board[16] <= 0;
					board[17] <= 0;
					board[18] <= 0;
					board[19] <= 0;
				
					countFlag <= 0;
				end
			end
			SWAP:
			begin
				state <= FALL;
				
				orientation <= 0;
				next_block = $random % 6;
				shape <= next_block;
				// Set curr based on next_block;
				case(next_block)
					0:
					begin
						curr_y[0] <= 0;
						curr_y[1] <= 1;
						curr_y[2] <= 2;
						curr_y[3] <= 2;
						
						curr_x[0] <= 5;
						curr_x[1] <= 5;
						curr_x[2] <= 5;
						curr_x[3] <= 6;
					end
					1:
					begin
						curr_y[0] <= 0;
						curr_y[1] <= 1;
						curr_y[2] <= 2;
						curr_y[3] <= 2;
						
						curr_x[0] <= 4;
						curr_x[1] <= 4;
						curr_x[2] <= 4;
						curr_x[3] <= 5;
					end
					2:
					begin
						curr_y[0] <= 0;
						curr_y[1] <= 1;
						curr_y[2] <= 0;
						curr_y[3] <= 1;
						
						curr_x[0] <= 4;
						curr_x[1] <= 4;
						curr_x[2] <= 5;
						curr_x[3] <= 5;
					end
					3:
					begin
						curr_y[0] <= 0;
						curr_y[1] <= 1;
						curr_y[2] <= 1;
						curr_y[3] <= 1;
						
						curr_x[0] <= 4;
						curr_x[1] <= 3;
						curr_x[2] <= 4;
						curr_x[3] <= 5;
					end
					4:
					begin
						curr_y[0] <= 0;
						curr_y[1] <= 0;
						curr_y[2] <= 1;
						curr_y[3] <= 1;
						
						curr_x[0] <= 3;
						curr_x[1] <= 4;
						curr_x[2] <= 4;
						curr_x[3] <= 5;
					end
					5:
					begin
						curr_y[0] <= 0;
						curr_y[1] <= 1;
						curr_y[2] <= 0;
						curr_y[3] <= 1;
						
						curr_x[0] <= 5;
						curr_x[1] <= 4;
						curr_x[2] <= 4;
						curr_x[3] <= 3;
					end
				endcase
			end
			CHECK:
			begin
				if(board[curr_y[0] + 1][curr_x[0]] |
					board[curr_y[1] + 1][curr_x[1]] |
					board[curr_y[2] + 1][curr_x[2]] |
					board[curr_y[3] + 1][curr_x[3]] |
					curr_y[0] == 19 | curr_y[1] == 19 |
					curr_y[2] == 19 | curr_y[3] == 19)
					state <= CLEAR;
				else
					state <= FALL;
				
				if(board[curr_y[0] + 1][curr_x[0]] |
					board[curr_y[1] + 1][curr_x[1]] |
					board[curr_y[2] + 1][curr_x[2]] |
					board[curr_y[3] + 1][curr_x[3]] |
					curr_y[0] == 19 | curr_y[1] == 19 |
					curr_y[2] == 19 | curr_y[3] == 19)
				begin
					board[curr_y[0]][curr_x[0]] <= 1;
					board[curr_y[1]][curr_x[1]] <= 1;
					board[curr_y[2]][curr_x[2]] <= 1;
					board[curr_y[3]][curr_x[3]] <= 1;
					
					clearCurr <= 19;
				end
			end
			CLEAR:
			begin
				if(clearCurr == 0)
					state <= SWAP;
				else if(board[clearCurr] == 10'b1111111111)
					state <= CLEARROW;
				
				if(board[clearCurr] == 10'b1111111111)
					clearCounter <= clearCurr;
				else if(clearCurr != 0)
					clearCurr <= clearCurr - 1;
			end
			CLEARROW:
			begin
				if(clearCounter == 0)
					state <= CLEAR;
			
				if(clearCounter == 0)
					board[clearCounter] <= 0;
				else
				begin
					board[clearCounter] <= board[clearCounter - 1];
					clearCounter <= clearCounter - 1;
				end
			end
			FALL:
			begin
				if(fall_timer)
					state <= CHECK;
				else
					state <= LISTEN;
				
				if(countFlag)
				begin
					countFlag <= 0;
					counter_reset <= 0;
				end
				if(fall_timer)
				begin
					// Reset counter
					counter_reset <= 1;
					countFlag <= 1;
					
					// Move current block down
					
					curr_y[0] <= curr_y[0] + 1;
					curr_y[1] <= curr_y[1] + 1;
					curr_y[2] <= curr_y[2] + 1;
					curr_y[3] <= curr_y[3] + 1;
				end
			end
			LISTEN:
			begin
				if(fall_timer)
					state <= FALL;
				else if(Left)
					state <= MOVE_L;
				else if(Right)
					state <= MOVE_R;
				else if(DownS)
					state <= MOVE_DS;
				else if(DownF)
					state <= MOVE_DF;
				else if(START)
					state <= ROTATE;
			end
			MOVE_L:
			begin
				state <= CHECK;
				
				if((curr_x[0]) != 0 & (curr_x[1]) != 0 &
					(curr_x[2]) != 0 & (curr_x[3]) != 0)
				begin
					curr_x[0] <= curr_x[0] - 1;
					curr_x[1] <= curr_x[1] - 1;
					curr_x[2] <= curr_x[2] - 1;
					curr_x[3] <= curr_x[3] - 1;
				end
			end
			MOVE_R:
			begin
				state <= CHECK;
				
				if((curr_x[0]) != 9 & (curr_x[1]) != 9 &
					(curr_x[2]) != 9 & (curr_x[3]) != 9)
				begin
					curr_x[0] <= curr_x[0] + 1;
					curr_x[1] <= curr_x[1] + 1;
					curr_x[2] <= curr_x[2] + 1;
					curr_x[3] <= curr_x[3] + 1;
				end
			end
			MOVE_DS:
			begin
				state <= CHECK;
				
				if((curr_y[0] + 1) < 19 & (curr_y[1] + 1) < 19 &
					(curr_y[2] + 1) < 19 & (curr_y[3] + 1) < 19)
				begin
					curr_y[0] <= curr_y[0] + 1;
					curr_y[1] <= curr_y[1] + 1;
					curr_y[2] <= curr_y[2] + 1;
					curr_y[3] <= curr_y[3] + 1;
				end
			end
			MOVE_DF:
			begin
				// Not sure if this is right
				if(board[curr_y[0] - 1] | board[curr_y[1] - 1] |
					board[curr_y[2] - 1] | board[curr_y[3] - 1])
					state <= SWAP;
				else
					state <= MOVE_DF;
				
				curr_y[0] <= curr_y[0] + 1;
				curr_y[1] <= curr_y[1] + 1;
				curr_y[2] <= curr_y[2] + 1;
				curr_y[3] <= curr_y[3] + 1;
			end
			ROTATE:
			begin
				state <= ROTATEMU;
				
				orientation <= orientation + 1;
				case(shape)
				0: // I
				begin
					case(orientation)
					0: // N
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					1: // E
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					2: // S
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					3: // W
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					endcase
				end
				1: // J
				begin
					case(orientation)
					0: // N
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					1: // E
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					2: // S
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					3: // W
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					endcase
				end
				2: // L
				begin
					case(orientation)
					0: // N
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					1: // E
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					2: // S
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					3: // W
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					endcase
				end
				3: // O
				begin
					case(orientation)
					0: // N
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					1: // E
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					2: // S
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					3: // W
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					endcase
				end
				4: // S
				begin
					case(orientation)
					0: // N
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					1: // E
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					2: // S
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					3: // W
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					endcase
				end
				5: // T
				begin
					case(orientation)
					0: // N
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					1: // E
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					2: // S
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					3: // W
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					endcase
				end
				6: // Z
				begin
					case(orientation)
					0: // N
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					1: // E
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					2: // S
					begin
						curr_y[0] <= curr_y[1];
						curr_y[1] <= curr_y[1];
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1];
						
						curr_x[0] <= curr_x[0] - 1;
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1] + 1;
						curr_x[3] <= curr_x[1] + 2;
					end
					3: // W
					begin
						curr_y[0] <= curr_y[1] - 2;
						curr_y[1] <= curr_y[1] - 1;
						curr_y[2] <= curr_y[1];
						curr_y[3] <= curr_y[1] + 1;
						
						curr_x[0] <= curr_x[1];
						curr_x[1] <= curr_x[1];
						curr_x[2] <= curr_x[1];
						curr_x[3] <= curr_x[1];
					end
					endcase
				end
				endcase
			end
		/* 0: N
			1: E
			2: S
			3: W
			reg [1:0] orientation */
		/* 0: I
			1: J
			2: L
			3: O
			4: S
			5: T
			6: Z
			reg [2:0] shape */
			ROTATEMU:
			begin
				if(curr_x[0] > 19 |
					curr_x[1] > 19 |
					curr_x[2] > 19 |
					curr_x[3] > 19 |
					board[curr_y[0]][curr_x[0]] |
					board[curr_y[1]][curr_x[1]] |
					board[curr_y[2]][curr_x[2]] |
					board[curr_y[3]][curr_x[3]])
					state <= ROTATEMU;
				else
					state <= FALL;
				
				if(curr_x[0] > 19 |
					curr_x[1] > 19 |
					curr_x[2] > 19 |
					curr_x[3] > 19)
				begin
					curr_x[0] <= curr_x[0] - 1;
					curr_x[1] <= curr_x[1] - 1;
					curr_x[2] <= curr_x[2] - 1;
					curr_x[3] <= curr_x[3] - 1;
				end
				else if(board[curr_y[0]][curr_x[0]] |
					board[curr_y[1]][curr_x[1]] |
					board[curr_y[2]][curr_x[2]] |
					board[curr_y[3]][curr_x[3]])
				begin
					curr_y[0] <= curr_y[0] - 1;
					curr_y[1] <= curr_y[1] - 1;
					curr_y[2] <= curr_y[2] - 1;
					curr_y[3] <= curr_y[3] - 1;
				end
			end
		endcase
	end
end

always @(posedge CLK, posedge RESET)
begin
	if(RESET)
		counter <= 0;
	else
	begin
		if(!fall_timer)
			counter <= counter + 1;
		if(counter_reset)
		begin
			counter <= 0;
		end
	end
end


endmodule
