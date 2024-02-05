library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divide_ip is
    PORT
    (
      aclr		: IN STD_LOGIC ;
      clock		: IN STD_LOGIC ;
      clken		: IN STD_LOGIC ;
      numer		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
      denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      quotient		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
      remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
  end entity;
  
  -- To omit the huge simulation overhead of the real divide ip model this design replaces it.
  architecture arch of divide_ip is
  
  begin
  
    quotient <= std_logic_vector(unsigned(numer) / unsigned(denom));
  
  end architecture arch;