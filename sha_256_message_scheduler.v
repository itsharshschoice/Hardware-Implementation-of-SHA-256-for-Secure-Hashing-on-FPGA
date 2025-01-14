module sha_256_message_scheduler(
    input clk,rst,
	 input done,                                   // Done signal to indicate padding done
    input [511:0] block,                          // 512-bit input message block
    output reg [31:0] W                           // Output a single 32-bit word at a time
);	
    reg [31:0] W_temp [0:63]; // 64 words of 32 bits each (W[0] to W[63])
	 reg [6:0] round; // To keep track of which W_temp to output (0-63)
	 integer t;
	 
	 always @(posedge clk or posedge rst) begin
	 
        if (rst) begin
		  
            // Reset all W_temp and W
            for (t = 0; t < 64; t = t + 1) begin
                W_temp[t] <= 32'd0;
            end
            W <= 32'd0;
				round <= 7'd0;
        end 
		  
		  else begin
		    if (done) begin
				
            if (round < 16) begin
                // Initialize W_temp[0] to W_temp[15] from the input block
                W_temp[round] <= block[511 - (32 * round) -: 32];
					 
					 W <= block[511 - (32 * round) -: 32];  // Directly assign block value to W
					 
            end
				
				else begin
                // Compute W_temp[16] to W_temp[63]
                W_temp[round] <= W_temp[round-16] +
                                 ({W_temp[round-15][6:0], W_temp[round-15][31:7]} ^
                                  {W_temp[round-15][17:0], W_temp[round-15][31:18]} ^
                                 (W_temp[round-15] >> 3)) +
                                 W_temp[round-7] +
                                 ({W_temp[round-2][16:0], W_temp[round-2][31:17]} ^
                                  {W_temp[round-2][18:0], W_temp[round-2][31:19]} ^
                                 (W_temp[round-2] >> 10));
											 
									 W <= W_temp[round-16] + 
                                 ({W_temp[round-15][6:0], W_temp[round-15][31:7]} ^
                                  {W_temp[round-15][17:0], W_temp[round-15][31:18]} ^
                                 (W_temp[round-15] >> 3)) +
                                 W_temp[round-7] +
                                 ({W_temp[round-2][16:0], W_temp[round-2][31:17]} ^
                                  {W_temp[round-2][18:0], W_temp[round-2][31:19]} ^
                                 (W_temp[round-2] >> 10));  // Directly compute W in the same cycle
            end


            // Increment round counter
            if (round < 63) begin
                round <= round + 1;
            end else begin
                round <= 0; // Reset after reaching W_temp[63]
            end
			end
       end
    end
endmodule