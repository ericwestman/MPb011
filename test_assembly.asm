# Eric's code
lw $t1, 1021
lw $t2, 1022
sw $t1, 1023
xori $t3, $t1, 99
add $t4, $t1, $t2
sub $t5, $t2, $t1
slt $t6, $t1, $t2

bne $t1, $t2, jumpelseif
	add $t7, $t1, $t2
	j jumpend
jumpelseif:
	sub $t8, $t2, $t1
jumpend:

li $s0, 8
li $s1, 4
lw $sp, 1020
jal recurse

li $v0, 10
syscall

# assume a > b

# function recurse (a, b)
# if a == b
#	return 0
# else
#	return 1 + recurse(a - 1 , b)

recurse:
bne $s0, $s1, end
	add $v1, $zero, $zero
	jr $ra
end:
	# pushing to the stack
	sub $sp, $sp, $t4
	sw $ra, 2($sp)
	sw $s1, 1($sp)
	sw $s0 0($sp)
	
	# Argument prep
	sub $s0, $s0, $t1
	
	# jal
	jal recurse
	
	# popping from the stack
	lw $ra, 2($sp)
	lw $s1, 1($sp)
	lw $s0, 0($sp)
	add $sp, $sp, $t4
	
	# return 1 + recurse($t1 , $t2)
	add $v1, $v1, $t1
	jr $ra