`timescale 1ns/1ps

module tb_spi_chk_04_register_rw;

`include "tb_spi_checklist_common.vh"

    initial begin
        init_signals();
        repeat (2) @(posedge REFCLK);
        #1;

        $display("--- CHK 04 (register_rw mapped): preload and transfer ---");
        select_slave(8'd0);
        preload_master(8'hA5);
        preload_slave(8'h3C);
        start_transfer();

        if (SLAVE_OUT !== 8'hA5) begin
            $display("FAIL: slave received 0x%h (expected 0xA5)", SLAVE_OUT);
            $finish;
        end
        if (MASTER_OUT !== 8'h3C) begin
            $display("FAIL: master received 0x%h (expected 0x3C)", MASTER_OUT);
            $finish;
        end

        $display("PASS: preload and transfer behavior correct");
        $finish;
    end

    initial begin
`ifdef XCELIUM
        $recordfile("waves");
        $recordvars("depth=0", tb_spi_chk_04_register_rw);
`else
        $dumpfile("spi_chk_04_register_rw.vcd");
        $dumpvars(0, tb_spi_chk_04_register_rw);
`endif
    end

endmodule
