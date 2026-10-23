`timescale 1ns/1ps
module fir_direct #(
    parameter N  = 100,
    parameter DW = 16,
    parameter CW = 16
)(
    input  clk,
    input  rst,
    input  signed [DW-1:0] x_in,
    input  sample_valid,
    output reg signed [DW-1:0] y_out
);

    reg signed [DW-1:0] shift_reg [0:N-1];
    reg signed [CW-1:0] coeff [0:N-1];
    reg signed [DW+CW+7:0] acc;
    integer i;

    initial begin
        $readmemh("C:/manoj/exp04/verilogexp04/coefficients_Q214_hex.txt", coeff);

        // synthesis translate_off
        #1;
        $display("DEBUG: coeff[0]=%d coeff[N/2]=%d coeff[N-1]=%d", coeff[0], coeff[N/2], coeff[N-1]);
        // synthesis translate_on
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < N; i = i + 1)
                shift_reg[i] <= 0;
            y_out <= 0;
        end 
        else if (sample_valid) begin
            for (i = N-1; i > 0; i = i - 1)
                shift_reg[i] <= shift_reg[i-1];
            shift_reg[0] <= x_in;

            acc = 0;
            for (i = 0; i < N; i = i + 1)
                acc = acc + $signed(shift_reg[i]) * $signed(coeff[i]);

            // synthesis translate_off
            if ($time < 2000)
                $display("DEBUG: acc=%0d x0=%d", acc, shift_reg[0]);
            // synthesis translate_on

            // Debug output: direct bits from accumulator
            y_out <= acc[29:14];
        end
    end

endmodule

