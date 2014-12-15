
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity befunge_alu is
	generic(
        word_size : integer := 8
	);
	 
    port( 
        clk          : in  std_logic;
        reset        : in  std_logic;
        a            : in  std_logic_vector(word_size-1 downto 0);
        b            : in  std_logic_vector(word_size-1 downto 0);
        result       : out std_logic_vector(word_size-1 downto 0);
        op           : in  std_logic_vector(2 downto 0);
        en           : in  std_logic;
        working      : out std_logic
    );
end befunge_alu;

architecture alu_v1 of befunge_alu is
    constant zero : std_logic_vector(word_size - 1 downto 0) := (others => '0');
    signal en_shadow : std_logic;
begin
    

	process(reset,clk)
        variable result_int : std_logic_vector((word_size * 2) -1 downto 0);
	begin
        if(reset = '1') then
            result <= (others => '0');
            en_shadow <= '0';
            working <= '0';--This flag should be used to stall the cpu for multi cycle instructions (mod and div)
        else
            if rising_edge(clk) then
                en_shadow <= en;
                if ( en = '1' and en_shadow = '0' ) then
                    working <= '1';
                    if ( op = "000" ) then      -- + add
                        result <= std_logic_vector(Unsigned(a) + Unsigned(b));
                    elsif ( op = "001" ) then  -- - subract
                        result <= std_logic_vector(Unsigned(a) - Unsigned(b));
                    elsif ( op = "010" ) then  -- * multiply 
                        result_int := std_logic_vector(Unsigned(a) * Unsigned(b));
                        result <= result_int(word_size-1 downto 0);
                    elsif ( op = "011" ) then  -- / divide (hard!)
--                        result <= std_logic_vector(Unsigned(a) / Unsigned(b));
                    elsif ( op = "100" ) then  -- % modulue (hard!)
                        --result <= std_logic_vector(Unsigned(a) % Unsigned(b));
                    elsif ( op = "101" ) then  -- ! not 
                        if (a /= zero) then
                            result <= (others => '0');
                        else
                            result <= "00000001";
                        end if;
                    elsif ( op = "110" ) then  -- ' greater than
                        result <= (others => '0');
                    end if;
                else
                working <= '0';
                end if;
                
            end if;
		end if;
    end process;
end alu_v1;