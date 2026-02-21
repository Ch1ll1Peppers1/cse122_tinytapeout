module tt_um_ch1ll1peppers1_matmul(
    input  wire [7:0] ui,
    output reg  [7:0] uo,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire clk,
    input  wire rst_n
);

    // --- Internal registers ---
    reg [7:0] A [0:2][0:2];
    reg [7:0] B [0:2][0:2];
    reg [15:0] C [0:2][0:2];

    reg [4:0] load_counter;     // 0..17
    reg [3:0] compute_counter;  // 0..8
    reg loading;
    reg computing;
    reg done;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_counter <= 0;
            compute_counter <= 0;
            loading <= 1'b0;
            computing <= 1'b0;
            done <= 1'b0;
            uo <= 8'b0;
        end else begin
            // --- Loading phase ---
            if (ui[6]) begin  // load signal
                loading <= 1'b1;
                done <= 1'b0;
                if (load_counter < 9) begin
                    // Load A matrix
                    A[load_counter/3][load_counter%3] <= ui[5:0];
                end else begin
                    // Load B matrix
                    B[(load_counter-9)/3][(load_counter-9)%3] <= ui[5:0];
                end
                load_counter <= load_counter + 1;
                if (load_counter == 17) begin
                    loading <= 1'b0;
                    computing <= 1'b1;
                    compute_counter <= 0;
                end
            end

            // --- Compute phase ---
            if (computing) begin
                integer i,j,k;
                i = compute_counter / 3;
                j = compute_counter % 3;
                C[i][j] = 0;
                for (k=0; k<3; k=k+1)
                    C[i][j] = C[i][j] + A[i][k]*B[k][j];
                // output lower 8 bits first
                uo <= C[i][j][7:0];
                compute_counter <= compute_counter + 1;
                if (compute_counter == 9) begin
                    computing <= 1'b0;
                    done <= 1'b1;
                end
            end

            // --- Done flag ---
            if (done) begin
                uo <= 8'd255; // example signal for done
            end
        end
    end

endmodule
