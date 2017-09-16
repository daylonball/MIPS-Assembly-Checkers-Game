# Global Procedures
.globl turn


## =================================================================== ##
## ============================( Launcher )=========================== ##
## =================================================================== ##


.text
	
	## ===========================( Game Setup )========================== ##

	main:
		li $s4, 0
		jal redraw # Draw the board for the first time
		j turn # Start first players turn

	## =======================( Main Program Loop )======================= ##

	turn:
		jal getInput
		
		lb $t0, 0($v0)
		beq $t0, '\n', endTurn

		la $s0, ($v0) # $s0 stores the player input
        	la $a0, ($s0)
        	jal verifyInput

        	la $a0, ($s0)
        	jal verifyMove

        	la $a0, ($s0)
        	la $a1, ($v0)
        	la $a2, ($v1)
        	jal performMove
        	
        	jal redraw
        	jal endGameStateCheck
		j turn
		
		endTurn:
			#lw $t1, activePlayer
			#beq $t1, 0, setRedActive
			#beq $t1, 1, setBlueActive
			beq $s4, 0, setRedActive
			beq $s4, 1, setBlueActive
			setRedActive:
				#li $t2, 1
				#sw $t1, activePlayer
				li $s4, 1
				jal endGameStateCheck
				j turn
			setBlueActive:
				#li $t2, 0
				#sw $t1, activePlayer
				li $s4, 0
				jal endGameStateCheck
				j turn
			
