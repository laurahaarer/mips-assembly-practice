.data
intro: .asciiz "*** TIC-TAC-TOE ***\n"
positionInstructions: .asciiz "Make a move by choosing a number representing a new position\n"
invalidNumberMessage: .asciiz "[invalid input] - number entered must be between 1 and 9 (inclusive)\n"
positionTakenMessage: .asciiz "[invalid input] - that position is already taken\n"

rowDivider: .asciiz "---+---+---\n"
columnDivider: .asciiz " | "
space: .byte ' '
newline: .asciiz "\n"

moves: .byte '1', '2', '3', '4', '5', '6', '7', '8', '9' # a 9-character array of bytes representing players' positions

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
	
	la $s0, moves       		# load the address of the beginning of the moves array
	li $s1, 9			# track the current turn

	jal printCurrentBoard		# print the board with numbers corresponding to positions
	
	jal initEmptyMovesArray		# clear out the board
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
	
playerXMove:
	# Print player prompt
	la $a0, playerXPrompt
	li $v0, 4
	syscall
	
	li $v0, 5 			# Read in user input
	syscall
	
	move $a0, $v0 			# Move user input into argument regiester
	jal checkInput
	
	# Once a valid move has been made, decrement turn counter
	subi $s1, $s1, 1
	
	# Store the player input in the appropriate position in the array
	lb $t0, xMove
	subi $t1, $v0, 1		# subtract 1 from the input number to convert to 0-based array index
	add $t1, $t1, $s0		# add the offset to the address of the beginning of the array to get the address of the index
	sb $t0, ($t1)			# store player move in array position
	
	# print the updated game board
	jal printCurrentBoard
	
	# check for win; expects the appropriate player win message to be in $a0
	la $a0, playerXWonMessage
	j checkWin

playerOMove:
	# Print player prompt
	la $a0, playerOPrompt
	li $v0, 4
	syscall
	
	li $v0, 5 			# Read in user input
	syscall
	
	move $a0, $v0 			# Move user input into argument regiester
	jal checkInput
	
	# Once a valid move has been made, decrement turn counter
	subi $s1, $s1, 1
	
	# Store the player input in the appropriate position in the array
	lb $t0, oMove
	subi $t1, $v0, 1		# subtract 1 from the input number to convert to 0-based array index
	add $t1, $t1, $s0		# add the offset to the address of the beginning of the array to get the address of the index
	sb $t0, ($t1)			# store player move in array position
	
	# print the updated game board
	jal printCurrentBoard
	
	# check for win; expects the appropriate player win message to be in $a0
	la $a0, playerOWonMessage
	j checkWin

checkInput:
	# Verify that the user input is a number in 1-9
	blt $a0, 1, invalidNumber
	bgt $a0, 9, invalidNumber
	
	# Verify that that spot in the array is not
	subi $t0, $a0, 1		# subtract 1 from the user input to get the zero-based index
	add $t0, $t0, $s0		# add the user input to the beginning of the array to get the correct address offset
	lb $t0, ($t0)			# load the byte at the address of the chosen array position
	lb $t1, space			# load the space byte into $t1
	bne $t0, $t1, positionTaken	# check if the byte in the chosen array position is a space - if not, the position is taken
	
	# Otherwise, jump back to current position
	jr $ra

invalidNumber:
	# Print the invalid input number message and jump to ask for user input again
	la $a0, invalidNumberMessage
	li $v0, 4
	syscall
	j playGame
	
positionTaken:
	# Print the spot taken message and jump to ask for user input again
	la $a0, positionTakenMessage
	li $v0, 4
	syscall
	j playGame

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
	# $a0: the address of the first index of the row to print

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
	# $a0: the address of the current player win message to print if there is a win

	# -- check rows; increment amount = 1 --
	li $a2, 1
	# row 1
	la $a1, ($s0)			# address of the first item of the firts row
	jal checkUnit
	# row 2
	la $a1, 3($s0)			# address of the first item of the second row
	jal checkUnit
	# row 3
	la $a1, 6($s0)			# address of the first item of the third row
	jal checkUnit

	# -- check columns; increment amount = 3 --
	li $a2, 3
	# column 1
	la $a1, ($s0)			# address of the first item of the first column
	jal checkUnit
	# column 2
	la $a1, 1($s0)			# address of the first item of the second column
	jal checkUnit
	# column 3
	la $a1, 2($s0)			# address of the first item of the third column
	jal checkUnit

	# top left to bottom right diagonal - indices 0, 4, 8
	la $a1, ($s0)
	li $a2, 4
	jal checkUnit
	
	# top right to bottom left diagonal - indices 2, 4, 6
	la $a1, 2($s0)
	li $a2, 2
	jal checkUnit
	
	# If this is reached, no player has won yet; continue the game
	j playGame
	
checkUnit:
	# $a0: the message to print if there is a winner
	# $a1: the beginning of the column to check
	# $a2: the offset between indices that should be checked
	
	move $t0, $a1			# store the address of beginning of the row so $t0 can act as a counter through therow
	lb $t1, ($t0)			# load the byte at the current index
	
	lb $t2, space
	beq $t1, $t2, return		# if the byte is a space, it's not a win - continue the game
	
	add $t0, $t0, $a2		# increment $t0 to the address of the next array index to check
	lb $t2, ($t0)			# load the second byte to check
	bne $t1, $t2, return		# if the two bytes don't match, no win; the game continues
	
	add $t0, $t0, $a2		# increment $t0 to the address of the next array to check
	lb $t2, ($t0)			# load the third byte to check
	bne $t1, $t2, return		# if the bytes don't match, no win; the game continues
	
	# if we make it here, the row is the same and a player won
	# the appropriate player won message to print is already in a0
	j printEndMessage

return:
	jr $ra

printEndMessage:
	# $a0: the message to print if there is a winner
	
	# print the given game message (tie, x won, or o won)
	li $v0, 4
	syscall
	
	# exit the game
	li $v0, 10
	syscall

tieGame:
	la $a0, tieMessage
	j printEndMessage
