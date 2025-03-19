module State_Machine #(parameter CNTS_PER_SEC = 25000000,  // calculate count for 1 sec on 25MHz clock
                       parameter DIFFICULTY = 6)

(
    input i_Clk,
    input i_Switch_1,
    input i_Switch_2,
    input i_Switch_3,
    input i_Switch_4,
    output o_LED_1,
    output o_LED_2,
    output o_LED_3,
    output o_LED_4,
	output reg [3:0] o_LcdBinary; //assign 4-bit output register for LcdBinary
);


// Local parameters for the seven states **ASK**
localparam START           = 3'b000;
localparam SEQUENCE_OFF    = 3'b001;
localparam SEQUENCE_ON     = 3'b010;
localparam PLAYER_INPUT    = 3'b011;
localparam INCREASE_DIFF   = 3'b100;
localparam END             = 3'b101;
localparam SUCCESS         = 3'b110;

//Assign wires for switches 1-4
wire w_Switch_1 = i_Switch_1;
wire w_Switch_2 = i_Switch_2;
wire w_Switch_3 = i_Switch_3;
wire w_Switch_4 = i_Switch_4

//Assign wires for LCD segment1 A-G
wire w_LcdSeg_A;
wire w_LcdSeg_B;
wire w_LcdSeg_C;
wire w_LcdSeg_D;
wire w_LcdSeg_E;
wire w_LcdSeg_F;
wire w_LcdSeg_G;

//Assign 4-bit wire for LcdBinary
reg [3:0] r_LcdBinary;
assign o_LcdBinary = r_LcdBinary;

//Assign a register for state machine current state. Determine how many bits are needed for 7 states. **ASK**
reg [2:0] r_Current_State;

//Assign registers for switches 1-4
reg r_ButtonPressed;
reg r_Toggle;
reg r_Switch_1, r_Switch_2, r_Switch_3, r_Switch_4;

//Create a 2-bit by 11-bit memory register to store Sequence value
reg [1:0] r_Sequence [10:0];

//Create a dynamic register to track memory Index that checks DIFFICULTY value
reg [1:0] r_ButtonId;
reg [$clog2(DIFFICULTY)-1:0];
wire [21:0] w_Lfsr_Data; // Assuming LFSR generates 22-bit data ******ASK********
wire w_CounterEnable;
wire w_Toggle;

// State machine logic
always @(posedge i_Clk)
begin
    if (i_Switch_1 & i_Switch_2)
        r_Current_State <= START; //when Switch 1 & 2 are pressed
    else
    begin
        case (r_Current_State)
			//first state//
            START:
            begin
                if (!i_Switch_1 & !i_Switch_2 & r_ButtonPressed)
                begin
                    r_LcdBinary <= 0;
                    r_Index <= 0;
                    r_Current_State <= SEQUENCE_ON;
                end
            end

            //second state//
			SEQUENCE_ON:
            begin
                if (!w_Toggle & r_Toggle)
                    r_Current_State <= SEQUENCE_OFF;
            end

            //third state//
			SEQUENCE_OFF:
            begin
                if (!w_Toggle & r_Toggle)
                begin
                    if (r_LcdBinary == r_Index)
                    begin
                        r_Index <= 0;
                        r_Current_State <= PLAYER_INPUT;
                    end
                    else
                    begin
                        r_Index <= r_Index + 1;
                        r_Current_State <= SEQUENCE_OFF;
                    end
                end
            end

            //fourth state//
			PLAYER_INPUT:
            begin
                if (r_ButtonPressed)
                begin
                    if (r_Sequence[r_Index] == r_ButtonId && r_Index == r_LcdBinary)
                    begin
                        r_Index <= 0;
                        r_Current_State <= INCREASE_DIFF;
                    end
                    else if (r_Sequence[r_Index] != r_ButtonId)
                        r_Current_State <= END;
                    else
                        r_Index <= r_Index + 1;
                end
            end

			//fifth state//
            INCREASE_DIFF:
            begin
                r_LcdBinary <= r_LcdBinary + 1;
                if (r_LcdBinary == DIFFICULTY - 1)
                    r_Current_State <= SUCCESS;
                else
                    r_Current_State <= SEQUENCE_OFF;
            end
			//sixth state//
            SUCCESS:
            begin
                r_LcdBinary <= 4'hB;
            end
			
			//seventh state//
            END:
            begin
                r_LcdBinary <= 4'hE;
            end

            default:
                r_Current_State <= START;
        endcase
    end
end

// Sequence initialization
always @(posedge i_Clk)
begin
    if (r_Current_State == START)
    begin
        r_Sequence[0] <= w_Lfsr_Data[1:0];
        r_Sequence[1] <= w_Lfsr_Data[3:2];
        r_Sequence[2] <= w_Lfsr_Data[5:4];
        r_Sequence[3] <= w_Lfsr_Data[7:6];
        r_Sequence[4] <= w_Lfsr_Data[9:8];
        r_Sequence[5] <= w_Lfsr_Data[11:10];
        r_Sequence[6] <= w_Lfsr_Data[13:12];
        r_Sequence[7] <= w_Lfsr_Data[15:14];
        r_Sequence[8] <= w_Lfsr_Data[17:16];
        r_Sequence[9] <= w_Lfsr_Data[19:18];
        r_Sequence[10] <= w_Lfsr_Data[21:20];
    end
end

// LED assignments
assign o_LED_1 = (r_Current_State == SEQUENCE_ON && r_Sequence[r_Index] == 2'b00) ? 1'b1 : i_Switch_1;
assign o_LED_2 = (r_Current_State == SEQUENCE_ON && r_Sequence[r_Index] == 2'b01) ? 1'b1 : i_Switch_2;
assign o_LED_3 = (r_Current_State == SEQUENCE_ON && r_Sequence[r_Index] == 2'b10) ? 1'b1 : i_Switch_3;
assign o_LED_4 = (r_Current_State == SEQUENCE_ON && r_Sequence[r_Index] == 2'b11) ? 1'b1 : i_Switch_4;

// Switch and button logic
always @(posedge i_Clk)
begin
    r_Toggle <= w_Toggle;
    r_Switch_1 <= i_Switch_1;
    r_Switch_2 <= i_Switch_2;
    r_Switch_3 <= i_Switch_3;
    r_Switch_4 <= i_Switch_4;

    if (r_Switch_1 & !i_Switch_1)
    begin
        r_ButtonPressed <= 1'b1;
        r_ButtonId <= 0;
    end
    else if (r_Switch_2 & !i_Switch_2)
    begin
        r_ButtonPressed <= 1'b1;
        r_ButtonId <= 1;
    end
    else if (r_Switch_3 & !i_Switch_3)
    begin
        r_ButtonPressed <= 1'b1;
        r_ButtonId <= 2;
    end
    else if (r_Switch_4 & !i_Switch_4)
    begin
        r_ButtonPressed <= 1'b1;
        r_ButtonId <= 3;
    end
    else
    begin
        r_ButtonPressed <= 1'b0;
        r_ButtonId <= 0;
    end
end

assign w_CounterEnable = (r_Current_State == SEQUENCE_ON || r_Current_State == SEQUENCE_OFF);

// Instantiate the Counter module
Counter #(.COUNT_MAX(CNTS_PER_SEC/4)) Counter_Inst (
    .i_Clk(i_Clk),
    .i_CounterEnable(w_CounterEnable),
    .o_Toggle(w_Toggle)
);

// Instantiate the Lfsr module
Lfsr Lfsr_Inst (
    .i_Clk(i_Clk),
    .o_Lfsr_Data(w_Lfsr_Data),
	.o_Lfsr_Done()
);

endmodule
