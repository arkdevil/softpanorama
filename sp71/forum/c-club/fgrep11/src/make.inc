# make.inc - General purpose targets for makefiles -*-Text-*-
# Copyright (C) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu

# $Header$
#

# This library of targets contains fairly standard idioms
# for makefile (but they seem not yet ripe enough to become
# hard coded defaults).

#
# Maintaing backups in a .zip archive and on floppy disk.
#
# entry points:
# zip, disk
#
# required macros:
# ZIPFILE:  name of the zip file (without suffix)
# DISK:     letter of the disk on which the backup lives
# RCSFILES: files living in RCS (w/o prefix)
# MISC:	    more files


ifdef ZIPFILE

.PHONY: zip
zip: $(ZIPFILE).zip

ifdef RCSFILES
$(ZIPFILE).zip: $(addprefix RCS/, $(RCSFILES)) $(MISC)
else
$(ZIPFILE).zip: $(MISC)
endif
	pkzip -r- -P $@ $?


ifdef DISK

.PHONY: disk
disk: $(DISK):/$(ZIPFILE).zip
$(DISK):/$(ZIPFILE).zip: $(ZIPFILE).zip
	cp -f $< $@
	pkunzip -t $@ | grep -vw OK

endif # DISK

endif # ZIPFILE

#
# Creating .tar files:

%.tar:
	tar -cf $@ $^

# Compressing .tar files for mailing

%.uue: %.tar
	compress < $< | uuencode $<.Z > $@



#
# Local Variables:
# mode:Text
# ChangeLog:ChangeLog
# compile-command:make
# End:

