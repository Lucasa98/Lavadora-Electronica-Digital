library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity Lavarropas is
port (
    Inicio: in std_logic := '0';                --Boton de inicio
    Led_Lav: out std_logic := '0';              --LED
    Led_Enj: out std_logic := '0';              --LED
    Led_Centr: out std_logic := '0';            --LED
	Led_Tapa: out std_logic := '0';             --LED
    Traba_Tapa: out std_logic := '0';           --Traba de tapa
    Perilla: in  STD_LOGIC_VECTOR (2 downto 0) := "000";
    Sen_S4: in std_logic := '0';                --Sensor S4 (Rebalse)
    Sen_S3: in std_logic := '0';                --Sensor S3 (LLeno)
    Sen_S0: in std_logic := '0';                --Sensor S0 (Vacio)
    Valv_Jab: out std_logic := '0';             --Valvula de entrada (Jabon)
    Valv_Suav: out std_logic := '0';            --Valvula de entrada (Suavizante)
    Valv_Agua: out std_logic := '0';            --Valvula de entrada (Agua)
    Valv_Des: out std_logic := '0';             --Valvula de vaciado del lavarropas
    Bomba: out std_logic := '0';                --Bomba de desagote
    Motor_Pot: out std_logic := '0';            --Potencia del motor(0=Lavado,1=Centrifugado)
    Motor_Pow: out std_logic := '0';            --Encendido del motor.
    clk: in std_logic := '0';                    --Clock

    --debug
    termino : out std_logic := '0';
    cont : out std_logic_vector (6 downto 0) := "0000000"
);
end entity; 

architecture lav of Lavarropas is
    signal current_state  : std_logic_vector(4 downto 0);
    signal next_state : std_logic_vector(4 downto 0);

    Constant IDLE         : std_logic_vector(4 downto 0) := "00001";
    Constant LAVADO       : std_logic_vector(4 downto 0) := "00010";
    Constant ENJUAGUE     : std_logic_vector(4 downto 0) := "00100";
    Constant CENTRIFUGADO : std_logic_vector(4 downto 0) := "01000";
    Constant EMERGENCIA   : std_logic_vector(4 downto 0) := "10000";

    --Banderas
    signal contador : integer range 0 to 63 := 0;
    signal etapa : integer range 0 to 2 := 0;
    signal Lavado_con_agua : std_logic := '0';

begin
    --cont <= contador;
    process(next_state)
    begin                            
        current_state <= next_state;
    end process;

    process(clk)
    begin
        cont <= std_logic_vector(to_unsigned(contador,cont'length));
        if rising_edge(clk) then
            if(contador > 0) then
                termino <= '0';
                contador <= contador - 1;
            else
                termino <= '1';
            end if;
            case current_state is
----------------------------------------------------------------------------------------------------
                when IDLE=>
                    Traba_Tapa <= '0';
                    Led_Tapa <= '0';
                    if Inicio = '1' then
                        if Perilla = "001" or Perilla = "011" or Perilla = "101" or Perilla = "111" then
                            next_state <= LAVADO;
                        elsif Perilla = "110" or Perilla = "010" then
                            next_state <= ENJUAGUE;
                        elsif Perilla = "100" then
                            next_state <= CENTRIFUGADO;
                        else
                            next_state <= IDLE;
                        end if;
                    else
                        next_state <= IDLE;
                    end if;
----------------------------------------------------------------------------------------------------
                when LAVADO =>                    
                    --Etapa del lavado
                    if etapa = 0 then
                        Traba_Tapa <= '1';
                        Led_Tapa <= '1';
                        Led_Lav <= '1';

                        if Lavado_con_agua = '0' then
                            Valv_Jab <= '1';
                        else
                            Valv_Agua <= '1';
                        end if;
                        
                        --Control de carga
                        if Sen_S3 = '1' then
                            Valv_Jab <= '0';
                            Valv_Agua <= '0';
                            contador <= 8;
                            etapa <= etapa + 1;
                        end if;
                    elsif contador = 0 and etapa = 1 then
                        --Verificamos que no este perdiendo agua
                        if Sen_S3 = '1' and Sen_S4 = '0' then
                            Motor_Pot <= '0';
                            Motor_Pow <= '1';
                            contador <= 16;
                            etapa <= etapa + 1;
                        else
                            etapa <= 0;
                            next_state <= EMERGENCIA;
                        end if;
                    elsif contador = 0 and etapa = 2 then
                        Motor_Pow <= '0';
                        Valv_Des <= '1';
                        Bomba <= '1';
                        --Se termino de vaciar
                        if Sen_S0 = '0' then
                            Led_Lav <= '0';
                            Bomba <= '0';
                            Valv_Des <= '0';
                            etapa <= 0;
                            if Lavado_con_agua = '0' then
                                Lavado_con_agua <= '1';
                                next_state <= LAVADO;
                            else
                                Lavado_con_agua <= '0';
                                if (Perilla = "011" or Perilla = "111") then
                                    next_state <= ENJUAGUE;
                                elsif Perilla = "101" then
                                    next_state <= CENTRIFUGADO;
                                else
                                    next_state <= IDLE;
                                end if;
                            end if;
                        end if;
                    end if;


                
--------    --------------------------------------------------------------------------------------------
                when ENJUAGUE =>
                    --Etapa del lavado
                    if etapa = 0 then
                        Traba_Tapa <= '1';
                        Led_Tapa <= '1';
                        Led_Enj <= '1';

                        if Lavado_con_agua = '0' then
                            Valv_Suav <= '1';
                        else
                            Valv_Agua <= '1';
                        end if;
                        
                        --Control de carga
                        if Sen_S3 = '1' then
                            Valv_Suav <= '0';
                            Valv_Agua <= '0';
                            contador <= 8;
                            etapa <= etapa + 1;
                        end if;
                    elsif contador = 0 and etapa = 1 then
                        --Verificamos que no este perdiendo agua
                        if Sen_S3 = '1' and Sen_S4 = '0' then
                            Motor_Pot <= '0';
                            Motor_Pow <= '1';
                            contador <= 16;
                            etapa <= etapa + 1;
                        else
                            next_state <= EMERGENCIA;
                            etapa <= 0;
                        end if;
                    elsif contador = 0 and etapa = 2 then
                        Motor_Pow <= '0';
                        Valv_Des <= '1';
                        Bomba <= '1';
                        --Se termino de vaciar
                        if Sen_S0 = '0' then
                            Led_Enj <= '0';
                            Bomba <= '0';
                            Valv_Des <= '0';
                            etapa <= 0;
                            if Lavado_con_agua = '0' then
                                Lavado_con_agua <= '1';
                                next_state <= ENJUAGUE;
                            else
                                Lavado_con_agua <= '0';
                                if (Perilla = "110" or Perilla = "111") then
                                    next_state <= CENTRIFUGADO;
                                else
                                    next_state <= IDLE;
                                end if;
                            end if;
                        end if;
                    end if;
                
--------    --------------------------------------------------------------------------------------------
                when CENTRIFUGADO =>
                    if etapa = 0 then
                        --LEDS
                        Traba_Tapa <= '1';
                        Led_Tapa <= '1';
                        Led_Centr <= '1';
                        
                        --Centrifugado
                        Motor_Pot <= '1';
                        Motor_Pow <= '1';
                        contador <= 16;
                        etapa <= etapa + 1;
                    elsif contador = 0 and etapa = 1 then
                        Motor_Pow <= '0';
                        Led_Centr <= '0';
                        etapa <= 0;
                        next_state <= IDLE;
                    end if;

--------    --------------------------------------------------------------------------------------------
                when EMERGENCIA =>
                    if etapa = 0 then
                        Led_Centr <= '1';
                        Led_Lav <= '1';
                        Led_Enj <= '1';
                        Led_Tapa <= '1';
                        Traba_Tapa <= '1';
                        Motor_Pow <= '0';
                        Valv_Agua <= '0';
                        Valv_Jab <= '0';
                        Valv_Suav <= '0';
                        Valv_Des <= '1';
                        Bomba <= '1';
                        etapa <= etapa + 1;
                    elsif Sen_S0 = '0' and etapa = 1 then
                        Bomba <= '0';
                        Valv_Des <= '0';
                        Led_Centr <= '0';
                        Led_Lav <= '0';
                        Led_Enj <= '0';
                        etapa <= 0;
                        next_state <= IDLE;
                    end if;
                    
                when others =>
                next_state <= IDLE;
            end case;
        end if;   
    end process;

end architecture;