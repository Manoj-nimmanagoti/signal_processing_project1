`timescale 1ns/1ps
module fir_genva #(
    parameter N  = 100,        // Filter length (must be even)
    parameter DW = 16,         // Data width
    parameter CW = 16          // Coefficient width
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire signed [DW-1:0]  x_in,
    input  wire                  sample_valid,
    output reg  signed [DW-1:0]  y_out
);

    reg signed [DW-1:0] shift_reg [0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : SHIFT_REG_GEN
            always @(posedge clk) begin
                if (rst) begin
                    shift_reg[i] <= 0;
                end
                else if (sample_valid) begin
                    if (i == 0)
                        shift_reg[0] <= x_in;
                    else
                        shift_reg[i] <= shift_reg[i-1];
                end
            end
        end
    endgenerate
	 
    reg signed [CW-1:0] coeff [0:(N/2)-1];
    initial begin
        $readmemh("C:/dspverilogcodes/exp04/MATexp04/coefficients_Q214_hex_half.txt", coeff);
        #1;
        $display("DEBUG: coeff[0]=%d coeff[N/2-1]=%d", coeff[0], coeff[(N/2)-1]);
    end

    wire signed [DW+CW:0] products [0:(N/2)-1];

    genvar k;
    generate
        for (k = 0; k < N/2; k = k + 1) begin : PRODUCT_GEN
            assign products[k] = $signed(coeff[k]) *
                                 ($signed(shift_reg[k]) + $signed(shift_reg[N-1-k]));
        end
    endgenerate
	 
    reg signed [DW+CW+7:0] acc;
    integer j;

    always @(*) begin
        acc = 0;
        for (j = 0; j < N/2; j = j + 1)
            acc = acc + products[j];
    end

    always @(posedge clk) begin
        if (rst)
            y_out <= 0;
        else if (sample_valid)
            y_out <= acc[29:14]; 
    end

endmodule
