// Seven-segment display
module sseg_encoder
(
    input   logic [3:0] digit,
    output  logic [6:0] encoded
);
    parameter ZERO  = 7'b1000000;
    parameter ONE   = 7'b1111001;
    parameter TWO   = 7'b0100100;
    parameter THREE = 7'b0110000;
    parameter FOUR  = 7'b0011001;
    parameter FIVE  = 7'b0010010;
    parameter SIX   = 7'b0000010;
    parameter SEVEN = 7'b1111000;
    parameter EIGHT = 7'b0000000;
    parameter NINE  = 7'b0010000;

    always @(*) begin
        case(digit)
            4'd0: encoded = ZERO;
            4'd1: encoded = ONE;
            4'd2: encoded = TWO;
            4'd3: encoded = THREE;
            4'd4: encoded = FOUR;
            4'd5: encoded = FIVE;
            4'd6: encoded = SIX;
            4'd7: encoded = SEVEN;
            4'd8: encoded = EIGHT;
            4'd9: encoded = NINE;
            default: encoded = 7'b1111111;
        endcase
    end
endmodule