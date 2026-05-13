module spi_master(
    input [7:0] IN,
    input [1:0] CNTL,
    input REFCLK,
    input MISO,

    output       MOSI,
    output reg [7:0] OUT,
    output reg READY,
    output       SCLK,
    output reg [7:0] SS
);

    //---- Internal Registers -----
    reg [7:0] tx_reg;
    reg [7:0] rx_reg;
    reg [7:0] ss_reg;
    reg [3:0] bit_cnt;

    // ---- State Machine ------
    localparam IDLE = 2'b00;
    localparam TRANSMIT = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    reg       sclk_reg;

    initial begin
        state   = IDLE;
        READY   = 1'b1;
        OUT     = 8'b0;
        SS      = 8'hFF;
        tx_reg  = 8'b0;
        rx_reg  = 8'b0;
        ss_reg  = 8'hFF;
        bit_cnt = 4'b0;
        sclk_reg = 1'b0;
    end

    assign MOSI = tx_reg[7];
    assign SCLK = sclk_reg;

    // ------ refclk generation --------
    always @(posedge REFCLK) begin
        case (state)

            IDLE: begin
                READY <= 1'b1;
                bit_cnt <= 4'b0;
                sclk_reg <= 1'b0;

                    case (CNTL)
                        2'b00: ;

                        2'b01: begin
                            //Ready to transmit data
                            tx_reg <= IN;
                        end

                        2'b10: begin
                            //Slave select
                            ss_reg = ~(8'b00000001 << IN);
                        end

                        2'b11: begin
                            READY <= 1'b0;
                            state <= TRANSMIT;
                            SS <= ss_reg;
                            rx_reg <= 8'b0;
                            bit_cnt <= 4'b0;
                            sclk_reg <= 1'b0;
                        end
                    endcase
            end

            TRANSMIT: begin
                sclk_reg <= ~sclk_reg;
            end

            DONE: begin
                SS <= 8'b11111111;
                READY <= 1'b1;
                OUT <= rx_reg;
                sclk_reg <= 1'b0;

                if(CNTL != 2'b11) begin
                    state <= IDLE;
                end
            end

        endcase
    end

    // Sample MISO on SCLK rising edge
    always @(posedge sclk_reg) begin
        if (state == TRANSMIT) begin
            rx_reg <= {rx_reg[6:0], MISO};
            bit_cnt <= bit_cnt + 1;

            if (bit_cnt == 4'd7) begin
                state <= DONE;
            end
        end
    end

    // Shift MOSI on SCLK falling edge
    always @(negedge sclk_reg) begin
        if (state == TRANSMIT) begin
            tx_reg <= {tx_reg[6:0], 1'b0};
        end
    end

endmodule