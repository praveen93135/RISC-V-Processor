`timescale 1ns/1ps
`include "alu.v"

module alu_64_bit_tb;
    reg [63:0] a, b;
    reg [3:0] opcode;
    wire [63:0] result;
    wire cout, carry_flag, overflow_flag, zero_flag;
    integer pass_count = 0, total_tests = 55;
    
    localparam  ADD_Oper  = 4'b0000,
                SLL_Oper  = 4'b0001,
                SLT_Oper  = 4'b0010,
                SLTU_Oper = 4'b0011,
                XOR_Oper  = 4'b0100,
                SRL_Oper  = 4'b0101,
                OR_Oper   = 4'b0110,
                AND_Oper  = 4'b0111,
                SUB_Oper  = 4'b1000,
                SRA_Oper  = 4'b1101;

    alu_64_bit uut(
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .cout(cout),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .zero_flag(zero_flag)
    );

    task run_test;
        input [7:0] test_number;
        input [63:0] test_a, test_b, expected_result;
        input [3:0] test_opcode;
        input exp_carry, exp_overflow, exp_zero;
        begin
            a = test_a;
            b = test_b;
            opcode = test_opcode;
            #10;
            $display("Test %0d:", test_number);
            $display("  A: %016h  B: %016h  Opcode: %b", a, b, test_opcode);
            $display("  Result: %016h  Flags: C=%b, O=%b, Z=%b", result, carry_flag, overflow_flag, zero_flag);
            
            if (result === expected_result && 
                carry_flag === exp_carry && 
                overflow_flag === exp_overflow && 
                zero_flag === exp_zero) begin
                pass_count = pass_count + 1;
                $fdisplay(file_handle, "Test %0d, Status: PASS", test_number);
            end else begin
                $fdisplay(file_handle, "Test %0d, Status: FAIL", test_number);
                $display("  FAIL! Expected: result=%016h, carry=%b, overflow=%b, zero=%b", 
                        expected_result, exp_carry, exp_overflow, exp_zero);
                $display("         Got:     result=%016h, carry=%b, overflow=%b, zero=%b", 
                        result, carry_flag, overflow_flag, zero_flag);
            end
        end
    endtask

    task run_test_rz;
        input [7:0] test_number;
        input [63:0] test_a, test_b, expected_result;
        input [3:0] test_opcode;
        input exp_zero;
        begin
            a = test_a;
            b = test_b;
            opcode = test_opcode;
            #10;
            $display("Test %0d:", test_number);
            $display("  A: %016h  B: %016h  Opcode: %b", a, b, test_opcode);
            $display("  Result: %016h  Zero=%b", result, zero_flag);
            
            if (result === expected_result && zero_flag === exp_zero) begin
                pass_count = pass_count + 1;
                $fdisplay(file_handle, "Test %0d, Status: PASS", test_number);
            end else begin
                $fdisplay(file_handle, "Test %0d, Status: FAIL", test_number);
                $display("  FAIL! Expected: result=%016h, zero=%b", expected_result, exp_zero);
                $display("         Got:     result=%016h, zero=%b", result, zero_flag);
            end
        end
    endtask

    integer file_handle;

    initial begin
        file_handle = $fopen("alu_results.txt", "w");
        if (file_handle == 0) begin
            $display("Error: Could not open file for writing.");
            $finish;
        end
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_64_bit_tb);
        pass_count = 0;

        run_test(1, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, ADD_Oper, 0, 0, 1);

        run_test(2, 64'h7FFFFFFFFFFFFFFF, 64'h0000000000000001, 64'h8000000000000000, ADD_Oper, 0, 1, 0);

        run_test(3, 64'h8000000000000000, 64'h8000000000000000, 64'h0000000000000000, ADD_Oper, 1, 1, 1);

        run_test(4, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000001, 64'h0000000000000000, ADD_Oper, 1, 0, 1);

        run_test(5, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFE, ADD_Oper, 1, 0, 0);

        run_test(6, 64'h7FFFFFFFFFFFFFFF, 64'h7FFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFE, ADD_Oper, 0, 1, 0);

        run_test(7, 64'h8000000000000000, 64'hFFFFFFFFFFFFFFFF, 64'h7FFFFFFFFFFFFFFF, ADD_Oper, 1, 1, 0);

        run_test(8, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, ADD_Oper, 1, 0, 1);

        run_test(9, 64'h00000000FFFFFFFF, 64'h0000000000000001, 64'h0000000100000000, ADD_Oper, 0, 0, 0);

        run_test(10, 64'h06EAE7CD9408D55F, 64'h0000000AA221D37B, 64'h06EAE7D8362AA8DA, ADD_Oper, 0, 0, 0);

        run_test(11, 64'h0023185DDFBF101B, 64'hFFFD288475FDE3B9, 64'h002040E255BCF3D4, ADD_Oper, 1, 0, 0);

        run_test(12, 64'h0000000100000000, 64'hFFFFFFFF00000000, 64'h0000000000000000, ADD_Oper, 1, 0, 1);

        run_test(13, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, SUB_Oper, 0, 0, 1);

        run_test(14, 64'h0000000000000001, 64'h0000000000000001, 64'h0000000000000000, SUB_Oper, 0, 0, 1);

        run_test(15, 64'h0000000000000000, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, SUB_Oper, 1, 0, 0);

        run_test(16, 64'h8000000000000000, 64'h0000000000000001, 64'h7FFFFFFFFFFFFFFF, SUB_Oper, 0, 1, 0);

        run_test(17, 64'h7FFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h8000000000000000, SUB_Oper, 1, 1, 0);

        run_test(18, 64'h0000000000000000, 64'h8000000000000000, 64'h8000000000000000, SUB_Oper, 1, 1, 0);

        run_test(19, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, SUB_Oper, 0, 0, 1);

        run_test(20, 64'h06EAE7CD9408D55F, 64'h0000000AA221D37B, 64'h06EAE7C2F1E701E4, SUB_Oper, 0, 0, 0);

        run_test(21, 64'h0023185DDFBF101B, 64'hFFFD288475FDE3B9, 64'h0025EFD969C12C62, SUB_Oper, 1, 0, 0);

        run_test(22, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFE, SUB_Oper, 0, 0, 0);

        run_test(23, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000002, SUB_Oper, 1, 0, 0);

        run_test_rz(24, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 64'h0000000000000000, AND_Oper, 1);

        run_test_rz(25, 64'h00002C84C4D54177, 64'h011C2D636E06D380, 64'h00002C0044044100, AND_Oper, 0);

        run_test_rz(26, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 64'h0000000000000000, AND_Oper, 1);

        run_test_rz(27, 64'h123456789ABCDEF0, 64'hFFFFFFFF00000000, 64'h1234567800000000, AND_Oper, 0);

        run_test_rz(28, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, OR_Oper, 1);

        run_test_rz(29, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 64'hFFFFFFFFFFFFFFFF, OR_Oper, 0);

        run_test_rz(30, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 64'hFFFFFFFFFFFFFFFF, OR_Oper, 0);

        run_test_rz(31, 64'h00002C84C4D54177, 64'h011C2D636E06D380, 64'h011C2DE7EED7D3F7, OR_Oper, 0);

        run_test_rz(32, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, XOR_Oper, 1);

        run_test_rz(33, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 64'hFFFFFFFFFFFFFFFF, XOR_Oper, 0);

        run_test_rz(34, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 64'hFFFFFFFFFFFFFFFF, XOR_Oper, 0);

        run_test_rz(35, 64'h123456789ABCDEF0, 64'h123456789ABCDEF0, 64'h0000000000000000, XOR_Oper, 1);

        run_test_rz(36, 64'h0000000000000001, 64'h000BEEF000000000, 64'h0000000000000001, SLL_Oper, 0);

        run_test_rz(37, 64'h0000000000000001, 64'h0000DADA0000003F, 64'h8000000000000000, SLL_Oper, 0);

        run_test_rz(38, 64'hAAAAAAAAAAAAAAAA, 64'h0000000000000001, 64'h5555555555555554, SLL_Oper, 0);

        run_test_rz(39, 64'h0000000000000000, 64'h000000000000000A, 64'h0000000000000000, SLL_Oper, 1);

        run_test_rz(40, 64'h0000000000000001, 64'h000DEAF000000000, 64'h0000000000000001, SRL_Oper, 0);

        run_test_rz(41, 64'h7000000000000000, 64'h00B00B500000003F, 64'h0000000000000000, SRL_Oper, 1);

        run_test_rz(42, 64'h8000000000000000, 64'h0000000000000020, 64'h0000000080000000, SRL_Oper, 0);

        run_test_rz(43, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000020, 64'h00000000FFFFFFFF, SRL_Oper, 0);

        run_test_rz(44, 64'h8000000000000000, 64'h00B00B5000000001, 64'hC000000000000000, SRA_Oper, 0);

        run_test_rz(45, 64'h4000000000000000, 64'h0123400000000001, 64'h2000000000000000, SRA_Oper, 0);

        run_test_rz(46, 64'h0000000000000001, 64'h00DEED0000000001, 64'h0000000000000000, SRA_Oper, 1);

        run_test_rz(47, 64'h8000000000000000, 64'h0000000000000020, 64'hFFFFFFFF80000000, SRA_Oper, 0);

        run_test_rz(48, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, SLT_Oper, 1);

        run_test_rz(49, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 64'h0000000000000001, SLT_Oper, 0);

        run_test_rz(50, 64'h0000000000000000, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, SLT_Oper, 1);

        run_test_rz(51, 64'h8000000000000000, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000001, SLT_Oper, 0);

        run_test_rz(52, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, SLTU_Oper, 1);

        run_test_rz(53, 64'h0000000000000001, 64'h0000000000000000, 64'h0000000000000000, SLTU_Oper, 1);

        run_test_rz(54, 64'h7FFFFFFFFFFFFFFF, 64'h8000000000000000, 64'h0000000000000001, SLTU_Oper, 0);

        run_test_rz(55, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, SLTU_Oper, 1);

        $display("\n========================================");
        $display("  FINAL RESULT: Passed %0d/%0d tests", pass_count, total_tests);
        $display("========================================\n");
        $fdisplay(file_handle, "Passed %0d/%0d tests", pass_count, total_tests);
        $fclose(file_handle);
        #10 $finish;
    end
endmodule

