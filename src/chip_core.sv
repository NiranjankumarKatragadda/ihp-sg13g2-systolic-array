`default_nettype none
module chip_core #(
    parameter NUM_INPUT_PADS=10, parameter NUM_OUTPUT_PADS=8,
    parameter NUM_BIDIR_PADS=8,  parameter NUM_ANALOG_PADS=8
)(
    input  logic clk, input logic rst_n,
    input  wire [NUM_INPUT_PADS-1:0]  input_in,
    output wire [NUM_OUTPUT_PADS-1:0] output_out,
    input  wire [NUM_BIDIR_PADS-1:0]  bidir_in,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_out,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_oe,
    inout  wire [NUM_ANALOG_PADS-1:0] analog
);
    assign bidir_oe='1;
    logic _u1; assign _u1=&bidir_in;
    logic _u2; assign _u2=&analog;
    localparam DATA_WIDTH=8, ACC_WIDTH=24;
    localparam IDLE=2'b00,LOAD=2'b01,COMPUTE=2'b10,READ=2'b11;
    logic [1:0] ctrl_in; logic [7:0] data_in; logic [1:0] col_sel;
    assign ctrl_in=input_in[9:8]; assign data_in=input_in[7:0]; assign col_sel=input_in[1:0];
    logic [1:0] sa_ctrl;
    assign sa_ctrl=(ctrl_in==LOAD||ctrl_in==COMPUTE)?ctrl_in:IDLE;
    logic [DATA_WIDTH-1:0] skew[0:3];
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin skew[0]<='0;skew[1]<='0;skew[2]<='0;skew[3]<='0; end
        else if (ctrl_in==COMPUTE) begin skew[0]<=data_in;skew[1]<=skew[0];skew[2]<=skew[1];skew[3]<=skew[2]; end
        else begin skew[0]<='0;skew[1]<='0;skew[2]<='0;skew[3]<='0; end
    end
    logic [DATA_WIDTH-1:0] a_row0,a_row1,a_row2,a_row3;
    always_comb begin
        case(ctrl_in)
            LOAD:    begin a_row0=data_in;a_row1=data_in;a_row2=data_in;a_row3=data_in; end
            COMPUTE: begin a_row0=skew[0];a_row1=skew[1];a_row2=skew[2];a_row3=skew[3]; end
            default: begin a_row0='0;a_row1='0;a_row2='0;a_row3='0; end
        endcase
    end
    logic [ACC_WIDTH-1:0] c_col0,c_col1,c_col2,c_col3;
    systolic_array_4x4 #(.DATA_WIDTH(DATA_WIDTH),.ACC_WIDTH(ACC_WIDTH),.N(4)) i_systolic (
        .clk(clk),.rst_n(rst_n),.ctrl(sa_ctrl),
        .a_row0_in(a_row0),.a_row1_in(a_row1),.a_row2_in(a_row2),.a_row3_in(a_row3),
        .c_out_col0(c_col0),.c_out_col1(c_col1),.c_out_col2(c_col2),.c_out_col3(c_col3)
    );
    logic [ACC_WIDTH-1:0] result[0:3];
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin result[0]<='0;result[1]<='0;result[2]<='0;result[3]<='0; end
        else if (ctrl_in==READ) begin result[0]<=c_col0;result[1]<=c_col1;result[2]<=c_col2;result[3]<=c_col3; end
    end
    logic [ACC_WIDTH-1:0] sel_result;
    always_comb begin
        case(col_sel)
            2'b00:sel_result=result[0]; 2'b01:sel_result=result[1];
            2'b10:sel_result=result[2]; 2'b11:sel_result=result[3];
        endcase
    end
    assign output_out=sel_result[7:0];
    logic out_valid;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) out_valid<=0; else out_valid<=(ctrl_in==READ);
    end
    assign bidir_out={ctrl_in,col_sel,out_valid,1'b0,2'b00};
endmodule
`default_nettype wire
