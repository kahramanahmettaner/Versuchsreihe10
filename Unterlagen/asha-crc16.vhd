--! Standardbibliothek benutzen
library IEEE;
--! Logikelemente verwenden
use IEEE.std_logic_1164.ALL;

--! Numerisches Rechnen ermoeglichen
use IEEE.NUMERIC_STD.ALL;

--! Abgeleitet von:
--! http://www.sunshine2k.de/articles/coding/crc/understanding_crc.html
--! 4.3 General CRC-8 bitwise implementation
--! 5. Extending to CRC-16

entity AshaCRC16 is
    Port ( Clock : in std_logic; --! Taktsignal
           Reset : in  std_logic; --! Resetsignal
           NextData : in  std_logic; --! Sendeanweisung (1 Takt)
           InByte  : in  std_logic_vector (7 downto 0); --! Dateneingang
           CRCOut : out  std_logic_vector (15 downto 0)); --! CRC-Ausgang
end AshaCRC16;

architecture Behavioral of AshaCRC16 is

signal CRC : std_logic_vector(15 downto 0); 	-- internes CRC-Register
signal Counter : unsigned( 2 downto 0); 	-- Zähler
signal MSB : std_logic; 					-- Zwischenspeicher MSB
signal Running : std_logic; 					-- Verarbeitung am laufen

begin

  CRCOut<=CRC;
  MSB <= CRC(15);
  
  --! CRC Behandlung per Schieberegister
  process (Clock)
  begin
    if rising_edge(Clock) then
      if (Reset='1') then
			CRC<="0000000000000000"; 
			Counter <= "000";
			Running <= '0';
		elsif Running='0' AND NextData='1' then
			
			--! move InByte into MSB of 16bit CRC
			CRC(15) <= CRC(15) xor InByte(7);
			CRC(14) <= CRC(14) xor InByte(6);
			CRC(13) <= CRC(13) xor InByte(5);
			CRC(12) <= CRC(12) xor InByte(4);
			CRC(11) <= CRC(11) xor InByte(3);
			CRC(10) <= CRC(10) xor InByte(2);
			CRC(9) <= CRC(9) xor InByte(1);
			CRC(8) <= CRC(8) xor InByte(0);
			
			Counter <= "000";
			Running <= '1';
			
		elsif Running='1' then
			--! alte CRC(15) wird sozusagen verworfen
			--! wenn es 0 ist, überspringen wir es in der Rechnung
			--! wenn es 1 ist, teilen wir mit dem polynom 1 xor 1 = 0
			CRC(15) <= CRC(14);
			CRC(14) <= CRC(13);
			CRC(13) <= CRC(12);
			CRC(12) <= CRC(11) xor MSB;
			CRC(11) <= CRC(10);
			CRC(10) <= CRC(9);
			CRC(9) <= CRC(8);
			CRC(8) <= CRC(7);
			CRC(7) <= CRC(6);
			CRC(6) <= CRC(5);
			CRC(5) <= CRC(4) xor MSB;
			CRC(4) <= CRC(3);
			CRC(3) <= CRC(2);
			CRC(2) <= CRC(1);
			CRC(1) <= CRC(0);
			CRC(0) <= MSB;

			if(Counter="111") then
				Running<='0';
			end if;
			Counter <= Counter + 1;
      end if;
    end if;
  end process;

end Behavioral;

