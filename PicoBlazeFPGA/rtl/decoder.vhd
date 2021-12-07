--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: decoder
--
-- Author: Javier Mateos Najari 
--
-- Description:
--   Generates a set of "selection" signals to address different peripherals,
--   according to the address provided (input PortId). Only one selection signal
--   is active (or none if PortId does not correspond to any defined area).
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

entity decoder is
   port (
      -- Port address from microprocessor:
      PortId : in  std_logic_vector (7 downto 0);
      -- Selection output to peripherals (at most one bit is 1):
      Sel    : out std_logic_vector (2 downto 0)
   );
end decoder;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of decoder is

    signal baseAddress: std_logic_vector (4 downto 0);
begin

   process (PortId)
   begin
      baseAddress <= PortId (7 downto 3);
      case baseAddress is
         when "11100"  => -- Base: E0, Peripheral: gen_interrupt
             Sel <= "001";
         when "11101"  => -- Base: E8, Peripheral: sw_btn_leds
             Sel <= "010";
         when "11110"  => -- Base: F0, Peripheral: copro
             Sel <= "100";
         when others => null; -- do nothing
      end case;
   end process;
  
end rtl;

