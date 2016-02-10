`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10/02/2016 
// Design Name: 
// Module Name:    noise_generator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: generate random bit on edge of clk
//
// 32 bit LFSR (period 2^32 bits)
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module noise_generator(clk,reset,random_bit);

	parameter SEED = 32'b10101011101010111010101110101011;// LFSR starting state
	parameter TAPS = 31'b0000000000000000000000001100010;// LFSR feedback taps

	input clk;
	input reset;
	output random_bit;
	
	reg [31:0] shift_register;
	initial shift_register = SEED;

	always @(posedge clk)
	begin

		if(!reset)
		begin
			// feedback 1,5,6
			if(shift_register[31])
				shift_register[31:1] <= shift_register[30:0]^TAPS;
			else
				shift_register[31:1] <= shift_register[30:0];

			// feedback 31
			shift_register[0] <= shift_register[31];
		end
		else
		begin
			// reset seed
			shift_register <= SEED;
		end
		
	end	

	// clock out random bits from the end of the register
	assign random_bit = shift_register[31];

endmodule
