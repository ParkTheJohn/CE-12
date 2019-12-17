###################################################################################################################
# Created by:   Park, Jongwoo
#               jpark510
#               03 December 2018
#
# Assignment:   Lab 5: Subroutines
#               CMPE012, Computer Systems and Assembly Language
#               UC Santa Cruz, Fall 2018
#
# Description: 	This program contains the subroutines that checks the entered string and keeps track of the time limit
#               of Lab5Test.asm.
#
# Notes:        This program is intended to be run from MARS IDE.
###################################################################################################################
#
# REGISTER USAGE:
# $v0: syscalls 4, 8, 9, 30
#      lower 32 bit of time prompt was given in milliseconds
#      success or loss value, (1 or 0)
# $a0: address of type prompt to be printed to user
#      address of type prompt printed to user
#      address of first string to compare
#      first char to compare (contained in the least significant byte)
# $a1: time type prompt was given to user
#      address of second string to compare
#      second char to compare (contained in the least significant byte)
# $t0: temporary saved address of the type prompt from $a0
#      time allowed to type
# $t1: temporary saved address type prompt to be printed to user     
#      address of the firstArray
# $t2: temporary saved address of what the user typed
#      address of the array
# $t3: loaded byte from the first address, $a0
# $t4: loaded byte from the second address, $a1     
# $t7: counter to keep track of the total times charsLoop was run to exit
# $t8: counter to keep track of the total times arrayLoop1 was run for size
# $t9: counter to keep track of the total times arrayLoop2 was run for size
# $ra: return address to properly return from subroutines 
# $sp: stack pointer to keep track of which $ra address was entered and when to not be stuck in infinite loop
#

#-----------------------------------------------------------------------------
# give_type_prompt 
# 
# input:  $a0 - address of type prompt to be printed to user 
# 
# output: $v0 - lower 32 bit of time prompt was given in milliseconds
#-----------------------------------------------------------------------------

.text
give_type_prompt:
# set $v0 to be lower 32bit time
# $a0 is still the address of prompt
  move $t0 $a0          # saved the address of type prompt in $t0
  la $a0 typePrompt
  li $v0 4
  syscall               # print typeprompt
  move $a0 $t0          # bring address back from $t0 to $a0 to print
  syscall               # print the first string

# setting $v0 to time
  li $v0 30
  syscall
  move $v0 $a0
  move $a0 $t0

  jr $ra

.data
typePrompt: .asciiz "Type Prompt: "


#-----------------------------------------------------------------------------
# check_user_input_string 
# 
# input:  $a0 - address of type prompt printed to user 
#         $a1 - time type prompt was given to user 
#         $a2 - contains amount of time allowed for response 
# 
# output: $v0 - success or loss value (1 or 0
#-----------------------------------------------------------------------------


.text
# $t0 contains time allowed
check_user_input_string:
  add $t0 $a1 $a2   # $t0 has time allowed
  move $t1 $a0      #$t1 has address of type prompt printed to user
  li $a1 60

  addi $sp $sp -8
  sw $ra 0($sp)
  sw $a1 4($sp)

# allocate memory in heap
  li $v0 9
  lw $a0 4($sp)
  syscall

# prompt user for string
  move $a0 $v0
  li $v0 8
  lw $a1 4($sp)
  syscall
  move $t2 $a0          # set $t2 to address of second string, the entered string

# record time when entered
  li $v0 30
  syscall

  bgt $a0 $t0 fail      # if the time used($a0) is greater than time allowed ($t0) then fail

  move $a0 $t1          # set $a0 to address of the first string
  move $a1 $t2          # set $a1 to address of the second string
  jal compare_strings

  lw $ra 0($sp)
  addi $sp $sp 8
  jr $ra

# set $v0 to 0 and return
fail:
  li $v0 0
  lw $ra 0($sp)
  addi $sp $sp 8
  jr $ra

#-----------------------------------------------------------------------------
# compare_strings 
# 
# input:  $a0 - address of first string to compare 
#         $a1 - address of second string to compare 
# 
# output: $v0 - comparison result (1 == strings the same, 0 == strings not the same)
#-----------------------------------------------------------------------------

.text
compare_strings:
# load address into memory and set counters
  addi $sp $sp -4
  sw $ra 0($sp)

  li $t8 0
  li $t9 0
  la $t1 firstArray
  la $t2 secondArray

# load each byte from the address of the string into the array    
  arrayLoop1:
    lb $t3 ($a0)                           # load from the argument address to $t2
    beq $t3 $zero exitArrayLoop1
    sb $t3 ($t1)                           # store into array

    addi $a0 $a0 1                         # increment byte in argument, first string
    addi $t1 $t1 1                         # increment the firstArray memory
    addi $t8 $t8 1
  
    b arrayLoop1
  
  exitArrayLoop1:
  
# load each byte from the address of the string into the array      
  arrayLoop2:
    lb $t4 ($a1)
    beq $t4 $zero exitArrayLoop2
    sb $t4 ($t2)  

    addi $a1 $a1 1                      # increment byte in argument, second string
    addi $t2 $t2 1                      # increment the secondArray memory
    addi $t9 $t9 1

    b arrayLoop2
  
  exitArrayLoop2:

# reset array address and counter 
  la $t1 firstArray
  la $t2 secondArray
  li $t7 0 
 
# compare each character entered into the array   
  charsLoop:
    lb $a0 ($t1)
    lb $a1 ($t2)
    jal compare_chars
    beq $v0 $zero exitCharsLoop
    addi $t1 $t1 1                      # increment the firstArray memory
    addi $t2 $t2 1                      # increment the secondArray memory
    addi $t7 $t7 1

# check if the first string was all checked
    beq $t7 $t8 checkSecondString

    b charsLoop
  
# check if the second string was all checked, then exit  
  checkSecondString:
    beq $t7 $t9 exitCharsLoop

    b charsLoop
  
  exitCharsLoop:
    lw $ra 0($sp)
    addi $sp $sp 4
    jr $ra
  
.data
firstArray: .space 60
secondArray: .space 60


#-----------------------------------------------------------------------------
# compare_chars 
# 
# input:  $a0 - first char to compare (contained in the least significant byte) 
#         $a1 - second char to compare (contained in the least significant byte) 
# 
# output: $v0 - comparison result (1 == chars the same, 0 == chars not the same) 
#-----------------------------------------------------------------------------

.text
compare_chars:
# start by setting $v0 to 1, branch and set to 0 if not equal
  addi $sp $sp -4
  sw $ra 0($sp)

  li $v0 1
  bne $a0 $a1 notEqual

  return:
    lw $ra 0($sp)
    addi $sp $sp 4
    jr $ra

  notEqual:
    li $v0 0
    b return

