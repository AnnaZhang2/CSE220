# CSE 220 Programming Project #3
# Anna Zhang
# zhang127
# 112167606

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
initialize:
	addi $sp, $sp, -8
	sw $s1, ($sp)
	sw $s2, 4($sp)
	
	move $s1, $a1 # num_rows
	move $s2, $a2 # num_cols
	
	# check for error
	blez $s1, return_neg
	blez $s2, return_neg
	j save_return_values
	
	return_neg:
		li $v0, -1
		li $v1, -1
		j initialize_return
	
	save_return_values:
		move $v0, $s1
		move $v1, $s2
	
	# num of times looping
	mul $t0, $s1, $s2
	
	# save rows and cols to struct
	sb $s1, ($a0)
	sb $s2, 1($a0)
	addi $a0, $a0, 2
	
	li $t1, 0 # counter
	save_to_struct:
		sb $a3, ($a0)
		addi $t1, $t1, 1
		addi $a0, $a0, 1
		beq $t1, $t0, initialize_return
		j save_to_struct
	
	initialize_return:
		lw $s1, ($sp)
		lw $s2, 4($sp)
		addi $sp, $sp, 8
		jr $ra

load_game:
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	move $s0, $a0 # state
	move $s1, $a1 # filename
	
	#open file
	li $v0, 13 # syscall value for open file
	move $a0, $a1 # filename
	li $a1, 0 # read only
	li $a2, 0 # mode (ignored)
	syscall
	
	li $t7, 0
	bltz $v0, return_file_error_l
	li $t7, 1
	
	# move everything back
	move $a0, $s0
	move $a1, $s1
	move $s2, $v0
	
	# read from file
	li $t0, '\n'
	
	# get row
	addi $sp, $sp, -1
	li $v0, 14 # syscall value to read from file
	move $a0, $s2 # file descriptor
	move $a1, $sp # input buffer
	li $a2, 1 # read one character at a time
	syscall
	
	lb $s3, ($sp) # $s3 has the first digit of row
	addi $sp, $sp, 1 # reset
	
	addi $sp, $sp, -1
	li $v0, 14 # syscall value to read from file
	move $a0, $s2 # file descriptor
	move $a1, $sp # input buffer
	li $a2, 1 # read one character at a time
	syscall
	
	lb $t1, ($sp) # $t1 has the second "digit" of row
	addi $sp, $sp, 1 # reset
	
	bne $t1, $t0, get_row # if the second "digit" isn't '\n', get row
	addi $s3, $s3, -48 # get the actual value
	sb $s3, ($s0)
	j read_for_col
	
	get_row: # knows it's 2 digits at this point, so read again for '\n'
		addi $s3, $s3, -48 # get the actual value
		addi $t1, $t1, -48
		li $t2, 10
		mul $s3, $s3, $t2 # multiply the first digit by 10
		add $s3, $s3, $t1 # add the first digit to the second digit
		sb $s3, ($s0)
		
		#read '\n'
		addi $sp, $sp, -1
		li $v0, 14 # syscall value to read from file
		move $a0, $s2 # file descriptor
		move $a1, $sp # input buffer
		li $a2, 1 # read one character at a time
		syscall

		addi $sp, $sp, 1 # reset
		
	read_for_col:
		#get first digit
		addi $sp, $sp, -1
		li $v0, 14 # syscall value to read from file
		move $a0, $s2 # file descriptor
		move $a1, $sp # input buffer
		li $a2, 1 # read one character at a time
		syscall
		
		lb $s4, ($sp) # $s4 has the first digit of col
		addi $sp, $sp, 1 # reset
		
		#get first digit
		addi $sp, $sp, -1
		li $v0, 14 # syscall value to read from file
		move $a0, $s2 # file descriptor
		move $a1, $sp # input buffer
		li $a2, 1 # read one character at a time
		syscall
		
		lb $t1, ($sp) # $t1 has the second "digit" of col
		addi $sp, $sp, 1 # reset
		
		bne $t1, $t0, get_col # if $t1 != '\n', get the actual value
		
		addi $s4, $s4, -48
		sb $s4, 1($s0)
		j start_load_game
		
		get_col:
			addi $s4, $s4 -48 # get actual value
			addi $t1, $t1, -48
			li $t2, 10
			mul $s4, $s4, $t2 # multiply first digit by 10
			add $s4, $s4, $t1 # add first digit and second digit
			sb $s4, 1($s0)
			
			#read '\n'
			addi $sp, $sp, -1
			li $v0, 14 # syscall value to read from file
			move $a0, $s2 # file descriptor
			move $a1, $sp # input buffer
			li $a2, 1 # read one character at a time
			syscall

			addi $sp, $sp, 1 # reset
		
		start_load_game:
			addi $s0, $s0, 2
			#declare constants
			li $t0, 'O'
			li $t1, '.'
			li $t2, '\n'
			li $t3, 1 # counter
			li $t6, 0 # num of O's read
			li $t5, 0 # num of invalid read
			
			#read
			inner_loop_l: # in charge of cols
				#get character
				addi $sp, $sp, -1
				li $v0, 14 # syscall value to read from file
				move $a0, $s2 # file descriptor
				move $a1, $sp # input buffer
				li $a2, 1 # read one character at a time
				syscall
	
				lbu $t4, ($sp) # $t4 has the character
				addi $sp, $sp, 1 # reset
					
				#check
				beq $t4, $t2, continue_outer_loop_l # if char = '\n', go to check for outer_loop_l
				beq $t4, $t0, save_to_state_O
				beq $t4, $t1, save_to_state_valid
					
				#save invalid
				sb $t1, ($s0)
				addi $s0, $s0, 1
				addi $t5, $t5, 1 # increment invalid
					
				j inner_loop_l
					
				save_to_state_O:
					sb $t4, ($s0)
					addi $s0, $s0, 1
					addi $t6, $t6, 1 # increment O's
					j inner_loop_l
					
				save_to_state_valid:
					sb $t4, ($s0)
					addi $s0, $s0, 1
					j inner_loop_l
					
				continue_outer_loop_l:
					addi $t3, $t3, 1
					beq $t3, $s3, inner_loop_l_2 # if outer loop looped row times, end
					j inner_loop_l
					
			inner_loop_l_2:
				#get character
				addi $sp, $sp, -1
				li $v0, 14 # syscall value to read from file
				move $a0, $s2 # file descriptor
				move $a1, $sp # input buffer
				li $a2, 1 # read one character at a time
				syscall
	
				lbu $t4, ($sp) # $t4 has the character
				addi $sp, $sp, 1 # reset
					
				#check
				beq $t4, $t0, save_to_state_O_2
				beq $t4, $t1, save_to_state_valid_2
					
				#save invalid
				sb $t1, ($s0)
				addi $s0, $s0, 1
				addi $t5, $t5, 1 # increment invalid
				addi $s4, $s4, -1
				beqz $s4, close_file
				j inner_loop_l_2
					
				save_to_state_O_2:
					sb $t4, ($s0)
					addi $s0, $s0, 1
					addi $t6, $t6, 1 # increment O's
					addi $s4, $s4, -1
					beqz $s4, close_file
					j inner_loop_l_2
					
				save_to_state_valid_2:
					sb $t4, ($s0)
					addi $s0, $s0, 1
					addi $s4, $s4, -1
					beqz $s4, close_file
					j inner_loop_l_2
	
	# close the file
	close_file:
		li $v0, 16 # syscall value to close file
		move $a0, $s2 # file descriptor
		syscall
		
	beqz $t7, return_file_error_l
	move $v0, $t6
	move $v1, $t5
	j load_game_end
	return_file_error_l:
		li $v0, -1
		li $v1, -1
		
	load_game_end:
	# move everything back
	move $a0, $s0
	move $a0, $s1
	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
    jr $ra

get_slot:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s2, $a0
	
	# get given row and col
	lb $s0, ($s2) # $s0 contains given_row
	lb $s1, 1($s2) # $s1 contains given_col
	# check for any potential errors in given row and col
	bltz $s0, return_error_get
	bltz $s1, return_error_get
	
	# check for any potential errors in desired row and col
	bltz $a1, return_error_get
	bge $a1, $s0, return_error_get

	bltz $a2, return_error_get
	bge $a2, $s1, return_error_get
	
	# calculations to get to destination
	addi $t2, $a1, 1 # increment row by 1
	mul $t0, $s1, $t2 # multiply given_col and (desired_row + 1)
	addi $t1, $s1, -1 # subtract given_col by 1
	sub $t0, $t0, $t1 # $t0 has num of times to move (given_col * (desired_row + 1) - (given_col-1)
	
	add $s2, $s2, $t0 # move to the desired row
	
	addi $t1, $a2, 1
	add $s2, $s2, $t1 # move to the (desired col + 1)
	
	lb $v0, ($s2)
	j get_slot_end
	
	return_error_get:
		li $v0, -1
	
	get_slot_end:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
    	jr $ra

set_slot:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s2, $a0
	
	# get given row and col
	lb $s0, ($s2) # $s0 contains given_row
	lb $s1, 1($s2) # $s1 contains given_col
	# check for any potential errors in given row and col
	bltz $s0, return_error_set
	bltz $s1, return_error_set
	
	# check for any potential errors in desired row and col
	bltz $a1, return_error_set
	bge $a1, $s0, return_error_set

	bltz $a2, return_error_set
	bge $a2, $s1, return_error_set
	
	# calculations to get to destination
	addi $t2, $a1, 1 # increment row by 1
	mul $t0, $s1, $t2 # multiply given_col and (desired_row + 1)
	addi $t1, $s1, -1 # subtract given_col by 1
	sub $t0, $t0, $t1 # $t0 has num of times to move (given_col * (desired_row + 1) - (given_col-1)
	
	add $s2, $s2, $t0 # move to the desired row
	
	addi $t1, $a2, 1
	add $s2, $s2, $t1 # move to the (desired col + 1)
	sb $a3, ($s2)
	
	lb $v0, ($s2)
	j set_slot_end
	
	return_error_set:
		li $v0, -1
	
	set_slot_end:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
    	jr $ra

rotate:
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	bltz $a1, return_error_r
	beqz $a1, return_original
	
	move $s1, $a1
	li $a1, -1
	jal get_slot
	jal set_slot
	move $a1, $s1
	
	j check_bytes
	return_original:
		lb $t5, ($a0)
		sb $t5, ($a2)
		lb $t5, 1($a0)
		sb $t5, 1($a2)
		
		lb $t5 2($a0)
		sb $t5, 2($a2)
		lb $t5, 3($a0)
		sb $t5, 3($a2)
		lb $t5, 4($a0)
		sb $t5, 4($a2)
		lb $t5, 5($a0)
		sb $t5, 5($a2)
		lb $t5, 6($a0)
		sb $t5, 6($a2)
		lb $t5, 7($a0)
		sb $t5, 7($a2)
		
		move $v0, $a1
		
		j rotate_end
	
	check_bytes:
		move $s0, $a0
		move $s1, $a1
		move $s2, $a2
	
		lbu $t0, ($s0)
		lbu $t1, 1($s0)
	
		#check if it's an O piece
		li $t2, 2
		beq $t0, $t2, check_if_sec_2
	
		#check if it's an I piece
		li $t2, 1
		beq $t0, $t2, check_if_sec_4
		li $t2, 4
		beq $t0, $t2, check_if_sec_1
	
	# other pieces
	check_other_pieces:
		li $t2, 4
		div $a1, $t2 # divide rotation by 4
		mfhi $t3 # remainder
		beqz $t3, return_original # if remainder is a multiple of 4, don't rotate and return original
		li $t2, 2
		beq $t3, $t2, switch_2
		li $t2, 1
		
		lb $t5, ($a0)
		sb $t5, 1($a2)
		lb $t5, 1($a0)
		sb $t5, ($a2)
		
		beq $t3, $t2, switch_1
		
	switch_3:
		li $t2, 2
		beq $t0, $t2, switch_2_3_3
		
		lb $t5, 3($a0)
		sb $t5, 2($a2)
		lb $t5, 5($a0)
		sb $t5, 3($a2)
		lb $t5, 7($a0)
		sb $t5, 4($a2)
		lb $t5, 2($a0)
		sb $t5, 5($a2)
		lb $t5, 4($a0)
		sb $t5, 6($a2)
		lb $t5, 6($a0)
		sb $t5, 7($a2)
		j switch_3_done
		
		switch_2_3_3:
			lb $t5, 4($a0)
			sb $t5, 2($a2)
			lb $t5, 7($a0)
			sb $t5, 3($a2)
			lb $t5, 3($a0)
			sb $t5, 4($a2)
			lb $t5, 6($a0)
			sb $t5, 5($a2)
			lb $t5, 2($a0)
			sb $t5, 6($a2)
			lb $t5, 5($a0)
			sb $t5, 7($a2)
		
		switch_3_done:
			move $v0, $a1
			j rotate_end
		
	switch_1:
		li $t2, 2
		beq $t0, $t2, switch_2_3_1
		
		lb $t5, 6($a0)
		sb $t5, 2($a2)
		lb $t5, 4($a0)
		sb $t5, 3($a2)
		lb $t5, 2($a0)
		sb $t5, 4($a2)
		lb $t5, 7($a0)
		sb $t5, 5($a2)
		lb $t5, 5($a0)
		sb $t5, 6($a2)
		lb $t5, 3($a0)
		sb $t5, 7($a2)
		j switch_1_done
		
		switch_2_3_1:
			lb $t5, 5($a0)
			sb $t5, 2($a2)
			lb $t5, 2($a0)
			sb $t5, 3($a2)
			lb $t5, 6($a0)
			sb $t5, 4($a2)
			lb $t5, 3($a0)
			sb $t5, 5($a2)
			lb $t5, 7($a0)
			sb $t5, 6($a2)
			lb $t5, 4($a0)
			sb $t5, 7($a2)
		
		switch_1_done:
			move $v0, $a1
			j rotate_end
	
	switch_2:
		lb $t5, ($a0)
		sb $t5, ($a2)
		lb $t5, 1($a0)
		sb $t5, 1($a2)

		lb $t5, 7($a0)
		sb $t5, 2($a2)
		lb $t5, 6($a0)
		sb $t5, 3($a2)
		lb $t5, 5($a0)
		sb $t5, 4($a2)
		lb $t5, 4($a0)
		sb $t5, 5($a2)
		lb $t5, 3($a0)
		sb $t5, 6($a2)
		lb $t5, 2($a0)
		sb $t5, 7($a2)
		
		move $v0, $a1
		j rotate_end
	
	check_if_sec_4:
		li $t2, 4
		beq $t1, $t2, rotate_I
		j return_error_r
		
	check_if_sec_1:
		li $t2, 1
		beq $t1, $t2, rotate_I
		j return_error_r
		
	rotate_I:
		li $t2, 4
		div $a1, $t2 # divide rotation by 4
		mfhi $t3 # remainder
		
		li $t2, 2
		beq $t3, $t2, return_same_I # check if remainder is a 2
		
		# switch 1 and 4
		move $a0, $a2 # rotated piece into struct
		move $a1, $t1 # second_byte into num_rows
		move $a2, $t0 # first_byte into num_cols
		li $a3, 'O' # character
			
		jal initialize
			
		move $a2, $a0 # move struct into rotated_piece
		# move everything back
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
			
		j return_O_I
		
		return_same_I:
			move $a0, $a2 # rotated piece into struct
			move $a1, $t0 # first_byte into num_rows
			move $a2, $t1 # second_byte into num_cols
			li $a3, 'O' # character
			
			jal initialize
			
			move $a2, $a0 # move struct into rotated_piece
			# move everything back
			move $a0, $s0
			move $a1, $s1
			move $a2, $s2
			move $a3, $s3
			
			j return_O_I
	
	check_if_sec_2:
		bne $t1, $t2,check_other_pieces
	 
	 return_O:
	 	li $t2, '.'
	 	move $a0, $a2 # rotated piece into struct
		move $a1, $t0 # first_byte into num_rows
		move $a2, $t1 # second_byte into num_cols
		li $a3, 'O' # character
			
		jal initialize
			
		move $a2, $a0 # move struct into rotated_piece
		# move everything back
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
		
		return_O_I:
			li $t2, '.'
			sb $t2, 6($a2)
			sb $t2, 7($a2)
			move $v0, $a1
			j rotate_end
	 
	 return_error_r:
	 	li $v0, -1
	 
	 rotate_end:
	 	lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20
		
    	jr $ra

count_overlaps:
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# check if values are invalid
	bltz $a1, return_error_c # if row of piece is negative, error
	lb $t1, ($s0)
	bge $a1, $t1, return_error_c # if row of piece is greater than and equal to row of state, error
	bltz $a2, return_error_c # if col of piece is negative, error
	lb $t2, 1($s0)
	bge $a2, $t2, return_error_c # if col of piece is greater than and equal to col of state
	
	lb $t3, ($s3) # row of piece
	lb $t4, 1($s3) # col of piece
	
	# check if part of the piece is outside the bound
	add $t0, $s1, $t3 # add given row to row of piece
	bgt $t0, $t1, return_error_c
	add $t0, $s2, $t4 # add given col to col of piece
	bgt $t0, $t2, return_error_c
	
	addi $s3, $s3, 2
	
	li $s4, 0 # counter for inner loop
	li $s5, 0 # counter for outer loop
	li $s6, 0 # counter for # of overlaps
	li $t5, 'O'
	
	move $t6, $s1 # move given row to $t6
	move $t7, $s2 # move given col to $t7
	 
	overlap_loop:
		# check if character of piece is 'O'
		lbu $t9, ($s3)
		beq $t9, $t5, check_state_character
		j increment_inner
		check_state_character:
			move $a1, $t6
			move $a2, $t7
			jal get_slot
			# move everything back
			move $a0, $s0
			move $a1, $s1
			move $a2, $s2

			beq $v0, $t5, increment_overlap
			j increment_inner
			
		increment_overlap:
				addi $s6, $s6, 1
				
		increment_inner:
			addi $s4, $s4, 1 # increment inner counter
			addi $t7, $t7, 1 # increment col counter
			addi $s3, $s3, 1 # move along piece
			beq $s4, $t4, increment_outer
			j overlap_loop
			
		increment_outer:
			addi $s5, $s5, 1 # increment outer counter
			move $t7, $s2 # reset col counter
			li $s4, 0
			addi $t6, $t6, 1 # increment row counter
			beq $s5, $t3, return_overlaps
			j overlap_loop
		
	return_overlaps:
		move $v0, $s6
		j counter_overlaps_end
	
	return_error_c:
		li $v0, -1
		
	counter_overlaps_end:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		addi $sp, $sp, 32
				
		jr $ra

drop_piece:
	#get rotated_piece from stack
	lw $t0, ($sp)
	
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	move $s0, $a0 # state
	move $s1, $a1 # col
	move $s2, $a2 # piece
	move $s3, $a3 # rotation
	move $s4, $t0
	
	bltz $s3, return_neg_2 # if rotation is negative, return -2
	bltz $s1, return_neg_2 # if col is negative, return -2
	lb $s5, 1($s0) # state.col
	bge $s1, $s5, return_neg_2 # if col is greater than or equal to state.col, return -2
	
	# call rotate
	move $a0, $s2 # piece
	move $a1, $s3 # rotation
	move $a2, $s4 # rotated piece
	
	jal rotate
	
	move $s4, $a2 # move rotated piece from $a0 to $s4
	# move everything back
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	
	lb $t0, 1($s4) # get rotated_piece.col
	add $t1, $t0, $s1
	bgt $t1, $s5, return_neg_3
	
	li $s6, 0 # row
	drop_piece_loop:
		move $a0, $s0 # state
		move $a1, $s6 # row
		move $a2, $s1 # given col
		move $a3, $s4 # rotated piece
		
		jal count_overlaps
		
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
		
		beqz $v0, continue_loop # if $v0 = 0, keep looping until nonzero
		addi $s6, $s6, -1
		bltz $s6, return_neg_1
		
		lb $t8, ($s4) # piece.row
		lb $t9, 1($s4) # piece.col
		addi $s4, $s4, 2 # move along piece
		
		li $t5, 'O'
		move $t6, $s6 # move topmost row to $t6
		move $t7, $s1 # move leftmost col to $t7
		li $s5, 0 # inner counter
		li $s7, 0 # outer counter
		
		move $s1, $a1
		li $a1, -1
		jal get_slot
		move $a1, $s1
	
		d_write_loop:
			# check if character of piece is 'O'
			lbu $t4, ($s4)
			beq $t4, $t5, write_d # if char.piece is 'O', write to struct
			j increment_inner_d # if not, move on
			
			write_d:
				move $a1, $t6 # row
				move $a2, $t7 # col
				li $a3, 'O'
				jal set_slot
				# move everything back
				move $a1, $s1
				move $a2, $s2
				move $a3, $s3
				
			increment_inner_d:
				addi $s5, $s5, 1 # increment inner counter
				addi $t7, $t7, 1 # increment col counter
				addi $s4, $s4, 1 # move along piece
				beq $s5, $t9, increment_outer_d
				j d_write_loop
			
			increment_outer_d:
				addi $s7, $s7, 1 # increment outer counter
				move $t7, $s1 # reset col counter
				li $s5, 0 # reset inner counter
				addi $t6, $t6, 1 # increment row counter
				beq $s7, $t8, return_row
				j d_write_loop
				
		return_row:
			move $v0, $s6
			j drop_piece_end
		
		continue_loop:
			addi $s6, $s6, 1 # increment row
			j drop_piece_loop
	
	return_neg_1:
		li $v0, -1
		j drop_piece_end
		
	return_neg_3:
		li $v0, -3
		j drop_piece_end
	
	return_neg_2:
		li $v0, -2
		
	drop_piece_end:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36
		jr $ra

check_row_clear:
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	# save everything in s registers
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	bltz $s1, return_row_error
	lb $t0, ($s0) # state.row
	bge $s1, $t0, return_row_error # if given row is greater than or equal to state.row, error
	
	li $t3, 'O'
	li $t4, 0 # for col
	lb $t5, 1($s0) # state.col
	check_row_full_loop:
		move $a2, $t4
		jal get_slot
		move $a2, $s2
		
		beq $v0, $t3, continue_row_full_loop # if the character is 'O', keep looping
		j return_row_0
		continue_row_full_loop: # increment
			addi $t4, $t4, 1 # increment col
			#check if col goes out of bound
			bge $t4, $t5, clear_row # if col is greater than or equal to state.col, the row is full
			j check_row_full_loop
			
	clear_row:
		move $t3, $s1 # $t3 has the given row
		move $t6, $s1 # $t6 also has the given row 
		addi $t3, $t3, -1 # $t3 has given row - 1
		li $t4, 0 # col
		
		clear_row_loop:
			beqz $t6, set_row_dot
			
			move $a1, $t3
			move $a2, $t4
			jal get_slot # get the character at (row-1, col)
			move $a1, $t6
			# keep $a2 the same, since still need it as col for set_slot
			
			move $a3, $v0 # move the character returned from get_slot into $a3
			jal set_slot
			move $a1, $s1
			move $a2, $s2
			move $a3, $s3
			
			addi $t4, $t4, 1 # increment col
			bge $t4, $t5, reset_clear # if given row is greater than or equal to state.col, reset the col and decrement row
			j clear_row_loop # otherwise, continue looping
			
			reset_clear:
				addi $t6, $t6, -1 # decrement row
				addi $t3, $t3, -1 # decrement row-1
				li $t4, 0 # reset col to 0
				j clear_row_loop
				
			set_row_dot:
				li $a1, 0
				move $a2, $t4
				li $a3, '.'
				jal set_slot
				move $a1, $s1
				move $a2, $s2
				move $a3, $s3
				addi $t4, $t4, 1
				bge $t4, $t5, return_row_cleared # if given row is greater than or equal to state.col, return
				j set_row_dot # otherwise, keep looping
				
	return_row_cleared:
		li $v0, 1
		j check_row_clear_end
		
	return_row_0:
		li $v0, 0
		j check_row_clear_end
	return_row_error:
		li $v0, -1
	
	check_row_clear_end:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20
		jr $ra

simulate_game:
	lw $t0, ($sp) # num_pieces_to_drop
	lw $t1, 4($sp) # pieces_array
	
	addi $sp, $sp, -36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	move $s0, $a0 # state
	move $s1, $a1 # filename
	move $s2, $a2 # moves
	move $s3, $a3 # rotated_piece
	move $s4, $t0 # num_piece_to_drop
	move $s5, $t1 # pieces_array
	
	jal load_game
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	
	bltz $v0, return_0_s # if $v0 is -1, return 0, 0
	bltz $v1, return_0_s # if $v1 is -1, return 0, 0
	
	li $s6, 0 # num of pieces successfully dropped (num_successful_drops)
	li $t0, 0 # num of pieces attempted to drop so far (move_number)
	
	li $t1, 0 # len(move)/4 (moves_length)
	calculate_num_of_moves:
		lb $t2, ($s2)
		beqz $t2, calculate_end
		addi $t1, $t1, 1
		addi $s2, $s2, 4
		j calculate_num_of_moves
		
	calculate_end:
	move $s2, $a2
	li $t2, 0 # game_over set to FALSE (game_over)
	li $s7, 0 # score
	
	simulate_game_loop:
		bnez $t2, end_game # if game_over == TRUE (1), end game
		bge $s6, $s4, end_game # if num_successful_drops >= num_pieces_to_drop, end game
		bge $t0, $t1, end_game # if move_number >= moves_length, end game
		
		#extract next piece, column and rotation from the string
		lbu $t3, ($s2) # piece_type
		lbu $t5, 1($s2) # rotation
		addi $t5, $t5, -48 # get the actual value
		lbu $t6, 2($s2) # col
		addi $t6, $t6, -48
		beqz $t6, get_last_char # check if third char is 0, if yes, reinitialize to the fourth char
		
		li $t7, 10
		mul $t6, $t6, $t7 # multiply third char by 10
		lbu $t7, 3($s2) # get the fourth char
		addi $t7, $t7, -48
		add $t6, $t6, $t7 # add third_char *10 + fourth_char
		j skip_last_char
		get_last_char:
			lbu $t6, 3($s2)
			addi $t6, $t6, -48
			
		skip_last_char:
		li $t7, 0 # invalid
		li $t4, 'T'
		beq $t3, $t4, get_T
		li $t4, 'J'
		beq $t3, $t4, get_J
		li $t4, 'Z'
		beq $t3, $t4, get_Z
		li $t4, 'O'
		beq $t3, $t4, get_O
		li $t4, 'S'
		beq $t3, $t4, get_S
		li $t4, 'L'
		beq $t3, $t4, get_L
		li $t4, 'I'
		beq $t3, $t4, get_I
		
		get_T:
			li $t8, 0
			j s_continue
		get_J:
			li $t8, 8
			add $s5, $s5, $t8
			j s_continue
		get_Z:
			li $t8, 16
			add $s5, $s5, $t8
			j s_continue
		get_O:
			li $t8, 24
			add $s5, $s5, $t8
			j s_continue
		get_S:
			li $t8, 32
			add $s5, $s5, $t8
			j s_continue
		get_L:
			li $t8, 40
			add $s5, $s5, $t8
			j s_continue
		get_I:
			li $t8, 48
			add $s5, $s5, $t8
		
		s_continue:
		move $s3, $a3
		# save t registers on stack
		addi $sp, $sp, -20
		sw $t0, ($sp)
		sw $t1, 4($sp)
		sw $t2, 8($sp)
		sw $t7, 12($sp)
		sw $t8, 16($sp)
		
		# $a0 remains
		move $a1, $t6 # col
		move $a2, $s5 # piece
		move $a3, $t5 # rotation
		addi $sp, $sp, -4
		sw $s3, ($sp) # rotated_piece
		
		jal drop_piece
		
		addi $sp, $sp, 4
		# move everything back
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
		lw $t0, ($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		lw $t7, 12($sp)
		lw $t8, 16($sp)
		addi $sp, $sp, 20
		
		sub $s5, $s5, $t8 # reset piece
		
		li $t8, -2
		beq $v0, $t8, set_invalid
		li $t8, -3
		beq $v0, $t8, set_invalid
		li $t8, -1
		beq $v0, $t8, set_invalid_over
		j check_invalid
		
		set_invalid_over:
			li $t2, 1
		set_invalid:
			li $t7, 1
			
		check_invalid:
			li $t8, 1
			beq $t7, $t8, increment_move_number
			j check_for_line_to_clear
			increment_move_number:
				addi $t0, $t0, 1
				j move_on_to_next_iteration
			
		check_for_line_to_clear:
			li $t8, 0 # num of lines cleared (count)
			lbu $t9, ($a0) # state.row
			addi $t9, $t9, -1 # state.row - 1 (r)
			
			check_for_line_to_clear_loop:
				bltz $t9, update_score # if r < 0, end loop and update score
				addi $sp, $sp, -12
				sw $t0, ($sp)
				sw $t1, 4($sp)
				sw $t2, 8($sp)
				move $a1, $t9
				addi $sp, $sp, -4
				sw $t8, ($sp)
				
				jal check_row_clear
				
				move $a1, $s1
				lw $t8, ($sp)
				addi $sp, $sp, 4
				lw $t0, ($sp)
				lw $t1, 4($sp)
				lw $t2, 8($sp)
				addi $sp, $sp, 12
				
				li $t7, 1
				beq $v0, $t7, increment_count
				addi $t9, $t9, -1
				j check_for_line_to_clear_loop
				increment_count:
					addi $t8, $t8, 1
					j check_for_line_to_clear_loop
					
		update_score:
			li $t7, 1
			beq $t8, $t7, add_40
			li $t7, 2
			beq $t8, $t7, add_100
			li $t7, 3
			beq $t8, $t7, add_300
			li $t7, 4
			beq $t8, $t7, add_1200
			j increment_success
			add_40:
				addi $s7, $s7, 40
				j increment_success
			add_100:
				addi $s7, $s7, 100
				j increment_success
			add_300:
				addi $s7, $s7, 300
				j increment_success
			add_1200:
				addi $s7, $s7, 1200
				j increment_success
		
		increment_success:
			addi $s6, $s6, 1 # increment num_successful_drops
			addi $t0, $t0, 1 # increment move_number
		move_on_to_next_iteration:
			addi $s2, $s2, 4
			j simulate_game_loop
		
		
	end_game:
		move $v0, $s6
		move $v1, $s7
		j simulate_game_end
	
	return_0_s:
		li $v0, 0
		li $v1, 0
	
	simulate_game_end:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $ra, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36
		jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
