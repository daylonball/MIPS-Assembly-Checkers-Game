# Global Data
.globl gameStateArray
.globl numLocations
.globl iterator
.globl activePlayer

# Global Procedures
.globl performMove
.globl getPieceAt
.globl setPieceAt
.globl locationID_toIndex


## =================================================================== ##
## ===================( Game State Data Structure )=================== ##
## =================================================================== ##


.data
	#		       Row 1(top)  Row 2       Row 3       Row 4       Row 5       Row 6       Row 7       Row 8(bottom)
	#		       |	   |	       |	   |	       |	   |	       |           |
	gameStateArray: .word  0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 3, 0, 0, 0, 0, 1, 0, 0
	numLocations: .word 31 # 31 (max index)
	iterator: .word 0 # iterator index
	
	activePlayer: .word 0 # 0:Blue, 1:Red

	blue_pawn_value: .word 1
	blue_queen_value: .word 2

	red_pawn_value: .word 3
	red_queen_value: .word 4

	noQueenString: .asciiz "\tNo queen string\n"
	queenBlueMoved: .asciiz "\tQueen - Blue moved\n"
	queenRedMoved: .asciiz "\tQueen - Red moved\n"
	queenPieceCalled: .asciiz "\tQueening Procedure called\n"

.text


	## ==========================( Perform Move )========================= ##


	## Applies a move to the game state
	# Preconditions:
	# - Both location ID provided are valid
	# - The move defined by both locations ID is valid
	# Paramters:
	# - $a0: Input string 
	# - $a1: 1 if piece captured, otherwise 0
	# - $a2: positionID of captured piece 
	performMove:       
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
				
		beqz $a1, swapInitialAndFinal
		
		move $a1, $a2
		li $a2, 0
		jal setPieceAt
		
		swapInitialAndFinal:		
        		lb $a1, 0($a0)
        		lb $a2, 1($a0)
        		jal locationID_toIndex
        		la $t4, ($v1) # Store ID of initial position
        	
 			lb $a1, 3($a0)
			lb $a2, 4($a0)
        		jal locationID_toIndex
        		la $t5, ($v1) # Store ID of final position
        		#jal showInputIDs
        	
			la $a1, ($t4)
        		jal getPieceAt
        		la $a2, ($v1) # Store ID of piece at initial position
        	
			la $a1, ($t5)
			jal setPieceAt # Assign ID of piece at initial position to final position
			move $a1, $t5
        		jal queenPiece
        	
        		la $a1, ($t4)
        		li $a2, 0
        		jal setPieceAt # Assign piece ID of 0 (no piece) to initial position
            	
           		lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra	
	
	
	## Queen a piece
	# Parameters
	# - $a1: index of the final position of the moved piece
	queenPiece:	
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		mul $t0, $a1, 4 # gameStateArray-index = index * 4
		lw $t1, gameStateArray($t0)

		# check what colour of piece (red and blue)
		beq $t1, 1, queenPieceBlue
		beq $t1, 3, queenPieceRed
		j queenPieceDone
		
		queenPieceBlue: # Check if blue piece is in position 0, 1, 2, or 3
			beq $a1, 0, queenIt
			beq $a1, 1, queenIt
			beq $a1, 2, queenIt
			beq $a1, 3, queenIt
			j queenPieceDone # No piece is queened
			
		queenPieceRed: # Check if red piece is in position 28, 29, 30, or 31
			beq $a1, 28, queenIt
			beq $a1, 29, queenIt
			beq $a1, 30, queenIt
			beq $a1, 31, queenIt
			j queenPieceDone # No piece is queened
			
		queenIt: # A piece is queened
			addi $a2, $t1, 1
			jal setPieceAt
			
		queenPieceDone:
			lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra	
			
	
	## =============================( Access )============================ ##
	

	## Determines the index of the input location ID in the gameStateArray
	# Preconditions:
	# - The location ID provided is valid
	# Paramters:
	# - $a1: The character of the ID
	# - $a2: The number of the ID
	# Return:
	# - $v1: The index of that location in the gameStateArray
	locationID_toIndex:
		li $t0, 0
		beq $a1, 'a', lidti_numFactor
		addi $t0, $t0, 1
		beq $a1, 'c', lidti_numFactor
		addi $t0, $t0, 1
		beq $a1, 'e', lidti_numFactor
		addi $t0, $t0, 1
		beq $a1, 'g', lidti_numFactor
		addi $t0, $t0, 1
		beq $a1, 'b', lidti_numFactor
		addi $t0, $t0, 1
		beq $a1, 'd', lidti_numFactor
		addi $t0, $t0, 1
		beq $a1, 'f', lidti_numFactor
		addi $t0, $t0, 1
			lidti_numFactor:
			beq $a2, '8', lidti_return
			beq $a2, '7', lidti_return
			addi $t0, $t0, 8
			beq $a2, '6', lidti_return
			beq $a2, '5', lidti_return
			addi $t0, $t0, 8
			beq $a2, '4', lidti_return
			beq $a2, '3', lidti_return
			addi $t0, $t0, 8
			lidti_return:
				la $v1, ($t0)
				jr $ra


	## Locates the element at index $a1, and stores it in $v1
	# Preconditions:
	# - $a1 must be in the range [0, numLocations]
	# Parameters:
	# - $a1: Index of desired element
	# Return: 
	# - $v1: Address of element at index $a1
	getPieceAt:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		la $t0, gameStateArray
		lw $t2, numLocations
		blt $s1, $a0, resetIterator # If (desiredIndex > currentIndex) currentIndex = 0
		resetIterator:
			li $s1, 0
		getPieceAt_loop:
			bgt $s1, $t2, getPieceAt_endLoop # If (index > size) end function
			beq $s1, $a1, getPieceAt_locationFound # If (index == desiredIndex) return element
			addi $s1, $s1, 1 # Increment iterator
			j getPieceAt_loop
		getPieceAt_locationFound:
			sll $t3, $s1, 2 # t3 = 4*iterator
			addu $t3, $t3, $t0 # t3 = t3 + (memory location of gameState array)
			#li $v0, 1
			#la $a0, ($t3)
			#syscall
			lw $v1, 0($t3) # Store address in $v1 (Return value)
		getPieceAt_endLoop:
			li $s1, 0
			lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra	


	## Stores $a2 in the element at index $a1 in the gameStateArray
	# Preconditions:
	# - $a1 must be in the range [0, numLocations]
	# - $a2 must be in the range [0, 4]
	# Parameters:
	# - $a1: Index of desired element
	# - $a2: Value to be stored at that index of the gameStateArray
	setPieceAt:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		la $t0, gameStateArray
		lw $t2, numLocations
		#blt $a0, $s1, resetIterator # If (desiredIndex > currentIndex) currentIndex = 0
		#resetIterator:
		#	li $s1, 0
		setPieceAt_loop:
			bgt $s1, $t2, setPieceAt_endLoop # If (index > size) end function
			beq $s1, $a1, setPieceAt_locationFound # If (index == desiredIndex) return element
			addi $s1, $s1, 1 # Increment iterator
			j setPieceAt_loop
		setPieceAt_locationFound:
			sll $t3, $s1, 2 # t3 = 4*iterator
			addu $t3, $t3, $t0 # t3 = t3 + (memory location of gameStateArray)
			#li $v0, 1
			#la $a0, ($t3)
			#syscall
			sw $a2, 0($t3) # Store address in $v1 (Return value)
		setPieceAt_endLoop:
			li $s1, 0
			lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra


