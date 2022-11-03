transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl/led_alarm.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl/data_gen.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/par/ipcore {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/par/ipcore/pll_clk.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl/top_sd_rw.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl/sd_write.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl/sd_read.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl/sd_init.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/rtl/sd_ctrl_top.v}
vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/par/db {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/par/db/pll_clk_altpll.v}

vlog -vlog01compat -work work +incdir+E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/par/../sim {E:/academic/shuzi_keshe/ziliao/29_top_sd_rw/par/../sim/tb_top_sd_rw.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_top_sd_rw

add wave *
view structure
view signals
run -all
