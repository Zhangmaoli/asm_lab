;exp1.asm
;1~36存储在6*6数组中，打印出左下角
.model small
data   segment   'data'
    arr db 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36   ;arr[x][y],数字占1字节，为char型
data   ends     

code   segment   'code'
    assume cs:code,ds:data
start:
    mov ax,data
    mov ds,ax  
    mov cx,0   ;cx相当于x,行  0<=x<6
    mov di,0   ;di相当于y,列  0<=y<6
    
L1:
    cmp cx,6;cx-6 改变CF/OF/SF/ZF            即比较x与6
    jl  L2  ;SF与OF异或=1  (SF ? OF) = 1     即<跳转到L2
    jnl L4  ;SF与OF异或=0  (SF ? OF) = 0      >=时跳转到L4
L2:
    cmp di,cx                               ;比较y与x(根据要求需要打印出左下角的数字)
    jng print     ;( (SF?OF)∨ZF )= 1         <=时跳转到print,即按要求打印
    jg  L3       ;( (SF?OF)∨ZF )= 0         >跳转到L3
L3:
    inc cx       ;cx+1
    mov di,0
    mov dl,10
    mov ah,02H
    int 21H      ;打印换行符\n
    mov dl,13
    mov ah,02H
    int 21H      ;打印回车符\r
    jmp L1
L4:
    mov ax,4c00H
    int 21H      ;结束程序
L5:                                          
    mov dl,10
    div dl       ;al/10,下面输出余数和商的ASCII码
    mov bl,ah
    mov dl,al
    add dl,48    ;dl+48,输出对应字符的ASCII
    mov ah,02H
    int 21H      ;输出dl中的数
    mov dl,bl
    add dl,48
    mov ah,02H
    int 21H
    inc di       ;di+1
    jmp L6
L6:
    mov dl,32
    mov ah,02H
    int 21H      ;跳出空格
    jmp L2
print:
    mov ax,cx
    mov si,6
    mul si       ;ax=ax*si
    add ax,di
    mov si,ax
    mov al,arr[si]
    cmp al,10
    jnl L5
    mov dl,al
    add dl,48
    mov ah,02H
    int 21H      ;输出dl中的数
    inc di
    jmp L6
code   ends
end start
    
        