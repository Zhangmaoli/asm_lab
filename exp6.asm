;算术协处理器，从键盘输入x和a1~a3，计算a1*x^1/2 + a2*e^x + a3*sin(x)，结果输出到屏幕。当x小于0时，请输出信息“Error: x<0!”
.486				;指明指令集
.model flat,stdcall	;程序工作模式，flat为Windows程序使用的模式(代码和数据
				;使用同一个4GB段),stdcall为API调用时右边的参数先入栈
option casemap:none	;指明大小写敏感

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
 
scanf PROTO C:dword,:vararg            ;函数名称  PROTO [调用规则] :[第一个参数类型] [,:后续参数类型]
printf PROTO C:dword,:vararg

.data
    x   real8   ?               ;双精度
    a1  real8   ?
    a2  real8   ?
    a3  real8   ?    
    szin byte '%lf %lf %lf %lf',0
    szout byte 0ah,'%lf',0
    errormsg byte 0ah,'Error:x<0!',0ah,0

    res real8   ?               
    one     real8   1.0
    two     real8   2.0
    zero    real8   0.0

.code
start:
    invoke scanf, offset szin,offset x,offset a1,offset a2,offset a3
    fld x
    fcom zero                            ;比较栈顶x与内存中0的大小
    fstsw   ax                           ;将状态寄存器中内容复制到AX中
    sahf                                 ;将协处理器标志复制到标志寄存器中
    jb  error                            ;x<0 跳转到error输出错误信息
    fsqrt                                ;x^1/2,结果存于栈顶
    fmul a1                              ;a1*x^0.5
    fstp res                             ;res = a1*x^0.5，并将结果弹出栈顶
    fld x
    fldl2e                               ;log2 e 压栈
    fmul                                 ;x*log2 e = log2 e^x
    fcom    one
    fstsw   ax
    sahf
    ja  large                            ;log2 e^x > 1 跳转到large
    f2xm1                                ;求函数(2^x - 1)，-1<x<1 ,此处x = log2 e^x，栈顶结果为e^x-1
    fld1 
    fadd                                 ;栈顶为e^x 
pow_end:         
    fmul a2                              ;a2*e^x
    fadd res                             ;a1*x^1/2 + a2*e^x
    fstp res                             ;res = a1*x^1/2 + a2*e^x，并将结果弹出栈顶
    fld x
    fsin
    fmul a3                              ;a3*sin(x)
    fadd res                             ;a1*x^1/2 + a2*e^x + a3*sin(x)
    fstp res                             ;res = a1*x^1/2 + a2*e^x + a3*sin(x)，并将结果弹出栈顶
    invoke printf,offset szout,res
    ret
;--------------------------------------------------------
error:
    invoke printf,offset errormsg
    ret
;--------------------------------------------------------
    large:
        mov ebx,0
    large_loop:
        fld1                             ;1.0
        fsub                             ;log2 e^x - 1
        inc ebx
        fcom one                        
        fstsw   ax
        sahf
        ja large_loop                    ;loop to less than 1
        f2xm1
        fld1 
        fadd                             ;e^x/(2^n)    
        fld1                             
    lsolve:                              ;2^n 
        cmp ebx,0
        je  large_end
        fmul two
        dec ebx
        jmp lsolve
    large_end:
        fmul                             ;e^x
        jmp  pow_end
;--------------------------------------------------------
   
end start