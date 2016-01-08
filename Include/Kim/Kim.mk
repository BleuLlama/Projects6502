# Makefile include for the 6502-KIM code projects
#
#  2016-1-1  yorgle@gmail.com
#
#
# To use this, see the skeleton project.
# Essentially, your Makefile in the project directory needs to have two lines:
#	PROJ := source_file_without_extension
#	include ../Include/Kim/Kim.mk


################################################################################
# compile args

CARGS := --include-dir ../Include/Kim


################################################################################
# main targets
all: $(PROJ).lst install


################################################################################
# build rules
$(PROJ).lst: $(PROJ).asm
	@echo $(PROJ): ca65 $@ to $<
	@ca65 $(CARGS) $(PROJ).asm --target none --cpu 6502 -l $(PROJ).lst


################################################################################
# install into Kim Uno Remix Desktop
install:
	@echo $(PROJ): Sending SIGUSR1 to KIM application
	@killall -SIGUSR1 KIM
.PHONY: install


################################################################################
# keep the place tidy
clean:
	@echo $(PROJ): Cleaning project
	@-rm -f $(PROJ).o $(PROJ).lst
.PHONY: clean

