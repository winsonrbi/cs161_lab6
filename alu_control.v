`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:39:37 01/31/2020 
// Design Name: 
// Module Name:    alu_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
 module alu_control  (
    input wire [1:0] alu_op , 
    input wire [5:0] instruction_5_0 , 
    output reg [3:0] alu_out  
    );
always @(*) begin
	case(alu_op)
		2'b00: begin
			//lw or sw - add
			alu_out = 4'b0010;
		end
		2'b01: begin
			//beq - sub
			alu_out = 4'b0110;
		end
		2'b10: begin
			//R-Type
			case(instruction_5_0)
				6'b100000: begin
					//add
					alu_out = 4'b0010;
				end
				6'b100010: begin
					//sub
					alu_out = 4'b0110;
				end
				6'b100100: begin
					//AND
					alu_out = 4'b0000;
				end
				6'b100101: begin
					//OR
					alu_out = 4'b0001;
				end
				6'b100111: begin
					//NOR
					alu_out = 4'b1100;
				end
				6'b101010: begin
					//slt
					alu_out = 4'b0111;
				end
				default: begin
					$display("**********************Undefined Case in ALU CONTROL*******************");
					$display("instruction code is: %b", instruction_5_0);
				end
			endcase
		end
	endcase
end
endmodule
