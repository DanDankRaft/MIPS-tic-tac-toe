.include "macros.asm"

.data

fireannouncement:   .asciiz     "FIRE! ONE SQUARE IS RANDOMLY DELETED\n"
removeannouncement: .asciiz     "REMOVE! THE USER CAN REMOVE ONE CIRCLE OF THEIR CHOICE\n"

.text

#FUNCTION that finds a random, non-empty square
#INPUTS:
#$a0 = 
# 1 for X
# 2 for O
# 3 for EITHER
#OUTPUT:
#$v0 = the square found
#$v1 = which shape the found square has.
# 1 for X
# 2 for O
findsquare:

    #move the requested input to the thing
    move $t0, $a0

findsquareloop:

    #generate a random value
    li $v0, 30
	syscall
	
	move $a1, $a0
	li $v0, 40
	syscall
	
	#get the value and mod it by 9
	li $v0, 41
	syscall
	move $t1, $a0
	abs $t1, $t1
	rem $t1, $t1, 9
	addi $t1, $t1, 1

    #get the value in the square (and also copy the square number)
    move $t2, $t1
    getSquareMacro($t1)
    beq $t1, 0, findsquareloop

    #if the value in the square is equal to the value we need (OR if we have a 3...) exit the loop!
    beq $t1, $t0, findsquareexit
    beq $t0, 3, findsquareexit

    j findsquareloop

findsquareexit:

    move $v0, $t2
    move $v1, $t1

    jr $ra

#This event will delete one random X or O with a fire animation
.globl fireevent
fireevent:

    li $v0, 4
    la $a0, fireannouncement
    syscall

    #find a random square that is not empty
    li $a0, 3
    jal findsquare

    #Once it is found, DELETE IT WITH FIRE AND FURY

    #delete it from the database
    move $s6, $v0
    move $s7, $v1

    move $a0, $v0
    move $a1, $zero
    jal setSquare

    #then delete it using a fancy animation

    #if square
    beq $s7, 1, fireanimX
    #if circle
    beq $s7, 2, fireanimO

#animation where it draws an orange X, waits half a second, and then removes it.
fireanimX:

    move $a0, $s6
    li $a1, ORANGE
    jal drawX

    li $v0, 32
    li $a0, 500
    syscall

    move $a0, $s6
    move $a1, $zero
    jal drawX

    j inputloopbegin

#animation where it draws an orange O, waits half a second, and then remvoes it.
fireanimO:

    move $a0, $s6
    li $a1, ORANGE
    jal drawCircle

    li $v0, 32
    li $a0, 500
    syscall

    move $a0, $s6
    move $a1, $zero
    jal drawCircle

    j inputloopbegin



#REMOVE EVENT: Gives the player the ability to remove one circle from the board
.globl removeevent
removeevent:
    #announce to the console
    li $v0, 4
    la $a0, removeannouncement
    syscall

    #change the border
    li $a0, PURPLE
    jal drawboard
    
    #use an input loop to let the user pick a square - copy code from the main program?
inputloopRemove:
	

	#$s7 stores if there is input. If there is no input, repeat the inputloop
	lw $s7, READYBIT
	beqz $s7, inputloopRemove
	
	#lw stores the actual input...
	lw $s6, VALUEBIT
	#if the value is less than '1' or greater than '9', repeat the loop because it is INVALID!
	blt $s6, '1', inputloopRemoveerror
	bgt $s6, '9', inputloopRemoveerror

	#if the value is in range, convert it to a number
	subi $s6, $s6, '0'

	#CHECK IF THERE IS ALREADY A VALUE IN THE GIVEN SQUARE. If so, give the user a warning and let it try again
	move $a0, $s6
	jal getSquare
	
	#Throws an error if the user tries putting an X where there is already an X or Empty
	bne $v0, 2, inputfullRemoveerror

    #Remove the circle in the chosen square
    move $a0, $s6
    li $a1, PURPLE
    jal drawCircle

    li $v0, 32
    li $a0, 500
    syscall

    move $a0, $s6
    li $a1, 0
    jal drawCircle

    #delete it from the database too
    move $a0, $s6
    li $a1, 0
    jal setSquare

    #change the border to white!
    li $a0, WHITE
    jal drawboard

    j inputloopbegin



inputloopRemoveerror:
	#the error message printed if the user tried to pick an invalid value (IE not 0-9)
	la $a0, inputerrormessage
	li $v0, 4
	syscall

	#then, return to the loop...
	j inputloopRemove
	
inputfullRemoveerror:
	

	#in the case of 1, flash that in red
	beq $v0, 1, fullerrorX
	#in the case of 2, flash that as a red X
	beq $v0, 0, fullerrorEmpty
	
fullerrorX:
	#draw the initial red
	move $a0, $s6
	li $a1, RED
	jal drawX
	
	#sleep for a little bit
	li $v0, 32
	li $a0, 250
	syscall
	
	#draw the white again
	move $a0, $s6
	li $a1, WHITE
	jal drawX
	
	j inputloopRemove
	
fullerrorEmpty:

	#draw the initial red
	move $a0, $s6
	li $a1, RED
	jal drawX
	
	#sleep for a few seconds
	li $v0, 32
	li $a0, 250
	syscall
	
	#draw the black again
	move $a0, $s6
	li $a1, 0
	jal drawX
	
	j inputloopRemove
