`timescale 1ns/1ps

module tb_spi_slave;

    reg        LOAD;
    reg        SCLK;
    reg        CS;
    reg        MOSI;
    reg  [7:0] IN;

    wire       MISO;
    wire [7:0] OUT;
    wire       READY;

    spi_slave dut (
        .LOAD (LOAD),
        .SCLK (SCLK),
        .CS   (CS),
        .MOSI (MOSI),
        .IN   (IN),
        .MISO (MISO),
        .OUT  (OUT),
        .READY(READY)
    );

    reg [7:0] master_tx;
    reg [7:0] master_rx;

    task spi_tick;
    begin
        // data should be stable before posedge
        SCLK = 1'b0;
        #5;
        SCLK = 1'b1;
        #5;
        // complete the cycle so the slave sees the falling edge
        SCLK = 1'b0;
        #5;
    end
    endtask

    initial begin
        LOAD = 1'b0;
        SCLK = 1'b0;
        CS   = 1'b1;
        MOSI = 1'b0;
        IN   = 8'b0;
        master_tx = 8'b0;
        master_rx = 8'b0;

        #10;

        $display("--- SLAVE-ONLY TEST ---");

        // Preload slave TX data
        IN = 8'hA5;
        LOAD = 1'b1;
        #5;
        LOAD = 1'b0;

        // Start transfer
        CS = 1'b0;
        master_tx = 8'h3C;
        master_rx = 8'b0;

        repeat (8) begin
            MOSI = master_tx[7];
            spi_tick();
            master_rx = {master_rx[6:0], MISO};
            master_tx = {master_tx[6:0], 1'b0};
        end

        CS = 1'b1;
        #10;

        if (OUT !== 8'h3C) begin
            $display("FAIL: slave OUT 0x%h (expected 0x3C)", OUT);
        end else begin
            $display("PASS: slave MOSI sample correct");
        end

        if (master_rx !== 8'hA5) begin
            $display("FAIL: master RX 0x%h (expected 0xA5)", master_rx);
        end else begin
            $display("PASS: slave MISO stream correct");
        end

        $display("--- SLAVE-ONLY DONE ---");
        $finish;
    end

    initial begin
        $dumpfile("spi_slave_wave.vcd");
        $dumpvars(0, tb_spi_slave);
    end

endmodule
