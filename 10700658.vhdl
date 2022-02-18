library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR(7 downto 0);
           o_address : out STD_LOGIC_VECTOR(15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR(7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state is ( START_STATE, W_READ_REQUEST,
				W_READ, CHECK_END, WORD_READ_REQUEST,
				WORD_READ, LOW_START_STATE, TEMP_INC_COUNT_ENCODER_BIT,
				INC_COUNT_ENCODER_BIT, CHECK_ENCODER_END,
				WRITE_FIRST_WORD, WRITE_SECOND_WORD,
				TEMP_INC_COUNT_WORD, INC_COUNT_WORD,
				S00, S01, S10, S11);

signal is_loop : STD_LOGIC := '0';
signal state_next : state := START_STATE;
signal state_curr : state;
signal state_curr_encoder, tmp_state_curr_encoder : state := S00;
signal o_encoder_data, tmp_o_encoder_data : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal i_word, tmp_i_word: STD_LOGIC_VECTOR(7 downto 0);
signal encoded_word, tmp_encoded_word: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
signal i_num, tmp_i_num : UNSIGNED(7 downto 0) := "00000000";
signal count_encoder_bit, tmp_count_encoder_bit : UNSIGNED(3 downto 0) := "0000";
signal count_word, tmp_count_word: UNSIGNED(7 downto 0) := "00000000";

begin



process(i_clk, i_rst)
begin
	if(rising_edge(i_clk))then
		if(state_curr = state_next) then 
			is_loop <= not is_loop;
		end if;
		state_curr <= state_next;
		state_curr_encoder <= tmp_state_curr_encoder;
		encoded_word <= tmp_encoded_word;
		count_word <= tmp_count_word;
		count_encoder_bit <= tmp_count_encoder_bit;
		i_word <= tmp_i_word;
		i_num <= tmp_i_num;
		o_encoder_data <= tmp_o_encoder_data;
	end if;
	if(i_rst = '1')then
		state_curr <= START_STATE;
		state_curr_encoder <= S00;
		encoded_word <= "0000000000000000";
		count_word <= "00000000";
		count_encoder_bit <= "0000";
		i_word <= "00000000";
		i_num <= "00000000";
		o_encoder_data <= "00";
	end if;
end process;
		

process(state_curr,is_loop, i_data, i_start, o_encoder_data, state_curr_encoder, encoded_word, count_word, count_encoder_bit, i_word, i_num)
	variable temp : UNSIGNED(4 downto 0);
begin
	o_en <= '0';
	o_we <= '0';
	o_done <= '0';
        o_address <= "0000000000000000";
	o_data <= "00000000";
	case state_curr is

            		when START_STATE => 
								tmp_state_curr_encoder <= S00;
								tmp_encoded_word <= "0000000000000000";
								tmp_count_word <= "00000000";
								tmp_count_encoder_bit <= "0000";
								tmp_i_word <= "00000000";
								tmp_i_num <= "00000000";
								tmp_o_encoder_data <= "00";
                                				if(i_start = '1')then
                                    					state_next <= W_READ_REQUEST;
                               					else
                                    					state_next <= START_STATE;
                                				end if;
								
            		when W_READ_REQUEST =>  
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								o_en <= '1';
                                				o_we <= '0';
                               					o_address <= "0000000000000000";
                                				state_next <= W_READ;

            		when W_READ =>  
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= unsigned(i_data);
                               					state_next <= CHECK_END;
								
			when CHECK_END =>	
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								if(i_num = "00000000")then
									o_done <= '1';
									state_next <= LOW_START_STATE;
								elsif(count_word = i_num)then
									o_done <= '1';
									state_next <= LOW_START_STATE;
								else
									o_done <= '0';
									state_next <= WORD_READ_REQUEST;
								end if;
								
            	    	when WORD_READ_REQUEST =>  
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								o_en <= '1';
                                				o_we <= '0';
                                				o_address <= "00000000" & std_logic_vector(count_word+1);
                               					state_next <= WORD_READ;
								
       		   	when WORD_READ =>  
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= "0000000000000000";
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= "0000";
								tmp_i_word <= i_data;
								tmp_i_num <= i_num;
								state_next <= state_curr_encoder;
								
            		when S00 => 		
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								if(i_word(to_integer(7 - count_encoder_bit)) = '0')then
									tmp_o_encoder_data <= "00";
									tmp_state_curr_encoder <=S00;
								else
									tmp_o_encoder_data <= "11";
									tmp_state_curr_encoder <= S10;
								end if;
								state_next <= TEMP_INC_COUNT_ENCODER_BIT;
								
			when S01 => 		
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								if(i_word(to_integer(7 - count_encoder_bit)) = '0')then
									tmp_o_encoder_data <= "11";
									tmp_state_curr_encoder <=S00;
								else
									tmp_o_encoder_data <= "00";
									tmp_state_curr_encoder <= S10;
								end if;
								state_next <= TEMP_INC_COUNT_ENCODER_BIT;
								
			when S10 => 		
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								if(i_word(to_integer(7 - count_encoder_bit)) = '0')then
									tmp_o_encoder_data <= "01";
									tmp_state_curr_encoder <=S01;
								else
									tmp_o_encoder_data <= "10";
									tmp_state_curr_encoder <= S11;
								end if;
								state_next <= TEMP_INC_COUNT_ENCODER_BIT;
								
			when S11 => 		
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								if(i_word(to_integer(7 - count_encoder_bit)) = '0')then
									tmp_o_encoder_data <= "10";
									tmp_state_curr_encoder <=S01;
								else
									tmp_o_encoder_data <= "01";
									tmp_state_curr_encoder <= S11;
								end if;
								state_next <= TEMP_INC_COUNT_ENCODER_BIT;
								
			when TEMP_INC_COUNT_ENCODER_BIT =>
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_count_word <= count_word;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								temp := count_encoder_bit & '0';
								tmp_encoded_word <= encoded_word;
								tmp_encoded_word(to_integer(15-temp)) <= o_encoder_data(1);
								tmp_encoded_word(to_integer(14-temp)) <= o_encoder_data(0);
								tmp_count_encoder_bit <= count_encoder_bit + 1;
								state_next <= INC_COUNT_ENCODER_BIT;
								
			when INC_COUNT_ENCODER_BIT =>
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								state_next <= CHECK_ENCODER_END;
								
			when CHECK_ENCODER_END =>
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								if(to_integer(count_encoder_bit) > 7)then
									state_next <= WRITE_FIRST_WORD;
								else 
									state_next <= state_curr_encoder;
								end if;
								
			when WRITE_FIRST_WORD =>	
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								o_en <= '1';
								o_we <= '1';
								o_address <= std_logic_vector(to_unsigned(1000+to_integer(count_word & '0'),16));
								o_data <= encoded_word(15 downto 8);
								state_next <= WRITE_SECOND_WORD;
								
			when WRITE_SECOND_WORD =>	
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								o_en <= '1';
								o_we <= '1';
								o_address <= std_logic_vector(to_unsigned(1001+to_integer(count_word & '0'),16));
								o_data <= encoded_word(7 downto 0);
								state_next <= TEMP_INC_COUNT_WORD;
								
			when TEMP_INC_COUNT_WORD =>
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								tmp_count_word <= count_word + 1;
								state_next <= INC_COUNT_WORD;
								
			when INC_COUNT_WORD => 
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								state_next <= CHECK_END;
								
            		when LOW_START_STATE => 
								tmp_o_encoder_data <= o_encoder_data;
								tmp_state_curr_encoder <= state_curr_encoder;
								tmp_encoded_word <= encoded_word;
								tmp_count_word <= count_word;
								tmp_count_encoder_bit <= count_encoder_bit;
								tmp_i_word <= i_word;
								tmp_i_num <= i_num;
								o_done <= '1';
								if(i_start = '0')then
									state_next <= START_STATE;
                                				else
									state_next <= LOW_START_STATE;
                               					end if;
        end case;

end process;

end Behavioral;