--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: mux_rdata
--
-- Author: (UAM)
--
-- Description:
--   Multiplexes three input read data buses, in order to provide I/O port
--   data to a processor, as a function of a set of Selection signals (only
--   one of them active at a given moment).
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

entity mux_rdata is
  port (
        -- Input selection bits and input read data buses:
        Sel      : in  std_logic_vector (2 downto 0); -- Selection signals
                                                      --  (only 1 active)
        RDataIn0 : in  std_logic_vector (7 downto 0); -- Input buses
        RDataIn1 : in  std_logic_vector (7 downto 0); --
        RDataIn2 : in  std_logic_vector (7 downto 0); --
        -- Output read data buses:
        RDataOut : out std_logic_vector (7 downto 0)  -- Output bus
       );
end mux_rdata;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of mux_rdata is
  signal sel0Bus : std_logic_vector (7 downto 0); -- Sel(0) replicated 8 times
  signal sel1Bus : std_logic_vector (7 downto 0); -- Sel(1) replicated 8 times
  signal sel2Bus : std_logic_vector (7 downto 0); -- Sel(2) replicated 8 times
begin
  
  sel0Bus <= (others => Sel(0));
  sel1Bus <= (others => Sel(1));
  sel2Bus <= (others => Sel(2));
  
  RDataOut <= (RDataIn0 and sel0Bus) or
              (RDataIn1 and sel1Bus) or
              (RDataIn2 and sel2Bus);
   
end rtl;
