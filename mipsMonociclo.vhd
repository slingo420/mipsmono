library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPSMonociclo is
	port(
		clock, clock_ram, reset: in std_logic;
		-- externalizando sinais de controle (PARA TESTES)
		RegDst, DvCeq, DvCne, DvI, LerMem, MemParaReg, EscMem, ULAFonte, EscReg: out std_logic;
		ULAOp: out std_logic_vector(1 downto 0);
		-- externalizando saídas das memorias, do banco de registradores e da ULA (PARA TESTES)
		InstrucaoLida, DadoLido, RegLido1, RegLido2, ULAResultado: out std_logic_vector(31 downto 0)
	);
end entity;

architecture structure of MIPSMonociclo is
component datapath is
	port(
	    -- control inputs
	    clock, clock_ram, reset: in std_logic;
		RegDst, DvCeq, DvCne, DvI, LerMem, MemParaReg, EscMem, ULAFonte, EscReg: in std_logic;
		ULAOp: in std_logic_vector(1 downto 0);
        -- control outputs
		Opcode: out std_logic_vector(5 downto 0);
		-- externalizando saídas das memorias, do banco de registradores e da ULA (PARA TESTES)
		InstrucaoLida, DadoLido, RegLido1, RegLido2, ULAResultado: out std_logic_vector(31 downto 0)
	);
end component;
component Controle is
	port(
	    -- control inputs (status)
		Opcode: in std_logic_vector(5 downto 0);
		-- control outputs (commands)
		RegDst, DvCeq, DvCne, DvI, LerMem, MemParaReg, EscMem, ULAFonte, EscReg: out std_logic;
		ULAOp: out std_logic_vector(1 downto 0)
	);
end component;
    -- COMPLETE COM SINAIS INTERNOS
	signal Opcode: std_logic_vector(5 downto 0);
	signal s_RegDst, s_DvCeq, s_DvCne, s_DvI, s_LerMem, s_MemParaReg, s_EscMem, s_ULAFonte, s_EscReg: std_logic; 
	signal s_ulaop: std_logic_vector(1 downto 0);
begin
    controle_inst: Controle
	  port map (
		Opcode     => Opcode,
		RegDst     => s_RegDst,
		DvCeq      => s_DvCeq,
		DvCne      => s_DvCne,
		DvI        => s_DvI,
		LerMem     => s_LerMem,
		MemParaReg => s_MemParaReg,
		EscMem     => s_EscMem,
		ULAFonte   => s_ULAFonte,
		EscReg     => s_EscReg,
		ULAOp      => s_ULAOp
	  );

	datapath_inst: datapath
	  port map (
		clock         => clock,
		clock_ram     => clock_ram,
		reset         => reset,
		RegDst        => s_RegDst,
		DvCeq         => s_DvCeq,
		DvCne         => s_DvCne,
		DvI           => s_DvI,
		LerMem        => s_LerMem,
		MemParaReg    => s_MemParaReg,
		EscMem        => s_EscMem,
		ULAFonte      => s_ULAFonte,
		EscReg        => s_EscReg,
		ULAOp         => s_ULAOp,
		Opcode        => Opcode,
		InstrucaoLida => InstrucaoLida,
		DadoLido      => DadoLido,
		RegLido1      => RegLido1,
		RegLido2      => RegLido2,
		ULAResultado  => ULAResultado
	  );
end architecture;