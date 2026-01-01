@ECHO OFF
CLS
ECHO This BATCH file will run PGP (Pretty Good Privacy) to check and
ECHO see if the file 'ACT-1196.TXT' has been tampered with.  If a
ECHO bad signature message is given, someone has changed the contents
ECHO of that file.  To be sure of getting an offical copy, FTP a copy
ECHO from  ftp://ftp.simtel.net/pub/simtelnet/msdos/arcers/actest22.zip
ECHO I upload a copy there myself.  - Jeff Gilchrist, author of A.C.T.
ECHO.
ECHO If you do not have a copy of my public key on your PGP keyring
ECHO then e-mail: jeffg@nbnet.nb.ca  and I will send you my key.
ECHO.
PAUSE

PGP ACT-1196.SIG ACT-1196.TXT
