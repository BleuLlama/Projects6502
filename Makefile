# makefile to clean all subdirs (and other type stuff)
#
# 2015-12-31  yorgle@gmail.com


SUBDIRS := \
	Skeleton \
	DiscoDisco \
	VideoTest \
	GameOfLife \
	LlamaCalc \
	FBOK_A
	

all: clean


clean: $(SUBDIRS)
.PHONY: clean

$(SUBDIRS):
	@echo ==== $@ ====
	@cd $@ ; make clean
.PHONY: $(SUBDIRS)
