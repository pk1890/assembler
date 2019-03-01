
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt


dane1 segment
    
hellotxt db "Wprowadz slowny opis dzialania: $"
one db "jeden $"
two db "dwa $"
three db "trzy $"
four db "cztery $"
five db "piec $"
six db "szesc $"
seven db "siedem $"
eight db "osiem $"
nine db "dziewiec $"
ten db "dizesiec $"
eleven db 'jedenascie $'
twelve db 'dwanascie $'
thirteen db 'trzynascie $'
fourteen db 'czternascie $'
fifteen db 'pietnascie $'
sixteen db 'szesnascie $'
seventeen db 'siedemnascie $'
eighteen db 'osiemnascie $'
nineteen db 'dziewietnascie $' 
tewnty db 'dwadziescia $'
thirty db 'trzydziesci $'
fourty db 'czterdziesci $'
fifty db 'piecdziesiat $'
sixty db 'szescdziesiat $'
seventy db 'siedemdizesiat $'
eighty db 'osiemdziesiat $'
ninety db 'dziewiecdziesiat $'
hundred db 'sto $'


dane1 ends

code1 segment
    
start1:
    ;inicjowanie stosu
    mov sp, offset wstosu
    mov ax, seg wstosu
    mov ss, ax
    
    mov dx, offset hellotxt
    mov ax, seg hellotxt
    mov ds, ax
    mov ah, 9 ;wypisz stringa z from ds:dx
    int 21h        
    
    mov bl, 0dh; w bl jest zapisany znak enter
    loop1:                           
    mov ah, 01h
    int 21h ;czytaj z echem jeden znak podany 
    push ax                              
    sub al, bl ; czy enter nacisniety
    jne loop1
    
        ;DO CZYTANIA STRINGOW JEST int 21h z ah = 0ah
    
                            
                               
    mov	ah,4ch  ; zakoncz program i wroc do systemu
	int	021h
 

ret

code1 ends

stos1 segment stack
    dw 200 dup(?)
wstosu dw ?

stos1 ends

end start1


