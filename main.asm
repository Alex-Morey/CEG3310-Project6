; CEG 3310 Project 6: menu-driven singly linked list
; Node: word 0=value (00..99), word 1=next pointer (0 = null)
; Load input.asm and output.asm into simulator before running.
; Uses TRAP x40 (read two digits) and x41 (print two digits).
.ORIG x3000
; Install TRAP vector entries in writable LC-3 vector table.
LD R0, INPUT_ADDR
STI R0, VECTOR40
LD R0, OUTPUT_ADDR
STI R0, VECTOR41
LD R6, STACK_TOP
AND R0, R0, #0
ST R0, HEAD
ST R0, FREE_HEAD
LD R0, HEAP_START_ADDR
ST R0, HEAP_NEXT
MENU
LEA R0, MENU_TEXT
PUTS
; Menu selection: accept 1..4, ignore Enter and other characters.
MENU_READ
GETC
LD R1, NEG_ASC1
ADD R1, R0, R1
BRn MENU_READ
ADD R2, R1, #-4
BRzp MENU_READ
OUT
LD R0, NEWLINE
OUT
ADD R1, R1, #-1
BRz DO_PRINT
ADD R1, R1, #-1
BRz DO_ADD
ADD R1, R1, #-1
BRz DO_REMOVE
BRnzp FINISH
DO_PRINT
LD R0, HEAD
ADD R6, R6, #-1
STR R0, R6, #0
JSR PRINT_LIST
ADD R6, R6, #1
BRnzp MENU
DO_ADD
LEA R0, ASK_ADD
PUTS
TRAP x40
ST R0, TEMP_VALUE
LD R0, NEWLINE
OUT
LD R0, TEMP_VALUE
ADD R6, R6, #-1
STR R0, R6, #0          ; second argument: value
LEA R0, HEAD
ADD R6, R6, #-1
STR R0, R6, #0          ; first argument: &head
JSR ADD_NODE
ADD R6, R6, #2
BRnzp MENU
DO_REMOVE
LEA R0, ASK_REMOVE
PUTS
TRAP x40
ST R0, TEMP_VALUE
LD R0, NEWLINE
OUT
LD R0, TEMP_VALUE
ADD R6, R6, #-1
STR R0, R6, #0          ; second argument: value
LEA R0, HEAD
ADD R6, R6, #-1
STR R0, R6, #0          ; first argument: &head
JSR REMOVE_NODE
ADD R6, R6, #2
BRnzp MENU
FINISH
; main has no saved caller frame; reset SP then halt.
LD R6, STACK_TOP
HALT

INPUT_ADDR .FILL x4000
OUTPUT_ADDR .FILL x5000
VECTOR40 .FILL x0040
VECTOR41 .FILL x0041
STACK_TOP .FILL xFDFF
HEAP_END_ADDR .FILL HEAP_END
HEAP_START_ADDR .FILL HEAP
NEG_ASC1 .FILL #-49
NEWLINE .FILL #10
SPACE .FILL #32
HEAD .BLKW 1
FREE_HEAD .BLKW 1
HEAP_NEXT .BLKW 1
TEMP_VALUE .BLKW 1
MENU_TEXT .STRINGZ "\n1 Print  2 Add  3 Remove  4 Quit: "
ASK_ADD .STRINGZ "Enter two digits (00-99): "
ASK_REMOVE .STRINGZ "Remove two-digit value: "
EMPTY_TEXT .STRINGZ "(empty list)\n"
FULL_TEXT .STRINGZ "List storage full\n"
MISSING_TEXT .STRINGZ "Value not found\n"

; PRINT_LIST(head): traverse using next pointer; no modifications.
PRINT_LIST
ADD R6, R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R6, R6, #-1
STR R1, R6, #0
ADD R6, R6, #-1
STR R2, R6, #0
ADD R6, R6, #-1
STR R3, R6, #0
ADD R6, R6, #-1
STR R4, R6, #0
ADD R5, R6, #0
LDR R1, R5, #6          ; head pointer (passed by value)
BRnp PRINT_LOOP
LEA R0, EMPTY_TEXT
PUTS
BRnzp PRINT_DONE
PRINT_LOOP
LDR R0, R1, #0          ; node.value
TRAP x41
LD R0, SPACE
OUT
LDR R1, R1, #1          ; node.next
BRnp PRINT_LOOP
LD R0, NEWLINE
OUT
PRINT_DONE
LDR R4, R6, #0
ADD R6, R6, #1
LDR R3, R6, #0
ADD R6, R6, #1
LDR R2, R6, #0
ADD R6, R6, #1
LDR R1, R6, #0
ADD R6, R6, #1
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1
RET

; ADD_NODE(&head, value): prepend new node. Recycle removed nodes.
ADD_NODE
ADD R6, R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R6, R6, #-1
STR R1, R6, #0
ADD R6, R6, #-1
STR R2, R6, #0
ADD R6, R6, #-1
STR R3, R6, #0
ADD R6, R6, #-1
STR R4, R6, #0
ADD R5, R6, #0
LD R1, FREE_HEAD
BRz ADD_FRESH
LDR R2, R1, #1
ST R2, FREE_HEAD
BRnzp ADD_HAVE_NODE
ADD_FRESH
LD R1, HEAP_NEXT
LD R2, HEAP_END_ADDR
NOT R3, R2
ADD R3, R3, #1
ADD R3, R1, R3
BRzp ADD_FULL             ; no two-word node fits
ADD R2, R1, #2
ST R2, HEAP_NEXT
ADD_HAVE_NODE
LDR R2, R5, #7          ; value
STR R2, R1, #0
LDR R3, R5, #6          ; &head
LDR R4, R3, #0          ; old head
STR R4, R1, #1          ; new->next = old head
STR R1, R3, #0          ; *head = new node
BRnzp ADD_DONE
ADD_FULL
LEA R0, FULL_TEXT
PUTS
ADD_DONE
LDR R4, R6, #0
ADD R6, R6, #1
LDR R3, R6, #0
ADD R6, R6, #1
LDR R2, R6, #0
ADD R6, R6, #1
LDR R1, R6, #0
ADD R6, R6, #1
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1
RET

; REMOVE_NODE(&head, value): remove FIRST matching node.
; R1 = pointer to link pointing at current node (&head or &prev.next).
REMOVE_NODE
ADD R6, R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R6, R6, #-1
STR R1, R6, #0
ADD R6, R6, #-1
STR R2, R6, #0
ADD R6, R6, #-1
STR R3, R6, #0
ADD R6, R6, #-1
STR R4, R6, #0
ADD R5, R6, #0
LDR R1, R5, #6          ; &head
REMOVE_LOOP
LDR R2, R1, #0          ; current node
BRz REMOVE_MISSING
LDR R3, R2, #0          ; current.value
LDR R4, R5, #7          ; desired value
NOT R4, R4
ADD R4, R4, #1
ADD R3, R3, R4
BRz REMOVE_FOUND
ADD R1, R2, #1          ; address of current.next
BRnzp REMOVE_LOOP
REMOVE_FOUND
LDR R3, R2, #1          ; next node
STR R3, R1, #0          ; unlink node (also works for head)
LD R3, FREE_HEAD
STR R3, R2, #1
ST R2, FREE_HEAD        ; recycle node for next ADD
BRnzp REMOVE_DONE
REMOVE_MISSING
LEA R0, MISSING_TEXT
PUTS
REMOVE_DONE
LDR R4, R6, #0
ADD R6, R6, #1
LDR R3, R6, #0
ADD R6, R6, #1
LDR R2, R6, #0
ADD R6, R6, #1
LDR R1, R6, #0
ADD R6, R6, #1
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1
RET

HEAP .BLKW #80           ; space for 40 two-word nodes
HEAP_END .FILL #0
.END
