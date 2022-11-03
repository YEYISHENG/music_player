`timescale 1ns/1ns

	module tb_LCD;
	reg 		clk			;
	reg 		rst_n		;
    reg         key1_flag   ;
    reg         key2_flag   ;
    reg         key3_flag   ;
    reg         key4_flag   ;			//输入信号要在always块中赋值，故为reg型
	wire 		LCD_E 		;
	wire 	 	LCD_RS		;
	wire [7:0]  LCD_DATA	;			//输出信号用连线引出，便于观察，故为wire型
	


	initial begin
		clk <= 1'b0;
		rst_n <= 1'b0;
		#20
		key1_flag <= 1'b0;
		key2_flag <= 1'b0;
		key3_flag <= 1'b0;
		key4_flag <= 1'b0;
		rst_n <=1'b1;
		#200
		key2_flag <= 1'b1;
		#20
		key2_flag <= 1'b0;
		#20
		key3_flag <= 1'b1;
		#20
		key3_flag <= 1'b0;
		#20
		key1_flag <= 1'b1;
		#20
		key1_flag <= 1'b0;
		#20
		key3_flag <= 1'b1;
		#20
		key3_flag <= 1'b0;
		#20
		key3_flag <= 1'b1;
		#20
		key3_flag <= 1'b0;
		#20
		key2_flag <= 1'b1;
		#20
		key2_flag <= 1'b0;
		#20
		key4_flag <= 1'b1;
		#20
		key4_flag <= 1'b0;
		#20
		key1_flag <= 1'b1;
		#20
		key1_flag <= 1'b0;
		#20
		key3_flag <= 1'b1;
		#20
		key3_flag <= 1'b0;
		#20
		key2_flag <= 1'b1;
		#20
		key2_flag <= 1'b0;
		#20
		key3_flag <= 1'b1;
		#20
		key3_flag <= 1'b0;
		#20
		key3_flag <= 1'b1;
		#20
		key3_flag <= 1'b0;
	end

	always #10 clk <= ~clk;

	LCD LCD_inst
	(
		.clk		 (clk) 	,
		.rst_n	 	 (rst_n) 	,
    	.key1_flag	 (key1_flag)   ,
    	.key2_flag	 (key2_flag)   ,
    	.key3_flag	 (key3_flag)   ,
    	.key4_flag	 (key4_flag)   ,
		.LCD_E 	 	 (LCD_E) 	,
		.LCD_RS	 	 (LCD_RS) 	,
		.LCD_DATA 	 (LCD_DATA) 	
	);



	endmodule