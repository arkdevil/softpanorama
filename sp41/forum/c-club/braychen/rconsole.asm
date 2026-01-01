COMMENT ~
        Программа RCONSOLE - это русификатор EGA/VGA дисплеев и клавиатуры.
        Аналогичных программ существует достаточно много, например:
          UNI... Бунича, KEYRUS Гуртяка и др.
        И тем не менее мне пришлось разработать еще одну.
        Основные черты данной программы:
          - поддержка ВСЕХ НЕСТАНДАРТНЫХ видеорежимов EGA/VGA,
            как текстовых, так и графических,
            включающихся через видеофункцию 00..h (Set Video Mode)
            и использующих шрифты высотой 8, 14 и 16 линий
          - установка GRAFTABL шрифта
          - работа только через документированные функции
            и области данных DOS и BIOS
          - малые размеры резидентной части (использует часть PSP и
            самомодифицирующийся код, автоматически настраивается на
            EGA, уменьшаясь на 4Кб по сравнению с VGA-вариантом)
          - переключение клавиатуры крайне редко используемой клавишей
            <Scroll Lock>, которая к тому же имеет свою лампочку на
            клавиатуре, что делает ненужной дополнительную сигнализацию
          - 2 варианта трансляции букв: стирание SCAN кодов, т.е.
            имитация ALT-ввода (основной), и сохранение SCAN кодов
            (включается с помощью /s в командной строке)
          - доступность исходного текста (иногда помогает при отладке
            других программ, особенно системных и графических)
        Средства редактирования раскладки клавиатуры и замены шрифтов
        не включены в RCONSOLE, но мной разработана дополнительная программа
        RCCONFIG, которая выполняет эти функции непосредственно с файлом
        RCONSOLE.COM, используя встроенный экранный редактор раскладки 
        и шрифты в формате EVAFONT.

        Программа должна транслироваться в .COM файл!

        Использовался транслятор TASM 2.0 с ключом /m2 (2 прохода),
        но ничего специфичного для TASM в программе нет.

        При разработке использовались идеи программы EGAGA, опубликованной
        в СОФТПАНОРАМЕ Vol.2, No.4 (8) - апрель 1990 г., а также программы
        AKBD, опубликованной в СОФТПАНОРАМЕ Vol.3, No.7 (21) - сентябрь 1991 г.

        Автор: В.И.Брайченко (Vadim Braychenko), Центр подготовки космонавтов.
        Адрес: 141160 Московская обл., Звездный городок, а/я 139.
        ~
;
; Сегмент данных BIOS
;
LowMem	segment at 40h
	org 17h
KB_SSF  label byte                      ; Состояние флагов клавиатуры
	org 1Ah
KB_head label word                      ; Указатель головы буфера клавиатуры
	org 1Ch
KB_tail label word                      ; Указатель хвоста буфера клавиатуры
	org 60h
Cursor  label word                      ; Размер курсора (0 - граф. режим)
	org 84h
NRows   label byte                      ; Количество строк экрана - 1
	org 85h
Points  label byte                      ; Высота символа в пикселах
LowMem	ends
;
; Сегмент программы
;
Code	segment
	assume cs:Code,ds:Code
;
; Смещения в префиксе программного сегмента
;
	org 02Ch
EnvSeg  label word                      ; Адрес окружения
	org 05Ch
Scratch label byte                      ; Начало реальной раскладки клавиатуры
	org 080h
ParmLen label byte                      ; Длина строки параметров
	org 081h
ParmStr label byte                      ; Строка параметров
;
; Начало кода программы
;
        org 100h                        ; для .COM - файла
RConsole:
        jmp Install
        org 118h                        ; Место для раскладки клавиатуры
	assume ds:NOTHING
;
; Обработчик видеофункции 1130h (Информация о шрифтах).
; Вызывает BIOS, затем подставляет в возвращаемые характеристики
; адрес соответствующего собственного шрифта.
;
GetInfo:
	pushf
	db 09Ah				; opcode CALL far
GI_ofs	dw ?				; offset
GI_seg	dw ?				; segment
GI_2:	cmp bh,2
	jne GI_3
        mov bp,OFFSET Font_14
	jmp SHORT GI_end
GI_3:	cmp bh,3
	jne GI_4
        mov bp,OFFSET Font_08
	jmp SHORT GI_end
GI_4:	cmp bh,4
        jne GI_6
GI_ega  label byte                      ; EGA: заменить jne GI_6 на jne GI_ret
        mov bp,OFFSET Font_08 + 128*8
	jmp SHORT GI_end
GI_6:	cmp bh,6
        jne GI_ret
        mov bp,OFFSET Font_16
GI_end:	push cs
	pop es
GI_ret:	iret
;
; Обработчик видеофункций 11..h (Функции знакогенератора).
; Функции загрузки встроенных шрифтов (из видео-BIOS) заменяются на
; функции загрузки соответствующих по размеру пользовательских шрифтов.
;
CharGen:
	cmp al,30h
	je GetInfo
	push es
	push bp
	push bx
	push ax
	push cx
	push dx
CG_1:	cmp al,1
	jne CG_2
	mov al,0
	mov bh,14
        mov bp,OFFSET Font_14
	jmp SHORT CG_Tx
CG_2:	cmp al,2
	jne CG_4
CG_ega1 label byte                      ; EGA: заменить jne CG_4 на jne CG_11
	mov al,0
	mov bh,8
        mov bp,OFFSET Font_08
	jmp SHORT CG_Tx
CG_4:	cmp al,4
	jne CG_11
	mov al,0
	mov bh,16
        mov bp,OFFSET Font_16
	jmp SHORT CG_Tx
CG_11:	cmp al,11h
	jne CG_12
	mov al,10h
	mov bh,14
        mov bp,OFFSET Font_14
	jmp SHORT CG_Tx
CG_12:	cmp al,12h
	jne CG_14
CG_ega2 label byte                      ; EGA: заменить jne CG_14 на jne CG_22
	mov al,10h
	mov bh,8
        mov bp,OFFSET Font_08
	jmp SHORT CG_Tx
CG_14:	cmp al,14h
	jne CG_22
	mov al,10h
	mov bh,16
        mov bp,OFFSET Font_16
	jmp SHORT CG_Tx
CG_22:	cmp al,22h
	jne CG_23
	mov al,21h
	mov cx,14
        mov bp,OFFSET Font_14
	jmp SHORT CG_Gx
CG_23:	cmp al,23h
	jne CG_24
CG_ega3 label byte                      ; EGA: заменить jne CG_24 на jne CG_do
	mov al,21h
	mov cx,8
        mov bp,OFFSET Font_08
	jmp SHORT CG_Gx
CG_24:	cmp al,24h
	jne CG_do
	mov al,21h
	mov cx,16
        mov bp,OFFSET Font_16
	jmp SHORT CG_Gx
CG_Tx:	mov cx,256
	xor dx,dx
CG_Gx:	push cs
	pop es
CG_do:	pushf
	db 09Ah				; opcode CALL far
CG_ofs	dw ?				; offset
CG_seg	dw ?				; segment
       	pop dx
	pop cx
       	pop ax
CG_end:	pop bx
	pop bp
	pop es
	iret
;
; Обработчик видеофункции  00..h (Установка видеорежима).
; Вызывает BIOS, затем в зависимости от установленного видеорежима
; вызывает ту или иную функцию установки пользовательского шрифта.
;
SetMode:
	pushf
	db 09Ah				; opcode CALL far
SM_ofs	dw ?				; offset
SM_seg	dw ?				; segment
SM_ini:	push es
	push bp
	push bx
	mov bp,SEG LowMem
	mov es,bp
	assume es:LowMem
	mov bl,0
	mov bh,Points
SM_08:	cmp bh,8
	jne SM_14
        mov bp,OFFSET Font_08
	jmp SHORT SM_do
SM_14:	cmp bh,14
	jne SM_16
SM_ega  label byte                      ; EGA: заменить jne SM_16 на jne CG_end
        mov bp,OFFSET Font_14
	jmp SHORT SM_do
SM_16:	cmp bh,16
        jne CG_end
        mov bp,OFFSET Font_16
SM_do:	push ax
	push cx
	push dx
        cmp Cursor,0
	je SM_APA
SM_TXT: mov ax,1100h
	jmp CG_Tx
SM_APA: mov ax,1121h
	mov cx,bx
	xchg ch,cl
	mov dl,NRows
	inc dl
	jmp CG_Gx
	assume es:NOTHING
;
; Обработчик видеопрерывания.
; Перехватывает функции установки видеорежима и знакогенератора,
; остальные переадресует в BIOS.
;
Int10h:
        or ah,ah                        ; Установка видеорежима?
	jnz No_SM
	jmp SetMode
No_SM:  cmp ah,11h                      ; Функции знакогенератора?
	jne No_CG
	jmp CharGen
No_CG:	db 0EAh				; opcode JMP far
j10ofs	dw ?                            ; offset
j10seg	dw ?				; segment
;
; Обработчик прерывания от клавиатуры.
; Включается в работу установкой флага 'Scroll Lock',
; вызывает BIOS, затем проверяет, произошла ли запись символа
; в буфер клавиатуры, если да, то перекодирует его по имеющейся раскладке.
;
Int09h:
	push ds
	push bx
	mov bx,SEG LowMem
	mov ds,bx
	assume ds:LowMem
        test KB_SSF,10h                 ; Scroll Lock = 1?
        jnz KB_job                      ; да, необходима обработка
        pop bx
        pop ds
	db 0EAh				; opcode JMP far
j09ofs	dw ?
j09seg	dw ?

KB_job: mov bx,KB_tail                  ; запомнить адрес конца буфера
        pushf                           ; вызвать BIOS
        db 09Ah                         ; opcode CALL far
c09ofs	dw ?
c09seg	dw ?
        cmp bx,KB_tail                  ; записан ли новый символ?
        je KB_qit                       ; нет
	push ax
        mov ax,[bx]                     ; взять его для анализа
        or ah,ah                        ; есть ли SCAN код?
        jz KB_end                       ; нет
        cmp ah,35h                      ; введен ли он с основной клавиатуры?
        jae KB_end                      ; нет
        cmp al,KB_frst                  ; подлежит ли перекодировке?
        jb  KB_end                      ; нет
	cmp al,KB_last
        ja  KB_end                      ; нет
        test KB_SSF,40h                 ; проверить Caps Lock
	push bx
        mov bx,OFFSET Scratch - KB_frst ; раскладка для Caps Lock = 0
        jz KB_do                        ; Caps Lock = 0!
        add bx,KB_size                  ; раскладка для Caps Lock = 1
KB_do:  xlat Scratch
	pop bx
KB_scan label byte                      ; замена mov ah,0 на JMP SHORT KB_end
        mov ah,0                        ; стереть SCAN код
        mov [bx],ax                     ; и вернуть символ в буфер клавиатуры
KB_end:	pop ax
KB_qit:	pop bx
	pop ds
	assume ds:NOTHING
	iret
;
; Шрифты.
;
	even
Font_08 label byte
	.xlist
        include Font_08.asm
	.list
Font_14 label byte
	.xlist
        include Font_14.asm
	.list
Font_16 label byte
	.xlist
        include Font_16.asm
	.list
;
; Раскладки клавиатуры (во время установки копируются в Scratch).
;
KB_xlat db  '!Э#$%&э()*+б-ю/'
	db '0123456789ЖжБ=Ю?'
	db '@ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯх\ъ^_'
	db '`фисвуапршолдьтщзйкыегмцчняХ|Ъ~'
KB_caps	db  '!э#$%&Э()*+Б-Ю/'
	db '0123456789жЖб=ю?'
	db '@ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯХ\Ъ^_'
	db '`фисвуапршолдьтщзйкыегмцчнях|ъ~'
KB_size = KB_caps - KB_xlat             ; размер раскладки
KB_frst = 33                            ; первый перекодируемый символ
KB_last = 126                           ; последний перекодируемый символ
;
; Нерезидентная часть программы - производит установку и настройку.
;
Install:
	assume ds:Code
;
; Вывести на консоль сообщение о себе.
;
	mov ah,9
	mov dx,OFFSET Message
	int 21h
;
; Обработать ключи командной строки
;
        mov al,'/'                      ; ключи начинаются с '/'
        mov cl,ParmLen
	mov ch,0
        mov di,OFFSET ParmStr
I_loop: repne scasb                     ; сканировать строку в поисках ключей
        jcxz I_break                    ; строка закончилась
        cmp byte ptr [di],'s'           ; сохранить SCAN код?
	jne I_loop
        mov KB_scan,0EBh                ; заменить 'mov ah,' на 'jmp SHORT'
	jmp SHORT I_loop
I_break:
;
; Получить текущие вектора прерываний и записать их в резидентную часть
;
        mov ax,3510h                    ; вектор видеопрерывания (10h)
	int 21h
	mov GI_ofs,bx
	mov GI_seg,es
	mov CG_ofs,bx
	mov CG_seg,es
	mov SM_ofs,bx
	mov SM_seg,es
	mov j10ofs,bx
	mov j10seg,es
        mov ax,3509h                    ; вектор клавиатурного прерывания (09h)
	int 21h
	mov j09ofs,bx
	mov j09seg,es
	mov c09ofs,bx
	mov c09seg,es
;
; Скопировать раскладки клавиатуры в резидентную часть
;
	mov ax,ds
	mov es,ax
	mov cx,KB_size
	mov si,OFFSET KB_xlat
	mov di,OFFSET Scratch
	rep movsw
;
; Если адаптер не VGA, а EGA, то можно значительно уменьшить размер резидента
;
        mov si,OFFSET KB_xlat           ; установить конец резидента для VGA
        mov ax,1A00h                    ; проверить наличие VGA
	int 10h
        cmp al,1Ah                      ; есть ли VGA?
        je I_skip                       ; да, есть, корректировки не нужны
        mov si,OFFSET Font_16           ; конец резидента для EGA
        mov GI_ega  - 1,OFFSET GI_ret - OFFSET GI_ega   ; произвести
        mov CG_ega1 - 1,OFFSET CG_11  - OFFSET CG_ega1  ; необходимые
        mov CG_ega2 - 1,OFFSET CG_22  - OFFSET CG_ega2  ; исправления
        mov CG_ega3 - 1,OFFSET CG_do  - OFFSET CG_ega3  ; в резидентной
        mov SM_ega  - 1,OFFSET CG_end - OFFSET SM_ega   ; части программы
I_skip:
;
; Установить текущий шрифт, используя подпрограмму из резидентной части
;
        pushf                           ; для IRET
        push cs                         ; для IRET
        call SM_ini
;
; Установить шрифт GRAFTABL
        mov ax,1120h
        mov bp,OFFSET Font_08 + 128*8
	int 10h
;
; Установить новые вектора прерываний
;
        mov ax,2510h                    ; видео
	mov dx,OFFSET Int10h
	int 21h
        mov ax,2509h                    ; клавиатура
	mov dx,OFFSET Int09h
	int 21h
;
; Оставить в памяти резидентную часть и вернуться в DOS.
;
	mov dx,si
	int 27h

Message db 10,13,'RConsole - Программа русификации клавиатуры и EGA/VGA. Версия 1.0'
        db 10,13,'Вызов: rconsole [ключи]'
        db 10,13,'  /s - сохранять SCAN коды для русских букв'
        db 10,13,'Русская клавиатура включается клавишей <Scroll Lock>.'
        db 10,13,'Автор: В.И.Брайченко (Vadim Braychenko), Центр подготовки космонавтов.'
        db 10,13,'Адрес: 141160 Московская обл., Звездный городок, а/я 139.'
	db 10,13,'$'

Code	ends
	end RConsole
