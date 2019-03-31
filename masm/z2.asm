
data segment

    errormsg db "Wrong input file format $"   
    currx dw 0000h 
    curry dw 0000h
    zoom dw 0001h
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
      
    pixelArray db   0fffch dup (0) ; tablica pikseli
    red24Val db ?
    green24Val db ?
    blue24Val db ?
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

    call loadPalette
    

    mov cx, 200
    mov di, cx
    push dx
    drawRowLoop:
        call loadRow
        push cx
        mov cx, di
        mov dx, seg zoom
        mov ds, dx
        mov dx, word ptr ds:zoom 


        zoomLoop:
        call drawRow
        dec di
        dec cx
        dec dx
        cmp dx, 0
        jg zoomLoop

        ; call drawRow
        ; dec di

        pop cx
        dec cx
        cmp di, 0
        jg drawRowLoop

    ;  loop drawRowLoop
pop dx

   

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
    cmp ah, 04Eh ;male a strzalka w dol
    je zoomUp 
    cmp ah, 04Ah ;male a strzalka w dol
    je zoomDown
    cmp al, '1'
    je switchRed
    cmp al, '2'
    je switchGreen
    cmp al, '3'
    je switchBlue
    
    cmp ah, 01h
    je endd
    
    
    jmp MAINLOOP


    zoomUp:
    mov dx, seg zoom
    mov ds, dx
    mov dx, word ptr ds:zoom
    cmp dx, 4
    je MAINLOOP
    shl dx, 1
    mov word ptr ds:zoom, dx


    jmp MAINLOOP

    zoomDown:
    mov dx, seg zoom
    mov ds, dx
    mov dx, word ptr ds:zoom
    cmp dx, 1
    je MAINLOOP
    shr dx, 1
    mov word ptr ds:zoom, dx


    jmp MAINLOOP

    GoDown:
        mov dx, seg curry
        mov ds, dx 
        mov dx, word ptr ds:curry
        add dx, 2
        mov word ptr ds:curry, dx
    jmp MAINLOOP
   GoUp:
        mov dx, seg curry
        mov ds, dx 
        mov dx, word ptr ds:curry
        sub dx, 2
        mov word ptr ds:curry, dx
    jmp MAINLOOP

   GoLeft:
        mov dx, seg curry
        mov ds, dx 
        mov dx, word ptr ds:currx
        sub dx, 2
        mov word ptr ds:currx, dx
    jmp MAINLOOP
        
   GoRight:
        mov dx, seg curry
        mov ds, dx 
        mov dx, word ptr ds:currx
        add dx, 2
        mov word ptr ds:currx, dx
    jmp MAINLOOP
        
    switchRed:
        mov dx, seg curry
        mov ds, dx 
        xor byte ptr ds:effectflags[0], 00000001b
    jmp MAINLOOP

    switchGreen:
        mov dx, seg curry
        mov ds, dx 
        xor byte ptr ds:effectflags[0], 00000010b
    jmp MAINLOOP

    switchBlue:
        mov dx, seg curry
        mov ds, dx 
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
 

    mov ah, 0
    mov al, 03h
    int 10h

 ;   mov ah, 1
  ;  int 21h 


    mov ax, 4c00h ; zakoncz program
    int 21h    
    errendd:

    mov ah, 0
    mov al, 03h
    int 10h

     
    mov dx, offset errormsg 
    mov ax, seg errormsg
    mov ds, ax
    mov ah, 9 ;wypisz stringa z from ds:dx
    int 21h  
    
    mov ax, 4c00h ; zakoncz program
    int 21h    

    loadRow: ; wystietl 1 linie obrazka (nr linii w cx)
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

        cmp cx, 0
        jl nullLine
        
        cmp cx, word ptr ds:biHeight
        jge nullLine

        jmp contRead 

        nullLine:
        push di
        mov di, 0
        mov al, 00h;
        blackLoop:

        mov dx, seg pixelArray
        mov ds, dx
        ; neg al
        mov byte ptr ds:pixelArray[di], al 

        inc di
        mov dx, seg biWidth
        mov ds, dx
        cmp di, word ptr ds:biWidth
        jl blackLoop

        pop di
        pop ax
        pop cx 
        ret

        contRead:
        mov ax, cx
        mov cx, word ptr ds:biWidth

        ;;poprawka na wielkosc rzedu
        push ax
        push bx
        push dx
        
        mov ax, cx
        mov bx, word ptr ds:biBitCount ;;liczba bitow na piksel
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

        cmp byte ptr ds:biBitCount, 24
        je readLine24

        mov cx, word ptr ds:biWidth
        mov dx, seg pixelArray
        mov ds, dx
        mov dx, offset pixelArray  
        mov ah, 3fh ; czytaj z pliku linie
        int 21h

        pop ax
        pop cx 
        ret

        readLine24:
        push di
        mov di, 0

        preparePixel:        

        mov cx, 3 ; zczytaj 3 bajty 
        mov dx, seg red24Val
        mov ds, dx
        mov dx, offset red24Val  
        mov ah, 3fh ; czytaj z pliku 3 bajty (info o jednym pikselu)
        int 21h

        ; mov dx, seg biWidth
        ; mov ds, dx 
        ; mov cx, word ptr ds:biWidth
        ; mov dx, seg pixelArray
        ; mov ds, dx
        ; mov dx, offset pixelArray  
        ; mov ah, 3fh ; czytaj z pliku linie
        ; int 21h



        mov ax, 0
        mov ah, byte ptr ds:red24Val
        and ah, 11100000b ; wytnij 3 najstarsze bajty

        add al, ah ; w al - RRR00000

        mov ah, byte ptr ds:green24Val
        and ah, 11100000b ; wytnij 3 najstarsze bajty
        mov cl, 3
        shr ah, cl
        
        add al, ah ; w al - RRRGGG00 

        mov ah, byte ptr ds:blue24Val
        and ah, 11000000b ; wytnij 2 najstarsze bajty
        mov cl, 6
        shr ah, cl
        
        add al, ah ; w al - RRRGGGBB
        ; mov al, byte ptr ds:red24Val
        mov dx, seg pixelArray
        mov ds, dx
        ; neg al
        mov byte ptr ds:pixelArray[di], al 

        inc di
        mov dx, seg biWidth
        mov ds, dx
        cmp di, word ptr ds:biWidth
        jl preparePixel

        mov dx, seg red24Val
        mov ds, dx
        mov byte ptr ds:red24Val, 00h 
        mov byte ptr ds:green24Val, 00h 
        mov byte ptr ds:blue24Val, 00h 

        pop di
        pop ax
        pop cx 
        ret

        drawRow:
        push ax
        push bx
        push cx 
        push dx

        dec cx

        mov dx, seg currx
        mov ds, dx
        
        ; pop ax ; nr linii ktora chcemy wyswietlic
        mov ax, cx
        mov bx, 320
        mul bx
        mov cx, 320
        mov dx, cx
        push di
        ;mov di, 8
        LineLoop:
        mov di, seg zoom
        mov ds, di
        mov di, word ptr ds:zoom
        pixZoomLoop:
        call setPixelLine
        dec dx
        dec di
        cmp di, 0
        jg pixZoomLoop
        
        loop LineLoop
        pop di
;;;;;;;;;;;;;;;;;

    ; drawRowLoop
    ;     call loadRow
    ;     push cx
    ;     mov cx, di
    ;     mov dx, seg zoom
    ;     mov ds, dx
    ;     mov dx, word ptr ds:zoom 

    ;     zoomLoop:
    ;     call drawRow
    ;     dec di
    ;     dec cx
    ;     dec dx
    ;     cmp dx, 0
    ;     jg zoomLoop

    ;     ; call drawRow
    ;     ; dec di

    ;     pop cx
    ;     dec cx
    ;     cmp di, 0
    ;     jg drawRowLoop
;;;;;;;;;;;;;;;;

        pop dx
        pop cx
        pop bx
        pop ax

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

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    setPixelLine: ; wersja z wyswietlaniem piksela na aktualnej linii (w ax = 320*y, w cx x) x w pamieci obrazu w dx
        push ax
        push dx
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
        pop cx
        sub bx, cx
        pop dx
        add bx, dx
 ;       sub bx, 320
    ;    sub bx, 320

        mov byte ptr es:[bx], al
        
        ;  pop cx
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
        cmp ds:biBitCount, 8 
        je loadPalette8
        cmp ds:biBitCount, 24
        je loadPalette24
        jmp errendd

        loadPalette8:
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

        loadPalette24: ; konwencja: RRRGGGBB
        push ax
        push bx
        push cx 
        push dx

        mov dx, 3C8h
        mov al, 0
        out dx, al
        push bx
        mov cx, 0000h
        loadloop24:
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;BLUE;;;;;;;;;;;;;;;;;;;
        mov al, cl
        and al, 00000011b ; wydobadz dwa najmlodsze bity 
        mov dh, 4
        xchg dh, cl
        shl al, cl ; przesun je tak by najwieksza wartosc byla rowna 63
        xchg dh, cl

        mov bl, byte ptr ds:effectflags[0]
        and bl, 00000100b
        je skipblueeff24

        mov al, 00h
        skipblueeff24:

        mov dx, 3C9h
        out dx, al

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GREEN;;;;;;;;;;;;;;;;;;;
        mov al, cl
        and al, 00011100b ; wydobadz trzy kolejne bity 
        mov dh, 01h
        xchg dh, cl
        shl al, cl ; przesun je tak by najwieksza wartosc byla rowna 63
        xchg dh, cl
        
        mov bl, byte ptr ds:effectflags[0]
        and bl, 00000010b
        je skipgreeneff24

        mov al, 00h
        skipgreeneff24:

        mov dx, 3C9h
        out dx, al
        
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;RED
        mov al, cl
        and al, 11100000b ; wydobadz dwa trzy najstarsze bity
        mov dh, 02h
        xchg dh, cl
        shr al, cl ; przesun je tak by najwieksza wartosc byla rowna 63
        xchg dh, cl

        mov bl, byte ptr ds:effectflags[0]
        and bl, 00000001b
        je skipredeff24
        mov al, 00h
        
        skipredeff24:
        mov dx, 3C9h
        out dx, al

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         inc cx
         cmp cx, 00ffh
         jle loadloop24
        ;loop loadloop24
        pop bx

        pop  dx
        pop  cx 
        pop  bx
        pop  ax
        ret
code ends

end start
