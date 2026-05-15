# RISC-V Processor Design — Sequential & Pipelined

> A modular 64-bit RISC-V CPU implemented in Verilog HDL, developed in two phases:  
> **Phase 1 — Single-Cycle Sequential Processor** | **Phase 2 — 5-Stage Pipelined Processor**

---

## Supported Instructions

| Type | Instructions |
|------|-------------|
| R-Type | `add`, `sub`, `and`, `or` |
| I-Type | `addi`, `ld` |
| S-Type | `sd` |
| B-Type | `beq` |

> **Memory Organization:** Big-Endian for both instruction and data memory.

---

## Phase 1 — Sequential (Single-Cycle) Processor

Each instruction completes all stages within a single clock cycle. Simple to verify but limited in throughput.

### Datapath Components

- **Program Counter (PC):** 64-bit register holding the address of the current instruction; updated on every rising clock edge.
- **Instruction Memory:** Read-only memory block; supplies 32-bit instructions based on the PC address.
- **Register File:** 32 × 64-bit registers; supports two simultaneous reads and one write per cycle.
- **Control Unit:** Decodes the opcode and generates control signals — `RegWrite`, `ALUSrc`, `MemRead`, `MemWrite`, `MemtoReg`, `Branch`, `ALUOp`.
- **Immediate Generator (ImmGen):** Sign-extends 12-bit immediates to 64 bits for I, S, and B-type instructions.
- **ALU Control:** Generates 4-bit ALU operation code from `funct3`, `funct7`, and `ALUOp`.
- **ALU:** Performs arithmetic (`add`, `sub`) and logical (`and`, `or`) operations; produces a Zero flag for branch decisions.
- **Data Memory:** Supports 64-bit load (`ld`) and store (`sd`); write on rising clock edge, read combinationally.
- **Adder Blocks:** PC+4 adder for sequential fetch; branch target adder computes `PC + (imm << 1)`.

### Clocking

Fully synchronous, rising-edge-triggered. Clock period is sized to accommodate the worst-case combinational delay across the entire datapath.

### Instruction Flow Summary

| Instruction | Key Steps |
|-------------|-----------|
| R-type | Fetch → Read rs1, rs2 → ALU op → Write rd |
| Load (`ld`) | Fetch → Read rs1 → ALU computes address → Read memory → Write rd |
| Store (`sd`) | Fetch → Read rs1, rs2 → ALU computes address → Write memory |
| `addi` | Fetch → Read rs1 → ALU adds immediate → Write rd |
| `beq` | Fetch → Read rs1, rs2 → ALU subtracts → Zero flag selects next PC |

### Verification

Tested with:
- Fibonacci sequence generation
- Linear search in an array
- Sum of first *n* natural numbers

Simulation waveforms captured at **50 ns**, **500 ns**, and program completion confirmed correct PC updates, register writes, ALU results, and memory accesses.

---

## Phase 2 — Pipelined Processor (5-Stage)

Implements a 5-stage in-order pipeline with full hazard handling, gate-level ALU and control unit, and a tournament branch predictor.

### Pipeline Stages

```
IF  →  ID  →  EX  →  MEM  →  WB
```

Separated by four pipeline registers: **IF/ID**, **ID/EX**, **EX/MEM**, **MEM/WB**.

| Stage | Description |
|-------|-------------|
| **IF** | PC fetches instruction from memory; gate-level ripple-carry PC+4 adder; supports stalling via `PC_Write` signal |
| **ID** | Gate-level control unit decodes opcode; register file read; ImmGen sign-extends; hazard detection unit monitors load-use hazards |
| **EX** | Gate-level 64-bit ALU (full/half adders, barrel shifters, bitwise gates); forwarding unit resolves RAW hazards; branch target computed and evaluated |
| **MEM** | 64-bit byte-addressable data memory; synchronous writes, combinational reads; branch flush logic |
| **WB** | MemtoReg mux selects between ALU result and memory data; writes back to register file |

### Pipeline Registers

- **IF/ID:** Holds fetched instruction and PC+4; controlled by `IF_ID_Write` for stalls; flushed on taken branch via `IF_Flush`.
- **ID/EX:** Passes register operands, immediate, PC, control signals, register indices, and branch prediction metadata to EX stage. On flush/reset, inserts a bubble; on stall, clears control signals while preserving data.
- **EX/MEM:** Holds ALU result, Zero flag, branch target, store data, destination register `rd`, and control signals (`MemRead`, `MemWrite`, `MemtoReg`, `RegWrite`). Also enables forwarding via `EX_MEM_rd`.
- **MEM/WB:** Holds memory read data, ALU result, `rd`, and write-back control signals for the final register write.

---

## Hazard Handling

### Data Hazards

| Type | Solution |
|------|----------|
| **Load-Use Stall** | PC and IF/ID registers freeze; NOP bubble inserted into ID/EX for 1 cycle |
| **EX-EX Forwarding** | ALU result from EX/MEM forwarded directly to ALU input of current EX stage |
| **MEM-EX Forwarding** | Writeback mux output from MEM/WB forwarded to ALU input of current EX stage |

### Control Hazards

Branch outcomes are resolved in the **EX stage**. If a branch is taken, both IF/ID and ID/EX registers are flushed to zero — incurring a **2-cycle penalty**. A tournament branch predictor (see below) reduces the frequency of these flushes.

---

## Branch Prediction

A **tournament branch predictor** dynamically selects between two sub-predictors to minimize misprediction penalties.

### Components

- **1-bit Predictor:** Stores the last branch outcome; flips on misprediction. Fast but prone to oscillation in complex patterns.
- **2-bit Saturating Counter:** Requires two consecutive mispredictions before changing state. More stable for typical loop-heavy code.
- **Tournament Selector:** A per-entry 2-bit counter that tracks which sub-predictor has been more accurate and selects accordingly.

### Selector Update Logic

| Scenario | Action |
|----------|--------|
| Both correct | No change |
| Both wrong | No change |
| Only 1-bit correct | Decrease selector (favor 1-bit) |
| Only 2-bit correct | Increase selector (favor 2-bit) |

### Implementation Details

- **Table size:** 64 entries, indexed by `PC[7:2]` (direct-mapped; entry 65 wraps to entry 0).
- Prediction metadata (1-bit state, 2-bit state, selector state) is propagated through IF/ID and ID/EX pipeline registers to ensure the correct speculative state is available at the EX stage for updating.
- On misprediction: pipeline is flushed and PC is corrected.
- States `00`/`01` → predict **not taken**; `10`/`11` → predict **taken** (2-bit counter MSB as output).
