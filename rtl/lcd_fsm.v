module lcd_fsm(
input            clk               ,
input            rst_n             ,
input            key1_flag         ,
input            key2_flag         ,
input            key3_flag         ,
input            key4_flag         ,
output reg [1:0] music             ,
output reg [1:0] speed             ,
output reg       mode              ,
output reg [2:0] volume
);

reg [2:0] KEY;


//按键状态
parameter key1 = 2'b00, key2 = 2'b01, key3 = 2'b10, key4 = 2'b11;                   //按键的flag标志


//内部寄存器状态参数
parameter mu1 = 2'b00, mu2 = 2'b01, mu3 = 2'b10, mu4 = 2'b11;                       //选中的音乐
parameter sp1 = 2'b00, sp2 = 2'b01, sp3 = 2'b10;                                    //选中的播放速度
parameter vl1 = 3'b000, vl2 = 3'b001, vl3 = 3'b010, vl4 = 3'b011, vl5 = 3'b100;     //选中的播放音量大小
parameter md1 = 1'b0, md2 = 1'b1;                                                   //选中的播放模式
//parameter tm1 = 2'b00, tm2 = 2'b01, tm3 = 2'b10, tm4 = 2'b11;                     //选中的定时时长


//存储LCD显示界面的状态参数
parameter S0=5'd0, S1=5'd1, S2=5'b00010, S3=5'b00011, S4=5'b00100, S5=5'b00101, S6=5'd6;
parameter S7=5'b00111, S8=5'b01000, S9=5'b01001, S10=5'b01010, S11=5'b01011, S12=5'b01100, S13=5'b01101;
parameter S14=5'b01110, S15=5'b01111, S16=5'b10000, S17=5'b10001, S18=5'b10010, S19=5'b10011, S20=5'b10100 ;


//内部寄存器,用来存储播放的状态
reg [4:0] nextstate, currentstate;

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

//显示界面状态转移
always @(posedge clk or negedge rst_n) begin
    if  (!rst_n)  
        currentstate <= S1;                         //上电复位显示的第一个界面,S0状态我没有使用
    else   
        currentstate <= nextstate;
end

always @(*) begin
    if(!rst_n) begin
        nextstate = S1;
    end
    else begin
        case(currentstate)
        S1: if(KEY == key1) nextstate = S1;
            else if(KEY == key2) nextstate = S5;
            else if(KEY == key3) nextstate = S2;
            else if(KEY == key4) nextstate = S4;
            else nextstate = S1;

        S2: if(KEY == key1) nextstate = S2;
            else if(KEY == key2) nextstate = S8;
            else if(KEY == key3) nextstate = S3;
            else if(KEY == key4) nextstate = S1;
            else nextstate = S2;

        S3: if(KEY == key1) nextstate = S3;
            else if(KEY == key2) nextstate = S10;
            else if(KEY == key3) nextstate = S4;
            else if(KEY == key4) nextstate = S2;
            else nextstate = S3;

        S4: if(KEY == key1) nextstate = S4;
            else if(KEY == key2) nextstate = S13;
            else if(KEY == key3) nextstate = S1;
            else if(KEY == key4) nextstate = S3;
            else nextstate = S4;

        S5: if(KEY == key1) nextstate = S1;
            else if(KEY == key2) nextstate = S18;
            else if(KEY == key3) nextstate = S6;
            else if(KEY == key4) nextstate = S7;
            else nextstate = S5;

        S6: if(KEY == key1) nextstate = S1;
            else if(KEY == key2) nextstate = S19;
            else if(KEY == key3) nextstate = S7;
            else if(KEY == key4) nextstate = S5;
            else nextstate = S6;

        S7: if(KEY == key1) nextstate = S1;
            else if(KEY == key2) nextstate = S20;
            else if(KEY == key3) nextstate = S5;
            else if(KEY == key4) nextstate = S6;
            else nextstate = S7;

        S8: if(KEY == key1) nextstate = S2;
            else if(KEY == key2) nextstate = S2;
            else if(KEY == key3) nextstate = S9;
            else if(KEY == key4) nextstate = S9;
            else nextstate = S8;

        S9: if(KEY == key1) nextstate = S2;
            else if(KEY == key2) nextstate = S2;
            else if(KEY == key3) nextstate = S8;
            else if(KEY == key4) nextstate = S8;
            else nextstate = S9;

        S10: if(KEY == key1) nextstate = S3;
            else if(KEY == key2) nextstate = S3;
            else if(KEY == key3) nextstate = S11;
            else if(KEY == key4) nextstate = S12;
            else nextstate = S10;

        S11: if(KEY == key1) nextstate = S3;
            else if(KEY == key2) nextstate = S3;
            else if(KEY == key3) nextstate = S12;
            else if(KEY == key4) nextstate = S10;
            else nextstate = S11;

        S12: if(KEY == key1) nextstate = S3;
            else if(KEY == key2) nextstate = S3;
            else if(KEY == key3) nextstate = S10;
            else if(KEY == key4) nextstate = S11;
            else nextstate = S12;

        S13: if(KEY == key1) nextstate = S4;
            else if(KEY == key2) nextstate = S4;
            else if(KEY == key3) nextstate = S14;
            else if(KEY == key4) nextstate = S17;
            else nextstate = S13;

        S14: if(KEY == key1) nextstate = S4;
            else if(KEY == key2) nextstate = S4;
            else if(KEY == key3) nextstate = S15;
            else if(KEY == key4) nextstate = S13;
            else nextstate = S14;

        S15: if(KEY == key1) nextstate = S4;
            else if(KEY == key2) nextstate = S4;
            else if(KEY == key3) nextstate = S16;
            else if(KEY == key4) nextstate = S14;
            else nextstate = S15;
                    
        S16: if(KEY == key1) nextstate = S4;
            else if(KEY == key2) nextstate = S4;
            else if(KEY == key3) nextstate = S17;
            else if(KEY == key4) nextstate = S15;
            else nextstate = S16;

        S17: if(KEY == key1) nextstate = S4;
            else if(KEY == key2) nextstate = S4;
            else if(KEY == key3) nextstate = S13;
            else if(KEY == key4) nextstate = S16;
            else nextstate = S17;

        S18: if(KEY == key1) nextstate = S5;
            else if(KEY == key2) nextstate = S18;
            else if(KEY == key3) nextstate = S18;
            else if(KEY == key4) nextstate = S18;
            else nextstate = S18;

        S19: if(KEY == key1) nextstate = S6;
            else if(KEY == key2) nextstate = S19;
            else if(KEY == key3) nextstate = S19;
            else if(KEY == key4) nextstate = S19;
            else nextstate = S19;

        S20: if(KEY == key1) nextstate = S7;
            else if(KEY == key2) nextstate = S20;
            else if(KEY == key3) nextstate = S20;
            else if(KEY == key4) nextstate = S20;
            else nextstate = S20;

        default: nextstate = S1;
            
        endcase
    end
end


//配置音乐寄存器
always @(posedge clk or negedge rst_n)
    if (!rst_n)  
        music <= mu1;
    else
        case(currentstate)
        S5:if(KEY == key2) music <= mu1;
           else  music <= music;

        S6:if(KEY == key2) music <= mu2;
           else  music <= music;

        S7:if(KEY == key2) music <= mu3;
           else  music <= music;

        default:music <= music;
        endcase


//配置播放模式寄存器
always @(posedge clk or negedge rst_n)
    if (!rst_n)  
        mode = md1;                               //上电复位默认顺序播放
    else 
        case(currentstate)
        S8: if(KEY == key2) mode <= md1;
            else mode <= mode;

        S9: if(KEY == key2) mode <= md2;
            else mode <= mode;               //仅在“选择模式界面”按下“确认键”才会改变寄存器值
                                                      //在“其他界面”，或“选择模式界面”按下“非确认键”不会改变寄存器值
        default: mode <= mode; 
        endcase

//配置播放速度寄存器
always @(posedge clk or negedge rst_n) 
    if(!rst_n)
        speed <= sp1;                               //上电复位默认原速播放
    else 
        case(currentstate)
        S10: if(KEY == key2) speed <= sp1;
            else speed <= speed;

        S11: if(KEY == key2) speed = sp2;
            else speed <= speed;

        S12: if(KEY == key2) speed = sp3;
            else speed <= speed;               //仅在“选择速度界面”按下“确认键”才会改变寄存器值
                                                        //在“其他界面”，或“选择速度界面”按下“非确认键”不会改变寄存器值
        default: speed <= speed; 
        endcase

//配置播放音量寄存器
always @(posedge clk or negedge rst_n)
    if(!rst_n)
        volume = vl1;                               //上电复位默认音量1
    else 
        case(currentstate)
        S13: if(KEY == key2) volume = vl1;
            else volume = volume;

        S14: if(KEY == key2) volume = vl2;
            else volume = volume;

        S15: if(KEY == key2) volume = vl3;
            else volume = volume;

        S16: if(KEY == key2) volume = vl4;
            else volume = volume;

        S17: if(KEY == key2) volume = vl5;
            else volume = volume;               //仅在“选择音量界面”按下“确认键”才会改变寄存器值
                                                        //在“其他界面”，或“选择音量界面”按下“非确认键”不会改变寄存器值
        default: volume = volume; 
        endcase

endmodule