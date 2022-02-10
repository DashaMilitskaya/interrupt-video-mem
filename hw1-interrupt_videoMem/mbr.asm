; Пример кода MBR, осуществляющего вывод строки на экран через видеопамять.
;
; Маткин Илья Александрович     25.02.2015


use16
org 7C00h

	


	mov sp, 7C00h
	
	mov ax, PrintString
	call ChangeIDT
	
	
	mov ah,00h    ;Переходим в текстовый режим 80х25
	mov al,02h   ;очищаем экран           
	int 10h
	
	mov si, hello
	mov ah, 1Eh
	mov dx, 1
	int 40h
	mov si, hello
	mov ah, 1Eh
	mov dx, 1
	int 40h
	
	@@:
	mov si, @f
	jmp tic
	@@:
	
	mov dx, 2;clear
	int 40h
	
	@@:
	mov si, @f
	jmp tic
	@@:
	
	mov si, hello
	mov ah, 1Bh
	mov dx, 1
	int 40h
	
	;write string
	mov si, hellot ;string ptr
	mov ah, 1Eh ;color
	mov dx, 1 ;option
	int 40h ;interrupt
	
	mov si, hellot
	mov ah, 1Bh
	mov dx, 1
	int 40h
	
	mov si, hellog
	mov ah, 1Eh
	mov dx, 1
	int 40h
	
	mov dx, 0;write sign
	mov ah, 1Ch
	mov al, 'A'
	int 40h
	
	mov si, hellog
	mov ah, 1Eh
	mov dx, 1
	int 40h
	
	@@:
	mov si, @f
	jmp tic
	@@:
	
	mov cx, 0
	@@:
	cmp cx, 22
	je @f
	inc cx
	mov si, hello
	mov ah, 1Eh
	mov dx, 1
	int 40h
	jmp @b
	@@:
	
	@@:
	mov si, @f
	jmp tic
	@@:
	
	mov cx, 0
	@@:
	cmp cx, 22
	je @f
	inc cx
	mov si, hellot
	mov ah, 0Ch
	mov dx, 1
	int 40h
	jmp @b
	@@:
	; бесконечный цикл
	jmp $
;--------------------

; функция вывода строки
PrintString:

    push bp
    mov bp, sp
	push si
    push bx
    push es
    push cx
	;mov si, [bp + 4]
    
    mov cx, 0B800h
	mov es, cx
    mov cl, ah
    xor bx, bx
    
    add bx, word [num]
    
    cmp dx, 0
	je sign
	
	 cmp dx, 1
	je strings
	
	cmp dx, 2
	je clean
	
	jmp rtn
strings:
	xor dx, dx
@@:
	lodsb
	
	cmp al, 0
	je @f

	mov byte [es:bx], al
    mov byte [es:bx+1], cl
    
    add bx, 2
    inc dx
    mov ah,02h
	mov al,02h              
	int 10h
	
    jmp @b
@@:
	mov ax, 160
	add word [num], ax
	jmp rtn
	
sign:
	xor dx, dx
	cmp al, 0
	je rtn

	mov byte [es:bx], al
    mov byte [es:bx+1], cl
    
    add bx, 2
    inc dx
    mov ah,02h
	mov al,02h              
	int 10h
	
	mov ax, 160
	add word [num], ax
	jmp rtn
	
clean:
	xor ax, ax
	mov word [num], ax
	mov ah,00h    ;Переходим в текстовый режим 80х25
	mov al,02h   ;очищаем экран           
	int 10h
rtn:	
	mov ax, 4000
	cmp word [num], ax
	jge slipvdmem
rtn2:
	pop cx
    pop es
    pop bx
    pop si
	mov sp, bp
    pop bp
	ret

slipvdmem:
	
	xor bx, bx
	xor dx, dx
	mov ax, 0B800h
	mov es, ax
	mov cx,  word [num]
	@@:
	cmp cx, 160
	jle @f
	mov al, byte [es:bx+160]
	mov cl, byte [es:bx+160+1]
	mov byte [es:bx], al
    mov byte [es:bx+1], cl
    
    add bx, 2
    inc dx
    mov ah,02h
	mov al,02h          
	int 10h
	sub cx, 2
    jmp @b
	@@:
	mov ax, 160
	sub word [num], ax
jmp rtn2	
	
; адрес обработчика в регистре ax
ChangeIDT:

	push si
	xor si, si
    
    mov es, si
    
    mov [es:si+4*40h], ax
    mov word [es:si+4*40h+2], 0

	pop si
	ret	
	
tic:
mov ah, 01h ;установим счётчик тиков в ноль
	xor cx, cx
	xor dx, dx
	int 1Ah
	
	;зациклимся пока счётчик тиков не больше 300
	cyc_timer_start:
	cmp dx, 300
	ja cyc_timer_end
	
	mov ah, 00h
	int 1Ah
	jmp cyc_timer_start
	cyc_timer_end:
jmp si

hello db "Hello, World!",0
hellot db "Hell", 0
hellog db "Hello, aaaaaaaaaaaaaaaaaaaaaaa", 0
num dw 0


; забивка нулями до конца сектора
;times 510-($-$$) db 0
db 510-($-$$) dup (0)

; сигнатура загрузочного сектора
db 55h, 0AAh
