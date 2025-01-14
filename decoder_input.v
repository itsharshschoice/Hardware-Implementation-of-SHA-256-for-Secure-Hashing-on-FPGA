module decoder_input (
    input clk,
    input rst,
    input input_start,              // Start signal to begin processing
	 input input_complete,           // Signal indicating the input sequence is complete
    input [5:0] data_in,            // 6-bit input from switches
    output reg [511:0] padded_msg,  // Output padded message (512-bit)
    output reg done                 // Output done signal when processing is complete
);

    // Localparam for defining FSM states
    localparam IDLE          = 2'b00;
    localparam PROCESSING    = 2'b01;
    localparam COMPLETE      = 2'b10;
    reg [1:0] PS, NS;
	 
	 reg [5:0] write_pointer;         // Write pointer for memory (supports up to 64 characters)(we need only 55)
    reg [7:0] memory [0:54];         // Internal memory array to store ASCII characters (upto 55)
    wire [7:0] decoded_ascii;        // Wire for decoder result
	 
	 integer msg_length;              // To track the original message length in bits
	 integer i;

	 
	  
    // Instantiate the decoder6x64 module
    decoder_mapping map (
        .data_in(data_in),
        .ascii_out(decoded_ascii)
    );

	 
    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PS <= IDLE;  // Reset to IDLE state
				for (i = 0; i < 55; i = i + 1) begin
					 memory[i] <= 8'b0;  // Clear all memory locations
				end
				padded_msg <= 512'b0;  // Clear the padded message
				done <= 0;
				write_pointer <= 0;    // Reset write pointer
				msg_length <= 0;       // Reset message length
				end
				
        else begin
            PS <= NS;  // Transition to next state
           
				 if (PS == PROCESSING && !input_complete) begin
					memory[write_pointer] <= decoded_ascii;  // Store decoded value in memory
					write_pointer <= write_pointer + 1;      // Increment write pointer
					msg_length <= msg_length + 8;             // Increment message length by 8 bits
			  end
		 
				 else if (PS == COMPLETE) begin
                // Padding logic
                
                // First, set the first part of padded message (the original message)
                for (i = 0; i < write_pointer && i < 55; i = i + 1) begin
                    padded_msg[511 - (i*8) -: 8] <= memory[i];
                end
                
                // Add the 1-bit padding at the end of the message
                padded_msg[511 - (write_pointer*8)] <= 1'b1;
                
                // Fill the next bits with 0s (for padding)
                for (i = 0; i < 448; i = i + 1) begin
					     if (i >= write_pointer*8 + 1) begin
                       padded_msg[511 - i] <= 1'b0; 
                    end
                end
                
                // Finally, add the message length (in bits) as the last 64 bits
                padded_msg[63:0] <= msg_length;
                
                done <= 1;  // Set done to indicate completion
            end
		  end		  
		  
	 end
	 

    // Next state logic
    always @(*) begin
        case (PS)
		  
            IDLE: begin
                if (input_start)  // If start signal is high, move to PROCESSING state
                    NS = PROCESSING;
                else
                    NS = IDLE;  // Stay in IDLE if no start signal
            end
				
            PROCESSING: begin
                if (write_pointer >= 55 || input_complete)  // If input sequence is complete or excceed 55 characters
                    NS = COMPLETE;
                else
                    NS = PROCESSING;  // Go back to PROCESSING for next input
            end
				
            COMPLETE: begin
                NS = COMPLETE;  // Hold
            end
				
            default: begin
                NS = IDLE;  // Default state is IDLE
            end
				
        endcase
    end


endmodule
