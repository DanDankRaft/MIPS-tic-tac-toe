.include "macros.asm"


#Draws a 2x2 square
#%location is the top-left corner of the square, a REGISTER
#%color is the color of the square, a CONSTANT

.macro drawsquare(%location, %color)
	li $t9, %color

	sw $t9, (%location)
	sw $t9, ROWSIZE(%location)
	addi $t8, %location, 4
	sw $t9, ($t8)
	sw $t9, ROWSIZE($t8)

.end_macro

.macro drawsquareRegister(%location, %color)
	
	sw %color, (%location)
	sw %color, ROWSIZE(%location)
	addi $t8, %location, 4
	sw %color, ($t8)
	sw %color, ROWSIZE($t8)

.end_macro

.macro numtolocation(%x)

	beq %x, 1, conv1
	beq %x, 2, conv2
	beq %x, 3, conv3
	beq %x, 4, conv4
	beq %x, 5, conv5
	beq %x, 6, conv6
	beq %x, 7, conv7
	beq %x, 8, conv8
	beq %x, 9, conv9

	j macroexit

conv1:
	lw %x, pos1
	j macroexit
conv2:
	lw %x, pos2
	j macroexit
conv3:
	lw %x, pos3
	j macroexit
conv4:
	lw %x, pos4
	j macroexit
conv5:
	lw %x, pos5
	j macroexit
conv6:
	lw %x, pos6
	j macroexit
conv7:
	lw %x, pos7
	j macroexit
conv8:
	lw %x, pos8
	j macroexit
conv9:
	lw %x, pos9
	j macroexit
macroexit:

.end_macro

.data

errortextX: 	.asciiz 	"Did not print X because of invalid value: "
errortextCircle: .asciiz 	"Did not print circle because of invalid value: "

#TODO: add memory locations for all slots, from 1 to 9. Also add a macro where u input a number and it gives you a slot
pos1: 		.word 		0x10040104
pos2: 		.word 		0x1004015C
pos3: 		.word 		0x100401B4
pos4: 		.word 		0x10041704
pos5: 		.word 		0x1004175C
pos6: 		.word 		0x100417B4
pos7: 		.word 		0x10042D04
pos8: 		.word 		0x10042D5C
pos9: 		.word 		0x10042DB4

.text


#INPUT
#$a0 = slot where the X is to be drawn
#$a1 = Color
.globl drawX
drawX:
	#if the inputted number is less than 1 or greater than 9, EXIT
	blt $a0, 1, drawXExitError
	bgt $a0, 9, drawXExitError

	#$t0 location of square "coming from" the top left
	move $t0, $a0
	numtolocation($t0)		


	#$t1 location of square "coming from" the top right
	#15 * 4 = 60
	addi $t1, $t0, 64

	#loop: draw the thing!
	#$t3 is the counter
	li $t3, 0

drawXLoop:
	bge $t3, 17, drawXExit

	#draw the friggin squares!
	drawsquareRegister($t0, $a1)
	drawsquareRegister($t1, $a1)

	#update the positions of $t0 and $t1
	addi $t0, $t0, ROWSIZE
	addi $t0, $t0, 4

	addi $t1, $t1, ROWSIZE
	subi $t1, $t1, 4

	addi $t3, $t3, 1
	j drawXLoop

drawXExit:

	jr $ra

drawXExitError:
	move $t0, $a0
	
	la $a0, errortextX
	li $v0, 4
	syscall

	li $a0, '\n'
	li $v0, 1
	syscall

	move $a0, $t0
	li $v0, 11
	syscall

	jr $ra


#INPUT:
#$a0 = input position
#$a1 = Color
.globl drawCircle
drawCircle:
	#if the inputted number is less than 1 or greater than 9, EXIT
	blt $a0, 1, drawCircleExitError
	bgt $a0, 9, drawCircleExitError

	#$t0 location of the first brush
	move $t0, $a0
	numtolocation($t0)

	#$t1 location of the second brush
	addi $t0, $t0, 28
	addi $t1, $t0, 4

	drawsquareRegister($t0, $a1)
	drawsquareRegister($t1, $a1)

	addi $t1, $t1, 8
	subi $t0, $t0, 4

	drawsquareRegister($t0, $a1)
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	subi $t0, $t0, 8
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	addi $t1, $t1, 8
	drawsquareRegister($t1, $a1)

	subi $t0, $t0, 4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, 4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	addi $t0, $t0, -4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	addi $t1, $t1, 4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	addi $t0, $t0, -4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	addi $t1, $t1, 4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, 512
	addi $t0, $t0, -4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, 512
	addi $t1, $t1, 4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, 512
	addi $t0, $t0, 4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, 512
	addi $t1, $t1, -4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	addi $t0, $t0, 4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	addi $t1, $t1, -4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	addi $t0, $t0, 4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	addi $t1, $t1, -4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, 4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, -4
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, ROWSIZE
	addi $t0, $t0, 8
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, ROWSIZE
	addi $t1, $t1, -8
	drawsquareRegister($t1, $a1)

	addi $t0, $t0, 4
	drawsquareRegister($t0, $a1)

	addi $t1, $t1, -4
	drawsquareRegister($t1, $a1)


drawCircleExit:
	jr $ra

drawCircleExitError:
	move $t0, $a0
	
	la $a0, errortextCircle
	li $v0, 4
	syscall

	li $a0, '\n'
	li $v0, 1
	syscall

	move $a0, $t0
	li $v0, 11
	syscall

	jr $ra