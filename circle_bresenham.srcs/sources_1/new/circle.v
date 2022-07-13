`timescale 1ns/1ps

module circle(// General
		 input		clk,

		 // Coordinates for centroid and radius
		 input [7:0] start_x,
		 input [7:0] start_y,
		 input [7:0] radius,
		 // Signal control - input
		 input  wire go,

		 // Signal control - output
		 output wire busy,
		 output wire we,
		 // Coordinates for Bresenham circle
		 output [15:0] address
		);

	// State
	reg [1:0] state;
	// parameters
	parameter [1:0]IDLE = 2'd0;
	parameter [1:0]RUN  = 2'd1;
	parameter [1:0]DONE = 2'd2;

	// Intermmediate variables for decision parameter and coordinates
	wire [7:0] dec_init;
	reg  [7:0] decision;

	reg  [7:0] x;
	reg  [7:0] y;
	wire [7:0] xc;
	wire [7:0] yc;
	reg   [2:0] counter;

	// Wires for signal control
	wire in_loop, complete;

	// Set state of circle drawing: draw, wait for command or done
	always@(posedge clk)
	begin
		case(state)
			IDLE:	
			begin
				if(go)
				begin
					state <= RUN;
				end
				else
				begin
					state <= IDLE;
				end	
			end

			RUN:
			begin
				if(complete)
				begin
					state <= DONE;
				end
				else
				begin
					state <= RUN;
				end	
			end

			DONE:
			begin
				if(go)
				begin
					state <= RUN;
				end
				else
				begin
					state <= IDLE;
				end	
			end
			
			default: state <= IDLE;
			endcase
	end

	//Bresenham circle algorithm
	//Correction of centroid coordinates
	assign xc = start_x + 0;
	assign yc = start_y + 0;

	//Initialize parameters
	always@(posedge go)
	begin
		x <= 1;
		y <= (dec_init > 0)? (radius - 1) : (radius);
		decision <= dec_init;
		counter <= 1;
	end
	
	// For loop
	assign in_loop  = (state == RUN)? 1 : 0;
	assign complete = (y < x)? 1 : 0;

    wire [7:0]decision1;
    wire [7:0]decision2;
    
    assign decision1 = decision + 4*(x - y) + 10;
    assign decision2 = decision + 4*x + 6;
	//
	assign dec_init = 3 - 2 * radius;

	//
	always@(posedge clk && state == RUN)
	begin
		x <= (counter == 0)? (x+1) : x;
		y <= ((decision > 0)&&(counter == 0))? (y - 1) : y;
		decision <= (decision > 0)? (decision1) : (decision2);
		counter  <= counter + 1;
	end


	assign address = (counter == 0)? {yc + y, xc + x}:
                     (counter == 1)? {yc + y, xc - x}:
	                 (counter == 2)? {yc - y, xc + x}:
	                 (counter == 3)? {yc - y, xc - x}:
	                 (counter == 4)? {yc + x, xc + y}:
	                 (counter == 5)? {yc + x, xc - y}:
	                 (counter == 6)? {yc - x, xc + y}:
	                                 {yc - x, xc - y};

	assign we   = (state == RUN)? 1 : 0;
	assign busy = (state == RUN)? 1 : 0;


endmodule