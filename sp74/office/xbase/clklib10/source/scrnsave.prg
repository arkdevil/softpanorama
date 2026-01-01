*PROCEUDRE: ScrnSave - Until the user hits a key display a moving message.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 19 Jul 1994


Procedure ScrnSave
 Parameters scrnsize, message, fcolor
 Private scrn, junk, lastx, lasty

 set talk off

 save screen to scrn
 @ 0,0 clear

 store Rand(-1) to junk
 store 0 to lastx, lasty

 do while (InKey() <> 0)
 enddo
 
 set cursor off
 
 lastx = Mod(Rand()*100, scrnsize)
 lasty = Mod(Rand()*100, 80-Len(message))
 @ lastx,lasty say message color &fcolor.

 do while (Inkey(3) = 0)
    @ lastx,lasty say Space(Len(message))

    lastx = Mod(Rand()*100, scrnsize)
    lasty = Mod(Rand()*100,80-Len(message))

    @ lastx,lasty say message color &fcolor.
 enddo

 set cursor on

 restore screen from scrn
 release screen scrn

Return

