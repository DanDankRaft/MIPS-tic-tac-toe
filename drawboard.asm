.include "macros.asm"

.macro drawboardColumn(%location)
	sw $t9, (%location)
	sw $t9, 4(%location)

.end_macro

.macro drawboardRow(%location)
	sw $t9, (%location)
	sw $t9, ROWSIZE(%location)

.end_macro

#Draws the borders of the game board
#INPUTS:
#$a0 = color to be used
.globl drawboard
drawboard:
	move $t9, $a0

	#save to $t0 and $t1 the locations of the columns
	
	
	li $t0, 20
	mul $t0, $t0, 4
	addi $t0, $t0, HEAP
	addi $t0, $t0, ROWSIZE
	
	li $t1, 42
	mul $t1, $t1, 4
	addi $t1, $t1, HEAP
	addi $t1, $t1, ROWSIZE
	
	#$t8 = the counter - from 0 to 64
	li $t8, 1
drawboardColumnLoop:
	bgt $t8, 62, drawboardColumnExit

	drawboardColumn($t0)
	drawboardColumn($t1)
	
	addi $t0, $t0, ROWSIZE
	addi $t1, $t1, ROWSIZE
	
	addi $t8, $t8, 1
	j drawboardColumnLoop
	
drawboardColumnExit:

		
	li $t0, 20
	mul $t0, $t0, ROWSIZE
	addi $t0, $t0, HEAP
	addi $t0, $t0, 4

	li $t1, 42
	mul $t1, $t1, ROWSIZE
	addi $t1, $t1, HEAP
	addi $t1, $t1, 4

	li $t8, 1
drawboardRowLoop:
	bgt $t8, 62, drawboardRowExit

	drawboardRow($t0)
	drawboardRow($t1)
	
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	
	addi $t8, $t8, 1
	j drawboardRowLoop
	
drawboardRowExit:

	jr $ra