.data	#	Variaveis
	.align 2
#		Textos - Menu
	titulo:	.asciiz 	"Programa de Controle de Gastos Pessoais\n"
	op:			.asciiz 	"Operacoes:\n"
	op1:		.asciiz 	"1.	Registrar despesa\n"
	op2:		.asciiz 	"2.	Excluir despesa\n"
	op3:		.asciiz 	"3.	Listar despesas\n"
	op4:		.asciiz 	"4.	Exibir gasto mensal\n"
	op5:		.asciiz 	"5.	Exibir gasto por categoria\n"
	op6:		.asciiz 	"6.	Exibir ranking de despesas\n"
	op0:		.asciiz 	"0.	Sair\n"
	ask:		.asciiz 	"Qual operacao deseja realizar? "

#		Textos - Registrar Despesa
	registro_data:			.asciiz		"Entre com a Data da Despesa: "
	registro_categoria:	.asciiz		"Entre com a Categoria da Despesa: "
	registro_valor:			.asciiz		"Entre com o Valor da Despesa: "

#		Textos - Erros
	erro_opcao:				.asciiz		"Erro! Opcao nao Encontrada.\n"
	erro_registrar:		.asciiz		"Erro! Memoria cheia."

#		Textos - Exibe Registro
	exibe_titulo:			.asciiz		"\nDados Coletados:\n"
	exibe_ID:					.asciiz		"\tID: "
	exibe_Data:				.asciiz		" Data: "
	exibe_Data0:			.asciiz		"/"
	exibe_Categoria:	.asciiz		" Categoria: "
	exibe_valor:			.asciiz		" Valor: "
	pula_linha:				.asciiz		"\n"

#		Variáveis
	registro:	##	Alinhamento de 2^2 bits, 10 x 64 bits alocados
		.align 2
		.space	640
	indice:		.word	1

####===================================####
.text
.globl main

####===================================####
####			Função Principal						 ####
####===================================####
main:
#	Exibe Menu
	jal		exibe_menu

#	Recebe Opção
	li		$v0 , 5		##	Recebe Int
	syscall

#	Verifica Opção
	beq		$v0 , 00 , call_sair
	beq		$v0 , 01 , call_registrar
	beq		$v0 , 02 , call_excluir
	beq		$v0 , 03 , call_listar_despesas
	beq		$v0 , 04 , call_gasto_mensal
	beq		$v0 , 05 , call_gasto_categoria
	beq		$v0 , 06 , call_ranking_despesas

#	Erro Opção não Encontrada
	la		$a0, erro_opcao
	jal		exibe_str
	j			main_loop				# jump tomain_loop

#	Chamada Opção Sair
call_sair:
	jal		sair
	j			main_loop				# jump to main_loop

#	Chamada Opção Registrar
call_registrar:
	jal		registrar
	j			main_loop				# jump to 	main_loop

#	Chamada Opção Excluir
call_excluir:
	jal		excluir
	j			main_loop				# jump 	main_loop

#	Chamada Opção Listar Despesas
call_listar_despesas:
	jal		listar_despesas
	j			main_loop				# jump 	main_loop

#	Chamada Opção Gasto Mensal
call_gasto_mensal:
	jal		gasto_mensal
	j			main_loop				# jump 	main_loop

#	Chamada Opção Gasto Categoria
call_gasto_categoria:
	jal		gasto_categoria
	j			main_loop				# jump 	main_loop

	#	Chamada Opção Ranking Despesas
call_ranking_despesas:
	jal		ranking_despesas
	j			main_loop				# jump 	main_loop

#	Itera
main_loop:
	j			main

####===================================####
##	Função para Simplificara a Exibição	 ##
##							de Strings							 ##
##	Argumentos:													 ##
##       $a0 = Endereço da String				 ##
####===================================####
exibe_str:
	li		$v0 , 4
	syscall
	jr		$ra
####===================================####
##	Função para Simplificar a Exibição	 ##
##						do Menu										 ##
####===================================####
exibe_menu:
	addi 	$sp , $sp, -4
	sw		$ra , 0($sp)
	# sw		$v0 , 4($sp)

	la		$a0 , titulo
	jal		exibe_str
	la		$a0,op
	jal		exibe_str
	la		$a0,op1
	jal		exibe_str
	la		$a0,op2
	jal		exibe_str
	la		$a0,op3
	jal		exibe_str
	la		$a0,op4
	jal		exibe_str
	la		$a0,op5
	jal		exibe_str
	la		$a0,op6
	jal		exibe_str
	la		$a0,op0
	jal		exibe_str
	la		$a0,ask
	jal		exibe_str

	lw		$ra , 0($sp)
	# lw		$v0 , 4($sp)
	addi 	$sp , $sp, 4
	jr		$ra
####===================================####
####		Finalizar o Programa					 ####
####===================================####
sair:
	li 		$v0 , 10	#	Encerra o Programa
	syscall

####===================================####
####		Opção Registrar								 ####
####===================================####
registrar:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)

	la		$s0 , registro			#	Começo do Registro em S0
	addi	$t0 , $s0 , 640			#	Fim do Registro em t0

#		Verifica se há espaço para uma nova despesa
registro_verif:
	beq		$s0 , $t0 , registro_cheio		##	Verifica se Chegou no Fim do Registro
	lw		$t1 , 0($s0)
	beq		$t1 , $zero , registro_add		##	Se não,Verifica se o Indice é Zero (Vazio | Excluído)
	addi	$s0 , $s0 , 64								##	Se não, Anda no Registro
	j		registro_verif

#		Erro : Registro Cheio
registro_cheio:
	la		$a0, erro_registrar
	jal		exibe_str
	j			registro_fim

#		Adiciona Despesa
registro_add:
#	Indice
	lw		$t0, indice		#	Recupera o Indice
	sw		$t0, 0($s0)		#	Guarda ID
	addi	$t0, $t0, 1		#	Atualiza o Num do ID
	sw		$t0, indice		#	Guarda na Memória

#	Data
	la		$a0, registro_data
	jal		exibe_str

	li		$v0, 5				#	Recebe Int ( Dia )
	syscall
	sw		$v0, 4($s0)		#	Guarda Dia
	li		$v0, 5				#	Recebe Int ( Mês )
	syscall
	sw		$v0, 8($s0)		#	Guarda Mês
	li		$v0, 5				#	Recebe Int ( Ano )
	syscall
	sw		$v0, 12($s0)	#	Guarda Ano

#	Categoria
	la		$a0, registro_categoria
	jal		exibe_str

	li		$v0, 8				#	Recebe String
	la		$a0, 16($s0)	# Passa Endereço do Inicio da String
	li		$a1, 16				# Tamanho da String = 16bits
	syscall

#	Valor
	la		$a0, registro_valor
	jal		exibe_str

	li		$v0, 6 				#	Recebe Float
	syscall
	s.s		$f0, 32($s0)	#	Guarda o Valor (?)

#	Exibe Dados Coletados
	la		$a0, 0($s0)
	jal		exibe_registro

registro_fim:
	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Função para a Exibição 				 ####
####			de um Registro na Memoria		 ####
####		Argumentos:						 				 ####
####		$a0 = End. Inicial do Registro ####
####===================================####
exibe_registro:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)

	move 	$s0, $a0			#	Copia o End. de A0 p/ S0

	#	Exibe Titulo
	la		$a0, exibe_titulo
	jal		exibe_str

	#	Exibe Conteúdo
	la		$a0, exibe_ID
	jal		exibe_str

	li		$v0, 1				#	Exibe Int
	lw		$a0, 0($s0)		#	End. do ID
	syscall

	la		$a0, exibe_Data
	jal		exibe_str

	li		$v0, 1				#	Exibe Int
	lw		$a0, 4($s0)		#	End. do Dia
	syscall

	la		$a0, exibe_Data0
	jal		exibe_str

	li		$v0, 1				#	Exibe Int
	lw		$a0, 8($s0)		#	End. do Mês
	syscall

	la		$a0, exibe_Data0
	jal		exibe_str

	li		$v0, 1				#	Exibe Int
	lw		$a0, 12($s0)	#	End. do Ano
	syscall

	la		$a0, exibe_Categoria
	jal		exibe_str

	la		$a0, 16($s0)	#	End. da Categoria
	jal		exibe_str

	la		$a0, exibe_valor
	jal		exibe_str

	li		$v0, 2				#	Exibe Float
	l.s		$f12, 32($s0)	#	End. do Valor
	syscall

	la		$a0, pula_linha
	jal		exibe_str

	li 		$v0, 5 				# apenas para esperar um [enter]
	syscall

	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Excluir									 ####
####===================================####
excluir:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)


	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Listar Despesas					 ####
####===================================####
listar_despesas:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)


	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Gasto Mensal						 ####
####===================================####
gasto_mensal:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)


	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Gasto por Categoria			 ####
####===================================####
gasto_categoria:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)


	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Ranking de Despesas			 ####
####===================================####
ranking_despesas:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)


	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra
