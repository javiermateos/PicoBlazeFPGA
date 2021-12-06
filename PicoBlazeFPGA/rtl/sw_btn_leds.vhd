--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: sw_btn_leds
--
-- Author: (UAM)
--
-- Description:
--   Peripheral for PicoBlaze, providing registers to interface the slide
--   switches, pushbutton and LEDs in the Zybo board.
--   If connected directly to this board, the polarity is as follows:
--   A 1 in a switch means "up" position, a 1 in a pushbutton means "pressed",
--   a 1 turns a LED on.
--
--   Configuration registers map (offset address):
--      0 - Switches (SW0 to SW3) values in corresponding bits (read only),
--             other bits are read as '0'.
--      1 - Pushbuttons (BTN0 to BTN3) values in corresponding bits (read only),
--             other bits are read as '0'.
--      2 - LEDs (LD0 to LD3) values in corresponding bits (read/write),
--             other bits are don't-care-read-as-0.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

   entity sw_btn_leds is
      port (
         -- System signals
         Clk     : in  std_logic; -- System clock
         Reset   : in  std_logic; -- System asynchronous reset, active high

         -- Configuration Registers interface
         Sel     : in  std_logic;                     -- If 1, block is accessed
         WriteEn : in  std_logic;                     -- If 1, access is write
         Address : in  std_logic_vector (1 downto 0); -- Offset address of reg.
         WData   : in  std_logic_vector (7 downto 0); -- Write data
         RData   : out std_logic_vector (7 downto 0); -- Read data

         -- External Input/Output interface:
         Switch  : in  std_logic_vector (3 downto 0); -- Switches
         Button  : in  std_logic_vector (3 downto 0); -- Pushbuttons
         Led     : out std_logic_vector (3 downto 0)  -- LEDs
      );
   end sw_btn_leds;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of sw_btn_leds is

   --  Constants defining register addresses:
   constant ADDR_SWITCHES    : std_logic_vector (1 downto 0) := ;  -- <-- COMPLETAR
   constant ADDR_PUSHBUTTONS : std_logic_vector (1 downto 0) := ;  -- <-- COMPLETAR
   constant ADDR_LEDS        : std_logic_vector (1 downto 0) := ;  -- <-- COMPLETAR

   -- Signal declarations:

   --   Anti-metastability chains for switches and pushbuttons:
   signal switchMeta0 : std_logic_vector (3 downto 0); -- first FF in chain
   signal switchMeta1 : std_logic_vector (3 downto 0); -- second FF in chain
   signal buttonMeta0 : std_logic_vector (3 downto 0); -- first FF in chain
   signal buttonMeta1 : std_logic_vector (3 downto 0); -- second FF in chain
   --   LED value register:
   signal ledsValue   : std_logic_vector (3 downto 0);
  
begin

   -- Anti-metastability chains for inputs
   process (Clk, Reset)
   begin
      if Reset = '1' then
         switchMeta0 <= (others => '0');
         switchMeta1 <= (others => '0');
         buttonMeta0 <= (others => '0');
         buttonMeta1 <= (others => '0');
      elsif Clk'event and Clk = '1' then
         switchMeta0 <= Switch;
         switchMeta1 <= switchMeta0;
         buttonMeta0 <= Button;
         buttonMeta1 <= buttonMeta0;
      end if;
   end process;  
  
   -- User-writable registers: LEDs:
   process (Clk, Reset)                 -- <-- COMPLETAR ESTE PROCESO
   begin
      if Reset = '1' then
      elsif Clk'event and Clk = '1' then
      end if;
   end process;  

   Led <= ledsValue; -- we use "ledsValue" intermediate signal because we want
                     -- to read it below

   -- User-readable registers: all (switches, pushbuttons and programmed led values)
   process (Address, switchMeta1, buttonMeta1, ledsValue)  -- <-- COMPLETAR ESTE PROCESO
   begin
   end process;    
 
end rtl;


 