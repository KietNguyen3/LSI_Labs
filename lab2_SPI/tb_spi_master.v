`timescale 1ns/1ps

module tb_spi_master;

    reg        REFCLK;
    reg  [7:0] IN;
    reg  [1:0] CNTL;
    reg        MISO;

    wire       MOSI;
    wire [7:0] OUT;
    wire       READY;
    wire       SCLK;
    wire [7:0] SS;

    spi_master dut (
        .IN     (IN),
        .CNTL   (CNTL),
        .REFCLK (REFCLK),
        .MISO   (MISO),
        .MOSI   (MOSI),
        .OUT    (OUT),
        .READY  (READY),
        .SCLK   (SCLK),
        .SS     (SS)
    );

    initial REFCLK = 1'b0;
    always #5 REFCLK = ~REFCLK;

    reg [7:0] slave_tx;
    reg [7:0] slave_rx;

    task start_transfer;
    begin
        CNTL = 2'b11;
        @(posedge REFCLK); #1;
        wait (READY == 1'b1);
        CNTL = 2'b00;
        @(posedge REFCLK); #1;
    end
    endtask

    always @(posedge SCLK) begin
        if (SS[0] == 1'b0) begin
            slave_rx <= {slave_rx[6:0], MOSI};
        end
    end

    always @(negedge SCLK or negedge SS[0]) begin
        if (SS[0] == 1'b0) begin
            MISO <= slave_tx[7];
            slave_tx <= {slave_tx[6:0], 1'b0};
        end
    end

    integer edge_cnt;
    initial edge_cnt = 0;

    always @(posedge SCLK) begin
        if (SS[0] == 1'b0) begin
            edge_cnt = edge_cnt + 1;
            if (edge_cnt <= 4) begin
                $display("posedge SCLK #%0d: MISO=%b", edge_cnt, MISO);
            end
        end
    end

    always @(negedge SCLK) begin
        if (SS[0] == 1'b0) begin
            if (edge_cnt <= 4) begin
                $display("negedge SCLK #%0d: MISO_next=%b", edge_cnt + 1, slave_tx[7]);
            end
        end
    end

    initial begin
        IN   = 8'b0;
        CNTL = 2'b00;
        MISO = 1'b0;
        slave_tx = 8'b0;
        slave_rx = 8'b0;

        @(posedge REFCLK); #1;
        @(posedge REFCLK); #1;

        $display("--- MASTER-ONLY TEST ---");

        // Select slave 0
        IN = 8'd0;
        CNTL = 2'b10;
        @(posedge REFCLK); #1;
        CNTL = 2'b00;
        @(posedge REFCLK); #1;

        // Load master TX
        IN = 8'hA5;
        CNTL = 2'b01;
        @(posedge REFCLK); #1;
        CNTL = 2'b00;
        @(posedge REFCLK); #1;

        // Prepare slave model data
        slave_tx = 8'hAA;
        slave_rx = 8'b0;
        MISO = slave_tx[7];

        start_transfer();

        if (slave_rx !== 8'hA5) begin
            $display("FAIL: slave model received 0x%h (expected 0xA5)", slave_rx);
        end else begin
            $display("PASS: master MOSI stream correct");
        end

        if (OUT !== 8'hAA) begin
            $display("FAIL: master OUT 0x%h (expected 0xAA)", OUT);
        end else begin
            $display("PASS: master MISO sample correct");
        end

        $display("--- MASTER-ONLY DONE ---");
        $finish;
    end

    initial begin
        $dumpfile("spi_master_wave.vcd");
        $dumpvars(0, tb_spi_master);
    end

endmodule
