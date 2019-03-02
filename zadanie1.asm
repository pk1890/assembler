
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt


dane1 segment
    
hellotxt db "Wprowadz slowny opis dzialania:  $"
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
buffer db 30,?, 30 dup(0),    ;bufor na podanego stringa

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
    
 ;   mov bl, 0dh; w bl jest zapisany znak enter
  ;  loop1:                           
  ;  mov ah, 01h
  ;  int 21h ;czytaj z echem jeden znak podany 
  ;  push ax                              
  ;  sub al, bl ; czy enter nacisniety
  ;  jne loop1
    
        ;DO CZYTANIA STRINGOW JEST int 21h z ah = 0ah
   
   mov dx, offset buffer
   mov ah, 0ah           ;czytaj stringa
   int 21h
   
   xor bx, bx                      ; zeruj bx
   mov bl, byte ptr buffer[1]      ; na 1 bajcie budora jest ile znakow sczytano
   mov byte ptr buffer[bx+2], ' '
   mov byte ptr buffer[bx+3], '$'  ; dodaj na koncu sczytanego stringa $
   
    mov ah, 2
	mov dl, 0ah ; wypisz \n
	int 21h 
	
	mov ah, 2
	mov dl, 0dh ; wypisz crt
	int 21h     
        
    mov dx, offset buffer + 2
;	mov ah, 9
;    int 21h   ;wypisz zapisanego stringa
    
    mov ax, offset eight
    
    call checkword                
    
    jne isnotok
    
    isok:
    mov dl, 'Y' ;jak nie to sprawdz nastepny bajt 
    mov ah, 2
    int 21h 
    jmp end
    
    isnotok:
    mov dl, 'N' ;jak nie to sprawdz nastepny bajt 
    mov ah, 2
    int 21h 
    jmp end
    
   
    
    
    
    end:
                              
    mov	ah,4ch  ; zakoncz program i wroc do systemu   
	int	021h   
	
	
	
	
	 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    checkword proc ; sprawdza, czy slowo zaczynajace sie na adresie ds:dx zgadza sie ze wzorcem pod adresem ds:ax 
    
    mov bp, dx ;przepisz do cx poczatek stringa
    mov bx, ax ; wpisz do bx adres wzorca
            
    checkloop:        
    mov al, byte ptr [bx]    ;pierwszy bajt stringa do porownania
    mov ah, byte ptr ds:[bp]    ;pierwszy bajt wprowadzonego stringa

    
    sub al, ah ;czy sa takie same
    jne endfunc_checkword 
    
    ok: ; jak ok to:
    mov al, 20h ;wprowadzam spacje
    sub al, ah ;sprawdzam, czy ten znak to byla spacja
    
    je endfunc_checkword ;jak to byla spacja, to znaczy ze wprowadzone slowo zgadza sie ze wzornikiem
    
    mov dl, 'y' ;jak nie to sprawdz nastepny bajt 
    mov ah, 2
    int 21h  
    inc bx  ;nastepny bajt
    inc bp  ;nastepny bajt
    jmp checkloop
    
                         
    endfunc_checkword: 
    ret
    
    checkword endp
 

ret

code1 ends

stos1 segment stack
    dw 200 dup(?)
wstosu dw ?

stos1 ends

end start1


