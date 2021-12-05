
library IEEE;
use ieee.std_logic_1164.all; use ieee.numeric_std.all;

-- Se establece la entidad del circuito RX con sus puertos I/O

entity TB_TX_UART is
end TB_TX_UART;

architecture TB of TB_TX_UART is

	signal CLK, RST, TX_serial   : std_logic;
	signal TX_registro	     : std_logic_vector(7 downto 0);
	signal flag_completo 	     : std_logic;
	signal startB		     : std_logic;

BEGIN
	------------------------------------------------------------------------
	D: entity work.TX_UART(TX)
		port map (CLK, RST, TX_serial, TX_registro, flag_completo, startB);
	------------------------------------------------------------------------
	process
	begin
		while Now < 4100 us loop
			-- la señal de reloj de los 50MHz dura 10ns en bajo
			CLK <= '0';
			wait for 10 ns;
			CLK <= '1';
			wait for 10 ns;
		end loop;
		wait;
	end process;
	------------------------------------------------------------------------
	process
	begin
		-- Empieza en IDLE por el reset con una señal en alto
		RST <= '1';
		startB <= '1';	
		wait for 104.16 us;

		-- En flanco de bajada se empieza a mandar datos a puerto serial
		RST <= '0';
		startB <= '1';	
		wait for 104.16 us;

		-- Se manda el Start bit
		RST <= '0';
		startB <= '0';	
		wait for 104.16 us;

		-- Se mandan bits de datos
		TX_registro <= "10010011";
		wait for 833.28 us;
		TX_registro <= "00000000";
		startB <= '1';	
		wait for 104.16 us;
		wait for 50 us;
------------------------------------------------------------------------------------------

		-- En flanco de bajada se empieza a mandar datos a puerto serial
		RST <= '0';
		startB <= '1';	
		wait for 104.16 us;

		-- Se manda el Start bit
		RST <= '0';
		startB <= '0';	
		wait for 104.16 us;

		-- Se mandan bits de datos
		TX_registro <= "10010011";
		wait for 833.28 us;
		TX_registro <= "00000000";
		startB <= '1';	
		wait for 104.16 us;
		wait for 50 us;
		wait;

	end process;
	------------------------------------------------------------------------


END TB;