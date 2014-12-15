-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS 

  -- Component Declaration
          component befunge_processor_v2 is
	 generic
	 (
					grid_power		   : integer := 3;
					word_size 			: integer := 8;
					instruction_size 	: integer := 16; 
					stack_size 			: integer := 2048; 
					grid_width 			: integer := 80; 
					grid_height 		: integer := 25
	);
    port 
	( 
					FDE_OUT : OUT std_logic_vector(word_size-1 downto 0);
					INSTRUCTION_OUT : OUT std_logic_vector(word_size-1 downto 0);
					GRID_ADDRESS_OUT : OUT std_logic_vector((grid_power * 2)-1 downto 0);
					clk,reset : in   std_logic;
					data_in   : in   std_logic_vector(word_size-1 downto 0);
					data_out  : out  std_logic_vector(word_size-1 downto 0)
	);
end component;

constant 				grid_power 			: integer 	:= 3;
constant 				word_size 			: integer 	:= 8;
constant					instruction_size 	: integer 	:= 16; 
constant					stack_size 			: integer 	:= 2048; 
constant					grid_width 			: integer 	:= 80; 
constant					grid_height 		: integer 	:= 25;
					
signal clk,reset : std_logic;
signal data_in,data_out : std_logic_vector(word_size-1 downto 0);
signal FDE_OUT,INSTRUCTION_OUT : std_logic_vector(word_size-1 downto 0);
signal GRID_ADDRESS_OUT : std_logic_vector((grid_power * 2)-1 downto 0);
  BEGIN

  -- Component Instantiation
          uut: befunge_processor_v2 generic map
	 (
					grid_power 			=> grid_power,
					word_size 			=> word_size,
					instruction_size 	=> instruction_size, 
					stack_size 			=> stack_size,
					grid_width 			=> grid_width, 
					grid_height 		=> grid_height
	)
    port map
	( 
					FDE_OUT => FDE_OUT,
					INSTRUCTION_OUT => INSTRUCTION_OUT,
					GRID_ADDRESS_OUT => GRID_ADDRESS_OUT,
					clk => clk,
					reset => reset,
					data_in   => data_in,
					data_out  => data_out
	);


  --  Test Bench Statements
     clock_process : PROCESS
     BEGIN
		  clk <= '0';
		  wait for 5 ns;
		  clk <= '1';
		  wait for 5 ns;
     END PROCESS clock_process;
	  
	  reset_process : PROCESS
     BEGIN
		  reset <= '1';
		  wait for 50 ns;
		  reset <= '0';
		  wait;
     END PROCESS reset_process;
  --  End Test Bench 

  END behavior;
