module sha_256(
    input clk, rst,
    input input_start,              // Start signal to begin processing
	 input input_complete,           // Signal indicating the input sequence is complete
    input [5:0] data_in,            // 6-bit input from switches
    /*output lcd_done,                // Indicates completion
    output [7:0] lcd_data,          // Data to send to the LCD
    output lcd_rs,                  // Register select (command or data)
	 output lcd_en,         		   // Enable signal for LCD
    output lcd_rw,             		// Read/Write select (write mode)
    output lcd_on,             		// Power on signal for LCD
    output lcd_blon            		// Backlight on signal for LCD */
	 output [6:0] hash_bit511, hash_bit510, hash_bit509, hash_bit508, hash_bit507, hash_bit506, hash_bit505, hash_bit504
);


    wire [511:0] padded_msg;  // Output padded message (512-bit)
	 wire [255:0] hash;        // 256 bit hash value
    wire input_done;          // To indicate padding is completed
	 wire rounds_done;         // To indicate rounds are completed
	 
	 // Instantiate the decoder_input module
	 decoder_input input1 ( .clk(clk), .rst(rst), .input_start(input_start), .input_complete(input_complete),
	                       .data_in(data_in), .padded_msg(padded_msg), .done(input_done) );

    // Instantiate the sha_256_round module
	 sha_256_round round ( .clk(clk), .rst(rst), .done(input_done), .message_block(padded_msg),
	                      .hash(hash), .rounds_done(rounds_done) );
	 
	 /*
	 // Instantiate the lcd_display module
	 lcd_display disp ( .clk(clk), .rst(rst), .rounds_done(rounds_done), .hash_value(hash), 
	                   .done(lcd_done), .lcd_data(lcd_data), .lcd_rs(lcd_rs), .lcd_en(lcd_en),
							 .lcd_rw(lcd_rw), .lcd_on(lcd_on), .lcd_blon(lcd_blon) ); */
			
    // Instantiate seven_segment_display_driver module
	 seven_segment_display_driver disp1( .value(hash[255:252]), .rounds_done(rounds_done), .seg(hash_bit511) );
	 seven_segment_display_driver disp2( .value(hash[251:248]), .rounds_done(rounds_done), .seg(hash_bit510) );
	 seven_segment_display_driver disp3( .value(hash[247:244]), .rounds_done(rounds_done), .seg(hash_bit509) );
	 seven_segment_display_driver disp4( .value(hash[243:240]), .rounds_done(rounds_done), .seg(hash_bit508) );
	 seven_segment_display_driver disp5( .value(hash[239:236]), .rounds_done(rounds_done), .seg(hash_bit507) );
	 seven_segment_display_driver disp6( .value(hash[235:232]), .rounds_done(rounds_done), .seg(hash_bit506) );
	 seven_segment_display_driver disp7( .value(hash[231:228]), .rounds_done(rounds_done), .seg(hash_bit505) );
	 seven_segment_display_driver disp8( .value(hash[227:224]), .rounds_done(rounds_done), .seg(hash_bit504) );
			
endmodule