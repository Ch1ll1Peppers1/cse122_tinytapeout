//`timescale 1ns / 1ps

module matmul_3x3 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        load,
    input  wire        start,
    input  wire [7:0]  data_in,
    output reg  [15:0] data_out,
    output reg         done
);

    // Storage
    reg [7:0] A [0:8];
    reg [7:0] B [0:8];
    reg [15:0] C [0:8];

    reg [4:0] load_count;
    reg [3:0] i, j, k;
    reg [15:0] acc;

    reg computing;

    integer idx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_count <= 0;
            done <= 0;
            computing <= 0;
            i <= 0; j <= 0; k <= 0;
            acc <= 0;
        end
        else begin
            done <= 0;

            // LOAD MATRIX
            if (load) begin
                if (load_count < 9)
                    A[load_count] <= data_in;
                else if (load_count < 18)
                    B[load_count - 9] <= data_in;

                load_count <= load_count + 1;
            end

            // START COMPUTE
            if (start && !computing) begin
                computing <= 1;
                i <= 0; j <= 0; k <= 0;
                acc <= 0;
            end

            if (computing) begin
                acc <= acc + A[i*3 + k] * B[k*3 + j];
                k <= k + 1;

                if (k == 2) begin
                    C[i*3 + j] <= acc + A[i*3 + k] * B[k*3 + j];
                    acc <= 0;
                    k <= 0;
                    j <= j + 1;

                    if (j == 2) begin
                        j <= 0;
                        i <= i + 1;

                        if (i == 2) begin
                            computing <= 0;
                            done <= 1;
                        end
                    end
                end
            end
        end
    end

endmodule
