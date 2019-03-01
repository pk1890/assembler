
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

;obsluga stringow



printchar:
mov ah, 0
mov al, 3
int 10h ;trybb tekstowy vga

jmp load

mov ah, 9
mov dx, offset string ;wyswietl stringa pod adresem dx
int 21h
          

load:
mov dx, offset buffer
mov ah, 0ah
int 21h
          
print:
xor bx, bx
mov bl, buffer[1] ;ustaw bx na koniec 

mov buffer[bx+2], '$'                       

mov dx, offset buffer + 2

mov ah, 9 ;wypisz od dx (od drugiego byte'u )
int 21h
          
          
ret

buffer db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
string db 'jeden $' 