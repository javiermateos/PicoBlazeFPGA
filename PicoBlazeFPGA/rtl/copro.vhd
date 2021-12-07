--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: copro
--
-- Author: (UAM)
--
-- Description:
--   Example peripheral for PicoBlaze.
--   It calculates the sum of two products: R = (A*B)+(C*D).
--   Both the input data and the result is 8-bit. Overflow bits are lost.
--   Address map is as follows:
--     0 - A
--     1 - B
--     2 - C
--     3 - D
--     4 - R
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

   entity copro is
      port (
         -- System signals
         Clk       : in  std_logic; -- System clock
         Reset     : in  std_logic; -- System asynchronous reset, active high

         -- Configuration Registers interface
         Sel       : in  std_logic;                     -- If 1, block is accessed
         WriteEn   : in  std_logic;                     -- If 1, access is write
         Address   : in  std_logic_vector (2 downto 0); -- Offset address of reg.
         WData     : in  std_logic_vector (7 downto 0); -- Write data
         RData     : out std_logic_vector (7 downto 0)  -- Read data
      );
   end copro;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of copro is

   -- Registers:
   -- - Input data (read/write):
   signal data0  : std_logic_vector (7 downto 0);
   signal data1  : std_logic_vector (7 downto 0);
   signal data2  : std_logic_vector (7 downto 0);
   signal data3  : std_logic_vector (7 downto 0);
   -- - Result (read only):
   signal result : std_logic_vector (7 downto 0);
  
begin

   -- Writing of registers:
   process (Clk, Reset)
   begin
      if Reset = '1' then
         data0 <= (others => '0');
         data1 <= (others => '0');
         data2 <= (others => '0');
         data3 <= (others => '0');
      elsif Clk'event and Clk = '1' then
         if (Sel = '1') and (WriteEn = '1') then
            case Address is
               when "000" => data0 <= WData;
               when "001" => data1 <= WData;
               when "010" => data2 <= WData;
               when "011" => data3 <= WData;
               when others => null; -- do nothing
            end case;
         end if;
      end if;
   end process;

   -- Reading of registers:
   process (Address, data0, data1, data2, data3, result)
   begin
      case Address is
         when "000"  => RData <= data0;
         when "001"  => RData <= data1;
         when "010"  => RData <= data2;
         when "011"  => RData <= data3;
         when "100"  => RData <= result;
         when others => RData <= (others => '0');
      end case;
   end process;    
 
   -- Calculation:
   process (Clk, Reset)
   begin
      if Reset = '1' then
         result <= (others => '0');
      elsif Clk'event and Clk = '1' then
         result <= conv_std_logic_vector(
                   (unsigned(data0) * unsigned(data1)) + 
                   (unsigned(data2) * unsigned(data3))
                   , 8);
      end if;
   end process;
   
   
end rtl;


 
