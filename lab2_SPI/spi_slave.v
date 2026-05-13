module spi_slave(
    input        LOAD,
    input        SCLK,
    input        CS,
    input        MOSI,
    input  [7:0] IN,

    output           MISO,
    output reg [7:0] OUT,
    output           READY
);

    reg [7:0] tx_reg;
    reg [7:0] rx_reg;
    reg [3:0] bit_cnt;

    // READY = idle = CS is HIGH (not selected)
    assign READY = CS;

    initial begin
        tx_reg  = 8'b0;
        rx_reg  = 8'b0;
        bit_cnt = 4'b0;
        OUT     = 8'b0;
    end

    // ---- LOAD: preload tx_reg BEFORE transmission ----
    always @(posedge LOAD) begin
        if (READY) begin
            tx_reg  <= IN;        // load data to send
            bit_cnt <= 4'b0;
        end
    end

    // ---- Sample MOSI on SCLK rising edge ----
    always @(posedge SCLK) begin
        if (~CS) begin          // only when selected
            rx_reg  <= {rx_reg[6:0], MOSI};

            if (bit_cnt == 4'd7) begin
                OUT <= {rx_reg[6:0], MOSI};
            end

            bit_cnt <= bit_cnt + 1;
        end else begin
            bit_cnt <= 4'b0;
        end
    end

    // ---- Shift MISO on SCLK falling edge so data is stable before next sample ----
    always @(negedge SCLK) begin
        if (~CS) begin
            tx_reg <= {tx_reg[6:0], 1'b0};
        end
    end

    // MISO always drives MSB of tx_reg
    assign MISO = tx_reg[7];

endmodule