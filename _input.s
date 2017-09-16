# Global Procedures
.globl getInput


## =================================================================== ##
## ======================( Retrieve User Input )====================== ##
## =================================================================== ##


.data
	blueMovePrompt: .asciiz "[Blue] Enter your next move: "
	redMovePrompt: .asciiz "[Red] Enter your next move: "
	
	.align 4
	buffer: .space 40
	
.text

	## Checks if the input is valid. If input is not valid, displays error message and restarts the players turn
	# Return:
	# - v0: Input string
	getInput:
		addiu $sp, $sp, -4
		sw $ra, 0($sp)
		
		#lw $t0, activePlayer
		#beq $t0, 0, bluePlayer
		#beq $t0, 1, redPlayer
		beq $s4, 0, bluePlayer
		beq $s4, 1, redPlayer
		bluePlayer:
			li $v0, 4
			la $a0, blueMovePrompt
			syscall	
			j input
		redPlayer:
			li $v0, 4
			la $a0, redMovePrompt
			syscall
		input:
		li $v0, 8
		la $a0, buffer
		li $a1, 8
		syscall # Get user input
		la $v0, ($a0)
	        	
	    	lw $ra, 0($sp)
		addiu $sp, $sp, 4
		jr $ra
