/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ch1ll1peppers1 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [7:0] data_in = ui_in;
    wire load  = ui_in[6];
    wire start = ui_in[7];

    wire [15:0] result;
    wire done;

    matmul_3x3 core (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .start(start),
        .data_in(data_in),
        .data_out(result),
        .done(done)
    );

    assign uo_out[3:0] = result[3:0];
    assign uo_out[4]   = done;
    assign uo_out[7:5] = 3'b000;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, uio_in};

endmodule
