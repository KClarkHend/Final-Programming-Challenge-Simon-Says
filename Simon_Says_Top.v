module Simon_Says_Top

(input i_Clk,
input i_Switch_1,
input i_Switch_2,
input i_Switch_3,
input i_Switch_4,
output o_LED_1,
output o_LED_2,
output o_LED_3,
output o_LED_4,
output o_Segment1_A
output o_Segment1_B,
output o_Segment1_C,
output o_Segment1_D,
output o_Segment1_E,
output o_Segment1_F,
output o_Segment1_G);

localparam DIFFICULTY = 6;
localparam CNTS_PER_SEC = 25000000;
localparam SIGNAL_MAX = 250000;

wire w_Switch_1,
wire w_Switch_2,
wire w_Switch_3,
wire w_Switch_4;

wire w_Segment1_A, 
wire w_Segment1_B,
wire w_Segment1_C,
wire w_Segment1_D,
wire w_Segment1_E,
wire w_Segment1_F,
wire w_Segment1_G;

wire [3:0] w_LcdBinary;

Signal_Filter #(.SIGNAL_MAX(SIGNAL_MAX)) Filter_Sw1_Inst
(.i_Clk(i_Clk),
.i_Unfiltered(i_Switch_1),
.o_Filtered(w_Switch_1));

Signal_Filter #(.SIGNAL_MAX(SIGNAL_MAX)) Filter_Sw2_Inst
(.i_Clk(i_Clk),
.i_Unfiltered(i_Switch_2),
.o_Filtered(w_Switch_2));

Signal_Filter #(.SIGNAL_MAX(SIGNAL_MAX)) Filter_Sw3_Inst
(.i_Clk(i_Clk),
.i_Unfiltered(i_Switch_3),
.o_Filtered(w_Switch_3));

Signal_Filter #(.SIGNAL_MAX(SIGNAL_MAX)) Filter_Sw4_Inst
(.i_Clk(i_Clk),
.i_Unfiltered(i_Switch_4),
.o_Filtered(w_Switch_4));

Seven_Segment_Display LCD_Display_Inst
(.i_Clk(i_Clk),
.i_LcdBinary(w_LcdBinary),
.o_Segment1_A(w_Segment1_A),
.o_Segment1_A(w_Segment1_B),
.o_Segment1_A(w_Segment1_C),
.o_Segment1_A(w_Segment1_D),
.o_Segment1_A(w_Segment1_E),
.o_Segment1_A(w_Segment1_F),
.o_Segment1_A(w_Segment1_G));

State_Machine #(.CNTS_PER_SEC(CNTS_PER_SEC), .DIFFICULTY(DIFFICULTY))
State_Machine_Inst
(.i_Clk(i_Clk),
.i_Switch_1(w_Switch_1),
.i_Switch_2(w_Switch_2),
.i_Switch_3(w_Switch_3),
.i_Switch_4(w_Switch_4),
.o_LED_1(o_LED_1),
.o_LED_2(o_LED_2),
.o_LED_3(o_LED_3),
.o_LED_4(o_LED_4),
.o_LcdBinary(w_LcdBinary));

assign o_Segment1_A = !w_Segment1_A;
assign o_Segment1_B = !w_Segment1_B;
assign o_Segment1_C = !w_Segment1_C;
assign o_Segment1_D = !w_Segment1_D;
assign o_Segment1_E = !w_Segment1_E;
assign o_Segment1_F = !w_Segment1_F;
assign o_Segment1_G = !w_Segment1_G;

endmodule