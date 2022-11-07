`timescale 1ns/1ns

	module tb_LCD;
	reg 		clk			;
	reg 		rst_n		;
    reg         KEY1   ;
    reg         KEY2   ;
    reg         KEY3   ;
    reg         KEY4   ;			//输入信号要在always块中赋值，故为reg型
	wire 		LCD_E 		;
	wire 	 	LCD_RS		;
	wire [7:0]  LCD_DATA	;			//输出信号用连线引出，便于观察，故为wire型
	wire		LCD_ON		;
	wire		LCD_RW;
	wire		order_reg;
	wire[1:0]	music_reg;
	wire[2:0]	volume_reg;
	wire[1:0]	speed_reg;
	wire		play_reg;




	initial begin
		clk <= 1'b0;
		rst_n <= 1'b0;
		#20
		KEY1 <= 1'b1;
		KEY2 <= 1'b1;
		KEY3 <= 1'b1;
		KEY4 <= 1'b1;
		rst_n <=1'b1;
		#15000000
		KEY2 <= 1'b0;
		#20000000
		KEY2 <= 1'b1;					//确认
		#20000000
		KEY2 <= 1'b0;
		#20000000
		KEY2 <= 1'b1;					//确认
		#20000000
		KEY3 <= 1'b0;
		#20000000
		KEY3 <= 1'b1;					//下一首
		#20000000
		KEY1 <= 1'b0;
		#20000000
		KEY1 <= 1'b1;					//返回
		#20000000
		KEY2 <= 1'b0;
		#20000000
		KEY2 <= 1'b1;					//确认
		#20000000
		KEY1 <= 1'b0;
		#20000000
		KEY1 <= 1'b1;					//返回
		#20000000
		KEY3 <= 1'b0;
		#20000000
		KEY3 <= 1'b1;					//下翻一首
		#20000000
		KEY2 <= 1'b0;
		#20000000
		KEY2 <= 1'b1;					//确认
		#20000000
		KEY1 <= 1'b0;
		#20000000
		KEY1 <= 1'b1;					//返回
		#20000000
		KEY1 <= 1'b0;
		#20000000
		KEY1 <= 1'b1;					//返回
		#20000000
		KEY2 <= 1'b0;
		#20000000
		KEY2 <= 1'b1;					//确认
		#20000000
		KEY2 <= 1'b0;
		#20000000
		KEY2 <= 1'b1;					//暂停
	end

	always #10 clk <= ~clk;

	LCD LCD_inst
	(
		.clk		 (clk) 	,
		.rst_n	 	 (rst_n) 	,
    	.KEY1	 (KEY1)   ,
    	.KEY2	 (KEY2)   ,
    	.KEY3	 (KEY3)   ,
    	.KEY4	 (KEY4)   ,
		.LCD_E 	 	 (LCD_E) 	,
		.LCD_RS	 	 (LCD_RS) 	,
		.LCD_DATA 	 (LCD_DATA) ,	
		.LCD_ON			(LCD_ON	),
    	.LCD_RW			(LCD_RW	),
		.order_reg		(order_reg),
		.music_reg		(music_reg),
		.volume_reg 	(volume_reg),
		.speed_reg		(speed_reg),
		.play_reg	(play_reg)
	);



	endmodule