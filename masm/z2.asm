
data segment

    pkey db "press any key...$"   
    currx dw 0000h 
    curry dw 0000h
    zoom db 00h
    effectflags db 00000000b
    handle dw ?
        
    ;BITMAPFILEHEADER ma 14 bajtow
    bfType	dw	?
    bfSize	dd	?
    bfReserved1	dw	?
    bfReserved2	dw	?
    bfOffBits	dd	?
    ;BITMAPINFOHEADER ma 40 bajtow
    biSize	dd	?
    biWidth	dd	?
    biHeight	dd	?
    biPlanes	dw	?
    biBitCount	dw	?
    biCompression	dd	?
    biSizeImage	dd	?
    biXPelsPerMeter	dd	?
    biYPelsPerMeter	dd	?
    biClrUsed	dd	?
    biClrImportant	dd	?
    ;Paleta kolorow
    palette	dd	256 dup (?)
data ends  

image segment
      
    pixelArray db   0ffffh dup (0) ; tablica pikseli
image ends

stack segment stack
        dw   128  dup(0)
peak    db   ?
stack ends

code segment
start:             
    
     ;inicjowanie stosu
    mov sp, offset peak
    mov ax, seg peak
    mov ss, ax 

; set segment registers:
    mov ax, data
   ; mov ds, ax     
    mov es, ax
                                             
    mov bl, byte ptr ds:[80h]; zapisz dlugosc wczytanego argumentu
    
    mov byte ptr [bx+81h], 0; zastepujemy CRET po sczytanym argumencie '$'
    

    mov al, 13h
	mov ah, 0
	int 10h     ; set graphics video mode. 
    
    
    mov al, 0 ; read mode
	mov dx, 82h       ;otworz plik o nawzie poerwszego argumentu
	mov ah, 3dh
	int 21h  

	jc  errendd  ;if error on opening file end program
    
    mov dx, seg handle
    mov ds, dx
         
    mov word ptr ds:handle ,ax ;file handle   
    
 
    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov cx, 1078; ilosc bajtow do zczytania pliku od poczatku do palety kolorow                        
    mov dx, seg bfType
    mov ds, dx
    mov dx, offset bfType  
    mov ah, 3fh ; czytaj z pliku
    int 21h

    MAINLOOP:

    mov cx, 200
    drawRowLoop:
        call drawRow
        ; call drawRow
    loop drawRowLoop

    call loadPalette

   

    ;  mov dx, seg curry
    ;     mov ds, dx 
    ;     mov dx, word ptr ds:curry
    ;     add dx, 1
    ;     mov word ptr ds:curry, dx
   
    mov ah, 00h
    int 16h
    ; cmp al, 'a'
   
    cmp ah, 050h ;male a strzalka w dol
    je GoDown
    cmp ah, 048h ;male a strzalka w dol
    je GoUp
    cmp ah, 04Bh ;male a strzalka w dol
    je GoLeft
    cmp ah, 04Dh ;male a strzalka w dol
    je GoRight
    cmp al, '1'
    je switchRed
    cmp al, '2'
    je switchGreen
    cmp al, '3'
    je switchBlue
    
    cmp ah, 01h
    je endd
    
    
    jmp MAINLOOP

    GoDown:
        mov dx, seg curry
        mov ds, dx 
        mov dx, word ptr ds:curry
        add dx, 2
        mov word ptr ds:curry, dx
    jmp MAINLOOP
   GoUp:
        mov dx, word ptr ds:curry
        sub dx, 2
        mov word ptr ds:curry, dx
    jmp MAINLOOP

   GoLeft:
        mov dx, word ptr ds:currx
        sub dx, 2
        mov word ptr ds:currx, dx
    jmp MAINLOOP
        
   GoRight:
        mov dx, word ptr ds:currx
        add dx, 2
        mov word ptr ds:currx, dx
    jmp MAINLOOP
        
    switchRed:
        xor byte ptr ds:effectflags[0], 00000001b
    jmp MAINLOOP

    switchGreen:
        xor byte ptr ds:effectflags[0], 00000010b
    jmp MAINLOOP

    switchBlue:
        xor byte ptr ds:effectflags[0], 00000100b
    jmp MAINLOOP


    ; mov dx, seg handle
    ; mov ds, dx
    ; mov bx, word ptr ds:handle; wpisz handle do pliku
    ; mov cx, 320*200; wybierz 320x200 bajtow i zapisz je do odpowiedniego bufora
    ; mov dx, seg pixelArray
    ; mov ds, dx
    ; mov dx, offset pixelArray  
    ; mov ah, 3fh ; czytaj z pliku
    ; int 21h
    ; call loadPalette

    ; mov cx, 320*200
    ; l1:
    
    ;     call setPixel
        
    ; loop l1


    

    mov dx, seg handle
    mov ds, dx


    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov ah, 3eh
    int 21h ;zamknij plik
    
    endd:  
 


 ;   mov ah, 1
  ;  int 21h 

    mov ah, 0
    mov al, 03h
    int 10h


    mov ax, 4c00h ; zakoncz program
    int 21h    
    errendd:
    
    mov dx, 0A000h ; wskaz na pamiec vga
	mov es, dx

    mov bx, 500
    llp:
    mov byte ptr es:[bx], 13
    dec bx
    jne llp
    jmp endd

    drawRow: ; wystietl 1 linie obrazka (nr linii w cx)
        push cx ;zeby zachowac ten z petli
        dec cx

        mov dx, seg currx 
        mov ds, dx



        push cx
        xor cx, cx
        mov dx, word ptr ds:bfOffBits
        mov bx, word ptr ds:handle
        mov al, 0 ;SEEK FROM BEGIN
        mov ah, 42h
        int 21h ;przesun za naglowek
        
        pop cx
        mov ax, cx ; w ax siedzi numer linii do wczytania
        push cx

        mov cx, word ptr ds:biHeight
        sub cx, ax
        mov ax, word ptr ds:curry
        sub cx, ax ; cx = height - cx - curry

        mov ax, cx
        mov cx, word ptr ds:biWidth

        ;;poprawka na wielkosc rzedu
        push ax
        push bx
        push dx
        
        mov ax, cx
        mov bx, 8 ;;liczba bitow na piksel
        mul bx 
        
        add ax, 31
        jnc notoveradd
        add dx, 1
        notoveradd:
        mov bx, 32
        div bx

        mov bx, 4
        mul bx
        mov cx, ax

        pop dx
        pop bx
        pop ax



        mul cx ; wynik w dx:ax
        mov cx, dx
        mov dx, ax ; przeniesienie do cx:dx

        mov bx, word ptr ds:handle
        mov al, 1 ;SEEK FROM CURRENT
        mov ah, 42h
        int 21h ; przejdz na poczatek szukanej linii

        mov dx, seg handle
        mov ds, dx
        mov bx, word ptr ds:handle; wpisz handle do pliku

        mov cx, word ptr ds:biWidth
        mov dx, seg pixelArray
        mov ds, dx
        mov dx, offset pixelArray  
        mov ah, 3fh ; czytaj z pliku linie
        int 21h

        mov dx, seg currx
        mov ds, dx
        
        pop ax ; nr linii ktora chcemy wyswietlic
        mov bx, 320
        mul bx
        mov cx, 320
        LineLoop:
        call setPixelLine
        loop LineLoop


        pop cx
        ret

    ; setPixelLine: ; wersja z wyswietlaniem piksela na aktualnej linii (w ax = y, w cx x)
    ;     push ax
    ;     push cx

    ;     dec cx ; poprawka na to ze w petli cx jesrt od 320 do 1 a potzreba od 319 do 0
    ;     mov bx, 320
    ;     mul ax
    ;     add ax, cx

    ;     mov dx, 0A000h ; wskaz na pamiec vga
    ;     mov es, dx

    ;     mov dx, seg pixelArray ;wskaz na
    ;     mov ds, dx

    ;     mov dx, seg currx 
    ;     mov ds, dx
    ;     mov dx, word ptr ds:currx
    ;     add cx, dx ; cx = currx + x

    ;     mov dx, seg pixelArray
    ;     mov ds, dx

    ;     mov di, cx ; di = currx + x

    ;     mov cl, byte ptr ds:[di]
    ;     mov di, ax ;przekaz do rejestru adresowego offset w pamieci obrazu
    ;     mov byte ptr es:[di], cl



    ;     pop cx 
    ;     pop ax
    ;     ret
    setPixelLine: ; wersja z wyswietlaniem piksela na aktualnej linii (w ax = 320*y, w cx x)
        push ax
        push cx

        dec cx ; poprawka na to ze w petli cx jesrt od 320 do 1 a potzreba od 319 do 0

        add ax, cx
        mov cx, ax
        mov dx, 0A000h ; wskaz na pamiec vga
        mov es, dx

        mov dx, seg pixelArray ;wskaz na
        mov ds, dx

        xor dx, dx
        mov ax, cx
        mov bx, 320
        div bx ; w ax y w dx x
        
        mov bx, dx
        mov dx, seg currx ;wskaz na
        mov ds, dx
        mov dx, word ptr ds:currx
        add bx, dx
        
        mov dx, seg pixelArray ;wskaz na
        mov ds, dx

        mov al, byte ptr ds:[bx] 
       ; mov al, 10
        mov bx, cx
        mov byte ptr es:[bx], al
        
        pop cx
        pop ax
        ret


    setPixel: ; wyswietl piksel pod koordynatami cx = 320*y+x (tablica pikseli pod ds:[bx]) w lewym gornym rogu zaczynamy od piksela o offsecie currx, curry   
        
        mov dx, 0A000h ; wskaz na pamiec vga
        mov es, dx

        mov dx, seg pixelArray
        mov ds, dx

        xor dx, dx
        mov ax, cx
        mov bx, 320
        div bx ; w ax y w dx x

        push dx
        neg ax
        add ax, 200
        mov dx, 320
        mul dx
        pop dx
        add ax, dx
        mov bx, ax

        mov al, byte ptr ds:[bx] 
       ; mov al, 10
        mov bx, cx
        mov byte ptr es:[bx], al
        
        ret
    
    loadPalette:
        push ax
        push bx
        push cx 
        push dx
        
        mov dx, 3C8h
        mov al, 0
        out dx, al
        
        mov dx, seg palette
        mov ds, dx
        mov cx, 256
        mov di, offset ds:palette
        loadloop:
        ; mov di, 256*4
        ; sub di, cx
        ; mov dx, offset palette
        ; add di, dx
        ;mov ax, 0ffffh
        push cx
        mov cl, 02h
        
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;RED
        mov al, byte ptr ds:[di+2]
        mov ch, byte ptr ds:effectflags[0]
        and ch, 00000001b
        je skipredeff
        mov al, 00h
        
        skipredeff:
        shr al, cl
        mov dx, 3C9h
        out dx, al
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GREEN;;;;;;;;;;;;;;;;;;;
        mov al, byte ptr ds:[di+1]
        mov ch, byte ptr ds:effectflags[0]
        shr al, cl
        
        and ch, 00000010b
        je skipgreeneff
        mov al, 00h
        skipgreeneff:

        mov dx, 3C9h
        out dx, al
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;BLUE;;;;;;;;;;;;;;;;;;;
        mov al, byte ptr ds:[di]
        mov ch, byte ptr ds:effectflags[0]
        shr al, cl
        
        and ch, 00000100b
        je skipblueeff
        mov al, 00h
        skipblueeff:

        mov dx, 3C9h
        out dx, al

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        pop cx
        add di, 4
        loop loadloop

        pop  dx
        pop  cx 
        pop  bx
        pop  ax
        ret

code ends

end start
