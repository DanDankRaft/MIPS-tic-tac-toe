.include "macros.asm"

.data

.globl square1
square1: 	.word 		0
.globl square2
square2: 	.word 		0
.globl square3
square3: 	.word 		0
.globl square4
square4: 	.word 		0
.globl square5
square5: 	.word 		0
.globl square6
square6: 	.word 		0
.globl square7
square7: 	.word 		0
.globl square8
square8: 	.word 		0
.globl square9
square9: 	.word 		0

.text

#Inserts the given value (X, O or BOTH) to the given square
#INPUTS:
#$a0 = slot as a number
#$a1 = value to be inserted
.globl setSquare
setSquare:

    move $t0, $a0
    numToSlot($t0)
    sw $a1, ($t0)

    jr $ra


#Gets the value of the given square
#INPUTS:
#$a0 = slot as a number
#OUTPUTS:
#$v0 = the value from the square
.globl getSquare
getSquare:

    move $t0, $a0
    numToSlot($t0)
    lw $v0, ($t0)

    jr $ra
