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
--(dont)--use work.befunge_pkg.all;--not now anyway

entity befunge_processor_v2 is
	 generic
	 (
					grid_power		   : integer := 3;
					word_size 			: integer := 8;
					instruction_size 	: integer := 16; 
					stack_size 			: integer := 4; 
					grid_width 			: integer := 8; 
					grid_height 		: integer := 8
	);
    port 
	( 
		--DEBUG
					FDE_OUT : OUT std_logic_vector(word_size-1 downto 0);
					INSTRUCTION_OUT : OUT std_logic_vector(word_size-1 downto 0);
					GRID_ADDRESS_OUT : OUT std_logic_vector((grid_power * 2)-1 downto 0);
		--DEBUG
					clk,reset : in   std_logic;
					data_in   : in   std_logic_vector(word_size-1 downto 0);
					data_out  : out  std_logic_vector(word_size-1 downto 0)
	);
end befunge_processor_v2;

architecture processor_v1 of befunge_processor_v2 is

    component befunge_pc_v2 is
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
    end component;
    
    component befunge_alu is
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
    end component;

    component befunge_stack is
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
    end component;



    constant word_zero : std_logic_vector(word_size -1 downto 0) := (others => '0');
	
--((grid_height*grid_width)-1 downto 0)
	type grid_declaration is array(0 to (2**(grid_power*2))-1) of std_logic_vector(word_size-1 downto 0);
	signal grid : grid_declaration := 
	(
	std_logic_vector(to_unsigned(character'pos('>'),word_size)),std_logic_vector(to_unsigned(character'pos('1'),word_size)),std_logic_vector(to_unsigned(character'pos('v'),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),
	std_logic_vector(to_unsigned(character'pos('v'),word_size)),std_logic_vector(to_unsigned(character'pos('>'),word_size)),std_logic_vector(to_unsigned(character'pos('>'),word_size)),std_logic_vector(to_unsigned(character'pos('1'),word_size)),std_logic_vector(to_unsigned(character'pos('+'),word_size)),std_logic_vector(to_unsigned(character'pos(':'),word_size)),std_logic_vector(to_unsigned(character'pos('2'),word_size)),std_logic_vector(to_unsigned(character'pos('-'),word_size)),
	std_logic_vector(to_unsigned(character'pos('_'),word_size)),std_logic_vector(to_unsigned(character'pos('^'),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos('v'),word_size)),
	std_logic_vector(to_unsigned(character'pos('v'),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos('>'),word_size)),
    std_logic_vector(to_unsigned(character'pos('>'),word_size)),std_logic_vector(to_unsigned(character'pos('"'),word_size)),std_logic_vector(to_unsigned(character'pos('h'),word_size)),std_logic_vector(to_unsigned(character'pos('e'),word_size)),std_logic_vector(to_unsigned(character'pos('l'),word_size)),std_logic_vector(to_unsigned(character'pos('l'),word_size)),std_logic_vector(to_unsigned(character'pos('"'),word_size)),std_logic_vector(to_unsigned(character'pos('v'),word_size)),
	std_logic_vector(to_unsigned(character'pos('v'),word_size)),std_logic_vector(to_unsigned(character'pos('"'),word_size)),std_logic_vector(to_unsigned(character'pos('o'),word_size)),std_logic_vector(to_unsigned(character'pos('w'),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos('o'),word_size)),std_logic_vector(to_unsigned(character'pos('"'),word_size)),std_logic_vector(to_unsigned(character'pos('<'),word_size)),
	std_logic_vector(to_unsigned(character'pos('>'),word_size)),std_logic_vector(to_unsigned(character'pos('"'),word_size)),std_logic_vector(to_unsigned(character'pos('r'),word_size)),std_logic_vector(to_unsigned(character'pos('l'),word_size)),std_logic_vector(to_unsigned(character'pos('d'),word_size)),std_logic_vector(to_unsigned(character'pos('"'),word_size)),std_logic_vector(to_unsigned(character'pos('v'),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),
	std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos('v'),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size)),std_logic_vector(to_unsigned(character'pos('<'),word_size)),std_logic_vector(to_unsigned(character'pos(' '),word_size))
	);
	--(others =>(std_logic_vector(to_unsigned(character'pos('<'),word_size))));    --GO EAST!!!
	--grid looks like
	-- +----grid_width--------
	-- |
	-- |
	--grid_height
	-- |
	-- |
	--(x,y) is therefore x+(y*grid_width), which makes hardware a little more complex :(
	
	type fde_cycle_states is (idle,fetch,decode,execute,step,nop, alu, alu2, get, get2, put, put2);
	signal fde_cycle,fde_previous : fde_cycle_states := idle;
	 
    signal grid_data_in,grid_data_out   : std_logic_vector(word_size-1 downto 0);
	 
    signal grid_address    : std_logic_vector((grid_power * 2)-1 downto 0);
    signal grid_load       : std_logic;
    signal grid_store      : std_logic;
    signal grid_access     : std_logic;
    signal grid_access_address : std_logic_vector((grid_power * 2)-1 downto 0);

    signal dir             : std_logic_vector(1 downto 0);

    signal pc_address    : std_logic_vector((grid_power * 2)-1 downto 0);
    signal pc_skip		   : std_logic;
    signal pc_enable       : std_logic;
    
    signal stack_0 : std_logic_vector(word_size-1 downto 0);  
    signal stack_1 : std_logic_vector(word_size-1 downto 0);
    signal stack_i : std_logic_vector(word_size-1 downto 0);   
    signal stack_pop1 : std_logic;      
    signal stack_pop2 : std_logic;   
    signal stack_push : std_logic;  
    signal stack_swap : std_logic;     
    signal stack_en   : std_logic; 
    
    signal alu_a            : std_logic_vector(word_size-1 downto 0);
    signal alu_b            : std_logic_vector(word_size-1 downto 0);
    signal alu_result       : std_logic_vector(word_size-1 downto 0);
    signal alu_op           : std_logic_vector(2 downto 0);
    signal alu_en           : std_logic;
    signal alu_working      : std_logic;
    
    signal string_mode      : std_logic;
begin

	
--DEBUG
	GRID_ADDRESS_OUT <= grid_address;
	data_out 		<= grid_data_out;
--	grid_data_in 	<= data_in;
--DEBUG
	
    alu_inst : befunge_alu
      	generic map
	    (
            word_size
	    )
	    port map
	    (
            clk,         
            reset,        
            alu_a,
            alu_b,
            alu_result,
            alu_op,
            alu_en,
            alu_working         
	    );  
    
    stack : befunge_stack
	    generic map
	    (
	    	8,
            word_size
	    )
	    port map
	    (
            clk,         
            reset,        
            stack_0,    
            stack_1,  
            stack_i,    
            stack_pop1,        
            stack_pop2,         
            stack_push,    
            stack_swap,       
            stack_en          
	    );
        
    alu_a <= stack_0;
    alu_b <= stack_1;
    
    program_counter : befunge_pc_v2
	    generic map
	    (
	    	grid_power
	    )
	    port map
	    (
		    clk,
	        reset,
            pc_address,
            dir,
            pc_skip,
            pc_enable
	    );
	
--Can't do that any more :(
	--TODO : this shit needs casted
	grid_address <= pc_address when grid_access = '0' else grid_access_address;--to_integer(signed(stack_top));
    
	--grid_address_y <= stack_s1;
	
    
	
	--The grid must handle a write from a store instruction 
	--the grid must handle a read from the pc address
	--the grid must handle a read from a load instruction
	grid_process : process(reset,clk)	
        variable push_flag : std_logic := '0';
	begin
	    if(reset = '1') then
		    fde_cycle <= idle;
            stack_pop1 <= '0';        
            stack_pop2 <= '0';        
            stack_push <= '0';
            stack_swap <= '0';
            string_mode <= '0';
            pc_skip <= '0';
            dir <= "00";
            --grid_data_out <= grid(0);
	    else
		    if rising_edge(clk) then
					--set all signals inside this and we're laughing
					--fetch execute cycle that we can use to synchronise read/write signals
					case fde_cycle is
						when nop =>
                            FDE_OUT <= X"04";
							fde_cycle <= fde_previous;
						when idle =>
                            FDE_OUT <= X"00";
							pc_enable <= '0';
                            pc_skip <= '0';
							grid_load <= '0';
                            push_flag := '0';
                            stack_push <= '0';
                            stack_en <= '0';
                            stack_pop1 <= '0';
                            stack_pop2 <= '0';
                            stack_swap <= '0';
                            
                            alu_en <= '0';
                            
							fde_cycle <= fetch;
						when fetch => 
                            FDE_OUT <= X"01";
							grid_load <= '1';
							fde_cycle <= decode;
						when decode =>
                            FDE_OUT <= X"02";
							grid_load <= '0';
							fde_cycle <= execute;
                            
                            
						when execute =>
                            fde_cycle <= step;  --this must be at the start of the case so it can be overriden
                            FDE_OUT <= X"03";
                            
							grid_load <= '0';
                            if (string_mode = '0' ) then
--*********************************************Load Literal************************************************************
                                if ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('0'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(0, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('1'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(1, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('2'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(2, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('3'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(3, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('4'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(4, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('5'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(5, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('6'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(6, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('7'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(7, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('8'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(8, word_size));
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('9'), word_size))) then
                                    stack_i <= std_logic_vector(to_unsigned(9, word_size));
                                    push_flag := '1';
--*********************************************Alu ops*****************************************************************
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('+'), word_size))) then
                                    alu_op <= "000";
                                    alu_en <= '1';
                                    fde_cycle <= alu;
                                    stack_en <= '1';
                                    stack_pop2 <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('-'), word_size))) then
                                    alu_op <= "001";
                                    alu_en <= '1';
                                    fde_cycle <= alu;
                                    stack_en <= '1';
                                    stack_pop2 <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('*'), word_size))) then
                                    alu_op <= "010";
                                    alu_en <= '1';
                                    fde_cycle <= alu;
                                    stack_en <= '1';
                                    stack_pop2 <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('/'), word_size))) then
                                    alu_op <= "011";
                                    alu_en <= '1';
                                    push_flag := '1';
                                    fde_cycle <= alu;
                                    stack_en <= '1';
                                    stack_pop2 <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('%'), word_size))) then
                                    alu_op <= "100";
                                    alu_en <= '1';
                                    push_flag := '1';
                                    fde_cycle <= alu;
                                    stack_en <= '1';
                                    stack_pop2 <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('!'), word_size))) then
                                    alu_op <= "101";
                                    alu_en <= '1';
                                    push_flag := '1';
                                    fde_cycle <= alu;
                                    stack_en <= '1';
                                    stack_pop1 <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('''), word_size))) then
                                    alu_op <= "110";
                                    alu_en <= '1';
                                    push_flag := '1';
                                    fde_cycle <= alu;
                                    stack_en <= '1';
                                    stack_pop1 <= '1';

--*********************************************Control flow************************************************************
								elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('<'), word_size))) then --move left!!
                                    INSTRUCTION_OUT <= X"00";
									dir <= "10";
                                    
									--fde_cycle <= nop;
									--fde_previous <= idle;
								elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('>'), word_size))) then --move right!!
                                    INSTRUCTION_OUT <= X"01";
									dir <= "00";
									--fde_cycle <= nop;
									--fde_previous <= idle;
								elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('^'), word_size))) then --move up!!
                                    INSTRUCTION_OUT <= X"02";
									dir <= "01";
									--fde_cycle <= nop;
									--fde_previous <= idle;
								elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('v'), word_size))) then --move down!!
                                    INSTRUCTION_OUT <= X"03";
									dir <= "11";
									--fde_cycle <= nop;
									--fde_previous <= idle;
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('|'), word_size))) then --verticle switch!!
                                    fde_cycle <= step;
                                    stack_en <= '1';
                                    stack_pop1 <= '1';
                                    
                                    if ( stack_0 = word_zero ) then
                                        dir <= "11";
                                    else
                                        dir <= "01";
                                    end if;
                                    
								elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('_'), word_size))) then --horizontal switch!!
                                    fde_cycle <= step;
                                    stack_en <= '1';
                                    stack_pop1 <= '1';
                                    
                                    if ( stack_0 = word_zero ) then
                                        dir <= "00";
                                    else
                                        dir <= "10";
                                    end if;
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('?'), word_size))) then --move in random direction
                                    fde_cycle <= step;
                                    dir <= "10"; --High quality random number obtained using http://www.random.org/integers/
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos(':'), word_size))) then --duplicate stack
                                    fde_cycle <= step;
                                    
                                    stack_i <= stack_0;
                                    push_flag := '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('\'), word_size))) then --swap stack
                                    fde_cycle <= step;
                                    
                                    stack_en <= '1';
                                    stack_swap <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('$'), word_size))) then --discard stack
                                    fde_cycle <= step;
                                    stack_en <= '1';
                                    stack_pop1 <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('$'), word_size))) then --trampoline
                                    fde_cycle <= step;
                                    pc_skip <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('"'), word_size))) then --String mode
                                    fde_cycle <= step;
                                    string_mode <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('p'), word_size))) then --put
                                    fde_cycle <= put;
                                    
                                    grid_access_address((grid_power * 2)-1 downto ((grid_power*2)/2)) <= stack_0(grid_power-1 downto 0);
                                    grid_access_address(((grid_power * 2)/2)-1 downto 0) <= stack_1(grid_power-1 downto 0);
                                    
                                    grid_access <= '1';
                                    stack_pop2 <= '1';
                                    stack_en <= '1';
                                    
                                elsif ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('g'), word_size))) then --get
                                    fde_cycle <= get;
                                    grid_access <= '1';
                                    stack_pop2 <= '1';
                                    stack_en <= '1';
                                    
                                    grid_access_address((grid_power * 2)-1 downto ((grid_power*2)/2)) <= stack_0(grid_power-1 downto 0);
                                    grid_access_address(((grid_power * 2)/2)-1 downto 0) <= stack_1(grid_power-1 downto 0);
                                    
								else
                                    INSTRUCTION_OUT <= X"04";
									--fde_cycle <= nop;
									--fde_previous <= idle;
                                end if;
                            else -- string mode
                            
                                fde_cycle <= step;
                                if ( grid_data_out = std_logic_vector(to_Unsigned(character'pos('"'), word_size))) then -- end string mode
                                    string_mode <= '0';
                                else
                                    push_flag := '1';
                                    stack_i <= grid_data_out;
                                end if;
                            end if;
                                
                        when alu =>
                            FDE_OUT <= X"04";
                            alu_en <= '0';
                            stack_en <= '0';
                            stack_pop1 <= '0';
                            stack_pop2 <= '0';
                            fde_cycle <= alu2;
                            
                        when alu2 =>
                            FDE_OUT <= X"05";

                            if ( alu_working = '0' ) then
                                fde_cycle <= step;
                                stack_i <= alu_result;
                                push_flag := '1';
                            else 
                                fde_cycle <= alu;
                            end if;
                            
                        when get =>
                            fde_cycle <= get2;
                            stack_en <= '0';
                            stack_pop2 <= '0';
                            grid_load <= '1';
                            
                        when get2 =>
                            fde_cycle <= step;
                            stack_i <= grid_data_out;
                            grid_load <= '0';
                            push_flag := '1';
                            
                        when put =>
                            fde_cycle <= put2;
                            stack_en <= '1';
                            stack_pop1 <= '1';
                            grid_data_in <= stack_0;
                        
                        when put2 =>
                            fde_cycle <= step;
                            stack_en <= '0';
                            stack_pop1 <= '0';
                            grid_store <= '1';
                        
                        when step =>
                            if ( push_flag = '1' ) then
                                stack_en <= '1';
                                stack_push <= '1';
                                push_flag := '0';
                            else
                                stack_en <= '0';
                            end if;
                            
                            stack_pop1 <= '0';
                            stack_pop2 <= '0';
                            stack_swap <= '0';
                            
						    FDE_OUT <= X"06";
							grid_load <= '0';
                            grid_store <= '0';
                            pc_enable <= '1';
							fde_cycle <= idle;
                            grid_access <= '0';
					end case;
                    
                    
                    
		        --only write the grid when the grid_store flag is enabled
                if (grid_store = '1') then
					INSTRUCTION_OUT <= X"AD";
                    grid(to_integer(unsigned(grid_address))) <= grid_data_in;
                end if;
                                
                if (grid_load = '1') then
					INSTRUCTION_OUT <= X"FF";
                    grid_data_out <= grid(to_integer(unsigned(grid_address)));
                --else
                  --  grid_data_out <= grid(pc_address);
                end if;
	                      
		    end if;
	    end if;
	end process;
		
end processor_v1;

