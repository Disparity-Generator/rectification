library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;
  use ieee.std_logic_textio.all;
  use work.fixed_pkg.all;

entity TB_RECTIFICATION is -- keine Schnittstellen
end entity TB_RECTIFICATION;

architecture TESTBENCH of TB_RECTIFICATION is

  component RECTIFICATION is
    generic (
      -- G_H_11     : sfixed(16 downto -13) := to_sfixed(-0.0083, 16, -13);
      -- G_H_12     : sfixed(16 downto -13) := to_sfixed(0.00005902, 16, -13);
      -- G_H_13     : sfixed(16 downto -13) := to_sfixed(-0.9984, 16, -13);

      -- G_H_21     : sfixed(16 downto -13) := to_sfixed(-0.00015862, 16, -13);
      -- G_H_22     : sfixed(16 downto -13) := to_sfixed(-0.0083, 16, -13);
      -- G_H_23     : sfixed(16 downto -13) := to_sfixed(-0.0547, 16, -13);

      -- G_H_31     : sfixed(16 downto -13) := to_sfixed(-0.00000043221, 16, -13);
      -- G_H_32     : sfixed(16 downto -13) := to_sfixed(-0.000000061932, 16, -13);
      -- G_H_33     : sfixed(16 downto -13) := to_sfixed(-0.0081, 16, -13);

      -- G_H_INV_11 : sfixed(16 downto -13) := to_sfixed(-121.042, 16, -13);
      -- G_H_INV_12 : sfixed(16 downto -13) := to_sfixed(-0.9748, 16, -13);
      -- G_H_INV_13 : sfixed(16 downto -13) := to_sfixed(14918, 16, -13);

      -- G_H_INV_21 : sfixed(16 downto -13) := to_sfixed(2.2774, 16, -13);
      -- G_H_INV_22 : sfixed(16 downto -13) := to_sfixed(-120.8159, 16, -13);
      -- G_H_INV_23 : sfixed(16 downto -13) := to_sfixed(534.7015, 16, -13);

      -- G_H_INV_31 : sfixed(16 downto -13) := to_sfixed(0.0064, 16, -13);
      -- G_H_INV_32 : sfixed(16 downto -13) := to_sfixed(0.00097522, 16, -13);
      -- G_H_INV_33 : sfixed(16 downto -13) := to_sfixed(-124.1868, 16, -13)

      --

      G_H_11 : sfixed(16 downto -15) := to_sfixed(-0.01185545, 16, -15);
      G_H_12 : sfixed(16 downto -15) := to_sfixed(0.00012253, 16, -15);
      G_H_13 : sfixed(16 downto -15) := to_sfixed(-0.05225939, 16, -15);
      
      G_H_21 : sfixed(16 downto -15) := to_sfixed(-0.00032235, 16, -15);
      G_H_22 : sfixed(16 downto -15) := to_sfixed(-0.01148006, 16, -15);
      G_H_23 : sfixed(16 downto -15) := to_sfixed(-0.27270534, 16, -15);
      
      G_H_31 : sfixed(16 downto -15) := to_sfixed(-0.00000088, 16, -15);
      G_H_32 : sfixed(16 downto -15) := to_sfixed(-0.00000003, 16, -15);
      G_H_33 : sfixed(16 downto -15) := to_sfixed(-0.01118997, 16, -15);
      
      G_H_INV_11 : sfixed(16 downto -15) := to_sfixed(-84.35593253, 16, -15);
      G_H_INV_12 : sfixed(16 downto -15) := to_sfixed(-0.90129435, 16, -15);
      G_H_INV_13 : sfixed(16 downto -15) := to_sfixed(415.92396948, 16, -15);
      
      G_H_INV_21 : sfixed(16 downto -15) := to_sfixed(2.21045981, 16, -15);
      G_H_INV_22 : sfixed(16 downto -15) := to_sfixed(-87.08869734, 16, -15);
      G_H_INV_23 : sfixed(16 downto -15) := to_sfixed(2112.07307591, 16, -15);
      
      G_H_INV_31 : sfixed(16 downto -15) := to_sfixed(0.00665988, 16, -15);
      G_H_INV_32 : sfixed(16 downto -15) := to_sfixed(0.00027081, 16, -15);
      G_H_INV_33 : sfixed(16 downto -15) := to_sfixed(-89.40344283, 16, -15)
    );
    -- 000000110011011100100001110101
    -- 000110110011001100110011001100
    port (
      I_CLOCK              : in    std_logic;
      I_RESET_N            : in    std_logic;

      I_START              : in    std_logic;
      I_X                  : signed(21 downto 0);
      I_Y                  : signed(21 downto 0);
      I_USE_INVERSE        : in    std_logic;

      O_X_fp : out sfixed(33 downto -26); 
      O_Y_fp : out std_logic_vector(63 downto 0); 

      O_X                  : out   integer range -999999 to 999999;
      O_Y                  : out   integer range -999999 to 999999;
      O_VALID              : out   std_logic;
      O_ACK                : out   std_logic;
      O_COORDINATE_INVALID : out   std_logic
    );
  end component;

  component SDRAM_CONTROLLER is
    generic (
      G_CLK_FREQ           : real := 50.0;

      G_ADDR_WIDTH         : natural := 25;

      G_SDRAM_ADDR_WIDTH   : natural := 13;
      G_SDRAM_DATA_WIDTH   : natural := 32;
      G_SDRAM_COL_WIDTH    : natural := 10;
      G_SDRAM_ROW_WIDTH    : natural := 13;
      G_SDRAM_BANK_WIDTH   : natural := 2;

      G_CAS_LATENCY        : natural := 2;

      G_BURST_LENGTH       : natural := 1;

      G_WRITE_BURST_MODE   : std_logic := '0';

      G_T_DESL             : real := 200000.0;
      G_T_MRD              : real := 14.0;
      G_T_RC               : real := 70.0;
      G_T_RCD              : real := 20.0;
      G_T_RP               : real := 20.0;
      G_T_WR               : real := 15.0;
      G_T_REFI             : real := 7812.5;
      G_USE_AUTO_PRECHARGE : std_logic := '0'
    );
    port (
      I_RESET_N           : in    std_logic := '1';
      I_CLOCK             : in    std_logic;
      I_ADDRESS           : in    unsigned(G_ADDR_WIDTH - 1 downto 0);
      I_DATA              : in    std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0);
      I_WRITE_ENABLE      : in    std_logic;
      I_REQUEST           : in    std_logic;
      O_ACKNOWLEDGE       : out   std_logic;
      O_VALID             : out   std_logic;
      O_Q                 : out   std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0);
      O_SDRAM_A           : out   unsigned(G_SDRAM_ADDR_WIDTH - 1 downto 0);
      O_SDRAM_BA          : out   unsigned(G_SDRAM_BANK_WIDTH - 1 downto 0);
      IO_SDRAM_DQ         : inout std_logic_vector(G_SDRAM_DATA_WIDTH - 1 downto 0);
      O_SDRAM_CKE         : out   std_logic;
      O_SDRAM_CS          : out   std_logic;
      O_SDRAM_RAS         : out   std_logic;
      O_SDRAM_CAS         : out   std_logic;
      O_SDRAM_WE          : out   std_logic;
      O_SDRAM_DQML        : out   std_logic;
      O_SDRAM_DQMH        : out   std_logic;
      O_SDRAM_INITIALIZED : out   std_logic
    );
  end component sdram_controller;

  component PLL is
    port (
      CLK_CLK            : in    std_logic                     := 'X';
      RESET_RESET_N      : in    std_logic                     := 'X';
      CLK_SYSTEM_CLK     : out   std_logic;
      CLK_SDRAM_CLK      : out   std_logic
    );
  end component pll;

  component SDRAM_DE2_115_WRAPPER is
    port (
      I_CLOCK             : in    std_logic;

      I_SDRAM_A           : in    unsigned(13 - 1 downto 0);
      I_SDRAM_BA          : in    unsigned(2 - 1 downto 0);
      IO_SDRAM_DQ         : inout std_logic_vector(32 - 1 downto 0);
      I_SDRAM_CKE         : in    std_logic;
      I_SDRAM_CS          : in    std_logic;
      I_SDRAM_RAS         : in    std_logic;
      I_SDRAM_CAS         : in    std_logic;
      I_SDRAM_WE          : in    std_logic;
      I_SDRAM_DQML        : in    std_logic;
      I_SDRAM_DQMH        : in    std_logic
    );
  end component;

  procedure discard_separator (
    variable line_pointer : inout line
  ) is

    variable dump : string(1 to 1);

  begin

    read(line_pointer, dump);

  end procedure;

  procedure get_integer (
    variable line_pointer : inout line;
    variable int_out      : out integer) is

    variable v_int_out           : integer;
    variable v_separator_discard : string(1 to 1);

  begin

    read(line_pointer, v_int_out);
    int_out := v_int_out;
    discard_separator(line_pointer);

  end procedure;

  procedure get_integer (
    variable line_pointer : inout line;
    signal int_out        : out std_logic_vector) is

    variable v_int_out           : integer;
    variable v_separator_discard : string(1 to 1);

  begin

    read(line_pointer, v_int_out);
    int_out <= std_logic_vector(to_unsigned(v_int_out, int_out'length));
    discard_separator(line_pointer);

  end procedure;

  constant c_original_image_width                                 : integer := 640;
  constant c_original_image_height                                : integer := 480;

  type image_memory is ARRAY (0 to c_original_image_height - 1, 0 to c_original_image_width - 1) of std_logic_vector(7 downto 0);

  signal source_image                                             : image_memory;
  signal result_image                                             : image_memory;

  -- Ports in Richtung nutzende Komponente
  signal clk_tb_s                                                 : std_logic;
  signal w_clk_system                                             : std_logic;
  signal w_clk_sdram                                              : std_logic;

  signal w_sdram_addr                                             : std_logic_vector(24 downto 0);
  signal w_sdram_rdval                                            : std_logic;
  signal w_sdram_we_n                                             : std_logic;
  signal w_sdram_we                                               : std_logic;
  signal w_sdram_writedata                                        : std_logic_vector(31 downto 0);
  signal w_sdram_ack                                              : std_logic;
  signal w_sdram_readdata                                         : std_logic_vector(31 downto 0);
  signal w_sdram_req                                              : std_logic;

  signal w_reset_n                                                : std_logic;

  constant c_filename_image1                                      : string := "SOURCE.csv";
  constant c_filename_out                                         : string := "TARGET.ppm";

  constant c_left_range                                           : integer := 16;
  constant c_right_range                                          : integer := -13;

  constant c_0 : signed(21 downto 0) := to_signed(0, 22);
  constant c_1 : signed(21 downto 0) := to_signed(1, 22);
  constant c_479 : signed(21 downto 0) := to_signed(479, 22);
  constant c_639 : signed(21 downto 0) := to_signed(639, 22);

  file   fptr                                                     : text;
  signal test_int                                                 : integer;
  -- signal test_string : string(1 to 1);

  signal r_line_opened                                            : std_logic := '0';

  type t_states is (
    CLOSE_FILE,
    WAIT_FOR_READY,
    STORE_ORIGINAL_IMAGE,
    CALCULATE_LEFT_UPPER,
    CALCULATE_RIGHT_UPPER,
    CALCULATE_LEFT_LOWER,
    CALCULATE_RIGHT_LOWER,
    CALCULATE_TARGET_AREA,
    LOAD_OLD_COORDINATE,
    LOAD_OLD_PIXEL,
    WRITE_NEW_PIXEL,
    WRITE_TO_FILE,
    FINISHED
  );

  signal w_next_state                                             : t_states;
  signal r_current_state                                          : t_states := CLOSE_FILE;

  -- Current column and of the first image to load
  -- Row 0 <= x < block_size
  -- Values get reset after each load
  signal r_image_load_col                                         : integer := 0;
  signal r_image_load_row                                         : integer := 0;

  signal r_image2_load_col                                        : integer := 0;
  signal r_image2_load_row                                        : integer := 0;
  -- Current row in the images
  signal r_image_row_pointer                                      : integer := 0;

  signal w_start_rectification                                    : std_logic;
  signal w_i_x                                                    : signed (21 downto 0);
  signal w_i_y                                                    : signed (21 downto 0);
  signal w_use_inverse                                            : std_logic;
  signal w_o_x                                                    : integer range -999999 to 999999;
  signal w_o_y                                                    : integer range -999999 to 999999;
  signal w_rect_valid                                             : std_logic;
  signal w_rect_ack                                               : std_logic;
  signal w_coordinate_invalid                                     : std_logic;

  signal w_dram_addr                                              : unsigned(12 downto 0);
  signal w_dram_ba                                                : unsigned(1 downto 0);
  signal w_dram_cas_n                                             : std_logic;
  signal w_dram_clk                                               : std_logic;
  signal w_dram_cke                                               : std_logic;
  signal w_dram_we_n                                              : std_logic;
  signal w_dram_cs_n                                              : std_logic;
  signal w_dram_dq                                                : std_logic_vector(31 downto 0);
  signal w_dram_ras_n                                             : std_logic;
  signal w_dram_dqml                                              : std_logic_vector(1 downto 0);
  signal w_dram_dqmh                                              : std_logic_vector(1 downto 0);
  signal w_dram_dqml_0                                            : std_logic;
  signal w_dram_dqml_1                                            : std_logic;
  signal w_dram_dqmh_0                                            : std_logic;
  signal w_dram_dqmh_1                                            : std_logic;

  signal r_original_image_write_pointer                           : integer range 0 to 307200;
  signal r_original_image_read_pointer                            : integer range 0 to 307200;

  signal r_pixel                                                  : std_logic_vector(7 downto 0);

  signal w_dqml                                                   : std_logic;
  signal w_dqmh                                                   : std_logic;
  signal w_sdram_initialized                                      : std_logic;

  constant c_bounding_box_left_x_offset                           : integer range -639 to 639 := 0;
  constant c_bounding_box_right_x_offset                          : integer range -639 to 639 := 0;
  constant c_bounding_box_upper_y_offset                          : integer range -479 to 479 := 0;
  constant c_bounding_box_lower_y_offset                          : integer range -479 to 479 := 0;

  signal r_bounding_box_ready                                     : std_logic := '0';
  signal r_bounding_box_w                                         : integer range 0 to 99999;
  signal r_bounding_box_h                                         : integer range 0 to 99999;

  signal r_bounding_box_left_upper_x                              : integer range -999999 to 999999;
  signal r_bounding_box_left_upper_y                              : integer range -999999 to 999999;

  signal r_bounding_box_left_lower_x                              : integer range -999999 to 999999;
  signal r_bounding_box_left_lower_y                              : integer range -999999 to 999999;

  signal r_bounding_box_right_upper_x                             : integer range -999999 to 999999;
  signal r_bounding_box_right_upper_y                             : integer range -999999 to 999999;

  signal r_bounding_box_right_lower_x                             : integer range -999999 to 999999;
  signal r_bounding_box_right_lower_y                             : integer range -999999 to 999999;

  signal r_bounding_box_max_x                                     : integer range -999999 to 999999;
  signal r_bounding_box_max_y                                     : integer range -999999 to 999999;

  signal r_target_area_y_start                                    : signed(21 downto 0);
  signal r_target_area_y_end                                      : signed(21 downto 0);
  signal r_target_area_x_start                                    : signed(21 downto 0);
  signal r_target_area_x_end                                      : signed(21 downto 0);

  signal r_current_new_x                                          : signed(21 downto 0);
  signal r_current_new_y                                          : signed(21 downto 0);
  signal r_current_new_write_col                                  : integer range 0 to 639          := 0;
  signal r_current_new_write_row                                  : integer range 0 to 479          := 0;

  signal r_current_original_write_col                             : integer range 0 to 640;
  signal r_current_original_write_row                             : integer range 0 to 480;

  signal r_next_new_x                                             : signed(21 downto 0);
  signal r_next_new_y                                             : signed(21 downto 0);

  signal r_current_old_x                                          : integer range 0 to 639 := 0;
  signal r_current_old_y                                          : integer range 0 to 479 := 0;
  signal r_old_coordinate_invalid : std_logic;

  signal w_new_coordinate_lut                                     : integer range 0 to 307200;
  signal w_old_coordinate_lut                                     : integer range 0 to 307200;

  signal r_old_pixel                                              : std_logic_vector(7 downto 0) := (others => '0');

  signal r_next_old_coordinate_ready                              : std_logic := '0';
  signal r_ram_write_finished                                     : std_logic := '0';

  signal r_current_file_write_column                              : integer range 0 to 639 := 0;
  signal r_current_file_write_row                                 : integer range 0 to 479 := 0;
  signal w_file_write_lut                                         : integer range 0 to 307200;

  signal r_lock_start                                             : std_logic := '0';

begin

  RECT : RECTIFICATION
    port map (
      I_CLOCK   => w_clk_system,
      I_RESET_N => w_reset_n,

      I_START       => w_start_rectification,
      I_X           => w_i_x,
      I_Y           => w_i_y,
      I_USE_INVERSE => w_use_inverse,

      O_X                  => w_o_x,
      O_Y                  => w_o_y,
      O_VALID              => w_rect_valid,
      O_ACK                => w_rect_ack,
      O_COORDINATE_INVALID => w_coordinate_invalid
    );

  -- RAM : SDRAM_DE2_115_WRAPPER
  --   port map (
  --     I_CLOCK => w_clk_sdram,

  --     I_SDRAM_A    => w_dram_addr,
  --     I_SDRAM_BA   => w_dram_ba,
  --     IO_SDRAM_DQ  => w_dram_dq,
  --     I_SDRAM_CKE  => w_dram_cke,
  --     I_SDRAM_CS   => w_dram_cs_n,
  --     I_SDRAM_RAS  => w_dram_ras_n,
  --     I_SDRAM_CAS  => w_dram_cas_n,
  --     I_SDRAM_WE   => w_dram_we_n,
  --     I_SDRAM_DQML => w_dqml,
  --     I_SDRAM_DQMH => w_dqmh
  --   );

  COMP_PLL : PLL
    port map (
      CLK_CLK        => clk_tb_s,
      RESET_RESET_N  => w_reset_n,
      CLK_SYSTEM_CLK => w_clk_system,
      CLK_SDRAM_CLK  => w_clk_sdram
    );

  COMP_SDRAM_CONTROLLER : SDRAM_CONTROLLER
    port map (
      -- reset
      I_RESET_N           => w_reset_n,
      I_CLOCK             => w_clk_system,
      I_ADDRESS           => unsigned(w_sdram_addr),
      I_DATA              => w_sdram_writedata,
      I_WRITE_ENABLE      => w_sdram_we,
      I_REQUEST           => w_sdram_req,
      O_ACKNOWLEDGE       => w_sdram_ack,
      O_VALID             => w_sdram_rdval,
      O_Q                 => w_sdram_readdata,
      O_SDRAM_A           => w_dram_addr,
      O_SDRAM_BA          => w_dram_ba,
      IO_SDRAM_DQ         => w_dram_dq,
      O_SDRAM_CKE         => w_dram_cke,
      O_SDRAM_CS          => w_dram_cs_n,
      O_SDRAM_RAS         => w_dram_ras_n,
      O_SDRAM_CAS         => w_dram_cas_n,
      O_SDRAM_WE          => w_dram_we_n,
      O_SDRAM_DQML        => w_dqml,
      O_SDRAM_DQMH        => w_dqmh,
      O_SDRAM_INITIALIZED => w_sdram_initialized
    );

  PROC_STATE_OUT : process (r_current_original_write_col, r_current_original_write_row, r_lock_start, w_o_x, w_o_y, w_sdram_rdval, r_current_file_write_column, r_current_file_write_row, r_ram_write_finished, r_next_old_coordinate_ready, w_sdram_ack, w_sdram_rdval, w_new_coordinate_lut, w_old_coordinate_lut, r_current_new_y, r_current_new_x, w_rect_valid, r_current_state, w_sdram_initialized, r_original_image_write_pointer, r_pixel) is

    variable v_col_count_image1 : integer := 0;
    variable v_row_count_image1 : integer := 0;

    variable v_fstatus  : file_open_status;
    variable v_line_out : line;

    file image1 : text open read_mode is c_filename_image1;

    variable v_current_image1_line : line;

  begin

    case r_current_state is

      when CLOSE_FILE =>
        w_next_state <= WAIT_FOR_READY;
        w_sdram_we   <= '0';
        w_sdram_req  <= '0';
        w_sdram_addr <= (others => '0');

        w_start_rectification <= '0';
        w_i_x                 <= c_0;
        w_i_y                 <= c_0;
        w_use_inverse         <= '0';

      when WAIT_FOR_READY =>

        if (w_sdram_initialized = '1') then
          w_next_state <= STORE_ORIGINAL_IMAGE;
        else
          w_next_state <= WAIT_FOR_READY;
        end if;

        w_start_rectification <= '0';
        w_i_x                 <= c_0;
        w_i_y                 <= c_0;
        w_use_inverse         <= '0';

      -- Übertrage BLOCK_SIZE Zeilen von Bild 1
      when STORE_ORIGINAL_IMAGE =>

        if (r_current_original_write_col = c_original_image_width - 1 and r_current_original_write_row = c_original_image_height - 1) then

          w_next_state <= CALCULATE_TARGET_AREA;
        else
          w_next_state <= STORE_ORIGINAL_IMAGE;
        end if;

        w_start_rectification <= '0';
        w_i_x                 <= c_0;
        w_i_y                 <= c_0;
        w_use_inverse         <= '0';

      when CALCULATE_LEFT_UPPER =>

        if (w_rect_valid = '1') then
          w_next_state <= CALCULATE_RIGHT_UPPER;
        else
          w_next_state <= CALCULATE_LEFT_UPPER;
        end if;

        if (r_lock_start = '0') then
          w_start_rectification <= '1';
        else
          w_start_rectification <= '0';
        end if;

        w_i_x         <= c_0;
        w_i_y         <= c_0;
        w_use_inverse <= '0';

      -- w_sdram_writedata(31 downto 0) <= (others => '0');
      -- w_sdram_req                    <= '0';
      -- w_sdram_we                     <= '0';
      -- w_sdram_addr                   <= (others => '0');

      when CALCULATE_RIGHT_UPPER =>

        if (w_rect_valid = '1') then
          w_next_state <= CALCULATE_LEFT_LOWER;
        else
          w_next_state <= CALCULATE_RIGHT_UPPER;
        end if;

        if (r_lock_start = '0') then
          w_start_rectification <= '1';
        else
          w_start_rectification <= '0';
        end if;

        w_i_x         <= c_639;
        w_i_y         <= c_0;
        w_use_inverse <= '0';
                                            
      when CALCULATE_LEFT_LOWER =>

        if (w_rect_valid = '1') then
          w_next_state <= CALCULATE_RIGHT_LOWER;
        else
          w_next_state <= CALCULATE_LEFT_LOWER;
        end if;

        if (r_lock_start = '0') then
          w_start_rectification <= '1';
        else
          w_start_rectification <= '0';
        end if;

        w_i_x         <= c_0;
        w_i_y         <= c_479;
        w_use_inverse <= '0';

      when CALCULATE_RIGHT_LOWER =>

        if (w_rect_valid = '1') then
          w_next_state <= CALCULATE_TARGET_AREA;
        else
          w_next_state <= CALCULATE_RIGHT_LOWER;
        end if;

        if (r_lock_start = '0') then
          w_start_rectification <= '1';
        else
          w_start_rectification <= '0';
        end if;

        w_i_x         <= c_639;
        w_i_y         <= c_479;
        w_use_inverse <= '0';

      when CALCULATE_TARGET_AREA =>
        w_next_state <= LOAD_OLD_COORDINATE;

        w_start_rectification <= '0';
        w_i_x                 <= c_0;
        w_i_y                 <= c_0;
        w_use_inverse         <= '0';

      when LOAD_OLD_COORDINATE =>

        if (w_rect_valid = '1') then
          w_next_state <= LOAD_OLD_PIXEL;
        else
          w_next_state <= LOAD_OLD_COORDINATE;
        end if;

        if (r_lock_start = '0') then
          w_start_rectification <= '1';
        else
          w_start_rectification <= '0';
        end if;

        w_i_x         <= r_current_new_x;
        w_i_y         <= r_current_new_y;
        w_use_inverse <= '1';

      when LOAD_OLD_PIXEL =>

      if(w_rect_ack = '1') then
        w_next_state <= WRITE_NEW_PIXEL;
      end if;

        if (r_lock_start = '0') then
          w_start_rectification <= '1';
        else
          w_start_rectification <= '0';
        end if;

        w_i_x         <= r_next_new_x;
        w_i_y         <= r_next_new_y;
        w_use_inverse <= '1';

      when WRITE_NEW_PIXEL =>

        if (r_next_old_coordinate_ready = '1') then
          if (r_current_new_x = r_target_area_x_end and r_current_new_y = r_target_area_y_end) then
            w_next_state <= WRITE_TO_FILE;
          else
            w_next_state <= LOAD_OLD_PIXEL;
          end if;
        else
          w_next_state <= WRITE_NEW_PIXEL;
        end if;

        w_start_rectification <= '0';
        w_i_x                 <= c_0;
        w_i_y                 <= c_0;
        w_use_inverse         <= '0';

      when WRITE_TO_FILE =>

        if (r_current_file_write_column = 639 and r_current_file_write_row = 479) then
          w_next_state <= FINISHED;
        else
          w_next_state <= WRITE_TO_FILE;
        end if;

      when FINISHED =>
        w_next_state <= FINISHED;

        w_start_rectification <= '0';
        w_i_x                 <= c_0;
        w_i_y                 <= c_0;
        w_use_inverse         <= '0';

    end case;

  end process PROC_STATE_OUT;

  PROC_STATE_FF : process (w_reset_n, w_clk_system) is
  begin

  end process PROC_STATE_FF;

  PROC_FILE_HANDLER_IN : process (w_reset_n, w_clk_system) is

    variable fstatus  : file_open_status;
    variable line_out : line;

    file image1 : text open read_mode is c_filename_image1;

    variable current_image1_line : line;
    variable current_image2_line : line;

    variable v_original_pixel : integer;
    variable pixel_right      : std_logic_vector(7 downto 0);

  begin

    if (w_reset_n = '0') then
      r_current_state <= WAIT_FOR_READY;
    elsif (rising_edge(w_clk_system)) then
      r_current_state <= w_next_state;

      if (w_rect_ack = '1') then
        r_lock_start <= '1';
      elsif (r_current_state /= w_next_state) then
        r_lock_start <= '0';
      end if;

      case r_current_state is

        when CLOSE_FILE =>
          file_close(fptr);

        when WAIT_FOR_READY =>
          if (w_next_state = STORE_ORIGINAL_IMAGE) then
            file_open(fstatus, fptr, c_filename_out, write_mode);

            write(line_out, string'("P2"));
            writeline(fptr, line_out);
            write(line_out, string'("# Ausgangsbild"));
            writeline(fptr, line_out);
            write(line_out, string'("640 480"));
            writeline(fptr, line_out);
            write(line_out, string'("255"));
            writeline(fptr, line_out);

            readline(image1, current_image1_line);
          -- get_integer(current_image1_line, r_pixel);
          end if;

        when STORE_ORIGINAL_IMAGE =>

          get_integer(current_image1_line, v_original_pixel);

          source_image(r_current_original_write_row, r_current_original_write_col) <= std_logic_vector(to_unsigned(v_original_pixel, 8));

          if (r_current_original_write_col = c_original_image_width - 1) then
            if (r_current_original_write_row < c_original_image_height - 1) then
              if (r_image_row_pointer < c_original_image_height - 1) then
                readline(image1, current_image1_line);
              end if;
              r_current_original_write_row <= r_current_original_write_row + 1;
              r_image_row_pointer          <= r_image_row_pointer + 1;
            else
              r_current_original_write_row <= 0;
            end if;
          end if;

          if (r_current_original_write_col < c_original_image_width - 1) then
            r_current_original_write_col <= r_current_original_write_col + 1;
          else
            r_current_original_write_col <= 0;
          end if;

          if (w_sdram_ack = '1') then
            if (r_original_image_write_pointer < 307200) then
              r_original_image_write_pointer <= r_original_image_write_pointer + 1;
            else
              r_original_image_write_pointer <= 0;
            end if;
          end if;

        when CALCULATE_LEFT_UPPER =>

          if (w_rect_valid = '1') then
            r_bounding_box_left_upper_x <= w_o_x;
            r_bounding_box_left_upper_y <= w_o_y;

            r_bounding_box_max_x <= w_o_x;
            r_bounding_box_max_y <= w_o_y;
          end if;

        when CALCULATE_RIGHT_UPPER =>
          if (w_rect_valid = '1') then
            r_bounding_box_right_upper_x <= w_o_x;
            r_bounding_box_right_upper_y <= w_o_y;

            if (w_o_x > r_bounding_box_max_x) then
              r_bounding_box_max_x <= w_o_x;
            end if;

            if (w_o_y > r_bounding_box_max_y) then
              r_bounding_box_max_y <= w_o_y;
            end if;
          end if;

        when CALCULATE_LEFT_LOWER =>

          if (w_rect_valid = '1') then
            r_bounding_box_left_lower_x <= w_o_x;
            r_bounding_box_left_lower_y <= w_o_y;

            if (w_o_x > r_bounding_box_max_x) then
              r_bounding_box_max_x <= w_o_x;
            end if;

            if (w_o_y > r_bounding_box_max_y) then
              r_bounding_box_max_y <= w_o_y;
            end if;
          end if;

        when CALCULATE_RIGHT_LOWER =>

          if (w_rect_valid = '1') then
            r_bounding_box_right_lower_x <= w_o_x;
            r_bounding_box_right_lower_y <= w_o_y;

            if (w_o_x > r_bounding_box_max_x) then
              r_bounding_box_max_x <= w_o_x;
            end if;

            if (w_o_y > r_bounding_box_max_y) then
              r_bounding_box_max_y <= w_o_y;
            end if;
          end if;

        when CALCULATE_TARGET_AREA =>

          r_target_area_x_start <= c_0;
          r_target_area_x_end   <= c_639;

          r_target_area_y_start <= c_0;
          r_target_area_y_end   <= c_479;

          r_bounding_box_ready <= '1';

          r_current_new_x <= c_0;
          r_current_new_y <= c_0;

          r_next_new_x <= c_1;
          r_next_new_y <= c_0;

        when LOAD_OLD_COORDINATE =>

          if (w_rect_valid = '1') then
            r_current_old_x <= w_o_x;
            r_current_old_y <= w_o_y;

            r_old_coordinate_invalid <= w_coordinate_invalid;
          end if;
          
          when LOAD_OLD_PIXEL =>

          if (w_rect_valid = '1') then
            r_next_old_coordinate_ready <= '1';
            r_current_old_x             <= w_o_x;
            r_current_old_y             <= w_o_y;
            r_old_coordinate_invalid <= w_coordinate_invalid;
          end if;
          
          -- if (w_sdram_rdval = '1') then
          if(r_old_coordinate_invalid = '0') then
            r_old_pixel <= source_image(r_current_old_y, r_current_old_x);
          else
            r_old_pixel <= (others => '0');
          end if;
          
          if(w_next_state /= r_current_state) then
            if (r_current_new_x < r_target_area_x_end) then
            r_current_new_x <= r_current_new_x + 1;
          else
            r_current_new_x <= r_target_area_x_start;
          end if;

          if (r_current_new_x = r_target_area_x_end) then
            if (r_current_new_y < r_target_area_y_end) then
              r_current_new_y <= r_current_new_y + 1;
            else
              r_current_new_y <= r_target_area_y_start;
            end if;
          end if;

          if (r_next_new_x < r_target_area_x_end) then
            r_next_new_x <= r_next_new_x + 1;
          else
            r_next_new_x <= r_target_area_x_start;
          end if;

          if (r_next_new_x = r_target_area_x_end) then
            if (r_next_new_y < r_target_area_y_end) then
              r_next_new_y <= r_next_new_y + 1;
            else
              r_next_new_y <= r_target_area_y_start;
            end if;
          end if;

          if (r_current_new_write_col < 639) then
            r_current_new_write_col <= r_current_new_write_col + 1;
          else
            r_current_new_write_col <= 0;
          end if;

          if (r_current_new_write_col = 639) then
            if (r_current_new_write_row < 479) then
              r_current_new_write_row <= r_current_new_write_row + 1;
            else
              r_current_new_write_row <= 0;
            end if;
          end if;
        end if;
        -- end if;

        when WRITE_NEW_PIXEL =>

          result_image(r_current_new_write_row, r_current_new_write_col) <= r_old_pixel;

          if (w_next_state = LOAD_OLD_PIXEL) then
            r_next_old_coordinate_ready <= '0';
            r_ram_write_finished        <= '0';
          end if;

          if (w_sdram_ack = '1') then
            r_ram_write_finished <= '1';
          end if;

          if (w_rect_valid = '1') then
            r_next_old_coordinate_ready <= '1';
            r_current_old_x             <= w_o_x;
            r_current_old_y             <= w_o_y;
            r_old_coordinate_invalid <= w_coordinate_invalid;
          end if;

        when WRITE_TO_FILE =>
            if (r_current_file_write_column < 639) then
              r_current_file_write_column <= r_current_file_write_column + 1;
            else
              r_current_file_write_column <= 0;
            end if;

            if (r_current_file_write_column = 639) then
              if (r_current_file_write_row < 479) then
                r_current_file_write_row <= r_current_file_write_row + 1;
              else
                r_current_file_write_row <= 0;
              end if;
            end if;

            write(line_out, to_integer(unsigned(result_image(r_current_file_write_row, r_current_file_write_column))));

            if (r_current_file_write_column = 639) then
              writeline(fptr, line_out);
            else
              write(line_out, string'(" "));
            end if;
          -- end if;

        when FINISHED =>
          file_close(fptr);

      end case;

    end if;

  end process PROC_FILE_HANDLER_IN;

  w_new_coordinate_lut <= r_current_new_write_row * 640 + r_current_new_write_col;
  w_old_coordinate_lut <= r_current_old_y * 640 + r_current_old_x;
  w_file_write_lut     <= r_current_file_write_row * 640 + r_current_file_write_column;

  w_reset_n <= '1';

end architecture TESTBENCH;
