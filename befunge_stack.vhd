----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:21:54 12/01/2014 
-- Design Name: 
-- Module Name:    befunge_stack - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity befunge_stack is
	generic(
	    stack_depth_pow  : integer := 4;
        word_size : integer := 8
	);
	 
    port( 
        clk          : in  std_logic;
        reset        : in  std_logic;
        stack_0_o    : out std_logic_vector(word_size-1 downto 0);
        stack_1_o    : out std_logic_vector(word_size-1 downto 0);
        stack_i      : in  std_logic_vector(word_size-1 downto 0);
        pop1         : in  std_logic;
        pop2         : in  std_logic;
        push         : in  std_logic;
        swap         : in  std_logic;
        en           : in  std_logic
    );
end befunge_stack;

architecture stack_v1 of befunge_stack is
   type stack_type is array ((2**stack_depth_pow)-1 downto 0) of std_logic_vector(word_size-1 downto 0);
   signal stack : stack_type;
   signal stack_ptr : Signed(stack_depth_pow-1 downto 0);
begin

    stack_0_o <= stack(to_integer(Unsigned(stack_ptr)));
    stack_1_o <= stack(to_integer(Unsigned(stack_ptr- 1)));

	process(reset,clk)
        variable ptr_incr : integer range -2 to 1;
	begin
        if(reset = '1') then
            --stack_0_o <= (others => '0');	
            --stack_1_o <= (others => '0');	
            stack <= (others => (others => '0'));
            stack_ptr <= (others => '0');
        else
            if rising_edge(clk) then
                ptr_incr := 0;
                if ( en = '1' ) then

                    if (pop1 = '1' or pop2 = '1' or push = '1') then
                        if ( pop1 = '1' ) then
                            ptr_incr := - 1;
                        elsif ( pop2 = '1' ) then
                            ptr_incr := - 2;
                        elsif ( push = '1' ) then
                            ptr_incr := 1;
                            stack(to_integer(Unsigned(stack_ptr + ptr_incr))) <= stack_i;
                        end if;

                        

                    elsif (swap = '1' ) then
                        stack(to_integer(stack_ptr)) <= stack(to_integer(stack_ptr - 1));
                        stack(to_integer(stack_ptr - 1)) <= stack(to_integer(stack_ptr));

                        --stack_0_o <= stack(to_integer(stack_ptr + ptr_incr -1));
                        --stack_1_o <= stack(to_integer(stack_ptr + ptr_incr));
                    end if;

                    stack_ptr <= stack_ptr + ptr_incr;
                end if;
            end if;
		end if;
    end process;
end stack_v1;