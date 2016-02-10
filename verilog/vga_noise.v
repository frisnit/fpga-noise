`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10/02/2016 
// Design Name: 
// Module Name:    vga_noise 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: generate 8-bit VGA output with the following effects:
//
// Colour test:      vertical colour bars
// Monochrome test:  vertical monochrome bars
// Colour noise:     8bpp random noise
// Monochrome noise: monochrome random noise
//
// Both noise effects can be 'paused' by resetting the LFSR seed on each vsync
//
// Dependencies: noise_generator.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module vga_noise(clk, color, pause, vsync, hsync, style, test, audio_l, audio_r);

	input clk;
	output [7:0] color;
	input pause;
	input vsync, hsync;
	input style;
	input test;
	output audio_l, audio_r;
	
	reg [1:0] audio_data;

	reg [7:0] latch;
	reg [7:0] sr;
	
	reg [12:0] divider;
	
	wire noise_bit;
		
	noise_generator gen (
		.clk(clk),
		.reset(pause&vsync),// reset the LFSR on vsync to give 'paused' noise effect
		.random_bit(noise_bit)
		);	

	// handy line-synchronised counter
	always @(negedge clk)
	begin
	
		if(hsync)
			divider <= 0;
		else
			divider <= divider + 1;

	end

	// divider[2] is a clock at pixel frequency
	always @(posedge divider[2])
	begin
		latch <= sr;// latch shift register each complete byte (every 8 clock cycles)		
	end

	// audio noise can be at a much lower rate
	always @(posedge divider[12])
	begin
		if(!test && !pause)// turn off sound when noise is 'paused'
		begin
			audio_data <= sr[1:0];
		end
	end

	always @(posedge clk)
	begin	
	
		if(style)// colour
		begin
		
			if(test)
			begin
				// display test pattern (colour vertical stripes)
				sr <= {divider[9],divider[9],divider[9],divider[8],divider[8],divider[8],divider[7],divider[7]};
			end
			else
			begin
				// add noise bits to shift register (8-bit 'colour' noise)
				sr[7:1] <= sr[6:0];
				sr[0] <= noise_bit;
			end
		end
		else // monochrome
		begin
			if(test)
			begin
				// display test pattern (monochrome vertical stripes)
				sr <= {divider[5],divider[5],divider[5],divider[5],divider[5],divider[5],divider[5],divider[5]};
			end
			else
			begin
			
				// load shift register with current noise bit value (monochrome noise)
				sr <= {noise_bit,noise_bit,noise_bit,noise_bit,noise_bit,noise_bit,noise_bit,noise_bit};
			end
		end
		
	end

	assign color = latch;
	
	// stereo noise!
	assign audio_l = audio_data[0];
	assign audio_r = audio_data[1];

endmodule
