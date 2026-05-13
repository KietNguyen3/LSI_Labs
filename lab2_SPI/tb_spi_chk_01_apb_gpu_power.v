`timescale 1ns/1ps

module tb_spi_chk_01_apb_gpu_power;

`include "tb_spi_checklist_common.vh"

    initial begin
        init_signals();
        repeat (2) @(posedge REFCLK);
        #1;

        $display("--- CHK 01 (apb_gpu_power mapped): idle ready/preload ---");
        if (SLAVE_READY !== 1'b1) begin
            $display("FAIL: slave not ready while CS is high");
            $finish;
        end
        preload_slave(8'h5A);

        $display("PASS: idle ready and preload path works");
        $finish;
    end

    initial begin
`ifdef XCELIUM
        $recordfile("waves");
        $recordvars("depth=0", tb_spi_chk_01_apb_gpu_power);
`else
        $dumpfile("spi_chk_01_apb_gpu_power.vcd");
        $dumpvars(0, tb_spi_chk_01_apb_gpu_power);
`endif
    end

endmodule
