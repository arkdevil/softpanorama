For: Norton Editor 1.5 ALPHA
By: Madis Kaal

file: ne.com

@This patch will for NE 1.5 to create backup files like older versions
@did - using the tilde (~). Originally, NE 1.5 uses '@'. It will also
@remove the stpid wait for keystroke after you have netered file name
@to edit.
@
?Do you want to do it
@Patching NE.COM
offset:   7e
original: e8 ac 52
replace:  90 90 90
offset:   3954
original: 2e 89 45 02 2e c6 45 01 40
replace:  2e 89 45 02 2e c6 45 01 7e
offset:   3963
replace:  c3 2e c7 05 2e 7e
@
@NE will now create old-style backups, but there is more!
@
@Norton editor can be tuned to be DESQview aware, though
@this will disable NE's internal mouse support under DESQview.
@
?Do you want to make your copy of NE DESQview aware
offset: 4e
original: 60 28
replace:  50 38
offset:   38a0
replace:  06 53 50 2e 8b 1e 35 9d 8e c3 b4 fe cd 10 2e 8c
offset:   38b0
replace:  06 35 9d 2e 3b 1e 35 9d 74 0d 2e c7 06 70 77 b0
offset:   38c0
replace:  00 2e c6 06 72 77 c3 58 5b 07 e8 e3 ef c3
end

