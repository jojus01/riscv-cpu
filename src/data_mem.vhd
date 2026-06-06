library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_mem is
    Port (
    CLK : in STD_LOGIC;
    write_enable : in STD_LOGIC;
    funct3 : in STD_LOGIC_VECTOR(2 downto 0);
    addr : in STD_LOGIC_VECTOR(31 downto 0);
    write_data : in STD_LOGIC_VECTOR(31 downto 0);
    read_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end data_mem;

architecture Behavioral of data_mem is
  type mem_t is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem : mem_t := (others => (others => '0'));
-- force distributed RAM
  attribute ram_style : string;
  attribute ram_style of mem : signal is "distributed";
-- internal signals
  signal word_addr : INTEGER range 0 to 255;
  signal word : STD_LOGIC_VECTOR(31 downto 0);

begin

  word_addr <= TO_INTEGER(unsigned(addr(9 downto 2)));
  word <= mem(word_addr);

  process(word, funct3, addr)
      variable byte_sel : std_logic_vector(7 downto 0);
      variable half_sel : std_logic_vector(15 downto 0);
    begin
      -- default: full word (LW)
      read_data <= word;

      case funct3 is
        when "000" | "100" =>
          -- select the correct byte from the 32-bit word
          case addr(1 downto 0) is
            when "00"   => byte_sel := word( 7 downto  0);
            when "01"   => byte_sel := word(15 downto  8);
            when "10"   => byte_sel := word(23 downto 16);
            when others => byte_sel := word(31 downto 24);
          end case;

          if funct3 = "000" then
            read_data <= (31 downto 8 => byte_sel(7)) & byte_sel;
          else
            read_data <= (31 downto 8 => '0') & byte_sel;
          end if;

        when "001" | "101" =>
          -- select lower or upper halfword
          if addr(1) = '0' then
            half_sel := word(15 downto 0);   -- lower halfword
          else
            half_sel := word(31 downto 16);  -- upper halfword
          end if;

          if funct3 = "001" then
            read_data <= (31 downto 16 => half_sel(15)) & half_sel;
          else
            -- LHU: zero extension
            read_data <= (31 downto 16 => '0') & half_sel;
          end if;

        when "010" =>
          read_data <= word;

        when others =>
          read_data <= word;

      end case;
  end process;

  -- Synchronous write
  process(clk)
      variable current_word : std_logic_vector(31 downto 0);
  begin
    if rising_edge(clk) then
      if write_enable = '1' then
        -- read current word for read-modify-write
        current_word := mem(word_addr);

        case funct3 is

          -- SB: store byte
          when "000" =>
            case addr(1 downto 0) is
              when "00" =>
                  current_word( 7 downto  0) := write_data(7 downto 0);
              when "01" =>
                  current_word(15 downto  8) := write_data(7 downto 0);
              when "10" =>
                  current_word(23 downto 16) := write_data(7 downto 0);
              when others =>
                  current_word(31 downto 24) := write_data(7 downto 0);
            end case;

            -- SH: store halfword
          when "001" =>
            if addr(1) = '0' then
                current_word(15 downto  0) := write_data(15 downto 0);
            else
                current_word(31 downto 16) := write_data(15 downto 0);
            end if;
          -- SW: store word - replace entire 32-bit word
          when "010" =>
            current_word := write_data;

          when others =>
            current_word := write_data;
        end case;
        -- write modified word back to memory
        mem(word_addr) <= current_word;

      end if;
    end if;
  end process;
end Behavioral;
