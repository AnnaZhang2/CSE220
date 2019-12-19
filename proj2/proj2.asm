# CSE 220 Programming Project #2
# Anna Zhang
# zhang127
# 112167606

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

strlen:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	li $s0, 0 # count of chars
	move $s1, $a0 # address of string
	
	count_length:
		lb $a0, ($s1)
		beqz $a0,  count_length.done # if at null terminator, prepare for returning
    
		#increment
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		j count_length
			
	count_length.done:
		move $v0, $s0
		lw $s0, ($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		jr $ra

index_of:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)

	li $v0, 0 # index
	move $s1, $a0 # address of string
	lbu $s0, ($s1)
	find_char:
		beq $s0, $a1, index_of.done # if the current char is equal to the input char, prepare for returning
		beqz $s0, reset # if at null terminator, prepare for returning
		
		#increment
		addi $v0, $v0, 1
		addi $s1, $s1, 1
		lbu $s0, ($s1)
		j find_char
			
	reset:
			li $v0, -1
	index_of.done:
			lw $s0, ($sp)
			lw $s1, 4($sp)
			addi $sp, $sp, 8
    	jr $ra

bytecopy:
	lw $t0, ($sp)
	addi $sp, $sp, 4
	addi $sp, $sp, -12
	sw $s0, ($sp) # src
	sw $s1, 4($sp) #dest
	sw $s2, 8($sp) # length
	move $s2, $t0
	
	li $v0, -1
	
	# if $t0=length<=0, return -1
	blez $s2, byte_copy.done
	# if $a1=src_pos and $a3=dest_pos<0, return -1
	bltz $a1, byte_copy.done
	bltz $a3, byte_copy.done
	
	move $s0, $a0 # address of src
	lb $t4, ($s0)
	beqz $t4, byte_copy.done # if src is empty, return
	move $s1, $a2 # address of dest
	lb $t4, ($s1)
	beqz $t4, byte_copy.done # if dest is empty, return
	
	li $t1, 0 # counter
	# get to dest_pos
	add $s1, $s1, $a3 # move along the string
	add $a2, $a2, $a3 # move along dest string

	#go to src_pos
	add $s0, $s0, $a1
	
	li $t1, 0 # reset counter
	li $v0, 0 # num of chars copied
	src_substring: # uses length as limit
		beq $t1, $s2, byte_copy.done # is the counter = length
		lb $t3, ($s0) # load the byte from src to $t3
		sb $t3, ($a2) # stores byte to dest
		addi $v0, $v0, 1 # increments the num of chars copied
		addi $t1, $t1, 1 # increments counter
		addi $s0, $s0, 1 # moves along the string
		addi $a2, $a2, 1 # moves along dest string
		addi $s1, $s1, 1
		j src_substring
		
	byte_copy.done:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra

scramble_encrypt:
	addi $sp, $sp, -8
	sw $s0, ($sp) # plaintext
	sw $s1, 4($sp) # alphabet
	
	move $s0, $a1 # address of plaintext
	lb $t0, ($a1)
	li $v0, 0 # num of chars encrypted
	beqz $t0, scramble_encrypt.done # if plaintext is empty, return
	
	plaintext_loop:
		move $s1, $a2 # address of alphabet
		li $t1, 65 # decimal value of A
		lb $t0, ($s0)
		beqz $t0, scramble_encrypt.done # check if it's null terminator
		bge $t0, $t1, check_90 # if it is greater than A, check if it's less than Z
		move $t3, $t0
		j write_to_cipher # if it is not, directly write to ciphertext
		
		check_90:
			li $t1, 90 # decimal value of Z
			ble $t0, $t1, subtract_65 # if it is between A and Z, subtract 65
			li $t1, 97 # decimal value of a
			bge $t0, $t1, check_122 # if it is greater than a, check if it's less than z
			
			check_122:
				li $t1, 122 # decimal value of z
				ble $t0, $t1, subtract_71
				move $t3, $t0
				j write_to_cipher # if it is greater than z, directly write to ciphertext
		
		subtract_65:
			addi $t0, $t0, -65 # to get the index
			j set_counter
			
		subtract_71:
			addi $t0, $t0, -71
		
		set_counter:
			li $t4, 0 # counter
		alpha_loop:
			lb $t3, ($s1) # get the char from alphabet
			beq $t0, $t4, letters_encrypted # if it reaches the index, write to ciphertext
			addi $s1, $s1, 1 # move along the string
			addi $t4, $t4, 1 # increment counter
			beqz $t3, scramble_encrypt.done
			j alpha_loop
		
		letters_encrypted:
			addi $v0, $v0, 1
		write_to_cipher:
			sb $t3, ($a0)
			addi $a0, $a0, 1 # move along the ciphertext
			addi $s0, $s0, 1 # move along the string for plaintext
			j plaintext_loop
	
	scramble_encrypt.done:
		sb $zero, ($a0)
		lw $s0, ($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
	
		jr $ra

scramble_decrypt:
	addi $sp, $sp, -16
	sw $s0, ($sp) # ciphertext
	sw $s1, 4($sp) # alphabet
	sw $s2, 8($sp)
	sw $ra, 12($sp) # return address
	
	li $t5, 0 # num of chars decrypted
	move $s0, $a1 # address of ciphertext
	
	lb $t4, ($s0)
	beqz $t4, scramble_decrypt.done # if ciphertext is empty, return
	
	ciphertext_loop:
		move $s1, $a2 # address of alphabet
		move $s2, $a0 # address of plaintext
		
		lb $t4, ($s0) # load the char from cipher into $t4
		beqz $t4, scramble_decrypt.done # check if it's null terminator
		
		lbu $a1, ($s0) # load the char from the ciphertext to $a1 for index_of
		move $a0, $s1 # copy the alphabet to $s1 for index_of
		
		jal index_of # grab the index of the char from ciphertext
		move $t1, $v0 # copy the index to $t1
		
		move $a0, $s2 # move plaintext back into $a0
		
		li $t6, -1
		beq $t1, $t6 write_to_plain # if the index is -1, then write directly to plaintext
		
		addi $t1, $t1, 65 # if not, add 65
		move $t4, $t1
		
		li $t3, 65 # decimal value of A
		bge $t1, $t3, check_90_p # if it is greater than A, check if it's less than Z
		j write_to_plain # if it is not, directly write to plaintext
		
		check_90_p:
			li $t3, 90 # decimal value of Z
			ble $t1, $t3, letters_decrypted # if it is between A and Z, write to plain
			li $t3, 97 # decimal value of a
			bge $t1, $t3, check_122_p # if it is greater than a, check if it's less than z
			
			check_122_p:
				li $t3, 122 # decimal value of z
				ble $t1, $t3, add_6
				j write_to_plain # if it is greater than z, directly write to plaintext
			
		add_6:
			addi $t1, $t1, 6
			move $t4, $t1
	
	letters_decrypted:
		addi $t5, $t5, 1
	write_to_plain:
		sb $t4, ($a0)
		addi $a0, $a0, 1 # move along the plaintext
		addi $s0, $s0, 1 # move along the string for ciphertext
		j ciphertext_loop
		
	scramble_decrypt.done:
		sb $zero, ($a0)
		move $v0, $t5
		
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16
		
		jr $ra

base64_encode:
	addi $sp, $sp, -32
	sw $s0, ($sp) #str
	sw $s1, 4($sp) # base64_table
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $ra, 28($sp) # return address
	
	move $s0, $a1 # address of str
	move $s1, $a2 # address of base64_table
	
	move $s3, $a0 # move contents of $a0 into $s3
	move $a0, $a1 # move contents of $a1 into $a0
	jal strlen # get the length of str
	move $a1, $s0
	move $a0, $s3
	
	move $s4, $v0 # length of string
	
	li $s5, 3
	div $s4, $s5 # divide length by 3
	mfhi $s4 # change content of $s4 to remainder
	mflo $s6 # quotient
	
	li $v0, 0
	beqz $s6, check_remainder_for_null
	j initialize
	check_remainder_for_null:
		beqz $s4, base_64.done
	initialize:
	li $t1, 0 # counter for convert_to_binary
	li $s2, 0 # where the "total" bits will be stored
	li $t3, 0 # counter for whole loop
	li $t4, 18 # num of times to shift to the left to get groups of 6
	li $t5, 0x3F
	sllv $t5, $t5, $t4
	convert_to_binary:
		lb $t0, ($s0)
		sll $s2, $s2, 8 # shift bits 8 bits to the left
		or $s2, $s2, $t0, # combine two bytes
		
		addi $s0, $s0, 1 # move along str
		addi $t1, $t1, 1 # increment counter
		beq $t1, $s5, convert_to_6 # if looped 3 times, convert to groups of 6 bits
		j convert_to_binary
		
		#guaranteed to be a multiple of 6
		convert_to_6:
			and $s3, $s2, $t5 # mask the first group of 6
			srlv $s3, $s3, $t4 # $s3 will be the index
			
		li $t7, 0 # counter
		# loop until index
		table_loop:
			lb $t6, ($s1) # byte from alphabet
			beq $s3, $t7, write_to_str # at index, write to str
			addi $s1, $s1, 1 # move alphabet along
			addi $t7, $t7, 1 # increment counter
			j table_loop
			
		write_to_str:
			sb $t6, 0($a0)
				
			addi $v0, $v0, 1
			addi $a0, $a0, 1 # move along encoded_str
			addi $t4, $t4, -6 #decrement
			srl $t5, $t5, 6 # shift
			move $s1, $a2
			bltz $t4, check_finished
		j convert_to_6
		
		check_finished:
			addi $t3, $t3, 1
			beq $t3, $s6, check_remainder # check against quotient
			#reset variables
			li $s2, 0 # shifted result
			li $t1, 0 # counter for looping through binary
			li $t4, 18 # num of times to shift to the left to get groups of 6
			li $t5, 0x3F # 6 bits of 1
			sllv $t5, $t5, $t4
			
			j convert_to_binary
			
		check_remainder:
			beqz $s4, base_64.done
			li $t0, 1
			beq $s4, $t0, add_two_paddings
			li $t0, 2
			beq $s4, $t0, add_padding
			
			add_two_paddings:
				lb $t2, ($s0)
				li $t3, 0xFC
				and $t2, $t2, $t3
				srl $t2, $t2, 2
				
				li $t7, 0
				table_loop_p:
					lb $t6, ($s1) # byte from alphabet
					beq $t2, $t7, write_to_str_1 # at index, write to str
					addi $s1, $s1, 1 # move alphabet along
					addi $t7, $t7, 1 # increment counter
					j table_loop_p
				
				write_to_str_1:
					sb $t6, ($a0)
					addi $a0, $a0, 1
				
				lb $t2, ($s0)
				li $t3, 0x3
				and $t2, $t2, $t3
				sll $t2, $t2, 4
				
				table_loop_q:
					lb $t6, ($s1) # byte from alphabet
					beq $t2, $t7, write_to_str_2 # at index, write to str
					addi $s1, $s1, 1 # move alphabet along
					addi $t7, $t7, 1 # increment counter
					j table_loop_q
					
				write_to_str_2:
					sb $t6, ($a0)
					addi $a0, $a0, 1
					
				li $t1, '='
				sb $t1, ($a0)
				addi $a0, $a0, 1
				sb $t1, ($a0)
				addi $a0, $a0, 1
				j base_64.done
				
			add_padding:
				lb $t2, ($s0)
				sll $t2, $t2, 8
				lb $t4, 1($s0)
				or $t2, $t2, $t4
				
				li $t3, 0xFC00
				and $t5, $t2, $t3
				srl $t5, $t5, 10
				
				li $t7, 0
				table_loop_r:
					lb $t6, ($s1) # byte from alphabet
					beq $t5, $t7, write_to_str_3 # at index, write to str
					addi $s1, $s1, 1 # move alphabet along
					addi $t7, $t7, 1 # increment counter
					j table_loop_r
				
				write_to_str_3:
					sb $t6, ($a0)
					addi $a0, $a0, 1
					
				sub $s1, $s1, $t7
				
				li $t3, 0x3F0
				and $t5, $t2, $t3
				srl $t5, $t5, 4
				
				li $t7, 0
				table_loop_s:
					lb $t6, ($s1) # byte from alphabet
					beq $t5, $t7, write_to_str_4 # at index, write to str
					addi $s1, $s1, 1 # move alphabet along
					addi $t7, $t7, 1 # increment counter
					j table_loop_s
				
				write_to_str_4:
					sb $t6, ($a0)
					addi $a0, $a0, 1
					
				sub $s1, $s1, $t7
				
				li $t3, 0xF
				and $t5, $t2, $t3
				sll $t5, $t5, 2
				
				li $t7, 0
				table_loop_t:
					lb $t6, ($s1) # byte from alphabet
					beq $t5, $t7, write_to_str_5 # at index, write to str
					addi $s1, $s1, 1 # move alphabet along
					addi $t7, $t7, 1 # increment counter
					j table_loop_t
				
				write_to_str_5:
					sb $t6, ($a0)
					addi $a0, $a0, 1
				
				li $t1, '='
				sb $t1, ($a0)
				addi $a0, $a0, 1
			
		base_64.done:
			sb $zero, ($a0)
			
			lw $s0, ($sp) #str
			lw $s1, 4($sp) # base64_table
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $s5, 20($sp)
			lw $s6, 24($sp)
			lw $ra, 28($sp) # return address
			addi $sp, $sp, 32
		
			jr $ra
		
base64_decode:
	addi $sp, $sp, -36
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	
	move $s0, $a0 # decoded_str
	move $s1, $a1 # encoded_str
	move $s2, $a2 # base64_table
	
	li $t1, 4 # max num to loop
	li $t2, 0 # counter
	li $t3, 6# times shifted
	li $t4, '='
	li $t5, 0 # boolean if finished
	li $t6, 255
	li $t7, 16 # num of time need to shift
	sllv $t6, $t6, $t7
	li $t8, 0 # counter for num of '='
	li $s6, 0 # count for total num of times looped through encoded_str
	li $s7, 0 # num decoded
	
	move $a0, $a1
	jal strlen # find length of encoded_str
	move $s5, $v0 # length of encoded_str
	move $a0,$s0
	move $a1, $s1
	
	find_index:
		lbu $a1, ($s1) # don't forget to move it back in
		beq $a1, $t4, add_0 # check if it's '='; if it is, add 0
		beqz $a1, check_len # if char is 0, check if we're at len
		check_len:
			beq $s6, $s5, base64_decode.done # if at pos len, then null terminator
			# if not, continue
		move $a0, $a2
		jal index_of
		move $t0, $v0 # index of the char
		#move everything back
		move $a1, $s1
		move $a0, $s0
		
		sllv $s3, $s3, $t3 # shift to the left
		or $s3, $s3, $t0
		
		j in
		
		add_0:
			move $a1, $s1 # move content back
			sll $s3, $s3, 6 # for every '=', shift 6 to the left
			addi $t8, $t8, 1
		in:
			addi $s1, $s1, 1 # move decoded_str along
			addi $t2, $t2, 1 # increment counter
			addi $s6, $s6, 1
			beq $t1, $t2, convert_to_8 #check if looped 4 times; if so, convert to 8
		
		j find_index
		
		#convert to groups of 8 bits
		convert_to_8:
			#check if there is padding
			bnez $t8, check_padding
			j get_ascii
			
			check_padding:
				li $t9, 8
				mul $t9, $t8, $t9 # multiply num of '=' by 8
				srlv $t6, $t6, $t9 # shifting 8 bits of 1 to the right $t8 many times
				srlv $s3, $s3, $t9 # shift result binary to the right
				
			get_ascii:
				and $s4, $s3, $t6
				srl $t6, $t6, 8
				beqz $t8, use_t6
				li $t0, 2
				beq $t0, $t8, sub16
				j shift
				sub16:
					li $t9, 0
				shift:
					srlv $s4, $s4, $t9
				j write
				
				use_t6:
					srlv $s4, $s4, $t7 # $s4 will have the ascii value
					addi $t7, $t7, -8
				
				write:
					sb $s4, ($a0)
			
					addi $a0, $a0, 1
					addi $s0, $s0, 1
					addi $s7, $s7, 1 # num decoded
					
					li $t0, 1
					beq $t0, $t8, decrement
					j check
					decrement:
						addi $t9, $t9, -8
					check:
					beqz $t6, d.check_finished # $t6 = num of times shifted
					j get_ascii
					
					beq $s6, $s5, base64_decode.done # if at pos len, then null terminator
			
			d.check_finished:
				beq $s6, $s5, base64_decode.done
				# reset variables
				li $t2, 0 # counter for looping through binary
				li $s3, 0 # shifted result
				li $t7, 16 # num of time need to shift
				li $t6, 0xFF # 8 bits of 1
				sllv $t6, $t6, $t7
				
				j find_index
				
	base64_decode.done:
		sb $zero, ($a0)
		
		move $v0, $s7
		
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $ra, 32($sp)
		addi $sp, $sp, 36
		jr $ra


bifid_encrypt:
	bltz $a3, return_1
	
	lw $t0, ($sp) # index_buffer
	lw $t1, 4($sp) # block buffer
	addi $sp, $sp, 8
	
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s5, 4($sp)
	sw $s4, 8($sp) # key_square
	sw $s3, 12($sp) # plaintext
	sw $s2, 16($sp) # ciphertext
	sw $s1, 20($sp) # block_buffer
	sw $s0, 24($sp) # index_buffer
	sw $s7, 28($sp) # counter
	
	lbu $t2, ($a1)
	li $v0, 0
	beqz $t2, load
	
	move $s0, $t0
	move $s1, $t1
	move $s2, $a0 # ciphertext
	move $s3, $a1, # plaintext
	move $s4, $a2 # key_square
	
	#get length
	move $a0, $a1
	jal strlen
	move $a0, $s2
	move $s5, $v0 # $s5 now stores the length
	
	li $t1, 0 # counter for loop
	li $t4, 9
	# loop through plaintext, get the rows and cols and store them into index_buffer
	# to end, check if it reaches len
	plain_loop:
		lbu $t0, ($s3)
		
		#find index in key_square: $s4
		move $a0, $s4
		move $a1, $t0
		jal index_of
		move $a0, $s2
		move $a1, $s3
		move $t2, $v0 # $t2 has the index
		
		#find the row and col
		div $t2, $t4
		mflo $t3 # row
		addi $t3, $t3, 48
		mfhi $t5 # col
		addi $t5, $t5, 48
		
		#write to index_buffer: $s0
		sb $t3, ($s0) # write row
		add $t6, $s5, $t1 # $t6 holds len + counter
		sub $t6, $t6, $t1

		add $s0, $s0, $t6
		sb $t5, ($s0) # write column
		
		sub $s0, $s0, $t6
		addi $s0, $s0, 1
		
		addi $t1, $t1, 1 # increment counter
		addi $s3, $s3, 1 # move plaintext along
		beq $t1, $s5, move_back_pointer
		j plain_loop
	
	move_back_pointer:
		sub $s0, $s0, $s5
		
	li $s7, 0 # counter for the second loop
	# loop through index_buffer ($s0) and get groups of period indices
	div $s5, $a3
	mflo $t9 # len / period
	beqz $t9, check_remainder_2
	mul $t8, $t9, $a3 # multiply quotient by period
	create_block:
		move $s6, $a3 # $s6 now has period
		move $a0, $s0 # src: index_buffer
		move $a1, $s7 # src_pos for row
		move $a2, $s1 # dest: block_buffer
		li $t4, 0
		move $a3, $t4 # dest_pos: 0
		addi $sp, $sp, -4
		sw $s6, ($sp)
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $s6
		
		addi $sp, $sp, -4
		sw $s6, ($sp)
		move $a0, $s0 # src: index_buffer
		
		add $t2, $s7, $s5 # add product to length
		move $a1,  $t2 # src_pos for col
		move $a2, $s1 # dest: block_buffer
		move $t4, $s6
		move $a3, $t4 # dest_pos: $s6
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $s6
		
		li $t0, 0 # counter
		li $t6, 9
		add $t1, $s6, $s6
		
		block_loop:
			# get the pair
			lbu $t3, ($s1)
			lbu $t4, 1($s1)
			# turn back to num
			addi $t3, $t3, -48
			addi $t4, $t4, -48
		
			# get the index
			mul $t5, $t3, $t6 # multiply first num of pair by 9
			add $t5, $t5, $t4 # add second num to product
		
			add $s4, $s4, $t5
			lbu $t7, ($s4)
			sb $t7, ($a0) # write to cipher
			sub $s4, $s4, $t5 # reset $s4 pointer
			
			addi $s1, $s1, 2 # move block by 2
			addi $t0, $t0, 2 # increment counter by 2
			addi $a0, $a0, 1 # move cipher along
			addi $s2, $s2, 1 # move copy cipher along
			
			bne $t0, $t1, block_loop
			sub $s1, $s1, $t1 # reset pointer for block
		
		add $s7, $s7, $s6 # increment counter by period
		
		beq $s7, $t8, check_remainder_2
		j create_block
	
	#remainder
	check_remainder_2:
		div $s5, $a3
		mfhi $t9 # remainder
		beqz $t9, bifid_encrypt.done # if there are no remainders, end
		
		li $t1, 0 # counter
		li $t8, 1
	remainder_loop:
		move $a0, $s0 # src: index_buffer
		move $a1, $s7 # src_pos for row
		move $a2, $s1 # dest: block_buffer
		li $t4, 0
		move $a3, $t4 # dest_pos: 0
		addi $sp, $sp, -4
		sw $t9, ($sp)
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $t9
		
		addi $sp, $sp, -4
		sw $t9, ($sp)
		move $a0, $s0 # src: index_buffer
		
		add $t2, $s7, $s5 # add product to length
		move $a1,  $t2 # src_pos for col
		move $a2, $s1 # dest: block_buffer
		move $t4, $t9
		move $a3, $t4 # dest_pos: # num of remainder
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $s6
		
		li $t0, 0
		li $t2, 0 # actual counter
		li $t6, 9
		
		block_loop_r:
			# get the pair
			lbu $t3, ($s1)
			lbu $t4, 1($s1)
			# turn back to num
			addi $t3, $t3, -48
			addi $t4, $t4, -48
		
			# get the index
			mul $t5, $t3, $t6 # multiply first num of pair by 9
			add $t5, $t5, $t4 # add second num to product
		
			add $s4, $s4, $t5
			lbu $t7, ($s4)
			sb $t7, ($a0) # write to cipher
			sub $s4, $s4, $t5 # reset $s4 pointer
			
			addi $s1, $s1, 2 # move block by 2
			addi $t0, $t0, 2 # increment counter by 2
			addi $t2, $t2, 1
			addi $a0, $a0, 1 # move cipher along
			addi $s2, $s2, 1 # move copy cipher along
			
			bge $t2, $t1, bifid_encrypt.done
			j block_loop_r

	return_1:
		li $v0, -1
		
	bifid_encrypt.done:
		sb $zero, ($a0)
		div $s5, $a3
		mflo $t8 # quotient
		beqz $t8, set_to_1
		mfhi $t9 # remainder
		beqz $t9, set_to_quotient
		addi $v0, $t8, 1
		j load
		set_to_1:
			li $v0, 1
			j load
		set_to_quotient:
			move $v0, $t8
		load:
			lw $ra, 0($sp)
			lw $s5, 4($sp)
			lw $s4, 8($sp) # key_square
			lw $s3, 12($sp) # ciphertext
			lw $s2, 16($sp) # plaintext
			lw $s1, 20($sp) # block_buffer
			lw $s0, 24($sp) # index_buffer
			sw $s7, 28($sp) # counter
			addi $sp, $sp, 32
		
		jr $ra

bifid_decrypt:
	bltz $a3, return_1
	
	lw $t0, ($sp) # index_buffer
	lw $t1, 4($sp) # block buffer
	addi $sp, $sp, 8
	
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s5, 4($sp)
	sw $s4, 8($sp) # key_square
	sw $s3, 12($sp) # plaintext
	sw $s2, 16($sp) # ciphertext
	sw $s1, 20($sp) # block_buffer
	sw $s0, 24($sp) # index_buffer
	sw $s7, 28($sp) # counter
	
	lbu $t2, ($a1)
	li $v0, 0
	beqz $t2, d_load
	
	move $s0, $t0 # index_buffer
	move $s1, $t1 # block_buffer
	move $s2, $a0 # plaintext
	move $s3, $a1, # ciphertext
	move $s4, $a2 # key_square
	
	#get length
	move $a0, $a1
	jal strlen
	move $a0, $s2
	move $s5, $v0 # $s5 now stores the length
	
	li $t1, 0 # counter for loop
	li $t4, 9
	add $t6, $s5, $s5 # double length
	# loop through plaintext, get the rows and cols and store them into index_buffer
	# to end, check if it reaches len
	cipher_loop:
		lbu $t0, ($s3)
		
		#find index in key_square: $s4
		move $a0, $s4
		move $a1, $t0
		jal index_of
		move $a0, $s2
		move $a1, $s3
		move $t2, $v0 # $t2 has the index
		
		#find the row and col
		div $t2, $t4
		mflo $t3 # row
		addi $t3, $t3, 48
		mfhi $t5 # col
		addi $t5, $t5, 48
		
		#write to index_buffer: $s0
		sb $t3, ($s0) # write to index_buffer
		sb $t5, 1($s0) # write to index_buffer
		
		addi $s0, $s0, 2 # move along plaintext
		addi $s3, $s3, 1 # move along ciphertext
		addi $t1, $t1, 2 # increment counter by 2
		beq $t1, $t6, d_move_back_pointer
		j cipher_loop
	
	d_move_back_pointer:
		sub $s0, $s0, $t6
		
	#loop through blocks
	li $s7, 0 #src_pos
	div $s5, $a3 # divide length by period
	mflo $t9 # len / period
	beqz $t9, check_remainder_3
	li $t8, 0 # counter
	d_create_block:
		move $s6, $a3 # $s6 now has period
		move $a0, $s0 # src: index_buffer
		move $a1, $s7 # src_pos for row
		move $a2, $s1 # dest: block_buffer
		li $t4, 0
		move $a3, $t4 # dest_pos: 0
		addi $sp, $sp, -4
		sw $s6, ($sp)
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $s6
		
		addi $sp, $sp, -4
		sw $s6, ($sp)
		move $a0, $s0 # src: index_buffer
		
		add $s7, $s7, $s6 # add period to src_pos
		move $a1,  $s7 # src_pos for col
		move $a2, $s1 # dest: block_buffer
		move $t4, $s6
		move $a3, $t4 # dest_pos: $s6
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $s6
		
		li $t1, 0 # counter
		li $t6, 9
		d_block_loop:
			lbu $t2, ($s1)
			add $s1, $s1, $s6 # move block_buffer period * counter times
			lbu $t3, ($s1)
			sub $s1, $s1, $s6 # move pointer back for block_buffer
		
			# turn back to num
			addi $t2, $t2, -48
			addi $t3, $t3, -48
		
			# get the index
			mul $t4, $t2, $t6 # multiply first num of pair by 9
			add $t4, $t4, $t3 # add second num to product
			
			add $s4, $s4, $t4 # move keysquare index times
			lbu $t7, ($s4)
			sb $t7, ($a0) # write to plaintext
			sub $s4, $s4, $t4 # reset $s4 pointer
			
			addi $t1, $t1, 1 # increment counter
			addi $s1, $s1, 1 # move block_buffer along
			addi $a0, $a0, 1 # move ciphertext along
			addi $s2, $s2, 1 # move copy along
			bne $t1, $s6, d_block_loop
			sub $s1, $s1, $s6 # reset pointer for block
		
		add $s7, $s7, $s6 # multiply index by period
		addi $t8, $t8, 1 # increment counter
		beq $t8, $t9, check_remainder_3
		j d_create_block
	
		check_remainder_3:
		div $s5, $a3
		mfhi $t9 # remainder
		beqz $t9, bifid_encrypt.done # if there are no remainders, end
		
		li $t1, 0 # counter
		li $t8, 1
		remainder_loop_2:
		move $s6, $a3 # $s6 now has period
		move $a0, $s0 # src: index_buffer
		move $a1, $s7 # src_pos for row
		move $a2, $s1 # dest: block_buffer
		li $t4, 0
		move $a3, $t4 # dest_pos: 0
		addi $sp, $sp, -4
		sw $t9, ($sp) # remainder will be the length
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $s6
		
		addi $sp, $sp, -4
		sw $t9, ($sp)
		move $a0, $s0 # src: index_buffer
		
		add $s7, $s7, $t9 # add remainder to src_pos
		move $a1,  $s7 # src_pos for col
		move $a2, $s1 # dest: block_buffer
		move $t4, $t9
		move $a3, $t4 # dest_pos: $s6
		
		jal bytecopy
		
		move $a0, $s2
		move $a1, $s3
		move $a2, $s4
		move $a3, $s6
		
		li $t1, 0 # counter
		li $t6, 9
		d_block_loop_r:
			lbu $t2, ($s1)
			add $s1, $s1, $t9 # move block_buffer remainder * counter times
			lbu $t3, ($s1)
			sub $s1, $s1, $t9 # move pointer back for block_buffer
		
			# turn back to num
			addi $t2, $t2, -48
			addi $t3, $t3, -48
		
			# get the index
			mul $t4, $t2, $t6 # multiply first num of pair by 9
			add $t4, $t4, $t3 # add second num to product
			
			add $s4, $s4, $t4 # move keysquare index times
			lbu $t7, ($s4)
			sb $t7, ($a0) # write to plaintext
			sub $s4, $s4, $t4 # reset $s4 pointer
			
			addi $t1, $t1, 1 # increment counter
			addi $s1, $s1, 1 # move block_buffer along
			addi $a0, $a0, 1 # move ciphertext along
			addi $s2, $s2, 1 # move copy along
			bne $t1, $t9, d_block_loop_r
			sub $s1, $s1, $t9 # reset pointer for block
		
	
	bifid_decrypt.done:
		sb $zero, ($a0)
		
		div $s5, $a3
		mflo $t8 # quotient
		beqz $t8, d_set_to_1
		mfhi $t9 # remainder
		beqz $t9, d_set_to_quotient
		addi $v0, $t8, 1
		j d_load
		d_set_to_1:
			li $v0, 1
			j load
		d_set_to_quotient:
			move $v0, $t8
		d_load:
		lw $ra, 0($sp)
		lw $s5, 4($sp)
		lw $s4, 8($sp) # key_square
		lw $s3, 12($sp) # plaintext
		lw $s2, 16($sp) # ciphertext
		lw $s1, 20($sp) # block_buffer
		lw $s0, 24($sp) # index_buffer
		sw $s7, 28($sp) # counter
		addi $sp, $sp, 32
		jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
