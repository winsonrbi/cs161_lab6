`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

`define WORD_SIZE 32
//TODO: add PC register and then combine to rest of circuit 
module cs161_datapath(
    clk ,     
    rst ,     
    instr_op ,
    funct   , 
    reg_dst , 
    branch  , 
    mem_read , 
    mem_to_reg ,
    alu_op    , 
    mem_write  ,
    alu_src  ,  
    reg_write ,  
	 
    // Debug Signals
    prog_count ,  
    instr_opcode ,  
    reg1_addr   ,  
    reg1_data  ,   
    reg2_addr  ,   
    reg2_data  ,   
    write_reg_addr ,
    write_reg_data
    );

 input wire  clk ; 
 input wire  rst ;
 
 output wire[5:0] instr_op ;
 output wire[5:0] funct  ;  
 
 input wire   reg_dst  ;
 input wire   branch   ;
 input wire   mem_read ;
 input wire   mem_to_reg ;
 input wire[3:0] alu_op  ;  
 input wire   mem_write ;
 input wire   alu_src   ; 
 input wire   reg_write  ;
 
// ----------------------------------------------
// Debug Signals
// ----------------------------------------------
  
 output wire[`WORD_SIZE-1:0]  prog_count;
 output wire[5:0] instr_opcode;  
 output wire[4:0] reg1_addr;   
 output wire[`WORD_SIZE-1:0] reg1_data;
 output wire[4:0] reg2_addr;   
 output wire[`WORD_SIZE-1:0] reg2_data;
 output wire[4:0] write_reg_addr;
 output wire[`WORD_SIZE-1:0] write_reg_data; 

// Insert your solution below here.
wire [`WORD_SIZE-1:0] full_instruction_line; //used to load 32 bit instruction from memory
wire [`WORD_SIZE-1:0] read_data1_line;
wire [`WORD_SIZE-1:0] read_data2_line;
wire [4:0] write_reg_line;
wire [`WORD_SIZE-1:0] read_data_line;
wire [`WORD_SIZE-1:0] alu_result_line;
wire [`WORD_SIZE-1:0] write_data_line;
wire [`WORD_SIZE-1:0] alu_src_mux_line;
wire [`WORD_SIZE-1:0] sign_ext_out_line;
wire zero_out_line;
wire [`WORD_SIZE-1:0] pc_in_line;
wire [`WORD_SIZE-1:0] cpu_reg_in_line;
wire [31:0] IF_ID_PC_ID_EX_line;
wire [31:0] ID_EX_pc_register_out;
wire [31:0] alu_channel_a_in;
wire [31:0] read_data2_pipeline_out;
wire [31:0] ID_EX_sign_ext_reg_out;
wire ID_EX_alu_src_out;
wire ID_EX_reg_dst_out;
wire [4:0] ID_EX_reg_dst_0_out;
wire [4:0] ID_EX_reg_dst_1_out;

wire ID_EX_reg_write_out;
wire ID_EX_mem_write_out;
wire ID_EX_mem_read_out;
wire ID_EX_mem_reg_out;
wire ID_EX_branch_out;
wire [3:0]ID_EX_alu_op_out;

wire [31:0] EX_MEM_read_data_2_register_out;
wire [31:0] EX_MEM_alu_out;
wire [31:0] EX_MEM_pc_register_out;
wire [4:0] EX_MEM_reg_dst_result_out;
wire EX_MEM_reg_write_out;
wire EX_MEM_mem_write_out;
wire EX_MEM_mem_read_out;
wire EX_MEM_mem_reg_out;
wire EX_MEM_branch_out;
wire EX_MEM_alu_zero_out;

wire MEM_WB_reg_write_out;
wire MEM_WB_mem_reg_out;
wire [4:0] MEM_WB_reg_dst_result_out;
wire [31:0] MEM_WB_alu_result_reg_out;
wire [31:0] MEM_WB_read_data_out;
//Registers
wire pc_mux_line;
wire [`WORD_SIZE-1:0] pc_alu_result_line;
wire [`WORD_SIZE-1:0] current_prog_count;
wire [`WORD_SIZE-1:0] current_pc_plus_four;

assign current_pc_plus_four = current_prog_count + 4;
assign pc_alu_result_line = ID_EX_pc_register_out + 4 + (ID_EX_sign_ext_reg_out * 4);
assign pc_mux_line = EX_MEM_branch_out & EX_MEM_alu_zero_out;
//================================
//Register for the program counter
//================================

gen_register #(32) IF_ID_instruction_reg(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(full_instruction_line), //Full instruction from memory
    .data_out(cpu_reg_in_line) //Goes out to CPU registers
);
gen_register #(32) IF_ID_pc_add_4_register(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(current_pc_plus_four), //comes from assign above
    .data_out(IF_ID_PC_ID_EX_line) // Goes into next pipeline reg
);
gen_register #(32) ID_EX_pc_register(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(IF_ID_PC_ID_EX_line), 
    .data_out(ID_EX_pc_register_out) // Goes into next pipeline reg
);
gen_register #(32) ID_EX_read_data_1_register(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(read_data1_line), 
    .data_out(alu_channel_a_in) 
);
gen_register #(32) ID_EX_read_data_2_register(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(read_data2_line),
    .data_out(read_data2_pipeline_out)
);
gen_register #(32) ID_EX_sign_ext_register(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(sign_ext_out_line),
    .data_out(ID_EX_sign_ext_reg_out)
);
gen_register #(1) ID_EX_alu_src(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(alu_src),
    .data_out(ID_EX_alu_src_out)
);
gen_register #(1) ID_EX_reg_write(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(reg_write),
    .data_out(ID_EX_reg_write_out)
);
gen_register #(1) ID_EX_reg_dst(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(reg_dst),
    .data_out(ID_EX_reg_dst_out)
);
gen_register #(1) ID_EX_mem_write(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(mem_write),
    .data_out(ID_EX_mem_write_out)
);
gen_register #(1) ID_EX_mem_read(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(mem_read),
    .data_out(ID_EX_mem_read_out)
);
gen_register #(1) ID_EX_mem_reg(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(mem_to_reg),
    .data_out(ID_EX_mem_reg_out)
);
gen_register #(1) ID_EX_branch(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(branch),
    .data_out(ID_EX_branch_out)
);
gen_register #(4) ID_EX_alu_op(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(alu_op),
    .data_out(ID_EX_alu_op_out)
);
gen_register #(5) ID_EX_reg_dst_0(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(cpu_reg_in_line[20:16]),
    .data_out(ID_EX_reg_dst_0_out)
);
gen_register #(5) ID_EX_reg_dst_1(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(cpu_reg_in_line[15:11]),
    .data_out(ID_EX_reg_dst_1_out)
);
gen_register #(32) EX_MEM_pc_register(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(pc_alu_result_line), 
    .data_out(EX_MEM_pc_register_out) // Goes into next pipeline reg
);
gen_register #(5) EX_MEM_reg_dst_result(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(write_reg_line),
    .data_out(EX_MEM_reg_dst_result_out)
);
gen_register #(32) EX_MEM_read_data_2_register(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(read_data2_pipeline_out),
    .data_out(EX_MEM_read_data_2_register_out)
);
gen_register #(1) EX_MEM_reg_write(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(ID_EX_reg_write_out),
    .data_out(EX_MEM_reg_write_out) //Goes to next stage of pipeline
);
gen_register #(1) EX_MEM_mem_write(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(ID_EX_mem_write_out),
    .data_out(EX_MEM_mem_write_out) //Goes to memory
);
gen_register #(1) EX_MEM_mem_read(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(ID_EX_mem_read_out),
    .data_out(EX_MEM_mem_read_out)//Goes to memory
);
gen_register #(1) EX_MEM_mem_reg(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(ID_EX_mem_reg_out),
    .data_out(EX_MEM_mem_reg_out) //Goes to next stage
);
gen_register #(1) EX_MEM_branch(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(ID_EX_branch_out),
    .data_out(EX_MEM_branch_out) // ANDED to check for branch condition
);
gen_register #(32) EX_MEM_alu_result_reg(
	 .clk (clk),
	 .rst (rst),
	 .write_en(clk),
	 .data_in(alu_result_line),
	 .data_out(EX_MEM_alu_out)
);
gen_register #(1) EX_MEM_alu_zero(
//Holds alu zero result for pipeline
	 .clk (clk),
	 .rst (rst),
	 .write_en (clk),
	 .data_in(zero_out_line),
	 .data_out(EX_MEM_alu_zero_out)
);
gen_register #(5) MEM_WB_reg_dst_result(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(EX_MEM_reg_dst_result_out),
    .data_out(MEM_WB_reg_dst_result_out)
);
gen_register #(1) MEM_WB_reg_write(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(EX_MEM_reg_write_out),
    .data_out(MEM_WB_reg_write_out) //Goes to CPU Registers
);
gen_register #(1) MEM_WB_mem_reg(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(EX_MEM_mem_reg_out),
    .data_out(MEM_WB_mem_reg_out) //Goes to memory mux
);
gen_register #(32) MEM_WB_alu_result_reg(
	 .clk (clk),
	 .rst (rst),
	 .write_en(clk),
	 .data_in(EX_MEM_alu_out),
	 .data_out(MEM_WB_alu_result_reg_out)
);

gen_register #(32) MEM_WB_read_data(
//Reads From CPU MEMORY and stores it for the mux for next cycle
	 .clk (clk),
	 .rst (rst),
	 .write_en(clk),
	 .data_in(read_data_line),
	 .data_out(MEM_WB_read_data_out)
);
//================================
//Register for the program counter
//================================
gen_register #(32) GenR1(
    .clk (clk),
    .rst (rst),
    .write_en(clk),
    .data_in(pc_in_line),
    .data_out(current_prog_count)
);
cpumemory cpu_memory_inst(
    .clk (clk),
    .rst (rst),
	 //Divide program counter by 4 to get line number
    .instr_read_address (current_prog_count[9:2]),
    .instr_instruction (full_instruction_line),
    .data_mem_write (EX_MEM_mem_write_out),
    .data_address (EX_MEM_alu_out[9:2]),
    .data_write_data (EX_MEM_read_data_2_register_out),
    .data_read_data (read_data_line) //Goes to MEM/WB pipeline
);
cpu_registers cpu_registers_inst(
    .clk (clk),
    .rst (rst),
    .reg_write (MEM_WB_reg_write_out), //Must change
    .read_register_1 (cpu_reg_in_line[25:21]),
    .read_register_2 (cpu_reg_in_line[20:16]),
    .write_register (MEM_WB_reg_dst_result_out),
    .write_data (write_data_line),
    .read_data_1 (read_data1_line),
    .read_data_2 (read_data2_line)
);
//ALU incorrectly calculating
alu alu_inst(
    //Inputs
    .alu_control_in (ID_EX_alu_op_out),
    .channel_a_in (alu_channel_a_in),
    .channel_b_in (alu_src_mux_line),
    //Outputs
    .zero_out (zero_out_line),
    .alu_result_out (alu_result_line)
);


mux_2_1 #(5) write_reg_mux(
    .select_in (ID_EX_reg_dst_out),
    .datain1 (ID_EX_reg_dst_0_out), //Comes IE/EX pipeline registers
    .datain2 (ID_EX_reg_dst_1_out),//Comes ID/EX pipeline registers
    .data_out (write_reg_line)  
);

mux_2_1 #(32) mem_to_reg_mux(
    //Controls if we send data from memory or alu back 
    .select_in (MEM_WB_mem_reg_out),
	 .datain1 (MEM_WB_read_data_out),
    .datain2 (MEM_WB_alu_result_reg_out),
    .data_out (write_data_line)
);
//Want to fix this, thinks data in is zero for channel b
mux_2_1 alu_src_mux(
    .select_in (ID_EX_alu_src_out),
    .datain1 (read_data2_pipeline_out),
    .datain2 (ID_EX_sign_ext_reg_out),
    .data_out (alu_src_mux_line)
);

mux_2_1 #(32) pc_mux(
    .select_in (pc_mux_line),
    .datain1 (current_pc_plus_four),
    .datain2 (EX_MEM_pc_register_out),
    .data_out(pc_in_line)
);
sign_ext sign_ext_inst(
    .a (cpu_reg_in_line[15:0]),
    .result (sign_ext_out_line) 
);
//Assign debug variables
assign instr_op = cpu_reg_in_line[31:26];
assign funct = ID_EX_sign_ext_reg_out[5:0];
assign reg1_addr = cpu_reg_in_line[25:21];
assign reg1_data = read_data1_line;
assign reg2_addr = cpu_reg_in_line[20:16];
assign reg2_data = read_data2_line;
assign write_reg_addr = MEM_WB_reg_write_out;
assign write_reg_data = write_data_line;
assign prog_count = current_prog_count;

endmodule
