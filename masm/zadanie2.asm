; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"   
    handle dw ?
    
    
data ends  

image segment
      
    buf db   65535 dup (0)
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
    
    
    mov al, 0 ; read mode
	mov dx, 82h       ;otworz plik o nawzie poerwszego argumentu
	mov ah, 3dh
	int 21h  
	
	jc  endd  ;if error on opening file end program
    
    mov dx, seg dane
    mov ds, dx ; ustaw segment danych, juz nie potrzebujemy nazwy pliku
                  
    mov word ptr ds:handle ,ax ;file handle   
                                       
    

    
 
    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov cx, 0ffffh; ilosc bajtow                        
    mov dx, seg buf
    mov ds, dx
    mov dx, offset buf  
    mov ah, 3fh ; czytaj z pliku
    int 21h
    
    
    mov bx, word ptr ds:handle; wpisz handle do pliku
    mov ah, 3eh
    int 21h ;zamknij plik
    
    mov al, 13h
	mov ah, 0
	int 10h     ; set graphics video mode. 
	mov al, 1100b
	mov cx, 10
	mov dx, 20
	mov ah, 0ch
	int 10h     ; set pixel.
	 
    ; wait for any key....    
    mov ah, 1
    int 21h   
    
    endd:
        
    mov ax, 4c00h ; exit to operating system.
    int 21h    
code ends

end start ; set entry point and stop the assembler.
