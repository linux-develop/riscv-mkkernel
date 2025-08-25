.PHONY: test_01 clean_test_01 all

CROSS_COMPILE = riscv64-linux-gnu
CC = $(CROSS_COMPILE)-gcc
LD = $(CROSS_COMPILE)-ld
TEST_01 = test_01
TEST_02 = test_02
LDFLAGS = "-Wl,-z,common-page-size=0x4000"

TEST_01_4KB = output/$(TEST_01)_4kb
TEST_01_16KB = output/$(TEST_01)_16kb

$(TEST_01_4KB):
	mkdir -p output
	$(CC) $(TEST_01).c -o $(TEST_01_4KB)

$(TEST_01_16KB):
	mkdir -p output
	$(CC) $(TEST_01).c -o $(TEST_01_16KB) $(LDFLAGS)

test_01: $(TEST_01_4KB) $(TEST_01_16KB)

clean_test_01:
	rm $(TEST_01_4KB) $(TEST_01_16KB)
	rm -r output/

all: test_01
