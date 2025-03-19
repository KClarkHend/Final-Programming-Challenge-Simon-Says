//PROGRAMMING CHALLENGE: Create a simple counter

module Counter #(parameter COUNT_MAX = 10) 
(input i_Clk,
input i_CounterEnable,
output o_Toggle);

reg [$clog2(COUNT_MAX-1):0] r_Counter;
reg r_Toggle

always @(posedge i_Clk) 
begin 
    if (i_CounterEnable == 1'b1)  // Reset the counter and state
	begin
        if (r_Counter == COUNT_MAX-1)
		begin 
			r_Toggle <= !r_Toggle;
			r_Counter <= 0;
		end 
		else //if hardware is confused and doesn't know where it's at, Counter will set to 0
			r_Counter <= r_Counter+1;

	end
	else
			r_Toggle <= 1'b0;
end
	
assign o_Toggle = r_Toggle;
	
endmodule