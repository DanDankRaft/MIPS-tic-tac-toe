.include "macros.asm"

.macro checkXVictory(%val1, %val2, %val3)
    #get the values for each square
    li $t1, %val1
    getSquareMacro($t1)
    li $t2, %val2
    getSquareMacro($t2)
    li $t3, %val3
    getSquareMacro($t3)

    #ANDing them all together. If there is a 1 in the LSB after this, it is a victory!
    and $t0, $t1, $t2
    and $t0, $t0, $t3

    #testing if the lsb is indeed 1.
    rem $t0, $t0, 2
    li $a1, %val1
    li $a2, %val2
    li $a3, %val3
    beq $t0, 1, exitfuncxvictory
.end_macro

.macro checkOVictory(%val1, %val2, %val3)
    #get the values for each square
    li $t1, %val1
    getSquareMacro($t1)
    li $t2, %val2
    getSquareMacro($t2)
    li $t3, %val3
    getSquareMacro($t3)

    #ANDing them all together. If there is a 1 in the second bit, it's a victory!
    and $t0, $t1, $t2
    and $t0, $t0, $t3

    #this will move the 1st to the 0th bit, so we can check if it equals 1
    srl $t0, $t0, 1
    li $a1, %val1
    li $a2, %val2
    li $a3, %val3
    beq $t0, 1, exitfuncovictory
.end_macro

.data

xwon:       .asciiz     "X won!"
owon:       .asciiz     "O won!"
tiewon:        .asciiz     "It's a tie!"


.text
#checks if any player has won.
#First checks if X won
#Then checks if O won
#Finally checks if the board is full and there is a tie.
#If both players win on the same round because of an overlap it will count as a victory for X
#INPUTS:
#none
#OUTPUTS:
#$v0:
# 0 if nobody won
# 1 if X won
# 2 if O won
# 3 if a tie
#$a registers
#If there is a victory, the a registers will contain the locations of all the winners! 
.globl checkvictory
checkvictory:

    #Check if X won, using all possible combinations
    #1 2 3 - top horizontal
    checkXVictory(1, 2, 3)
    #1 4 7 - left vertical
    checkXVictory(1, 4, 7)
    #1 5 9 - top-left to bottom-right diagonal
    checkXVictory(1, 5, 9)
    #2 5 8 - middle vertical
    checkXVictory(2, 5, 8)
    #3 6 9 - right vertical
    checkXVictory(3, 6, 9)
    #3 5 7 - top-right to bottom-left diagonal
    checkXVictory(3, 5, 7)
    #4 5 6 - middle horizontal
    checkXVictory(4, 5, 6)
    #7 8 9 - middle horizontal
    checkXVictory(7, 8, 9)

    #step 2: check if O won
    #1 2 3 - top horizontal
    checkOVictory(1, 2, 3)
    #1 4 7 - left vertical
    checkOVictory(1, 4, 7)
    #1 5 9 - top-left to bottom-right diagonal
    checkOVictory(1, 5, 9)
    #2 5 8 - middle vertical
    checkOVictory(2, 5, 8)
    #3 6 9 - right vertical
    checkOVictory(3, 6, 9)
    #3 5 7 - top-right to bottom-left diagonal
    checkOVictory(3, 5, 7)
    #4 5 6 - middle horizontal
    checkOVictory(4, 5, 6)
    #7 8 9 - middle horizontal
    checkOVictory(7, 8, 9)

    #finally, check for a tie - if all slots are full, we've got a tie!
    #iterate over squares 1 through 9 and check if any of them are empty
    li $t0, 1
checktieloop:

    move $t1, $t0
    getSquareMacro($t1)
    beq $t1, 0, exitfunccontinue

    addi $t0, $t0, 1
    bgt $t0, 9, exitfunctie

    j checktieloop

exitfunctie:
    li $v0, 3
    jr $ra

exitfunccontinue:

    jr $ra

exitfuncxvictory:
    li $v0, 1
    jr $ra

exitfuncovictory:
    li $v0, 2
    jr $ra

.globl xvictory
xvictory:

    #print victory message
    li $v0, 4
    la $a0, xwon
    syscall

    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    move $a0, $s1
    li $a1, GREEN
    jal drawX

    move $a0, $s2
    li $a1, GREEN
    jal drawX

    move $a0, $s3
    li $a1, GREEN
    jal drawX 

    #change the border to green
    li $a0, GREEN
    jal drawboard

    j exitprog

.globl ovictory
ovictory:

    #print victory message
    li $v0, 4
    la $a0, owon
    syscall

    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    move $a0, $s1
    li $a1, RED
    jal drawCircle

    move $a0, $s2
    li $a1, RED
    jal drawCircle

    move $a0, $s3
    li $a1, RED
    jal drawCircle

    #change the border to red
    li $a0, RED
    jal drawboard

    j exitprog

.globl tie
tie:

    #print tie message:
    li $v0, 4
    la $a0, tiewon
    syscall

    #change the border to yellow
    li $a0, YELLOW
    syscall

    #for each square, check what's in there and turn it red
    li $s0, 1

    #turn every x yellow
tiexloop:
    
    bgt $s0, 9, tiexloopexit

    move $s1, $s0
    getSquareMacro($s1)


    rem $s1, $s1, 2
    beq $s1, 1, paintxyellow

tiexloopending:
    addi $s0, $s0, 1
    j tiexloop

tiexloopexit:

    li $s0, 1
tieoloop:
    bgt $s0, 9, exitprog

    move $s1, $s0
    getSquareMacro($s1)


    bge $s1, 2, paintoyellow

tieoloopending:
    addi $s0, $s0, 1
    j tieoloop

exitprog:
    li $v0, 10
    syscall


paintxyellow:
    move $a0, $s0
    li $a1, YELLOW
    jal drawX
    j tiexloopending

paintoyellow:
    move $a0, $s0
    li $a1, YELLOW
    jal drawCircle
    j tieoloopending