// Single-cycle RISC-V CPU from chapter 26, prepared for the iCE40 FPGA (chapter 27).
// Instructions: add, sub, and, or, addi, lw, sw, beq, bne.
// Changes compared to chapter 26:
//  - ce (clock enable): the CPU executes one instruction per clock cycle in which ce = 1.
//    All storing elements (PC, register file, data memory) only change when ce = 1.
//  - the register file lives in block RAM (see regfile.v), the data memory has 8 words.
//  - debug outputs: the PC and a copy of register x1, because the contents of a block RAM
//    cannot be watched from outside.
module cpu #(
    parameter PROGRAM = "program.hex"
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        ce,          // clock enable: execute one instruction
    output wire [31:0] dbg_pc,      // current PC
    output reg  [31:0] dbg_x1       // copy of register x1
);
    // ---- instruction fetch -------------------------------------------------
    reg  [31:0] pc;
    wire [31:0] inst;
    wire [31:0] pc_plus4 = pc + 4;               // first adder

    instr_mem #(.PROGRAM(PROGRAM)) imem (.addr(pc), .inst(inst));

    // ---- decode: the fields of the instruction ----------------------------
    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd     = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1    = inst[19:15];
    wire [4:0] rs2    = inst[24:20];

    // ---- control ------------------------------------------------------------
    wire       reg_write, alu_src, mem_to_reg, mem_read, mem_write, branch;
    wire [1:0] alu_op;
    wire [3:0] alu_ctrl;

    control ctl (
        .opcode(opcode), .reg_write(reg_write), .alu_src(alu_src),
        .mem_to_reg(mem_to_reg), .mem_read(mem_read), .mem_write(mem_write),
        .branch(branch), .alu_op(alu_op)
    );
    alu_control actl (.alu_op(alu_op), .funct7_5(inst[30]), .funct3(funct3), .alu_ctrl(alu_ctrl));

    // ---- register file and immediate ---------------------------------------
    wire [31:0] rd1, rd2, imm, write_data;

    regfile rf (
        .clk(clk), .rs1(rs1), .rs2(rs2), .rd1(rd1), .rd2(rd2),
        .we(reg_write & ce), .rd(rd), .wd(write_data)
    );
    imm_gen ig (.inst(inst), .imm(imm));

    // ---- execute -------------------------------------------------------------
    wire [31:0] alu_b = alu_src ? imm : rd2;     // multiplexer in front of the ALU
    wire [31:0] alu_result;
    wire        zero, overflow;

    alu #(.N(32)) alu (
        .a(rd1), .b(alu_b), .ctrl(alu_ctrl),
        .result(alu_result), .zero(zero), .overflow(overflow)
    );

    // ---- memory access ---------------------------------------------------------
    wire [31:0] mem_data;

    data_mem dmem (
        .clk(clk), .addr(alu_result), .mem_read(mem_read), .mem_write(mem_write & ce),
        .wd(rd2), .rd(mem_data)
    );

    // ---- write back ------------------------------------------------------------
    assign write_data = mem_to_reg ? mem_data : alu_result;   // multiplexer behind the memory

    // ---- next PC ---------------------------------------------------------------
    wire [31:0] branch_target = pc + imm;                     // second adder
    wire        pc_src = branch & (zero ^ inst[12]);          // inst[12] = 1 for bne
    wire [31:0] pc_next = pc_src ? branch_target : pc_plus4;  // multiplexer in front of the PC

    always @(posedge clk)
        if (rst)     pc <= 0;
        else if (ce) pc <= pc_next;

    // ---- debug ---------------------------------------------------------------
    assign dbg_pc = pc;

    always @(posedge clk)                                     // follows every write to x1
        if (rst)                              dbg_x1 <= 0;
        else if (ce && reg_write && rd == 1)  dbg_x1 <= write_data;
endmodule
