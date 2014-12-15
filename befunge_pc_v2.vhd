----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:21:54 12/01/2014 
-- Design Name: 
-- Module Name:    befunge_pc - Behavioral 
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
--PC outputs x and y coordinates to read from grid
--dir input affects PC incrementing, it denotes the direction of execution in befunge_pc
--skip increments the pc twice to avoid a cell
--en, so that the operation of the pc can be clocked

entity befunge_pc_v2 is
	generic(
	    grid_power  : integer
	);
	 
    port( 
        clk          : in  std_logic;
        reset        : in  std_logic;
        pc_address   : out std_logic_vector((grid_power * 2)-1 downto 0);
        dir          : in  std_logic_vector (1 downto 0);
        skip		 : in  std_logic;
        en           : in  std_logic
    );
end befunge_pc_v2;

--dir:
--0 = right
--1 = down
--2 = left
--3 = up

architecture pc_v1 of befunge_pc_v2 is
   signal pc_address_int : std_logic_vector((grid_power * 2)-1 downto 0);
   signal pc_row : std_logic_vector(grid_power-1 downto 0);
   signal pc_col : std_logic_vector(grid_power-1 downto 0);
begin

   pc_address((grid_power * 2)-1 downto ((grid_power*2)/2)) <= pc_col;
	pc_address(((grid_power * 2)/2)-1 downto 0) <= pc_row;
    
	process(reset,clk)
        variable increment : integer range 1 to 2;
	begin
	if(reset = '1') then
		pc_address_int <= (others => '0');	
		pc_row <= (others => '0');	
		pc_col <= (others => '0');	
		increment := 1;
	else
		if rising_edge(clk) then
		    if ( en = '1' ) then
                if ( skip = '1' ) then
                    increment := 2;
                else
                    increment := 1;
                end if;
                if ( dir = "00" ) then 							--move right: add 1
                    pc_row <= std_logic_vector((unsigned(pc_row) + increment));
                elsif ( dir = "01" ) then						--move up: subtract grid_width
                    pc_col <= std_logic_vector((unsigned(pc_col) - increment));
                elsif ( dir = "10" ) then						--move left: subtract 1
                    pc_row <= std_logic_vector((unsigned(pc_row) - increment));
                elsif (dir = "11") then							--move down: add grid_width
                    pc_col <= std_logic_vector((unsigned(pc_col) + increment));
				else											--do nothing, laaaatchhh!!!!

                end if;
            end if;
		end if;
	end if;
end process;

end pc_v1;
