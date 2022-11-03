module LCD1602(
	input 				clk			,
	input 				rst_n		,
    input               key1_flag   ,
    input               key2_flag   ,
    input               key3_flag   ,
    input               key4_flag   ,
	output 				LCD_E 		,
	output 	reg 		LCD_RS		,
	output 	reg[7:0]	LCD_DATA	
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
			if(cnt_500hz == TIME_500HZ/2-1'b1)
				cnt_500hz <= 1'b0;
			else
				cnt_500hz <= cnt_500hz+1'b1;
		else
			cnt_500hz <= 1'b0;
	
	assign LCD_E=(cnt_500hz>(TIME_500HZ-1'b1)/2)?1'b0:1'b1;//使能端,每个工作周期一次下降沿,执行一次命令
	wire write_flag=(cnt_500hz==TIME_500HZ-1'b1)?1'b1:1'b0;//每到一个工作周期,write_flag置高一周期


    //根据按键进行显示界面的切换
    parameter key1 = 2'b00, key2 = 2'b01, key3 = 2'b10, key4 = 2'b11;                   //按键的flag标志
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



	//状态机有40种状态,此处用了格雷码,一次只有一位变化(在二进制下)
	parameter IDLE = 8'h00;						//闲置状态
	parameter SET_FUNCTION = 8'h01;				//工作方式设置，用来设置8(4)数据接口、2(1)行显示、5*8(5*10)dot
	parameter DISP_OFF = 8'h03;					//显示开关设置关，设置是否显示字符和光标
	parameter DISP_CLEAR = 8'h02;					//清屏
	parameter ENTRY_MODE = 8'h06;					//进入模式设置，写入新数据后光标是否移动？移动方向？
	parameter DISP_ON = 8'h07;					//显示开关设置开
	parameter ROW1_ADDR = 8'h05;					//第一行显示首地址(DDRAM地址)
	parameter ROW1_0 = 8'h04;						//显示字符数据(DDRAM中的数据)
	parameter ROW1_1 = 8'h0C;
	parameter ROW1_2 = 8'h0D;
	parameter ROW1_3 = 8'h0F;
	parameter ROW1_4 = 8'h0E;
	parameter ROW1_5 = 8'h0A;
	parameter ROW1_6 = 8'h0B;
	parameter ROW1_7 = 8'h09;
	parameter ROW1_8 = 8'h08;
	parameter ROW1_9 = 8'h18;
	parameter ROW1_A = 8'h19;
	parameter ROW1_B = 8'h1B;
	parameter ROW1_C = 8'h1A;
	parameter ROW1_D = 8'h1E;
	parameter ROW1_E = 8'h1F;
	parameter ROW1_F = 8'h1D;
	parameter ROW2_ADDR = 8'h1C;					//第二行显示首地址(DDRAM地址)
	parameter ROW2_0 = 8'h14;
	parameter ROW2_1 = 8'h15;
	parameter ROW2_2 = 8'h17;
	parameter ROW2_3 = 8'h16;
	parameter ROW2_4 = 8'h12;
	parameter ROW2_5 = 8'h13;
	parameter ROW2_6 = 8'h11;
	parameter ROW2_7 = 8'h10;
	parameter ROW2_8 = 8'h30;
	parameter ROW2_9 = 8'h31;
	parameter ROW2_A = 8'h33;
	parameter ROW2_B = 8'h32;
	parameter ROW2_C = 8'h36;
	parameter ROW2_D = 8'h37;
	parameter ROW2_E = 8'h35;
	parameter ROW2_F = 8'h34;
	
	reg[5:0]currentstate;//Current state,当前状态
	reg[5:0]nextstate;//Next state,下一状态
	
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
			DISP_ON:				nextstate = ROW1_ADDR;
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
			default:;
		endcase



	//RS端口信号控制
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			LCD_RS <= 1'b0;//为0时输入指令,为1时输入数据
		else if(write_flag)
			//当状态为七个指令任意一个,将RS置为指令输入状态
			if((nextstate == SET_FUNCTION)||(nextstate==DISP_OFF)||(nextstate==DISP_CLEAR)||(nextstate==ENTRY_MODE)||(nextstate==DISP_ON)||(nextstate==ROW1_ADDR)||(nextstate==ROW2_ADDR))
				LCD_RS <= 1'b0; 
			else
				LCD_RS <= 1'b1;
		else
			LCD_RS <= LCD_RS;


	//显示输出
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			LCD_DATA<=1'b0;
		else if(write_flag)
			case(nextstate)
				IDLE:					LCD_DATA <= 8'hxx;
				SET_FUNCTION:			LCD_DATA <= 8'h38;//8'b0011_1000,工作方式设置:DL=1(DB4,8位数据接口),N=1(DB3,两行显示),L=0(DB2,5x8点阵显示).
				DISP_OFF:				LCD_DATA <= 8'h08;//8'b0000_1000,显示开关设置:D=0(DB2,显示关),C=0(DB1,光标不显示),D=0(DB0,光标不闪烁)
				DISP_CLEAR:				LCD_DATA <= 8'h01;//8'b0000_0001,清屏
				ENTRY_MODE:				LCD_DATA <= 8'h06;//8'b0000_0110,进入模式设置:I/D=1(DB1,写入新数据光标右移),S=0(DB0,显示不移动)
				DISP_ON:				LCD_DATA <= 8'h0c;//8'b0000_1100,显示开关设置:D=1(DB2,显示开),C=0(DB1,光标不显示),D=0(DB0,光标不闪烁)
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
				ROW1_F:					LCD_DATA <= arrow;
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
			endcase
		else
			LCD_DATA<=LCD_DATA;



	//配置想要输出的字符数据，共16*8=128bit
	reg[127:0]  row_1;
	reg[127:0]  row_2;
        
    parameter show_0 = "MUSIC           ";
    parameter show_1 = "MODE            ";
    parameter show_2 = "SPEED           ";
    parameter show_3 = "VOLUME          ";
    parameter show_4 = "music_1         ";
    parameter show_5 = "music_2         ";
    parameter show_6 = "play in order   ";
    parameter show_7 = "single cycle    ";
    parameter show_8 = "1               ";
    parameter show_9 = "1.25            ";
    parameter show_A = "0.75            ";
    parameter show_B = "VOLUME_1        ";
    parameter show_C = "VOLUME_2        ";
    parameter show_D = "VOLUME_3        ";
    parameter show_E = "VOLUME_4        ";
    parameter show_F = "VOLUME_5        ";
    parameter arrow = 8'b0111_1111;
    
    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            row_1 = show_0;
        else    
            case(row_1)
                show_0: if(KEY == key1) row_1 <=show_0;
                        else if(KEY == key2) row_1 <=show_4;
                        else if(KEY == key3) row_1 <=show_1;
                        else row_1 <= show_3;

                show_1: if(KEY == key1) row_1 <=show_1;
                        else if(KEY == key2) row_1 <=show_6;
                        else if(KEY == key3) row_1 <=show_2;
                        else row_1 <= show_0;
                
                show_2: if(KEY == key1) row_1 <=show_2;
                        else if(KEY == key2) row_1 <=show_8;
                        else if(KEY == key3) row_1 <=show_3;
                        else row_1 <= show_1;

                show_3: if(KEY == key1) row_1 <=show_3;
                        else if(KEY == key2) row_1 <=show_B;
                        else if(KEY == key3) row_1 <=show_0;
                        else row_1 <= show_2;

                show_4: if(KEY == key1) row_1 <=show_0;
                        else if(KEY == key2) row_1 <=show_0;
                        else if(KEY == key3) row_1 <=show_5;
                        else row_1 <= show_5;

                show_5: if(KEY == key1) row_1 <=show_0;
                        else if(KEY == key2) row_1 <=show_0;
                        else if(KEY == key3) row_1 <=show_4;
                        else row_1 <= show_4;

                show_6: if(KEY == key1) row_1 <=show_1;
                        else if(KEY == key2) row_1 <=show_1;
                        else if(KEY == key3) row_1 <=show_7;
                        else row_1 <= show_7;

                show_7: if(KEY == key1) row_1 <=show_1;
                        else if(KEY == key2) row_1 <=show_1;
                        else if(KEY == key3) row_1 <=show_6;
                        else row_1 <= show_6;

                show_8: if(KEY == key1) row_1 <=show_2;
                        else if(KEY == key2) row_1 <=show_2;
                        else if(KEY == key3) row_1 <=show_9;
                        else row_1 <= show_A;

                show_9: if(KEY == key1) row_1 <=show_2;
                        else if(KEY == key2) row_1 <=show_2;
                        else if(KEY == key3) row_1 <=show_A;
                        else row_1 <= show_8;

                show_A: if(KEY == key1) row_1 <=show_2;
                        else if(KEY == key2) row_1 <=show_2;
                        else if(KEY == key3) row_1 <=show_8;
                        else row_1 <= show_9;

                show_B: if(KEY == key1) row_1 <=show_3;
                        else if(KEY == key2) row_1 <=show_3;
                        else if(KEY == key3) row_1 <=show_C;
                        else row_1 <= show_F;

                show_C: if(KEY == key1) row_1 <=show_3;
                        else if(KEY == key2) row_1 <=show_3;
                        else if(KEY == key3) row_1 <=show_D;
                        else row_1 <= show_B;

                show_D: if(KEY == key1) row_1 <=show_3;
                        else if(KEY == key2) row_1 <=show_3;
                        else if(KEY == key3) row_1 <=show_E;
                        else row_1 <= show_C;

                show_E: if(KEY == key1) row_1 <=show_3;
                        else if(KEY == key2) row_1 <=show_3;
                        else if(KEY == key3) row_1 <=show_F;
                        else row_1 <= show_D;

                show_F: if(KEY == key1) row_1 <=show_3;
                        else if(KEY == key2) row_1 <=show_3;
                        else if(KEY == key3) row_1 <=show_B;
                        else row_1 <= show_E;

                default: row_1 <= show_0;
            endcase 


    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            row_2 <= show_1;
        else    
            case(row_1)
                show_0: row_2 <= show_1;
                show_1: row_2 <= show_2;
                show_2: row_2 <= show_3;
                show_3: row_2 <= show_0;
                show_4: row_2 <= show_5;
                show_5: row_2 <= show_4;
                show_6: row_2 <= show_7;
                show_7: row_2 <= show_6;
                show_8: row_2 <= show_9;
                show_9: row_2 <= show_A;
                show_A: row_2 <= show_8;
                show_B: row_2 <= show_C;
                show_C: row_2 <= show_D;
                show_D: row_2 <= show_E;
                show_E: row_2 <= show_F;
                show_F: row_2 <= show_B;
                default: row_2 <=show_1;              
            endcase


endmodule






