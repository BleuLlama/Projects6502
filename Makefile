# makefile to clean all subdirs (and other type stuff)
#
# 2015-12-31  yorgle@gmail.com


SUBDIRS := \
	Skeleton \
	\
	DiscoDisco \
	VideoTest \
	GameOfLife \
	FBOK_A FBOK_B FBOK_C FBOK_D \
	\
	LlamaCalc 
	

all: clean


clean: $(SUBDIRS)
.PHONY: clean

$(SUBDIRS):
	@echo ==== $@ ====
	@cd $@ ; make clean
.PHONY: $(SUBDIRS)
