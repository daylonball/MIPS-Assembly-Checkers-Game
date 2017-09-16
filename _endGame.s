# Global Procedures
.globl noPiecesLeft
.globl endGameStateCheck


## =================================================================== ##
## ======================( End-game State Test )====================== ##
## =================================================================== ##


.data
	red_Wins: .asciiz "\n blue has no more pieces, red wins."
	blue_Wins: .asciiz "\n red has no more pieces, blue wins."

	moveFound: .asciiz "\tPossible move found!\n"
	noMoveFound: .asciiz "\t No move found! Game over!\n"
	
	searchingPosition: .asciiz "\tSearching another position...\n"
	searchingIT1Position: .asciiz "\t\tPosition is of inner type 1\n"
	
.text

	endGameStateCheck:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		li $t1, 16 # index
		
		# Inner positions check: Checks if any pieces in any of the central 18 positions can be moved by the active player
		typeLoop:
			beq $t1, 128, finishedSearching_noMove # 31 positions, 4 bytes per position, => 124
			lw $t2, gameStateArray($t1) # ID of piece at index $t1
			
			li $v0, 4
			la $a0, searchingPosition
			syscall
			
			beq $t2, 0, typeLoop_iterate
			
			# Discriminate against pieces on the non-active players team
			beq $s4, 0, blueIsActive
			redIsActive:
				beq $t2, 1, typeLoop_iterate
				beq $t2, 2, typeLoop_iterate
				j continueTest
			blueIsActive:
				beq $t2, 3, typeLoop_iterate
				beq $t2, 4, typeLoop_iterate
			continueTest:
			
			# 4, 5, 6, 12, 13, 14, 20, 21, and 22 (*4)
			beq $t1, 16, innerType1
			beq $t1, 20, innerType1
			beq $t1, 24, innerType1
			beq $t1, 48, innerType1
			beq $t1, 52, innerType1
			beq $t1, 56, innerType1
			beq $t1, 80, innerType1
			beq $t1, 84, innerType1
			beq $t1, 88, innerType1
			# 9, 10, 11, 17, 18, 19, 25, 26, and 27 (*4)
			beq $t1, 36, innerType2
			beq $t1, 40, innerType2
			beq $t1, 44, innerType2
			beq $t1, 68, innerType2
			beq $t1, 72, innerType2
			beq $t1, 76, innerType2
			beq $t1, 100, innerType2
			beq $t1, 104, innerType2
			beq $t1, 108, innerType2
			# Current position is not tested by this procedure
			j typeLoop_iterate
			
			# ===================== Inner type 1 =====================
			# Positions with index: 4, 5, 6, 12, 13, 14, 20, 21, or 22
			innerType1: 
				li $v0, 4
				la $a0, searchingIT1Position
				syscall
				# === Determine piece type ===
				
				# If $t2 is a red pawn, try 1 and 2.
				beq $t2, 3, iT1_RedPawn
				j iT1_jump_RedPawn # Not red pawn, skip red specific details
				iT1_RedPawn:
					jal iT1_1
					jal iT1_2
					j typeLoop_iterate
				iT1_jump_RedPawn:
				
				# If $t2 is a blue pawn, try 3 and 4
				beq $t2, 1, iT1_BluePawn
				j iT1_Queen # not blue pawn, therefore queen
				iT1_BluePawn:
					jal iT1_3
					jal iT1_4
					j typeLoop_iterate
					
				# If $t2 is a queen, try 1, 2, 3 and 4
				iT1_Queen:
					jal iT1_1
					jal iT1_2
					jal iT1_3
					jal iT1_4
					j typeLoop_iterate
				
				# === Movement types ===
				
				iT1_1: # 1. check for move down-right: i+5 (NO CAPTURE RESTRICTIONS)
					addiu $sp, $sp, -4
					sw $ra, 0($sp)
					
					# Store ID of piece in this direction
					addi $t3, $t1, 20 # 5 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 1a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 1b. If contains piece on opponents team AND if it can be captured, move possible
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					addi $t5, $t3, 16 # 4 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					j doneSearchingDirection # No move found in this direction
			
				iT1_2: # 2. check for move down-left: i+4 (CANNOT CAPTURE 8, 16, 24)
					addiu $sp, $sp, -4
					sw $ra, 0($sp)
					
					# Store ID of piece in this direction
					addi $t3, $t1, 16 # 4 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 2a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 2b. If contains piece on opponents team AND if it can be captured, move possible
					beq $t3, 32, doneSearchingDirection # 8(index)*4(sizeOfWord)
					beq $t3, 64, doneSearchingDirection # 16(index)*4(sizeOfWord)
					beq $t3, 96, doneSearchingDirection # 24(index)*4(sizeOfWord)
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					addi $t5, $t3, 12 # 3 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					j doneSearchingDirection # No move found in this direction
						
				iT1_3: # 3. check for move up-right: i-3 (CANNOT CAPTURE 1, 2, 3)
					addiu $sp, $sp, -4
					sw $ra, 0($sp)
					
					# Store ID of piece in this direction
					subi $t3, $t1, 12 # 3 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 2a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 2b. If contains piece on opponents team AND if it can be captured, move possible
					beq $t3, 4, doneSearchingDirection # 1(index)*4(sizeOfWord)
					beq $t3, 8, doneSearchingDirection # 2(index)*4(sizeOfWord)
					beq $t3, 12, doneSearchingDirection # 3(index)*4(sizeOfWord)
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					subi $t5, $t3, 16 # 4 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					j doneSearchingDirection # No move found in this direction
						
				iT1_4: # 4. check for move up-left: i-4 (CANNOT CAPTURE 0, 1, 2)
					
					
					# Store ID of piece in this direction
					subi $t3, $t1, 16 # 4 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 2a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 2b. If contains piece on opponents team AND if it can be captured, move possible
					beq $t3, 0, doneSearchingDirection # 0(index)*4(sizeOfWord)
					beq $t3, 4, doneSearchingDirection # 1(index)*4(sizeOfWord)
					beq $t3, 8, doneSearchingDirection # 2(index)*4(sizeOfWord)
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					subi $t5, $t3, 20 # 5 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					# Here: No move found in this direction
					
			# ===================== Inner type 2 =====================
			# Positions with index: 4, 5, 6, 12, 13, 14, 20, 21, or 22
			innerType2: 
				#li $v0, 4
				#la $a0, searchingIT2Position
				#syscall
				
				# === Determine piece type ===
				
				# If $t2 is a red pawn, try 1 and 2.
				beq $t2, 3, iT2_RedPawn
				j iT2_jump_RedPawn # Not red pawn, skip red specific details
				iT2_RedPawn:
					jal iT2_1
					jal iT2_2
					j typeLoop_iterate
				iT2_jump_RedPawn:
				
				# If $t2 is a blue pawn, try 3 and 4
				beq $t2, 1, iT2_BluePawn
				j iT2_Queen # not blue pawn, therefore queen
				iT2_BluePawn:
					jal iT2_3
					jal iT2_4
					j typeLoop_iterate
					
				# If $t2 is a queen, try 1, 2, 3 and 4
				iT2_Queen:
					jal iT2_1
					jal iT2_2
					jal iT2_3
					jal iT2_4
					j typeLoop_iterate
				
				# === Movement types ===
				
				iT2_1: # 1. check for move down-right: i+5 (CANNOT CAPTURE 29, 30, 31)
					addiu $sp, $sp, -4
					sw $ra, 0($sp)
					
					# Store ID of piece in this direction
					addi $t3, $t1, 20 # 5 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 1a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 1b. If contains piece on opponents team AND if it can be captured, move possible
					beq $t3, 116, doneSearchingDirection # 29(index)*4(sizeOfWord)
					beq $t3, 120, doneSearchingDirection # 30(index)*4(sizeOfWord)
					beq $t3, 124, doneSearchingDirection # 31(index)*4(sizeOfWord)
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					addi $t5, $t3, 16 # 4 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					j doneSearchingDirection # No move found in this direction
			
				iT2_2: # 2. check for move down-left: i+4 (CANNOT CAPTURE 28, 29, 30)
					addiu $sp, $sp, -4
					sw $ra, 0($sp)
					
					# Store ID of piece in this direction
					addi $t3, $t1, 16 # 4 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 2a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 2b. If contains piece on opponents team AND if it can be captured, move possible
					beq $t3, 112, doneSearchingDirection # 28(index)*4(sizeOfWord)
					beq $t3, 116, doneSearchingDirection # 29(index)*4(sizeOfWord)
					beq $t3, 120, doneSearchingDirection # 30(index)*4(sizeOfWord)
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					addi $t5, $t3, 12 # 3 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					j doneSearchingDirection # No move found in this direction
						
				iT2_3: # 3. check for move up-right: i-3 (CANNOT CAPTURE 7, 15, 23)
					addiu $sp, $sp, -4
					sw $ra, 0($sp)
					
					# Store ID of piece in this direction
					subi $t3, $t1, 12 # 3 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 2a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 2b. If contains piece on opponents team AND if it can be captured, move possible
					beq $t3, 28, doneSearchingDirection # 7(index)*4(sizeOfWord)
					beq $t3, 60, doneSearchingDirection # 15(index)*4(sizeOfWord)
					beq $t3, 92, doneSearchingDirection # 23(index)*4(sizeOfWord)
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					subi $t5, $t3, 16 # 4 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					j doneSearchingDirection # No move found in this direction
						
				iT2_4: # 4. check for move up-left: i-4 (NO CAPTURE RESTRICTIONS)
					
					
					# Store ID of piece in this direction
					subi $t3, $t1, 16 # 4 positions away * 4 bytes per word
					lw $t4, gameStateArray($t3)
					
					# 2a. If empty, move possible
					beqz $t4, finishedSearching_movePossible
					# 2b. If contains piece on opponents team AND if it can be captured, move possible
					move $a0, $t2
					move $a1, $t4
					jal onDifferentTeams
					beqz $v0, doneSearchingDirection
					# Here: Piece is on other team. 
					# Store ID of piece down and to the right of it.
					subi $t5, $t3, 20 # 5 positions away * 4 bytes per word
					lw $t6, gameStateArray($t5)
					beqz $t6, finishedSearching_movePossible # If no piece is there, possible move found, stop searching
					# Here: No move found in this direction
				
			doneSearchingDirection:
				lw $ra, 0($sp)
				addiu $sp, $sp, 4
				jr $ra
				
			typeLoop_iterate:
				addi $t1, $t1, 4
				j typeLoop
			
		finishedSearching_movePossible:
			li $v0, 4
			la $a0, moveFound
			syscall
		
			addiu $sp, $sp, 4 # Back out of inner return address
			lw $ra, 0($sp) # Recover outter return address
			addiu $sp, $sp, 4 
			jr $ra
		finishedSearching_noMove:
			li $v0, 4
			la $a0, noMoveFound
			syscall
			jal outerPositionsCheck
			jal noPiecesLeft
			lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra
			#j gameOver # TODO: Display who won	
            	
	
	## Helper procedure to determine if two pieces are on different teams
	# Paramters:
	# - $a0: ID of first piece
	# - $a1: ID of second piece
	# Return:
	# - $v0: 1 if piece are on different teams, else 0
	onDifferentTeams:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		beq $a0, 1, onDifferentTeams_firstBlue
		beq $a0, 2, onDifferentTeams_firstBlue
		beq $a0, 3, onDifferentTeams_firstRed
    		beq $a0, 4, onDifferentTeams_firstRed
    		
    		onDifferentTeams_firstBlue:
    	    		beq $a1, 3, onDifferentTeams_different
        		beq $a1, 4, onDifferentTeams_different
        		j onDifferentTeams_same
        		
    		onDifferentTeams_firstRed:
        		beq $a1, 1, onDifferentTeams_different
        		beq $a1, 2, onDifferentTeams_different
        		j onDifferentTeams_same
        		
    		onDifferentTeams_different:
        		li $v0, 1
        		j onDifferentTeams_return
    		onDifferentTeams_same:
        		li $v0, 0
        	onDifferentTeams_return:
        		lw $ra, 0($sp)
			addiu $sp, $sp, 4
			jr $ra


	## Checks gameStateArray to see if a player has lost all of their pieces.
	noPiecesLeft:
		addi $t0, $zero, 0 # $t0 is the counter for the loop.
		addi $t1, $zero, 0 # $t1 is the index for obtaining a value from gameSateArray.
		addi $t2, $zero, 0 # $t2 will store the value of gameStatue array
		addi $t3, $zero, 0 # $t3 tracker for how many blue pieces
		addi $t4, $zero, 0 # $t2 tracker for how many red pieces
		
		countPieces:
			beq $t0, 32, CountPieces_end # end loop
			lw $t2, gameStateArray($t1) # load the value of gameStateArray into $t2
			
			# print the value of $t2, used for testing
			#addi $a0, $t2, 0 
			#li $v0, 1
			#syscall
			
			addi $t1, $t1, 4 # increment the index by 4
			addi $t0, $t0, 1 # increment counter by 1
			
			beq $t2, 1, isBlue # if the current location has a blue pawn (1) call isBlue 
			beq $t2, 2, isBlue # if the current location has a blue queen (2) call isBlue 
			beq $t2, 3, isRed # if the current location has a blue pawn (3) call isRed 
			beq $t2, 4, isRed # if the current location has a blue queen (4) call isRed 

			j countPieces
		
			#increase red piece tracker ($t4) by 1
			isRed:
				addi $t4, $t4, 1
				# print the value of $t4, used for testing
				#addi $a0, $t4, 0 
				#li $v0, 1
				#syscall
				j countPieces
			
			#increase blue piece tracker ($t3) by 1
			isBlue:
				addi $t3, $t3, 1			
				# print the value of $t3, used for testing
				#addi $a0, $t3, 0 
				#li $v0, 1
				#syscall				
				j countPieces
			
			redWins:
				# ouput "red wins"
				li $v0, 4
				la $a0, red_Wins
				syscall
				j gameOver

			blueWins:
				# ouput "blue wins"
				li $v0, 4
				la $a0, blue_Wins
				syscall
				j gameOver
				
		CountPieces_end:
			beq $t3, 0, redWins #if blue has 0 pieces jump to redWins
			beq $t4, 0, blueWins #if red has 0 pieces jump to blueWins
			jr $ra 		



	## End-game features can be added here
	#gameOver:
	#	li $v0, 10
	#	syscall
