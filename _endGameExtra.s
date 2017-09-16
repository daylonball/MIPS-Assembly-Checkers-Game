.globl outerPositionsCheck
.globl gameOver


## =================================================================== ##
## ===================( End-game State Test : ext )=================== ##
## =================================================================== ##


.data 
	#index number          0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31	used for testing scenarios
	gameIsNotOver: .asciiz	"the game is not over"
	gameIsOver: .asciiz	" no more possible moves, the game is over"
.text 

	##checks every element of gameStateArray and if there is no more moves available it ends the program
	outerPositionsCheck:
		#declaring "variables". not need but i like to keep track of what im using and what they contain.
		addi $t0, $zero, 0 #used in beq operations to see what is in gameStateArray
		addi $t1, $zero, 0 #will contain index of gameStateArray
		addi $t2, $zero, 0 #will contain the value of what is in the current index of gameStateArray
		# $t3 was in use but was found to be useless
		# $t4 was in use but was found to be useless
		addi $t5, $zero, 0 #used when changing current index, allows for the original index to be maintained
		
		indexSet1: #index 0, 32, 64, 96 (gameStateArray bit numbers)
			addi $t1, $zero, 0 #setting current index
			
			indexSet1_loop:
				beq $t1, 128 indexSet2 #branch to next index set after index 96
				
				#checks to see if current index is empty
				addi $t0, $zero, 0 
				lw $t2, gameStateArray($t1)
				beq $t2, 0, indexSet1_increment #if it is empty increment the index by 32 (next index number) and restart loop
				
				#checks to see if the current index has a blue pawn
				addi $t0, $zero, 1 #change $t0 to be value of blue pawn
				lw $t2, gameStateArray($t1)
				beq $t2, $t0, indexSet1_BP #if it is a blue pawn check to see if it can move/capture
				
				#checks to see if the current index has a blue queen
				addi $t0, $zero, 2 #change $t0 to be value of blue queen
				lw $t2, gameStateArray($t1)
				beq $t2, $t0, indexSet1_BQD #if it is a blue queen check to see if it can move/capture
				
				#checks to see if the current index has a red pawn
				addi $t0, $zero, 3 #change $t0 to be value of red pawn
				lw $t2, gameStateArray($t1)
				beq $t2, $t0, indexSet1_RP #if it is a red pawn check to see if it can move/capture
								
				#checks to see if the current index has a red queen
				addi $t0, $zero, 4 #change $t0 to be value of red queen
				lw $t2, gameStateArray($t1)
				beq $t2, $t0, indexSet1_RQD #if it is a red queen check to see if it can move/capture
				
				#checks to see if a blue pawn can move or capture
				#a blue pawn can only move to index -16 unless it is on index 0, or jump to index -28 unless it is index 0
				indexSet1_BP:
					#checking if the current index is 0 (a blue pawn can not excist in index 0 as it will get promoted to a queen)
					addi $t4, $zero, 0
					beq $t1, $t4, indexSet1_increment
					
					addi $t5, $t1, -16 #increment current index by -16
					
					#checking if index -16 is open 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index -16 is open that means the current index can move and the game can continue
					
					#checking if index -16 has a blue pawn
					addi $t0, $zero, 1 #change $t0 to be the value of a blue pawn
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a blue pawn then the current index can not move, therefore check next index
					
					#checking if index -16 has a blue queen
					addi $t0, $zero, 2 #change $t0 to be the value of a blue queen
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					
					#checking if index -28 is open 
					addi $t5, $t1, -28
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index -128 is open that means the current index can move and the game can continue					
					j indexSet1_increment #else, jump to next index
					
				#checks to see if a blue queen can move or capture
				#a blue queen can move to index -16(unless 0) and +16, or capture to index -28(unless 0) or 36(unless 96)
				indexSet1_BQD:							
					#will now look at index +16
					addi $t5, $t1, 16 
					
					#checking if index +16 is open 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index +16 is open that means the current index can move and the game can continue
					
					#checking if index +16 has a blue pawn
					addi $t0, $zero, 1 #change $t0 to be the value of a blue pawn
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_BQU #if it has a blue pawn then the current index can not move, therefore check if it can move up
					
					#checking if index +16 has a blue queen
					addi $t0, $zero, 2 #change $t0 to be the value of a blue queen
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_BQU #if it has a blue queen then the current index can not move, therefore check if it can move up
							
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
						
					#checking if the +36 index went outside of the board range
					addi $t5, $t1, 36
					addi $t0, $zero, 124
					blt $t0, $t5, indexSet1_increment # if it goes outside boundary go to next index
					
					#checking if index +36 is open  
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index +36 is open that means the current index can move and the game can continue						
					j indexSet1_BQU
				indexSet1_BQU:
					addi $t5, $t1, -16 #look at index -16
					
					#checking if the -16 increment went outside of the board range
					addi $t0, $zero, 0
					blt $t5, $t0, indexSet1_increment
					
					#checking if index -16 is open 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index -16 is open that means the current index can move and the game can continue
					
					#checking if index -16 has a blue pawn
					addi $t0, $zero, 1 #change $t0 to be the value of a blue pawn
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a blue pawn then the current index can not move, therefore check next index
					
					#checking if index -16 has a blue queen
					addi $t0, $zero, 2 #change $t0 to be the value of a blue queen
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					
					#checking if index -28 is open 
					addi $t5, $t1, -28 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index -28 is open that means the current index can move and the game can continue					
					j indexSet1_increment #else check the next index
					
				#checks to see if a red pawn can move or capture
				#a red pawn can move to +16, or jump to +36(unless 96)
				indexSet1_RP: 
					#incrementing index by +16
					addi $t5, $t1, 16 
					
					#checking if index +16 is open 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index +16 is open that means the current index can move and the game can continue
					
					#checking if index +16 has a red pawn
					addi $t0, $zero, 3 #change $t0 to be the value of a red pawn
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a red pawn then the current index can not move, therefore check next index
					
					#checking if index +16 has a red queen
					addi $t0, $zero, 4 #change $t0 to be the value of a red queen
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a red queen then the current index can not move, therefore check next index
							
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
						
					#checking if the +36 index went outside of the board range
					addi $t5, $t1, 36
					addi $t0, $zero, 124
					blt $t0, $t5, indexSet1_increment
					
					#checking if index +36 is open  
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index +36 is open that means the current index can move and the game can continue						
					j indexSet1_increment #else go to next index	
					
				#checks to see if a red queen can move or capture
				#a red queen can move to all indexs that a blue queen can move to
				indexSet1_RQD:
					
					addi $t5, $t1, -16 #look at index -16
					
					#will now look at index +16
					addi $t5, $t1, 16 
					
					#checking if index +16 is open 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index +16 is open that means the current index can move and the game can continue
					
					#checking if index +16 has a red pawn
					addi $t0, $zero, 3 #change $t0 to be the value of a red pawn
					lw $t2, gameStateArray($t5)
					beq $t2, $t0, indexSet1_RQU #if it has a red pawn then the current index can not move, therefore check next index
					
					#checking if index +16 has a red queen
					addi $t0, $zero, 4 #change $t0 to be the value of a red queen
					lw $t2, gameStateArray($t5)
					beq $t2, $t0, indexSet1_RQU #if it has a red queen then the current index can not move, therefore check if it can move up
							
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
						
					#checking if the +36 index went outside of the board range
					addi $t5, $t1, 36
					addi $t0, $zero, 124
					blt $t0, $t5, indexSet1_increment # if it goes outside boundary go to next index
					
					#checking if index +36 is open  
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index +36 is open that means the current index can move and the game can continue						
					j indexSet1_RQU #else check if it can move up					
				indexSet1_RQU:
					#checking if the -16 increment went outside of the board range
					addi $t0, $zero, 0
					blt $t5, $t0, indexSet1_increment
					
					#checking if index -16 is open 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index -16 is open that means the current index can move and the game can continue
					
					#checking if index -16 has a red pawn
					addi $t0, $zero, 3 #change $t0 to be the value of a red pawn
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a red pawn then the current index can not move, therefore check next index
					
					#checking if index -16 has a red queen
					addi $t0, $zero, 4 #change $t0 to be the value of a red queen
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 indexSet1_increment #if it has a red queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					
					#checking if index -28 is open 
					addi $t5, $t1, -28 
					addi $t0, $zero, 0 #change $t0 to be value of a open location
					lw $t2, gameStateArray($t5)
					beq $t2, $t0 continueGame #if index -28 is open that means the current index can move and the game can continue								

				#increments the index number by 32 and restarts the loop
				indexSet1_increment:
					addi $t1, $t1, 32
					j indexSet1_loop
		
		indexSet2: #index 28, 60, 92, 124
			addi $t1, $zero, 28 #setting current index
			
			indexSet2_loop:
				beq $t1, 156 indexSet3 #branch to next index set after index 128
				
				lw $t2, gameStateArray($t1) #place into $t2 what the value of the current index is
				
				#check what is in the current location
				beq $t2, 0, indexSet2_increment #if it is empty increment the index by 32 (next index number) and restart loop
				beq $t2, 1, indexSet2_BP #if it is a blue pawn check to see if it can move/capture
				beq $t2, 2, indexSet2_BQD #if it is a blue queen check to see if it can move/capture
				beq $t2, 3, indexSet2_RP #if it is a red pawn check to see if it can move/capture
				beq $t2, 4, indexSet2_RQD #if it is a red queen check to see if it can move/capture
		
				#checks to see if a blue pawn can move or capture
				#a blue pawn can only move to index -16, or jump to index -36 (unless index 28)
				indexSet2_BP:					
					addi $t5, $t1, -16 #increment current index by -16
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -16 is open that means the current index can move and the game can continue
					beq $t2, 1, indexSet2_increment #if it has a blue pawn then the current index can not move, therefore check next index
					beq $t2, 2, indexSet2_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index -36 is open 
					addi $t5, $t1, -36 #change current index to -36
					blt $t5, 0, indexSet2_increment #if index -36 goes outside of the bounds of the board, check next index
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -36 is open that means the current index can move and the game can continue					
					j indexSet2_increment #else, jump to next index
					
				#checks to see if a blue queen can move or capture
				#a blue queen can move to index -16 and +16(unless 124), or capture to index -36(unless 28) or +28(unless 124)
				indexSet2_BQD:							
					#will now look at index +16
					addi $t5, $t1, 16 #set index +16
					lw $t2, gameStateArray($t5) # obtain value of current index
					
					bgt $t5, 124, indexSet2_BQU #if index +16 goes outside of the bounds of the board, check if it can move up 					
	
					beq $t2, 0, continueGame #if index +16 is open that means the current index can move and the game can continue
					beq $t2, 1, indexSet2_BQU #if it has a blue pawn then the current index can not move, therefore check if it can move up
					beq $t2, 2, indexSet2_BQU #if it has a blue queen then the current index can not move, therefore check if it can move up
					
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index +36 is open  
					addi $t5, $t1, 28
					lw $t2, gameStateArray($t5)
					beq $t2,0, continueGame #if index +36 is open that means the current index can move and the game can continue						
					j indexSet2_BQU #else check if it can move up
					
				indexSet2_BQU:
					addi $t5, $t1, -16 #look at index -16
					lw $t2, gameStateArray($t5) # set value of current index
					
					beq $t2, 0, continueGame #if index -16 is open that means the current index can move and the game can continue
					beq $t2, 1, indexSet2_increment #if it has a blue pawn then the current index can not move, therefore check next index
					beq $t2, 2, indexSet2_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index -28 is open 
					addi $t5, $t1, -36 #set to index -28
					blt $t5, 1 indexSet2_increment # if it is out of bounds the go to next index
					
					lw $t2, gameStateArray($t5)# set value of current index
					beq $t2, 0 continueGame #if index -28 is open that means the current index can move and the game can continue					
					j indexSet2_increment #else check the next index
					
				#checks to see if a red pawn can move or capture
				#a red pawn can move to +16(unless 124, or jump to +28(unless 124)
				indexSet2_RP: 
					addi $t5, $t1, 16  #incrementing index by +16
					bgt $t5, 124, indexSet2_increment 
					lw $t2, gameStateArray($t5)# set value of current index
				
					beq $t2, 0,  continueGame #if index +16 is open that means the current index can move and the game can continue
					beq $t2, 3, indexSet2_increment #if it has a red pawn then the current index can not move, therefore check next index
					beq $t2, 4, indexSet2_increment #if it has a red queen then the current index can not move, therefore check next index
							
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if the +28 index went outside of the board range
					addi $t5, $t1, 28
					bgt $t5, 124, indexSet2_increment #if the index is out of bounds go to next index
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0 continueGame #if index +36 is open that means the current index can move and the game can continue						
					j indexSet2_increment #else go to next index	
					
				#checks to see if a red queen can move or capture
				#a red queen can move to all indexs that a blue queen can move to
				indexSet2_RQD:							
					#will now look at index +16
					addi $t5, $t1, 16 #set index +16
					lw $t2, gameStateArray($t5) # obtain value of current index
					
					bgt $t5, 124, indexSet2_RQU #if index +16 goes outside of the bounds of the board, check if it can move up 					
	
					beq $t2, 0, continueGame #if index +16 is open that means the current index can move and the game can continue
					beq $t2, 3, indexSet2_RQU #if it has a red pawn then the current index can not move, therefore check if it can move up
					beq $t2, 4, indexSet2_RQU #if it has a red queen then the current index can not move, therefore check if it can move up
					
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index +36 is open  
					addi $t5, $t1, 28
					lw $t2, gameStateArray($t5)
					beq $t2,0, continueGame #if index +36 is open that means the current index can move and the game can continue						
					j indexSet2_RQU #else check if it can move up
					
				indexSet2_RQU:
					addi $t5, $t1, -16 #look at index -16
					lw $t2, gameStateArray($t5) # set value of current index
					
					beq $t2, 0, continueGame #if index -16 is open that means the current index can move and the game can continue
					beq $t2, 3, indexSet2_increment #if it has a blue pawn then the current index can not move, therefore check next index
					beq $t2, 4, indexSet2_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index -28 is open 
					addi $t5, $t1, -36 #set to index -28
					blt $t5, 1 indexSet2_increment # if it is out of bounds then go to next index
					
					lw $t2, gameStateArray($t5)# set value of current index
					beq $t2, 0 continueGame #if index -28 is open that means the current index can move and the game can continue					
					j indexSet2_increment #else check the next index
							
				#increments the index number by 32 and restarts the loop
				indexSet2_increment:
					addi $t1, $t1, 32
					j indexSet2_loop
							

		indexSet3: #index 4, 8, 12
			addi $t1, $zero, 4 #setting current index
			
			indexSet3_loop:
				beq $t1, 16 indexSet4 #branch to next index set after index 16
				
				lw $t2, gameStateArray($t1) #place into $t2 what the value of the current index is
				
				#check what is in the current location
				beq $t2, 0, indexSet3_increment #if it is empty increment the index by 4 (next index number) and restart loop
				beq $t2, 1, indexSet3_BPR #if it is a blue pawn check to see if it can move/capture
				beq $t2, 2, indexSet3_BPR #if it is a blue queen check to see if it can move/capture
				beq $t2, 3, indexSet3_RPR #if it is a red pawn check to see if it can move/capture
				beq $t2, 4, indexSet3_RPR #if it is a red queen check to see if it can move/capture
		
				#checks to see if either a blue pawn or blue queen can move right(if a blue pawn is in this location it will be promoted to a queen)
				#can move right +16 or jump to +36(unless 12)
				indexSet3_BPR:					
					addi $t5, $t1, 16 #increment current index by 16
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +16 is open that means the current index can move and the game can continue
					beq $t2, 1, indexSet3_BPL #if it has a blue pawn then the current index can not move, therefore check if it can move left
					beq $t2, 2, indexSet3_BPL #if it has a blue queen then the current index can not move, therefore check if it can move left
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index +36 is open 
					addi $t5, $t1, 36 #change current index to +36
					bgt $t5, 45, indexSet3_BPL #if index +36 goes outside of the bounds of the board, check if it can move left
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +36 is open that means the current index can move and the game can continue					
					j indexSet3_BPL #else, see if it can move left
					
				#can move left +12 or jump +28	
				indexSet3_BPL:					
					addi $t5, $t1, 12 #increment current index by 12
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +12 is open that means the current index can move and the game can continue
					beq $t2, 1, indexSet3_increment #if it has a blue pawn then the current index can not move, therefore check next index
					beq $t2, 2, indexSet3_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index +28 is open 
					addi $t5, $t1, 28 #change current index to +28
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +28 is open that means the current index can move and the game can continue					
					j indexSet3_increment #else, next index
					
				#checks if a red pawn or red queen can move( they have the same movement)
				#can move to all locations a blue piece can move to	
				indexSet3_RPR:					
					addi $t5, $t1, 16 #increment current index by 16
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +16 is open that means the current index can move and the game can continue
					beq $t2, 3, indexSet3_RPL #if it has a red pawn then the current index can not move, therefore check if it can move left
					beq $t2, 4, indexSet3_RPL #if it has a red queen then the current index can not move, therefore check if it can move left
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index +36 is open 
					addi $t5, $t1, 36 #change current index to +36
					bgt $t5, 45, indexSet3_BPR #if index +36 goes outside of the bounds of the board, check if it can move left
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +36 is open that means the current index can move and the game can continue					
					j indexSet3_BPL #else, see if it can move left
					
				#can move left +12 or jump +28	
				indexSet3_RPL:					
					addi $t5, $t1, 12 #increment current index by 12
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +12 is open that means the current index can move and the game can continue
					beq $t2, 3, indexSet3_increment #if it has a blue pawn then the current index can not move, therefore check next index
					beq $t2, 4, indexSet3_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index +28 is open 
					addi $t5, $t1, 28 #change current index to +28
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index +28 is open that means the current index can move and the game can continue					
					j indexSet3_increment #else, next index
							
				#increments the index number by 4 and restarts the loop
				indexSet3_increment:
					addi $t1, $t1, 4
					j indexSet3_loop
		
		indexSet4: #index 112. 116. 120
			addi $t1, $zero, 112 #setting current index
			
			indexSet4_loop:
				beq $t1, 124, gameOver #if no pieces can move then the game is over
				
				lw $t2, gameStateArray($t1) #place into $t2 what the value of the current index is
				
				#check what is in the current location
				beq $t2, 0, indexSet4_increment #if it is empty increment the index by 4 (next index number) and restart loop
				beq $t2, 1, indexSet4_BPR #if it is a blue pawn check to see if it can move/capture
				beq $t2, 2, indexSet4_BPR #if it is a blue queen check to see if it can move/capture
				beq $t2, 3, indexSet4_RPR #if it is a red pawn check to see if it can move/capture
				beq $t2, 4, indexSet4_RPR #if it is a red queen check to see if it can move/capture
		
				#checks to see if either a blue pawn or blue queen can move right(if a blue pawn is in this location it will be promoted to a queen)
				#can move right -12 or jump to -28
				indexSet4_BPR:					
					addi $t5, $t1, -12 #increment current index by -12
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -12 is open that means the current index can move and the game can continue
					beq $t2, 1, indexSet4_BPL #if it has a blue pawn then the current index can not move, therefore check if it can move left
					beq $t2, 2, indexSet4_BPL #if it has a blue queen then the current index can not move, therefore check if it can move left
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index -28 is open 
					addi $t5, $t1, -28 #change current index to -28
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -28 is open that means the current index can move and the game can continue					
					j indexSet4_BPL #else, see if it can move left
					
				#can move left -16 or jump -36(unless 112)	
				indexSet4_BPL:					
					addi $t5, $t1, -16 #increment current index by -16
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -16 is open that means the current index can move and the game can continue
					beq $t2, 1, indexSet4_increment #if it has a blue pawn then the current index can not move, therefore check next index
					beq $t2, 2, indexSet4_increment #if it has a blue queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index -36 is open 
					addi $t5, $t1, -36 #change current index to -36
					blt $t5, 79, indexSet4_increment #if the index goes outside the bounds check next index
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -36 is open that means the current index can move and the game can continue					
					j indexSet4_increment #else, next index
					
				#checks if a red pawn or red queen can move( they have the same movement)
				#can move to all locations a blue piece can move to	
				indexSet4_RPR:					
					addi $t5, $t1, -12 #increment current index by -12
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -12 is open that means the current index can move and the game can continue
					beq $t2, 3, indexSet4_RPL #if it has a red pawn then the current index can not move, therefore check if it can move left
					beq $t2, 4, indexSet4_RPL #if it has a red queen then the current index can not move, therefore check if it can move left
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index -28 is open 
					addi $t5, $t1, -28 #change current index to -28
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -28 is open that means the current index can move and the game can continue					
					j indexSet4_RPL #else, see if it can move left
					
				#can move left -16 or jump -36(unless 112)	
				indexSet4_RPL:					
					addi $t5, $t1, -16 #increment current index by -16
					
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -16 is open that means the current index can move and the game can continue
					beq $t2, 3, indexSet4_increment #if it has a red pawn then the current index can not move, therefore check next index
					beq $t2, 4, indexSet4_increment #if it has a red queen then the current index can not move, therefore check next index
				
					#this means an enemy piece is currently in the location, therefore check to see if you can capture it
					#checking if index -36 is open 
					addi $t5, $t1, -36 #change current index to -36
					blt $t5, 79, indexSet4_increment #if the index goes outside the bounds check next index
					lw $t2, gameStateArray($t5)
					beq $t2, 0, continueGame #if index -36 is open that means the current index can move and the game can continue					
					j indexSet4_increment #else, next index
							
				#increments the index number by 4 and restarts the loop
				indexSet4_increment:
					addi $t1, $t1, 4
					j indexSet4_loop		
			
			#no more possible moves, therefore the game ends
			gameOver:
			li $v0, 4
			la $a0, gameIsOver
			syscall
			
			li $v0, 10
			syscall
			
			continueGame:
			jr $ra
	
	
	
	
	
	
	
	
