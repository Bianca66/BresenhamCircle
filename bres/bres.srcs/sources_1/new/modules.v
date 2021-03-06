module d_ff #(parameter SIZE = 8)
             (// General
              input            clk,
              input [SIZE-1:0] d,
              output[SIZE-1:0] q
    //	      output[SIZE-1:0] q_n
                );

	wire [SIZE-1:0] d_n;
	wire [SIZE-1:0] x;
	wire [SIZE-1:0] y;
	wire [SIZE-1:0] q_n;

	not   not1(d_n,d); 
	nand nand1(x,clk,d); 
	nand nand2(y,clk,d_n); 
	nand nand3(q,q_n,y); 
	nand nand4(q_n,q,x); 

endmodule


module d_ff_en #(parameter SIZE = 8)
	            (// General
	             input            clk,
		         input            ce,
	             input [SIZE-1:0] d,
                 output[SIZE-1:0] q
  //	         output[SIZE-1:0] q_n
                );

	wire [SIZE-1:0] d_n;
	wire [SIZE-1:0] x;
	wire [SIZE-1:0] y;
	wire [SIZE-1:0] q_n;
	wire            en;

	not   not1(d_n,d); 
	or     or1(en,clk,ce);
	nand nand1(x,clk,d); 
	nand nand2(y,clk,d_n); 
	nand nand3(q,q_n,y); 
	nand nand4(q_n,q,x); 

endmodule



module mux2 #(parameter SIZE = 8)
	    (input [SIZE-1:0] in1,
	     input [SIZE-1:0] in2,
	     input            sel,
	     output[SIZE-1:0] out);
	
	wire sel_n;
	wire [SIZE-1:0] x;
	wire [SIZE-1:0] y;

	not   not1(sel_n,sel);
	nand nand1(x,in1,sel);
	nand nand2(y,in2,sel);
	nand nand3(out,x,y);

endmodule


module mux3 #(parameter SIZE = 8)
	    (input [SIZE-1:0] in1,
	     input [SIZE-1:0] in2,
	     input [SIZE-1:0] in3,
	     input      [1:0] sel,
	     output[SIZE-1:0] out);
	
	wire sel1_n;
	wire sel2_n;
	wire [SIZE-1:0] x;
	wire [SIZE-1:0] y;
	wire [SIZE-1:0] z;

	not   not1(sel1_n,sel[1]);
	not   not2(sel2_n,sel[0]);
	nand nand1(x,in1,sel1_n,sel2_n);
	nand nand2(y,in2,sel1_n,sel[0]);
	nand nand3(z,in3,sel[1],sel2_n);
	nand nand4(out,x,y,z);

endmodule

module sum #(parameter SIZE = 8)
	    (input  [SIZE-1:0] in1,
	     input  [SIZE-1:0] in2,
	     output [SIZE-1:0] out,
	     output            carry);

	wire cin;
	wire [SIZE-1:0] x;
	wire [SIZE-1:0] y;
	wire [SIZE-1:0] z;
	wire [SIZE-1:0] w;
	
	nand nand1(x, in1, in2);
	nand nand2(carry, x, x);
	nand nand3(y, in1, x);
	nand nand4(z, in2, x);
	nand nand5(w, y, z);

endmodule


module sub #(parameter SIZE = 8)
	    (input  [SIZE-1:0] in1,
	     input  [SIZE-1:0] in2,
	     output [SIZE-1:0] out,
	     output            b);

	wire [SIZE-1:0] in1_n;
	not not1(in1_n, in1);
	xor xor1(out, in1, in2);
	and and1(b, in1_n, in2);

endmodule


module eq #(parameter SIZE = 8)
	    (input  [SIZE-1:0] in1,
	     input  [SIZE-1:0] in2,
	     output            out);

	wire [SIZE-1:0]x;
	and and1(x,in1, in2);
	assign out = | x;

endmodule


module ls#  (parameter SIZE = 8)
	    (input  [SIZE-1:0] in1,
	     input  [SIZE-1:0] in2,
	     output            out);

	wire [SIZE-1:0] in1_n;
	not not1(in1_n, in1);
	and and1(out, in1_n, in2);

endmodule


module gt  #(parameter SIZE = 8)
	    (input  [SIZE-1:0] in1,
	     input  [SIZE-1:0] in2,
	     output            out);

	wire [SIZE-1:0] in2_n;
	not not1(in2_n, in2);
	and and1(out, in1, in2_n);

endmodule

module mult4  #(parameter SIZE = 8)
	     (input  [SIZE-1:0] in,
	      output            out);

	assign out = in << 2;

endmodule

module mult2  #(parameter SIZE = 8)
             (input  [SIZE-1:0] in,
              output            out);

	assign out = in << 1;

endmodule