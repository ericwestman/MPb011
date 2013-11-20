module CPU(clk);

	// Inputs
	input clk;

	// Registers
	reg [31:0] PC, Regfile[0:31], Memory[0:1023], MDR, A, B, ALUResult, IR;
	reg [2:0]  state;

	// Wires
	wire [5:0] opcode, func;
	wire [4:0] rs, rt, rd, sa;
	wire [31:0] immediate;
	wire [25:0] target;

	// R-type instructions (ADD, SUB, SLT, JR)
	// opcode(6), rs(5), rt(5), rd(5), sa(5), func(6)
	// NOTE: sa is the shift amount

	// I-type instructions (LW, SW, XORI, BNE)
	// opcode(6), rs(5), rt(5), immediate(16)

	// J-type instructions (J, JAL)
	// opcode(6), target(26)


	// Assign wires
	assign opcode = IR[31:26];
	assign rs = IR[25:21];
	assign rt = IR[20:16];
	assign rd = IR[15:11];
	assign sa = IR[10:6];
	assign func = IR[5:0];
	assign immediate = {{16{IR[15]}}, IR[15:0]};
	assign target = IR[25:0];

	// opcodes
	parameter OP_LI   = 6'b001001;
	parameter OP_LW   = 6'b100011;
	parameter OP_SW   = 6'b101011;
	parameter OP_J    = 6'b000010;
	parameter OP_JAL  = 6'b000011;
	parameter OP_BNE  = 6'b000101;
	parameter OP_XORI = 6'b001110;
	parameter OP_R_TYPE  = 6'b000000;

	// func codes
	parameter FUNC_JR   = 6'b001000;
	parameter FUNC_ADD  = 6'b100000;
	parameter FUNC_SUB  = 6'b100010;
	parameter FUNC_SLT  = 6'b101010;

	// state definitions
	parameter IF 	= 0;
	parameter ID	= 1;
	parameter EX 	= 2;
	parameter MEM 	= 3;
	parameter WB 	= 4;


	integer i;
	initial begin 
		PC = 0;
		state = 0;
		for ( i=0; i<32; i = i+1 ) begin
      		Regfile[i] = 0000_0000_0000_0000_0000_0000_0000_0000;
   		end
   		Memory[1021] = 'h00000001;
   		Memory[1022] = 'h00000010;
		$readmemb("..\\..\\MARS\\allinstructions.dat", Memory);
	end

	always @(posedge clk) begin

	case (state)
		IF: begin
			IR <= Memory[PC];
			PC <= PC + 1;
			state = ID;
		end
		
		ID: begin
			A <= Regfile[rs];
			B <= Regfile[rt];
			if(opcode == OP_BNE) begin
				ALUResult <= PC + immediate;
				state = EX;
			end
			else if (opcode == OP_J) begin
				// PC <= {PC[31:28],IR[25:0],2'b00};
				PC <= {PC[31:28],IR[25],IR[25],IR[25:0]};
				state = IF;
			end
			else if (opcode == OP_JAL) begin
				// Store PC in $ra
				Regfile[31]<= PC;
				state = EX;
			end
			else if (opcode == OP_R_TYPE || opcode == OP_XORI || opcode == OP_LW || opcode == OP_SW) begin
				state = EX;
			end
			else if (opcode == OP_LI) begin
				Regfile[rt] <= immediate;
				state = IF;
			end
			else begin
				state = IF;
			end
		end

		EX: begin
			if(opcode == OP_LW || opcode == OP_SW) begin
				ALUResult = A + immediate;
				state = MEM;
			end
			else if (opcode == OP_JAL) begin
				// PC <= {PC[31:28],IR[25:0],2'b00};
				PC <= {PC[31:28],IR[25],IR[25],IR[25:0]};
				state = IF;
			end
			else if (opcode == OP_BNE) begin
				if (A != B) PC <= ALUResult;
				state = IF;
			end
			else if (opcode == OP_XORI) begin
				ALUResult <= A^immediate;
				state = WB;
			end
			else if (opcode == OP_R_TYPE) begin
				if (func == FUNC_JR) begin
					PC <= A;
					state = IF;
				end
				else if (func == FUNC_ADD) begin
					ALUResult <= A + B;
					state = WB;
				end
				else if (func == FUNC_SUB) begin
					ALUResult <= A - B;
					state = WB;
				end
				else if (func == FUNC_SLT) begin
					ALUResult <= (A < B) ? 1 : 0;
					state = WB;
				end
			end
			else begin
				state = IF;
			end
		end

		MEM: begin
			if(opcode == OP_LW) begin
				MDR <= Memory[ALUResult];
				state = WB;
			end
			else if(opcode == OP_SW) begin
				Memory[ALUResult] = B;
				state = IF;
			end
			else begin
				state = IF;
			end
		end

		WB: begin
			if (opcode == OP_LW) Regfile[rt] <= MDR;
			else if(opcode == OP_XORI) Regfile[rt] <= ALUResult;
			else if(opcode == OP_R_TYPE) Regfile[rd] <= ALUResult;
			state = IF;
		end
		
	endcase
	end

	initial
	$monitor($time, , opcode, , state, , PC, , ALUResult);

endmodule


module CPU_TESTBENCH();
  // Inputs
  reg clk;

  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end

  CPU MY_CPU( clk );
  

endmodule
