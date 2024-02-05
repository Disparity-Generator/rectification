 library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fixed_pkg.all;
  use work.float_pkg.all;

  
--! This component calculates, based on the stored transformation matrix, 
--! the corresponding coordinate based on an input coordinate. 
--! It's able to do forward and reverse transformation, thus
--! both matrices have to be passed.
entity RECTIFICATION is
  generic (
    G_LEFT_RANGE  : integer               := 16;
    G_RIGHT_RANGE : integer               := -15;

--! Forward transformation matrix element (1, 1)
G_H_11 : sfixed(16 downto -15) := to_sfixed(-0.01092232, 16, -15);

--! Forward transformation matrix element (1, 1)
G_H_12 : sfixed(16 downto -15) := to_sfixed(0.00013470, 16, -15);

--! Forward transformation matrix element (1, 3)
G_H_13 : sfixed(16 downto -15) := to_sfixed(-0.05616105, 16, -15);

--! Forward transformation matrix element (2, 1)
G_H_21 : sfixed(16 downto -15) := to_sfixed(-0.00032707, 16, -15);

--! Forward transformation matrix element (2, 2)
G_H_22 : sfixed(16 downto -15) := to_sfixed(-0.01072320, 16, -15);

--! Forward transformation matrix element (2, 3)
G_H_23 : sfixed(16 downto -15) := to_sfixed(-0.31203785, 16, -15);

--! Forward transformation matrix element (3, 1)
G_H_31 : sfixed(16 downto -15) := to_sfixed(-0.00000085, 16, -15);

--! Forward transformation matrix element (3, 2)
G_H_32 : sfixed(16 downto -15) := to_sfixed(0.00000003, 16, -15);

--! Forward transformation matrix element (3, 3)
G_H_33 : sfixed(16 downto -15) := to_sfixed(-0.01047320, 16, -15);

--! Reverse transformation matrix element (1, 1)
G_H_INV_11 : sfixed(16 downto -15) := to_sfixed(-91.56217754, 16, -15);

--! Reverse transformation matrix element (1, 2)
G_H_INV_12 : sfixed(16 downto -15) := to_sfixed(-1.14885521, 16, -15);

--! Reverse transformation matrix element (1, 3)
G_H_INV_13 : sfixed(16 downto -15) := to_sfixed(525.21807432, 16, -15);

--! Reverse transformation matrix element (2, 1)
G_H_INV_21 : sfixed(16 downto -15) := to_sfixed(2.57622553, 16, -15);

--! Reverse transformation matrix element (2, 2)
G_H_INV_22 : sfixed(16 downto -15) := to_sfixed(-93.21663066, 16, -15);

--! Reverse transformation matrix element (2, 3)
G_H_INV_23 : sfixed(16 downto -15) := to_sfixed(2763.47553403, 16, -15);

--! Reverse transformation matrix element (3, 1)
G_H_INV_31 : sfixed(16 downto -15) := to_sfixed(0.00744236, 16, -15);

--! Reverse transformation matrix element (3, 2)
G_H_INV_32 : sfixed(16 downto -15) := to_sfixed(-0.00014027, 16, -15);

--! Reverse transformation matrix element (3, 3)
G_H_INV_33 : sfixed(16 downto -15) := to_sfixed(-95.51752670, 16, -15)
  );
  port (
    I_CLOCK              : in    std_logic;
    I_RESET_N            : in    std_logic;

    --! Signal to start a transformation
    I_START              : in    std_logic;

    --! x-component of the base coordinate
    I_X                  : signed(21 downto 0);

    --! x-component of the base coordinate
    I_Y                  : signed(21 downto 0);

    --! Which matrix should be used?
    I_USE_INVERSE        : in    std_logic;

    --! Transformed x-coordinate in **integer** format
    O_X                  : out   integer range -999999 to 999999;

    --! Transformed y-coordinate in **integer** format
    O_Y                  : out   integer range -999999 to 999999;

    O_X_fp : out sfixed(30 downto -29); 
    O_Y_fp : out std_logic_vector(63 downto 0); 

    O_VALID              : out   std_logic;
    O_ACK                : out   std_logic;

    --! If the reverse transformation is used, this signal 
    --! shows if the base coordinate is inside the source image or not.
    O_COORDINATE_INVALID : out   std_logic;

    O_TEST : out std_logic_vector(31 downto 0)
  );
end entity RECTIFICATION;

architecture RTL of RECTIFICATION is

  type t_homography is array(1 to 3, 1 to 3) of sfixed(16 downto -15);

  type t_homogenous_coordinates is array(1 to 3) of sfixed(16 downto -15);

  --! Matrix elements combined to one array, for convenience. 
  constant c_homography                            : t_homography :=
  (
    (
      G_H_11,
      G_H_12,
      G_H_13
    ),
    (
      G_H_21,
      G_H_22,
      G_H_23
    ),
    (
      G_H_31,
      G_H_32,
      G_H_33
    )
  );

  --! Matrix elements combined to one array, for convenience. 
  constant c_homography_inv                        : t_homography :=
  (
    (
      G_H_INV_11,
      G_H_INV_12,
      G_H_INV_13
    ),
    (
      G_H_INV_21,
      G_H_INV_22,
      G_H_INV_23
    ),
    (
      G_H_INV_31,
      G_H_INV_32,
      G_H_INV_33
    )
  );

  type t_states is (IDLE, LOAD_INPUT, CALCULATE_PRODUCTS, CALCULATE_SUMS, RESIZE_SUM, CALCULATE_QUOTIENT, OUTPUT);

  constant c_0 : sfixed(G_LEFT_RANGE downto G_RIGHT_RANGE) := to_sfixed(0, G_LEFT_RANGE, G_RIGHT_RANGE);

  constant c_division_pipeline_length : integer := 64;

  signal r_current_state                           : t_states;
  signal w_next_state                              : t_states;

  signal r_homogenous_coordinates                  : t_homogenous_coordinates;

  signal r_hom_coord_1 : sfixed(33 downto -30) :=  to_sfixed(0, 33, -30);
  signal r_hom_coord_2 : sfixed(33 downto -30) := to_sfixed(0, 33, -30);
  signal r_hom_coord_3 : sfixed(33 downto -30) := to_sfixed(1, 33, -30);
  
  signal r_hom_coord_sum_1 : sfixed(35 downto -30) :=  to_sfixed(0, 35, -30);
  signal r_hom_coord_sum_2 : sfixed(35 downto -30) := to_sfixed(0, 35, -30);
  signal r_hom_coord_sum_3 : sfixed(35 downto -30) := to_sfixed(1, 35, -30);  
  
  signal r_hom_coord_sum_res_1 : sfixed(G_LEFT_RANGE downto G_RIGHT_RANGE) :=  to_sfixed(0, G_LEFT_RANGE, G_RIGHT_RANGE);
  signal r_hom_coord_sum_res_2 : sfixed(G_LEFT_RANGE downto G_RIGHT_RANGE) := to_sfixed(0, G_LEFT_RANGE, G_RIGHT_RANGE);
  signal r_hom_coord_sum_res_3 : sfixed(G_LEFT_RANGE downto G_RIGHT_RANGE) := to_sfixed(1, G_LEFT_RANGE, G_RIGHT_RANGE);  
  
  signal r_hom_coord_div_1 : sfixed(32 downto -31) :=  to_sfixed(0, 32, -31);
  signal r_hom_coord_div_2 : sfixed(32 downto -31) := to_sfixed(0, 32, -31);
  signal r_hom_coord_div_3 : sfixed(32 downto -31) := to_sfixed(1, 32, -31);
  
  --! Stores the first element of the homogenous base coordinate
  signal r_hom_coord_in_1 : sfixed(G_LEFT_RANGE downto G_RIGHT_RANGE) :=  to_sfixed(0, G_LEFT_RANGE, G_RIGHT_RANGE);
  --! Stores the second element of the homogenous base coordinate
  signal r_hom_coord_in_2 : sfixed(G_LEFT_RANGE downto G_RIGHT_RANGE) := to_sfixed(0, G_LEFT_RANGE, G_RIGHT_RANGE);
  --! Stores the third element of the homogenous base coordinate
  signal r_hom_coord_in_3 : sfixed(G_LEFT_RANGE downto G_RIGHT_RANGE) := to_sfixed(1, G_LEFT_RANGE, G_RIGHT_RANGE);

  signal r_use_inverse : std_logic;

  signal r_product_11                              : sfixed(33 downto -30);
  signal r_product_12                              : sfixed(33 downto -30);
  signal r_product_13                              : sfixed(33 downto -30);

  signal r_product_21                              : sfixed(33 downto -30);
  signal r_product_22                              : sfixed(33 downto -30);
  signal r_product_23                              : sfixed(33 downto -30);

  signal r_product_31                              : sfixed(33 downto -30);
  signal r_product_32                              : sfixed(33 downto -30);
  signal r_product_33                              : sfixed(33 downto -30);

  signal r_result_x                                : integer range -999999 to 999999999;
  signal r_result_y                                : integer range -999999 to 999999999;

  --! If one coordinate component is invalid, the whole coordinate won't be valid.
  signal r_x_valid : std_logic;
  signal r_y_valid : std_logic;

  signal r_result_valid                            : std_logic;
  signal r_ack                                     : std_logic;
  signal r_coordinate_invalid                      : std_logic;

  signal r_division_wait_counter : integer range 0 to 70;

  signal r_result_x_slv : std_logic_vector(G_LEFT_RANGE downto 0);
  signal r_result_y_slv : std_logic_vector(G_LEFT_RANGE downto 0);

  signal r_div_enable : std_logic;
  signal r_div_x_a : std_logic_vector(63 downto 0);
  signal r_div_y_a : std_logic_vector(63 downto 0);
  signal r_div_b : std_logic_vector(31 downto 0);
  signal w_div_result_x : std_logic_vector(63 downto 0);
  signal w_div_result_y : std_logic_vector(63 downto 0);
  signal w_div_remain_x : std_logic_vector(31 downto 0);
  signal w_div_remain_y : std_logic_vector(31 downto 0);
  signal r_div_clear : std_logic;

  component divide_ip is
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
  end component;

begin

  div : divide_ip
  port map (
    clock	=> I_CLOCK,
    clken		=> r_div_enable,
    aclr		=> r_div_clear,
    numer	=> r_div_x_a,
    denom	=> r_div_b,
    quotient	=> w_div_result_x,
    remain		=> w_div_remain_x
  );

  div_y : divide_ip
  port map (
    aclr		=> r_div_clear,
    clock	=> I_CLOCK,
    clken		=> r_div_enable,
    numer	=> r_div_y_a,
    denom	=> r_div_b,
    quotient	=> w_div_result_y,
    remain		=> w_div_remain_y
  );

  PROC_ASYNC : process (r_current_state, I_START, r_division_wait_counter) is
  begin

    -- w_ram_address_left <=

    case r_current_state is

      when IDLE =>

        if (I_START = '1') then
          w_next_state <= LOAD_INPUT;
        else
          w_next_state <= IDLE;
        end if;

      when LOAD_INPUT =>
        w_next_state <= CALCULATE_PRODUCTS;

      when CALCULATE_PRODUCTS =>
        w_next_state <= CALCULATE_SUMS;

      when CALCULATE_SUMS =>
        w_next_state <= RESIZE_SUM;
        
       when RESIZE_SUM =>
        w_next_state <= CALCULATE_QUOTIENT;

      when CALCULATE_QUOTIENT =>
        if(r_division_wait_counter = c_division_pipeline_length) then
          w_next_state <= OUTPUT;
        else
          w_next_state <= CALCULATE_QUOTIENT;
        end if;
        
      when OUTPUT =>
        w_next_state <= IDLE;

    end case;

  end process PROC_ASYNC;

  PROC_SYNC : process (I_CLOCK, I_RESET_N) is

  begin

    if (I_RESET_N = '0') then
      r_current_state          <= IDLE;

      r_hom_coord_in_1 <= to_sfixed(0, G_LEFT_RANGE, G_RIGHT_RANGE);
      r_hom_coord_in_2 <= to_sfixed(0, G_LEFT_RANGE, G_RIGHT_RANGE);
      r_hom_coord_in_3 <= to_sfixed(1, G_LEFT_RANGE, G_RIGHT_RANGE);

      r_hom_coord_1 <= to_sfixed(0, 33, -30);
      r_hom_coord_2 <= to_sfixed(0, 33, -30);
      r_hom_coord_3 <= to_sfixed(1, 33, -30);

      r_hom_coord_sum_1 <= to_sfixed(0, 35, -30);
      r_hom_coord_sum_2 <= to_sfixed(0, 35, -30);
      r_hom_coord_sum_3 <= to_sfixed(1, 35, -30);

      r_product_11             <= to_sfixed(0, 33, -30);
      r_product_12             <= to_sfixed(0, 33, -30);
      r_product_13             <= to_sfixed(0, 33, -30);

      r_product_21 <= to_sfixed(0, 33, -30);
      r_product_22 <= to_sfixed(0, 33, -30);
      r_product_23 <= to_sfixed(0, 33, -30);

      r_product_31 <= to_sfixed(0, 33, -30);
      r_product_32 <= to_sfixed(0, 33, -30);
      r_product_33 <= to_sfixed(0, 33, -30);

      r_result_x <= 0;
      r_result_y <= 0;
    elsif (rising_edge(I_CLOCK)) then
      r_current_state <= w_next_state;

      r_result_x <= 0;
      r_result_y <= 0;

      case r_current_state is

        when IDLE =>
          r_hom_coord_in_1 <= to_sfixed(I_X, G_LEFT_RANGE, G_RIGHT_RANGE);
          r_hom_coord_in_2 <= to_sfixed(I_Y, G_LEFT_RANGE, G_RIGHT_RANGE);
          r_hom_coord_in_3 <= to_sfixed(1, G_LEFT_RANGE, G_RIGHT_RANGE);

          r_result_valid           <= '0';
          r_ack                    <= '0';
          r_use_inverse <= '0';
          r_div_enable <= '0';
          r_div_clear <= '1';

        when LOAD_INPUT =>
          r_hom_coord_in_1 <= to_sfixed(I_X, G_LEFT_RANGE, G_RIGHT_RANGE);
          r_hom_coord_in_2 <= to_sfixed(I_Y, G_LEFT_RANGE, G_RIGHT_RANGE);
          r_hom_coord_in_3 <= to_sfixed(1, G_LEFT_RANGE, G_RIGHT_RANGE);

          r_ack                    <= '1';
          r_use_inverse <= I_USE_INVERSE;
          r_result_valid <= '0';
          r_div_clear <= '0';

        when CALCULATE_PRODUCTS =>
          r_result_valid <= '0';
          r_ack          <= '0';

          if (I_USE_INVERSE = '0') then
            r_product_11 <= c_homography(1, 1) * r_hom_coord_in_1;
            r_product_12 <= c_homography(1, 2) * r_hom_coord_in_2;
            r_product_13 <= c_homography(1, 3) * r_hom_coord_in_3;

            r_product_21 <= c_homography(2, 1) * r_hom_coord_in_1;
            r_product_22 <= c_homography(2, 2) * r_hom_coord_in_2;
            r_product_23 <= c_homography(2, 3) * r_hom_coord_in_3;

            r_product_31 <= c_homography(3, 1) * r_hom_coord_in_1;
            r_product_32 <= c_homography(3, 2) * r_hom_coord_in_2;
            r_product_33 <= c_homography(3, 3) * r_hom_coord_in_3;
          else
            r_product_11 <= c_homography_inv(1, 1) * r_hom_coord_in_1;
            r_product_12 <= c_homography_inv(1, 2) * r_hom_coord_in_2;
            r_product_13 <= c_homography_inv(1, 3) * r_hom_coord_in_3;

            r_product_21 <= c_homography_inv(2, 1) * r_hom_coord_in_1;
            r_product_22 <= c_homography_inv(2, 2) * r_hom_coord_in_2;
            r_product_23 <= c_homography_inv(2, 3) * r_hom_coord_in_3;

            r_product_31 <= c_homography_inv(3, 1) * r_hom_coord_in_1;
            r_product_32 <= c_homography_inv(3, 2) * r_hom_coord_in_2;
            r_product_33 <= c_homography_inv(3, 3) * r_hom_coord_in_3;
          end if;

        when CALCULATE_SUMS =>
          r_ack                    <= '0';
          r_result_valid           <= '0';

          r_hom_coord_sum_1 <= r_product_11 + r_product_12 + r_product_13;
          r_hom_coord_sum_2 <= r_product_21 + r_product_22 + r_product_23;
          r_hom_coord_sum_3 <= r_product_31 + r_product_32 + r_product_33;


        when RESIZE_SUM =>
          r_hom_coord_sum_res_1 <= resize(r_hom_coord_sum_1, c_0);
          r_hom_coord_sum_res_2 <= resize(r_hom_coord_sum_2, c_0);
          r_hom_coord_sum_res_3 <= resize(r_hom_coord_sum_3, c_0);

        when CALCULATE_QUOTIENT =>
          if(r_division_wait_counter < c_division_pipeline_length) then
            r_division_wait_counter <= r_division_wait_counter + 1;
          else
            r_division_wait_counter <= 0;
          end if;

          r_ack      <= '0';

          r_div_x_a <= to_stdlogicvector(r_hom_coord_sum_res_1) & "00000000000000000000000000000000";
          r_div_y_a <= to_stdlogicvector(r_hom_coord_sum_res_2) & "00000000000000000000000000000000";

          r_div_b <= to_stdlogicvector(r_hom_coord_sum_res_3);

          r_div_enable <= '1';
          r_result_valid <= '0';
          
          when OUTPUT =>
          
          if((to_integer(signed(w_div_result_x(63 downto 32))) < 0 or to_integer(signed(w_div_result_y(63 downto 32))) < 0 or to_integer(signed(w_div_result_x(63 downto 32))) > 639 or to_integer(signed(w_div_result_y(63 downto 32))) > 479) and r_use_inverse = '1') then
            r_coordinate_invalid <= '1';
            r_result_x           <= 0;
            r_result_y           <= 0;
          else
            r_coordinate_invalid <= '0';
            r_result_x           <= to_integer(signed(w_div_result_x(63 downto 32)));
            r_result_y           <= to_integer(signed(w_div_result_y(63 downto 32)));

          end if;
          r_result_valid <= '1';
          r_div_enable <= '0';

      end case;

    end if;

  end process PROC_SYNC;

  O_Y                  <= r_result_y;
  O_X                  <= r_result_x;

  O_VALID              <= r_result_valid;
  O_ACK                <= r_ack;
  O_COORDINATE_INVALID <= r_coordinate_invalid;

end architecture RTL;
