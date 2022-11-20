module reg2sign 
    #(parameter LENGTH = 3)
    (
    input                       clk         ,
    input                       rst_n       ,
    input wire[LENGTH-1:0]      reg_sign    ,
    output  reg                 flag_sign
    );

    reg [LENGTH-1:0] temp_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) temp_reg <= 0;
        else temp_reg <= reg_sign;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) flag_sign <= 0;
        else flag_sign = (temp_reg == reg_sign)?1'b0:1'b1;
    end
    
endmodule
