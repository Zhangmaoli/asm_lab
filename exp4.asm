DATA SEGMENT
    string db "**Please input an expression:**" ,0dh,0ah
    s dw 1200 dup(0)      ;�洢���ʽ
	s_opr dw 1200 dup(0)  ;�洢�з��Ų�����
	s_num dw 1200 dup(0)  ;�洢��������+��-
	p_opr dw 0            
    p_num dw 0
    num dw 0              ;ת��Ϊʮ���ƵĲ�����
    num1 dw 0
    num2 dw 0
    num3 dw 0
    op dw 0               ;������+��-
    flag dw 0             
    np dw 1               ;���ڴ�������������
	c dw 0                ;��ǰ�ַ�
	ex_c dw 0             ;�洢��ǰ�ַ�ǰһ���ַ�
	len dw 0              ;�洢����ı��ʽ���ȣ�������β���ţ�
	i dw 0
DATA ENDS
;---------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
    
START:
    MOV AX,DATA
    MOV DS,AX
;---------------------------------------------   
main proc 
    call input  
    call compute
    call output    
over:
    mov dl,0dh 
    mov ah,2 
    int 21h           ;�س�
    mov dl,0ah 
    mov ah,2 
    int 21h           ;����     
exit:
    mov ah,4Ch
    int 21h
main endp
;---------------------------------------------

;---------------------------------------------
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
inputinit:           ;��ʼ��
    mov di,len
    add di,len
    mov s[di],'('    ;���ʽ��ʼΪ��
    inc len
    mov np,1   
inputone:
;������ʽ������s[]�������س������� 
    mov ah,1
	int 21h              ;��׼����	
	cmp al,13            ;��λ�������س��������ȡ������
	je readover          ;=	
	mov ah,0
	mov di,len
	add di,len
	mov s[di],ax         ;�����ַ�������s[]
	inc len 
    jmp inputone
readover:
    mov di,len
    add di,len 
    mov s[di],')'
    inc len              ;���ʽ�����ϣ�    
    mov dl,10
    mov ah,2             
    int 21h              ;����
    mov dl,13
    mov ah,2
    int 21h              ;�س� 
ret
input endp 
;---------------------------------------------   
compute proc near
    mov i,0
loop0:      
    mov ax,c       
    mov ex_c,ax;ex_c=c
    mov di,i          
    add di,i
    mov ax,s[di]
    mov c,ax;   c=s[i]              
case:       
    mov ax,0  
   ;��cΪ��������ת            
    cmp c,'0'                    
    jb f0                ;<   ��ΪcΪ���Ż�Ӽ����������ת��f0
    cmp c,'9'
    ja f0                ;>
    mov ax,1             ;cΪ���֣�ax=1
f0: 
;�жϵ�ǰ�ַ�c�����ͣ����֡�+��-��������
    cmp ax,1              
    je c_eq_digit 
    cmp c,'+'
    je c_eq_operator
    cmp c,'-' 
    je c_eq_operator
    cmp c,'('
    je c_eq_lbracket     
    cmp c,')'
    je c_eq_rbracket                          
c_eq_digit:
;cΪ����ʱ��flag=1��ת��Ϊʮ���Ƹ�ֵ��num            
    mov flag,1              ;flag=1
    sub c,'0'               ;ת��Ϊʮ���� 0-9
    mov ax,num
    mov bx,10
    mul bx
    add ax,c          
    mov num,ax              ;num=num*10+c
    jmp endcase  
    
c_eq_operator:
    mov ax,flag       
    cmp ax,0
    je f1                   ;flag=0��ת
    mov ax,num
    mov bx,np
    mul bx
    mov di,p_num
    add di,p_num
    mov s_num[di],ax        ;s_num[p_num]=num*np
    inc p_num  
    mov num,0    
    mov flag,0    
    mov np,1       
f1:         
    mov ax,ex_c
    cmp ax,'('
    jne f2                  ;ex_c != '('��ת
    mov ax,c
    cmp ax,'-'
    jne f3                  ;c != '-'��ת
    mov np,-1   
f3:                   
    jmp endcase             ;continue
f2:                       
    dec p_opr               ;������ָ���Լ�
    mov di,p_opr
    add di,p_opr
    mov ax,s_opr[di]
    mov op,ax               ;op = s_opr[p_opr]
    cmp ax,'('
    jne op_neq_lbracket  
op_eq_lbracket:
    inc p_opr  
    mov di,p_opr
    add di,p_opr
    mov ax,c
    mov s_opr[di],ax        ;s_opr[p_opr]=c
    inc p_opr  
    jmp endcase
op_neq_lbracket:
    dec p_num  
    mov di,p_num
    add di,p_num
    mov ax,s_num[di]
    mov num2,ax             ;num2=s_num[p_num]
    dec p_num  
    mov di,p_num
    add di,p_num
    mov ax,s_num[di]
    mov num1,ax             ;num1=s_num[p_num]
    mov ax,op
    cmp ax,'+'              ;ѡ��+��-
    jne op_eq_minus1
op_eq_plus1:
    mov ax,num1
    add ax,num2
    mov num3,ax             ;num3=num1+num2
    jmp f4
op_eq_minus1:
    mov ax,num1
    sub ax,num2
    mov num3,ax             ;num3=num1-num2
    jmp f4
f4:
;�������Ľ��num3�͵�ǰ������c�ֱ����s_num[]��s_opr[]��
    mov ax,num3
    mov di,p_num
    add di,p_num
    mov s_num[di],ax         ;s_num[p_num]=num3
    inc p_num  
    mov ax,c  
    mov di,p_opr
    add di,p_opr
    mov s_opr[di],ax         ;s_opr[p_opr]=c
    inc p_opr
f5:
    jmp endcase
    
c_eq_lbracket:
    mov di,p_opr
    add di,p_opr
    mov ax,c
    mov s_opr[di],ax          ;s_opr[p_opr]=c
    inc p_opr  
    jmp endcase
c_eq_rbracket:
    mov ax,flag
    cmp ax,0
    je f6                     ;flag = 0��ת 
    mov flag,0                ;��flag = 1ʱ
    mov ax,np
    mov bx,num
    mul bx
    mov di,p_num
    add di,p_num
    mov s_num[di],ax           ;s_num[p_num]=num*np
    mov np,1
    inc p_num
    mov num,0
f6:         
    dec p_opr
    mov di,p_opr
    add di,p_opr
    mov ax,s_opr[di]
    mov op,ax                   ;op = s_opr[p_opr]
    cmp ax,'('
    jne f7                      ;op ��= '('��ת
    jmp endcase 
f7:    
    dec p_num  
    mov di,p_num
    add di,p_num
    mov ax,s_num[di]
    mov num2,ax                  ;num2=s_num[p_num]
    dec p_num  
    mov di,p_num
    add di,p_num
    mov ax,s_num[di]
    mov num1,ax                  ;num1=s_num[p_num]
    mov ax,op
    cmp ax,'+'
    jne op_eq_minus2
op_eq_plus2:
    mov ax,num1
    add ax,num2
    mov num3,ax 
    jmp f8
op_eq_minus2:
    mov ax,num1
    sub ax,num2
    mov num3,ax 
    jmp f8
f8:
    mov di,p_num
    add di,p_num
    mov ax,num3
    mov s_num[di],ax   
    inc p_num
    dec p_opr
    jmp endcase               
             
endcase:     
    inc i
    mov ax,i
    mov bx,len
    cmp ax,bx
    jb loop0
 
    mov di,0
    add di,0
    mov ax,s_num[di]
    mov num,ax         
ret  
compute endp                
;-------------------------------------------- 
output proc near
    cmp num,0
    jge initlen0        ;>=
    mov dl,'-'          ;�Ը���������д���
    mov ah,2
    int 21h
    mov ax,num
    not ax  
    inc ax
    mov num,ax
initlen0:        
    mov len,0
transdigit:
    mov ax,num
    mov dx,0
    mov bx,10
    div bx
    mov num1,ax
    mov di,len
    add di,len
    mov s[di],dx
    inc len
    mov ax,num1
    mov num,ax
    cmp al,0
    ja transdigit
print:
    dec len
    mov di,len   
    add di,len
    mov dx,s[di]
    add dx,'0'
    mov ah,2
    int 21h
    cmp len,0
    ja print
ret
output endp   
;--------------------------------------------    
CODE ENDS
END START;��������