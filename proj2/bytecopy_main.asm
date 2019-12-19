.data
src: .asciiz "ABCDEFG"
src_pos: .word 0
dest: .asciiz "abcdef"
dest_pos: .word -4
length: .word 3

.text
.globl main
main:
la $a0, src
lw $a1, src_pos
la $a2, dest
lw $a3, dest_pos
lw $t0, length
addi $sp, $sp, -4
sw $t0, 0($sp)
jal bytecopy
addi $sp, $sp, 4

move $a0, $v0
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

la $a0, dest
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
