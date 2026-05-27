library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder_tb is
end decoder_tb;

architecture sim of decoder_tb is
    component decoder is
        Port (
        inst : in STD_LOGIC_VECTOR(31 downto 0);
        rs1, rs2, rd : out STD_LOGIC_VECTOR(4 downto 0);
        imm : out STD_LOGIC_VECTOR(31 downto 0);
        alu_op : out STD_LOGIC_VECTOR(3 downto 0);
        funct3 : out STD_LOGIC_VECTOR(2 downto 0);
        alu_src : out STD_LOGIC;
        write_reg : out STD_LOGIC;
        read_mem : out STD_LOGIC;
        write_mem : out STD_LOGIC;
        mem_to_reg : out STD_LOGIC;
        branch : out STD_LOGIC;
        pc_src : out STD_LOGIC
        );
    end component;

    signal inst : STD_LOGIC_VECTOR(31 downto 0);
    signal rs1 : STD_LOGIC_VECTOR(4 downto 0);
    signal rs2 : STD_LOGIC_VECTOR(4 downto 0);
    signal rd : STD_LOGIC_VECTOR(4 downto 0);
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal imm : STD_LOGIC_VECTOR(31 downto 0);
    signal funct3 : STD_LOGIC_VECTOR(2 downto 0);
    signal cu_out : STD_LOGIC_VECTOR(6 downto 0);

begin

  decoder_inst: decoder
   port map(
      INST => INST,
      rs1 => rs1,
      rs2 => rs2,
      rd => rd,
      imm => imm,
      alu_op => alu_op,
      funct3 => funct3,
      alu_src => cu_out(6),
      write_reg => cu_out(5),
      read_mem => cu_out(4),
      write_mem => cu_out(3),
      mem_to_reg => cu_out(2),
      branch => cu_out(1),
      pc_src => cu_out(0)
  );
    sim : process
    begin
      inst <= x"002081b3"; -- ADD x3,x1,x2
      wait for 10 ns;
      assert rs1 = "00001" report "add: rs1 false" severity ERROR;
      assert rs2 = "00010" report "add: rs2 false" severity ERROR;
      assert rd = "00011" report "add: rd false" severity ERROR;
      assert imm = x"00000000" report "add: imm false" severity ERROR;
      assert alu_op = "0000" report "add: alu_op false" severity ERROR;
      assert funct3 = "000" report "add: funct3 false" severity ERROR;
      assert cu_out = "0100000" report "add: cu_out false" severity ERROR;
      
      inst <= x"40418333";  -- SUB x6,x3,x4
      wait for 10 ns;
      assert rs1 = "00011" report "sub: rs1 false" severity ERROR;
      assert rs2 = "00100" report "sub: rs2 false" severity ERROR;
      assert rd = "00110" report "sub: rd false" severity ERROR;
      assert imm = x"00000000" report "sub: imm false" severity ERROR;
      assert alu_op = "1000" report "sub: alu_op false" severity ERROR;
      assert funct3 = "000" report "add: funct3 false" severity ERROR;
      assert cu_out = "0100000" report "add: cu_out false" severity ERROR;

      inst <= x"09610293";  -- ADDI x5, x2, 150
      wait for 10 ns;
      assert rs1 = "00010" report "addi: rs1 false" severity ERROR;
      assert rd = "00101" report "addi: rd false" severity ERROR;
      assert imm = x"00000096" report "addi: imm false" severity ERROR;
      assert alu_op = "0000" report "addi: alu_op false" severity ERROR;
      assert funct3 = "000" report "addi: funct3 false" severity ERROR;
      assert cu_out = "1100000" report "addi: cu_out false" severity ERROR;

      inst <= x"02812083"; -- LW x1, 40(x2)
      wait for 10 ns;
      assert rs1 = "00010" report "lw: rs1 false" severity ERROR;
      assert rd = "00001" report "lw: rd false" severity ERROR;
      assert imm = x"00000028" report "lw: imm false" severity ERROR;
      assert alu_op = "0000" report "lw: alu_op false" severity ERROR;
      assert funct3 = "010" report "lw: funct3 false" severity ERROR;
      assert cu_out = "1110100" report "lw: cu_out false" severity ERROR;

      inst <= x"00511093";  -- SLLI x1, x2, 5
      wait for 10 ns;
      assert rs1 = "00010" report "slli: rs1 false" severity ERROR;
      assert rd = "00001" report "slli: rd false" severity ERROR;
      assert imm = x"00000005" report "slli: imm false" severity ERROR;
      assert alu_op = "0001" report "slli: alu_op false" severity ERROR;
      assert funct3 = "001" report "slli: funct3 false" severity ERROR;
      assert cu_out = "1100000" report "slli: cu_out false" severity ERROR;

      inst <= x"01415093";  -- SRLI x1,x2,20
      wait for 10 ns;
      assert rs1 = "00010" report "srli: rs1 false" severity ERROR;
      assert rd = "00001" report "srli: rd false" severity ERROR;
      assert imm = x"00000014" report "srli: imm false" severity ERROR;
      assert alu_op = "0101" report "srli: alu_op false" severity ERROR;
      assert funct3 = "101" report "srli: funct3 false" severity ERROR;
      assert cu_out = "1100000" report "srli: cu_out false" severity ERROR;

      inst <= x"0820ab23"; -- SW x2, 150(x1)
      wait for 10 ns;
      assert rs1 = "00001" report "sw: rs1 false" severity ERROR;
      assert rs2 = "00010" report "sw: rs2 false" severity ERROR;
      assert imm = x"00000096" report "sw: imm false" severity ERROR;
      assert alu_op = "0000" report "sw: alu_op false" severity ERROR;
      assert funct3 = "010" report "sw: funct3 false" severity ERROR;
      assert cu_out = "1001000" report "sw: cu_out false" severity ERROR;

      inst <= x"0c419463"; -- BNE x3, x4, 200
      wait for 10 ns;
      assert rs1 = "00011" report "bne: rs1 false" severity ERROR;
      assert rs2 = "00100" report "bne: rs2 false" severity ERROR;
      assert imm = x"000000c8" report "bne: imm false" severity ERROR;
      assert alu_op = "1000" report "bne: alu_op false" severity ERROR;
      assert funct3 = "001" report "bne: funct3 false" severity ERROR;
      assert cu_out = "0000011" report "bne: cu_out false" severity ERROR;
      
      inst <= x"02808367";  -- JALR x6, 40(x1)
      wait for 10 ns;
      assert rs1 = "00001" report "jalr: rs1 false" severity ERROR;
      assert rd = "00110" report "jalr: rd false" severity ERROR;
      assert imm = x"00000028" report "jalr: imm false" severity ERROR;
      assert alu_op = "0000" report "jalr: alu_op false" severity ERROR;
      assert funct3 = "000" report "jalr: funct3 false" severity ERROR;
      assert cu_out = "1100001" report "jalr: cu_out false" severity ERROR;

      inst <= x"0fa000ef";  -- JAL x1, 250
      wait for 10 ns;
      assert rd = "00001" report "jal: rd false" severity ERROR;
      assert imm = x"000000fa" report "jal: imm false" severity ERROR;
      assert alu_op = "0000" report "jal: alu_op false" severity ERROR;
      assert funct3 = "000" report "jal: funct3 false" severity ERROR;
      assert cu_out = "1100011" report "jal: cu_out false" severity ERROR;

      inst <= x"00000000"; --others
      wait for 10 ns;
      assert rs1 = "00000" report "add: rs1 false" severity ERROR;
      assert rs2 = "00000" report "add: rs2 false" severity ERROR;
      assert rd = "00000" report "add: rd false" severity ERROR;
      assert imm = x"00000000" report "add: imm false" severity ERROR;
      assert alu_op = "0000" report "add: alu_op false" severity ERROR;
      assert funct3 = "000" report "add: funct3 false" severity ERROR;
      assert cu_out = "0000000" report "add: cu_out false" severity ERROR;


        wait;
    end process;
end sim;
