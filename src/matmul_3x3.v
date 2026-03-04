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

    reg [7:0]  A [0:8];
    reg [7:0]  B [0:8];
    reg [15:0] C [0:8];

    reg [4:0] load_count;
    reg [3:0] i, j, k;
    reg [3:0] out_index;
    reg [15:0] acc;

    reg computing;
    reg outputting;

    integer idx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_count <= 0;
            done <= 0;
            computing <= 0;
            outputting <= 0;
            i <= 0; j <= 0; k <= 0;
            out_index <= 0;
            acc <= 0;
            data_out <= 0;

            for (idx = 0; idx < 9; idx = idx + 1) begin
                A[idx] <= 0;
                B[idx] <= 0;
                C[idx] <= 0;
            end
        end else begin

            // Default
            done <= 0;

            // LOAD
            if (load) begin
                if (load_count < 9)
                    A[load_count] <= data_in;
                else if (load_count < 18)
                    B[load_count - 9] <= data_in;

                load_count <= load_count + 1;
            end

            // START COMPUTE
            if (start && !computing && !outputting) begin
                computing <= 1;
                i <= 0; j <= 0; k <= 0;
                acc <= 0;
            end

            // COMPUTE
            if (computing) begin
                acc <= acc + A[i*3 + k] * B[k*3 + j];

                if (k == 2) begin
                    C[i*3 + j] <= acc + A[i*3 + k] * B[k*3 + j];
                    acc <= 0;
                    k <= 0;

                    if (j == 2) begin
                        j <= 0;
                        if (i == 2) begin
                            computing <= 0;
                            outputting <= 1;
                            out_index <= 0;
                        end else begin
                            i <= i + 1;
                        end
                    end else begin
                        j <= j + 1;
                    end
                end else begin
                    k <= k + 1;
                end
            end

            // OUTPUT PHASE
            if (outputting) begin
                done <= 1;
                data_out <= C[out_index];
            
                if (out_index == 8) begin
                    outputting <= 0;
                end else begin
                    out_index <= out_index + 1;
                end
            end
        end
    end

endmodule
