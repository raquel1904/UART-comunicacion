# UART-comunicacion

# Documentos
TX_1 y TB_TX_1 : Código VHDL principal y testbench para la simulación del transmisor UART

RX_2 y TB_RX_2 : Código VHDL principal y testbench para la simulación del receptor UART

# About
El UART (Universal Asynchronous Receiver/Transmitter ) es usado ampliamente para comunicar a dos dispositivos y puede trabajar con distintos protocolos de comunicación. En el puerto se tienen 2 entradas, Tx y Rx, una es para transmisión y otra para recepción respectivamente, por lo cual es de gran ventaja ya que sólo requiere el uso de dos cables para transmitir y recibir datos.

Primero, se observó con detalle el funcionamiento del receptor y transmisor y posteriormente se escogió una máquina de estado de tipo Moore para cada uno. Una vez que se obtuvo esto, en la programación se incluyeron las variables necesarias para representar las transiciones y los estados y se incluyó un reloj para determinar la velocidad de los bits. 

Para el diseño, se tomaron en cuenta los siguientes parámetros:
Start bit : 1   |   Data frame: 8 bits   |   Parity bit: 0  |   Stop bit:   1   |   Baud rate: 9600
