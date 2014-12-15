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
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.STD_LOGIC_UNSIGNED;
--PC outputs x and y coordinates to read from grid
--dir input affects PC incrementing, it denotes the direction of execution in befunge_pc
--skip increments the pc twice to avoid a cell
--en, so that the operation of the pc can be clocked

entity befunge_pc is
	generic(
	    grid_width  : integer;
	    grid_height : integer
	);
	 
    port( 
        clk          : in  std_logic;
        reset        : in  std_logic;
        pc_address    : out integer range 0 to (grid_width*grid_height)-1;
        dir          : in  std_logic_vector (1 downto 0);
        skip		 : in  std_logic;
        en           : in  std_logic
    );
end befunge_pc;

--dir:
--0 = right
--1 = down
--2 = left
--3 = up

architecture pc_v1 of befunge_pc is

   signal pc_address_int : integer range 0 to (grid_width*grid_height)-1;

begin

    pc_address <= pc_address_int;
    
	process(reset,clk)
        variable increment : integer range 1 to 2;
	begin
	if(reset = '1') then
		pc_address_int <= 0;	
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
                    pc_address_int <= pc_address_int + 1;
                elsif ( dir = "01" ) then						--move up: subtract grid_width
                    pc_address_int <= pc_address_int - 8;
                elsif ( dir = "10" ) then						--move left: subtract 1
                    pc_address_int <= pc_address_int - 1;
                elsif (dir = "11") then							--move down: add grid_width
					pc_address_int <= pc_address_int + 8;
				else											--do nothing, laaaatchhh!!!!
					pc_address_int <= pc_address_int;
                end if;
            end if;
		end if;
	end if;
end process;

end pc_v1;

architecture pc_v2 of befunge_pc is

   signal pc_address_int : integer range 0 to (grid_width*grid_height)-1;

begin

    pc_address <= pc_address_int;
    
	process(reset,clk)
        variable increment : integer range 1 to 2;
	begin
	if(reset = '1') then
		pc_address_int <= 0;	
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
                    pc_address_int <= pc_address_int + 1;
                elsif ( dir = "01" ) then						--move up: subtract grid_width
                    pc_address_int <= pc_address_int - 8;
                elsif ( dir = "10" ) then						--move left: subtract 1
                    pc_address_int <= pc_address_int - 1;
                elsif (dir = "11") then							--move down: add grid_width
					pc_address_int <= pc_address_int + 8;
				else											--do nothing, laaaatchhh!!!!
					pc_address_int <= pc_address_int;
                end if;
            end if;
		end if;
	end if;
end process;
end pc_v2;
