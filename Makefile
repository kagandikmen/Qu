# Makefile to compile tests for The Qu Processor
# Created:     2025-06-24
# Modified:    2025-06-26

# Copyright (c) 2025 Kagan Dikmen
# SPDX-License-Identifier: MIT
# See LICENSE for details

DESIGN_SOURCES := \
	hdl/lib/qu_pkg.sv \
	hdl/rtl/fetch.sv \
	hdl/rtl/fifo.sv \
	hdl/rtl/pc_ctr.sv \
	hdl/rtl/ram_sp_rf.sv

SIMULATION_SOURCES := \
	hdl/sim/tb_fetch.sv \
	hdl/sim/tb_fifo.sv \
	hdl/sim/tb_pc_ctr.sv

TESTDIRS := ut/

TOP_TESTBENCH := tb_fetch

RISCV_PREFIX ?= riscv32-unknown-elf

CFLAGS += -march=rv32i -Wall -Wextra -Os -fomit-frame-pointer \
	-ffreestanding -fno-builtin -fanalyzer -std=gnu99 \
	-Wall -Werror=implicit-function-declaration -ffunction-sections -fdata-sections
LDFLAGS += -march=rv32i -nostartfiles \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,--no-relax -Wl,--gc-sections \
	-Wl,-Tsw/qu.ld

all: clean run_vivado

create_project:
	rm -rf qu.prj
	for source in $(DESIGN_SOURCES) $(SIMULATION_SOURCES); do \
		echo "sv work $$source" >> qu.prj; \
	done

copy_tests: create_project
	test -d tests || mkdir tests
	for testdir in $(TESTDIRS); do \
		for test in $$(ls $$testdir | grep .S); do \
			cp $$testdir/$$test tests; \
		done \
	done

compile_tests: copy_tests
	test -d build || mkdir build
	for test in tests/* ; do \
		test=$${test##*/}; test=$${test%.*}; \
		$(RISCV_PREFIX)-gcc -c $(CFLAGS) -o build/$$test.o tests/$$test.S; \
		$(RISCV_PREFIX)-gcc -o build/$$test.elf $(LDFLAGS) build/$$test.o; \
		$(RISCV_PREFIX)-objcopy -j .text -O binary build/$$test.elf build/$$test.bin; \
		hexdump -v -e '1/4 "%08x\n"' build/$$test.bin > build/$$test.hex; \
	done

run_vivado: compile_tests
	for test in $$(ls build | grep .bin); do \
		test=$${test##*/}; test=$${test%.*}; \
		printf "Running test $$test\n\r"; \
		xelab $(TOP_TESTBENCH) -relax -debug all \
			-generic_top PMEM_INIT_FILE=\"build/$$test.hex\" \
			-prj qu.prj > /dev/null; \
		xsim $(TOP_TESTBENCH) -R --onfinish quit > build/$$test.results; \
	done

clean:
	rm -rf build/ tests/ xsim.dir/ qu.prj *.wdb *.log *.pb *.jou