module systolic_array_4x4 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 24,
    parameter N          = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [1:0]             ctrl,
    input  wire [DATA_WIDTH-1:0]  a_row0_in,
    input  wire [DATA_WIDTH-1:0]  a_row1_in,
    input  wire [DATA_WIDTH-1:0]  a_row2_in,
    input  wire [DATA_WIDTH-1:0]  a_row3_in,
    output wire [ACC_WIDTH-1:0]   c_out_col0,
    output wire [ACC_WIDTH-1:0]   c_out_col1,
    output wire [ACC_WIDTH-1:0]   c_out_col2,
    output wire [ACC_WIDTH-1:0]   c_out_col3
);
    localparam [ACC_WIDTH-1:0] ZERO_ACC = {ACC_WIDTH{1'b0}};
    wire [DATA_WIDTH-1:0] a_grid [0:N-1][0:N];
    wire [ACC_WIDTH-1:0]  c_grid [0:N][0:N-1];
    assign a_grid[0][0]=a_row0_in; assign a_grid[1][0]=a_row1_in;
    assign a_grid[2][0]=a_row2_in; assign a_grid[3][0]=a_row3_in;
    genvar gc;
    generate
        for (gc=0;gc<N;gc=gc+1) begin:top_edge
            assign c_grid[0][gc]=ZERO_ACC;
        end
    endgenerate
    genvar r,c;
    generate
        for (r=0;r<N;r=r+1) begin:row
            for (c=0;c<N;c=c+1) begin:col
                pe #(.DATA_WIDTH(DATA_WIDTH),.ACC_WIDTH(ACC_WIDTH)) pe_inst (
                    .clk(clk),.rst_n(rst_n),.ctrl(ctrl),
                    .a_in(a_grid[r][c]),.c_in(c_grid[r][c]),
                    .a_out(a_grid[r][c+1]),.c_out(c_grid[r+1][c])
                );
            end
        end
    endgenerate
    assign c_out_col0=c_grid[N][0]; assign c_out_col1=c_grid[N][1];
    assign c_out_col2=c_grid[N][2]; assign c_out_col3=c_grid[N][3];
endmodule
