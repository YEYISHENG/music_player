`timescale 1ns/1ns
module tb_top_sd_rw();

reg sys_clk;
reg sys_rst_n;
reg sd_miso;
wire  sd_clk;
wire  sd_cs;
wire  sd_mosi;
wire [3:0] led;

initial begin
    sys_clk <= 1'b0;
    sys_rst_n <= 1'b0;
    sd_miso <= 1'b1;
    #200
    sys_rst_n <= 1'b1;
end

always #10 sys_clk <= ~sys_clk;




top_sd_rw inst(
.sys_clk    () ,  //系统时钟
.sys_rst_n  () ,  //系统复位，低电平有效

.sd_miso    () ,  //SD卡SPI串行输入数据信号
.sd_clk     () ,  //SD卡SPI时钟信号
.sd_cs      () ,  //SD卡SPI片选信号
.sd_mosi    () ,  //SD卡SPI串行输出数据信号

.led        ()    //LED灯
    );








endmodule
