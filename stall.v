module stall(
	input wire if_stall,
	input wire id_stall,
	input wire mem_stall,
	output reg[`StallBus] stall_state
);

always @(*) begin
    if(mem_stall==`True)
        stall_state=`MemStall;
    else if (id_stall==`True)
        stall_state=`IdStall;
    else if (if_stall==`True)
        stall_state=`IfStall;
    else
        stall_state=`NoStall;
end
endmodule