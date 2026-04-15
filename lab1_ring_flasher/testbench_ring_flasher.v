module ring_flasher_tb;

    reg clk;
    reg rst;
    reg rep;
    wire [15:0] leds;

    // Instantiate DUT
    ring_flasher uut (
        .clk(clk),
        .rst(rst),
        .rep(rep),
        .leds(leds)
    );

    // Expose internal signals for monitoring
    wire [3:0] counter = uut.counter;
    wire [1:0] state   = uut.state;

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("ring_flasher.vcd");
        $dumpvars(0, ring_flasher_tb);

        // Initialize
        rst = 1;
        rep = 0;

        // Assert active-low reset
        @(negedge clk); rst = 0;
        #20;
        rst = 1;

        // Wait for FORWARD -> BACKWARD -> IDLE cycle
        #500;

        // Trigger rep in IDLE
        @(negedge clk); rep = 1;
        #10;
        rep = 0;

        // Wait for another full cycle
        #500;

        // Trigger rep again
        @(negedge clk); rep = 1;
        #10;
        rep = 0;

        #300;
        $stop;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | rst=%b rep=%b state=%b counter=%0d leds=%b",
                  $time, rst, rep, state, counter, leds);
    end

endmodule