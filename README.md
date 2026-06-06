# RISC-V CPU — RV32I Processor in VHDL

A fully functional RV32I processor implemented from scratch in VHDL, synthesized and tested on a Xilinx Artix-7 FPGA (Nexys A7 100T).

Built as a learning project to understand processor architecture from the ground up — every component designed, simulated, and verified independently before integration.

Status (May 2026): Core ALU and Decoder are fully functional on hardware. Currently implementing Data Memory and exploring hazard unit strategies.

---

## Architecture

A 2-stage pipelined processor:

```
Stage 1 — Fetch
  Program Counter → Instruction Memory (BRAM) → Pipeline Register

Stage 2 — Execute
  Decoder → Register File → ALU → Data Memory → Writeback
```

```
┌─────┐    ┌──────┐    ┌─────────┐    ┌─────┐
│ PC  │───▶│ IMEM │───▶│ Decoder │───▶│ ALU │───▶ Register File
└─────┘    └──────┘    └─────────┘    └─────┘
   ▲                        │              │
   │                        ▼              ▼
   └──────────── Branch   RegFile       DMEM
                 Logic
```

---

## Features

- **ISA:** RV32I Base Integer Instruction Set
- **Pipeline:** 2-Stage (Fetch + Execute) with branch flush
- **Instruction Memory:** 16KB BRAM (4096 × 32-bit), synthesized to Block RAM
- **Data Memory:** Separate read/write memory for load/store operations
- **Register File:** 32 × 32-bit registers, asynchronous read, synchronous write, x0 hardwired to zero
- **ALU:** All RV32I arithmetic and logic operations
- **Supported Instructions:**
  - R-Type: `ADD SUB AND OR XOR SLL SRL SRA SLT SLTU`
  - I-Type: `ADDI ANDI ORI XORI SLTI SLTIU SLLI SRLI SRAI`
  - Load: `LW LH LB LHU LBU`
  - Store: `SW SH SB`
  - Branch: `BEQ BNE BLT BGE BLTU BGEU`
  - Jump: `JAL JALR`

---

## Project Structure

```
riscv-cpu/
├── src/
│   ├── alu.vhd          # ALU — all RV32I operations
│   ├── alu_src.vhd      # Operand multiplexer (register vs immediate)
│   ├── registers.vhd    # 32×32-bit Register File
│   ├── pc.vhd           # Program Counter with reset and branch support
│   ├── imem.vhd         # Instruction Memory (BRAM inference)
│   ├── decoder.vhd      # Instruction Decoder — all RV32I formats
│   └── datapath.vhd     # Top-level integration
├── tb/
│   ├── alu_tb.vhd       # ALU testbench — all operations verified
│   ├── registers_tb.vhd # Register File testbench
│   ├── pc_tb.vhd        # Program Counter testbench
│   └── decoder_tb.vhd   # Decoder testbench
├── synth/
│   ├── build.tcl        # Vivado build script
│   ├── sources.tcl      # Source file list
│   └── constraints/
│       └── nexys_a7.xdc # Pin constraints for Nexys A7 100T
├── docs/
│   └── architecture.md  # Detailed architecture documentation
├── Makefile             # Simulation and synthesis automation
└── README.md
```

---

## Getting Started

### Prerequisites

- [GHDL](https://github.com/ghdl/ghdl) — VHDL simulation
- [GTKWave](https://gtkwave.sourceforge.net/) — waveform viewer
- [Vivado 2024+](https://www.xilinx.com/support/download.html) — synthesis (optional)

### Simulation

```bash
# Simulate a single component
cd riscv-cpu
make sim TARGET=alu_tb

# Run all testbenches
make test
```

### Synthesis

Requires Vivado and a remote or local Windows machine (Vivado is Windows/Linux only):

```bash
make synth
```

The build script automatically:
1. Transfers sources via SSH + tar
2. Creates a Vivado project
3. Runs synthesis and implementation
4. Downloads the bitstream

### Programming the FPGA

```bash
make flash
```

---

## Development Workflow

Each component was developed independently with its own testbench:

1. Write component in VHDL
2. Write testbench with `assert` statements
3. Simulate with GHDL, verify with GTKWave
4. Integrate into datapath

This bottom-up approach ensures each building block is verified before integration.

---

## Tools & Toolchain

| Tool | Purpose |
|------|---------|
| GHDL | VHDL simulation on macOS (Apple Silicon) |
| GTKWave | Waveform visualization |
| Vivado 2025.2 | Synthesis & implementation |
| openFPGALoader | FPGA programming from macOS |
| Tailscale + SSH | Remote Vivado on Windows PC |
| Neovim + vhdl_ls | VHDL development environment |

---

## Target Hardware

**Digilent Nexys A7 100T**
- FPGA: Xilinx Artix-7 XC7A100T
- On-board RAM: 128MB DDR2
- Clock: 100MHz (divided to 25MHz for CPU)

---

## Roadmap

- [x] ALU
- [x] Register File
- [x] Program Counter
- [x] Instruction Memory (BRAM)
- [x] Instruction Decoder
- [x] Data Memory
- [ ] Datapath integration
- [ ] Branch logic & pipeline flush
- [ ] UART peripheral
- [ ] C toolchain integration
- [ ] 5-stage pipeline
- [ ] M-Extension (multiply/divide)

---

## References

- [RISC-V Unprivileged ISA Specification](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf)
- [RISC-V Instruction Reference Card](https://github.com/jameslzhu/riscv-card)
- [GHDL Documentation](https://ghdl.github.io/ghdl/)

---

## Author

**Johannes** — Electrical Engineering Student, FH Dortmund
