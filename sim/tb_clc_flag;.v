`timescale 1ns/1ns
module tb_clc_flag;

reg         clk;
reg         rst_n;
reg [1:0]   music_reg;
wire        cnt_clc;


initial begin
    clk <= 1'b0;
    rst_n <= 1'b0;
    #20
    rst_n <= 1'b1;
    music_reg <= 2'd1;
    #200
    music_reg <= 2'd2;
    #80
    music_reg <= 2'd3;
    #80
    music_reg <= 2'd2;
    #80
    music_reg <= 2'd1;
end


always  begin
    #10
    clk <= ~clk; 
end


clc_flag clc_flag_inst
(
    .clk        (clk)     ,
    .rst_n      (rst_n)     ,
    .music_reg  (music_reg)     ,
    .cnt_clc    (cnt_clc)      
);

endmodule //Untitled-2