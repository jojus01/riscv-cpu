library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder is
    Port (
    INST : in STD_LOGIC_VECTOR(31 downto 0);    -- Instruction
    rs1 : out STD_LOGIC_VECTOR(4 downto 0);     -- first register address R-type instruction
    rs2 : out STD_LOGIC_VECTOR(4 downto 0);     -- second register address R-type instruction
    rd : out STD_LOGIC_VECTOR(4 downto 0);      -- destination register for alu result
    imm : out STD_LOGIC_VECTOR(31 downto 0);    -- sign-extended immediate
    alu_op : out STD_LOGIC_VECTOR(3 downto 0);  -- alu operation code funct7(5) & funct3(3 downto 0)
    funct3 : out STD_LOGIC_VECTOR(2 downto 0);  -- alu operation code for I,S,B and U-type instruction
    alu_src : out STD_LOGIC;                    -- selection of which operand should be used. immediate or register
    write_reg : out STD_LOGIC;                  -- at high status, values can be written in the register
    read_mem : out STD_LOGIC;                   
    write_mem : out STD_LOGIC;
    mem_to_reg : out STD_LOGIC;
    branch : out STD_LOGIC;                     -- for B-Type instruction
    pc_src : out STD_LOGIC;                        -- for J-Type instruction
    jalr : out STD_LOGIC
    );
end decoder;

architecture Behavioral of decoder is
begin

  funct3 <= inst(14 downto 12);
  jalr <= '1' when INST(6 downto 0) = "1100111" else '0';

  decode: process(inst)
  begin
    
    case inst(6 downto 0) is
      when "0110011" => 
        rs1 <= inst(19 downto 15);    -- R-Type
        rs2 <= inst(24 downto 20);
        rd <= inst(11 downto 7);
        alu_op <= inst(30) & inst(14 downto 12);
        alu_src <= '0';
        write_reg <= '1';
        read_mem <= '0';
        write_mem <= '0';
        mem_to_reg <= '0';
        branch <= '0';
        pc_src <= '0';
        imm <= (others => '0');
      
      when "0010011" =>               -- I-Type instructions 
        case inst(14 downto 12) is
          when "001" =>                         --SLLI
            alu_op <= '0' & inst(14 downto 12);
            imm(4 downto 0) <= inst(24 downto 20);
            imm(31 downto 5) <= (others => '0');

          when "101" =>                         --SRLI/SRAI
            alu_op <= inst(30) & inst(14 downto 12);
            imm(4 downto 0) <= inst(24 downto 20);
            imm(31 downto 5) <= (others => '0');

          when others =>
            alu_op <= '0' & inst(14 downto 12);
            imm(10 downto 0) <= inst(30 downto 20);     -- immediate instruction decoding
            imm(31 downto 11) <= (others => inst(31));
        end case;

        rs1 <= inst(19 downto 15);    -- I-Type. arithmetic immediate operations
        rs2 <= (others => '0');
        rd <= inst(11 downto 7);
        alu_src <= '1';           -- use immediate
        write_reg <= '1';
        read_mem <= '0';
        write_mem <= '0';
        mem_to_reg <= '0';
        branch <= '0';
        pc_src <= '0';

      when "0000011" =>           -- I-Type. Load instructions
        rs1 <= inst(19 downto 15);
        rs2 <= (others => '0');
        rd <= inst(11 downto 7);
        alu_op <= "0000";
        alu_src <= '1';
        write_reg <= '1';
        read_mem <= '1';
        write_mem <= '0';
        mem_to_reg <= '1';
        branch <= '0';
        pc_src <= '0';

        imm(10 downto 0) <= inst(30 downto 20);
        imm(31 downto 11) <= (others => inst(31));

      when "0100011" =>         -- S-Type. store instructions
        rs1 <= inst(19 downto 15);
        rs2 <= inst(24 downto 20);
        rd <= (others => '0');
        alu_op <= "0000";
        alu_src <= '1';
        write_reg <= '0';
        read_mem <= '0';
        write_mem <= '1';
        mem_to_reg <= '0';
        branch <= '0';
        pc_src <= '0';

        imm(10 downto 0) <= inst(30 downto 25) & inst(11 downto 7);
        imm(31 downto 11) <= (others => inst(31));
      
      when "1100011" =>     -- B-Type Branch operations
        rs1 <= inst(19 downto 15);
        rs2 <= inst(24 downto 20);
        rd <= (others => '0');
        alu_op <= "1000";
        alu_src <= '0';
        write_reg <= '0';
        read_mem <= '0';
        write_mem <= '0';
        mem_to_reg <= '0';
        branch <= '1';
        pc_src <= '0';

        imm(11 downto 0) <= inst(7) & inst(30 downto 25) & inst(11 downto 8) & '0';
        imm(31 downto 12) <= (others => inst(31));

      when "1101111" => -- Jump and Link operations
        rs1 <= (others => '0');
        rs2 <= (others => '0');
        rd <= inst(11 downto 7);
        alu_op <= "0000";
        alu_src <= '1';
        write_reg <= '1';
        read_mem <= '0';
        write_mem <= '0';
        mem_to_reg <= '0';
        branch <= '1';
        pc_src <= '1';

        imm(19 downto 0) <= inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0';
        imm(31 downto 20) <= (others => inst(31));
        
      when "1100111" =>   -- JALR
        rs1 <= inst(19 downto 15);
        rs2 <= (others => '0');
        rd <= inst(11 downto 7);
        alu_op <= "0000";  -- ADD: rs1 + imm
        alu_src <= '1';
        write_reg <= '1';
        read_mem <= '0';
        write_mem <= '0';
        mem_to_reg <= '0';
        branch <= '0';
        pc_src <= '1';

        imm(10 downto 0)  <= inst(30 downto 20);
        imm(31 downto 11) <= (others => inst(31));

      when "0110111" =>   -- LUI (Load Upper Immediate)
        rd  <= inst(11 downto 7);
        imm(31 downto 12) <= inst(31 downto 12);
        imm(11 downto 0)  <= (others => '0');
        alu_op     <= "0000";   -- ADD: result = x0 + imm = imm
        alu_src    <= '1';      -- use immediate
        write_reg  <= '1';      -- write result to rd
        read_mem   <= '0';
        write_mem  <= '0';
        mem_to_reg <= '0';
        branch     <= '0';
        pc_src     <= '0';
        rs1        <= "00000";  -- x0 is always 0 → result = 0 + imm

      when others =>
        rs1 <= (others => '0');
        rs2 <= (others => '0');
        rd  <= (others => '0');
        imm <= (others => '0');
        alu_op <= "0000";
        alu_src <= '0';
        write_reg <= '0';
        read_mem <= '0';
        write_mem <= '0';
        mem_to_reg <= '0';
        branch <= '0';
        pc_src <= '0';

    end case;
  end process decode;
end Behavioral;
