# CSE 220 Programming Project #4
# Anna Zhang
# zhang127
# 112167606

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

compute_checksum:
	lhu $v0, ($a0) # load total_length into $v0
	
	lhu $t0, 2($a0) # get the next half word
	andi $t1, $t0, 0xFFF # mask to get msg_id
	add $v0, $v0, $t1 # add msg_id to sum
	
	andi $t1, $t0, 0xF000 # mask to get version
	srl $t1, $t1, 12
	add $v0, $v0, $t1 # add version to sum
	
	lw $t0, 4($a0) # get the next word
	andi $t1, $t0, 0xFFF # mask to get fragment offset
	add $v0, $v0, $t1 # add fragment offset to sum
	
	andi $t1, $t0, 0x3FF000
	srl $t1, $t1, 12
	add $v0, $v0, $t1 # add protocol to sum
	
	andi $t1, $t0, 0xC00000
	srl $t1, $t1, 22
	add $v0, $v0, $t1 # add flags to sum
	
	lbu $t0, 7($a0) # load the byte where priority is
	add $v0, $v0, $t0 # add priority to sum
	
	lbu $t0, 8($a0) # load the byte where dest_addr is
	add $v0, $v0, $t0 # add dest_addr to sum
	
	lbu $t0, 9($a0) # load the byte where src_addr is
	add $v0, $v0, $t0 # add src_addr to sum
	
	li $t0, 65536 # 2^16
	div $v0, $t0 # divide sum by 2^16
	mfhi $v0 # store the remainder
	
	jr $ra

compare_to:
	lh $t0, 2($a0) # get the msg_id of packet_1
	andi $t1, $t0, 0xFFF # mask to get msg_id
	
	lh $t0, 2($a1) # get the msg_id of packet_2
	andi $t2, $t0, 0xFFF # mask to get msg_id
	
	blt $t1, $t2, return_neg_1 # if p1.msg_id < p2.msg_id, return -1
	bgt $t1, $t2, return_1 # if p1.msg_id > p2.msg_id, return 1
	
	lw $t0, 4($a0) # get the next word
	andi $t1, $t0, 0xFFF # mask to get fragment offset
	
	lw $t0, 4($a1) # get the next word
	andi $t2, $t0, 0xFFF # mask to get fragment offset
	
	blt $t1, $t2, return_neg_1 # if p1.frag_offset < p2.frag_offset, return -1
	bgt $t1, $t2, return_1 # if p1.frag_offset > frag_offset, return 1
	
	lbu $t1, 9($a0) # load the byte where src_addr is for packet_1
	lbu $t2, 9($a1) # load the byte where src_addr is for packet_2
	
	blt $t1, $t2, return_neg_1 # if p1.src_addr < p2.src_addr, return -1
	bgt $t1, $t2, return_1 # if p1.src_addr > p2.src_addr, return 1
	
	return_0:
		li $v0, 0
		j compare_to_end
		
	return_neg_1:
		li $v0, -1
		j compare_to_end
	
	return_1:
		li $v0, 1
		
	compare_to_end:
		jr $ra

packetize:
	lw $t0, ($sp) # msg_id
	lw $t1, 4($sp) # priority
	lw $t2, 8($sp) # protocol
	lw $t3, 12($sp) # src_addr
	lw $t4, 16($sp) # dest_addr
	
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s7, 24($sp)
	sw $ra, 28($sp)
	
	move $s0, $t0 # msg_id
	move $s1, $a1 # msg
	move $s2, $a2 # payload_size
	move $s3, $a3 # version
	move $s4, $t1 # priority
	move $s5, $t2 # protocol
	move $s6, $t3 # src_addr
	move $s7, $t4 # dest_addr
	
	li $t4, 0 # counter for frag_offset
	li $t5, 0 # counter to reset when reach payload_size
	li $t1, 01
	
	packetize_outer_loop:
		lbu $t6, ($s1) # get the char from msg
		sb $t6, 12($a0) # save it into the 12th byte of the packet
			
		addi $t5, $t5, 1 # increment counter for reset
		addi $s1, $s1, 1 # move along msg
		addi $a0, $a0, 1 # move along packets[]
		
		beqz $t6, change_bool # if char is null terminator, change the flag from 0b01 to 0b00
		beq $t5, $s2, move_packet_back # if counter reaches packetload_size, move $a0 back $t5 times
		j packetize_outer_loop # otherwise, keep looping
		
		change_bool:
			li $t1, 00
		
		move_packet_back:
			sub $a0, $a0, $t5 # move $a0 back to store other things
		
		packetize_inner_loop:
			addi $t3, $t5, 12 # add size of header to counter
			sh $t3, ($a0) # write total_length to $a0
			sh $s0, 2($a0) # write msg_id to $a0
			
			lhu $t7, 2($a0)
			sll $t8, $s3, 12 # shift version
			or $t7, $t8, $t7 # mask packet with shifted version to store version
			sh $t7, 2($a0)
		
			sw $t4, 4($a0) # store frag_offset to third half-word
		
			lw $t8, 4($a0) # load the second word into $t8
			sll $t9, $s5, 12 # shift protocol 12 times
			or $t8, $t8, $t9 # combine the second word with protocol
			sw $t8, 4($a0) # store the combo into the second word
		
			lw $t8, 4($a0) # load the second word into $t8
			sll $t9, $t1, 22 # shift flag 22 times
			or $t8, $t8, $t9 # combine second word with flag
			sw $t8, 4($a0) # store the combo into the second word
		
			sb $s4, 7($a0) # store priority into byte #7
			sb $s7, 8($a0) # store dest_addr into byte #8
			sb $s6, 9($a0) # store src_addr into byte #9
			
			addi $sp, $sp, -8
			sw $t0, ($sp)
			sw $t1, 4($sp)

			jal compute_checksum
			
			lw $t0, ($sp)
			lw $t1, 4($sp)
			addi $sp, $sp, 8
			
			move $s0, $t0
			
			sh $v0, 10($a0) # store checksum in 5th half-word
			
			beqz $t6, packetize_end # if char is null terminator, end packetizing
			
			add $a0, $a0, $t3 # if not, move packets[] for next packet
			li $t5, 0 # reset counter
			add $t4, $t4, $s2 # add payload_size to frag_offset for future packet
			j packetize_outer_loop # continue to the next msg
	
	packetize_end:
		add $v0, $t4, $s2
		div $v0 $s2
		mflo $v0
		
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s7, 24($sp)
		lw $ra, 28($sp)
		addi $sp, $sp, 32
		jr $ra

clear_queue:
	blez $a1, clear_return_neg_1
	
	li $t0, 0 # load a half_word of 0
	sh $t0, ($a0) # store that 0 as the size
	
	sh $a1, 2($a0) # store maz_queue_size to max_size
	
	li $t1, 0 # counter
	set_to_0:
		sw $t0, 4($a0)
		
		addi $t1, $t1, 1 # incremnt counter
		addi $a0, $a0, 4 # move along the queue
		beq $t1, $a1, clear_return_0
		j set_to_0
	
	clear_return_neg_1:
		li $v0, -1
		j clear_queue_end
	
	clear_return_0:
		li $v0, 0
	clear_queue_end:
		jr $ra

enqueue:
	lhu $t0, ($a0) # size
	lhu $t1, 2($a0) # max_size
	
	beq $t0, $t1, return_max_size # if size == max_size, return max_size
	
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $ra, 4($sp)
	
	sll $t2, $t0, 2 # multiply size by 4
	addi $a0, $a0, 4 # move queue to where packets begin
	move $s0, $a0
	add $a0, $a0, $t2 # move queue to the end
	sw $a1, ($a0) # store the packet to the end of the queue
	
	move $t5, $t0 # store index of current_node
	
	enqueue_loop:
		beqz $t5, enqueue_end # if index_of_current==0, end
		
		addi $t4, $t5, -1 # (current_index - 1)
		srl $t4, $t4, 1 # (current_index - 1) / 2 = index of parent_node
		
		move $t6, $t4 # move index_of_parent into a temp variable
		sll $t6, $t6, 2 # multiply index_of_parent by 4
		move $a0, $s0 # reset $a0 back to where packets begin
		add $a0, $a0, $t6 # traverse to index_of_parent
		lw $t7, ($a0) # get the parent packet
		
		move $a0, $t7
		jal compare_to
		move $a0, $s0
		blez $v0, enqueue_end # if the parent <= packet, increment size and return
		
		add $a0, $a0, $t6 # move to index_of_parent
		sw $a1, ($a0) # store current packet to that index
		move $a0, $s0 # reset $a0
		sll $t8, $t5, 2 # multiply index by 4
		add $a0, $a0, $t8 #move $a0 to current_node
		sw $t7, ($a0)
		move $a0, $s0 # reset $a0
		
		move $t5, $t4 # index_of_current becomes index_of_parent
		j enqueue_loop
		
	return_max_size:
		move $v0, $t1
		jr $ra
	
	enqueue_end:
		lhu $t0, -4($a0) # size
		addi $t0, $t0, 1 # increment size
		sh $t0, -4($a0) # store incremented size to queue
		move $v0, $t0 # set the return value
		lw $s0, ($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		jr $ra

dequeue:
	lhu $t0, ($a0) # size
	beqz $t0, dequeue_return_0 # if size = 0, return
	
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s0, $a0
	lw $s1, 4($a0) # get the first packet
	
	move $t1, $t0 # move size into temp variable
	addi $t1, $t1, -1
	sll $t1, $t1, 2 # multiply size by 4
	addi $a0, $a0, 4 # move queue to where packets begin
	move $s0, $a0
	add $a0, $a0, $t1 # move queue to the end
	lw $t2, ($a0) # get the last packet
	sw $0, ($a0)
	move $a0, $s0 # reset $a0 to where packets begin
	sw $t2, ($a0) # store the last packet to the root
	
	li $t3, 0 # pointer for current_node
	move $t6, $t0 # move size into temp variable
	addi $t6, $t6, -1 # decrement size to compare to
	dequeue_loop:
		sll $t4, $t3, 1
		addi $t4, $t4, 1 # pointer for left child
		sll $t5, $t3, 1
		addi $t5, $t5, 2 # pointer for right child
		
		bge $t4, $t6, dequeue_end # if index_of_left >= size - 1
		bge $t5, $t6, dequeue_end # if index_of_right >= size - 1
		
		move $t7, $t4 # move index_of_left into temp
		sll $t7, $t7, 2 # multiply index_of_left by 4
		move $a0, $s0 # reset $a0
		add $a0, $a0, $t7 # move to index
		lw $t8, ($a0) # left_child
		
		move $t7, $t5 # move index_of_right into temp
		sll $t7, $t7, 2 # multiply index_of_right by 4
		move $a0, $s0 # reset $a0
		add $a0, $a0, $t7
		lw $t9, ($a0) # right_child
		
		move $a0, $t8
		move $a1, $t9
		jal compare_to
		move $a0, $s0
		
		li $t0, 1
		beq $v0, $t0, swap_with_right
		
		move $t7, $t3 # move current_node into temp
		sll $t7, $t7, 2 # multiply index_of_current by 4
		move $a0, $s0 # reset $a0
		add $a0, $a0, $t7 # move to current_node
		lw $t9, ($a0) # get current packet 
			
		move $a0, $t9
		move $a1, $t8
		jal compare_to
		move $a0, $s0
		
		blez $v0, dequeue_end # if current_node >= left_child
			
		move $t7, $t3 # move current_node into temp
		sll $t7, $t7, 2 # multiply index_of_current by 4
		move $a0, $s0 # reset $a0
		add $a0, $a0, $t7 # move to current_node
		sw $t8, ($a0) # store left_child in index_of_current
			
		move $a0, $s0 # reset $a0
		move $t7, $t4 # move index_of_left into temp
		sll $t7, $t7, 2 # multiply index_of_left by 4
		move $a0, $s0 # reset $a0
		add $a0, $a0, $t7 # move to index_of_left
		sw $t9, ($a0) # store current_node into left_child
		
		move $t3, $t4 # index_of_current becomes index_of_left
		j dequeue_loop
		
		swap_with_right:
			move $t7, $t3 # move current_node into temp
			sll $t7, $t7, 2 # multiply index_of_current by 4
			move $a0, $s0 # reset $a0
			add $a0, $a0, $t7 # move to current_node
			lw $t8, ($a0) # get current packet 
			
			move $a0, $t8
			move $a1, $t9
			jal compare_to
			move $a0, $s0
		
			blez $v0, dequeue_end # if current_node >= right_child
			
			move $t7, $t3 # move current_node into temp
			sll $t7, $t7, 2 # multiply index_of_current by 4
			move $a0, $s0 # reset $a0
			add $a0, $a0, $t7 # move to current_node
			sw $t9, ($a0) # store right_child in index_of_current
			
			move $a0, $s0 # reset $a0
			move $t7, $t5 # move index_of_right into temp
			sll $t7, $t7, 2 # multiply index_of_right by 4
			move $a0, $s0 # reset $a0
			add $a0, $a0, $t7 # move to index_of_right
			sw $t8, ($a0) # store current_node into right_child
			
			move $t3, $t5 # index_of_current becomes index_of_right
			j dequeue_loop
	
	dequeue_return_0:
		li $v0, 0
		jr $ra
		
	dequeue_end:
		move $a0, $s0
		lhu $t0, -4($a0)
		addi $t0, $t0, -1
		sh $t0, -4($a0)
		
		move $v0, $s1
		
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra

assemble_message:
	lhu $t0, ($a0) # size
	beqz $t0, assemble_return_0 # if size==0, return
	
	addi $sp, $sp, -16
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	sw $s2, 12($sp)
	
	li $s2, 0
	li $v1, 0
	
	addi $a1, $a1, 4 # move $a0 to where packets begin
	
	assemble_message_outer_loop:
		lw $s0, ($a1) # get the first packet
		beqz $s0, assemble_message_end
		move $s1, $a0
		move $a0, $s0
		jal compute_checksum
		move $a0, $s1
	
		lhu $t1, 10($s0) # get checksum
	
		beq $t1, $v0, increment_pass
		addi $v1, $v1, 1
		
		increment_pass:		
			lw $t0, 4($s0)
			andi $t1, $t0, 0xFFF # mask to get fragment offset
		
			add $a0, $a0, $t1
		
			lhu $t2, ($s0) # get total length
			addi $t2, $t2, -12 # get the length of the payload
			li $t4, 0 # counter
		assemble_message_inner_loop:
			lbu $t3, 12($s0)
			sb $t3, ($a0)
			
			addi $t4, $t4, 1 # increment counter
			addi $s0, $s0, 1 # move along packet
			addi $a0, $a0, 1 # move along msg
			blt $t4, $t2, assemble_message_inner_loop # if counter < length of payload, continue
		
		sw $0, ($a1) # set the packet to 0
		addi $s2, $s2, 1
		addi $a1, $a1, 4 # move along queue
		sub $a0, $a0, $t2
		sub $a0, $a0, $t1
		j assemble_message_outer_loop
	
	assemble_return_0:
		li $v0, 0
		li $v1, 0
		jr $ra
		
	assemble_message_end:
		move $v0, $s2
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $ra, 8($sp)
		lw $s2, 12($sp)
		addi $sp, $sp, 16
		jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
