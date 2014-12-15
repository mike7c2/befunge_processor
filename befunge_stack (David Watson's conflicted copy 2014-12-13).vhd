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
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.STD_LOGIC_UNSIGNED;

entity befunge_stack is
	generic(
	    stack_depth_pow  : integer;
            word_size : integer
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

architecture pc_v1 of befunge_stack is
   type stack_type is array ((2**stack_depth_pow)-1 downto 0) of std_logic_vector(word_size-1 downto 0);
   signal stack : stack_type;
   signal stack_ptr : Unsigned(stack_depth_pow-1 downto 0);
begin

    stack_0 <= stack(stack_ptr);
    stack_1 <= stack(stack_ptr-1);

    
	process(reset,clk)
	
        variable ptr_incr : integer range(-2 to 1);
	begin
	if(reset = '1') then
		stack_0_o <= (others => '0');	
        stack_1_o <= (others => '0');	
        stack <= (others => (others => '0'));
	else
		if rising_edge(clk) then

		    if ( en = '1' ) then

                if ( pop1 = "1" ) then
                    ptr_incr := ptr_incr - 1;
                    
                elsif ( pop2 = "1" ) then
                    ptr_incr := ptr_incr - 2;

                elsif ( push = "1" ) then
                    ptr_incr := ptr_incr + 1;
                    stack(stack_ptr + ptr_incr) <= stack_i;

                elsif (swap = "1" ) then
                    stack(stack_ptr) <= stack(stack_ptr - 1);
                    stack(stack_ptr - 1) <= stack(stack_ptr);

                end if;

                stack_ptr <= std_logic_vector(stack_ptr + ptr_incr);
                stack_0_o <= stack(stack_ptr + ptr_incr);
                stack_1_o <= stack(stack_ptr + ptr_incr - 1);

            end if;
		end if;
	end if;
end process;


































