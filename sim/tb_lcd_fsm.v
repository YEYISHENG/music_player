`timescale 1ns/1ns

module tb_lcd_fsm;

reg clk;
reg rst_n;
reg key1_flag;
reg key2_flag;
reg key3_flag;
reg key4_flag;

wire [1:0] music ;
wire [1:0] speed ;
wire       mode  ;
wire [2:0] volume;

initial begin
    clk<= 1'b0;
    rst_n <= 1'b0;
    #20
    key1_flag <= 1'b0;
    key2_flag <= 1'b0;
    key3_flag <= 1'b0;
    key4_flag <= 1'b0;
    rst_n <= 1'b1;
    #200
    key2_flag <= 1'b1;
    #20
    key2_flag <= 1'b0;
    #20
    key3_flag <= 1'b1;
    #20
    key3_flag <= 1'b0;  
    #20 
    key2_flag <= 1'b1;
    #20
    key2_flag <= 1'b0;
    #20 
    key1_flag <= 1'b1;
    #20
    key1_flag <= 1'b0;
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
    key2_flag <= 1'b1;
    #20
    key2_flag <= 1'b0;
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
    key2_flag <= 1'b1;
    #20
    key2_flag <= 1'b0;
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
    #20 
    key2_flag <= 1'b1;
    #20
    key2_flag <= 1'b0;    
end

always #10 clk <= ~clk;

lcd_fsm lcd_fsm_inst(
.clk          (clk)     ,
.rst_n        (rst_n)     ,
.key1_flag    (key1_flag )     ,
.key2_flag    (key2_flag)     ,
.key3_flag    (key3_flag)     ,
.key4_flag    (key4_flag)     ,

.music        (music)     ,
.speed        (speed )     ,
.mode         (mode )     ,
.volume       (volume)
);





endmodule
