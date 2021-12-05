library IEEE;
use ieee.std_logic_1164.all; use ieee.numeric_std.all;

-- Se establece la entidad del circuito RX con sus puertos I/O

entity TB_RX_UART is
end TB_RX_UART;

architecture TB of TB_RX_UART is

	signal CLK, RST, RX_serial_in: std_logic;
	signal RX_registro	     : std_logic_vector(7 downto 0);
	signal flag_completo 	     : std_logic;

BEGIN
	------------------------------------------------------------------------
	D: entity work.RX_UART(RX)
		port map (CLK, RST, RX_serial_in, RX_registro, flag_completo);
	------------------------------------------------------------------------
	process
	begin
		while Now < 4000 us loop
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
		RX_serial_in <= '1';	
		wait for 104.16 us;

		-- En flanco de bajada se empieza a mandar datos a puerto serial
		RST <= '0';
		RX_serial_in <= '1';	
		wait for 104.16 us;

		-- Se manda el Start bit
		RST <= '0';
		RX_serial_in <= '0';	
		wait for 104.16 us;

		-- Se mandan bits de datos
		RX_serial_in <= '1';		-- 0
		wait for 104.16 us;	

		RX_serial_in <= '0';		-- 1
		wait for 104 us;	
		RX_serial_in <= '1';		-- 2
		wait for 104 us;	
		RX_serial_in <= '0';		-- 3
		wait for 104 us;	
		RX_serial_in <= '0';		-- 4
		wait for 104 us;	
		RX_serial_in <= '0';		-- 5
		wait for 104 us;	
		RX_serial_in <= '1';		-- 6
		wait for 104 us;	
		RX_serial_in <= '1';		-- 7
		wait for 104 us;	

		-- Se manda el Stop bit
		RX_serial_in <= '1';	
		wait for 104 us;
		wait;

	end process;
	------------------------------------------------------------------------


END TB;
