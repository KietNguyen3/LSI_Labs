`timescale 1ns/1ps

module tb_spi_checklist;

    reg        REFCLK;
    reg  [7:0] MASTER_IN;
    reg  [1:0] CNTL;
    reg  [7:0] SLAVE_IN;
    reg        LOAD;

    wire [7:0] MASTER_OUT;
    wire       MASTER_READY;
    wire [7:0] SLAVE_OUT;
    wire       SLAVE_READY;

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

    initial REFCLK = 1'b0;
    always #5 REFCLK = ~REFCLK;

    task preload_slave(input [7:0] value);
    begin
        SLAVE_IN = value;
        LOAD = 1'b1;
        @(posedge REFCLK);
        #1;
        LOAD = 1'b0;
        @(posedge REFCLK);
        #1;
    end
    endtask

    task preload_master(input [7:0] value);
    begin
        MASTER_IN = value;
        CNTL = 2'b01;
        @(posedge REFCLK);
        #1;
        CNTL = 2'b00;
        @(posedge REFCLK);
        #1;
    end
    endtask

    task select_slave(input [7:0] index);
    begin
        MASTER_IN = index;
        CNTL = 2'b10;
        @(posedge REFCLK);
        #1;
        CNTL = 2'b00;
        @(posedge REFCLK);
        #1;
    end
    endtask

    task start_transfer;
    begin
        CNTL = 2'b11;
        @(posedge REFCLK);
        #1;
        wait (MASTER_READY == 1'b1);
        CNTL = 2'b00;
        @(posedge REFCLK);
        #1;
    end
    endtask

    initial begin
        MASTER_IN = 8'b0;
        CNTL      = 2'b00;
        SLAVE_IN  = 8'b0;
        LOAD      = 1'b0;

        repeat (2) @(posedge REFCLK);
        #1;

        $display("--- CHECK 1: Idle slave ready and preload path ---");
        if (SLAVE_READY !== 1'b1) begin
            $display("FAIL: slave should be ready while CS is high");
            $finish;
        end
        preload_slave(8'hFF);

        $display("--- CHECK 2: First full-duplex transfer ---");
        select_slave(8'd0);
        preload_master(8'hA5);
        preload_slave(8'hFF);
        start_transfer();
        if (SLAVE_OUT !== 8'hA5) begin
            $display("FAIL: slave received 0x%h, expected 0xA5", SLAVE_OUT);
            $finish;
        end
        if (MASTER_OUT !== 8'hFF) begin
            $display("FAIL: master received 0x%h, expected 0xFF", MASTER_OUT);
            $finish;
        end

        $display("--- CHECK 3: Second transfer with new preload ---");
        preload_slave(8'h3C);
        preload_master(8'h69);
        start_transfer();
        if (SLAVE_OUT !== 8'h69) begin
            $display("FAIL: slave received 0x%h, expected 0x69", SLAVE_OUT);
            $finish;
        end
        if (MASTER_OUT !== 8'h3C) begin
            $display("FAIL: master received 0x%h, expected 0x3C", MASTER_OUT);
            $finish;
        end

        $display("--- CHECK 4: Slave remains ready after transfer ---");
        if (SLAVE_READY !== 1'b1) begin
            $display("FAIL: slave should be ready after transfer");
            $finish;
        end

        $display("--- ALL CHECKLIST TESTS PASSED ---");
        $finish;
    end

    initial begin
    `ifdef XCELIUM
        $recordfile("waves");
        $recordvars("depth=0", tb_spi_checklist);
    `else
        $dumpfile("spi_checklist.vcd");
        $dumpvars(0, tb_spi_checklist);
    `endif
    end

    // Debug monitor: print bus/registers each REFCLK edge
    always @(posedge REFCLK) begin
        $display("T=%0t SCLK=%b MOSI=%b MISO=%b m_tx=%h s_tx=%h m_rx=%h s_rx=%h m_cnt=%0d s_cnt=%0d", $time,
                 dut.master.SCLK, dut.master.MOSI, dut.slave.MISO,
                 dut.master.tx_reg, dut.slave.tx_reg, dut.master.rx_reg, dut.slave.rx_reg,
                 dut.master.bit_cnt, dut.slave.bit_cnt);
    end

endmodule