vlib work
vlog +define+SIM FIFO.sv FIFO_shared_pkg.sv FIFO_interface.sv FIFO_transaction_package.sv FIFO_coverage_package.sv FIFO_scoreboard_package.sv FIFO_tb.sv FIFO_monitor.sv FIFO_top.sv +cover -covercells
vsim -voptargs=+acc work.Top -cover
add wave /Top/inter/*
coverage save Top.ucdb -onexit
run -all

#quit -sim
#vcover report Top.ucdb -details -annotate -all -output FIFO_coverage.txt 