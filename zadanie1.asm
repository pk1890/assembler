
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt


dane1 segment
emptytxt db ' $'    
hellotxt db "Wprowadz slowny opis dzialania:  $"        
error_msg db 'Nieprawidlowe dane $'         
print_error_msg db 'liczba spoza zakresu wypisywania $' 
minus db 'minus $'
zero db "zero $"
one db "jeden $"
two db "dwa $"
three db "trzy $"
four db "cztery $"
five db "piec $"
six db "szesc $"
seven db "siedem $"
eight db "osiem $"
nine db "dziewiec $"
ten db "dziesiec $"
eleven db 'jedenascie $'
twelve db 'dwanascie $'
thirteen db 'trzynascie $'
fourteen db 'czternascie $'
fifteen db 'pietnascie $'
sixteen db 'szesnascie $'
seventeen db 'siedemnascie $'
eighteen db 'osiemnascie $'
nineteen db 'dziewietnascie $' 
twenty db 'dwadziescia $'
thirty db 'trzydziesci $'
fourty db 'czterdziesci $'
fifty db 'piecdziesiat $'
sixty db 'szescdziesiat $'
seventy db 'siedemdizesiat $'
eighty db 'osiemdziesiat $'
ninety db 'dziewiecdziesiat $'
hundred db 'sto $'
buffer db 30,?, 30 dup(0),    ;bufor na podanego stringa
db 100 dup(0)

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
        
    mov bx, offset buffer + 2  ;opusc dwa pierwsze bajty buforu (dlugosc buforu i ilosc sczytanych bajtow
    
    xor cx, cx
    
    loop:
    call delspace ;usun spacje z poczatku stringa
    
    mov al, byte ptr ds:[bx] ; sprawdz czy pierwszy znak stringa to nie dolar (czyli ze koniec)
    cmp al, '$'                                                             
    je end
    
    call read_num ;parsuj liczbe               
    
    cmp al, 0aah  ; obsluz bledne dane
    je wrong_input                    
        
    xor ah, ah ; wyczysc ah    
    push ax ;odluz liczbe na stos   
    
    add cx, ax

                             
                                 
    mov dl, 'Y' ;jak nie to sprawdz nastepny bajt 
    mov ah, 2
    int 21h   
    
    
    jmp loop
    
   
    
    
    
    end:
    mov ax, cx
    
    call print_unum_word       
                              
    mov	ah,4ch  ; zakoncz program i wroc do systemu   
	int	021h    
	
	wrong_input:
	mov dx, offset error_msg
	mov ah, 9
	int 21h
	jmp end
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CZESC KODU PROCEDUR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
	
	delspace proc ; utnij spacje z pocztaku stringa zaczynajacego sie na adresie ds:dx  
;	mov bx, dx
    delspace_loop:
    mov al, ' '
    mov ah, byte ptr ds:[bx]
    sub al, ah ; sprawdz czy pierwszy znak to spacja
    jne endfunc_delspace
    
    inc bx
    jmp delspace_loop
    
    endfunc_delspace:
   ; mov dx, bx
    ret 
    
    delspace endp
	
	
	 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    checkword proc ; sprawdza, czy slowo zaczynajace sie na adresie ds:bx zgadza sie ze wzorcem pod adresem ds:ax 
    push bx
    ;mov bp, dx ;przepisz do cx poczatek stringa
    mov bp, ax ; wpisz do bp adres wzorca
            
    checkloop:        
    mov al, byte ptr [bx]    ;pierwszy bajt stringa do porownania
    mov ah, byte ptr ds:[bp]    ;pierwszy bajt wprowadzonego stringa

    
    sub al, ah ;czy sa takie same
    jne endfunc_checkword_wrong 
    
    ok: ; jak ok to:
    mov al, 20h ;wprowadzam spacje
    sub al, ah ;sprawdzam, czy ten znak to byla spacja
    
    je endfunc_checkword_good ;jak to byla spacja, to znaczy ze wprowadzone slowo zgadza sie ze wzornikiem
        
        
    inc bx  ;nastepny bajt
    inc bp  ;nastepny bajt
    jmp checkloop ;powtorz
    
                         
    endfunc_checkword_wrong:
    pop bx ; przywroc wskaznik na przed slowem 
    ret                                       
    
    endfunc_checkword_good:
    add sp, 2          ;sciagnij wartosc ze stosu  ! zmienia zero flag
    cmp al, al ; ustaw zero flag
    ret
    
    checkword endp
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    read_num proc; procedura, ktora czyta slowo  zaczynajace sie na adresie ds:dx i zwraca jego wartosc w al
    
    mov ax, offset zero  
    call checkword
    mov al, 0
    je endfunc_read_num
    
    mov ax, offset one  
    call checkword
    mov al, 1
    je endfunc_read_num
    
    mov ax, offset two  
    call checkword
    mov al, 2
    je endfunc_read_num     
    
    mov ax, offset three  
    call checkword
    mov al, 3
    je endfunc_read_num
    
    mov ax, offset four  
    call checkword
    mov al, 4
    je endfunc_read_num
    
    mov ax, offset five  
    call checkword
    mov al, 5
    je endfunc_read_num
    
    mov ax, offset six  
    call checkword
    mov al, 6
    je endfunc_read_num
    
    mov ax, offset seven  
    call checkword
    mov al, 7
    je endfunc_read_num
    
    mov ax, offset eight  
    call checkword
    mov al, 8
    je endfunc_read_num
                         
    mov ax, seg nine
    mov ds, ax                     
    mov ax, offset nine   
    call checkword
    mov al, 9
    je endfunc_read_num 
    
     mov ax, offset ten  
    call checkword
    mov al, 10
    je endfunc_read_num                      
                         
    mov al, 0aah   ; 0aah oznacza nieprawidlowa wartosc
    
    endfunc_read_num:
    ret             
                   
                   
    read_num endp 
    
    
    print_unum_word proc ; wypisuje na ekranie liczbe z ax
        push ax
        push bx
        push cx
        push dx
        
        cmp ax, 0
        jnl print_abs 
        
        neg ax    ;ax = -ax
        push ax   ;push ax bo int21h wymaga zmiany ax
        mov dx, offset minus
        mov ah, 9   ;wyswietl min
        int 21h
        pop ax    ;przywroc stary
        
        
        
        print_abs:
        cmp ax, 100 
        je print_sto
        jg print_error     
        
              
        xor dx, dx      
              
        mov bx, 10
        div bx ;dzielimy przez 10
        
        push dx ; przechowaj reszte z dzielenia
        
        cmp ax, 0
        je sing_digit_print
        
        cmp ax, 1
        je teen_print
        
        cmp ax, 2
        mov dx, offset twenty
        je double_dig_print
                           
        
        cmp ax, 3
        mov dx, offset thirty
        je double_dig_print
        
        
        cmp ax, 4
        mov dx, offset fourty
        je double_dig_print
        
        
        cmp ax, 5
        mov dx, offset fifty
        je double_dig_print
        
        
        cmp ax, 6
        mov dx, offset sixty
        je double_dig_print
        
        
        cmp ax, 7
        mov dx, offset seventy
        je double_dig_print
        
        
        cmp ax, 8
        mov dx, offset eighty
        je double_dig_print
        
        
        cmp ax, 9
        mov dx, offset ninety
        je double_dig_print                   
          
        
        
        print_num_end:
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
        
        
        sing_digit_print:      
        pop dx ; zrzuc reszte z dzielenia
        mov ax, dx; przesun ja do ax
        
        cmp ax, 0
        mov dx, offset zero
        je digit_printout

        cmp ax, 1
        mov dx, offset one
        je digit_printout
        
        cmp ax, 2
        mov dx, offset two
        je digit_printout
        
        cmp ax, 3
        mov dx, offset three
        je digit_printout
        
        cmp ax, 4
        mov dx, offset four
        je digit_printout
        
        cmp ax, 5
        mov dx, offset five
        je digit_printout
        
        cmp ax, 6
        mov dx, offset six
        je digit_printout
        
        cmp ax, 7
        mov dx, offset seven
        je digit_printout
        
        cmp ax, 8
        mov dx, offset eight
        je digit_printout
        
        cmp ax, 9
        mov dx, offset nine
        je digit_printout
        

        digit_printout:
        mov ah, 9
    	int 21h
	    jmp  print_num_end 
        

        teen_print:
        pop dx ; zrzuc reszte z dzielenia

        mov ax, dx; przesun ja do ax
        
        cmp ax, 0
        mov dx, offset ten
        je digit_printout

        cmp ax, 1
        mov dx, offset eleven
        je digit_printout
        
        cmp ax, 2
        mov dx, offset twelve
        je digit_printout
        
        cmp ax, 3
        mov dx, offset thirteen
        je digit_printout
        
        cmp ax, 4
        mov dx, offset fourteen
        je digit_printout
        
        cmp ax, 5
        mov dx, offset fifteen
        je digit_printout
        
        cmp ax, 6
        mov dx, offset sixteen
        je digit_printout
        
        cmp ax, 7
        mov dx, offset seventeen
        je digit_printout
        
        cmp ax, 8
        mov dx, offset eighteen
        je digit_printout
        
        cmp ax, 9
        mov dx, offset nineteen
        je digit_printout


        double_dig_print:
        mov ah, 9 ; wypisz dziesiatki
    	int 21h

        jmp sing_digit_print

        print_sto:  ; osobny przypadek zeby nie musiec dzielic przez 100

        mov dx, offset hundred
    	mov ah, 9          
    	int 21h
	    jmp end
        
        print_error:
           
        mov dx, offset print_error_msg
    	mov ah, 9
    	int 21h
	    jmp  print_num_end 
	    
	    
	    
	      
        
        
    print_unum_word endp
    
ret

code1 ends

stos1 segment stack
    dw 200 dup(?)
wstosu dw ?

stos1 ends

end start1


