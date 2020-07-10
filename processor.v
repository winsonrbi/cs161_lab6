	`timescale 1ns / 1ps


module cs161_processor(
    clk ,
    rst ,   
	 // Debug signals 
    prog_count     , 
    instr_opcode   ,
    reg1_addr      ,
    reg1_data      ,
    reg2_addr      ,
    reg2_data      ,
    write_reg_addr ,
    write_reg_data 
 );

input wire clk ;
input wire rst ;
    
// Debug Signals

input wire[31:0] prog_count     ; 
input wire[5:0]  instr_opcode   ;
input wire[4:0]  reg1_addr      ;
input wire[31:0] reg1_data      ;
input wire[4:0]  reg2_addr      ;
input wire[31:0] reg2_data      ;
input wire[4:0]  write_reg_addr ;
input wire[31:0] write_reg_data ;

wire[5:0] alu_funct;
wire reg_dst;
wire branch;
wire mem_read;
wire mem_to_reg;
wire [1:0] alu_op;
wire mem_write;
wire alu_src;
wire reg_write;
wire [3:0] alu_control_out;

// Insert your solution below here.

//Include Control Unit
control_unit control_unit_inst(
  //inputs
  .instr_op (instr_opcode),
  //outputs
  .reg_dst(reg_dst),
  .branch (branch),
  .mem_read (mem_read),
  .mem_to_reg (mem_to_reg),
  .alu_op (alu_op),
  .mem_write (mem_write),
  .alu_src (alu_src),
  .reg_write (reg_write)
);
//Include Datapath
cs161_datapath datapth_inst(
  //inputs
  .clk (clk),
  .rst (rst),
  //input from control unit
  .reg_dst (reg_dst),
  .branch (branch),
  .mem_read (mem_read),
  .mem_to_reg (mem_to_reg),
  .alu_op (alu_control_out),
  .mem_write (mem_write),
  .alu_src (alu_src),
  .reg_write (reg_write),
  //outputs to alu
  .instr_op (instr_opcode),
  .funct (alu_funct),
  //Debug signals
  .prog_count (prog_count),
  .instr_opcode (instr_opcode),
  .reg1_addr (reg1_addr),
  .reg1_data (reg1_data),
  .reg2_addr (reg2_addr),
  .reg2_data (reg2_data),
  .write_reg_addr (write_reg_addr),
  .write_reg_data (write_reg_data)
);
//Include ALU Control Unit
alu_control alu_control_inst(
  //inputs
  .alu_op (alu_op),
  .instruction_5_0 (alu_funct),
  //outputs
  .alu_out (alu_control_out)
);
endmodule
