--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: pico_example_tb
--
-- Author: (UAM)
--
-- Description:
--   Simple testbench for pico_example design (a simple demo design running
--   on Spartan-3 Starter Kit Board, S3BOARD, implementing a stopwatch with
--   an embedded PicoBlaze processor).
--   This is not an automatic testbench with good functional coverage,
--   the intended usage is only to be able to start a simulation and
--   to see some waveforms, and to take it as a starting point for a more
--   complete testbench. 
--   The testbench starts the stopwatch and lets some time run.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

entity pico_example_tb is
end pico_example_tb;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture tb of pico_example_tb is

   -- Component declarations
   -------------------------

   -- Unit under test: PicoBlaze design example (stopwatch):
   component pico_example is
      port (
         -- Clock and reset
         Clk    : in std_logic; -- 125 MHz when taken from Zybo's oscillator
         XReset : in std_logic; -- Asynchronous, active high
         -- User interface signals:
         Switch  : in  std_logic_vector (3 downto 0); -- Switches
         Button  : in  std_logic_vector (3 downto 0); -- Pushbuttons
         Led     : out std_logic_vector (3 downto 0)  -- LEDs
      );
   end component pico_example;

   -- Constants:
   -------------
   
   -- Clock period:
   constant CLK_PERIOD  : time := 8 ns;
   constant CLK2_PERIOD : time := 2 * CLK_PERIOD;
   
   -- Length of pushbutton activation:
   constant PUSHB_LENGTH : time := 100 * CLK2_PERIOD;
   
   
   -- Signals:
   -----------
   
   -- Signals (real hardware):
   signal clk    : std_logic;  -- System clock
   signal xReset : std_logic;  -- System reset
   signal sw     : std_logic_vector (3 downto 0); -- Slide switches
   signal btn    : std_logic_vector (3 downto 0); -- Pushbuttons
   signal ld     : std_logic_vector (3 downto 0); -- LEDs
   
   -- Signals (testbench internals):
   signal endSim    : boolean := false; -- End of simulation flag
   signal sigButton : std_logic_vector (3 downto 0) := "0000"; -- Toggle to
                                                -- emulate pushing btn[3:0]

   -- Procedures:
   --------------

   -- Wait for a number of cycles:
   procedure wait_clock_cycles (ncyc : in integer) is
   begin
      for idx in 1 to ncyc loop
         wait until falling_edge(clk);
      end loop;
   end wait_clock_cycles;

   -- Push a button:
   procedure push_a_button (signal sig_button : inout std_logic_vector;
                            index : integer) is
   begin
      sig_button (index) <= not sig_button (index);
   end push_a_button;

  
begin  -- tb

   -- Component instantiation:
   i_pico_example : pico_example
      port map (
         -- Clock and reset
         Clk    => clk,
         XReset => xReset,
         -- User interface signals:
         Switch  => sw (3 downto 0),
         Button  => btn (3 downto 0),
         Led     => ld (3 downto 0)
      );
      
      
   -- Clock generation:
   clock_gen : process
   begin
      while not endSim loop
         clk <= '0';
         wait for CLK_PERIOD/2;
         clk <= '1';
         wait for CLK_PERIOD/2;
      end loop;
      wait;
   end process clock_gen;
  
   -- Pushbutton pushing generation (when requested, generate a high-level for
   -- PUSHB_LENGTH time);
   gen_pb : for idx in 0 to 3 generate
      process
      begin
         btn(idx) <= '0';
         wait on sigButton(idx);
         btn(idx) <= '1';
         wait for PUSHB_LENGTH;
      end process;
   end generate;

   -- Main process:

   process
   begin
      report "SIMULATION START";

      -- Initialize signals, with initial reset:
      xReset <= '1';
      sw     <= "0001";

      -- Wait some cycles and de-assert reset:
      wait_clock_cycles (10);
      xReset <= '0';

      -- Give some time for program initialization:
      wait_clock_cycles (250);
      
      -- Wait some cycles and then push all the buttons in sequence:
      wait_clock_cycles (20);
      for idx in 0 to 3 loop
         push_a_button (sigButton, idx);
         wait_clock_cycles (40);
      end loop;
      -- Wait and push a couple of buttons:
      wait for PUSHB_LENGTH;
      push_a_button (sigButton, 0);
      push_a_button (sigButton, 2);

      -- Wait until buttons are released:
      wait for PUSHB_LENGTH;
      
      -- Push another button repeatedly to see that once the first interrupt appears
      -- it is not passed to the corresponding led, because blinking is active and
		-- now it is the turn to have leds off (we would need to wait 0.1s to see the
		-- leds on again):
      wait_clock_cycles (100);
      for idx in 1 to 4 loop
         push_a_button (sigButton, 1);
         wait for PUSHB_LENGTH;
      end loop;

      report "SIMULATION END";
      endSim <= true;
      wait;
   end process;
    
end tb;
