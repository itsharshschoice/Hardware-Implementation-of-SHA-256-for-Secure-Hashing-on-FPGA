module sha_256_functions(
    input [31:0] x,y,z,
    output [31:0] Ch,Maj,sigma0,sigma1
);
    assign Ch  = (x & y) ^ (~x & z);   // Choice Function
    assign Maj = (x & y) ^ (y & z) ^ (z & x); // Majority function
    assign sigma0  = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]}; // sigma0(x)
    assign sigma1  = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]}; // sigma1(x)
	 
endmodule