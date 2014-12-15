----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:21:54 12/01/2014 
-- Design Name: 
-- Module Name:    befunge_processor - Behavioral 
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

--TODO - make PC and address signals use std_logic_vector

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED;
entity befunge_processor is
	 generic
	 (
					word_size 			: integer := 8;
					instruction_size 	: integer := 16; 
					stack_size 			: integer := 2048; 
					grid_width 			: integer := 8; 
					grid_height 		: integer := 8
	);
    port 
	( 
					clk,reset : in   std_logic;
					data_in   : in   std_logic_vector(word_size-1 downto 0);
					data_out  : out  std_logic_vector(word_size-1 downto 0)
	);
end befunge_processor;

architecture processor_v1 of befunge_processor is

    component befunge_pc is
	    generic(
	        grid_width  : integer;
	        grid_height : integer
    	);
	 
        port( 
            clk          : in  std_logic;
            reset        : in  std_logic;
            address_x    : out integer range 0 to grid_width-1;
            address_y    : out integer range 0 to grid_height-1;
            dir          : in  std_logic_vector (1 downto 0);
            skip		 : in  std_logic;
            en           : in  std_logic
        );    
    end component;

	constant LEFT_INSTRUCTION : integer range 0 to 255 := 62;
	
    type stack_declaration is array(stack_size-1 downto 0) of std_logic_vector(word_size-1 downto 0);
    signal stack : stack_declaration;

	type grid_nibble is array (grid_height-1 downto 0) of std_logic_vector(word_size-1 downto 0);
	type grid_stuff is array (grid_width-1 downto 0) of grid_nibble;
-- an array "array of array" type
	variable grid : grid_stuff := 
	(
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size))),
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size))),
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size))),
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size))),
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size))),
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size))),
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size))),
	   (std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)),std_logic_vector(to_unsigned(LEFT_INSTRUCTION,word_size)))
	);    

	type fde_cycle_states is (idle,fetch,decode,execute);
	signal fde_cycle : fde_cycle_states := idle;
	 
	type befunge_instruction_set is (move_left,move_right,move_up,move_down);
	signal instruction : befunge_instruction_set;
	 
    signal grid_data_in    : std_logic_vector(word_size-1 downto 0);
    signal grid_data_out   : std_logic_vector(word_size-1 downto 0);
    signal grid_address  : integer range 0 to (grid_width*grid_height)-1;
    --signal grid_address_y  : integer range 0 to grid_height-1;
    signal grid_load       : std_logic;
    signal grid_store      : std_logic;

    signal dir             : std_logic_vector(1 downto 0);

    signal pc_address_x    : integer range 0 to grid_width-1;
    signal pc_address_y    : integer range 0 to grid_height-1;

    signal pc_skip		   : std_logic;
    signal pc_enable       : std_logic;


    signal stack_ptr       : integer range 0 to stack_size-1;
    signal stack_s0        : std_logic_vector(word_size-1 downto 0);	--Top of stack
    signal stack_s1        : std_logic_vector(word_size-1 downto 0);    --Stack -1
    
begin

data_out <= grid_data_out;
	--this will kick up shit if we want to do read/write from the stack any other time
	--maybe best to keep a copy of these whenever pushes or pops occur?
    stack_s0 <= stack(stack_ptr);
    --stack_s1 <= stack(stack_ptr-1);

    program_counter : befunge_pc
	    generic map
	    (
	    	grid_width => grid_width,
		    grid_height => grid_height
	    )
	    port map
	    (
		    clk    				=> clk,
	        reset 				=> reset,
            address_x 		    => pc_address_x,
            address_y           => pc_address_y,
            dir          		=> dir,
            skip		 		=> pc_skip,
            en                  => pc_enable
	    );
	
	--TODO : this shit needs casted
	grid_address <= to_integer(signed(stack_s0));
	--grid_address_y <= stack_s1;
	
	
	--The grid must handle a write from a store instruction 
	--the grid must handle a read from the pc address
	--the grid must handle a read from a load instruction
	grid_process : process(reset,clk, grid_store,instruction)	
	begin
	    if(reset = '1') then
		    fde_cycle <= idle;
	    else
		    if rising_edge(clk) then
					--set all signals inside this and we're laughing
					--fetch execute cycle that we can use to synchronise read/write signals
					case fde_cycle is
						when idle =>
							grid_load <= '0';
						when fetch => 
							grid_load <= '1';
							fde_cycle <= decode;
						when decode =>
							grid_load <= '0';
							fde_cycle <= execute;
						when execute =>
							grid_load <= '0';
							case instruction is
								when move_left =>
									dir <= "10";
									fde_cycle <= fetch;
								when move_right =>
									dir <= "00";
									fde_cycle <= fetch;
								when move_up =>
									dir <= "01";
									fde_cycle <= fetch;
								when move_down =>
									dir <= "11";
									fde_cycle <= fetch;
								when others =>
									fde_cycle <= idle;
							end case;
							--fed_cycle <= idle;
					end case;
		        --only write the grid when the grid_store flag is enabled
                if (grid_store = '1') then
                    grid(grid_address_x,grid_address_y) <= grid_data_in;
                end if;
                                
                if (grid_load = '1') then
                    grid_data_out <= grid(grid_address);
                else
                    grid_data_out <= grid(pc_address);
                end if;
	                      
		    end if;
	    end if;
	end process;
	
	
	process(reset,clk,instruction,grid_data_out)
	begin
	    if(reset = '1') then
			instruction <= move_right;
	    else
		    if rising_edge(clk) then
				case grid_data_out(7 downto 0) is
					when X"3E" => --move right!!
						instruction <= move_right;
					when X"3C" => --move left!!
						instruction <= move_left;
					when X"5E" => --move up!!
						instruction <= move_up;
					when X"76" => --move down!!
						instruction <= move_down;
					when others =>
						instruction <= move_right;
				end case;
		    end if;
	    end if;
    end process;

end processor_v1;

