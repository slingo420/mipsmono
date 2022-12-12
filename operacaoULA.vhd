library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity operacaoULA is
	port(
		ULAOp: in std_logic_vector(1 downto 0);
		Funct: in std_logic_vector(5 downto 0);
		op: out std_logic_vector(2 downto 0)
	);
end entity;

architecture Behavioral of operacaoULA is
begin
    -- COMPLETE
	op <= "010" when ulaop = "00" else
									   "110" when ulaop = "01" else
									   "111" when funct(3) = '1' else
									   "001" when funct(0) = '1' else
									   "000" when funct(2) = '1' else
									   "010" when funct(1) = '0' else
									   "110";
end architecture;