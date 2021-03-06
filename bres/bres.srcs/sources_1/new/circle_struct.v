`timescale 1ns/1ps

module circle_struct(// General
		 input		clk,

		 // Coordinates for centroid and radius
		 input [7:0] start_x,
		 input [7:0] start_y,
		 input [7:0] radius,
		 // Signal control - input
		 input       go,

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
	reg  [2:0] counter;

	// Wires for signal control
	wire in_loop, complete;

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
	assign xc = start_x;
	assign yc = start_y;

	//Initialize parameters

	// Compute initial decision factor
	wire [7:0]  dec_init1;
	mult2 mult2_dec_init(radius, dec_init1);
	sub     sub_dec_init(8'd3, dec_init1,   dec_init);

	// Initialize x
	d_ff     x_init (go, 1'b1, x);

	// Initialize y
	wire     ce_dec_init; 
	gt       gt_dec_init(dec_init, 8'd0, ce_dec_init);
	d_ff_en  y_init(go, ce_dec_init, radius, y);

	// Counter
	d_ff     counter_init (go, 1'b1, counter);
	
	// While loop
	mux2 mux_in_loop(8'd1, 8'd0, state, in_loop);
	// End while loop
	ls   ls_complete(y,x,complete);

    	wire [7:0] decision1;
    	wire [7:0] decision2;
    
	//Compute factor decision1
	wire [7:0] res_sub1;
	wire [7:0] res_mult1;
	wire [7:0] res_sum1;

	sub     sub1(x,y,res_sub1);
	mult4 mult41(sub1, res_mult1);
	sum     sum1(res_mult1,  8'd10,  res_sum1);
	sum     sum2(res_sum1, decision, decision1);

	//Compute factor decision2
	wire [7:0] res_mult2;
	wire [7:0] res_sum2;

	mult4 mult41x(x, res_mult2);
	sum     sum11(res_mult2,   8'd6, res_sum2);
	sum     sum21(res_sum2,decision, decision2);

	//While loop
	wire ce_loop,en;
	eq eq_ce_loop(state, 2'd1, en);
	and      and1(clk, en, ce_loop);

	//Compute x
	wire ctrl_counter;
	eq      eq_counter(counter, 8'd0, ctrl_counter);
	wire [7:0] sumx1;
	sum     sum_x_1(x, 8'd1, sumx1);
	mux2    mux2_x_1(sumx1,x,ctrl_counter,x);
	d_ff d_ff_x  (ce_loop,x,x);

	//Compute y
	wire sel_dec;
	wire ctrl_y;
	wire [7:0] sub_y;
	and and2(ctrl_y, sel_dec, ctrl_counter);
	sub sub_y1(y,8'd1,sub_y);
	mux2 mux2_y(sub_y,y,ctrl_y,y);
	d_ff d_ff_y(ce_loop,y,y);

	//Compute decision
	wire [7:0] ctrl_dec;
	gt    gt_dec_y(decision, 8'd0, sel_dec);
	mux2  mux2_dec(decision1, decision2, sel_dec, ctrl_dec);
	d_ff d_ff_dec(ce_loop,ctrl_dec,decision);

	// Increment counter
	sum sum_counter1(counter, 8'd1, counter);

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