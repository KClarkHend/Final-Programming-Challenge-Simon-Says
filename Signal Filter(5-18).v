//PROGRAMMING CHALLENGE: 

parameter PARAMETER_NAME// a 'global' parameter that can be overwritten by external parameter redefinition
module Signal_Filter #(parameter Signal_MAX=20)
(input i_Clk,
input i_Unfiltered,
output o_Filtered);


reg[$clog2(SIGNAL_MAX)] //takes the log base 2 value of the variable & round it up. Used to create 'dynamic' register that can self adjust bit allocation

#(parameter NUMBER=30)
reg [$clog2(SIGNAL_MAX)-1:0] r_Counter=0; //This is a dynamic parameter. Start at -1 to start at 0. 
reg r_State = 1'b0,

//create delay
always @(posedge i_Clk ) 
begin 
        if (i_Unfiltered !== r_State && r_Counter < SIGNAL_MAX-1)  // Reset the counter and state
		begin
            r_Counter <= r_Counter +1;
			end 
		else if (r_Counter == SIGNAL_MAX-1)
		begin
			r_State <= i_Unfiltered;
			r_Counter <= 0;
			end 
		else //if hardware is confused and doesn't know where it's at, Counter will set to 0
		begin
			r_Counter <= 0;
		end
	end
	assign o_Filtered <= r_State;
	endmodule