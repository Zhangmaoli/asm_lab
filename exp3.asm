DATA SEGMENT ;���ݶζ��� 
    string db "Please input a number(1- 9999):" ,0dh,0ah
    wrongstring db " INPUT ERROR!INPUT ONCE MORE! ",0ah,0dh,'$' 
    inputbuffer db 6,0,6 dup(0) 
    c10 dw 10 ;����ʱ����ת������ 
    n dw ? ;Ҫ��׳˵�������ʱ�洢 
    m dw ? ;���� 
    c dw ? ;��λ 
    i dw ? ;��Ԫ�����Լ���׳�
    outputbuffer dw 30000 dup(?) 
DATA ENDS 
;-------------------------------------------------------- 
STACK SEGMENT PARA STACK 'STACK' ;��ջ�δ��� 
    DW 100 DUP(?) 
STACK ENDS 
;-------------------------------------------------------- 
CODE SEGMENT ;����ζ��� 
    ASSUME CS:CODE,DS:DATA,SS:STACK 
    
START: 
    MOV AX,DATA 
    MOV DS,AX 
;------------------------------------------
main proc
    call input 
    call compute 
    mov cx,di                                                             
routput: ;ѭ�����
    push cx           ;�˴�cx��Ϊ���� 
    mov di,cx 
    call output
    pop cx
    dec cx
    cmp cx,0
    jge routput       ;>=
over:
    mov dl,0dh 
    mov ah,2 
    int 21h           ;�س�
    mov dl,0ah 
    mov ah,2 
    int 21h           ;����
    jmp Start 
exit:
    mov ah,07h 
    int 21h 
    mov ax,4c00h      ;��������
    int 21H           ;����DOS
main endp             ;�������� 
;------------------------------------------ 

;------------------------------------------
input proc near
    lea bx,string    ;ȡԴ������ƫ�Ƶ�ַ
    mov cx, 33
disstring:
    mov dl,[bx]
    mov ah,2
    int 21h          ;�����ʾ��
    inc bx
    loop disstring
    jmp inputinit
wronginput:          ;��������
    lea dx,wrongstring
    mov ah,9
    int 21h          ;��ʾ�ַ���������ʾ
inputinit:           ;��ʼ��
    lea dx,inputbuffer   ;װ�����뻺�����׵�ַ
    mov ah,0ah           ;���빦�ܴ���
    int 21h              ;�Ӽ�������һ�������Իس�������
    mov ax,0             ;�ۼ�����0
    mov cl,inputbuffer+1 ;ѭ������
    mov ch,0
    lea bx,inputbuffer+2 ;װ���ַ�������׵�ַ
inputone:
    mul c10              ;ax = ax * 10                                                 
    mov dl,[bx]          ;���������ʱ����
    cmp dl,'0'
    jb wronginput        ;<
    cmp dl,'9'
    ja wronginput        ;>
    and dl,0fh           ;dl��ascii��30-39���˲�����������λת��Ϊʮ����
    add al,dl 
    adc ah,0 
    inc bx               ;��ַ��һ
    loop inputone 
    mov n,ax             ;n�洢���������
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
    mov cx,n             ;����������ʼΪ��������֣�ctrliѭ��һ�μ�һ
    mov i,1d             
    mov m,0d             ;����Ϊ0
    
    push dx                                                         
    mov di,0d 
    mov ax,di            
    mov bx,2d 
    mul bx               ;ax = 2 * di  ��Ϊ��dw���ͣ�ռ2�ֽ�
    mov si,ax            ;siΪ�±�
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
    div bx                ;ax����̣�dx�������
    mov c,ax

    push dx               ;����ѹջ����
    mov ax,di 
    mov bx,2d 
    mul bx                ;ax = 2 * di
    mov si,ax
    pop dx 
    mov outputbuffer[si],dx;�����洢���±�Ϊ2*di�� 
    inc di                ;di+1

    jmp ctrldi 
cmpc: 
    cmp c,0               ;�ж��Ƿ��н�λ
    ja three1             ;>
    jmp next 
three1:
    ;�н�λ��������һ�����̴洢��outputbuffer[si+2]��֮ǰ�ѽ������洢��outputbuffer[si]�� 
    inc m 
    mov ax,c 
    mov outputbuffer[si+2],ax 
next:
    inc i
    cmp cx,0              ;ѭ������
    jng if0               ;�з��űȽϣ�<=����cx=0
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
CODE ENDS ;������
END START ;��������