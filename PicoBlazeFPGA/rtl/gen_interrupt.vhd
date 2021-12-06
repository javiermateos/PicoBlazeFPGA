--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: gen_interrupt
--
-- Author: (UAM)
--
-- Description:
--   Generates an interrupt for PicoBlaze processor once a programmed
--   number of cycles (32-bit). The interrupt is cleared through
--   PicoBlaze's interrupt_ack signal.
--
--   The block is accessed by the microprocessor when the Sel signal is high.
--   Externally this Sel signal is generated according to a global peripheral
--   memory map (base address of this block is defined externally).
--
--   Configuration registers map (offset address):
--      0 - Interrupt Interval, byte 0 (LSB)
--      1 - Interrupt Interval, byte 1
--      2 - Interrupt Interval, byte 2
--      3 - Interrupt Interval, byte 3 (MSB)
--      The Interrupt Interval above is defined as:
--         Number of clock cycles between interrupts = (Interval + 1)
--      All these registers have read/write access.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

entity gen_interrupt is
   port (
      -- System signals
      Clk       : in std_logic;  -- System clock
      Reset     : in std_logic;  -- System reset, active high

      -- Configuration Registers interface
      Sel       : in  std_logic;                     -- If 1, block is accessed
      WriteEn   : in  std_logic;                     -- If 1, access is write
      Address   : in  std_logic_vector (1 downto 0); -- Offset address of reg.
      WData     : in  std_logic_vector (7 downto 0); -- Write data
      RData     : out std_logic_vector (7 downto 0); -- Read data

      -- Interrupt interface:
      InterruptAck : in std_logic;  -- Interrupt acknowledgement from micro
      Interrupt    : out std_logic  -- Interrupt output to micro
   );
end gen_interrupt;
     
--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of gen_interrupt is
   signal interval0 : std_logic_vector (7 downto 0); -- interval, byte 0 (LSByte)
   signal interval1 : std_logic_vector (7 downto 0); -- interval, byte 1
   signal interval2 : std_logic_vector (7 downto 0); -- interval, byte 2
   signal interval3 : std_logic_vector (7 downto 0); -- interval, byte 3 (MSByte)
   signal counter   : std_logic_vector (31 downto 0); -- clock cycle counter
begin
  
   -- Writing of registers holding the interrupt interval configuration:
   process (Clk, Reset)
   begin
      if Reset = '1' then
         interval0 <= (others => '0');
         interval1 <= (others => '0');
         interval2 <= (others => '0');
         interval3 <= (others => '0');
      elsif Clk'event and Clk = '1' then
         if (Sel = '1') and (WriteEn = '1') then
            case Address is
               when "00" => interval0 <= WData;
               when "01" => interval1 <= WData;
               when "10" => interval2 <= WData;
               when "11" => interval3 <= WData;
               when others => null; -- do nothing
            end case;
         end if;
      end if;
   end process;

   -- Reading of registers holding the interrupt interval configuration:
   process (Address, interval0, interval1, interval2, interval3)
   begin
      case Address is
         when "00"   => RData <= interval0;
         when "01"   => RData <= interval1;
         when "10"   => RData <= interval2;
         when others => RData <= interval3;
      end case;
   end process;    
 

   -- Generation of Interrupt output  
   process (Clk, Reset)
      variable interval : std_logic_vector (31 downto 0);
   begin
      if Reset = '1' then
         Interrupt <= '0';
         counter   <= (others => '0');
      elsif Clk'event and Clk = '1' then
         -- Concatenate the interval cfg. regs. to get the 32-bit value:
         interval := interval3 & interval2 & interval1 & interval0;
         -- If interval reached, raise interrupt and clear counter,otherwise count:
         if counter >= interval then
            counter   <= (others => '0');
            if interval /= (31 downto 0 => '0') then
               Interrupt <= '1';
            else
               Interrupt <= '0';
            end if;
         else
            counter <= counter + 1;
            -- Clear interrupt if acknowledgement is received:
            if InterruptAck = '1' then
               Interrupt <= '0';
            end if;
         end if;
      end if;
   end process;

end rtl;

-- Note: an alternative implementation could be:
-- - "interval" declared as a signal, with the full range (31 downto 0)
-- - Write process:
--    if (Sel = '1') and (WriteEn = '1') then
--       interval ((8 * conv_integer(Address)) + 7 downto (8 * conv_integer(Address))) <= WData;
-- - Read process as simply a concurrent assignment:
--    RData <= interval ((8 * conv_integer(Address)) + 7 downto (8 * conv_integer(Address)));
