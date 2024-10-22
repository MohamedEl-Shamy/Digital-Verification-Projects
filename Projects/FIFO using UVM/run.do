# vlib work
# vlog -f src_files.list +cover -covercells 
# vsim -voptargs=+acc work.top -cover

# add wave /top/FIFO_if_inst/*
# coverage save FIFO.ucdb -onexit

# run -all

# quit -sim 
# vcover report FIFO.ucdb -details -annotate -all -output  FIFO_Coverage.txt 

vlib work
vlog -f src_files.list +cover -covercells 
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=on -cover

add wave /top/FIFO_if_inst/*
coverage save FIFO.ucdb -onexit

run -all

quit -sim 
vcover report FIFO.ucdb -details -annotate -all -output  FIFO_Coverage.txt
