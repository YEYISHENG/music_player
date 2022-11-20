module clc_flag2
(
    input               clk             ,
    input               rst_n           ,
    input [1:0]         music_reg       ,
    input [7:0]         cnt_sec         ,
    input [7:0]         cnt_min         ,
    output reg          cnt_clc2        
);


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) cnt_clc2<= 0;
        else case(music_reg)
                2'd1: begin  if((cnt_min == 6'd1)&&(cnt_sec == 6'd23)) cnt_clc2 <= 1'b1;
                             else cnt_clc2 <= 1'b0;
                end
                2'd2: begin  if((cnt_min == 6'd2)&&(cnt_sec == 6'd34)) cnt_clc2 <= 1'b1;
                             else cnt_clc2 <= 1'b0;
                end
                2'd3: begin  if((cnt_min == 6'd3)&&(cnt_sec == 6'd45)) cnt_clc2 <= 1'b1;
                             else cnt_clc2 <= 1'b0;
                end
             endcase
    end



endmodule