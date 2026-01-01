
echo Check all files from directory
j-check *.*

echo Check all files from directory
echo       and save check-inform. to check-file (CHK.1)
j-check *.* > CHK.1

echo Testing check-inform.
j-check *.*  CHK.1

