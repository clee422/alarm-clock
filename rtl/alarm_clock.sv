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
    // parameter SETUP_HOUR_HI     = 3'b001;
    // parameter SETUP_HOUR_LO     = 3'b010;
    // parameter SETUP_MINUTE_0_HI = 3'b011;
    // parameter SETUP_MINUTE_0_LO = 3'b100;
    // parameter SETUP_MINUTE_1_HI = 3'b101;
    // parameter SETUP_MINUTE_1_LO = 3'b110;

    // logic [2:0] state = 3'b000;

    logic [25:0] clk_count = 26'b0;

    logic [3:0] hour    = 4'd12;
    logic [7:0] minute  = 8'd0;
    logic [7:0] second  = 8'd0;

    logic [6:0] encoded_hour_tens;
    logic [6:0] encoded_hour_ones;
    logic [6:0] encoded_minute_tens;
    logic [6:0] encoded_minute_ones;

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
                HEX3 = encoded_hour_tens;
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
        end
        // Setup mode
        else begin
            
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

    assign LEDR = 10'b0;
endmodule
