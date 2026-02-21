`timescale 1ns / 1ps

module matmul_3x3(
    input clk,
    input rst,
    input start,

    input  [71:0] A_flat,   // 9 elements × 8 bits
    input  [71:0] B_flat,

    output reg [143:0] C_flat, // 9 elements × 16 bits
    output reg done
);

    // Unpack A matrix
    wire [7:0] A0 = A_flat[7:0];
    wire [7:0] A1 = A_flat[15:8];
    wire [7:0] A2 = A_flat[23:16];
    wire [7:0] A3 = A_flat[31:24];
    wire [7:0] A4 = A_flat[39:32];
    wire [7:0] A5 = A_flat[47:40];
    wire [7:0] A6 = A_flat[55:48];
    wire [7:0] A7 = A_flat[63:56];
    wire [7:0] A8 = A_flat[71:64];

    // Unpack B matrix
    wire [7:0] B0 = B_flat[7:0];
    wire [7:0] B1 = B_flat[15:8];
    wire [7:0] B2 = B_flat[23:16];
    wire [7:0] B3 = B_flat[31:24];
    wire [7:0] B4 = B_flat[39:32];
    wire [7:0] B5 = B_flat[47:40];
    wire [7:0] B6 = B_flat[55:48];
    wire [7:0] B7 = B_flat[63:56];
    wire [7:0] B8 = B_flat[71:64];

    reg [15:0] C0,C1,C2,C3,C4,C5,C6,C7,C8;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            C_flat <= 0;
        end
        else begin
            if (start) begin

                // Row 0
                C0 <= A0*B0 + A1*B3 + A2*B6;
                C1 <= A0*B1 + A1*B4 + A2*B7;
                C2 <= A0*B2 + A1*B5 + A2*B8;

                // Row 1
                C3 <= A3*B0 + A4*B3 + A5*B6;
                C4 <= A3*B1 + A4*B4 + A5*B7;
                C5 <= A3*B2 + A4*B5 + A5*B8;

                // Row 2
                C6 <= A6*B0 + A7*B3 + A8*B6;
                C7 <= A6*B1 + A7*B4 + A8*B7;
                C8 <= A6*B2 + A7*B5 + A8*B8;

                done <= 1;

                C_flat <= {C8,C7,C6,C5,C4,C3,C2,C1,C0};
            end
            else begin
                done <= 0;
            end
        end
    end

endmodule
