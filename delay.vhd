library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay is
    port(
        clk : in std_logic;
        dT : in std_logic_vector(7 downto 0) := "00000000";
        cargar : in std_logic := '0';
        finish : out std_logic := '0'
    );
end delay;

architecture arch_delay of delay is

    signal state : std_logic_vector(7 downto 0) := "00000000";

begin
    process(clk,cargar)
    begin
        if (rising_edge(cargar)) then
            state <= dT;
            finish <= '0';
        elsif (state = "00000000") then
            finish <= '1';
        elsif (rising_edge(clk)) then
            state <= std_logic_vector(unsigned(state)-1);
        end if;
    end process;
end;