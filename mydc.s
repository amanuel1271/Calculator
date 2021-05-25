### --------------------------------------------------------------------
### mydc.s
### Amanuel Assefa
### ID 20170843'
### Assignment 4
### Desk Calculator (dc)
### --------------------------------------------------------------------

	.equ    ARRAYSIZE, 20
	.equ	EOF, -1   
	.equ 	OFFSET, 4
	
.section ".rodata"
        ### decimal and string print format to display required  
scanfFormat:
	.asciz "%s"
emptydcstack:
	.asciz "dc: stack empty\n"
printInteger:
	.asciz "%d\n"
zerodivision:
	.asciz "dc: remainder by zero\n"
zerodivisionfor:
	.asciz "dc: divide by zero\n"



### --------------------------------------------------------------------

        .section ".data"

### --------------------------------------------------------------------

        .section ".bss"
buffer:
        .skip  ARRAYSIZE

### --------------------------------------------------------------------

	.section ".text"

	## -------------------------------------------------------------
	## int main(void)
	## In the main function , input is repeatedly asked until
	## the user quits the program (by pressing q) or by EOF
	## the program  uses  alphabet commands r,p,d,x,y,c,f,q and all 
	## numbers  and operators +,-,*,/,^,% and it doesnt crash with other inputs
	## and depending on the pattern of the users' input
	## numbers are printed out like a calculator or messages are printed out.
	## the function finally returns 0.
	## -------------------------------------------------------------

	.globl  main
	.type   main,@function

main:

	pushl   %ebp
	movl    %esp, %ebp
	#call  srand once
	pushl 	$0x0
	call    time
	addl	$4, %esp
	pushl	%eax
	call 	srand
	addl	$4, %esp

 ##  repeatedly asks for a user input and goes to the appropriate label
input: 
	
	## scanf("%s", buffer)
	pushl	$buffer
	pushl	$scanfFormat
	call    scanf
	addl    $8, %esp

	## check if user input EOF, the return value of scanf is in %eax
	cmp	$EOF, %eax
	je	quit

	movsbl	buffer, %ebx
	pushl	%ebx
	call 	isdigit
	addl 	$4,	%esp
	cmpl	$0, %eax
	je	is_character_or_neg
	
	pushl	$buffer
	call    atoi
	addl	$4, %esp
	pushl	%eax
	jmp	input

	#compares each first non digit element and go to their respective operations
is_character_or_neg:
	cmpb	$'_', buffer
		je	negative	
	cmpb	$'p', buffer
		je	peek	
	cmpb	$'q', buffer
		je quit	
	cmpb	$'+', buffer
		je	add_operator
	
	cmpb	$'-', buffer
		je	subt_operator
	
	cmpb	$'*', buffer
		je mult_operator	
	cmpb	$'/', buffer
		je div_operator	
	cmpb	$'%', buffer
				je mod_operator	
	cmpb	$'^', buffer
		je	power_func_caller	
	cmpb	$'f', buffer
		je	print_contents	
	cmpb	$'c', buffer
		je	clear_contents	
	cmpb	$'d', buffer
		je duplicate_top	
	cmpb	$'r', buffer
		je swap_first_two	
	cmpb	$'x', buffer
		je random_generate	
	cmpb	$'y', buffer
		je	biggest_prime
	jmp   input


	#checks if the next element after the _ is digit or not
negative:
	movl    $buffer, %ebx
	addl	$1, %ebx
	movsbl	(%ebx), %edx
	pushl	%edx
	call 	isdigit
	addl 	$4,	%esp
	cmpl	$0, %eax
	je	symbol_after_neg
	pushl	%ebx
	call    atoi
	addl	$4, %esp
	## checks if the number after
	## _ is the maximimum positive number that an int represents
    	movl $2147483647,%ecx
    	cmpl %ecx,%eax
    	je min_signed
    	jmp  convert_to_neg

# if digit is inputted after _ it converts the numbers
# remaining to negative numbers
convert_to_neg:
	movl 	$0, %ebx
	subl	%eax, %ebx
	pushl	%ebx
	jmp input
## push the maximum negative number that 
## int represents if inputted by user
min_signed:
 	cmpb $'7',9(%ebx)
    	je   convert_to_neg
    	pushl $-2147483648
 	jmp input
         


#check for 1 operands and then print the value if it exist
# , or dc stack empty

peek:

	cmpl	%ebp, %esp
		je	printEmpty
	movl 	(%esp), %ebx
	pushl	%ebx
	pushl	$printInteger
	call 	printf
	addl 	$8, %esp
		jmp 	input
#print empty dc stack

printEmpty:
	pushl	$emptydcstack
	call    printf
	addl 	$4, %esp
		jmp     input
#check if there is an operand and 
#print contents of the stack

print_contents:
	
	cmpl	%ebp, %esp
		je	input
	movl    %esp, %ebx
	jmp     compareloop
#for all the numbers in stack print them in LIFO

compareloop:
	cmpl %ebp, %ebx
	je   input
	movl (%ebx), %ecx
	pushl	%ecx
	pushl	$printInteger
	call 	printf
	addl 	$8, %esp
	addl    $4,%ebx
	jmp 	compareloop
# clear contents of the stack if there was 
#a number pushed , otherwise does nothing

clear_contents:
	cmpl 	%esp, %ebp
		je	input
	addl  $4, %esp
	jmp 	clear_contents
# duplicates the top element in the stack
# if there is a number that is pushed to it

duplicate_top:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	(%esp), %ecx
	pushl 	%ecx
	jmp     input
# swaps the first two elements stored in the stack 
#if there are atleast two elements pushed into it

swap_first_two:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	%esp, %ecx
	addl    $4, %ecx
	cmpl %ecx, %ebp
		je	printEmpty
	movl	(%esp), %ebx
	movl 	(%ecx), %edx
	movl    %edx,  (%esp)
	movl 	%ebx, (%ecx)
	jmp 	input
# adds the top two numbers in the stack and
# push to result to stack if they exist and print 
# emptystack

add_operator:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	%esp, %ecx
	addl   $4, %ecx
	cmpl %ecx, %ebp
		je	printEmpty
	movl 	(%ecx), %ebx
	addl	(%esp), %ebx
	addl	$4, %ecx
	addl 	$8,	%esp
	pushl	%ebx
	jmp 	input
# subtracts the two numbers in the stack  and push 
#the result to stack if they exist or prints emptystack

subt_operator:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	%esp, %ecx
	addl    $4, %ecx
	cmpl %ecx, %ebp
		je	printEmpty
	movl 	(%ecx), %ebx
	subl	(%esp), %ebx
	addl	$4, %ecx
	addl 	$8,	%esp
	pushl	%ebx
	jmp 	input
# multiplies the two numbers in the stack 
#and push the result to stack if 
#they exist, or prints emptystack

mult_operator:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	%esp, %ecx
	addl    $4, %ecx
	cmpl %ecx, %ebp
		je	printEmpty
	movl   (%ecx), %ebx
	movl   (%esp), %eax
	imull   %ebx
	addl	$4, %ecx
	addl 	$8,	%esp
	pushl   %eax
	jmp     input
# divides the two numbers in the stack 
#and push the quotient to stack if 
#they exist or prints emptystack

div_operator:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	%esp, %ecx
	addl    $4, %ecx
	cmpl %ecx, %ebp
		je	printEmpty
	movl   (%ecx), %eax
	movl   (%esp), %ebx
	cmpl   $0, %ebx
	je     zero
	cltd
	idivl  	%ebx
	addl	$4, %ecx
	addl 	$8,	%esp
	pushl  	%eax
	jmp 	input
# divides the two numbers in the stack 
#and push the remainder to stack if 
#they exist or prints emptystack
mod_operator:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	%esp, %ecx
	addl    $4, %ecx
	cmpl %ecx, %ebp
		je	printEmpty
	movl   (%ecx), %eax
	movl   (%esp), %ebx
	cmpl   $0, %ebx
	je     dividebyzero
	cltd
	idivl  	%ebx
	addl	$4, %ecx
	addl 	$8,	%esp
	pushl  	%edx
	jmp 	input
# if division by zero occurs prints
# and displays a message
dividebyzero:
	pushl	$zerodivision
	call    printf
	addl 	$4, %esp
	jmp     input
zero:
	pushl	$zerodivisionfor
	call    printf
	addl 	$4, %esp
	jmp     input

		
# to generate a random number from 0 to 1023
random_generate:
	call 	rand
	pushl	%eax
	pushl	$1024
	jmp 	mod_operator

if_two:
	pushl %ebx
	jmp 	input
# checks if the number is prime or not
inner_loop:
	cmpl %edi , %esi
	jge 	decrement_outer_loop
	pushl 	%edi
	pushl	%esi
	movl   %edi, %eax
	movl 	%esi, %ebx
	cltd
	idivl  	%ebx
	addl 	$8,	%esp
	cmpl 	$0, %edx
	je 		decrement_outer_loop
	movl 	%edi, %ecx
	subl 	$1, %ecx
	cmpl 	%ecx, %esi
	je 		push_least_prime
	addl 	$1, %esi
	jmp 	inner_loop	
#pushes the least prime number if exists
push_least_prime:
	pushl   %edi
	jmp 	input

decrement_outer_loop:
	decl 	 %edi
	jmp 	outer_loop


outer_loop:
	cmpl 	$2, %edi
	jle 	input
	movl 	$2, %esi
	jmp 	inner_loop
# checks for least prime number if input is greater than 2
biggest_prime:
	cmpl	%ebp, %esp
		je	printEmpty
	movl 	(%esp), %ebx
	# handle if less than 2   and return to input
	cmpl 	$1, %ebx
	jle 	input
	# handle for  2
	cmpl    $2, %ebx
	je 		if_two
	#loop and get the biggest prime number equal or less to top
	movl 	%ebx, %edi
	jmp 	outer_loop
# caller for power function
power_func_caller:
	cmpl 	%ebp, %esp
		je	printEmpty
	movl 	%esp, %ecx
	addl    $4, %ecx
	cmpl %ecx, %ebp
		je	printEmpty
	call power_func
	addl 	$8, %esp
	addl 	$4, %ecx
	pushl 	%eax
	jmp 	input

# pushes 0 to stack if there is non digit after _ sign
symbol_after_neg:
	pushl $0
	jmp input

#returns 0 and quits main
quit:
	movl    $0, %eax
	movl    %ebp, %esp
	popl    %ebp
	ret
	
	#---------------------------------------------------------------


	.equ 	FOFFSET, 8
	.equ 	SOFFSET, 12
	
	# calculates a raised to b wher a, b are 
	# provided paramters, used to implement the ^ operator
	.type   power_func,@function
	#----------------------------------------------------------------

power_func: 
	pushl 	%ebp
	movl 	%esp, %ebp
	movl  	FOFFSET(%ebp), %esi
	cmpl 	$0, %esi
	jle		byzero
	movl 	$1, %eax
	movl 	SOFFSET(%ebp), %edi
	movl 	$1, %ebx
	jmp 	forloop
# pushes 1 if exponent is less than 0
byzero:
	movl 	$1, 	%eax

	movl 	%ebp, %esp
	popl 	%ebp
	ret	

forloop:
	cmpl 	%esi, %ebx
	jg	finish_loop
	imull 	%edi
	incl    %ebx
	jmp 	forloop

finish_loop:
	movl 	%ebp, %esp
	popl 	%ebp
	ret







