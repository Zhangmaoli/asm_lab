DATA SEGMENT
    string db "**Please input an expression:**" ,0dh,0ah
    s dw 1200 dup(0)      ;存储表达式
	s_opr dw 1200 dup(0)  ;存储有符号操作数
	s_num dw 1200 dup(0)  ;存储（、）、+、-
	p_opr dw 0            
    p_num dw 0
    num dw 0              ;转化为十进制的操作数
    num1 dw 0
    num2 dw 0
    num3 dw 0
    op dw 0               ;操作符+、-
    flag dw 0             
    np dw 1               ;用于处理正负数符号
	c dw 0                ;当前字符
	ex_c dw 0             ;存储当前字符前一个字符
	len dw 0              ;存储输入的表达式长度（包括首尾括号）
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
    int 21h           ;回车
    mov dl,0ah 
    mov ah,2 
    int 21h           ;换行     
exit:
    mov ah,4Ch
    int 21h
main endp
;---------------------------------------------

;---------------------------------------------
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
inputinit:           ;初始化
    mov di,len
    add di,len
    mov s[di],'('    ;表达式开始为（
    inc len
    mov np,1   
inputone:
;输入表达式并存入s[]，读到回车键结束 
    mov ah,1
	int 21h              ;标准输入	
	cmp al,13            ;归位键（按回车键输入读取结束）
	je readover          ;=	
	mov ah,0
	mov di,len
	add di,len
	mov s[di],ax         ;输入字符串存入s[]
	inc len 
    jmp inputone
readover:
    mov di,len
    add di,len 
    mov s[di],')'
    inc len              ;表达式最后加上）    
    mov dl,10
    mov ah,2             
    int 21h              ;换行
    mov dl,13
    mov ah,2
    int 21h              ;回车 
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
   ;若c为数字则不跳转            
    cmp c,'0'                    
    jb f0                ;<   若为c为括号或加减运算符，跳转至f0
    cmp c,'9'
    ja f0                ;>
    mov ax,1             ;c为数字，ax=1
f0: 
;判断当前字符c的类型：数字、+、-、（、）
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
;c为数字时，flag=1，转换为十进制赋值给num            
    mov flag,1              ;flag=1
    sub c,'0'               ;转换为十进制 0-9
    mov ax,num
    mov bx,10
    mul bx
    add ax,c          
    mov num,ax              ;num=num*10+c
    jmp endcase  
    
c_eq_operator:
    mov ax,flag       
    cmp ax,0
    je f1                   ;flag=0跳转
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
    jne f2                  ;ex_c != '('跳转
    mov ax,c
    cmp ax,'-'
    jne f3                  ;c != '-'跳转
    mov np,-1   
f3:                   
    jmp endcase             ;continue
f2:                       
    dec p_opr               ;操作符指针自减
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
    cmp ax,'+'              ;选择+或-
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
;将计算后的结果num3和当前操作符c分别存入s_num[]，s_opr[]中
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
    je f6                     ;flag = 0跳转 
    mov flag,0                ;当flag = 1时
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
    jne f7                      ;op ！= '('跳转
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
    mov dl,'-'          ;对负数结果进行处理
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
END START;结束程序