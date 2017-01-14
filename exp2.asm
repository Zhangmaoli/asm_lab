EOF=065 
;可以处理0-32767,15位二进制数
data segment
    intxt db '2.txt',0   ;数据所在文件
    inhandle dw 0000h     
    error1 db 'File not found',07h,0
    error2 db 'error',07h,0
    buffer db 0         
    s dw 1024 dup(0)     ;数据不超过1024  存储排序后的数
    n dw 5 dup(0)        
    flag db 0            ;标志是否读取结束
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
    cmp al,'s'           ;输入字符是s，则开始运行程序
    jz open
    jmp over
    
    ;打开输入文件    
over:
   mov ah,4Ch
   int 21h
open:
    mov dx,offset intxt
    mov ax,3D00h         ;打开文件入口参数ah = 3Dh
    int 21h
    jnc openin_ok        ;打开成功
    mov si,offset error1 ;打开失败提示信息
    call dmess
    jmp over
openin_ok:
    mov inhandle,ax
    
cont:
   cmp flag,0
   jg  type_ok           ;>0跳转，即读文件结束时跳转
   call readch           ;从文件中读一个字符
   jc err                ;出错跳转
   cmp al,EOF            ;判断是否读到文件结束符
   jz flagset            ;读到，跳转,修改标志位  
   
   cmp al,48             ;数字0
   jl L1                 ;<
   cmp al,57             ;数字9
   jg L1                 ;>     不是数字的两种情况
   mov di,1              ;di = 1,表示读入数字
   push ax               ;将读入的数字字符压栈
   add bp,1              ;bp + 1,bp表示栈的深度，表示已有数字读入，当读到空格或逗号时将所有数字出栈，写入s
   
   jmp cont              ;继续读字符
err:
   mov si,offset error2
   call dmess            ;不成功提示信息  
flagset:                 ;数据读取结束修改标志位
   mov flag,1
   jmp L1   
type_ok:
   ;关闭输入文件,数据存入s中,跳转至排序
   mov bx,inhandle
   mov ah,3Eh            ;关闭文件
   int 21h       
   mov di,0
   mov bx,0
   sub si,2              
   jmp sort 
   
   ;读字符子程序
readch proc
    mov bx,inhandle
    mov cx,1
    mov dx,offset buffer ;缓冲区地址
    mov ah,3Fh           ;入口参数
    int 21h              ;读
    jc readch2           ;读出错
    cmp ax,cx            ;判断文件是否结束
    mov al,EOF           ;结束置文件结束符
    jb readch1           ;文件结束
    mov al,buffer        ;文件未结束，取出所读的字符
readch1:CLC
readch2:ret
readch endp  

   ;打印字符串子程序
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
    jg L3                ;栈里面有数字，跳转到L3，将数字出栈处理
    add si,2
    mov di,0
    jmp cont
L3: 
    sub bp,1
    pop dx               ;dx是从栈中取出的值
    sub dx,48     
    mov ax,1 
    push cx              ;cx是计数器
    push dx
    mov dx,1
    jmp L4
L4: 
    cmp cx,0
    jng L5
    mov dx,10
    mul dx
    sub cx,1             ;计数器cx-1
    jmp L4               ;L4判断值的位数，第一位*1，第二位*10，以此类推
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
    ;初始时di为x，bx相当于y，令x = 0，y = x+2(因为这里是dw)，然后y = y+2，一直比较，大于则替换，一轮下来，x = 0最小，然后令x = x +2，以此类推，直至x = si
    mov bx,di
    cmp di,si
    jl L6    
    mov bp,0
    mov di,0
    jmp print 
 
L6:
    ;L6-8为排序过程 
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
    ;显示时主要令di = 0，di = di +2，依次类推至si，一次输出s[di]
    ;因为对于每个s[di]，它的位数小于6位，所以让它依次除以10,100,1000,10000，得到它的5位，为n[5],先得到的是低位，存储在n[4]中（注意，这里用的是dw，实际下标都要*2），然后依次n[3]/n[2]/n[1]
    mov bx,8  
   
    cmp di,si 
    jng p1 
    mov ah,4CH
    int 21H               ;程序结束
p1: 
    ;除法得到每一位
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
    ;读到某一位不为0，跳转到P4中依次输出剩下位和空格
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
    int 21H               ;输出空格
    add di,2
    jmp print     
p6:
    mov dl,0   
    add dl,48    
    mov ah,02H
    int 21H
    jmp p5               
              
    ;键盘输入字符子程序
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
    int 21H              ;输出空格 
   ; mov cx,0
   ; cmp di,1
   ; jz L2     ;di = 1
   ; mov di,0
    jmp cont 

L2:
    cmp bp,0
    jg L3                ;栈里面有数字，跳转到L3，将数字出栈处理
    add si,2
    mov di,0
    jmp cont
L3: 
    sub bp,1
    pop dx               ;dx是从栈中取出的值  
    cmp dx,57            ;dx是数字
    jl T1
    cmp dx,70            ;dx是大写字母
    jl T2                         
    cmp dx,102           ;dx是小写字母
    jl T3
  
T1:    
    sub dx,48     
    mov ax,1 
    push cx              ;cx是计数器
    push dx
    mov dx,1
    jmp L4
T2:
    sub dx,65    
    mov ax,1 
    push cx              ;cx是计数器
    push dx
    mov dx,1
    jmp L4 
T3：
    sub dx,97    
    mov ax,1 
    push cx              ;cx是计数器
    push dx
    mov dx,1
    jmp L4 
L4: 
    cmp cx,0
    jng L5
    mov dx,10
    mul dx
    sub cx,1             ;计数器cx-1
    jmp L4               ;L4判断值的位数，第一位*1，第二位*10，以此类推 
L5: 
    pop dx  
    mul dx               ;ax = ax * dx
    mov cx,s[si]
    add cx,ax
    mov s[si],cx  ;      ;s[i] = s[si]+ax
    pop cx               ;cx = s[si]+ax
    add cx,1             
    jmp L2        


       
       
