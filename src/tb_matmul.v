`timescale 1ns / 1ps

module tb_matmul;

    reg clk;
    reg rst;
    reg start;

    reg  [71:0] A_flat;
    reg  [71:0] B_flat;
    wire [143:0] C_flat;
    wire done;

    matmul_3x3 dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A_flat(A_flat),
        .B_flat(B_flat),
        .C_flat(C_flat),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    integer i;
    reg [15:0] expected [0:8];
    reg [15:0] result   [0:8];

    initial begin
        clk = 0;
        rst = 1;
        start = 0;

        #20;
        rst = 0;

        // Matrix A
        // 1 2 3
        // 4 5 6
        // 7 8 9
        A_flat = {8'd9,8'd8,8'd7,8'd6,8'd5,8'd4,8'd3,8'd2,8'd1};

        // Matrix B
        // 9 8 7
        // 6 5 4
        // 3 2 1
        B_flat = {8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,8'd9};

        // Expected results
        expected[0] = 30;
        expected[1] = 24;
        expected[2] = 18;

        expected[3] = 84;
        expected[4] = 69;
        expected[5] = 54;

        expected[6] = 138;
        expected[7] = 114;
        expected[8] = 90;

        #10;
        start = 1;
        #10;
        start = 0;

        wait(done);

        // Unpack result
        {result[8],result[7],result[6],
         result[5],result[4],result[3],
         result[2],result[1],result[0]} = C_flat;

        // Check results
        for (i = 0; i < 9; i = i + 1) begin
            if (result[i] !== expected[i]) begin
                $display("FAIL at index %0d: got %0d expected %0d",
                          i, result[i], expected[i]);
                $fatal;
            end
        end

        $display("=================================");
        $display("         TEST PASSED             ");
        $display("=================================");
        $finish;
    end

endmodule
