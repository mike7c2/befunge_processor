--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    00:01:24 12/15/2014
-- Design Name:    
-- Module Name:    /media/media/Dropbox/Dropbox/befunge_processor/befunge_stack_tb.vhd
-- Project Name:  befunge_processor
-- Target Device:  
-- Tool versions:  
-- Description:    
-- 
-- VHDL Test Bench Created by ISE for module: befunge_stack
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY befunge_stack_tb IS
END befunge_stack_tb;
 
ARCHITECTURE behavior OF befunge_stack_tb IS 
 
     -- Component Declaration for the Unit Under Test (UUT)
 
     COMPONENT befunge_stack
     PORT(
            clk : IN  std_logic;
            reset : IN  std_logic;
            stack_0_o : OUT  std_logic_vector(7 downto 0);
            stack_1_o : OUT  std_logic_vector(7 downto 0);
            stack_i : IN  std_logic_vector(7 downto 0);
            pop1 : IN  std_logic;
            pop2 : IN  std_logic;
            push : IN  std_logic;
            swap : IN  std_logic;
            en : IN  std_logic
          );
     END COMPONENT;
     

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal stack_i : std_logic_vector(7 downto 0) := (others => '0');
    signal pop1 : std_logic := '0';
    signal pop2 : std_logic := '0';
    signal push : std_logic := '0';
    signal swap : std_logic := '0';
    signal en : std_logic := '0';

 	--Outputs
    signal stack_0_o : std_logic_vector(7 downto 0);
    signal stack_1_o : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
    uut: befunge_stack PORT MAP (
             clk => clk,
             reset => reset,
             stack_0_o => stack_0_o,
             stack_1_o => stack_1_o,
             stack_i => stack_i,
             pop1 => pop1,
             pop2 => pop2,
             push => push,
             swap => swap,
             en => en
          );

    -- Clock process definitions
    clk_process :process
    begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
    end process;
 

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        reset <= '1';
        stack_i <= "00000000";
        swap <= '0';
        push <= '0';
        en <= '0';
        wait for 100 ns;	
        reset <= '0';
        

        wait for clk_period*10;

        wait until falling_edge(clk);
        stack_i <= "11111111";
        push <= '1';
        en <= '1';

        wait until falling_edge(clk);
        stack_i <= "10101010";
        push <= '1';
        en <= '1';
        
        wait until falling_edge(clk);
        stack_i <= "01010101";
        push <= '1';
        en <= '1';
        
        wait until falling_edge(clk);
        stack_i <= "11001100";
        push <= '1';
        en <= '1';
        
        wait until falling_edge(clk);
        stack_i <= "00000000";
        push <= '0';
        swap <= '1';
        en <= '1';
        
        wait until falling_edge(clk);
        stack_i <= "00000000";
        push <= '0';
        swap <= '0';
        en <= '0';
        
        
        
        
        -- insert stimulus here 

        wait;
    end process;

END;
