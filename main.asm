.include "macros.asm"

.data

xplaced: 				.asciiz 	"X placed on position "
oplaced: 				.asciiz 	"O placed on position "
xturn: 					.asciiz 	"It's X's turn\n"
oturn: 					.asciiz 	"It's O's turn\n"
.globl inputerrormessage
inputerrormessage: 		.asciiz 	"invalid input! try again\n"

.text


#function that resets the screen to all black on startup
resetscreen:
	#$t0 stores the value of the last pixel on the screen
	li $t0, HEAP
	addi $t0, $t0, 16384
	
	#$t1 stores the current pixel
	li $t1, HEAP
	
	#make everything black
resetscreenLoop:
	bgt $t1, $t0, resetscreenExit
	sd $zero, ($t1)
	
	addi $t1, $t1, 8
	j resetscreenLoop
	
resetscreenExit:
	jr $ra


.globl main
main:

	#reset the screen to all black. Allows us to avoid pressing the Reset button every time
	jal resetscreen

	#draw the outline for the board
	li $a0, WHITE
	jal drawboard
	
	#Lets the user draw an X
.globl inputloopbegin
inputloopbegin:
	#Print console prompt, but only on the first run of the loop
	li $v0, 4
	la $a0, xturn
	syscall
inputloop:
	

	#$s1 stores if there is input. If there is no input, repeat the inputloop
	lw $s1, READYBIT
	beqz $s1, inputloop
	
	#lw stores the actual input...
	lw $s0, VALUEBIT
	#if the value is less than '1' or greater than '9', repeat the loop because it is INVALID!
	blt $s0, '1', inputlooperror
	bgt $s0, '9', inputlooperror

	#if the value is in range, convert it to a number
	subi $s0, $s0, '0'

	#CHECK IF THERE IS ALREADY A VALUE IN THE GIVEN SQUARE. If so, give the user a warning and let it try again
	move $a0, $s0
	jal getSquare
	
	#Throws an error if the user tries putting an X where there is already an X or O
	bne $v0, 0, inputfullerror

drawXmain:
	#Send a console message saying that the player placed a value
	li $v0, 4
	la $a0, xplaced
	syscall

	li $v0, 1
	move $a0, $s0
	syscall

	li $v0, 11
	li $a0, '\n'
	syscall

	#draw the X initially as a yellow indicator
	move $a0, $s0
	li $a1, YELLOW
	jal drawX
	
	#sleep for the animation
	li $v0, 32
	li $a0, 250
	syscall
	
	#draw the permanent white X
	move $a0, $s0
	li $a1, WHITE
	jal drawX

	#store the value in the boardslots
	move $a0, $s0
	li $a1, 1
	jal setSquare

	#check if anyone won
	li $v0, 0
	jal checkvictory

	#if X won, do the thing
	beq $v0, 1, xvictory
	
	#if tie, do a tie
	beq $v0, 3, tie


	#announce to the console that O is going next
	li $v0, 4
	la $a0, oturn
	syscall

	#sleep a break that makes the game feel smoother
	#I initially found that without this break the game somehow felt "too" fast
	li $v0, 32
	li $a0, 500
	syscall

computerdraw:
	#use $s0 to store a random value for the computer to insert into
	
	#get system time and load it as the seed
	li $v0, 30
	syscall
	
	move $a1, $a0
	li $v0, 40
	syscall
	
	#get the value and mod it by 9
	li $v0, 41
	syscall
	move $s0, $a0
	rem $s0, $s0, 9

	#sometimes the value is negative which breaks things - absolute value takes are of that
	abs $s0, $s0
	
	addi $s0, $s0, 1
	
	#Checks if the computer picked a square that already had something in it. If so, it tries again
	move $a0, $s0
	jal getSquare
	bnez $v0, computerdraw
	
	#console announce that the computer picked a slot
	li $v0, 4
	la $a0, oplaced
	syscall

	li $v0, 1
	move $a0, $s0
	syscall

	li $v0, 11
	li $a0, '\n'
	syscall

	#draw a circle initially as a yellow indicator
	move $a0, $s0
	li $a1, YELLOW
	jal drawCircle
	
	#sleep for the animation
	li $v0, 32
	li $a0, 250
	syscall
	
	#draw the permanent white circle
	move $a0, $s0
	li $a1, WHITE
	jal drawCircle

	#store the value in the boardslots
	move $a0, $s0
	li $a1, 2
	jal setSquare

	#check for victories again - O could've won this time
	jal checkvictory
	beq $v0, 2, ovictory
	beq $v0, 3, tie

eventstime:

	#generate a random number between 1 and 100 to figure out which event will happen
	#get system time and load it as the seed
	li $v0, 30
	syscall
	
	move $a1, $a0
	li $v0, 40
	syscall
	
	#get the value and mod it by 100
	li $v0, 41
	syscall
	move $s0, $a0
	abs $s0, $s0
	rem $s0, $s0, 100
	addi $s0, $s0, 1

	#if the value is between 1 and 30, initiate a FIRE event
	ble $s0, 30, fireevent

	#if the value is between 31 and 50, initiate a REMOVE event
	#otherwise, do nothing
	subi $s0, $s0, 30
	ble $s0, 20, removeevent

	#return to the user's turn!
	j inputloopbegin

# ----------- END OF THE MAIN LOOP -----------




inputlooperror:
	#the error message printed if the user tried to pick an invalid value (IE not 0-9)
	la $a0, inputerrormessage
	li $v0, 4
	syscall

	#then, return to the loop...
	j inputloop
	
inputfullerror:
	

	#in the case of 1, flash that in red
	beq $v0, 1, fullerrorX
	#in the case of 2, flash that in red
	beq $v0, 2, fullerrorO
	
fullerrorX:
	#draw the initial red
	move $a0, $s0
	li $a1, RED
	jal drawX
	
	#sleep for a little bit
	li $v0, 32
	li $a0, 250
	syscall
	
	#draw the white again
	move $a0, $s0
	li $a1, WHITE
	jal drawX
	
	j inputloop
	
fullerrorO:

	#draw the initial red
	move $a0, $s0
	li $a1, RED
	jal drawCircle
	
	#sleep for a few seconds
	li $v0, 32
	li $a0, 250
	syscall
	
	#draw the white again
	move $a0, $s0
	li $a1, WHITE
	jal drawCircle
	
	j inputloop
