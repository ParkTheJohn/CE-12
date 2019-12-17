###################################################################################################################
# Created by:   Park, Jongwoo
#               jpark510
#               5 November 2018
#
# Assignment:   Lab 3: Looping in MIPS
#               CMPE012, Computer Systems and Assembly Language
#               UC Santa Cruz, Fall 2018
#
# Description: 	This program prompts the user for an integer value, then prints numbers starting at value 0,
#               and if the number is evenly divisible by 5, it instead prints "Flux". If the number is 
#               evenly divisible by 7, it prints "Bunny". If it is evenly divisible by both 5 and 7,
#               it prints "Flux Bunny". If the number is not divisible by neither 5 nor 7, then it prints
#               the number that it was supposed to print.
#
# Notes:        This program is intended to be run from MARS IDE.
###################################################################################################################

.data

prompt:         .asciiz "Please input a positive integer: "
flux:           .asciiz "Flux"
bunny:          .asciiz "Bunny"
fluxBunny:      .asciiz "Flux Bunny"
newLine:        .asciiz "\n"

.text

# Register usage:
# $t0 = user input
# $t1 = loop counter
# $t2 = remainder, mfhi
# $t3 = 5
# $t4 = 7

# Prompts the user for a positive integer
li      $v0, 4
la      $a0, prompt
syscall

# Receives user input of the integer and registers into $t0
li      $v0, 5
syscall
la      $t0, ($v0)

# Set $t3 to 5 and $t4 to 7 for division, and $t1 to 0 for loop counter incrementing
li      $t1, 0
addi    $t3, $zero, 5
addi    $t4, $zero, 7

# for(t1 = 0; t1 <= t0; t1++){
loop:
        bgt     $t1, $t0, exitLoop      # condition to exit loop, if the counter is greater than or equal to user input

        # checks if divisible by 5, branches to flux if true
        div     $t1, $t3                # divides user input by 5
        mfhi    $t2                     # stores remainder to $t2
        beqz    $t2, fluxLoop           # branches if the quotient of user input and 5 is 0

        # checks if divisible by 7, branches to bunny if true
        div     $t1, $t4                # divides user input by 7
        mfhi    $t2                     # stores remainder to $t2
        beqz    $t2, bunnyLoop          # branches if the quotient of user input and 7 is 0

        # prints the current counter because no condition was met for flux or bunny or flux bunny
        li      $v0, 1                  # sets $v0 to 1 to print integers because neither of the conditions to print string was met
        move    $a0, $t1                # sets $a0 to the user input at the current counter
        syscall                         # prints the integer at the current counter

        # new line after printing
        li      $v0, 4
        la      $a0, newLine
        syscall

        # increment counter and return to loop
        addi    $t1, $t1, 1             # increment counter
        b       loop                    # returns to top of the loop, repeats until counter is greater than or equal to user input
#}


fluxLoop:
                li      $v0, 4                  # sets $v0 to 4 to print string

                # checks if divisible by 7, branches to fluxbunny if true
                div     $t1, $t4                # divides user input by 7, stores it in $t2
                mfhi    $t2                     #
                beqz    $t2, fluxBunnyLoop      # branches to fluxBunnyLoop if both divisible by 5 and 7

                # print flux
                la      $a0, flux
                syscall

                # new line after printing
                li      $v0, 4
                la      $a0, newLine
                syscall

                # increment counter and return to loop
                addi    $t1, $t1, 1
                b       loop

bunnyLoop:
                li      $v0, 4                  # sets $v0 to 4 to print string

                # print bunny
                la      $a0, bunny
                syscall

                # new line after printing
                li      $v0, 4
                la      $a0, newLine
                syscall

                # increment counter and return to loop
                addi    $t1, $t1, 1
                b       loop

fluxBunnyLoop:  # print flux bunny
                la      $a0, fluxBunny
                syscall

                # new line after printing
                li      $v0, 4
                la      $a0, newLine
                syscall

                # increment counter and return to loop
                addi    $t1, $t1, 1
                b       loop

exitLoop:       # exits the program after exiting loop
                li      $v0, 10                 # sets $v0 to 10 to exit
                syscall                         # exit






