EOF=065 
;���Դ���0-32767,15λ��������
data segment
    intxt db '2.txt',0   ;���������ļ�
    inhandle dw 0000h     
    error1 db 'File not found',07h,0
    error2 db 'error',07h,0
    buffer db 0         
    s dw 1024 dup(0)     ;���ݲ�����1024  �洢��������
    n dw 5 dup(0)        
    flag db 0            ;��־�Ƿ��ȡ����
data ends

code segment
    assume cs:code,ds:data
start:
    mov ax,data
    mov ds,ax
              
    mov di,0
    mov bp,0
    mov si,0          
              
    call inputch
    cmp al,'s'           ;�����ַ���s����ʼ���г���
    jz open
    jmp over
    
    ;�������ļ�    
over:
   mov ah,4Ch
   int 21h
open:
    mov dx,offset intxt
    mov ax,3D00h         ;���ļ���ڲ���ah = 3Dh
    int 21h
    jnc openin_ok        ;�򿪳ɹ�
    mov si,offset error1 ;��ʧ����ʾ��Ϣ
    call dmess
    jmp over
openin_ok:
    mov inhandle,ax
    
cont:
   cmp flag,0
   jg  type_ok           ;>0��ת�������ļ�����ʱ��ת
   call readch           ;���ļ��ж�һ���ַ�
   jc err                ;������ת
   cmp al,EOF            ;�ж��Ƿ�����ļ�������
   jz flagset            ;��������ת,�޸ı�־λ  
   
   cmp al,48             ;����0
   jl L1                 ;<
   cmp al,57             ;����9
   jg L1                 ;>     �������ֵ��������
   mov di,1              ;di = 1,��ʾ��������
   push ax               ;������������ַ�ѹջ
   add bp,1              ;bp + 1,bp��ʾջ����ȣ���ʾ�������ֶ��룬�������ո�򶺺�ʱ���������ֳ�ջ��д��s
   
   jmp cont              ;�������ַ�
err:
   mov si,offset error2
   call dmess            ;���ɹ���ʾ��Ϣ  
flagset:                 ;���ݶ�ȡ�����޸ı�־λ
   mov flag,1
   jmp L1   
type_ok:
   ;�ر������ļ�,���ݴ���s��,��ת������
   mov bx,inhandle
   mov ah,3Eh            ;�ر��ļ�
   int 21h       
   mov di,0
   mov bx,0
   sub si,2              
   jmp sort 
   
   ;���ַ��ӳ���
readch proc
    mov bx,inhandle
    mov cx,1
    mov dx,offset buffer ;��������ַ
    mov ah,3Fh           ;��ڲ���
    int 21h              ;��
    jc readch2           ;������
    cmp ax,cx            ;�ж��ļ��Ƿ����
    mov al,EOF           ;�������ļ�������
    jb readch1           ;�ļ�����
    mov al,buffer        ;�ļ�δ������ȡ���������ַ�
readch1:CLC
readch2:ret
readch endp  

   ;��ӡ�ַ����ӳ���
dmess proc   
dmess1:
    mov di,[si]
    inc si
    or dl,dl
    jz dmess2
    mov ah,2
    int 21h
    jmp dmess1
dmess2:ret
dmess endp           

L1: 
    mov cx,0
    cmp di,1
    jz L2     ;di = 1
    mov di,0
    jmp cont  
L2:
    cmp bp,0
    jg L3                ;ջ���������֣���ת��L3�������ֳ�ջ����
    add si,2
    mov di,0
    jmp cont
L3: 
    sub bp,1
    pop dx               ;dx�Ǵ�ջ��ȡ����ֵ
    sub dx,48     
    mov ax,1 
    push cx              ;cx�Ǽ�����
    push dx
    mov dx,1
    jmp L4
L4: 
    cmp cx,0
    jng L5
    mov dx,10
    mul dx
    sub cx,1             ;������cx-1
    jmp L4               ;L4�ж�ֵ��λ������һλ*1���ڶ�λ*10���Դ�����
L5: 
    pop dx  
    mul dx               ;ax = ax * dx
    mov cx,s[si]
    add cx,ax
    mov s[si],cx  ;      ;s[i] = s[si]+ax
    pop cx               ;cx = s[si]+ax
    add cx,1             
    jmp L2        
              
sort: 
    ;��ʼʱdiΪx��bx�൱��y����x = 0��y = x+2(��Ϊ������dw)��Ȼ��y = y+2��һֱ�Ƚϣ��������滻��һ��������x = 0��С��Ȼ����x = x +2���Դ����ƣ�ֱ��x = si
    mov bx,di
    cmp di,si
    jl L6    
    mov bp,0
    mov di,0
    jmp print 
 
L6:
    ;L6-8Ϊ������� 
    cmp bx,si
    jnl L8       
    add bx,2   
    mov cx,s[bx]
    cmp s[di],cx
    jg L7
    jmp L6     
L7:
    mov cx,s[di]  
    mov bp,s[bx]
    mov s[di],bp
    mov s[bx],cx 
    jmp L6
    
L8:
    add di,2
    jmp sort      

print:  
    ;��ʾʱ��Ҫ��di = 0��di = di +2������������si��һ�����s[di]
    ;��Ϊ����ÿ��s[di]������λ��С��6λ�������������γ���10,100,1000,10000���õ�����5λ��Ϊn[5],�ȵõ����ǵ�λ���洢��n[4]�У�ע�⣬�����õ���dw��ʵ���±궼Ҫ*2����Ȼ������n[3]/n[2]/n[1]
    mov bx,8  
   
    cmp di,si 
    jng p1 
    mov ah,4CH
    int 21H               ;�������
p1: 
    ;�����õ�ÿһλ
    mov ax,s[di]   
    mov cx,10  
    mov dx,0
    div cx
    ;push dx
    mov n[bx],dx  
    mov s[di],ax 
    cmp bx,0
    jng p2
    sub bx,2 
    jmp p1
p2: 
    mov bx,0
    jmp p3   
p3:  
    ;����ĳһλ��Ϊ0����ת��P4���������ʣ��λ�Ϳո�
    cmp n[bx],0
    jg p4 
    add bx,2
    cmp bx,8
    jg p6
    jmp p3   
p4:
    cmp bx,8
    jg p5
    mov dx,n[bx]   
    ;pop dx
    add dl,48    
    mov ah,02H
    int 21H 
    add bx,2  
    jmp p4    
 p5:
    mov dl,32
    mov ah,02H
    int 21H               ;����ո�
    add di,2
    jmp print     
p6:
    mov dl,0   
    add dl,48    
    mov ah,02H
    int 21H
    jmp p5               
              
    ;���������ַ��ӳ���
inputch proc
    push dx
    mov ah,01h
    int 21h
    pop dx
    ret
inputch endp      

code ends
end start

 


L1:     
    mov dl,32
    mov ah,02H
    int 21H              ;����ո� 
   ; mov cx,0
   ; cmp di,1
   ; jz L2     ;di = 1
   ; mov di,0
    jmp cont 

L2:
    cmp bp,0
    jg L3                ;ջ���������֣���ת��L3�������ֳ�ջ����
    add si,2
    mov di,0
    jmp cont
L3: 
    sub bp,1
    pop dx               ;dx�Ǵ�ջ��ȡ����ֵ  
    cmp dx,57            ;dx������
    jl T1
    cmp dx,70            ;dx�Ǵ�д��ĸ
    jl T2                         
    cmp dx,102           ;dx��Сд��ĸ
    jl T3
  
T1:    
    sub dx,48     
    mov ax,1 
    push cx              ;cx�Ǽ�����
    push dx
    mov dx,1
    jmp L4
T2:
    sub dx,65    
    mov ax,1 
    push cx              ;cx�Ǽ�����
    push dx
    mov dx,1
    jmp L4 
T3��
    sub dx,97    
    mov ax,1 
    push cx              ;cx�Ǽ�����
    push dx
    mov dx,1
    jmp L4 
L4: 
    cmp cx,0
    jng L5
    mov dx,10
    mul dx
    sub cx,1             ;������cx-1
    jmp L4               ;L4�ж�ֵ��λ������һλ*1���ڶ�λ*10���Դ����� 
L5: 
    pop dx  
    mul dx               ;ax = ax * dx
    mov cx,s[si]
    add cx,ax
    mov s[si],cx  ;      ;s[i] = s[si]+ax
    pop cx               ;cx = s[si]+ax
    add cx,1             
    jmp L2        


       
       
