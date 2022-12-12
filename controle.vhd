library ieee;
use ieee.std_logic_1164.all;

entity controle is
	port(
	    -- control inputs (status)
		Opcode: in std_logic_vector(5 downto 0);
		-- control outputs (commands)
		RegDst, DvCeq, DvCne, DvI, LerMem, MemParaReg, EscMem, ULAFonte, EscReg: out std_logic;
		ULAOp: out std_logic_vector(1 downto 0)
	);
end entity;

architecture comportamento of controle is
    -- COMPLETE (tentar usar constants)
	constant r: std_logic_vector(5 downto 0) := "000000";
	constant lw: std_logic_vector(5 downto 0) := "100011";
	constant sw: std_logic_vector(5 downto 0) := "101011";
	constant beq: std_logic_vector(5 downto 0) := "000100"; 
	constant bne:std_logic_vector(5 downto 0) := "000101";
	constant jump: std_logic_vector(5 downto 0) := "000010";
	constant addi: std_logic_vector(5 downto 0) := "001000";
begin
    -- COMPLETE
	regdst <= '1' when opcode = r else '0';
	dvceq <= '1' when opcode = beq else '0';
	dvcne <= '1' when opcode = bne else '0';
	dvi <= '1' when opcode = jump else '0';
	lermem <= '1' when opcode = lw else '0';
	memparareg <= '1' when opcode = lw else '0';
	escmem <= '1' when opcode = sw else '0';
	ulafonte <= '1' when opcode = lw or opcode = sw else '0';
	escreg <= '1' when opcode = lw or opcode = r or opcode = addi else '0';

	ULAOp(1) <= '1' when opcode = r or opcode = jump or opcode = addi else '0';
	ULAOp(0) <= '1' when opcode = beq or opcode = bne else '0';
	
end architecture;



-- std_logic_vector --> unsigned 
-- unsigned(a)

-- unsigned --> std_logic_vector
-- std_logic_vector(a)

-- integer --> std_logic_vector
-- std_logic_vecor(to_unsigned(n, a'length))

