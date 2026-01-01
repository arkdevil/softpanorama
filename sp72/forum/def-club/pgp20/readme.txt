For setup russian language in PGP, you MUST set
Language = ru 
in your config.txt file and probably CharSet, see below.

Currently, two charsets handled by PGP, it is KOI8 and alternate codes.
Internal representation of text files is KOI8 with CR/LF.
If you transfer text file out of your local system, don't
forget to add -t (text) option to 'pgp' call.
Without it, your text can't be read if local and remote system 
charsets are different, f.e. Unix<-->MSDOS transfer.

If your Unix have alternate codes charset, or you are in pure
MSDOS with alternate codes, don't forget to set
CharSet = alt_codes
in your config.txt file.
WARNING: You MUST set alt_codes in this case, otherwise PGP don't
work properly.

If you have some kind of Unix with KOI8 russian codes or
MSDOS with KOI8 (strange?), PGP is ready to work without
additional settings.
Anyway, you can set
CharSet = koi8
 or
CharSet = noconv
in your config.txt file in this case.

