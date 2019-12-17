#TypeRacerTest



.text


#Create an array of addresses for the strings to be typed
#Used in second loop to send these strings to the game subroutines
la	$t0, wordSet
la	$t1, stringArray
li	$t3, 0
lb	$t4, numOfLines
loadPrompts:
	#load specified number of prompts
	lb	$t2, ($t0)
	beqz	$t2, exitLoadPrompts
	beq	$t3, $t4, exitLoadPrompts
	addi	$t3, $t3, 1
	sw	$t0, ($t1)
	addi	$t1, $t1, 4
	
	#Find start of next prompt in list
	findNextPrompt:
		lb	$t2, ($t0)
		addi	$t0, $t0, 1
		beqz	$t2, exitFindNextPrompt
	b	findNextPrompt
	exitFindNextPrompt:	nop
	
b	loadPrompts

exitLoadPrompts:	nop


#Run games subroutines
#Uses S0 so users must maintain s register values
la	$s0, stringArray
loop:

	#load string to be typed
	lw	$a0, ($s0)
	#game won when there are no more strings to be loaded
	beq	$a0, 1, gameWon
	#call first subroutine
	jal	give_type_prompt
	
	move	$a1, $v0
	#Amount of time allowed to type line in milliseconds
	li	$a2, 10000
	lw	$a0, ($s0)
	#call second subroutine
	jal	check_user_input_string
	beqz	$v0, gameOver
	addi	$s0, $s0, 4
	
b	loop


#Display Game Over Message
gameOver:	nop
li	$v0, 4
la	$a0, gameOverMessage
syscall
b	exitLoop

#Display Game Won Message
gameWon:	nop
li	$v0, 4
la	$a0, gameWonMessage
syscall

exitLoop:	nop


li	$v0, 10
syscall




.data
#Populate string array with arbitrary values
#Max Num of lines in stringArray
stringArray:	.word		1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1

gameWonMessage:	.asciiz		"\nCongratulations! You've Won!!!\n"
gameOverMessage:.asciiz		"\nSorry, Game Over...\n"

numOfLines:	.byte		10
wordSet:	.asciiz		"Hello, it's me\n"
wordSet_1:	.asciiz		"I was wondering if\n"
wordSet_2:	.asciiz		"after all these years\n"
wordSet_3:	.asciiz		"you'd like to meet\n"
wordSet_4:	.asciiz		"To go over everything\n"
wordSet_5:	.asciiz		"They say time's supposed to heal ya\n"
wordSet_6:	.asciiz		"But I ain't done much healing\n"
wordSet_7:	.asciiz		"Hello, can you hear me\n"
wordSet_8:	.asciiz		"I'm in California dreaming about who we used to be\n"
wordSet_9:	.asciiz		"When we were younger and free\n"


.include "Lab5.asm"
