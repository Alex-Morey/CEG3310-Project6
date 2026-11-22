; Project 6 custom decimal output TRAP x41
; Prints unsigned decimal values 0..99 from R0; preserves all registers.
.ORIG x5000
ST R0, OUT_R0
ST R1, OUT_R1
ST R2, OUT_R2
ST R3, OUT_R3
ST R7, OUT_R7
ADD R1, R0, #0          ; remaining value
AND R2, R2, #0          ; tens
OUT_TENS
ADD R3, R1, #-10
BRn OUT_DIGITS
ADD R1, R3, #0
ADD R2, R2, #1
BRnzp OUT_TENS
OUT_DIGITS
ADD R0, R2, #0
LD R3, OUT_ASC0
ADD R0, R0, R3
OUT
ADD R0, R1, R3
OUT
LD R0, OUT_R0
LD R1, OUT_R1
LD R2, OUT_R2
LD R3, OUT_R3
LD R7, OUT_R7
RET
OUT_ASC0 .FILL #48
OUT_R0 .BLKW 1
OUT_R1 .BLKW 1
OUT_R2 .BLKW 1
OUT_R3 .BLKW 1
OUT_R7 .BLKW 1
.END
