# Anna Zhang
# zhang127
# 112167606

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
royal_flush_str: .asciiz "ROYAL_FLUSH\n"
straight_flush_str: .asciiz "STRAIGHT_FLUSH\n"
four_of_a_kind_str: .asciiz "FOUR_OF_A_KIND\n"
full_house_str: .asciiz "FULL_HOUSE\n"
simple_flush_str: .asciiz "SIMPLE_FLUSH\n"
simple_straight_str: .asciiz "SIMPLE_STRAIGHT\n"
high_card_str: .asciiz "HIGH_CARD\n"

zero_str: .asciiz "ZERO\n"
neg_infinity_str: .asciiz "-INF\n"
pos_infinity_str: .asciiz "+INF\n"
NaN_str: .asciiz "NAN\n"
floating_point_str: .asciiz "_2*2^"

# Put your additional .data declarations here, if any.
new_line: .asciiz "\n"
neg_sign: .asciiz "-"
one_point: .asciiz "1."


# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here
    li $t1, 'F' # load 'F'
    lbu $t2, 0($t0) # get the first argument
    
    bne $t2, $t1, check_M # if equal, check argument; if not, check if it's M
	j check_arg_f
	
	check_M:
		li $t1, 'M' # load 'M'
		bne $t2, $t1, check_P # if equal, check argument; if not, check if it's P
		j check_arg_m
		
	check_P:
		li $t1, 'P' # load 'P'
		bne $t2, $t1, print_operation_error # if equal, check agument, if not, print error message
		j check_arg_p
		
	print_operation_error:
		la $a0, invalid_operation_error
		li $v0, 4
		syscall
		j exit
		
	check_arg_f:
		jal check_next_byte
		lw $t3, num_args # get the total number of args
		li $t1, 2
		
		bne $t3, $t1, print_invalid_arg # check if the number of args is 2
		
		j f_operation # start executing F operation
	
	check_arg_m:
		jal check_next_byte
		lw $t3, num_args # get the total number of args
		li $t1, 2
		
		bne $t3, $t1, print_invalid_arg # check if the number of args is 2
		
		j m_operation # start executing M operation
		
	check_arg_p:
		jal check_next_byte
		lw $t3, num_args # get the total number of args
		li $t1, 2
		
		bne $t3, $t1, print_invalid_arg # check if the number of args is 2
		
		j p_operation
		
	check_next_byte:
		lbu $t2, 1($t0)
		bnez $t2, print_operation_error # if the next byte is not a null terminator, print operation error
		jr $ra # return to where initially was
		
	print_invalid_arg:
		la $a0, invalid_args_error
		li $v0, 4
		syscall
		j exit
	
	convert_to_hexa:
			addi $t5, $t5, 1 # increment counter
			mul $t4, $t4, $t7
			
			lbu $t1, 0($t0) # get first byte
			li  $t2, 58 # load 58 into immediate
			
			#get the ascii values
			blt $t1, $t2, check_greater_than_47 # check if it's less than 58
			li $t2, 71
			blt $t1, $t2, check_greater_than_64 # check if it's less than 71
			j print_invalid_arg # if not both, then invalid
			
			check_greater_than_47:
				li $t2, 47
				bgt $t1, $t2, subtract_48 # if between 47 and 58, exclusive, subtract 48
				j print_invalid_arg
			
			check_greater_than_64:
				li $t2, 64
				bgt $t1, $t2, subtract_55 # if between 64 and 71, exclusive, subtract 5
				j print_invalid_arg
			
			 subtract_48:
				addi $t3, $t1, -48
				j end_subtract
			
			subtract_55:
				addi $t3, $t1, -55
				j end_subtract
			
			end_subtract:
			add $t4, $t4, $t3
			addi $t0, $t0, 1 # increment to the next byte
			
			bne  $t5, $t6 convert_to_hexa  # jump back to the beginning of conversion
			
			jr $ra # return to where it originally was
			
	#Part II
	m_operation:
		lw $t0, addr_arg1 # load second argument
		lbu $t1, 0($t0)
		
		li $t5, 0 # counter
		li $t6, 8 # max number of times it's going to loop
		li $t4, 0
		li $t7, 16
		jal convert_to_hexa
		
		# load the immediates for comparison
		li $t0, 0
		li $t1, 1
		li $t3, 2
		li $t5, 3
		li $t6, 4
		li $t7, 5
		
		mask: 
			beqz $t0, mask_first_6
			beq $t0, $t1, mask_first_5
			beq $t0, $t3, mask_sec_5
			beq $t0, $t5, mask_third_5
			beq $t0, $t6, mask_fourth_5
			beq $t0, $t7, mask_last_6
			
			j exit # exit when there's no more to mask
			
			mask_first_6:
				#mask
				andi $t2, $t4, 0xFC000000
				srl $t2, $t2, 24
				
				#check if it is 0
				bnez $t2, print_invalid_arg
				
				j print_output
				
			mask_first_5:
				#mask
				andi $t2, $t4, 0x3E00000
				srl $t2, $t2, 21
				j print_output
				
			mask_sec_5:
				#mask
				andi $t2, $t4, 0x1F0000
				srl $t2, $t2, 16
				j print_output
				
			mask_third_5:
				#mask
				andi $t2, $t4, 0xF800
				srl $t2, $t2, 11
				j print_output
				
			mask_fourth_5:
				#mask
				andi $t2, $t4, 0x7C0
				srl $t2, $t2, 6
				j print_output
				
			mask_last_6:
				#mask
				andi $t2, $t4, 0x3F
				j print_output
			
			print_output:
				#print the decimal value
				move $a0, $t2,
				li $v0, 1
				syscall
				
				beq $t0, $t7, print_new_line # print new line if it's the last field
		
			print_space:
				li $a0, 32
				li $v0, 11
				syscall
				j increment
			
			print_new_line:
				la $a0, new_line
				li $v0, 4
				syscall
				j exit
			
			increment:
				addi $t0, $t0, 1 #increment
				j mask
	
	#Part III
	f_operation:
		lw $t0, addr_arg1 # load second argument
		lbu $t1, 0($t0)
		
		li $t5, 0 # counter
		li $t6, 4 # max number of times it's going to loop
		li $t4, 0
		li $t7, 16
		jal convert_to_hexa
		
		#mask first bit and get the sign bit
		andi $t0, $t4, 0x8000
		srl $t0, $t0, 15
		
		#mask the next 5 bits to get the exponent field
		andi $t1, $t4, 0x7C00
		srl $t1, $t1, 10

		#mask the next 10 bits to get the fraction field
		andi $t2, $t4, 0x3FF
		
		# ---------------- Start printing ----------------
		beqz $t1, check_fraction_0 # if exponent = 0, check fraction
		
		addi $t1, $t1, -15 # subtract 15 from the value to get the actual exponent
		
		li $t5, 16 # decimal representation of 11111 - 15
		beq $t1, $t5, check_fraction_1 # if exponent is 11111 - 15, then check fraction
		
		# no special case
		bnez $t0, print_neg
		j print_1
			
		print_neg:
			la $a0, neg_sign # print "-"
			li $v0, 4
			syscall
				
		print_1:
			la $a0, one_point # print "1."
			li $v0, 4
			syscall
		
		li $t6, 0x200
		li $t7, 9
		trim_fraction:
			and $t5, $t2, $t6 # mask to get the leftmost bit of fraction
			srlv $t5, $t5, $t7 # shift all the way to right
			
			# print
			move $a0, $t5
			li $v0, 1
			syscall
			
			addi $t7, $t7, -1
			srl $t6, $t6, 1
			
			bltz $t7, print_floating
			j trim_fraction
		
		print_floating:
			la $a0, floating_point_str
			li $v0, 4
			syscall
				
		print_exponent:
			move $a0, $t1
			li $v0, 1
			syscall
			j print_new_line
		
		check_fraction_0: # if fraction = 0, print 0 and exit
			beqz $t2, print_0
			
		check_fraction_1:
			beqz $t2, check_sign # if fraction is 0, check sign
			j print_nan # if fraction is nonzero, print nan
			
		check_sign: # if sign bit =0, print +INF
			beqz $t0, print_pos_inf
			j print_neg_inf # else, print -INF
			
		print_0:
			la $a0, zero_str
			li $v0, 4
			syscall
			j exit
			
		print_pos_inf:
			la $a0, pos_infinity_str
			li $v0, 4
			syscall
			j exit
			
		print_neg_inf:
			la $a0, neg_infinity_str
			li $v0, 4
			syscall
			j exit
			
		print_nan:
			la $a0, NaN_str
			li $v0, 4
			syscall
			j exit
		
	#Part IV
	p_operation:
		lw $t0, addr_arg1 # load second argument
		addi $t0, $t0, 1
		lbu $t1, 0($t0) # load the second char
		
		li $t2, 83 # S
		li $t3, 67 # C
		li $t4, 72 # H
		li $t5, 68 # D
		li $t6, 0x50 # 'null terminator'
		
		li $s0, 0 # counter for S
		li $s1, 0 # counter for C
		li $s2, 0 # counter for H
		li $s3, 0 # counter for D
		
		li $t7, 1 # to add
		li $s4, 0 # counter for loop
		li $s5, 5 # max # of times to loop
		
		check_number_of_suits:
			lbu $t1, 0($t0) # load the second char
			bne $t1, $t2, check_c # check if it is S
			add $s0, $s0, $t7# if it is, increment counter
			j increment_s
			
			check_c:
				bne $t1, $t3, check_h # check if it is C
				add $s1, $s1, $t7 # if it is, increment counter
				j increment_s
				
			check_h:
				bne $t1, $t4, check_d # check if it is H
				add $s2, $s2, $t7 # if it is, increment counter
				j increment_s
			
			check_d:
				bne $t1, $t5, print_invalid_arg # check if it is D
				add $s3, $s3, $t7 # if it is, increment counter
						
			increment_s:
				addi $t0, $t0, 2
				add $s4, $s4, $t7
				
				beq $s4, $s5, is_5_s
				j check_number_of_suits
		
		# check if the suit counters are 5
		is_5_s:
			li $t8, 0 # "boolean" to say whether it's a flush or not
			
			li $t7, 5 # all 5 have same suits
			bne $s0, $t7, is_5_c # if no full spades, check club
			addi $t8, $t8, 1
			j initiate_for_check
			
			is_5_c:
				bne $s1, $t7, is_5_h # if no full clubs, check hearts
				addi $t8, $t8, 1
				j initiate_for_check
			
				is_5_h:
					bne $s2, $t7, is_5_d # if no full hearts, check diamonds
					addi $t8, $t8, 1
					j initiate_for_check
				
					is_5_d:
						bne $s3, $t7, initialize_4 # check 4 of a kind if it's not a flush
						addi $t8, $t8, 1
		
		initiate_for_check:
			li $s4, 0
			lw $t0, addr_arg1
			lbu $t1, 0($t0)
		
			# for comparison
			li $t2, 65 # A
			li $t3, 75 # K
			li $t4, 81 # Q
			li $t5, 74 # J
			li $t6, 84 # T
		
		check_ranks_AKQJT:
			bne $t1, $t2, check_K # check if it's A
			addi $s4, $s4, 0x1000 # if it is, increment the 13th bit
			j increment_r1
			
			check_K:
				bne $t1, $t3, check_Q # check if it's K
				addi $s4, $s4, 0x800 # if it is, increment the 12th bit
				j increment_r1
			
			check_Q:
				bne $t1, $t4, check_J # check if it's Q
				addi $s4, $s4, 0x400 # if it is, increment the 11th bit
				j increment_r1
			
			check_J:
				bne $t1, $t5, check_T # check if it's J
				addi $s4, $s4, 0x200 # if it is, increment the 10th bit
				j increment_r1
			
			check_T:
				bne $t1, $t6, check_within_range # check if it's T
				addi $s4, $s4, 0x100 # if it is, increment the 9th bit
				j increment_r1
			
			check_within_range: # if not AKQJT, then make sure the ranks are within 2-9
				li $t7, 50
				blt $t1, $t7, print_invalid_arg
				li $t7, 57
				bgt $t1, $t7, print_invalid_arg
				j initialize_for_seq # check for straight flush
				
			#increment
			increment_r1:
				addi $t0, $t0, 2
				lbu $t1, 0($t0)
			
				beq $t1, $zero, check_royal_flush
			j check_ranks_AKQJT
		
		check_royal_flush:
			andi $s4, $s4, 0x1F00
			srl $s4, $s4, 8
		
			li $t7, 0x1F
			bne $s4, $t7, initialize_for_seq # if not royal flush, check straight flush
		
		print_royal_flush:
			la $a0, royal_flush_str
			li $v0, 4
			syscall
			j exit
		
		initialize_for_seq:
			lw $t0, addr_arg1
			lbu $t1, 0($t0)
			li $s4, 0
			
			check_ranks_seq:
				li $t2, 65
				bne $t1, $t2, check_k
				addi $s4, $s4, 0x1000
				j increment_seq
				
				check_k:
					li $t2, 75
					bne $t1, $t2, check_q
					addi $s4, $s4, 0x800
					j increment_seq
				
				check_q:
					li $t2, 81
					bne $t1, $t2, check_j
					addi $s4, $s4, 0x400
					j increment_seq
				
				check_j:
					li $t2, 74
					bne $t1, $t2, check_t
					addi $s4, $s4, 0x200
					j increment_seq
				
				check_t:
					li $t2, 84
					bne $t1, $t2, check_9
					addi $s4, $s4, 0x100
					j increment_seq
				
				check_9:
					li $t2, 0x39
					bne $t1, $t2, check_8
					addi $s4, $s4, 0x80
					j increment_seq
				
				check_8:
					li $t2, 0x38
					bne $t1, $t2, check_7
					addi $s4, $s4, 0x40
					j increment_seq
				
				check_7:
					li $t2, 0x37
					bne $t1, $t2, check_6
					addi $s4, $s4, 0x20
					j increment_seq
				
				check_6:
					li $t2, 0x36
					bne $t1, $t2, check_5
					addi $s4, $s4, 0x10
					j increment_seq
				
				check_5:
					li $t2, 0x35
					bne $t1, $t2, check_4
					addi $s4, $s4, 0x8
					j increment_seq
				
				check_4:
					li $t2, 0x34
					bne $t1, $t2, check_3
					addi $s4, $s4, 0x4
					j increment_seq
				
				check_3:
					li $t2, 0x33
					bne $t1, $t2, check_2
					addi $s4, $s4, 0x2
					j increment_seq
				
				check_2:
					li $t2, 0x32
					bne $t1, $t2, print_invalid_arg
					addi $s4, $s4, 0x1
				
				increment_seq:
					addi $t0, $t0, 2
					lbu $t1, 0($t0)
			
					beq $t1, $zero, check_straight
					j check_ranks_seq
			
			check_straight:
				li $t4, 1 # for comparison
				li $t5, 0 # counter to shift
				li $t6, 13
				
				get_5_bits:
					andi $t3, $s4, 0x1 # get the rightmost bit
					beq $t3, $t4, shift_right # if the rightmost bit is a 1, start masking
					j increment_for_bits
					
						shift_right:
							andi $t7, $s4, 0x1F # mask to get the rightmost 5 bits
							j check_if_consec # check
							
					increment_for_bits:
						addi $t5, $t5, 1
						srl $s4, $s4, 1
						
					beq $t5, $t6, print_invalid_arg # no ranks
					
					j get_5_bits
			
				check_if_consec:
					li $t6, 0x1F #11111 in hex
					bne $t7, $t6, checked #  if not sequential, check if 4-of-a-kind and below has been checked
					li $t5, 1
					beq $t8, $t5, print_straight_flush
					j print_straight # if it's not a flush but the ranks are sequential, print straight
					
					checked:
						li $t5, 1
						bne $t9, $t5, initialize_4 # if not, check 4-of-a-kind
						j print_high_card # otherwise, print high card
				
			print_high_card:
				la $a0, high_card_str
				li $v0, 4
				syscall
				j exit
			
			print_straight_flush:
				la $a0, straight_flush_str
				li $v0, 4
				syscall
				j exit
				
			print_straight:
				la $a0, simple_straight_str
				li $v0, 4
				syscall
				j exit
				
			initialize_4:
				lw $t0, addr_arg1
				lbu $t1, 0($t0) # get the first rank
				addi $t0, $t0, 2
				lbu $t2, 0($t0) # get the second rank
				addi $t0, $t0, 2
				
				li $s4, 0 # counter for one rank
				li $s5, 0 # counter for the other rank
				
				bne $t1, $t2, add_to_diff_counter
				addi $s4, $s4, 2 # if the first two are the same
				li $t9, 1
				j for_loops
				
				add_to_diff_counter:
					addi $s4, $s4, 1
					addi $s5, $s5, 1
					
				for_loops:
					li $t4, 0 # counter for loop
					li $t5, 3 # max num of times to loop
				
				num_of_diff_ranks:
					lbu $t3, 0($t0) # get the third to compare
					
					bne $t3, $t1, compare_to_sec
					addi $s4, $s4 1
					j increment_4
					
					compare_to_sec:
						bne $t3, $t2, check_if_the_same 
						addi $s5, $s5, 1
						j increment_4
						
						check_if_the_same:
							li $s1, 1
							bne $t9, $s1, check_flush # if it's not equal to either one, then there are more than two ranks
							move $t2, $t3
							addi $s5, $s5, 1
							li $t9, 0
							
					increment_4:
						addi $t0, $t0, 2
						addi $t4, $t4, 1
						beq $t4, $t5, check_4_kind # go check for 4 of a kind
						j num_of_diff_ranks
			
			check_4_kind:
				li $t6, 4 # for checking if there are 4 cards of the same rank
				li $t7, 5 	# for checking if there are 5 cards of the same rank
				
				bne $s4, $t6, check_first_5
				j print_4_of_a_kind
				
				check_first_5:
					bne $s4, $t7, check_sec_4
					j print_4_of_a_kind
					
					check_sec_4:
						bne $s5, $t6, check_sec_5
						j print_4_of_a_kind
						
						check_sec_5:
							bne $s5, $t7, check_full_house
							j print_4_of_a_kind
							
			check_full_house:
				li $t6, 3 # for checking if there are 3 cards of the same rank
				li $t7, 2 # for checking if there are 2 cards of the same rank
				
				bne $s4, $t6, check_first_2 # if first counter is not 3, check if it's 2
				j check_sec_2 # if first counter is 3, check if second is 2
				
				check_first_2:
					bne $s5, $t6, check_flush # if both counters are not 3, then it's not a full house
					j print_full_house
				
				check_sec_2:
					bne $s5, $t7, check_flush # if first is 3 and second is not a 2, then error
					j print_full_house
			
			check_flush:
				li $t7, 1
				li $t9, 1 # everything has been checked
				
				bne $t7, $t8, initialize_for_seq # if it's not a flush, check if it's straight
				j print_flush
				
			print_flush:
				la $a0, simple_flush_str
				li $v0, 4
				syscall
				j exit
			
			print_4_of_a_kind:
				la $a0, four_of_a_kind_str
				li $v0, 4
				syscall
				j exit
				
			print_full_house:
				la $a0, full_house_str
				li $v0, 4
				syscall
				j exit
exit:
    li $v0, 10   # terminate program
    syscall
