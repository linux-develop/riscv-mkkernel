CROSS_COMPILE := riscv64-linux-gnu
CC            := $(CROSS_COMPILE)-gcc

LDFLAGS_16KB  := -Wl,-z,common-page-size=0x4000

OUTDIR  := output
TESTS   := $(patsubst %.c,%,$(wildcard test_*.c))
BINS_4K  := $(addprefix $(OUTDIR)/,$(addsuffix _4kb,$(TESTS)))
BINS_16K := $(addprefix $(OUTDIR)/,$(addsuffix _16kb,$(TESTS)))

.PHONY: all
all: $(BINS_4K) $(BINS_16K)

$(TESTS): %: $(OUTDIR)/%_4kb $(OUTDIR)/%_16kb

$(OUTDIR)/%_4kb: %.c | $(OUTDIR)
	$(CC) $< -o $@

$(OUTDIR)/%_16kb: %.c | $(OUTDIR)
	$(CC) $< -o $@ $(LDFLAGS_16KB)

$(OUTDIR):
	mkdir -p $@

.PHONY: clean
clean: 
	rm -f $(BINS_4K) $(BINS_16K)
