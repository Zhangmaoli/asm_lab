;exp1.asm
;1~36�洢��6*6�����У���ӡ�����½�
.model small
data   segment   'data'
    arr db 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36   ;arr[x][y],����ռ1�ֽڣ�Ϊchar��
data   ends     

code   segment   'code'
    assume cs:code,ds:data
start:
    mov ax,data
    mov ds,ax  
    mov cx,0   ;cx�൱��x,��  0<=x<6
    mov di,0   ;di�൱��y,��  0<=y<6
    
L1:
    cmp cx,6;cx-6 �ı�CF/OF/SF/ZF            ���Ƚ�x��6
    jl  L2  ;SF��OF���=1  (SF ? OF) = 1     ��<��ת��L2
    jnl L4  ;SF��OF���=0  (SF ? OF) = 0      >=ʱ��ת��L4
L2:
    cmp di,cx                               ;�Ƚ�y��x(����Ҫ����Ҫ��ӡ�����½ǵ�����)
    jng print     ;( (SF?OF)��ZF )= 1         <=ʱ��ת��print,����Ҫ���ӡ
    jg  L3       ;( (SF?OF)��ZF )= 0         >��ת��L3
L3:
    inc cx       ;cx+1
    mov di,0
    mov dl,10
    mov ah,02H
    int 21H      ;��ӡ���з�\n
    mov dl,13
    mov ah,02H
    int 21H      ;��ӡ�س���\r
    jmp L1
L4:
    mov ax,4c00H
    int 21H      ;��������
L5:                                          
    mov dl,10
    div dl       ;al/10,��������������̵�ASCII��
    mov bl,ah
    mov dl,al
    add dl,48    ;dl+48,�����Ӧ�ַ���ASCII
    mov ah,02H
    int 21H      ;���dl�е���
    mov dl,bl
    add dl,48
    mov ah,02H
    int 21H
    inc di       ;di+1
    jmp L6
L6:
    mov dl,32
    mov ah,02H
    int 21H      ;�����ո�
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
    int 21H      ;���dl�е���
    inc di
    jmp L6
code   ends
end start
    
        