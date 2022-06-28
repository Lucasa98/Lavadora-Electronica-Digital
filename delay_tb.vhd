library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;

entity delay_tb is
end delay_tb;

architecture arch_delay_tb of delay_tb is
    component delay is
        port(
            clk : in std_logic;
            dT : in std_logic_vector(7 downto 0) := "00000000";
            cargar : in std_logic := '0';
            finish : out std_logic := '0'
        );
    end component;

    signal clk, finish : std_logic;
    signal dT : std_logic_vector(7 downto 0);
    signal cargar : std_logic := '0';

begin
    uut : delay
        port map(
            clk => clk,
            dT => dT,
            cargar => cargar,
            finish => finish
        );
    
    clk_process : process
    begin
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
        wait;
    end process;

    excitation_process : process
    begin
        cargar <= '0'; dT <= "00001000";
        wait for 15 ns;
        cargar <= '1';
        wait for 5 ns;
        cargar <= '0';
        wait;
    end process;
end;