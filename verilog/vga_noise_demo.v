`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Elbert V2 Library
// Copyright (c) 2015 J.B. Langston
//
// (subsequently tweaked by MLT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//////////////////////////////////////////////////////////////////////////////////

module vga_noise_demo(clkin, dips, segments, anodes, hsync, vsync, red, green, blue, audio_l, audio_r, gpio_P1);
	
	input clkin;
	
	// DIP switch
	input [8:1] dips;
	
	// 7-SEG
	output [7:0] segments;
	output [3:1] anodes;
	
	// VGA
	output hsync, vsync;
	output [2:0] red, green;
	output [1:0] blue;
	wire [7:0] color;
	wire [9:0] x, y;
	//

	// AUDIO
	output audio_l, audio_r;

	// GPIO
	output [7:0] gpio_P1;

	wire [11:0] bcd;
	wire clk;

	reg [15:0] cnt;

	// Use the DCM to multiply the incoming 12MHz clock to a 192MHz clock
	clock_mgr dcm (
		 .CLKIN_IN(clkin), 
		 .CLKFX_OUT(clk), 
		 .CLKIN_IBUFG_OUT(), 
		 .CLK0_OUT()
		 );

	// Convert binary input from DIP switches into BCD
	binary_to_bcd conv (
		.binary({4'b0, ~dips}),
		.bcd(bcd)
		);

	// Increment a counter for each clock cycle which can be used to divide the clock as needed
	always @(posedge clk) cnt <= cnt + 1;
		
	// route the divided clock to GPIO
	// so we can see it on the scope
	// /1024 so MHz are now ~= kHz
	assign gpio_P1[0] = cnt[9];// main clock / 1024

	assign gpio_P1[1] = cnt[3];// pixel clock / 2

	assign gpio_P1[2] = dips[1]&vsync; // LFSR reset signal
	
	// assign remaining GPIOs to something
	assign gpio_P1[7:3] = 5'b00000;

	// Generate sync pulses and x/y coordinates
	// pixel clock is 25.5MHz, should be 25.175MHz
	vga_driver vga (
		 .clk(cnt[2]),
		 .color(color), 
		 .hsync(hsync), 
		 .vsync(vsync), 
		 .red(red),
		 .green(green),
		 .blue(blue),
		 .x(x), 
		 .y(y)
		 );
	
	
	// generate VGA output:
	//
	// DIP switch 1 pauses/unpauses the noise display
	// DIP switch 2 switches between colour/monochrome output
	// DIP switch 3 switches between noise mode and test mode
	vga_noise vga_noise(
		.clk(clk), 
		.color(color),
		.pause(dips[1]),
		.vsync(vsync),
		.hsync(hsync),
		.style(dips[2]),
		.test(dips[3]),
		.audio_l(audio_l),
		.audio_r(audio_r)
	);		 
		 
			 
	// Multiplex BCD value across seven segment display (no decimal points)
   seven_segment_mux mux (
		.clk(cnt[15]), 
		.value({4'b0, bcd}), 
		.dp(3'b000), 
		.segments(segments), 
		.anodes(anodes)
		);		 
		 
endmodule



