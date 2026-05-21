library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_src is
    Port (
    reg_data_0 : in STD_LOGIC_VECTOR(31 downto 0);
    imm_data_1 : in STD_LOGIC_VECTOR(31 downto 0);
    alu_src_out : out STD_LOGIC_VECTOR(31 downto 0);
    imm_enable : in STD_LOGIC
    );
end alu_src;

architecture Behavioral of alu_src is
begin
  mp_alu: process(imm_enable, imm_data_1, reg_data_0)
  begin
    if imm_enable = '1' then
      alu_src_out <= imm_data_1;
    else 
      alu_src_out <= reg_data_0;
    end if;
    
  end process mp_alu;
end Behavioral;
