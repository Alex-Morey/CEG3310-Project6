; Project 6 custom decimal input TRAP x40
; Reads exactly two decimal digits (ignores other characters).
; Returns numeric value 0..99 in R0. Preserves R1-R7.
.ORIG x4000
ST R1, IN_R1
ST R2, IN_R2
ST R3, IN_R3
ST R7, IN_R7
AND R2, R2, #0          ; accumulated value
AND R3, R3, #0          ; digit count
IN_LOOP
GETC
LD R1, IN_NEG0
ADD R1, R0, R1          ; digit candidate
BRn IN_LOOP
ADD R0, R1, #-10
BRzp IN_LOOP
; echo accepted digit
LD R0, IN_ASC0
ADD R0, R0, R1
OUT
; value = value*10 + digit
ADD R0, R2, R2          ; 2*value
ADD R2, R2, R2          ; 2*value
ADD R2, R2, R2          ; 4*value
ADD R2, R2, R2          ; 8*value
ADD R2, R2, R0          ; 10*value
ADD R2, R2, R1
ADD R3, R3, #1
ADD R0, R3, #-2
BRn IN_LOOP
ADD R0, R2, #0
LD R1, IN_R1
LD R2, IN_R2
LD R3, IN_R3
LD R7, IN_R7
RET
IN_NEG0 .FILL #-48
IN_ASC0 .FILL #48
IN_R1 .BLKW 1
IN_R2 .BLKW 1
IN_R3 .BLKW 1
IN_R7 .BLKW 1
.END
