DATA SEGMENT ;数据段定义 
    string db "Please input a number(1- 9999):" ,0dh,0ah
    wrongstring db " INPUT ERROR!INPUT ONCE MORE! ",0ah,0dh,'$' 
    inputbuffer db 6,0,6 dup(0) 
    c10 dw 10 ;输入时进制转换的数 
    n dw ? ;要求阶乘的数，临时存储 
    m dw ? ;步长 
    c dw ? ;进位 
    i dw ? ;主元，用以计算阶乘
    outputbuffer dw 30000 dup(?) 
DATA ENDS 
;-------------------------------------------------------- 
STACK SEGMENT PARA STACK 'STACK' ;堆栈段代码 
    DW 100 DUP(?) 
STACK ENDS 
;-------------------------------------------------------- 
CODE SEGMENT ;代码段定义 
    ASSUME CS:CODE,DS:DATA,SS:STACK 
    
START: 
    MOV AX,DATA 
    MOV DS,AX 
;------------------------------------------
main proc
    call input 
    call compute 
    mov cx,di                                                             
routput: ;循环输出
    push cx           ;此处cx即为步长 
    mov di,cx 
    call output
    pop cx
    dec cx
    cmp cx,0
    jge routput       ;>=
over:
    mov dl,0dh 
    mov ah,2 
    int 21h           ;回车
    mov dl,0ah 
    mov ah,2 
    int 21h           ;换行
    jmp Start 
exit:
    mov ah,07h 
    int 21h 
    mov ax,4c00h      ;结束处理
    int 21H           ;返回DOS
main endp             ;结束过程 
;------------------------------------------ 

;------------------------------------------
input proc near
    lea bx,string    ;取源操作数偏移地址
    mov cx, 33
disstring:
    mov dl,[bx]
    mov ah,2
    int 21h          ;输出提示语
    inc bx
    loop disstring
    jmp inputinit
wronginput:          ;错误输入
    lea dx,wrongstring
    mov ah,9
    int 21h          ;显示字符串错误提示
inputinit:           ;初始化
    lea dx,inputbuffer   ;装载输入缓冲区首地址
    mov ah,0ah           ;输入功能代码
    int 21h              ;从键盘输入一个数，以回车键结束
    mov ax,0             ;累加器清0
    mov cl,inputbuffer+1 ;循环次数
    mov ch,0
    lea bx,inputbuffer+2 ;装载字符存放区首地址
inputone:
    mul c10              ;ax = ax * 10                                                 
    mov dl,[bx]          ;输入非数字时报错
    cmp dl,'0'
    jb wronginput        ;<
    cmp dl,'9'
    ja wronginput        ;>
    and dl,0fh           ;dl中ascii码30-39，此操作保留低四位转换为十进制
    add al,dl 
    adc ah,0 
    inc bx               ;地址加一
    loop inputone 
    mov n,ax             ;n存储输入的数字
    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah
    mov ah,2
    int 21h  
ret
input endp 
;------------------------------------------
compute proc near 
    mov cx,n             ;计数器，初始为输入的数字，ctrli循环一次减一
    mov i,1d             
    mov m,0d             ;步长为0
    
    push dx                                                         
    mov di,0d 
    mov ax,di            
    mov bx,2d 
    mul bx               ;ax = 2 * di  因为是dw类型，占2字节
    mov si,ax            ;si为下标
    pop dx

    mov outputbuffer[si],1d 
ctrli: 
    mov c,0
    mov di,0d            
ctrldi:
    cmp di,m 
    jbe done              ;<= 
    jmp cmpc              
done:
    push dx 
    mov ax,di 
    mov bx,2d 
    mul bx 
    mov si,ax             ;si = 2 * ax
    pop dx

    mov ax,outputbuffer[si] 
    mov bx,i 
    mul bx                ;ax = i * ax
    add ax,c              ;ax = c + i * ax
    adc dx,0 
    mov bx,10000 
    div bx                ;ax存放商，dx存放余数
    mov c,ax

    push dx               ;余数压栈处理
    mov ax,di 
    mov bx,2d 
    mul bx                ;ax = 2 * di
    mov si,ax
    pop dx 
    mov outputbuffer[si],dx;余数存储至下标为2*di处 
    inc di                ;di+1

    jmp ctrldi 
cmpc: 
    cmp c,0               ;判断是否有进位
    ja three1             ;>
    jmp next 
three1:
    ;有进位，步长加一，将商存储至outputbuffer[si+2]，之前已将余数存储至outputbuffer[si]中 
    inc m 
    mov ax,c 
    mov outputbuffer[si+2],ax 
next:
    inc i
    cmp cx,0              ;循环条件
    jng if0               ;有符号比较，<=，即cx=0
    loop ctrli
if0:
    mov di,m 
ret 
compute endp ;
;--------------------------------------------
output proc near 
    push dx 
    mov ax,di 
    mov bx,2d 
    mul bx
    mov si,ax             ;si = 2 * di   di = m..0
    pop dx
    mov bx,outputbuffer[si]   
p1 proc 
    mov cx,10000 
    mov ax,bx 
    mov dx,0 
    div cx 
    mov bx,dx
    mov cx,1000 
    call print
    mov cx,100 
    call print 
    mov cx,10 
    call print 
    mov cx,1
    call print 
ret
p1 endp 
print proc 
    mov ax,bx 
    mov dx,0 
    div cx 
    mov bx,dx 
    mov dl,al 
    add dl,30h 
    mov ah,02h 
    int 21h 
ret
print endp 
;--------------------------------------------
CODE ENDS ;结束段
END START ;结束程序