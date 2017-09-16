# Global Procedures
.globl verifyInput
.globl verifyMove


## =================================================================== ##
## ==================( Input and Move Verification )================== ##
## =================================================================== ##


.data
	invalidCharInputString: .asciiz "\tInvalid position ID! Valid characters: a, b, c, d, e, f, g, OR h\n\t\tExample input: b1-a2\n"
	verifyInput_evenNumString: .asciiz "\tInvalid position ID! Provided character must be paired with an even number in range [2,8]\n"
	verifyInput_oddNumString: .asciiz "\tInvalid position ID! Provided character must be paired with an odd number in range [1,7]\n"
	invalidDistanceString: .asciiz "\tInvalid move! Moves must be 1 to 2 spaces along a diagonal.\n"
	invalidCaptureString: .asciiz "\tInvalid move! Cannot move 2 spaces without capturing opponent piece.\n"
	invalidFinalPosition: .asciiz "\tInvalid move! Final position must be empty.\n"
	invalidPieceColorRed: .asciiz "\tInvalid move! You can only move blue pieces!\n"
	invalidPieceColorBlue: .asciiz "\tInvalid move! You can only move red pieces!\n"
	invalidBluePawnMovementDirection: .asciiz "\tInvalid move! Blue pawns can only move up.\n"
	invalidRedPawnMovementDirection: .asciiz "\tInvalid move! Red pawns can only move down.\n"
	initialPositionEmpty: .asciiz "\tInvalid move! Initial position is empty!\n"

.text

	## =======================( Input Verification )====================== ##


	## Checks if the input is valid. If input is not valid, displays error message and restarts the players turn
	# Parameters:
	# - a0: Input string
	# Return:
	# - $v0: The distance of the move (1 or 2)
	verifyInput:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		la $t0, ($a0)
		
		# Final position ID
		lb $a0, 3($t0) # letter
		lb $a1, 4($t0) # number
		jal verifyInput_checkPair
		
		move $a2, $a0
		move $a3, $a1
		
		# Initial position ID
		lb $a0, 0($t0) # letter
		lb $a1, 1($t0) # number
		jal verifyInput_checkPair
		
		lw $ra, 0($sp)
		addiu $sp, $sp, 4
		jr $ra
			

	## Checks if a single char-num pair is a valid board position ID
	# Range of valid position ID's: 
	# 	LN, where:
	# 		L = (a, c, e, OR g) AND N = (2, 4, 6, OR 8)
	# 				    OR
	# 		L = (b, d, f, OR h) AND N = (1, 3, 5, OR 7)
	## Parameters:
	# - $a0: the character of the pair (Ex: 'c' in 'c4')
	# - $a1: the number of the pair (Ex: '4' in 'c4')
	verifyInput_checkPair:
		# Must be char in range ['a','h']
		beq $a0, 'a', verifyInput_checkNumberEven
		beq $a0, 'c', verifyInput_checkNumberEven
		beq $a0, 'e', verifyInput_checkNumberEven
		beq $a0, 'g', verifyInput_checkNumberEven
		beq $a0, 'b', verifyInput_checkNumberOdd
		beq $a0, 'd', verifyInput_checkNumberOdd
		beq $a0, 'f', verifyInput_checkNumberOdd
		beq $a0, 'h', verifyInput_checkNumberOdd
		la $a0, invalidCharInputString
		j invalidPair
		# Must be even number in range [2,8]
		verifyInput_checkNumberEven:
			beq $a1, '2', validPair
			beq $a1, '4', validPair
			beq $a1, '6', validPair
			beq $a1, '8', validPair
			la $a0, verifyInput_evenNumString
			j invalidPair
		# Must be odd number in range [1,7]
		verifyInput_checkNumberOdd:
			beq $a1, '1', validPair
			beq $a1, '3', validPair
			beq $a1, '5', validPair
			beq $a1, '7', validPair
			la $a0, verifyInput_oddNumString
			j invalidPair
		validPair: 
			jr $ra # If this line is reached, the provided char-num pair is a valid board position ID
		invalidPair:
			jal printUserError
			addiu $sp, $sp, 4
			j turn


	## =======================( Move Verification )======================= ##
	
	
	## Checks if the move violates any rules of the game. [INCOMPLETE]
	# Parameters:
	# - $a0: Input String
	# Return
	# - $v0: 1 if a piece has been captured, otherwise 0
	# - $v1: the position of the piece being captured
	verifyMove:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		lb $a0, 0($s0)
		lb $a1, 1($s0)
		lb $a2, 3($s0)
		lb $a3, 4($s0)
		jal verifyMove_checkDistance
		move $s7, $v0 # $s7 stores vertical distance of the move
		
		lb $a0, 0($s0)
		lb $a1, 1($s0)
		lb $a2, 3($s0)
		lb $a3, 4($s0)
	  	jal verifyMove_checkPositionContents
		
		# -- Prevent pawns from moving backwards
		lb $a1, 0($s0)
		lb $a2, 1($s0)
		jal locationID_toIndex
		move $a1, $v1
		move $a2, $s7
		jal verifyMove_checkPawnMovementDirection
		
		move $v0, $s7
		beq $v0, 1, noCapture # If move distance is 1 (or -1), move verification complete
		beq $v0, -1, noCapture
		j capture
		noCapture:
			li $v0, 0
			j verifyMove_complete
		capture:
			lb $a0, 0($s0)
			lb $a1, 1($s0)
			lb $a2, 3($s0)
			lb $a3, 4($s0)
			jal verifyMove_checkCapture # Move distance is 2
		verifyMove_complete:
			lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra	
		

	## Checks if the move from initial position to final position is a possible movement.
	# - Depends on what team the piece belongs to. (NOT YET IMPLEMENTED)
	# - Depends on whether the piece is a Queen. (NOT YET IMPLEMENTED)
	# Parameters:
	# - $a0: the character in the first pair (Ex: 'c' in 'c4')
	# - $a1: the number in the first pair (Ex: '4' in 'c4')
	# - $a2: the character in the second pair
	# - $a3: the number in the second pair
	# Return:
	# - $v0: The distance of the move (1 or 2)
	verifyMove_checkDistance:
		# Tests fail if d>2, d<-2, OR d==0
		
		# Compare Characters (horizontal distance)
		sub $t1, $a2, $a0
		bgt $t1, 2, invalidDistance
		blt $t1, -2, invalidDistance
		beqz $t1, invalidDistance
		
		# TODO: if $t2 == 2 or -2 check if there is a piece from the other team inbetween initialPos and finalPos
		
		# Compare Numbers (vertical distance)
		sub $t2, $a3, $a1
		bgt $t2, 2, invalidDistance
		blt $t2, -2, invalidDistance
		beqz $t2, invalidDistance
		
		# Set return ($v0) to be equal to vertical distance
		move $v0, $t2
		
		# The absolute value of vertical distance must equal absolute value of horizontal distance
		subu $t3, $t1, $t2 
		beqz $t3, validDistance
		
		validDistance:
			jr $ra
		invalidDistance:
			la $a0, invalidDistanceString
			jal printUserError
			addiu $sp, $sp, 4
			j turn
		

	## Ensure that the piece at the initial position is owned by the active player,
	# AND that the final position is empty.
	# Parameters:
	# - $a0: the character in the first pair (Ex: 'c' in 'c4')
	# - $a1: the number in the first pair (Ex: '4' in 'c4')
	# - $a2: the character in the second pair
	# - $a3: the number in the second pair
	verifyMove_checkPositionContents:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		move $t4, $a2
		move $t5, $a3
		move $t6, $a0
		move $t7, $a1
		
		# Checking if piece at initial position is owned by the active player
		move $a1, $t6
		move $a2, $t7
		jal locationID_toIndex
		mul $t0, $v1, 4
		lw $t0, gameStateArray($t0)
		beq $t0, 1, movingBluePiece
		beq $t0, 2, movingBluePiece
		beq $t0, 3, movingRedPiece
		beq $t0, 4, movingRedPiece
		beq $t0, 0, movingNothing
		
		movingBluePiece:
			beq $s4, 0, checkFinalPosition
			la $a0, invalidPieceColorBlue
			j movingWrongColor
			
		movingRedPiece:
			beq $s4, 1, checkFinalPosition
			la $a0, invalidPieceColorRed
			
		movingWrongColor:
			jal printUserError
			addiu $sp, $sp, 4
			j turn
		
		movingNothing:
			la $a0, initialPositionEmpty
			jal printUserError
			addiu $sp, $sp, 4
			j turn
		
		checkFinalPosition:
		# Checking if final position is empty
		move $a1, $t4
		move $a2, $t5
		jal locationID_toIndex # final position ID: $v1
		move $a1, $v1
		jal getPieceAt
		beq $v1, 0, finalPositionIsEmpty
		j nonEmptyFinalPosition
		
		finalPositionIsEmpty:
			#jal locationID_toIndex
			#move $t6, $v1 # initial position ID
		
			# Test passed
			lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra
		
		nonEmptyFinalPosition: # Test failed
			la $a0, invalidFinalPosition
			jal printUserError
			addiu $sp, $sp, 4
			j turn
		

	## Prevents a pawn from moving in the wrong direction.
	# Parameters:
	# - $a1: Index of piece being moved in the gameStateArray
	# - $a2: Vertical displacement of move (-2, -1, 1, or 2)
	verifyMove_checkPawnMovementDirection:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal getPieceAt
		beq $v1, 1, bluePawnMoving # Blue pawns can only move up
		beq $v1, 3, redPawnMoving # Red pawns can only move down
		j validDirection # Piece is a queen, therefore any direction is valid
		
		bluePawnMoving:
			la $a0, invalidBluePawnMovementDirection
			bltz $a2, invalidPawnMove
			j validDirection
		redPawnMoving:
			la $a0, invalidRedPawnMovementDirection
			bgtz $a2, invalidPawnMove
			j validDirection
		invalidPawnMove:
			jal printUserError
			addiu $sp, $sp, 4
			j turn
		validDirection:
			lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra
			

	## Checks if there is a piece of the opposing team inbetween the 
	# initial and final position on a move of distance 2
	# Parameters:
	# - $a0: the character in the first pair (Ex: 'c' in 'c4')
	# - $a1: the number in the first pair (Ex: '4' in 'c4')
	# - $a2: the character in the second pair
	# - $a3: the number in the second pair
	# Return
	# - $v0: 1 if a piece has been captured, otherwise 0
	# - $v1: the position of the piece being captured
	verifyMove_checkCapture:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		move $t4, $a0
		move $t5, $a1
		
		move $a1, $a2
		move $a2, $a3
		jal locationID_toIndex
		move $t7, $v1 # final position ID
		
		move $a1, $t4
		move $a2, $t5
		jal locationID_toIndex
		move $t6, $v1 # initial position ID
		
		add $t4, $t6, $t7 # Sum of position ID's
		
		beq, $t6, 0, skipAddOne
		beq, $t6, 1, skipAddOne
		beq, $t6, 2, skipAddOne
		beq, $t6, 3, skipAddOne
		beq, $t6, 8, skipAddOne
		beq, $t6, 9, skipAddOne
		beq, $t6, 10, skipAddOne
		beq, $t6, 11, skipAddOne
		beq, $t6, 16, skipAddOne
		beq, $t6, 17, skipAddOne
		beq, $t6, 18, skipAddOne
		beq, $t6, 19, skipAddOne
		beq, $t6, 24, skipAddOne
		beq, $t6, 25, skipAddOne
		beq, $t6, 26, skipAddOne
		beq, $t6, 27, skipAddOne
		addi $t4, $t4, 1
		skipAddOne:
			div $t4, $t4, 2 # $t4 - index of location being jumped
			
			move $a1, $t6
			jal getPieceAt
			la $t8, ($v1) # ID of piece at initial position
			
			move $a1, $t4 
			jal getPieceAt
			la $t9, ($v1) # ID of piece at position between initial and final positions
			
			beqz $t9, invalidJump
			beq $t8, 1, movingPieceBlue
			beq $t8, 2, movingPieceBlue
			beq $t8, 3, movingPieceRed
			beq $t8, 4, movingPieceRed
			
			movingPieceBlue:
				beq $t9, 3, validJump
				beq $t9, 4, validJump
				j invalidJump
			movingPieceRed:
				beq $t9, 1, validJump
				beq $t9, 2, validJump
				j invalidJump
			validJump:
				li $v0, 1
				move $v1, $t4
				lw $ra, 0($sp)
				addiu $sp, $sp, 4
				jr $ra
			invalidJump:
				la $a0, invalidCaptureString
				jal printUserError
				addiu $sp, $sp, 4
				j turn


	## ==========================( Error Output )========================= ##

	
	printUserError:
		li $v0, 4
		syscall
		jr $ra
