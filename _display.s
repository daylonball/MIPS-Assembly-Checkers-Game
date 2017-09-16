# Global Procedures
.globl redraw


## =================================================================== ##
## ===================( Bitmap Display Procedures )=================== ##
## =================================================================== ##


.data
	screen: .word 0x10040000 # Must be on (heap)

	gray: 	.word 0x00d6d6d6
	blue:	.word 0x000032d8 # Red player
	red: 	.word 0x00d8003d # Blue player

	pixel: 	.word 1
	row_count: .word 8
	cubes_per_row: .word 4

	cube_size: .word 256
	pawn_size: .word 128
	queen_size: .word 200

	zero: .word 0
	
.text

	## Draws the game board along with each piece in the appropriate position.
	redraw:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		lw $t0, screen # Pointer to the current pixel being drawn
		lw $t1, cube_size # Pixel counter for width of each board position
		lw $t2, cubes_per_row # Counter of board positions left to draw on current line
		lw $t3, cube_size # Pixel counter for height of each row
		lw $t4, row_count # Counter for the number of rows left to draw
		lw $s7, gray # Color of pixels
		
		# Counter: t1
		drawPoints:
			subi $t1, $t1, 4 # Decriment pixels left for current cube
			sw $s7, ($t0) # Set the color of this pixel
			NOP
			NOP
			addi $t0, $t0, 4 # Increment pointer to next pixel on display
			bgtz $t1, drawPoints # Recurse (Each time a pixel is drawn)
		
		# Counter: t2
		drawLines:
			subi $t2, $t2, 1 # Decrement the count of board positions left to draw on this line
			lw $t1, cube_size # Reset $t1 to full cube size
			NOP
			NOP
			add $t0, $t0, $t1 # Move display pointer to the first pixel of the next white cube on the board
			bgtz $t2, drawPoints # Recurse (Each time a pixel layer has been completed for a single board position)
		
		# Counter: t3
		drawRow:	
			subi $t3, $t3, 4 # Decrement the number of lines (rows of pixels) to be drawn for the current row of the board	
			lw $t2, cubes_per_row # Reset $t2 to the full number of cubes per row (columns on the game board)
			NOP
			bgtz $t3, drawPoints # Recurse (Each time a pixel layer has been completed for an entire row of the board)	
		
		# Counter: t4
		drawBoard:
			subi $t4, $t4, 1 # Decrement the rows remaining
			lw $t3, cube_size # Reset lines in row remaining
			addi $t0, $t0, 256 # Shift the colors for the next row over one
			bgtz $t4, drawPoints # Recurse (Each time a row of the board has completed, until finished)
			
		drawPieces:
			lw $s6, cube_size
			lw $t0, zero
			lw $t7, screen
			mul $s6, $s6, 508
			subi $s6, $s6, 256
			subi $s7, $s6, 512
			
			li $s2, 0
			# Counter: $s0
			checkNextLocation:
				
				move $a1, $s2
				jal getPieceAt # Stores ID of piece at position with index $a1 in $v1
				
				la $a2, ($v1) # Store piece ID
				la $a0, ($t7) # Store a reference to the pixel on the top left of the board position for the piece to be drawn.
				
				beqz $a2, shiftPen # If no piece, move pixel pointer to the top left of the next location
				lw $a1, red # Predict piece color is red
				bgt $a2, 2, pieceType
				lw $a1, blue # Change piece color to blue
				
				pieceType:
					beq $a2, 1, pawn
					beq $a2, 2, queen
					beq $a2, 3, pawn
					beq $a2, 4, queen	
				pawn: 
					jal drawPawn
					j shiftPen
				queen:
					jal drawQueen
				shiftPen:
					# Check how many pixels must be passed to reach the top left of the next location
					beq $s2, 3, whiteToBlackShift
					beq $s2, 11, whiteToBlackShift
					beq $s2, 19, whiteToBlackShift
					beq $s2, 27, whiteToBlackShift
					beq $s2, 7, blackToWhiteShift
					beq $s2, 15, blackToWhiteShift
					beq $s2, 23, blackToWhiteShift
					singleShift: # Next location is directly to the right
						addi $t7, $t7, 512
						j recurse
					whiteToBlackShift: # Next location is the second block in the next row
						add $t7, $t7, $s6
						j recurse
					blackToWhiteShift: # Next location is at the beginning of the next row
						add $t7, $t7, $s7
						j recurse
				recurse:
					addi $s2, $s2, 1 # Increment gameStateArray index
					bne $s2, 32, checkNextLocation # If s2 != 32, check next board position for piece
					
					lw $ra, 0($sp)
					addiu $sp, $sp, 4
					jr $ra
		
		
	## Draw a pawn.
	# Parameters:
	# - $a0: Reference pixel
	# - $a1: Pawn color
	drawPawn:
		lw $t6, pawn_size # Counter for piece height
		move $t1, $t6 # Counter for piece width
		lw $t2, cube_size
		sub $t3, $t2, $t1
		div $t3, $t3, 2 # t3 is the number of bits to shift the display pointer from the left edge of it's location cube
		mul $t4, $t2, 8 # t4 is the number of bits required to wrap around the display, to the pixel below the current pixel
		sub $t5, $t4, $t1 # t5 is the number of bits required to wrap around the display, from the right edge of the pawn to the left (one row down).

		# Center piece on position
		add $a0, $a0, $t3 # Shift right
		div $t3, $t3, 4
		mul $t3, $t3, $t4
		add $a0, $a0, $t3 # Shift down
		
		pawnLoop:
			sw $a1, 0($a0)
			addi $a0, $a0, 4 # Increment pointer to next pixel on display
			subi $t1, $t1, 4 # Decriment pixels left current row
			bnez $t1, pawnLoop
			NOP
			lw $t1, pawn_size
			add $a0, $a0, $t5 # Wrap around board from right side of piece to left
			subi $t6, $t6, 4 # Decriment rows left
			bnez $t6 pawnLoop
		jr $ra


	## Draw a queen.
	# Parameters:
	# - $a0: Reference pixel
	# - $a1: Queen color
	drawQueen:
		lw $t6, queen_size # Counter for piece height
		move $t1, $t6 # Counter for piece width
		lw $t2, cube_size
		sub $t3, $t2, $t1
		div $t3, $t3, 2 # t3 is the number of bits to shift the display pointer from the left edge of it's location cube
		mul $t4, $t2, 8 # t4 is the number of bits required to wrap around the display, to the pixel below the current pixel
		sub $t5, $t4, $t1 # t5 is the number of bits required to wrap around the display, from the right edge of the pawn to the left (one row down).

		# Center piece on position
		add $a0, $a0, $t3 # Shift right
		div $t3, $t3, 4
		mul $t3, $t3, $t4
		add $a0, $a0, $t3 # Shift down
		
		queenLoop:
			sw $a1, 0($a0)
			addi $a0, $a0, 4 # Increment pointer to next pixel on display
			subi $t1, $t1, 4 # Decriment pixels left current row
			bnez $t1, queenLoop
			NOP
			lw $t1, queen_size
			add $a0, $a0, $t5 # Wrap around board from right side of piece to left
			subi $t6, $t6, 4 # Decriment rows left
			bnez $t6 queenLoop
		jr $ra
