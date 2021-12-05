-- Raquel Alejandra Ramírez Valencia
-------------------------------------------------------------------------------------------------
--                                          TX UART                                            --
--   Este código es para el transmisor UART de start bit, 8 bits, stop bit, sin bit de paridad --
-------------------------------------------------------------------------------------------------

-- Se declaran las librerías necesarias

library IEEE;
use ieee.std_logic_1164.all; use ieee.numeric_std.all;

-- Se establece la entidad del circuito TX con sus puertos I/O
entity TX_UART is 
	port (
		CLK		: in std_logic;				-- Reloj del FPGA 50MHz
		RST		: in std_logic;				-- Reset del sistema
		TX_serial	: out std_logic;
		TX_registro	: in std_logic_vector(7 downto 0);	-- 8 bits que inserta el usuario para mandar
		flag_completo   : out std_logic;
		startB		: in std_logic
	     );
end entity;

-- Se declara la arqutiectura del circuito
architecture TX of TX_UART is
	type State is (IDLE, Start, Sending, Stop); 			-- Se ponen los estados posibles del proceso repetitivo
	signal current_state, next_state : State;
	signal ciclos_completo	 : integer := 0;		-- indica si ya pasaron los 5208 ciclos de reloj
	signal CLK_counter 		 : integer range 0 to 5209;
	signal bit_index 		 : integer range 0 to 8 :=0;	-- index de los bits a mandar


BEGIN
		--------------------------------------------------------------------------------------------
		process (CLK, RST)
		begin

		 if RST = '1' then                     -- reset asincrónico
		   	current_state <= IDLE;
		 elsif rising_edge(CLK) then
			current_state <= next_state;   -- Se asigna next a current en transición positiva de reloj
		 end if;

		end process;
		-------------------------------------------------------------------------------------------------
		process (CLK, current_state, RST, startB, CLK_counter, bit_index)                   -- lógica combinacional
		begin
			next_state <= current_state;                  				-- el estado siguiente toma el valor del estado actual
			flag_completo <= '0';

			case current_state is

				---
				-- IDLE: Se queda ahí sin recibir, hasta que RX va de high a low va a Start
				when IDLE =>
					flag_completo <= '0';
					TX_serial <= '1';
					bit_index <= 0;
					if RST='0' and startB='0' then
						next_state <= Start;
						TX_serial <= '0';
					else
						next_state <= IDLE;
					end if;
				when START =>
					flag_completo <= '0';
					TX_serial <= '0';
					if rising_edge(CLK) then		-- reloj para contar 5208 y para actualizar a 0
						CLK_counter <= CLK_counter +1;
						if CLK_counter = 5208 then
							CLK_counter <= 0;
							bit_index <= 0;
						end if;
					end if;
					if CLK_counter < 5208 then		-- mandar a estados
						next_state <= Start;
					else
						next_state <= Sending;
					end if;
				when Sending =>
					flag_completo <= '0';
					if rising_edge(CLK) then			-- reloj para contar 5208 y para actualizar a 0
						CLK_counter <= CLK_counter +1;
						if CLK_counter = 5208 then
							bit_index <= bit_index +1;
							CLK_counter <= 0;
						end if;
					end if;
					if bit_index <8 then				-- mantener en el loop o cambiar estado
						TX_serial <= TX_registro(bit_index);
						next_state <= Sending;
					else
						next_state <= Stop;
						TX_serial <= '1';
					end if;
					if rising_edge(CLK) then
						if bit_index = 8 then
							bit_index <=0;
						end if;
					end if;
				when Stop =>
					flag_completo <= '1';
					TX_serial <= '1';
					if rising_edge(CLK) then			-- reloj para contar
						CLK_counter <= CLK_counter +1;
						if CLK_counter = 5208 then
							bit_index <= bit_index +1;
							CLK_counter <= 0;
						end if;
					end if;
					if CLK_counter <5208 then			-- mandar a loop
						next_state <= Stop;
					else
						next_state <= IDLE;
					end if;
			end case;
		end process;
END TX;