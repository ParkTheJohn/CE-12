###################################################################################################################
# Created by:   Park, Jongwoo
#               jpark510
#               16 November 2018
#
# Assignment:   Lab 4: ASCII Decimal to 2SC
#               CMPE012, Computer Systems and Assembly Language
#               UC Santa Cruz, Fall 2018
#
# Description: 	This program prompts the user for two signed integer values, then prints the inputted numbers,
#               the sum of the two numbers in decimal, and the sum of the two numbers in 32bit 2SC. It also prints
#               the sum in Morse code.
#
# Notes:        This program is intended to be run from MARS IDE.
###################################################################################################################
#
# Pseudo Code:
# Receive user input from the program argument
# load word into array 
# Print the two user inputs
# Unload words from array for each byte
# Convert the hex of the program arguments into decimal, subtract 48, using loop
# Store the converted decimal value in register $s1 and $s2
# add the two together and store it in $s0
# store each converted byte into array
# Print the sum as a decimal byte by byte from the array
# loop the sum 32 times with AND 10000000000000000000000000000000 to get the 2SC binary value
# print 1 for any hex value 
# print each result of AND for each loop 



# REGISTER USAGE:
# $v0: used for syscalls
# $a0: used for syscalls
# $a1: stores the program argument when the program is run
# $t0: set as the address for s1Array, s2Array and asciiArray
#      counter for storing argument into $s1 and $s2
#      set as the mask for looping to print 32bit 2SC binary 
# $t1: counter for looping in s1Array and s2Array
#      set as the address for s1Array and s2Array in s1Loop and s2Loop
#      set as constant 100 and 10 to divide values into 100s and 10s places
#      set as the address for asciiArray when printing decimal sum
#      counter for looping in printing 32bit 2SC binary
# $t2: set as the loaded byte from the argument for both loops for both arguments
#      set as the added counter for looping in s1Loop and s2Loop
# $t3: the new added value of the incremented index and the address of the array to load byte from the array in s1Loop and s2Loop
# $t4: stores the value from the array in s1Loop and s2Loop
#      placeholder for the sum in $s0
#      remainder for 10s place division
# $t6: negative counter increment in s1Loop and s2Loop
#      quotient for 100s place division
# $t7: counter used to branch to multiply by -1 or not in s1Loop and s2Looop
#      quotient for 10s place division
# $t8: remainder for 1s place divison
# $t9: counter to branch to add negative sign or not
# $s0: sum of the two arguments in 32bit 2SC
# $s1: first argument stored as 32bit 2SC
# $s2L second argument stored as 32bit 2SC


.data
#sentences
entered: .asciiz "You entered the decimal numbers: \n"
space: .asciiz " "
newLine: .asciiz "\n"
decimalSum: .asciiz "The sum in decimal is: \n"
negativeSign: .asciiz "-"
binarySum: .asciiz "The sum in two's complement binary is: \n"

# Arrays
s1Array: .space 4
s2Array: .space 4
asciiArray: .space 4


.text
li $v0 4
la $a0, entered
syscall

# set up s1Array and loop counter
lw $a0, 0($a1)
syscall
li $t1 0                                   #counter
la $t0, s1Array                            # set array address to $t0

# $t0 is first element of array
# $t1 is the loop counter
# $t2 is where the loaded byte from the argument is saved
# $a0 is the where the argument is stored
#loop for registering first argument into an array
loop1:
  lb $t2, ($a0)                           # load from the argument address to $t2
  bne $t2, 0x30, notZero
  sb $t2 ($t0)                            # store into array
  b increment
  
  notZero:
    beq $t2, $zero, endLoop1              # branch to end loop if the loaded byte from address is zero
    beq $t2, 0x2d, skipNegative           # skip the negative if the loaded byte is a negative sign
    addi $t2, $t2, -48                    # subtract 48 to convert to decimal 
  
  skipNegative:
    sb $t2 ($t0)                          # store into array
  
  increment:
    addi $t1, $t1, 1                      # increment counter
    addi $a0, $a0, 1                      # increment byte in argument
    addi $t0, $t0, 1                      # increment the memory
  
    beq $t1, 3, endLoop1                  # branch to end if looped 3 times
  
    b loop1

endLoop1:

la $a0, space
syscall

# set up s2Array and loop counter  
lw $a0, 4($a1)
syscall
li $t1 0                                  #counter
la $t0, s2Array

# $t0 is first element of array
# $t1 is the loop counter
# $t2 is where the loaded byte from the argument is saved
# $a0 is the where the argument is stored      
loop2:
  lb $t2, ($a0)                           # load from the argument address to $t2
  bne $t2, 0x30, notZero2
  sb $t2 ($t0)                            # store into array
  b increment2
  
  notZero2:
    beq $t2, $zero, endLoop2              # branch to end loop if the loaded byte from address is zero
    beq $t2, 0x2d, skipNegative2          # skip the negative if the loaded byte is a negative sign
    addi $t2, $t2, -48                    # subtract 48 to convert to decimal 
  
  skipNegative2:
    sb $t2 ($t0)
    beq $t2, $zero, endLoop2
  
  increment2:
    addi $t1, $t1, 1                      # increment counter
    addi $a0, $a0, 1                      # increment byte in argument
    addi $t0, $t0, 1                      # increment the memory
  
    beq $t1, 3, endLoop2
  
    b loop2

endLoop2:

# print output
la $a0, newLine
syscall
la $a0, newLine
syscall
la $a0, decimalSum
syscall


li $t0 0 # counter 
li $t6 0 # negative counter
li $t7 0 # negative branch counter to mult by -1

# $t0 is the loop counter which also wil be used as the index for the array
# $t1 is the address for the array
# $t2 is the index of the value we are looking for
# $t3 is index + address, which gives us a new address for the value at different index
# $t4 is where the value from the array will be loaded to
# $t6 keeps track of whether to count in the negative value of not
# $t7 keeps track of whether to multiply by -1 at the end or not
# first argument into s1
s1Loop:
  la $t1, s1Array                     # set t1 as array1 address
  add $t2, $t0, $zero                 # set t2 as index which is counter
  add $t3, $t2, $t1                   # add index and counter together for updated array address
  lb $t4 ($t3)                        # load value into t4

  bne $t4, 48, skipIfNotZero
  addi $t4, $t4, -48
  b convertZero

  skipIfNotZero:
    beq $t4, $zero, singleDigit       # branch to single digit if the next loaded value is zero
    beq $t4, 0x2d, negativeBinaryLoop # branch to negative if the first value was a negative sign
    beq $t6, 1, mult10                # branch to mult10 to multiply by 10 if the first valu was negative and second was a 10s place
    beq $t0, 0, mult10                # branch to mult10 if the first value WASNT negative and first value was 10s place 

  convertZero:
    add $s1, $s1, $t4                 # add the updated index value at array to s1
    beq $t7, 1, multNegative          # branch to multNegative to multiply by -1 if the first value was negative
    j cont

  mult10:
    mulo $t4, $t4, 10                 # multiply by 10 on 10s place
    add $s1, $t4, $zero               # add the value to $s1
    addi $t0, $t0, 1                  # increment $t0
    li $t6 0                          # set $t6 to 0 to not branch again
    b s1Loop

  negativeBinaryLoop:
    addi $t0, $t0, 1                  # increment $t0
    addi $t6, $t6, 1                  # increment $t6, for next value will be 10s place
    addi $t7, $t7, 1                  # increment $t7, to let the program know whether to multiply by negative 1 or not
    b s1Loop

  multNegative:
    mulo $s1, $s1, -1                 # multiply by negative 1
    j cont

  singleDigit:
    div $s1, $s1, 10                  # divide by 10, if the first digit is the only digit
    beq $t7, 1, multNegative          # branch if the first digit was negative

cont:

li $t0 0                              # counter 
li $t6 0                              # negative counter
li $t7 0                              # negative branch counter to mult by -1

# $t0 is the loop counter which also wil be used as the index for the array
# $t1 is the address for the array
# $t2 is the index of the value we are looking for
# $t3 is index + address, which gives us a new address for the value at different index
# $t4 is where the value from the array will be loaded to
# $t6 keeps track of whether to count in the negative value of not
# $t7 keeps track of whether to multiply by -1 at the end or not
# second argument into $s2
s2Loop:
  la $t1, s2Array                      # set t1 as array2 address
  add $t2, $t0, $zero                  # set t2 as index which is counter
  add $t3, $t2, $t1                    # add index and counter together for updated array address
  lb $t4 ($t3)                         # load value into t4

  bne $t4, 48, skipIfNotZero2
  addi $t4, $t4, -48
  b convertZero2

  skipIfNotZero2:
    beq $t4, $zero, singleDigit2       # branch to single digit if the next loaded value is zero
    beq $t4, 0x2d, negativeBinaryLoop2 # branch to negative if the first value was a negative sign
    beq $t6, 1, mult102                # branch to mult10 to multiply by 10 if the first valu was negative and second was a 10s place
    beq $t0, 0, mult102                # branch to mult10 if the first value WASNT negative and first value was 10s place 
  
  convertZero2:
    add $s2, $s2, $t4                  # add the updated index value at array to s1
    beq $t7, 1, multNegative2          # branch to multNegative to multiply by -1 if the first value was negative
    j cont2

  mult102:
    mulo $t4, $t4, 10                  # multiply by 10 on 10s place
    add $s2, $t4, $zero                # add the value to $s1
    addi $t0, $t0, 1                   # increment $t0
    li $t6 0                           # set $t6 to 0 to not branch again
    b s2Loop

  negativeBinaryLoop2:
    addi $t0, $t0, 1                   # increment $t0
    addi $t6, $t6, 1                   # increment $t6, for next value will be 10s place
    addi $t7, $t7, 1                   # increment $t7, to let the program know whether to multiply by negative 1 or not
    b s2Loop

  multNegative2:
    mulo $s2, $s2, -1                  # multiply by negative 1
    j cont2

  singleDigit2:
    div $s2, $s2, 10                   # divide by 10, if the first digit is the only digit
    beq $t7, 1, multNegative2          # branch if the first digit was negative

cont2:

# add arguments into $s0
add $s0, $s1, $s2
add $t4, $s0, $zero
la $t0, asciiArray                     # set array address to $t0
li $t9, 0                              # print negative
bgez $s0, noRemoval 

# removes negative
addi $t9, $zero, 1
mulo $t4, $t4, -1


# insert 100s 10s and 1s values into asciiArray to print each decimal value 
noRemoval:
  bge $t4, 100, div100
  bge $t4, 10, div10
  j noConversion

div100:
  li $t1, 100
  div $t4, $t1
  mflo $t6                             # quotient, 100s
  mfhi $t4                             # remainder, 10s
  b div10

div10:
  li $t1 10
  div $t4, $t1
  mflo $t7                             # quotient, 10s
  mfhi $t8                             # remainder, 1s
  beq $t6, $zero, convert10s
  j convert100s

convert100s:
  addi $t6, $t6, 48
  sb $t6, ($t0)
  addi $t0, $t0, 1                     # increment the memory
  b convert10s

convert10s:
  addi $t7, $t7, 48
  sb $t7, ($t0)
  addi $t0, $t0, 1                     # increment the memory
  b convert1s

convert1s:
  addi $t8, $t8, 48
  sb $t8, ($t0)
  b endConversion

noConversion:
  addi $t8, $t4, 48
  sb $t8, ($t0)

endConversion:

# print decimal
beq $t9, 1, addNegativeSign           # branch if print negative sign

# print each byte in array
printDecimalSum:
  li $v0, 11
  la $t1, asciiArray                  # set t1 as array1 address
  lb $a0, ($t1)
  syscall
  lb $a0, 1($t1)
  syscall
  lb $a0, 2($t1)
  syscall
  b binary

addNegativeSign:
  la $a0, negativeSign
  li $v0, 4
  syscall
  b printDecimalSum

# print output
binary:
  li $v0, 4
  la $a0, newLine
  syscall
  la $a0, newLine
  syscall
  la $a0, binarySum
  syscall

  li $v0, 11
  li $t0 0x80000000               # set mask
  li $t1 0                        # set counter for loop

# loops through 32 times and prints each binary digit 
binaryOutputLoop:
  and $a0, $t0, $s0
  beq $a0, $zero, false
  li $a0, 0x31
  syscall
  b binaryOutputIncrement

  false:
    addi $a0, $a0, 48
    syscall

  binaryOutputIncrement:
    add $t1, $t1, 1
    srl $t0, $t0, 1
    beq $t1, 32, exit
    b binaryOutputLoop

exit:
  li $v0, 10
  syscall



