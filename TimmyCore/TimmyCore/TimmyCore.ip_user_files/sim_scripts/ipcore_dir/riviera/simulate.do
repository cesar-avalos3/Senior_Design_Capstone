onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ddr -L xil_defaultlib -L secureip -O5 xil_defaultlib.ddr

do {wave.do}

view wave
view structure

do {ddr.udo}

run -all

endsim

quit -force
