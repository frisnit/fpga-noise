`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:30:27 03/03/2015 
// Design Name: 
// Module Name:    vga 
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
module vga_driver(clk, color, hsync, vsync, red, green, blue, x, y);
	// VGA signal explanation and timing values for specific modes:
	// http://www-mtl.mit.edu/Courses/6.111/labkit/vga.shtml

	// 640x480 @ 60Hz, 25MHz pixel clock
	parameter H_ACTIVE = 640;
	parameter H_FRONT = 16;
	parameter H_PULSE = 96;
	parameter H_BACK = 48;
	parameter V_ACTIVE = 480;
	parameter V_FRONT = 11;
	parameter V_PULSE = 2;
	parameter V_BACK = 31;
	
	input clk;
	input [7:0] color;
	
	output hsync, vsync;
	output [9:0] x, y;
	output [2:0] red, green;
	output [1:0] blue;
	
	reg [9:0] h_count;
	reg [9:0] v_count;
	
	reg [6:0] bar_count;
	reg [2:0] column_count;
	
	always @(posedge clk)
	begin
	
		if (h_count < H_ACTIVE + H_FRONT + H_PULSE + H_BACK - 1)
		begin
			// Increment horizontal count for each tick of the pixel clock
			h_count <= h_count + 1;

			if (bar_count>91)
			begin
				bar_count <= 0;
				column_count <= column_count+1;
			end
			else
			begin
						bar_count <= bar_count + 1;
			end
			
		end		
		else
		begin

			bar_count <= 0;
			column_count <= 0;
			
			// At the end of the line, reset horizontal count and increment vertical
			h_count <= 0;
			if (v_count < V_ACTIVE + V_FRONT + V_PULSE + V_BACK - 1)
				v_count <= v_count + 1;
			else
				// At the end of the frame, reset vertical count
				v_count <= 0;
		end
	end
	
	// Generate horizontal and vertical sync pulses at the appropriate time
	assign hsync = h_count > H_ACTIVE + H_FRONT && h_count < H_ACTIVE + H_FRONT + H_PULSE;
	assign vsync = v_count > V_ACTIVE + V_FRONT && v_count < V_ACTIVE + V_FRONT + V_PULSE;
	
	// Output x and y coordinates
	assign x = h_count < H_ACTIVE ? h_count : 0;
	assign y = v_count < V_ACTIVE ? v_count : 0;

	// Generate separate RGB signals from different parts of color byte
	// Output black during horizontal and vertical blanking intervals

	assign red		= h_count < H_ACTIVE && v_count < V_ACTIVE ? color[7:5] : 3'b0;
	assign green	= h_count < H_ACTIVE && v_count < V_ACTIVE ? color[4:2] : 3'b0;
	assign blue		= h_count < H_ACTIVE && v_count < V_ACTIVE ? color[1:0] : 2'b0;
	
	assign colour_count = column_count;

endmodule

