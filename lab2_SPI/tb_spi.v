`timescale 1ns/1ps

module tb_spi;

    // ---- Inputs to top module ----
    reg        REFCLK;
    reg  [7:0] MASTER_IN;
    reg  [1:0] CNTL;
    reg  [7:0] SLAVE_IN;
    reg        LOAD;

    // ---- Outputs from top module ----
    wire [7:0] MASTER_OUT;
    wire       MASTER_READY;
    wire [7:0] SLAVE_OUT;
    wire       SLAVE_READY;

    // ---- Instantiate Top Module ----
    spi_top dut (
        .REFCLK      (REFCLK),
        .MASTER_IN   (MASTER_IN),
        .CNTL        (CNTL),
        .MASTER_OUT  (MASTER_OUT),
        .MASTER_READY(MASTER_READY),
        .SLAVE_IN    (SLAVE_IN),
        .LOAD        (LOAD),
        .SLAVE_OUT   (SLAVE_OUT),
        .SLAVE_READY (SLAVE_READY)
    );

    // ---- Clock Generation ----
    // 10ns period = 100MHz
    initial REFCLK = 0;
    always #5 REFCLK = ~REFCLK;

    // ---- Main Test ----
    initial begin
        // Initialize everything
        MASTER_IN = 8'b0;
        SLAVE_IN  = 8'b0;
        CNTL      = 2'b00;
        LOAD      = 1'b0;

        // Wait a few cycles
        @(posedge REFCLK); #1;
        @(posedge REFCLK); #1;

        // ============================================
        // TEST 1: Load slave TX data (SLAVE_IN = 0x3C)
        // ============================================
        $display("--- TEST 1: Preload Slave ---");
        SLAVE_IN = 8'hFF;
        LOAD     = 1'b1;
        @(posedge REFCLK); #1;
        LOAD     = 1'b0;
        $display("Slave preloaded with: %h", SLAVE_IN);

        // ============================================
        // TEST 2: Select slave 0
        // ============================================
        $display("--- TEST 2: Select Slave 0 ---");
        MASTER_IN = 8'd0;           // slave index 0
        CNTL      = 2'b10;          // load slave select
        @(posedge REFCLK); #1;
        CNTL      = 2'b00;          // back to no-op
        @(posedge REFCLK); #1;

        // ============================================
        // TEST 3: Load master TX data (0xA5)
        // ============================================
        $display("--- TEST 3: Load Master TX = 0xA5 ---");
        MASTER_IN = 8'hA5;
        CNTL      = 2'b01;          // load TX data
        @(posedge REFCLK); #1;
        CNTL      = 2'b00;
        @(posedge REFCLK); #1;

        // ============================================
        // TEST 4: Begin transmission
        // ============================================
        $display("--- TEST 4: Begin Transmission ---");
        CNTL = 2'b11;               // start!
        @(posedge REFCLK); #1;

        // Wait for master to finish (READY goes HIGH again)
        wait(MASTER_READY == 1'b1);
        CNTL = 2'b00;               // release CNTL
        @(posedge REFCLK); #1;
        @(posedge REFCLK); #1;

        // ============================================
        // CHECK RESULTS
        // ============================================
        $display("--- RESULTS ---");
        $display("Master sent:     0xA5");
        $display("Slave received:  0x%h (expected 0xA5)", SLAVE_OUT);
        $display("Slave sent:      0xFF");
        $display("Master received: 0x%h (expected 0xFF)", MASTER_OUT);

        if (SLAVE_OUT == 8'hA5)
            $display("PASS: Slave received correct data");
        else
            $display("FAIL: Slave received wrong data");

        if (MASTER_OUT == 8'hFF)
            $display("PASS: Master received correct data");
        else
            $display("FAIL: Master received wrong data");

        // ============================================
        // TEST 5: Loopback test (master talks to itself)
        // ============================================
        $display("--- TEST 5: Second Transfer ---");
        SLAVE_IN = 8'h3C;
        LOAD     = 1'b1;
        @(posedge REFCLK); #1;
        LOAD     = 1'b0;

        MASTER_IN = 8'h69;
        CNTL      = 2'b01;
        @(posedge REFCLK); #1;
        CNTL      = 2'b11;
        @(posedge REFCLK); #1;

        wait(MASTER_READY == 1'b1);
        CNTL = 2'b00;
        @(posedge REFCLK); #1;
        @(posedge REFCLK); #1;

        $display("Master sent:     0x69");
        $display("Slave received:  0x%h (expected 0x69)", SLAVE_OUT);
        $display("Slave sent:      0x3C");
        $display("Master received: 0x%h (expected 0x3C)", MASTER_OUT);

        $display("--- ALL TESTS DONE ---");
        $finish;
    end

    // ---- Waveform Dump ----
    initial begin
        $dumpfile("spi_wave.vcd");
        $dumpvars(0, tb_spi);
    end

    // Debug: monitor master state and counters
    always @(posedge REFCLK) begin
        $display("T=%0t state=%b bit_cnt=%0d READY=%b SCLK=%b", $time, dut.master.state, dut.master.bit_cnt, dut.master.READY, dut.master.SCLK);
    end

endmodule