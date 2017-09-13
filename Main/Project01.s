.data	#Variaveis
	.align 2
#Textos - Menu
	titulo:	.asciiz 	"\nPrograma de Controle de Gastos Pessoais\n"
	op:			.asciiz 	"Operacoes:\n"
	op1:		.asciiz 	"1.	Registrar despesa\n"
	op2:		.asciiz 	"2.	Excluir despesa\n"
	op3:		.asciiz 	"3.	Listar despesas\n"
	op4:		.asciiz 	"4.	Exibir gasto mensal\n"
	op5:		.asciiz 	"5.	Exibir gasto por categoria\n"
	op6:		.asciiz 	"6.	Exibir ranking de despesas\n"
	op0:		.asciiz 	"0.	Sair\n"
	ask:		.asciiz 	"Qual operacao deseja realizar? "

#Textos - Registrar Despesa
	registro_dia:				.asciiz		"Entre com Dia da Despesa: "
	registro_mes:				.asciiz		"Entre com Mes da Despesa: "
	registro_ano:				.asciiz		"Entre com Ano da Despesa: "
	registro_categoria:			.asciiz		"Entre com a Categoria da Despesa: "
	registro_valor:				.asciiz		"Entre com o Valor da Despesa: "

#Textos - Erros
	erro_opcao:				.asciiz		"\nErro! Opcao nao Encontrada.\n"
	erro_registrar:			.asciiz		"\nErro! Memoria cheia."
	erro_exluir:            .asciiz  	"Indice nao encontrado." ####Essa linha de texto não é utilizada em nenhum lugar do codigo

#Textos - Exibe Registro
	exibe_titulo:			.asciiz		"\nDados Coletados:\n"
	exibe_ID:				.asciiz		"\tID: "
	exibe_Data:				.asciiz		" |Data: "
	exibe_Data0:			.asciiz		"/"
	exibe_Categoria:		.asciiz		" |Categoria: "
	exibe_valor:			.asciiz		" |Valor: R$"
	pula_linha:				.asciiz		"\n"

#Textos-Exclui Elemento
	nexcluir:       	.asciiz    "\nQual o indice? "
	n_encontrado:   	.asciiz    "Elemento nao encontrado! \n"
	excluir_ok:         .asciiz    "Elemento excluido!\n"

# Textos - listar_despesas
	listar_texto:	.asciiz		"\nDados Ordenados por Data\n"
#Variáveis
	registro:	##	Alinhamento de 2^2 bits, 10 x 64 bits alocados
		.align 2
		.space 640
	indice:
		.word 1

  vetoraux:    ##vetor que sera usado como aux para a organizacao de datas
		.align 2
		.space 640

####===================================####
.text
.globl main

####===================================####
####		Função Principal    	   ####
####===================================####
main:
#Exibe Menu
	jal		exibe_menu

#Recebe Opção
	li		$v0 , 5		##Recebe Int
	syscall

#Verifica Opção
	beq		$v0 , 00 , call_sair
	beq		$v0 , 01 , call_registrar
	beq		$v0 , 02 , call_excluir
	beq		$v0 , 03 , call_listar_despesas
	beq		$v0 , 04 , call_gasto_mensal
	beq		$v0 , 05 , call_gasto_categoria
	beq		$v0 , 06 , call_ranking_despesas

#Erro Opção não Encontrada
	la		$a0, erro_opcao
	jal		exibe_str
	j		main_loop					# jump to main_loop

#Chamada Opção Sair
call_sair:
	jal		sair
	j		main_loop					# jump to main_loop

#Chamada Opção Registrar
call_registrar:
	jal		registrar
	j		main_loop					# jump to main_loop

#Chamada Opção Excluir
call_excluir:
	jal		excluir
	j		main_loop					# jump 	main_loop

#Chamada Opção Listar Despesas
call_listar_despesas:
	jal		listar_despesas
	j		main_loop					# jump 	main_loop

#Chamada Opção Gasto Mensal
call_gasto_mensal:
	jal		gasto_mensal
	j		main_loop					# jump 	main_loop

#Chamada Opção Gasto Categoria
call_gasto_categoria:
	jal		gasto_categoria
	j		main_loop					# jump 	main_loop

#Chamada Opção Ranking Despesas
call_ranking_despesas:
	jal		ranking_despesas
	j		main_loop					# jump 	main_loop

#Itera
main_loop:
	j		main

####===================================####
##	Função para Simplificara a Exibição	 ##
##	de Strings							 ##
##	Argumentos:							 ##
##       $a0 = Endereço da String		 ##
####===================================####
exibe_str:
	li		$v0 , 4
	syscall
	jr		$ra
####===================================####
##	Função para Simplificar a Exibição	 ##
##	do Menu								 ##
####===================================####
exibe_menu:
	addi 	$sp , $sp, -4
	sw		$ra , 0($sp)
	###########sw		$v0 , 4($sp)

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
	##########lw		$v0 , 4($sp)
	addi 	$sp , $sp, 4
	jr		$ra
####===================================####
####		Finalizar o Programa   	   ####
####===================================####
sair:
	li 		$v0 , 10	#	Encerra o Programa
	syscall

####===================================####
####		Opção Registrar			   ####
####===================================####
registrar:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)

	la		$s0 , registro			#	Começo do Registro em S0
	addi	$t0 , $s0 , 640			#	Fim do Registro em t0

#Verifica se há espaço para uma nova despesa
registro_verif:
	beq		$s0 , $t0 , registro_cheio		##	Verifica se Chegou no Fim do Registro
	lw		$t1 , 0($s0)
	beq		$t1 , $zero , registro_add		##	Se não,Verifica se o Indice é Zero (Vazio | Excluído)
	addi	$s0 , $s0 , 64					##	Se não, Anda no Registro
	j		registro_verif

#Erro : Registro Cheio
registro_cheio:
	la		$a0, erro_registrar
	jal		exibe_str
	j			registro_fim

#Adiciona Despesa
registro_add:
#Indice
	lw		$t0, indice		#	Recupera o Indice
	sw		$t0, 0($s0)		#	Guarda ID
	addi	$t0, $t0, 1		#	Atualiza o Num do ID
	sw		$t0, indice		#	Guarda na Memória

#Data
	la		$a0, registro_dia
	jal		exibe_str

	li		$v0, 5				#Recebe Int ( Dia )
	syscall
	sw		$v0, 4($s0)			#Guarda Dia

	##la		$a0, pula_linha
	##jal		exibe_str

	la		$a0, registro_mes
	jal		exibe_str
	li		$v0, 5				#Recebe Int ( Mês )
	syscall
	sw		$v0, 8($s0)			#Guarda Mês

	##la		$a0, pula_linha
	##jal		exibe_str

	la		$a0, registro_ano
	jal		exibe_str
	li		$v0, 5				#Recebe Int ( Ano )
	syscall
	sw		$v0, 12($s0)		#Guarda Ano

	##la		$a0, pula_linha
	##jal		exibe_str

#Categoria
	la		$a0, registro_categoria
	jal		exibe_str

	li		$v0, 8				# Recebe String
	la		$a0, 16($s0)		# Passa Endereço do Inicio da String
	li		$a1, 16				# Tamanho da String = 16bits
	syscall

	la		$a0, 16($s0)	# Passa Endereço do Inicio da String
	jal		string_arruma	# Verifica se o ENTER entrou como caracter, se sim limpa

	##la		$a0, pula_linha
	##jal		exibe_str

#Valor
	la		$a0, registro_valor
	jal		exibe_str

	li		$v0, 6 				#Recebe Float
	syscall
	s.s		$f0, 32($s0)		#Guarda o Valor

	##la		$a0, pula_linha
	##jal		exibe_str

#Exibe Dados Coletados

	#Exibe Titulo
	la		$a0, exibe_titulo
	jal		exibe_str

	la		$a0, 0($s0)
	jal		exibe_registro

registro_fim:
	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####	Função que "Limpa" o ENTER	   ####
####	de uma String				   ####
####	Argumentos:					   ####
####	$a0 = End. Inicial da String   ####
####===================================####
string_arruma:
	addi 	$sp , $sp, -4
	sw		$ra , 0($sp)

	add		$t0, $zero, $zero		#	Zera o Contador de Posição
	addi	$t2, $zero, 16			#	Cria limite para o Contador
	addi	$t3, $zero, 10			#	ENTER (ASCII == 10dec)
string_arruma_topo:
	beq		$t0, $t2, string_arruma_fim
	add		$t1, $t0, $a0									#	Adiciona o Deslocamento ao End. Inicial
	lb		$t1, 0($t1)										#	Carrega o Caracter
	beq		$t1, $t3, string_arruma_troca					#	Verifica se é ENTER (ASCII == 10dec)
	addi	$t0, $t0, 1										#	Atualiza o Contador da String
	j		string_arruma_topo								#	Itera

string_arruma_troca:
	add		$t1, $t0, $a0									#	Adiciona o Deslocamento ao End. Inicial
	sb		$zero, 0($t1)									#	Guarda $zero na posição que contém o ENTER

string_arruma_fim:
	lw		$ra , 0($sp)
	addi 	$sp , $sp, 4
	jr		$ra

####===================================####
####	Função para a Exibição 	   	   ####
####	de um Registro na Memoria	   ####
####	Argumentos:		 			   ####
####	$a0 = End. Inicial do Registro ####
####===================================####
exibe_registro:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)
	
	move 	$s0, $a0		#	Copia o End. de A0 p/ S0

#Exibe Conteúdo
	la		$a0, exibe_ID
	jal		exibe_str

	li		$v0, 1			#	Exibe Int
	lw		$a0, 0($s0)		#	End. do ID
	syscall

	la		$a0, exibe_Data
	jal		exibe_str

	li		$v0, 1			#	Exibe Int
	lw		$a0, 4($s0)		#	End. do Dia
	syscall

	la		$a0, exibe_Data0
	jal		exibe_str

	li		$v0, 1			#	Exibe Int
	lw		$a0, 8($s0)		#	End. do Mês
	syscall

	la		$a0, exibe_Data0
	jal		exibe_str

	li		$v0, 1			#	Exibe Int
	lw		$a0, 12($s0)	#	End. do Ano
	syscall

	la		$a0, exibe_Categoria
	jal		exibe_str

	la		$a0, 16($s0)	#	End. da Categoria
	jal		exibe_str

	la		$a0, exibe_valor
	jal		exibe_str

	li		$v0, 2			#	Exibe Float
	l.s		$f12, 32($s0)	#	End. do Valor
	syscall

	la		$a0, pula_linha
	jal		exibe_str
	
	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Excluir			   ####
####===================================####
excluir:

#fazer resumo depois
#s0 marca o comeco do vetor
#$t0 mostra o final do vetor para ver se acabou
#aux guarda o numero

	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)

#vai perguntar o numero do indice
	la  $a0,nexcluir
	jal	exibe_str

	li	$v0,5  							#	vai ler o inteiro do teclado lembrar que estara em v0 o integer
	syscall

	###########addi	$v0, $v0, -48					#	Ajusta de ASCII para DEC
    la 		$s0 , registro				#	Guarda posicao do 1 elemento
	addi	$s1 , $s0 , 640				#	Fim do Registro em t0 (para guardar os erros)


#comecar o loop de proximo entao
excluir_loopprox:
	beq		$s0, $s1, excluir_nencontrado

	lw		$t0, 0($s0) 					#vai valer apenas para a primeira vez
	beq		$t0, $v0, excluir_fimprocura 	#compara item com aux(numero a ser excluido)

	add		$t4, $zero, $v0

	add		$v0, $zero, $t4

	addi	$s0, $s0, 64
	j		excluir_loopprox

excluir_nencontrado:
	la	$a0,n_encontrado
	jal	exibe_str
	j	excluir_fim

excluir_fimprocura:
	la	$a0, excluir_ok
	jal	exibe_str

	sw	$zero, 0($s0)

excluir_fim:
	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Listar Despesas      ####
####===================================####
listar_despesas:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)


	la $s0, registro  	#S0 recebe o vetor com os itens
	la $s1,vetoraux	 	#vetor que ira guardar os gastos
	la $s2, registro 	#S0 recebe o vetor com os itens
	addi $s2, $s2, 640 	#para saber se o vetor explode


	#Copia o vetor registro
	#usando t0 como registrador para guardar variaveis
listar_copia:
	beq $s0,$s2,listar_item #condicao para sair do loop
	lw $t0,0($s0)
	sw $t0,0($s1)

	lw $t0,4($s0)
	sw $t0,4($s1)

	lw $t0,8($s0)
	sw $t0,8($s1)

	lw $t0,12($s0)
	sw $t0,12($s1)

	lw $t0,16($s0) #Começa a string
	sw $t0,16($s1)

	lw $t0,20($s0)
	sw $t0,20($s1)

	lw $t0,24($s0)
	sw $t0,24($s1)

	lw $t0,28($s0)
	sw $t0,28($s1) #acaba a string


	l.s $f0,32($s0) #pq eh float
	s.s $f0,32($s1)

	addi $s0,$s0,64
	addi $s1,$s1,64
	j listar_copia

listar_item:
	la	$a0,listar_texto
	jal	exibe_str

listar_prox_item: 	#para recomecar/comecar , (endereco de aux)
	la $s0, vetoraux
	la $s1, vetoraux
	addi $s2, $s0, 640

lstar_cmco_zero:
	lw $t0,0($s0) 	#pega o indice para ver se é 0
	bne $t0,0,listar_cnt1v
	addi $s0,$s0,64
	addi $s1,$s1,64
	beq $s0,$s2,listar_fim #vai ver se o vetor ja foi percorrido totalmente, se sim vai pro fim

	j lstar_cmco_zero #tenta para o proximo caso,pois ele seria 0

listar_cnt1v:
	lw $t0,12($s0)#da um store no 1 elemento ANO, ja se sabe que eh != de 0
listar_comeco:
	 addi $s0,$s0,64
	 beq $s0,$s2,listar_imprimir #se for maior ele excedeu o vetor, e como tem pelo menos o 1 imprm ele msm
	 lw $t1,0($s0)
	 bne $t1,0,list_cnt2v
	j listar_comeco

list_cnt2v:
	lw $t1, 12($s0)   			#dessa vez t1 tem o 2 ANO
	bgt $t0,$t1,listar_comeco 	#se o $t0 maior procura um proximo
	beq $t0,$t1,listar_msm_ano  #se forem o msm ano
	#proximo caso se $t0 menor que $t1
	move $t0,$t1
	la $s1,0($s0)
	j listar_comeco 			#volta para as proximas chamadas


listar_msm_ano:
#DEFINITIVOS:S1,T0  TEMPORARIOS/COMPARACAO:s0 t1
	lw $t0,8($s1) #pegando mes do 1
	lw $t1,8($s0) #pegando mes do 2
	bgt $t0,$t1,listar_cnt_m
	beq $t0,$t1,listar_msm_m
	lw $t0,12($s0)
	la $s1,0($s0)
	j listar_comeco
listar_cnt_m:
	lw $t0,12($s1)#colocando o ano novamente
	j listar_comeco

listar_msm_m:
	#passou para a comparacao de dias agora
	lw $t0,4($s1)
	lw $t1,4($s0)
	bgt $t0,$t1,listar_cnt_d
	lw $t0,12($s0)
	la $s1,0($s0)
	j listar_comeco
listar_cnt_d:
	lw $t0,12($s1)
	j listar_comeco

listar_imprimir:
	#vamos ver se da o pulo colocar end em t3 por prevencao
	la $t3,0($s1)	#pega o comeco da struct

	la $a0,0($t3)
	jal exibe_registro

	sw $zero,0($s1) #coloca como 0 para nao usar novamente(la na comparacao)
	j listar_prox_item

listar_fim:
	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra

####===================================####
####		Opção Gasto Mensal		   ####
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
####	Opção Gasto por Categoria	   ####
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
####	Opção Ranking de Despesas	   ####
####===================================####
ranking_despesas:
	addi 	$sp , $sp, -8
	sw		$ra , 0($sp)
	sw		$v0 , 4($sp)


	lw		$ra , 0($sp)
	lw		$v0 , 4($sp)
	addi 	$sp , $sp, 8
	jr		$ra
