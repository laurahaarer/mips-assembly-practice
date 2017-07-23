.data
intro: .asciiz "*** TIC-TAC-TOE ***\n"
positionInstructions: .asciiz "Make a move by choosing a number representing a new position\n"
numberBoard: .asciiz " 1 | 2 | 3 \n---+---+---\n 4 | 5 | 6 \n---+---+---\n 7 | 8 | 9 \n"

rowDivider: .asciiz "---+---+---\n"
columnDivider: .asciiz " | "
space: .byte ' '
newline: .asciiz "\n"

moves: .word 0:9 # hold a 9-character array of bytes representing players' positions

playerXPrompt: .asciiz "Player X move: "
playerOPrompt: .asciiz "Player O move: "
xMove: .byte 'X'
oMove: .byte 'O'

tieMessage: .asciiz "It's a tie!"
playerXWonMessage: .asciiz "Player X won!"
playerOWonMessage: .asciiz "Player O won!"

.text	
main:
	# Print out initial message
	la $a0, intro  			# load the intro into the argument register so it can be printed
	li $v0, 4			# system call for print_str
	syscall
	
	# Print position intructions and board representation
	la $a0, positionInstructions
	li $v0, 4
	syscall
	la $a0, numberBoard
	li $v0, 4
	syscall
	
	la $s0, moves       		# load the address of the beginning of the moves array
	li $s1, 9			# track the current turn
	
	jal initEmptyMovesArray
	j playGame
	
initEmptyMovesArray:
	# Fill the moves array with spaces
	li $t0, 0
	lb $t1, space
	
	initArrayLoop:
	bge $t0, 9, endArrayLoop	# end the loop if the counter is >= 9
	add $t2, $t0, $s0		# get the address of the current index in the array
	sb $t1, ($t2)			# store a space at the current index
	
	addi $t0, $t0, 1
	j initArrayLoop
	
	endArrayLoop:
	jr $ra
	
	
playGame:
	ble $s1, $zero, tieGame

	andi $t0, $s1, 1		# determine if current turn is even or odd
	beq $t0, 1, playerXMove		# if the value is odd, it's player x's turn
	j playerOMove			# otherwise, it's player o's turn
	
tieGame:
	la $a0, tieMessage
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	
	
playerXMove:
	# Print player prompt
	la $a0, playerXPrompt
	li $v0, 4
	syscall
	
	li $v0, 5 			# Read in user input
	syscall
	
	move $a0, $v0 			# Move user input into argument regiester
	jal checkInput
	
	# Store the player input in the appropriate position in the array
	lb $t0, xMove
	subi $t1, $v0, 1		# subtract 1 from the input number to convert to 0-based array index
	add $t1, $t1, $s0		# add the offset to the address of the beginning of the array to get the address of the index
	sb $t0, ($t1)			# store player move in array position
	
	# print the updated game board
	jal printCurrentBoard
	
	# TODO: check for win
	
	# Decrement turn counter and go again
	subi $s1, $s1, 1
	j playGame

playerOMove:
	# Print player prompt
	la $a0, playerOPrompt
	li $v0, 4
	syscall
	
	li $v0, 5 			# Read in user input
	syscall
	
	move $a0, $v0 			# Move user input into argument regiester
	jal checkInput
	
	# Store the player input in the appropriate position in the array
	lb $t0, oMove
	subi $t1, $v0, 1		# subtract 1 from the input number to convert to 0-based array index
	add $t1, $t1, $s0		# add the offset to the address of the beginning of the array to get the address of the index
	sb $t0, ($t1)			# store player move in array position
	
	# print the updated game board
	jal printCurrentBoard
	
	# TODO: check for win
	
	# Decrement turn counter and go again
	subi $s1, $s1, 1
	j playGame

checkInput:
	# TODO:
	# Verify that the user input is a value in 1-9
	# Verify that that spot in the array is not
	
	# Otherwise, jump back to playGame
	jr $ra


printCurrentBoard:
	# save the return address to the stack so it can be restored it later
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	la $a0, ($s0)			# address of the first item of the first row
	jal printPositionRow
	
	la $a0, rowDivider
	li $v0, 4
	syscall
	
	la $a0, 3($s0)			# address of the first item of the second row
	jal printPositionRow
	
	la $a0, rowDivider
	li $v0, 4
	syscall
	
	la $a0, 6($s0)			# address of the first item of the third row
	jal printPositionRow
	
	# reset the return address to its original value from the beginning of the function
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
printPositionRow:
	# note: $a0 is the address of the first index of the row to print
	move $t0, $a0			# move the contents of $a0 to a temporary register so a0 can be used for syscalls
	
	lb $a0, space
	li $v0, 11
	syscall
	
	# first column
	lb $a0, ($t0)
	li $v0, 11
	syscall
	
	la $a0, columnDivider
	li $v0, 4
	syscall
	
	# second column
	lb $a0, 1($t0)
	li $v0, 11
	syscall
	
	la $a0, columnDivider
	li $v0, 4
	syscall
	
	# third column
	lb $a0, 2($t0)
	li $v0, 11
	syscall
	
	lb $a0, space
	li $v0, 11
	syscall
	
	la $a0, newline
	li $v0, 4
	syscall
	
	jr $ra

checkWin:
	# TODO:
	# check row 1
	# check row 2
	# check row 3
	# check column 1
	# check column 2
	# check column 3
	# check diagonal 1 (top left to bottom right)
	# check diagonal 2 (bottom left to top right)
