;konwersja z UTF-8 na UTF-16 i wyswitlanie w MessboxW
.686
.model flat
extern _ExitProcess@4 : PROC
extern _MessageBoxW@16 : PROC
extern __write : PROC ; (dwa znaki podkreœlenia)
public _main


.data

    tytul dw 'T','e','k','s','t',' ','w',' '
    dw 'f','o','r','m','a','c','i','e',' '
    dw 'U','T','F','-','1','6', 0


    bufor   db    50H, 6FH, 0C5H, 82H, 0C4H, 85H, 63H, 7AH, 65H, 6EH, 69H, 61H, 20H

            db    0F0H, 9FH, 9AH, 82H   ; parowóz

            db    20H, 20H, 6BH, 6FH, 6CH, 65H, 6AH, 6FH, 77H, 6FH, 20H

            db    0E2H, 80H, 93H ; pó³pauza

            db    20H, 61H, 75H, 74H, 6FH, 62H, 75H, 73H, 6FH, 77H, 65H, 20H, 20H

            db    0F0H,  9FH,  9AH,  8CH ; autobus
    koniec db ?
    wynik dw 80 dup(?),0

.code
_main:

    
    mov ecx,(OFFSET koniec) - (OFFSET bufor);ilosc znakow
    mov esi,0
    mov edi,0
 ptl:
   mov eax,0
    mov al,bufor[esi]
    inc esi
    cmp al,80H  ;0-7F 1 bajt
    jb bajtowy
    cmp al,0E0H;C0-DF 2 bajty
    jb dwubajtowy
    cmp al,0F0H ;E0-EF 3bajty
    jb trzybajtowy
    jmp czterobajtowy 

bajtowy:
    mov wynik[edi],ax
    add edi,2
    sub ecx,1
    jnz ptl
    jmp next
dwubajtowy:
  ;110xxxxx 10xxxxxx
    mov ah,bufor[esi]
    inc esi
    xchg ah,al
    shl al,2 ;110xxxxx xxxxxx00
    shl ax,3;xxxxxxxx xxx00000
    shr ax,5;00000xxx xxxxxxxx
    mov wynik[edi],ax
    add edi,2
    sub ecx,2
    jnz ptl
    jmp next
trzybajtowy:
    ;1110xxxx 10xxxxxx 10xxxxxx 
    shl al,4
    shr al,4;0000xxxx
    movzx eax,al
    shl eax,16
    mov ah,bufor[esi]
    mov al,bufor[esi+1];0000xxxx 10xxxxxx 10xxxxxx
     add esi,2
    shl al,2;0000xxxx 10xxxxxx xxxxxx00
    shl ax,2;0000xxxx xxxxxxxx xxxx0000
    shr eax,4 ;
    mov wynik[edi],ax
    add edi,2
    sub ecx,3
    jnz ptl
    jmp next
czterobajtowy:
    ;11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    mov ah,bufor[esi]
    inc esi
    xchg ah,al
    shl al,2;11110xxx xxxxxx00
    shl ax,5
    shr ax,7;0000000x xxxx xxxx
    movzx eax,ax
    shl eax,16;
    mov ah,bufor[esi]
    mov al,bufor[esi+1];0000000x xxxx xxxx 10xxxxxx 10xxxxxx
    add esi,2
    shl al,2
    shl ax,2
    shr eax,4;0000000x xxxx xxxx xxxxxx xxxxxx0000
    sub eax,10000H ;algorytm kodowania w utf16
    mov ebx,eax
    shr ebx,10
    add bx,1101100000000000b;starsze s³owo 
    mov wynik[edi],bx
    add edi,2
    shl ax,6
    shr ax,6
    add ax,1101110000000000b;m³odsze s³owo
    mov wynik[edi],ax
    add edi,2
    
    sub ecx,4;
    ;110110xxxxxxxxxx 110111xxxxxxxxxx
    jnz ptl
next:

    push 0 ; liczba znaków wyœwietlanego tekstu
    push OFFSET tytul; po³o¿enie obszaru
    ; ze znakami
    push OFFSET wynik ; uchwyt urz¹dzenia wyjœciowego
    push 0
    call _MessageBoxW@16
    ; zakoñczenie wykonywania programu
    push dword PTR 0 ; kod powrotu programu
    call _ExitProcess@4
END




