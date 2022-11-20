module key_filter(
input    wire       key         ,
input    wire       sys_clk     ,
input    wire       sys_rst_n   ,

output   reg        temp_key_flag
);

parameter CNT_MAX = 20'd1_000_000;      //延时20ms
parameter FLAG_CNT_MAX = 18'd150_000;   //产生一个延时2ms的key_flag信号

reg     [19:0]      cnt;
reg		[17:0]	flag_cnt;
reg				flag_cnt_en;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        cnt <= 20'd0;
    else if(key == 1'b0)             //这段的意思是，按键key的信号必须持续20ms(理解为cnt持续充能20ms，一间断(key=1,按键没按下)cnt就等于0重新开始计数)
        if(cnt >= CNT_MAX - 1'd1)
            cnt <= CNT_MAX;
        else
            cnt <= cnt + 1;
    else
        cnt <= 20'd0;
end

always @(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0)
        temp_key_flag <= 1'b0;
    else if(cnt == CNT_MAX - 1'd1)            //当cnt持续充能20ms(按键按下产生了20ms的稳定充能信号)，产生一个高电平的key_flag信号
        temp_key_flag <= 1'b1;
    else
        temp_key_flag <= 1'b0;

	
always @(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0)
		flag_cnt_en  <= 1'b0;
	else if(temp_key_flag == 1'b1)
		flag_cnt_en <= 1'b1;
	else if(flag_cnt == FLAG_CNT_MAX - 1'd1)
		flag_cnt_en <= 1'b0;

always @(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0)
		flag_cnt <= 17'd0;
	else if(flag_cnt == FLAG_CNT_MAX - 1'd1)
		flag_cnt <= 17'd0;
	else if(flag_cnt_en)
		flag_cnt <= flag_cnt + 1'b1;
	else
		flag_cnt <= 17'd0;
	
	
	
endmodule
