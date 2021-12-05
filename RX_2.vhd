library IEEE;
use ieee.std_logic_1164.all; use ieee.numeric_std.all;

-- Se establece la entidad del circuito RX con sus puertos I/O
entity RX_UART is 
	port (
		CLK		: in std_logic;				-- Reloj del FPGA 50MHz
		RST		: in std_logic;				-- Reset del sistema
		RX_serial_in	: in std_logic;				-- Datos que recibe RX de forma serial
		RX_registro	: out std_logic_vector(7 downto 0);	-- 8 bits recibidos
		flag_completo   : out std_logic;
		output		: out std_logic_vector(1 downto 0)
	     );
end entity;

-- Se declara la arqutiectura del circuito
architecture RX of RX_UART is
	type State is (IDLE, Start, Data_incoming, Stop); 		-- Se ponen los estados posibles del proceso repetitivo
	signal current_state, next_state : State;
	signal ciclos_por_bit 		 : integer := 5208;
	signal CLK_counter 		 : integer range 0 to 10000;
	signal bit_index 		 : integer range -1 to 8 		;
	signal RXs_registro		 : std_logic_vector(7 downto 0)		:= "00000000";



BEGIN
		---------------------------------------------------------------------------------------------------------
		process (CLK, RST)
		begin

		 if RST = '1' then                     -- reset asincrónico
		   	current_state <= IDLE;
		 elsif rising_edge(CLK) then
			current_state <= next_state;   -- Se asigna next a current en transición positiva de reloj

		end if;

		end process;
		---------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------
		process (CLK, current_state, RX_serial_in, CLK_counter, bit_index,RST)                   -- lógica combinacional
		begin
			next_state <= current_state;                  				-- el estado siguiente toma el valor del estado actual
			flag_completo <= '0';

			case current_state is

				---
				-- IDLE: Se queda ahí sin recibir, hasta que RX va de high a low va a Start
				when IDLE =>
				  flag_completo <= '0';

				  -- variables en el estado IDLE
				  CLK_counter <= 0;
				  bit_index <= 0;

				  -- que hacer cuando se reciben bits
				  if (RX_serial_in = '0' and RST = '0') then     -- Si pasa de 1 a 0, ir a Start
					next_state <= Start;
				  elsif (RX_serial_in = '1' or RST = '1') then
					next_state <= IDLE;
				  end if;

				---
				-- Start: Se sale del estado hasta que el tiempo de 1 bit haya terminado (5208 ciclos)
				when Start =>

				  flag_completo <= '0';

				 if rising_edge(CLK) then
					CLK_counter <= CLK_counter + 1;
					if CLK_counter =5208 then
						CLK_counter <=0;
					end if;
				 end if;

				if CLK_counter > 5207 then
					next_state <= Data_incoming;
					bit_index <= 0;
				 else
					next_state <= Start;
					
				end if;
				

				---
				-- Data incoming: Cada 5208/2 ciclos (a mitad de la duración del bit) se guarda. Hasta que
				--                hayan pasado 8 bits, se sale del estado
				when Data_incoming =>
				  
					flag_completo <= '0';

					if rising_edge(CLK) then
		  				CLK_counter <= CLK_counter + 1;
					end if;
					
				if bit_index<=7 then
					if CLK_counter < ciclos_por_bit+1 then
					    if CLK_counter = ciclos_por_bit/2 then            -- guardar el bit a la mitad de duración
						RXs_registro(bit_index) <= RX_serial_in;
						--next_state <= Data_incoming;
					    end if;	
					else                                                -- si se llega a la duración del bit, seguir recibiendo y sumar 1 al índice
						bit_index <= bit_index + 1;
						CLK_counter <= 0;
						
					end if;
					next_state <= Data_incoming;
				else 
					
					next_state <= Stop;
				end if;				
					--CLK_counter <= 0;
				  
					
				---
				-- Stop : Completa el ciclo de recibir info. Hasta que pase la duración de 1 bit, se sale del estado y regresa a IDLE
				when Stop =>
				  bit_index <=0;
				  flag_completo <= '1';

				if rising_edge(CLK) then
		  			CLK_counter <= CLK_counter + 1;
				end if;

				  if CLK_counter < (ciclos_por_bit) then
					next_state <= Stop;
				  else
					--CLK_counter <= 0;
					next_state <= IDLE;
				  end if;
				 
				when others =>
				  flag_completo <= '0';
				  next_state <= IDLE;

			end case;
		end process;
		RX_registro <= RXs_registro;

		process (next_state)
		begin
		case next_state is
			when IDLE =>
				output <= "00";
			when Start =>
				output <= "01";
			when Data_incoming =>
				output <= "10";
			when Stop =>
				output <= "11";
		end case;
		end process;


END RX; 
