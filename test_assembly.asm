# Eric's code
lw $t1, 1022
lw $t2, 1023
sw $t1, 1017
xori $t3, $t1, 99
add $t4, $t1, $t2
sub $t5, $t2, $t1
slt $t6, $t1, $t2

bne $t1, $t2, jumpelseif
	add $t5, $t1, $t2
	j jumpend
jumpelseif:
	sub $t5, $t2, $t1
jumpend:
	add $t5, $t5, $t5


li $t1, 8
li $t2, 4
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
bne $t1, $t2, end
	add $v1, $zero, $zero
	jr $ra
end:
	# pushing to the stack
	sub $sp, $sp, 12
	sw $ra, 8($sp)
	sw $t2, 4($sp)
	sw $t1, 0($sp)
	
	# Argument prep
	sub $t1, $t1, 1
	
	# jal
	jal recurse
	
	# popping from the stack
	lw $ra, 8($sp)
	lw $t2, 4($sp)
	lw $t1, 0($sp)
	add $sp, $sp, 12
	
	# return 1 + recurse($t1 , $t2)
	add $v1, $v1, 1
	jr $ra

