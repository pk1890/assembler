; multi-segment executable file template.

data segment
    ; add your data here!
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
    
   ; mov ah, 9
   ; int 21h
    
    ; wait for any key....    
    mov ah, 1
    int 21h        

    mov al, 13h
	mov ah, 0
	int 10h     ; set graphics video mode. 
    
    
    mov al, 0 ; read mode
	mov dx, 82h       ;otworz plik o nawzie poerwszego argumentu
	mov ah, 3dh
	int 21h  
	
	jc  endd  ;if error on opening file end program
    
         
    mov word ptr ds:handle ,ax ;file handle   
                                       
    

    
 
    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov cx, 1078; ilosc bajtow do zczytania pliku od poczatku do palety kolorow                        
    mov dx, seg bfType
    mov ds, dx
    mov dx, offset bfType  
    mov ah, 3fh ; czytaj z pliku
    int 21h


    mov dx, 0A000h ; wskaz na pamiec vga
	mov es, dx

    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov cx, 0FA00h; wybierz 320x200 bajtow i zapisz je do odpowiedniego bufora
    mov dx, 0A000h
    mov ds, dx
    mov dx, offset 0  
    mov ah, 3fh ; czytaj z pliku
    int 21h
    
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
    
    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov ah, 3eh
    int 21h ;zamknij plik
    
    endd:  
    mov ah, 1
    int 21h 

    mov ax, 4c00h ; exit to operating system.
    int 21h    
    errendd:
	mov al, 1100b
	mov cx, 10
	mov dx, 20
	mov ah, 0ch
	int 10h     ; set pixel.
    ;  lea dx, ds:[82h] 
    
    ; mov ah, 9
    int 21h
    jmp endd

code ends

end start ; set entry point and stop the assembler.
