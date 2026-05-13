// Common SPI checklist testbench helpers. Include inside a module.

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

    task init_signals;
    begin
        MASTER_IN = 8'b0;
        CNTL      = 2'b00;
        SLAVE_IN  = 8'b0;
        LOAD      = 1'b0;
    end
    endtask

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
