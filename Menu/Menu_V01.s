.data	#	Variaveis
	titulo:	.asciiz 	"Programa de Controle de Gastos Pessoais\n"
	op:		.asciiz 	"Operacoes:\n"
	op1:	.asciiz 	"1.	Registrar despesa\n"
	op2:	.asciiz 	"2.	Excluir despesa\n"
	op3:	.asciiz 	"3.	Listar despesas\n"
	op4:	.asciiz 	"4.	Exibir gasto mensal\n"
	op5:	.asciiz 	"5.	Exibir gasto por categoria\n"
	op6:	.asciiz 	"6.	Exibir ranking de despesas\n"
	op0:	.asciiz 	"0.	Sair\n"
	ask:	.asciiz 	"Qual operacao deseja realizar? "

####===================================####
.text 
.globl main

####===================================####
####		Função Principal		   ####
####===================================####
main:  
#	Exibe Menu
	jal	exibe_menu
	
#	Recebe Opção
	li	$v0 , 5		##	Recebe Int
	syscall
	
#	Verifica Opção
	beq	$v0 , 00 , sair
	beq	$v0 , 01 , registrar
	beq	$v0 , 02 , excluir
	beq	$v0 , 03 , listar_despesas
	beq	$v0 , 04 , gasto_mensal
	beq	$v0 , 05 , gasto_categoria
	beq	$v0 , 06 , ranking_despesas
#	Itera
	j	main
	
####===================================####
##	Função para Simplificara a Exibição  ##
##				de Strings				 ##
##	Argumentos:							 ##
##		$a0 = Endereço da String		 ##
####===================================####
exibe_str:
	li	$v0 , 4
	syscall
	jr	$ra
####===================================####
##	Função para Simplificara a Exibição  ##
##				do Menu					 ##
####===================================####
exibe_menu:
	addi $sp , $sp, -4
	sw	 $ra , 0($sp)

	la	$a0 , titulo
	jal	exibe_str
	la	$a0,op
	jal	exibe_str
	la	$a0,op1
	jal	exibe_str
	la	$a0,op2
	jal	exibe_str
	la	$a0,op3
	jal	exibe_str
	la	$a0,op4
	jal	exibe_str
	la	$a0,op5
	jal	exibe_str
	la	$a0,op6
	jal	exibe_str
	la	$a0,op0
	jal	exibe_str
	la	$a0,ask
	jal	exibe_str
	
	lw	 $ra , 0($sp)
	addi $sp , $sp, 4
	jr	$ra
####===================================####
####		Finalizar o Programa	   ####
####===================================####
sair:
	li $v0 , 10	#	Encerra o Programa
	syscall
	
####===================================####
####		Opção Registrar			   ####
####===================================####
registrar:
	addi $sp , $sp, -4
	sw	 $ra , 0($sp)


	lw	 $ra , 0($sp)
	addi $sp , $sp, 4
	jr	$ra
	
####===================================####
####		Opção Excluir			   ####
####===================================####
excluir:
	addi $sp , $sp, -4
	sw	 $ra , 0($sp)


	lw	 $ra , 0($sp)
	addi $sp , $sp, 4
	jr	$ra
	
####===================================####
####		Opção Listar Despesas	   ####
####===================================####
listar_despesas:
	addi $sp , $sp, -4
	sw	 $ra , 0($sp)


	lw	 $ra , 0($sp)
	addi $sp , $sp, 4
	jr	$ra
	
####===================================####
####		Opção Gasto Mensal		   ####
####===================================####
gasto_mensal:
	addi $sp , $sp, -4
	sw	 $ra , 0($sp)


	lw	 $ra , 0($sp)
	addi $sp , $sp, 4
	jr	$ra
	
####===================================####
####	Opção Gasto por Categoria	   ####
####===================================####
gasto_categoria:
	addi $sp , $sp, -4
	sw	 $ra , 0($sp)


	lw	 $ra , 0($sp)
	addi $sp , $sp, 4
	jr	$ra
	
####===================================####
####	Opção Ranking de Despesas	   ####
####===================================####
ranking_despesas:
	addi $sp , $sp, -4
	sw	 $ra , 0($sp)


	lw	 $ra , 0($sp)
	addi $sp , $sp, 4
	jr	$ra