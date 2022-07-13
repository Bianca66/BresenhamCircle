`timescale 1ns/1ps

module circle_tb();
	
	reg		clk;

	// Coordinates for centroid and radius
	reg [7:0] start_x;
	reg [7:0] start_y;
	reg [7:0] radius;
	// Signal control - input
	reg go;

	// Signal control - output
	wire busy;
	wire we;
	// Coordinates for Bresenham circle
	wire [15:0] address;



circle circle(// General
		 .clk(clk),

		 // Coordinates for centroid and radius
		 .start_x(start_x),
		 .start_y(start_y),
		 .radius (radius),
		 // Signal control - input
		 .go(go),

		 // Signal control - output
		 .busy(busy),
		 .we(we),
		 // Coordinates for Bresenham circle
		 .address(address)
		);


	initial
    	begin
      		forever
        	#10 clk = !clk;
    	end

	initial
	begin
	        clk = 0;
		start_x = 0;
		start_y = 0;
		radius  = 5;
		go      = 0;
	end
	
	initial
	begin
		# 91 go = 1;
		# 340 go = 0;
		#1000 $stop;
	end

endmodule