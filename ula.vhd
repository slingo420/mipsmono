library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
generic(width: positive );
port(
op: in std_logic_vector(2 downto 0); --000:AND , 001:OR , 010:ADD, 110:SUB, 111:SLT
a, b: in std_logic_vector(width-1 downto 0);
zero: out std_logic;
res: out std_logic_vector(width-1 downto 0)
);
end entity;

architecture Behavioral of ULA is
-- COMPLETE (tente usar constantes inicializadas quando for util)
signal slt: std_logic_vector(res'range) := (others => '0');
begin

res <= a and b when op = "000" else
a or b when op = "001" else
std_logic_vector(signed(a) + signed(b)) when op = "010" else
std_logic_vector(signed(a) - signed(b)) when op = "110" else slt;

slt(0) <= '1' when signed(a) < signed(b) else '0';
zero <= '1' when (a=b) or (a="0000000000" or b="0000000000") or ((signed(a) > signed(b)) and op="111") else '0';
end architecture;
