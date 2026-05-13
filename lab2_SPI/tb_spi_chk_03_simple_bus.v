`timescale 1ns/1ps

module tb_spi_chk_06_simple_bus;

`include "tb_spi_checklist_common.vh"

    integer sclk_edges;

    always @(posedge dut.master.SCLK) begin
        sclk_edges = sclk_edges + 1;
    end

    initial begin
        init_signals();
        sclk_edges = 0;
        repeat (2) @(posedge REFCLK);
        #1;

        $display("--- CHK 06 (simple_bus mapped): bus activity ---");
        select_slave(8'd0);
        preload_master(8'hAA);
        preload_slave(8'h55);
        start_transfer();

        if (sclk_edges == 0) begin
            $display("FAIL: SCLK never toggled during transfer");
            $finish;
        end
        if (MASTER_READY !== 1'b1) begin
            $display("FAIL: master not ready after transfer");
            $finish;
        end

        $display("PASS: bus activity observed");
        $finish;
    end

    initial begin
`ifdef XCELIUM
        $recordfile("waves");
        $recordvars("depth=0", tb_spi_chk_06_simple_bus);
`else
        $dumpfile("spi_chk_06_simple_bus.vcd");
        $dumpvars(0, tb_spi_chk_06_simple_bus);
`endif
    end

endmodule
