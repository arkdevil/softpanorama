@echo off
tdstrip go32.exe
tdstrip debug32.exe
cp go32.exe /usr/local/bin/go32.exe
cp stub.exe /usr/local/bin/stub.exe
cp stub.exe /usr/local/bin/cpp.exe
cp stub.exe /usr/local/bin/cc1.exe
cp stub.exe /usr/local/bin/cc1plus.exe
cp stub.exe /usr/local/bin/as.exe
cp stub.exe /usr/local/bin/ld.exe
cp stub.exe /usr/local/bin/strip.exe
cp stub.exe /usr/local/bin/size.exe
cp stub.exe /usr/local/bin/nm.exe
cp stub.exe /usr/local/bin/ar.exe
cp stub.exe /usr/local/bin/objdump.exe
cp debug32.exe /usr/local/bin/debug32.exe
