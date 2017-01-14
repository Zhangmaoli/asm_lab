;����Э���������Ӽ�������x��a1~a3������a1*x^1/2 + a2*e^x + a3*sin(x)������������Ļ����xС��0ʱ���������Ϣ��Error: x<0!��
.486				;ָ��ָ�
.model flat,stdcall	;������ģʽ��flatΪWindows����ʹ�õ�ģʽ(���������
				;ʹ��ͬһ��4GB��),stdcallΪAPI����ʱ�ұߵĲ�������ջ
option casemap:none	;ָ����Сд����

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
 
scanf PROTO C:dword,:vararg            ;��������  PROTO [���ù���] :[��һ����������] [,:������������]
printf PROTO C:dword,:vararg

.data
    x   real8   ?               ;˫����
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
    fcom zero                            ;�Ƚ�ջ��x���ڴ���0�Ĵ�С
    fstsw   ax                           ;��״̬�Ĵ��������ݸ��Ƶ�AX��
    sahf                                 ;��Э��������־���Ƶ���־�Ĵ�����
    jb  error                            ;x<0 ��ת��error���������Ϣ
    fsqrt                                ;x^1/2,�������ջ��
    fmul a1                              ;a1*x^0.5
    fstp res                             ;res = a1*x^0.5�������������ջ��
    fld x
    fldl2e                               ;log2 e ѹջ
    fmul                                 ;x*log2 e = log2 e^x
    fcom    one
    fstsw   ax
    sahf
    ja  large                            ;log2 e^x > 1 ��ת��large
    f2xm1                                ;����(2^x - 1)��-1<x<1 ,�˴�x = log2 e^x��ջ�����Ϊe^x-1
    fld1 
    fadd                                 ;ջ��Ϊe^x 
pow_end:         
    fmul a2                              ;a2*e^x
    fadd res                             ;a1*x^1/2 + a2*e^x
    fstp res                             ;res = a1*x^1/2 + a2*e^x�������������ջ��
    fld x
    fsin
    fmul a3                              ;a3*sin(x)
    fadd res                             ;a1*x^1/2 + a2*e^x + a3*sin(x)
    fstp res                             ;res = a1*x^1/2 + a2*e^x + a3*sin(x)�������������ջ��
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