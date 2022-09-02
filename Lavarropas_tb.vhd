library ieee;
use ieee.std_logic_1164.all;

entity Lavarropas_tb is
end Lavarropas_tb;

architecture arch_Lavarropas_tb of Lavarropas_tb is
    component Lavarropas is
        port(
            Inicio: in std_logic := '0';                --Boton de inicio
            Perilla: in  STD_LOGIC_VECTOR (2 downto 0) := "000";
            Sen_S4: in std_logic := '0';                --Sensor S4 (Rebalse)
            Sen_S3: in std_logic := '0';                --Sensor S3 (LLeno)
            Sen_S0: in std_logic := '0';                --Sensor S0 (Vacio)
            clk: in std_logic := '0';                    --Clock
            Traba_Tapa: out std_logic := '0';           --Traba de tapa
            Valv_Jab: out std_logic := '0';             --Valvula de entrada (Jabon)
            Valv_Suav: out std_logic := '0';            --Valvula de entrada (Suavizante)
            Valv_Agua: out std_logic := '0';            --Valvula de entrada (Agua)
            Valv_Des: out std_logic := '0';             --Valvula de vaciado del lavarropas
            Bomba: out std_logic := '0';                --Bomba de desagote
            Motor_Pot: out std_logic := '0';            --Potencia del motor(0=Lavado,1=Centrifugado)
            Motor_Pow: out std_logic := '0';            --Encendido del motor.
            Led_Lav: out std_logic := '0';              --LED
            Led_Enj: out std_logic := '0';              --LED
            Led_Centr: out std_logic := '0';            --LED
            Led_Tapa: out std_logic := '0';             --LED

            --debug
            termino : out std_logic := '0';
            cont : out std_logic_vector(6 downto 0) := "0000000"
        );
    end component;

    --Entradas
    signal Inicio, Sen_S4, Sen_S3, Sen_S0, clk : std_logic;
    signal Perilla : std_logic_vector(2 downto 0) := "000";
    --Salidas
    signal Traba_Tapa, Valv_Jab, Valv_Suav, Valv_Agua, Valv_Des, Bomba, Motor_Pot, Motor_Pow, Led_Lav, Led_Enj, Led_Centr, Led_Tapa : std_logic;
    
    --CLK
    constant clk_period : time := 1 ns;

    --debug
    signal termino : std_logic;
    signal cont : std_logic_vector(6 downto 0) := "0000000";

begin
    uut : Lavarropas
        port map(
            Inicio => Inicio,
            Sen_S4 => Sen_S4,
            Sen_S3 => Sen_S3,
            Sen_S0 => Sen_S0,
            clk => clk,
            Perilla => Perilla,
            Traba_Tapa => Traba_Tapa,
            Valv_Jab => Valv_Jab,
            Valv_Suav => Valv_Suav,
            Valv_Agua => Valv_Agua,
            Valv_Des => Valv_Des,
            Bomba => Bomba,
            Motor_Pot => Motor_Pot,
            Motor_Pow => Motor_Pow,
            Led_Lav => Led_Lav,
            Led_Enj => Led_Enj,
            Led_Centr => Led_Centr,
            Led_Tapa => Led_Tapa,

            termino => termino,
            cont => cont
        );
    
    clk_process : process
    variable contadorTB : integer range 0 to 10000 := 0;
    begin
        contadorTB := contadorTB + 1;
        if contadorTB < 2000 then 
            clk <= '0';
            wait for clk_period/2;  --for 0.5 ns signal is '0'.
            clk <= '1';
            wait for clk_period/2;  --for next 0.5 ns signal is '1'.
        else
            wait;
        end if;
    end process;

    excitation_process : process
    begin
        Inicio <= '0'; Sen_S4 <= '0'; Sen_S3 <= '0'; Sen_S0 <= '0'; Perilla <= "000";
        
        --No deberia hacer nada
        wait for 10 ns;
        Inicio <= '1'; wait for 5 ns; Inicio <= '0';

        --Lavado completo
        wait for 10 ns;
        Perilla <= "111"; wait for 1 ns;
        Inicio <= '1'; wait for 5 ns; Inicio <= '0';

        --LAVADO
        wait for 50 ns;
        Sen_S0 <= '1';      --Se llena con jabon hasta el S0
        wait for 50 ns;
        Sen_S3 <= '1';      --Se llena con jabon hasta el S3
        wait for 20 ns;     --Trabaja el motor
        Sen_S3 <= '0';
        wait for 20 ns;
        Sen_S0 <= '0';      --Se vacia hasta S0;
        wait for 10 ns;     --Se llena con agua hasta S0
        Sen_S0 <= '1';
        wait for 10 ns;     --Se llena con agua hasta S3
        Sen_S3 <= '1';
        wait for 26 ns;     --Trabaja el motor
        Sen_S3 <= '0';
        wait for 10 ns;
        Sen_S0 <= '0';      --Se vacia hasta S0;
        --ENJUAGUE
        wait for 50 ns;
        Sen_S0 <= '1';     --Se llena con suavizante hasta el S0
        wait for 50 ns;
        Sen_S3 <= '1';     --Se llena con suavizante hasta el S3
        wait for 26 ns;     --Trabaja el motor
        Sen_S3 <= '0';
        wait for 10 ns;
        Sen_S0 <= '0';     --Se vacia hasta S0;
        wait for 10 ns;     --Se llena con agua hasta S0
        Sen_S0 <= '1';
        wait for 10 ns;     --Se llena con agua hasta S3
        Sen_S3 <= '1';
        wait for 26 ns;     --Trabaja el motor
        Sen_S3 <= '0';
        wait for 10 ns;
        Sen_S0 <= '0';     --Se vacia hasta S0;
        --CENTRIFUGADO
        wait for 50 ns;     --Centrifuga 26 ciclos


        --EMERGENCIA
        wait for 10 ns;
        Perilla <= "001"; wait for 1 ns;
        Inicio <= '1'; wait for 5 ns; Inicio <= '0';
        wait for 50 ns;
        Sen_S0 <= '1';      --Se llena con jabon hasta el S0
        wait for 50 ns;
        Sen_S3 <= '1';      --Se llena con jabon hasta el S3
        Sen_S4 <= '1';      --Rebalsa
        wait for 40 ns;     --Cambia a Emergencia
        Sen_S3 <= '0';
        Sen_S4 <= '0';
        wait for 20 ns;
        Sen_S0 <= '0';
        wait;
    end process;
end;