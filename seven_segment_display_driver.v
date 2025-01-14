module seven_segment_display_driver(value,seg,rounds_done);
input [3:0] value;
input rounds_done;
output reg [6:0] seg;

parameter ZERO= 7'b1000000; // 0
parameter ONE=7'b1111001;   // 1
parameter TWO=7'b0100100;   // 2
parameter THREE=7'b0110000; // 3
parameter FOUR=7'b0011001;  // 4
parameter FIVE=7'b0010010;  // 5
parameter SIX=7'b0000010;   // 6
parameter SEVEN=7'b1111000; // 7
parameter EIGHT=7'b0000000; // 8
parameter NINE=7'b0010000;  // 9
parameter A = 7'b0001000;   // A
parameter B = 7'b0000011;   // B
parameter C = 7'b1000110;   // C
parameter D = 7'b0100001;   // D
parameter E = 7'b0000110;   // E
parameter F = 7'b0001110;   // F

always @(*)
begin
if (rounds_done) begin
case(value)
 4'b0000 : seg = ZERO;
 4'b0001 : seg = ONE;
 4'b0010 : seg = TWO;
 4'b0011 : seg = THREE;
 4'b0100 : seg = FOUR;
 4'b0101 : seg = FIVE;
 4'b0110 : seg = SIX;
 4'b0111 : seg = SEVEN;
 4'b1000 : seg = EIGHT;
 4'b1001 : seg = NINE;
 4'b1010 : seg = A; 
 4'b1011 : seg = B; 
 4'b1100 : seg = C;  
 4'b1101 : seg = D; 
 4'b1110 : seg = E;   
 4'b1111 : seg = F; 
 default: seg = 7'b1111111; // All segments off
	endcase
	end
	else begin
	seg = 7'b1111111; // All segments off
	end
end
 
endmodule
