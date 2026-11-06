module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 20
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [1:0]             ctrl,
    input  wire [DATA_WIDTH-1:0]  a_in,
    input  wire [ACC_WIDTH-1:0]   c_in,
    output reg  [DATA_WIDTH-1:0]  a_out,
    output reg  [ACC_WIDTH-1:0]   c_out
);
    localparam IDLE=2'b00, LOAD=2'b01, COMPUTE=2'b10;
    reg [DATA_WIDTH-1:0] weight_reg;
    wire [2*DATA_WIDTH-1:0] product;
    assign product = a_in * weight_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_reg<=0; a_out<=0; c_out<=0;
        end else begin
            case (ctrl)
                LOAD:    begin weight_reg<=a_in; a_out<=a_in; c_out<=0; end
                COMPUTE: begin c_out<=c_in+product; a_out<=a_in; end
                default: begin a_out<=a_out; c_out<=c_out; end
            endcase
        end
    end
endmodule
