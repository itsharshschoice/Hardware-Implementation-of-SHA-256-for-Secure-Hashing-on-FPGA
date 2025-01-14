module sha_256_round(
    input clk,
    input rst,
	 input done,                                   // Done signal to indicate padding done
    input [511:0] message_block,                  // 512-bit input message block
	 output reg [255:0] hash,                      // SHA256 hash output (256 bits)
	 output reg rounds_done                            // To indicate rounds done
);  
    // Internal state variables
    reg [31:0] a, b, c, d, e, f, g, h;            // State variables
    reg [6:0] round_index;                        // Round index (0 to 63)
	 
	 // State Definitions
    localparam IDLE  = 2'd0;        
	 localparam ROUNDS  = 2'd1;       
	 localparam FINAL  = 2'd2;      
	 localparam HOLD  = 2'd3;         
	 reg [1:0] PS,NS;                      
	 
	 // Initial hash values
    localparam H0 = 32'h6a09e667;
	 localparam H1 = 32'hbb67ae85;
	 localparam H2 = 32'h3c6ef372; 
	 localparam H3 = 32'ha54ff53a;
    localparam H4 = 32'h510e527f;
	 localparam H5 = 32'h9b05688c;
	 localparam H6 = 32'h1f83d9ab;
	 localparam H7 = 32'h5be0cd19;

	 wire [31:0] Wt;                                 // Current message schedule word
    wire [31:0] Kt;                                 // Round constant for this round
    wire [31:0] Ch, Maj, sigma0, sigma1, T1, T2;    // Intermediate values
	 
	 
	 // Generate message schedule words using sha_256_message_scheduler
    sha_256_message_scheduler msg_sched( .clk(clk), .rst(rst), .done(done), .block(message_block), .W(Wt) );
	 
	 
    // Instantiate constant and function modules
    sha_256_constants constants(.index(round_index), .K(Kt));
    sha_256_functions funcs1(.x(e), .y(f), .z(g), .Ch(Ch), .sigma1(sigma1));
	 sha_256_functions funcs2(.x(a), .y(b), .z(c), .Maj(Maj), .sigma0(sigma0));
	 

    // Perform SHA-256 round calculations
    assign T1 = h + sigma1 + Ch + Kt + Wt;
    assign T2 = sigma0 + Maj;
	 
	 
	 // Sequential Logic: State Transition and Register Updates
    always @(posedge clk or posedge rst) begin
	 
        if (rst) begin
            // Reset everything
            a <= H0; 
				b <= H1;
				c <= H2;
				d <= H3;
            e <= H4;
				f <= H5;
				g <= H6;
				h <= H7;
            round_index <= 7'd0;
            PS <= IDLE;  // Initial state
            hash <= 256'd0;
				rounds_done <= 0;
        end
		  
        else begin
		  if (done) begin
		  
		  PS <= NS;  // Update state
		  
		  // Perform round updates in ROUNDS state
		  if (PS == ROUNDS && round_index < 64) begin
                a <= T1 + T2;
                b <= a;
                c <= b;
                d <= c;
                e <= d + T1;
                f <= e;
                g <= f;
                h <= g;
                round_index <= round_index + 1;
            end
				
		// Assign hash in the final state (FINAL)
            if (PS == FINAL) begin
                hash <= {H0 + a, H1 + b, H2 + c, H3 + d, H4 + e, H5 + f, H6 + g, H7 + h};
					 rounds_done <= 1;
					 // Reset round_index
                round_index <= 7'd0;
            end
			end
		  end  
		end
		
		
		// Combinational Logic: Next State Logic
    always @(*) begin
        NS = PS; // Default assignment to prevent latches
        case (PS)
            IDLE: begin
                // Move to rounds state
                NS = ROUNDS;
            end
            ROUNDS: begin
                // Perform 64 rounds
                if (round_index >= 64)
                    NS = FINAL; // Go to final state
            end
            FINAL: begin
                // Finalize hash computation, already handled in the always block
                NS = HOLD; // Hold final hash
            end
            HOLD: begin
                // Hold final hash
                NS = HOLD;
            end
            default: NS = IDLE; // Default safe state
        endcase    
    end
	 
endmodule