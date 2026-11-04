module alarm_clock (
    input logic CLOCK_50,
    input logic [3:0] KEY,
    input logic [9:0] SW,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [9:0] LEDR
);
    // // States
    // parameter CLOCK             = 3'b000;
    parameter SETUP_HOUR_HI     = 3'b001;
    parameter SETUP_HOUR_LO     = 3'b010;
    parameter SETUP_MINUTE_0_HI = 3'b011;
    parameter SETUP_MINUTE_0_LO = 3'b100;
    parameter SETUP_MINUTE_1_HI = 3'b101;
    parameter SETUP_MINUTE_1_LO = 3'b110;

    logic [2:0] state = SETUP_HOUR_HI;

    logic prev_key_0 = 1'b1;
    logic prev_key_1 = 1'b1;
    logic prev_key_2 = 1'b1;
    logic prev_key_3 = 1'b1;

    logic [25:0] clk_count = 26'b0;

    logic [3:0] hour    = 4'd12;
    logic [8:0] minute  = 9'd0;
    logic [7:0] second  = 8'd0;

    logic [6:0] encoded_hour_tens;
    logic [6:0] encoded_hour_ones;
    logic [6:0] encoded_minute_tens;
    logic [6:0] encoded_minute_ones;

    logic [6:0] display_hour_tens;

    always_ff @(posedge CLOCK_50) begin
        // Clock mode
        if (!SW[9]) begin
            if (clk_count == 49_999_999) begin
                clk_count <= 0;
                if (second == 59) begin
                    second <= 0;
                    if (minute == 59) begin
                        minute <= 0;
                        if (hour == 12)
                            hour <= 1;
                        else
                            hour <= hour + 4'b1;
                    end
                    else
                        minute <= minute + 8'b1;
                end
                else
                    second <= second + 8'b1;
            end
            else
                clk_count <= clk_count + 26'b1;

            // Dimmer
            if (clk_count % 16 == 0) begin
                HEX3 = display_hour_tens;
                HEX2 = encoded_hour_ones;
                HEX1 = encoded_minute_tens;
                HEX0 = encoded_minute_ones;
            end
            else begin
                HEX3 = 7'b1111111;
                HEX2 = 7'b1111111;
                HEX1 = 7'b1111111;
                HEX0 = 7'b1111111;
            end
            LEDR = 10'b0000000000;
        end
        // Setup mode
        else begin
            case(state)
                SETUP_HOUR_HI: begin 
                    HEX3 = display_hour_tens;
                    HEX2 = encoded_hour_ones;
                    HEX1 = encoded_minute_tens;
                    HEX0 = encoded_minute_ones;
                    LEDR = 10'b0001100000;
                    if (!KEY[2] && prev_key_2)
                        state <= SETUP_MINUTE_0_HI;
                    else if (!KEY[0] && prev_key_0) begin
                        if (hour == 12)
                            hour <= 4'd1;
                        else
                            hour <= hour + 4'd1;
                    end
                    else if (!KEY[1] && prev_key_1) begin
                        if (hour == 1)
                            hour <= 4'd12;
                        else
                            hour <= hour - 4'd1;
                    end
                    else
                        state <= SETUP_HOUR_HI;
                end
                SETUP_MINUTE_0_HI: begin
                    HEX3 = display_hour_tens;
                    HEX2 = encoded_hour_ones;
                    HEX1 = encoded_minute_tens;
                    HEX0 = encoded_minute_ones;
                    LEDR = 10'b0000010000;
                    if (!KEY[2] && prev_key_2)
                        state <= SETUP_MINUTE_1_HI;
                    else if (!KEY[3] && prev_key_3)
                        state <= SETUP_HOUR_HI;
                    else if (!KEY[0] && prev_key_0)
                        minute <= (minute + 10) % 60;
                    else if (!KEY[1] && prev_key_1) begin
                        if (minute < 10)
                            minute <= minute + 50;
                        else
                            minute <= minute - 10;
                    end
                    else
                        state <= SETUP_MINUTE_0_HI;                    
                end
                SETUP_MINUTE_1_HI: begin
                    HEX3 = display_hour_tens;
                    HEX2 = encoded_hour_ones;
                    HEX1 = encoded_minute_tens;
                    HEX0 = encoded_minute_ones;
                    LEDR = 10'b0000001000;
                    if (!KEY[3] && prev_key_3)
                        state <= SETUP_MINUTE_0_HI;
                    else if (!KEY[0] && prev_key_0)
                        minute <= (minute + 1) % 60;
                    else if (!KEY[1] && prev_key_1) begin
                        if (minute == 0)
                            minute <= 8'd59;
                        else
                            minute <= minute - 1;
                    end
                    else
                        state <= SETUP_MINUTE_1_HI;
                end
                default: state <= SETUP_HOUR_HI;
            endcase
            prev_key_0 <= KEY[0];
            prev_key_1 <= KEY[1];
            prev_key_2 <= KEY[2];
            prev_key_3 <= KEY[3];
        end
    end
    
    sseg_encoder hour_tens_encoder(
        .digit      (hour / 10),
        .encoded    (encoded_hour_tens)
    );
    sseg_encoder hour_ones_encoder(
        .digit      (hour % 10),
        .encoded    (encoded_hour_ones)
    );
    sseg_encoder minute_tens_encoder(
        .digit      (minute / 10),
        .encoded    (encoded_minute_tens)
    );
    sseg_encoder minute_ones_encoder(
        .digit      (minute % 10),
        .encoded    (encoded_minute_ones)
    );

    assign display_hour_tens = (hour < 10) ? 7'b1111111 : encoded_hour_tens;
endmodule
