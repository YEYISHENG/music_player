module clc_flag
(
    input                 clk             ,
    input                 rst_n           ,
    input   [1:0]         music_reg       ,
    output                cnt_clc1          
);

reg [1:0] temp_music_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) temp_music_reg <= 0;
    else temp_music_reg <= music_reg;
end


assign cnt_clc1 = (music_reg == temp_music_reg)?1'b0:1'b1;

endmodule