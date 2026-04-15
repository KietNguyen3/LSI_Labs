module ring_flasher(
    input clk,
    input rst,     // active LOW
    input rep,
    output reg [15:0] leds
);

reg [3:0] counter;
reg [1:0] state;
reg temp;

localparam IDLE     = 2'd0;
localparam FORWARD  = 2'd1;
localparam BACKWARD = 2'd2;

always @(posedge clk or negedge rst) begin 
    if (!rst) begin
        leds <= 16'b0;
        counter <= 0;
        state <= FORWARD;
    end
    else begin

        case (state)
        // 🔹 Forward 8 steps
        FORWARD: begin
            temp = leds[15] ^ 1'b1;
            leds <= {leds[14:0], temp};
            counter <= counter + 1;

            if (counter == 4'd7) begin
                counter <= 0;
                state <= BACKWARD;
            end
        end

        // 🔹 Backward 4 steps
        BACKWARD: begin
            temp = leds[0] ^ 1'b1;
            leds <= {temp, leds[15:1]};
            counter <= counter + 1;

            if(leds == 16'b0)
                state <= IDLE;

            else if(counter == 4'd3) begin
                counter <= 0;
                state <= FORWARD;
            end
        end

        // 🔹 Wait for rep
        IDLE: begin
            leds <= 16'b0;

            if (rep) begin
                counter <= 0;
                state <= FORWARD;
            end
        end

        endcase
    end
end

endmodule