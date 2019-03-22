
data segment

    pkey db "press any key...$"   
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
      
    pixelArray db   64000 dup (0) ; tablica pikseli
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
    
    lea dx, ds:[82h] 

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


    mov dx, seg handle
    mov ds, dx
    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov cx, 320*200; wybierz 320x200 bajtow i zapisz je do odpowiedniego bufora
    mov dx, seg pixelArray
    mov ds, dx
    mov dx, offset pixelArray  
    mov ah, 3fh ; czytaj z pliku
    int 21h

    call loadPalette

    mov cx, 320*200
    l1:
    
        call setPixel
        
    loop l1


    
    ; mov dx, seg pixelArray
    ; mov ds, dx
    ; mov dx, offset pixelArray      

    ; mov bx, seg palette
    ; mov di, offset palette

    ; mov ax, 0
    ; pixelLoop:
    
    ; mov dword ptr, 


    ; inc ax
    ; cmp ax, 0‭FA00‬h
    ; jl pixelLoop

    ; wait for any key....    
   ; mov ah, 1
    ;int 21h   

    mov dx, seg handle
    mov ds, dx


    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov ah, 3eh
    int 21h ;zamknij plik
    
    endd:  
 


    mov ah, 1
    int 21h 

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


    setPixel: ; wyswietl piksel pod koordynatami cx = 320*y+x (tablica pikseli pod ds:[bx])   
        
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
        mov dx, 3C8h
        mov ax, 0
        out dx, ax
        mov cx, 256*4
        loadloop:
        
        mov dx, seg palette
        mov ds, dx
        mov di, 256*4
        sub di, cx
        ;mov ax, 0ffffh
        mov ax, word ptr ds:[palette +di]
        mov dx, 3C9h
        out dx, ax
        loop loadloop

        ret

code ends

end start
