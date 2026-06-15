library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
    A : in STD_LOGIC_VECTOR(31 downto 0);     -- first operand       
    B : in STD_LOGIC_VECTOR(31 downto 0);     -- second operand
    OP : in STD_LOGIC_VECTOR(3 downto 0);    -- operation code. Part of R-Type instruction. OP = funct7[5] & funct3
    RES : out STD_LOGIC_VECTOR(31 downto 0);
    STAT_EQ : out STD_LOGIC;
    STAT_LT : out STD_LOGIC;
    STAT_LTU : out STD_LOGIC
    );
end alu;

architecture Behavioral of alu is
begin

  alu_operations: process(A,B,OP)
  begin

    case OP is
      when "0000" => RES <= STD_LOGIC_VECTOR(signed(A) + signed(B));  -- ADD
      when "1000" => RES <= STD_LOGIC_VECTOR(signed(A) - signed(B));  -- SUB
      when "0100" => RES <= A xor B;    -- XOR
      when "0110" => RES <= A or B;     -- OR 
      when "0111" => RES <= A and B;    -- AND 
      when "0001" => RES <= STD_LOGIC_VECTOR(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0))))); -- Shift left logical. Integer 0 to 31     
      when "0101" => RES <= STD_LOGIC_VECTOR(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0))))); -- Shift right logical. Integer 0 to 31 
      when "1101" => RES <= STD_LOGIC_VECTOR(shift_right(signed(A), to_integer(unsigned(B(4 downto 0))))); -- Shift right Arith. Integer 0 to 31

      when "0010" =>
        if signed(A) < signed(B) then     -- (A < B) ? 1 : 0 (SLT)
          RES <= x"00000001";
        else
          RES <= x"00000000";
        end if;

      when "0011" => 
        if unsigned(A) < unsigned(B) then     -- (A < B) ? 1 : 0 (SLTU)
          RES <= x"00000001";
        else
          RES <= x"00000000";
        end if;

      when others => RES <= x"00000000";
        
    end case;
    
  end process alu_operations;

  STAT_EQ <= '1' when signed(A) = signed(B) else '0';
  STAT_LT <= '1' when signed(A) < signed(B) else '0';
  STAT_LTU <= '1' when unsigned(A) < unsigned(B) else '0';

end Behavioral;
