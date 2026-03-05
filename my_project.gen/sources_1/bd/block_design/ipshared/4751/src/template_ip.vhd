-- =====================================================
-- Template IP Core
-- =====================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity template_ip is
    port (
        clk : in std_logic;
        rst : in std_logic;
        dout : out std_logic
    );
end entity template_ip;

architecture rtl of template_ip is

signal counter : unsigned(31 downto 0);

begin

process(clk,rst)
begin
    if rst='1' then
        counter <= (others=>'0');
    elsif rising_edge(clk) then
        counter <= counter + 1;
    end if;
end process;

dout <= counter(31);

end architecture rtl;