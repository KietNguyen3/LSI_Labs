module spi_top (
    // System
    input        REFCLK,

    // Master user interface
    input  [7:0] MASTER_IN,
    input  [1:0] CNTL,
    output [7:0] MASTER_OUT,
    output       MASTER_READY,

    // Slave user interface
    input  [7:0] SLAVE_IN,
    input        LOAD,
    output [7:0] SLAVE_OUT,
    output       SLAVE_READY
);

    // ---- Internal SPI Bus Wires ----
    wire        MOSI;
    wire        MISO;
    wire        SCLK;
    wire [7:0]  SS;

    // ---- Instantiate Master ----
    spi_master master (
        .REFCLK  (REFCLK),
        .IN      (MASTER_IN),
        .CNTL    (CNTL),
        .OUT     (MASTER_OUT),
        .READY   (MASTER_READY),
        .MOSI    (MOSI),
        .MISO    (MISO),
        .SCLK    (SCLK),
        .SS      (SS)
    );

    // ---- Instantiate Slave ----
    // This slave is slave 0 → watches SS[0]
    spi_slave slave (
        .IN      (SLAVE_IN),
        .LOAD    (LOAD),
        .SCLK    (SCLK),
        .CS      (SS[0]),       // ← slave 0 watches bit 0 of SS
        .MOSI    (MOSI),
        .MISO    (MISO),
        .OUT     (SLAVE_OUT),
        .READY   (SLAVE_READY)
    );

endmodule