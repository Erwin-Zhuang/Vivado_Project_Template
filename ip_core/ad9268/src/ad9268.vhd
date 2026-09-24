-- =====================================================
-- Template IP Core
-- =====================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity ad9268 is
    port (
        clk : in std_logic;
        rst : in std_logic;
        -- signal from fpga, 250MHz
        
        dco_p : in std_logic;
        dco_n : in std_logic;
        data_p : in std_logic_vector(15 downto 0);
        data_n : in std_logic_vector(15 downto 0);
        -- ADC 16-bit differential data inputs

        channel_a : out std_logic_vector(15 downto 0);
        channel_b : out std_logic_vector(15 downto 0);
        -- ADC data output to fpga

        dout : out std_logic
    );
end entity ad9268;

architecture rtl of ad9268 is
signal dco_single : std_logic;
signal data_single : std_logic_vector(15 downto 0);

begin
dco_input : IBUFDS
    port map (
        I  => dco_p,
        IB => dco_n,
        O  => dco_single
    );

data_inputs : for index in data_single'range generate
    data_input : IBUFDS
        port map (
            I  => data_p(index),
            IB => data_n(index),
            O  => data_single(index)
        );
end generate data_inputs;

ddr_inputs : for index in data_single'range generate
    ddr_input : IDDR
        generic map (
            DDR_CLK_EDGE => "OPPOSITE_EDGE"
        )
        port map (
            C  => clk,
            CE => '1',
            D  => data_single(index),
            Q1 => channel_a(index),
            Q2 => channel_b(index),
            R  => rst,
            S  => '0'
        );
end generate ddr_inputs;

end architecture rtl;