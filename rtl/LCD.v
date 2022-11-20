module LCD
	(
	input 				clk			 ,
	input 				rst_n		 ,
    input               KEY1   		 ,
    input               KEY2   		 ,
    input               KEY3  		 ,
    input               KEY4  		 ,
	output 				LCD_E 		 ,
	output reg 			LCD_RS		 ,
	output reg[7:0]	    LCD_DATA	 ,
    output wire         LCD_ON		 ,
    output wire         LCD_RW		 ,
	output 			    order1_flag	 ,
	output 			    order2_flag	 ,
	output      		music0_flag	 ,
	output      		music1_flag	 ,
	output              music2_flag	 ,
	output              music3_flag	 ,
	output      		volume1_flag ,
	output      		volume2_flag ,
	output      		volume3_flag ,
	output      		volume4_flag ,
	output      		volume5_flag ,
	output      		speed1_flag	 ,
	output      		speed2_flag	 ,
	output      		speed3_flag	 ,
	output 			    play_flag 	 ,
	output 			    pause_flag 	 ,
	output reg			LED 
	);
	`include "parameter_sheet.h"

	assign LCD_ON = 1'b1;     //打开LED电源
	assign LCD_RW = 1'b0;	  //因为没有读操作，所以LCD_RW一直是低电平
	
	//配置想要输出的字符数据，共16*8=128bit
    reg[127:0]  row_1;
	reg[127:0]  row_2;


	reg			order_reg;			  //用来判断是顺序播放还是单曲循环的标志
	reg[1:0]	music_reg;	  		  //用来记录当前播放的音乐是哪首
	reg[2:0] 	volume_reg;	  		  //用来记录选择的音量
	reg[1:0] 	speed_reg;	  		  //要来记录播放速度
	reg 	   	play_reg;	  		  //用来记录现在是暂停还是播放
	wire key1_flag;
	wire key2_flag;
	wire key3_flag;
	wire key4_flag;
	
	key_filter K1(
	.key        (KEY1) ,
	.sys_clk    (clk) ,
	.sys_rst_n  (rst_n) ,

	.temp_key_flag   (key1_flag)
	);

	key_filter K2(
	.key        (KEY2) ,
	.sys_clk    (clk) ,
	.sys_rst_n  (rst_n) ,

	.temp_key_flag   (key2_flag)
	);

	key_filter K3(
	.key        (KEY3) ,
	.sys_clk    (clk) ,
	.sys_rst_n  (rst_n) ,

	.temp_key_flag   (key3_flag)
	);

	key_filter K4(
	.key        (KEY4) ,
	.sys_clk    (clk) ,
	.sys_rst_n  (rst_n) ,

	.temp_key_flag  (key4_flag)
	);
	
	
	//上电稳定阶段
	parameter TIME_15MS=750_000;//需要15ms以达上电稳定(初始化)
	reg[19:0]cnt_15ms;
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			cnt_15ms <= 1'b0;
		else if(cnt_15ms == TIME_15MS-1'b1)
			cnt_15ms <= cnt_15ms;
		else
			cnt_15ms <= cnt_15ms+1'b1 ;
	
	wire delay_done = (cnt_15ms == TIME_15MS-1'b1)?1'b1:1'b0;//上电延时完毕



	//工作周期100_000分频，考虑到指令执行时间以及各种复杂的限制，作者直接将LCD工作周期降到2ms(500HZ)
	parameter TIME_500HZ=100_000;//工作周期
	reg[19:0]cnt_500hz;
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			cnt_500hz <= 1'b0;
		else if(delay_done)
			if(cnt_500hz == TIME_500HZ-1'b1)
				cnt_500hz <= 1'b0;
			else
				cnt_500hz <= cnt_500hz+1'b1;
		else
			cnt_500hz <= 1'b0;
	
	assign LCD_E=(cnt_500hz>(TIME_500HZ-1'b1)/2)?1'b0:1'b1;//使能端,每个工作周期一次下降沿,执行一次命令
	//wire write_flag=(cnt_500hz==TIME_500HZ-1'b1)?1'b1:1'b0;//每到一个工作周期,write_flag置高一周期
	
	reg write_flag;
		always@(posedge clk or negedge rst_n)
			if(!rst_n)
				write_flag <= 1'b0;
			else if(cnt_500hz == TIME_500HZ-1'b1)
			   write_flag <= 1'b1;
			else
				write_flag <= 1'b0;

    //根据按键进行显示界面的切换
    parameter key1 = 3'b000, key2 = 3'b001, key3 = 3'b010, key4 = 3'b011;                   //按键的flag标志
    reg [2:0] KEY;
    always @(posedge clk or negedge rst_n) 
        if (!rst_n)  
            KEY <= 2'd0;
        else if(key1_flag == 1'b1)
            KEY <= key1;
        else if(key2_flag == 1'b1)
            KEY <= key2;   
        else if(key3_flag == 1'b1)
            KEY <= key3;
        else if(key4_flag == 1'b1)
            KEY <= key4;
        else 
            KEY <= 3'b100;


	parameter TIME_1S = 50_000_000;			//缺省情况下为32位无符号十进制数
	reg [25:0] cnt_1s;
	reg [7:0] cnt_sec;			//秒钟计时
	reg [7:0] cnt_min;			//分钟计时
	wire cnt_clc1, cnt_clc;		//时钟清零信号，每切换一首歌曲都要重新计时
	wire cnt_clc2;				//时钟清零信号，放完一首完整的歌曲时清零

	assign cnt_clc = cnt_clc1|cnt_clc2;
	always @(posedge cnt_clc or negedge rst_n) begin
		if(!rst_n)
			LED <= 1'b0;
		else
			LED <= ~LED;
	end

	//计时1s
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) cnt_1s <= 0;
		else if(cnt_1s == (TIME_1S - 1'b1)) cnt_1s <= 0;
		else cnt_1s <= cnt_1s+1'b1;
	end

	//根据不同的播放速度更改定时器基准时间
	reg [31:0] time_for_spd;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) time_for_spd = TIME_1S;
		else if(speed_reg == 0) time_for_spd <= TIME_1S;
		else if(speed_reg == 2'd1) time_for_spd <= 0.8*TIME_1S;
		else if(speed_reg == 2'd2) time_for_spd <= 1.3333333*TIME_1S;
		else time_for_spd <= time_for_spd;
	end

	//秒钟计时
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) cnt_sec <= 0;
		else if(cnt_clc) cnt_sec <= 0;
		else case(play_reg)
					1'b0: cnt_sec <= cnt_sec;
					1'b1: if(cnt_sec == 8'd59) cnt_sec <= 0;
						  else if(cnt_1s == (time_for_spd - 1'b1)) cnt_sec <= cnt_sec+1; 					
						  else cnt_sec <= cnt_sec;
		endcase
	end

	//分钟计时
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) cnt_min <= 0;
		else if(cnt_clc) cnt_min <= 0;
		else if(cnt_sec == 8'd59) 
				if(cnt_min == 8'd59) cnt_min <= 0;
				else cnt_min <= cnt_min+1;
	end


	reg[7:0]currentstate;//Current state,当前状态
	reg[7:0]nextstate;//Next state,下一状态
	
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			currentstate <= IDLE;
		else if(write_flag)//每一个工作周期改变一次状态
			currentstate <= nextstate;
		else
			currentstate <= currentstate;
	
	always@(*)                  //扫描显示字符
		case (currentstate)
			IDLE:					nextstate = SET_FUNCTION;
			SET_FUNCTION:			nextstate = DISP_OFF;
			DISP_OFF:				nextstate = DISP_CLEAR;
			DISP_CLEAR:				nextstate = ENTRY_MODE;
			ENTRY_MODE:				nextstate = DISP_ON;
			DISP_ON:				nextstate = WEDD1;

			WEDD1:					nextstate = SEE0_0;
			SEE0_0:					nextstate = SEE0_1;
			SEE0_1:					nextstate = SEE0_2;
			SEE0_2:					nextstate = SEE0_3;
			SEE0_3:					nextstate = SEE0_4;
			SEE0_4:					nextstate = SEE0_5;
			SEE0_5:					nextstate = SEE0_6;
			SEE0_6:					nextstate = WEDD2;

			WEDD2:					nextstate = SEE1_0;
			SEE1_0:					nextstate = SEE1_1;
			SEE1_1:					nextstate = SEE1_2;
			SEE1_2:					nextstate = SEE1_3;
			SEE1_3:					nextstate = SEE1_4;
			SEE1_4:					nextstate = SEE1_5;
			SEE1_5:					nextstate = SEE1_6;
			SEE1_6:					nextstate = WEDD3;

			WEDD3:					nextstate = SEE2_0;
			SEE2_0:					nextstate = SEE2_1;
			SEE2_1:					nextstate = SEE2_2;
			SEE2_2:					nextstate = SEE2_3;
			SEE2_3:					nextstate = SEE2_4;
			SEE2_4:					nextstate = SEE2_5;
			SEE2_5:					nextstate = SEE2_6;
			SEE2_6:					nextstate = WEDD4;

			WEDD4:					nextstate = SEE3_0;
			SEE3_0:					nextstate = SEE3_1;
			SEE3_1:					nextstate = SEE3_2;
			SEE3_2:					nextstate = SEE3_3;
			SEE3_3:					nextstate = SEE3_4;
			SEE3_4:					nextstate = SEE3_5;
			SEE3_5:					nextstate = SEE3_6;
			SEE3_6:					nextstate = ROW1_ADDR;

			ROW1_ADDR:				nextstate = ROW1_0;
			ROW1_0:					nextstate = ROW1_1;
			ROW1_1:					nextstate = ROW1_2;
			ROW1_2:					nextstate = ROW1_3;
			ROW1_3:					nextstate = ROW1_4;
			ROW1_4:					nextstate = ROW1_5;
			ROW1_5:					nextstate = ROW1_6;
			ROW1_6:					nextstate = ROW1_7;
			ROW1_7:					nextstate = ROW1_8;
			ROW1_8:					nextstate = ROW1_9;
			ROW1_9:					nextstate = ROW1_A;
			ROW1_A:					nextstate = ROW1_B;
			ROW1_B:					nextstate = ROW1_C;
			ROW1_C:					nextstate = ROW1_D;
			ROW1_D:					nextstate = ROW1_E;
			ROW1_E:					nextstate = ROW1_F;
			ROW1_F:					nextstate = ROW2_ADDR;
			ROW2_ADDR:				nextstate = ROW2_0;
			ROW2_0:					nextstate = ROW2_1;
			ROW2_1:					nextstate = ROW2_2;
			ROW2_2:					nextstate = ROW2_3;
			ROW2_3:					nextstate = ROW2_4;
			ROW2_4:					nextstate = ROW2_5;
			ROW2_5:					nextstate = ROW2_6;
			ROW2_6:					nextstate = ROW2_7;
			ROW2_7:					nextstate = ROW2_8;
			ROW2_8:					nextstate = ROW2_9;
			ROW2_9:					nextstate = ROW2_A;
			ROW2_A:					nextstate = ROW2_B;
			ROW2_B:					nextstate = ROW2_C;
			ROW2_C:					nextstate = ROW2_D;
			ROW2_D:					nextstate = ROW2_E;
			ROW2_E:					nextstate = ROW2_F;
			ROW2_F:					nextstate = ROW1_ADDR;//循环到1-1进行扫描显示
			default:				nextstate = ROW1_0;
		endcase



	//RS端口信号控制
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			LCD_RS <= 1'b0;//为0时输入指令,为1时输入数据
		else if(write_flag)
			//当状态为七个指令任意一个,将RS置为指令输入状态
			if((currentstate == SET_FUNCTION)||(currentstate==DISP_OFF)||(currentstate==DISP_CLEAR)||(currentstate==ENTRY_MODE)||(currentstate==DISP_ON)||(currentstate==ROW1_ADDR)||(currentstate==ROW2_ADDR)||(currentstate==WEDD1)||(currentstate==WEDD2)||(currentstate==WEDD3)||(currentstate==WEDD4))
				LCD_RS <= 1'b0; 
			else
				LCD_RS <= 1'b1;
		else
			LCD_RS <= LCD_RS;


	//显示输出
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			LCD_DATA <= 1'b0;
		else if(write_flag)
			case(currentstate)
				IDLE:					LCD_DATA <= 8'hxx;
				SET_FUNCTION:			LCD_DATA <= 8'h38;//8'b0011_1000,工作方式设置:DL=1(DB4,8位数据接口),N=1(DB3,两行显示),L=0(DB2,5x8点阵显示).
				DISP_OFF:				LCD_DATA <= 8'h08;//8'b0000_1000,显示开关设置:D=0(DB2,显示关),C=0(DB1,光标不显示),D=0(DB0,光标不闪烁)
				DISP_CLEAR:				LCD_DATA <= 8'h01;//8'b0000_0001,清屏
				ENTRY_MODE:				LCD_DATA <= 8'h06;//8'b0000_0110,进入模式设置:I/D=1(DB1,写入新数据光标右移),S=0(DB0,显示不移动)
				DISP_ON:				LCD_DATA <= 8'h0c;//8'b0000_1100,显示开关设置:D=1(DB2,显示开),C=0(DB1,光标不显示),D=0(DB0,光标不闪烁)

				WEDD1:					LCD_DATA <= 8'h40;//设置CGRAM地址
				//向CGRAM中写入自定义的字符(下一曲)，一个字符为5*7bit
				SEE0_0:					LCD_DATA <= crt_F8[55:48];
				SEE0_1:					LCD_DATA <= crt_F8[47:40];
				SEE0_2:					LCD_DATA <= crt_F8[39:32];
				SEE0_3:					LCD_DATA <= crt_F8[31:24];
				SEE0_4:					LCD_DATA <= crt_F8[23:16];
				SEE0_5:					LCD_DATA <= crt_F8[15:8];
				SEE0_6:					LCD_DATA <= crt_F8[7:0];
				WEDD2:					LCD_DATA <= 8'h48;//设置CGRAM地址
				//向CGRAM中写入自定义的字符(上一曲)，一个字符为5*7bit
				SEE1_0:					LCD_DATA <= crt_F9[55:48];
				SEE1_1:					LCD_DATA <= crt_F9[47:40];
				SEE1_2:					LCD_DATA <= crt_F9[39:32];
				SEE1_3:					LCD_DATA <= crt_F9[31:24];
				SEE1_4:					LCD_DATA <= crt_F9[23:16];
				SEE1_5:					LCD_DATA <= crt_F9[15:8];
				SEE1_6:					LCD_DATA <= crt_F9[7:0];
				WEDD3:					LCD_DATA <= 8'h50;//设置CGRAM地址
				//向CGRAM中写入自定义的字符(正在播放)，一个字符为5*7bit
				SEE2_0:					LCD_DATA <= crt_FA[55:48];
				SEE2_1:					LCD_DATA <= crt_FA[47:40];
				SEE2_2:					LCD_DATA <= crt_FA[39:32];
				SEE2_3:					LCD_DATA <= crt_FA[31:24];
				SEE2_4:					LCD_DATA <= crt_FA[23:16];
				SEE2_5:					LCD_DATA <= crt_FA[15:8];
				SEE2_6:					LCD_DATA <= crt_FA[7:0];
				WEDD4:					LCD_DATA <= 8'h58;//设置CGRAM地址
				//向CGRAM中写入自定义的字符(暂停播放)，一个字符为5*7bit
				SEE3_0:					LCD_DATA <= crt_FB[55:48];
				SEE3_1:					LCD_DATA <= crt_FB[47:40];
				SEE3_2:					LCD_DATA <= crt_FB[39:32];
				SEE3_3:					LCD_DATA <= crt_FB[31:24];
				SEE3_4:					LCD_DATA <= crt_FB[23:16];
				SEE3_5:					LCD_DATA <= crt_FB[15:8];
				SEE3_6:					LCD_DATA <= crt_FB[7:0];

				ROW1_ADDR:				LCD_DATA <= 8'h80;//8'b1000_0000,设置DDRAM地址:00H->1-1,第一行第一位
				//将输入的row_1以每8-bit拆分,分配给对应的显示位
				ROW1_0:					LCD_DATA <= row_1[127:120];
				ROW1_1:					LCD_DATA <= row_1[119:112];
				ROW1_2:					LCD_DATA <= row_1[111:104];
				ROW1_3:					LCD_DATA <= row_1[103: 96];
				ROW1_4:					LCD_DATA <= row_1[ 95: 88];
				ROW1_5:					LCD_DATA <= row_1[ 87: 80];
				ROW1_6:					LCD_DATA <= row_1[ 79: 72];
				ROW1_7:					LCD_DATA <= row_1[ 71: 64];
				ROW1_8:					LCD_DATA <= row_1[ 63: 56];
				ROW1_9:					LCD_DATA <= row_1[ 55: 48];
				ROW1_A:					LCD_DATA <= row_1[ 47: 40];
				ROW1_B:					LCD_DATA <= row_1[ 39: 32];
				ROW1_C:					LCD_DATA <= row_1[ 31: 24];
				ROW1_D:					LCD_DATA <= row_1[ 23: 16];
				ROW1_E:					LCD_DATA <= row_1[ 15:  8];
				ROW1_F:					LCD_DATA <= row_1[  7:  0];

				ROW2_ADDR:				LCD_DATA <= 8'hc0;//8'b1100_0000,设置DDRAM地址:40H->2-1,第二行第一位
				ROW2_0:					LCD_DATA <= row_2[127:120];
				ROW2_1:					LCD_DATA <= row_2[119:112];
				ROW2_2:					LCD_DATA <= row_2[111:104];
				ROW2_3:					LCD_DATA <= row_2[103: 96];
				ROW2_4:					LCD_DATA <= row_2[ 95: 88];
				ROW2_5:					LCD_DATA <= row_2[ 87: 80];
				ROW2_6:					LCD_DATA <= row_2[ 79: 72];
				ROW2_7:					LCD_DATA <= row_2[ 71: 64];
				ROW2_8:					LCD_DATA <= row_2[ 63: 56];
				ROW2_9:					LCD_DATA <= row_2[ 55: 48];
				ROW2_A:					LCD_DATA <= row_2[ 47: 40];
				ROW2_B:					LCD_DATA <= row_2[ 39: 32];
				ROW2_C:					LCD_DATA <= row_2[ 31: 24];
				ROW2_D:					LCD_DATA <= row_2[ 23: 16];
				ROW2_E:					LCD_DATA <= row_2[ 15:  8];
				ROW2_F:					LCD_DATA <= row_2[  7:  0];
				default:				LCD_DATA <= 8'b0011_1111;						//输出问号
			endcase
		else
			LCD_DATA<=LCD_DATA;


	 //将分钟秒钟计时器的二进制装换成BCD码,方便显示
	wire[3:0] hun_s, ten_s, one_s, hun_m, ten_m, one_m;
    BCD BCD_inst_sec
	(
    	.binary     (cnt_sec)     ,
    	.Hundreds   (hun_s)     ,
    	.Tens       (ten_s)     ,
    	.Ones       (one_s)
	);
	BCD BCD_inst_min
	(
    	.binary     (cnt_min)     ,
    	.Hundreds   (hun_m)     ,
    	.Tens       (ten_m)     ,
    	.Ones       (one_m)
	);

	reg[31:0] show_time;						//显示计时字符

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) show_time[31:24] <= "0";
		else case(one_m)
				4'b0000:    show_time[31:24] <= "0";
				4'b0001:    show_time[31:24] <= "1";
				4'b0010:    show_time[31:24] <= "2";
				4'b0011:    show_time[31:24] <= "3";
				4'b0100:    show_time[31:24] <= "4";
				4'b0101:    show_time[31:24] <= "5";
				4'b0110:    show_time[31:24] <= "6";
				4'b0111:    show_time[31:24] <= "7";
				4'b1000:    show_time[31:24] <= "8";
				4'b1001:    show_time[31:24] <= "9";
				default: show_time[31:24] <= "0";
			endcase
	end
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) show_time[23:16] <= "0";
		else show_time[23:16] <= "m"; 
	end
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) show_time[15:8] <= "0";
		else case(ten_s)
				4'b0000:    show_time[15:8] <= "0";
				4'b0001:    show_time[15:8] <= "1";
				4'b0010:    show_time[15:8] <= "2";
				4'b0011:    show_time[15:8] <= "3";
				4'b0100:    show_time[15:8] <= "4";
				4'b0101:    show_time[15:8] <= "5";
				4'b0110:    show_time[15:8] <= "6";
				4'b0111:    show_time[15:8] <= "7";
				4'b1000:    show_time[15:8] <= "8";
				4'b1001:    show_time[15:8] <= "9";
				default: show_time[15:8] <= "0";
			endcase
	end
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) show_time[7:0] <= "0";
		else case(one_s)
				4'b0000:    show_time[7:0] <= "0";
				4'b0001:    show_time[7:0] <= "1";
				4'b0010:    show_time[7:0] <= "2";
				4'b0011:    show_time[7:0] <= "3";
				4'b0100:    show_time[7:0] <= "4";
				4'b0101:    show_time[7:0] <= "5";
				4'b0110:    show_time[7:0] <= "6";
				4'b0111:    show_time[7:0] <= "7";
				4'b1000:    show_time[7:0] <= "8";
				4'b1001:    show_time[7:0] <= "9";
				default: show_time[7:0] <= "0";
			endcase
	end


    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            row_1[127:32] = show_0[127:32];
        else  begin
            case(row_1[111:40])
                show_0[111:40]: if(KEY == key1) row_1[127:32] <=show_0[127:32];
                        else if(KEY == key2) begin 
						case(music_reg) 
							2'd0: row_1[127:32] <= show_4[127:32];
							2'd1: row_1[127:32] <= show_F2[127:32];
							2'd2: row_1[127:32] <= show_F3[127:32];
							2'd3: row_1[127:32] <= show_F4[127:32];
							default: row_1[127:32] <= show_4[127:32];
						endcase
						end
                        else if(KEY == key3) row_1[127:32] <=show_1[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_3[127:32];
						else row_1[127:32] <= row_1[127:32];
						
                show_1[111:40]: if(KEY == key1) row_1[127:32] <=show_1[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_6[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_0[127:32];
								else row_1[127:32] <= row_1[127:32];
								
                show_2[111:40]: if(KEY == key1) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_8[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_1[127:32];

                show_3[111:40]: if(KEY == key1) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_B[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_0[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_2[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_4[111:40]: if(KEY == key1) row_1[127:32] <=show_0[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_F2[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_5[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_F1[127:32];
								else row_1[127:32] <= row_1[127:32];
	
                show_5[111:40]: if(KEY == key1) row_1[127:32] <=show_0[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_F3[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_F1[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_4[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_6[111:40]: if(KEY == key1) row_1[127:32] <=show_1[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_1[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_7[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_7[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_7[111:40]: if(KEY == key1) row_1[127:32] <=show_1[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_1[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_6[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_6[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_8[111:40]: if(KEY == key1) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_9[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_A[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_9[111:40]: if(KEY == key1) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_A[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_8[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_A[111:40]: if(KEY == key1) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_2[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_8[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_9[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_B[111:40]: if(KEY == key1) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_C[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_F[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_C[111:40]: if(KEY == key1) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_D[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_B[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_D[111:40]: if(KEY == key1) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_E[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_C[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_E[111:40]: if(KEY == key1) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_F[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_D[127:32];
								else row_1[127:32] <= row_1[127:32];

                show_F[111:40]: if(KEY == key1) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_3[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_B[127:32];
                        else if(KEY == key4) row_1[127:32] <= show_E[127:32];
								else row_1[127:32] <= row_1[127:32];

				show_F1[111:40]: if(KEY == key1) row_1[127:32] <=show_0[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_F4[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_4[127:32];
                        else if(KEY == key4) row_1[127:32] <=show_5[127:32];
								else row_1[127:32] <= row_1[127:32];
				
				show_F2[111:40]: if(music_reg == 2'd1) begin
                                 case(KEY)
                                     key1: row_1[127:32] <=show_4[127:32];
                                     key2: row_1[127:32] <=show_F8[127:32];
                                     key3: row_1[127:32] <=show_F3[127:32];
                                     key4: row_1[127:32] <=show_F4[127:32];
								             default: row_1[127:32] <= row_1[127:32];
                                 endcase
								end
                              else if(music_reg == 2'd2) row_1[127:32] <=show_F3[127:32];
                              else if(music_reg == 2'd3) row_1[127:32] <=show_F4[127:32];
                              else row_1[127:32] <= row_1[127:32];

				show_F3[111:40]: if(music_reg == 2'd2) begin
                                 case(KEY)
                                     key1: row_1[127:32] <=show_4[127:32];
                                     key2: row_1[127:32] <=show_F9[127:32];
                                     key3: row_1[127:32] <=show_F4[127:32];
                                     key4: row_1[127:32] <=show_F2[127:32];
								             default: row_1[127:32] <= row_1[127:32];
                                 endcase
								end
                              else if(music_reg == 2'd1) row_1[127:32] <=show_F2[127:32];
                              else if(music_reg == 2'd3) row_1[127:32] <=show_F4[127:32];
                              else row_1[127:32] <= row_1[127:32];

				show_F4[111:40]: if(music_reg == 2'd3) begin
                                 case(KEY)
                                     key1: row_1[127:32] <=show_4[127:32];
                                     key2: row_1[127:32] <=show_FA[127:32];
                                     key3: row_1[127:32] <=show_F2[127:32];
                                     key4: row_1[127:32] <=show_F3[127:32];
								             default: row_1[127:32] <= row_1[127:32];
                                 endcase
								end
                              else if(music_reg == 2'd1) row_1[127:32] <=show_F2[127:32];
                              else if(music_reg == 2'd2) row_1[127:32] <=show_F3[127:32];
                              else row_1[127:32] <= row_1[127:32];

				show_F8[111:40]: if(KEY == key1) row_1[127:32] <=show_4[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_F2[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_F3[127:32];
                        else if(KEY == key4) row_1[127:32] <=show_F4[127:32];
								else row_1[127:32] <= row_1[127:32];
				
				show_F9[111:40]: if(KEY == key1) row_1[127:32] <=show_4[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_F3[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_F4[127:32];
                        else if(KEY == key4) row_1[127:32] <=show_F2[127:32];
								else row_1[127:32] <= row_1[127:32];
				
				show_FA[111:40]: if(KEY == key1) row_1[127:32] <=show_4[127:32];
                        else if(KEY == key2) row_1[127:32] <=show_F4[127:32];
                        else if(KEY == key3) row_1[127:32] <=show_F2[127:32];
                        else if(KEY == key4) row_1[127:32] <=show_F3[127:32];
								else row_1[127:32] <= row_1[127:32];

                default: row_1[127:32] <= show_0[127:32];
            endcase 
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) row_1[31:0] <= show_0[31:0];
		else if(row_1[127:32] == show_F2[127:32]) row_1[31:0] <= show_time;
		else if(row_1[127:32] == show_F3[127:32]) row_1[31:0] <= show_time;
		else if(row_1[127:32] == show_F4[127:32]) row_1[31:0] <= show_time;
		else if(row_1[127:32] == show_F8[127:32]) row_1[31:0] <= show_time;
		else if(row_1[127:32] == show_F9[127:32]) row_1[31:0] <= show_time;
		else if(row_1[127:32] == show_FA[127:32]) row_1[31:0] <= show_time;
		else begin
			 row_1[7:0] <= arrow;
			 row_1[31:8] <= "   ";
		end
	end

	//判断播放模式
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) order_reg <= 0;
		
		else if(row_1[127:32] == show_6[127:32]) order_reg <= 1'b0;	//play in order
		else if(row_1[127:32] == show_7[127:32]) order_reg <= 1'b1;	//single cycle
		else order_reg <= order_reg;
	end

	//记录播放的歌曲
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) music_reg <= 0; 										    //当前无播放音乐
		else if (row_1[127:32] ==show_4[127:32])begin
                if(KEY == key2) music_reg <= 2'd1; 							//当前播放音乐1
		end               
        else if(row_1[127:32] ==show_5[127:32]) begin
                if(KEY == key2) music_reg <= 2'd2; 							//当前播放音乐2 
		end              
        else if(row_1[127:32] ==show_F1[127:32]) begin
                if(KEY == key2) music_reg <= 2'd3; 							//当前播放音乐3
		end               

		else if(row_1[127:32] ==show_F2[127:32]) begin
                if(KEY == key3) music_reg <= 2'd2; 
				else if (KEY == key4) music_reg <= 2'd3;
				else case(music_reg)
                    2'd1:   	if((cnt_min == 6'd1)&&(cnt_sec == 6'd23)) begin
								
                               case(order_reg)
                                   1'b0: music_reg <= 2'd2;
                                   1'b1: music_reg <= music_reg;
                                   default: music_reg <= music_reg;
                               endcase
					end
                            else music_reg <= music_reg;
                    2'd2:   if((cnt_min == 6'd2)&&(cnt_sec == 6'd34)) begin
								
                               case(order_reg)
                                   1'b0: music_reg <= 2'd3;
                                   1'b1: music_reg <= music_reg;
                                   default: music_reg <= music_reg;
                               endcase
					end
                            else music_reg <= music_reg;
                    2'd3:   if((cnt_min == 6'd3)&&(cnt_sec == 6'd45)) begin
								
                               case(order_reg)
                                   1'b0: music_reg <= 2'd1;
                                   1'b1: music_reg <= music_reg;
                                   default: music_reg <= music_reg;
                               endcase
					end
                            else music_reg <= music_reg;
                    default: music_reg <= music_reg;
             endcase
		end
		else if(row_1[127:32] ==show_F3[127:32]) begin
                if(KEY == key3) music_reg <= 2'd3; 
				else if (KEY == key4) music_reg <= 2'd1;
				else if((cnt_min == 6'd2)&&(cnt_sec == 6'd34)) begin
						
                        case(order_reg)
                            1'b0: music_reg <= 2'd3;
                            1'b1: music_reg <= music_reg;
                            default: music_reg <= music_reg;
                        endcase
				end
                else music_reg <= music_reg;
		end
		else if(row_1[127:32] ==show_F4[127:32]) begin
                if(KEY == key3) music_reg <= 2'd1; 
				else if (KEY == key4) music_reg <= 2'd2;
				else case(music_reg)
                    2'd1:   	if((cnt_min == 6'd1)&&(cnt_sec == 6'd23))
                               case(order_reg)
                                   1'b0: music_reg <= 2'd2;
                                   1'b1: music_reg <= music_reg;
                                   default: music_reg <= music_reg;
                               endcase
                            else music_reg <= music_reg;
                    2'd2:   if((cnt_min == 6'd2)&&(cnt_sec == 6'd34))
                               case(order_reg)
                                   1'b0: music_reg <= 2'd3;
                                   1'b1: music_reg <= music_reg;
                                   default: music_reg <= music_reg;
                               endcase
                            else music_reg <= music_reg;
                    2'd3:   if((cnt_min == 6'd3)&&(cnt_sec == 6'd45))
                               case(order_reg)
                                   1'b0: music_reg <= 2'd1;
                                   1'b1: music_reg <= music_reg;
                                   default: music_reg <= music_reg;
                               endcase
                            else music_reg <= music_reg;
                    default: music_reg <= music_reg;
             endcase
		end
    end



	//调制切歌时计数器清零信号
	clc_flag clc_flag_inst
	(
    	.clk         (clk)    ,
    	.rst_n       (rst_n)    ,
    	.music_reg   (music_reg)    ,
    	.cnt_clc1     (cnt_clc1)     
	);

	//调制放完一首完整歌曲时清零信号
	clc_flag2 clc_flag2_inst
	(
    	.clk        (clk      )     ,
    	.rst_n      (rst_n    )     ,
    	.music_reg  (music_reg)     ,
    	.cnt_sec    (cnt_sec  )     ,
    	.cnt_min    (cnt_min  )     ,
    	.cnt_clc2   (cnt_clc2 )     
	);

	//记录播放音量
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) volume_reg <= 3'd1;
		else if(row_1[127:32] == show_B[127:32]) volume_reg <= 3'd1;
		else if(row_1[127:32] == show_C[127:32]) volume_reg <= 3'd2;
		else if(row_1[127:32] == show_D[127:32]) volume_reg <= 3'd3;
		else if(row_1[127:32] == show_E[127:32]) volume_reg <= 3'd4;
		else if(row_1[127:32] == show_F[127:32]) volume_reg <= 3'd5;
		else volume_reg <= volume_reg;
	end

	//记录播放速度
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) speed_reg <= 0;
		else if(row_1[127:32] == show_8[127:32]) speed_reg <= 0;				// × 1
		else if(row_1[127:32] == show_9[127:32]) speed_reg <= 2'd1;				// × 1.25
		else if(row_1[127:32] == show_A[127:32]) speed_reg <= 2'd2;				// × 0.75
		else speed_reg <= speed_reg;
	end

	//记录暂停还是播放
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) play_reg <= 0;
		else if(row_1[127:56] == show_F2[127:56]) play_reg <= 1; 		//播放
		else if(row_1[127:56] == show_F8[127:56]) play_reg <= 0;		//暂停
		else play_reg <= play_reg;
	end

    always @(*)
        if(!rst_n)
            row_2 = show_1;
        else    
            case(row_1[127:40])		//防止之后显示界面的第一行还要加动态时间显示，row_1的后几个显示字符始终在变化，故取始终不变的前8位作为判断标志
                show_0[127:40]: row_2 = show_1;
                show_1[127:40]: row_2 = show_2;
                show_2[127:40]: row_2 = show_3;
                show_3[127:40]: row_2 = show_0;
                show_4[127:40]: row_2 = show_5;
                show_5[127:40]: row_2 = show_F1;
                show_6[127:40]: row_2 = show_7;
                show_7[127:40]: row_2 = show_6;
                show_8[127:40]: row_2 = show_9;
                show_9[127:40]: row_2 = show_A;
                show_A[127:40]: row_2 = show_8;
                show_B[127:40]: row_2 = show_C;
                show_C[127:40]: row_2 = show_D;
                show_D[127:40]: row_2 = show_E;
                show_E[127:40]: row_2 = show_F;
                show_F[127:40]: row_2 = show_B;
				show_F1[127:40]: row_2= show_4;
				show_F2[127:40]: begin 
					row_2 = show_F5;
					row_2[31:0] = show_F5[31:0];
					row_2[95:88] = 8'h01;  //上一曲标志
					row_2[71:64] = 8'h02;	//播放标志
					row_2[47:40] = 8'h00;	//下一曲标志
				end
				show_F3[127:40]: begin
					row_2 = show_F6;
					row_2[31:0] = show_F6[31:0];
					row_2[95:88] = 8'h01;  //上一曲标志
					row_2[71:64] = 8'h02;	//播放标志
					row_2[47:40] = 8'h00;	//下一曲标志
				end
				show_F4[127:40]: begin
					row_2 = show_F7;
					row_2[31:0] = show_F7[31:0];
					row_2[95:88] = 8'h01;  //上一曲标志
					row_2[71:64] = 8'h02;	//播放标志
					row_2[47:40] = 8'h00;	//下一曲标志
				end
				show_F8[127:40]: begin 
					row_2 = show_F5;
					row_2[31:0] = show_F5[31:0];
					row_2[95:88] = 8'h01;  //上一曲标志
					row_2[71:64] = 8'h03;	//暂停标志
					row_2[47:40] = 8'h00;	//下一曲标志
				end
				show_F9[127:40]: begin
					row_2 = show_F6;
					row_2[31:0] = show_F6[31:0];
					row_2[95:88] = 8'h01;  //上一曲标志
					row_2[71:64] = 8'h03;	//暂停标志
					row_2[47:40] = 8'h00;	//下一曲标志
				end
				show_FA[127:40]: begin
					row_2 = show_F7;
					row_2[31:0] = show_F7[31:0];
					row_2[95:88] = 8'h01;  //上一曲标志
					row_2[71:64] = 8'h03;	//暂停标志
					row_2[47:40] = 8'h00;	//下一曲标志
				end
                default: row_2 <=show_1;              
            endcase


	output_flag output_flag_inst
    (
    .clk          	(clk)	,
    .rst_n        	(rst_n)	,
    .order_reg	  	(order_reg)	,
	.music_reg	  	(music_reg)	,
	.volume_reg   	(volume_reg)	,
	.speed_reg	  	(speed_reg)	,
	.play_reg	  	(play_reg)	,
    .order1_flag	(order1_flag) 	,        
    .order2_flag	(order2_flag) 	,        
    .music0_flag	(music0_flag) 	,        
	.music1_flag	(music1_flag)	,        
    .music2_flag	(music2_flag) 	,        
    .music3_flag	(music3_flag) 	,        
	.volume1_flag 	(volume1_flag)	,           
    .volume2_flag 	(volume2_flag)	,           
    .volume3_flag 	(volume3_flag)	,           
    .volume4_flag 	(volume4_flag)	,           
    .volume5_flag 	(volume5_flag)	,           
	.speed1_flag	(speed1_flag) 	,        
    .speed2_flag	(speed2_flag) 	,        
    .speed3_flag	(speed3_flag) 	,        
	.play_flag 	(play_flag) 	,        
    .pause_flag 	(pause_flag)          
    );


endmodule
