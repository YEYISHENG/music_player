module output_flag  //调制输出接口
    (
    input               clk          ,
    input               rst_n        ,
    input wire			order_reg	 ,
	input wire[1:0]		music_reg	 ,
	input wire[2:0]		volume_reg   ,
	input wire[1:0]		speed_reg	 ,
	input wire			play_reg	 ,
    output 	reg		    order1_flag	 ,           //play in order标志(默认) order_reg = 0
    output 	reg		    order2_flag	 ,           //single cycle标志       order_reg = 1
    output  reg    		music0_flag	 ,           //没有歌曲被选中标志(默认)music_reg = 0
	output  reg    		music1_flag	 ,           //music1标志              music_reg = 1
    output  reg         music2_flag	 ,           //music2标志              music_reg = 2
    output  reg         music3_flag	 ,           //music3标志              music_reg = 3
	output  reg    		volume1_flag ,           //volume1标志(默认)        volume_reg = 1
    output  reg    		volume2_flag ,           //volume2标志              volume_reg = 2
    output  reg    		volume3_flag ,           //volume3标志              volume_reg = 3
    output  reg    		volume4_flag ,           //volume4标志              volume_reg = 4
    output  reg    		volume5_flag ,           //volume5标志              volume_reg = 5
	output  reg    		speed1_flag	 ,           // × 1标志(默认)           speed_reg = 0
    output  reg    		speed2_flag	 ,           // × 1.25标志             speed_reg = 1
    output  reg    		speed3_flag	 ,           // × 0.75标志             speed_reg = 2
	output 	reg		    play_flag 	 ,           //play标志                 play_reg = 1
    output 	reg		    pause_flag 	             //pause标志(默认)          play_reg = 0
    );
    wire 			    temp_order_flag	;
    wire      		    temp_music_flag	;
    wire      		    temp_volume_flag    ;
    wire      		    temp_speed_flag	    ;
    wire 			    temp_play_flag	    ;




    reg2sign #(1) reg2sign_inst_order(
    .clk        (clk) ,
    .rst_n      (rst_n) ,
    .reg_sign   (order_reg) ,
    .flag_sign  (temp_order_flag)
    );

    reg2sign #(2) reg2sign_inst_music(
    .clk        (clk) ,
    .rst_n      (rst_n) ,
    .reg_sign   (music_reg) ,
    .flag_sign  (temp_music_flag)
    );

    reg2sign #(3) reg2sign_inst_volume(
    .clk        (clk) ,
    .rst_n      (rst_n) ,
    .reg_sign   (volume_reg) ,
    .flag_sign  (temp_volume_flag)
    );

    reg2sign #(2) reg2sign_inst_speed(
    .clk        (clk) ,
    .rst_n      (rst_n) ,
    .reg_sign   (speed_reg) ,
    .flag_sign  (temp_speed_flag)
    );

    reg2sign #(1) reg2sign_inst_play(
    .clk        (clk) ,
    .rst_n      (rst_n) ,
    .reg_sign   (play_reg) ,
    .flag_sign  (temp_play_flag)
    );


    //调制播放顺序输出信号
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) order1_flag <= 1'b1;
        else if(order_reg == 1'd0) order1_flag <= temp_order_flag;
        else order1_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) order2_flag <= 1'b0;
        else if(order_reg == 1'd1) order2_flag <= temp_order_flag;
        else order2_flag <= 1'b0;
    end


    //调制播放歌曲输出信号
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) music0_flag <= 1'b1;
        else music0_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) music1_flag <= 1'b0;
        else if(music_reg == 2'd1) music1_flag <= temp_music_flag;
        else music1_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) music2_flag <= 1'b0;
        else if(music_reg == 2'd2) music2_flag <= temp_music_flag;
        else music2_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) music3_flag <= 1'b0;
        else if(music_reg == 2'd3) music3_flag <= temp_music_flag;
        else music3_flag <= 1'b0;
    end


    //调制播放音量输出信号
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) volume1_flag <= 1'b1;
        else if(volume_reg == 3'd1) volume1_flag <= temp_volume_flag;
        else volume1_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) volume2_flag <= 1'b0;
        else if(volume_reg == 3'd2) volume2_flag <= temp_volume_flag;
        else volume2_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) volume3_flag <= 1'b0;
        else if(volume_reg == 3'd3) volume3_flag <= temp_volume_flag;
        else volume3_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) volume4_flag <= 1'b0;
        else if(volume_reg == 3'd4) volume4_flag <= temp_volume_flag;
        else volume4_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) volume5_flag <= 1'b0;
        else if(volume_reg == 3'd5) volume5_flag <= temp_volume_flag;
        else volume5_flag <= 1'b0;
    end


    //调制播放速度输出信号
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) speed1_flag <= 1'b1;
        else if(speed_reg == 2'd0) speed1_flag <= temp_speed_flag;
        else speed1_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) speed2_flag <= 1'b0;
        else if(speed_reg == 2'd1) speed2_flag <= temp_speed_flag;
        else speed2_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) speed3_flag <= 1'b0;
        else if(speed_reg == 2'd2) speed3_flag <= temp_speed_flag;
        else speed3_flag <= 1'b0;
    end

    //调制play pause输出信号
    always @(posedge clk or negedge rst_n) begin        //pause标志
        if(!rst_n) pause_flag <= 1'b1;
        else if(play_reg == 2'd0) pause_flag <= temp_play_flag;
        else pause_flag <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin        //play标志
        if(!rst_n) play_flag <= 1'b0;          
        else if(play_reg == 2'd1) play_flag <= temp_play_flag;
        else play_flag <= 1'b0;
    end

    





endmodule
