# Trabalho final AOC I - 2024/2 
# RPG .....
# Gabriela Rickes e Vitória Santa Lucia

.data
    # Mensagens de interface
    classe_menu: .asciiz "\nEscolha sua classe:\n1. Guerreiro (Vida: 120, Dano: 25)\n2. Mago (Vida: 80, Dano: 35)\n3. Arqueiro (Vida: 100, Dano: 30)\nEscolha: "
    menu: .asciiz "\nEscolha sua ação:\n1. Atacar\n2. Usar Poção\n3. Esquivar\n4. Fugir\nEscolha: "
    dificuldade_menu: .asciiz "\nEscolha a dificuldade:\n1. Fácil\n2. Normal\n3. Difícil\nEscolha: "
    msg_atacou: .asciiz "Você atacou o inimigo!\n"
    msg_pocao: .asciiz "Você usou uma poção e restaurou vida!\n"
    msg_fuga: .asciiz "Você fugiu da batalha!\n"
    msg_atacado: .asciiz "O inimigo atacou você!\n"
    msg_vitoria: .asciiz "Você derrotou o inimigo!\n"
    msg_derrotado: .asciiz "Você foi derrotado!\n"
    msg_invalido: .asciiz "Opção inválida!\n"
    nova_linha: .asciiz "\n"
    msg_HP_restante: .asciiz "Vida restante do inimigo:\n"
    msg_HP_atual: .asciiz "Vida atual:\n"
    msg_esquiva: .asciiz "Você não pode mais utilizar esquivas."

    # Variáveis do jogador
    hp_jogador: .word 100	# Vida do jogador
    dano_jogador: .word 20	# Dano do jogador
    pocoes_disponiveis: .word 3	# Poções disponíveis
    esquiva_disponivel: .word 1	# Esquivas disponíveis (base)

    # Variáveis do inimigo
    hp_inimigo: .word 80            # Vida do inimigo
    dano_inimigo: .word 15        # Dano do inimigo

.text
    .globl main

main:
   
    # Escolha da classe do personagem
    li $v0, 4
    la $a0, classe_menu
    syscall

    li $v0, 5  # Ler entrada do usuário
    syscall
    move $t1, $v0  # Armazena a escolha da classe

    beq $t1, 1, guerreiro   # Guerreiro
    beq $t1, 2, mago      # Mago
    beq $t1, 3, arqueiro    # Arqueiro
    j main  # Caso inválido, pede novamente

guerreiro:
    li $t2, 120  # Vida
    li $t3, 25   # Dano
    j definir_classe

mago:
    li $t2, 80   # Vida
    li $t3, 35   # Dano
    j definir_classe

arqueiro:
    li $t2, 100  # Vida
    li $t3, 30   # Dano
    j definir_classe

definir_classe:
    sw $t2, hp_jogador       # Define a vida do jogador
    sw $t3, dano_jogador   # Define o dano do jogador
    j definir_dificuldade
    
definir_dificuldade:
    # Escolha da dificuldade
    li $v0, 4
    la $a0, dificuldade_menu
    syscall

    li $v0, 5
    syscall
    move $t0, $v0  # armazena a opção escolhida

    beq $t0, 1, modo_facil   # fácil
    beq $t0, 2, modo_normal # normal
    beq $t0, 3, modo_dificil   # difícil
    j definir_dificuldade     # se inválido, repete a escolha

modo_normal:

    lw $t0, esquiva_disponivel
    addi $t0, $t0, 1
    sw $t0, esquiva_disponivel
    j loop_batalha

modo_facil: # mantém o número de esquivas
    lw $t1, hp_inimigo
    lw $t2, dano_inimigo
    subi $t1, $t1, 20  # reduz vida do inimigo
    subi $t2, $t2, 5  # reduz dano do inimigo
    sw $t1, hp_inimigo
    sw $t2, dano_inimigo
    j loop_batalha

modo_dificil:
    lw $t1, hp_inimigo
    lw $t2, dano_inimigo
    lw $t3, esquiva_disponivel
    addi $t1, $t1, 35  # aumenta vida do inimigo
    addi $t2, $t2, 10  # aumenta dano do inimigo
    addi $t3, $t3, 2
    sw $t1, hp_inimigo
    sw $t2, dano_inimigo
    sw $t3, esquiva_disponivel
    j loop_batalha

loop_batalha:
    # exibe o menu para o jogador
    li $v0, 4
    la $a0, menu
    syscall

    # lê a escolha do jogador
    li $v0, 5
    syscall
    move $t0, $v0  # armazena a opção escolhida

    # verifica a ação escolhida
    beq $t0, 1, jogador_ataca  # atacar
    beq $t0, 2, usa_pocao     # usar poção
    beq $t0, 3, esquiva
    beq $t0, 4, fuga           # fugir
    j opcao_invalida          # caso inválido

jogador_ataca:
    # o jogador ataca o inimigo
    lw $t1, hp_inimigo           # carrega a vida do inimigo
    lw $t2, dano_jogador      # carrega o dano do jogador
    sub $t1, $t1, $t2          # reduz a vida do inimigo
    sw $t1, hp_inimigo           # atualiza a vida do inimigo

    # exibe mensagem de ataque
    li $v0, 4
    la $a0, msg_atacou
    syscall
    
    # exibe a vida do inimigo na tela
    li $v0, 4
    la $a0, msg_HP_restante
    syscall
    li $v0, 1 
    lw $a0, hp_inimigo   
    syscall
    li $v0, 4
    la $a0, nova_linha
    syscall

    # verifica se o inimigo foi derrotado
    blez $t1, vitoria
    jal inimigo_ataca
    j loop_batalha

usa_pocao:
    # o jogador usa uma poção
    lw $t3, pocoes_disponiveis     # carrega o número de poções
    blez $t3, loop_batalha      # se não houver poções, volta ao menu

    addi $t3, $t3, -1          # reduz o número de poções
    sw $t3, pocoes_disponiveis
    lw $t4, hp_jogador          # carrega a vida do jogador
    addi $t4, $t4, 20          # restaura 20 pontos de vida
    sw $t4, hp_jogador

    # exibe mensagem de uso da poção
    li $v0, 4
    la $a0, msg_pocao
    syscall
    
    # exibe a vida do jogador na tela
    li $v0, 4
    la $a0, msg_HP_atual
    syscall
    li $v0, 1 
    lw $a0, hp_jogador   
    syscall
    li $v0, 4
    la $a0, nova_linha
    syscall

    # turno do inimigo
    jal inimigo_ataca
    j loop_batalha
    
esquiva:
	lw $t1, esquiva_disponivel
	# verifica se o jogador ainda tem esquivas disponíveis
	blez $t1, msgEsquiva
	addi $t1, $t1, -1 # reduz em 1 o numero de esquivas disponiveis
	sw $t1, esquiva_disponivel
	lw $t1, hp_inimigo           
    	lw $t2, dano_jogador     
   	sub $t1, $t1, $t2         
    	sw $t1, hp_inimigo
    	
    	# mostrando o hp do inimigo após o ataque
    	li $v0, 4
    	la $a0, msg_HP_restante
    	syscall
    	li $v0, 1 
    	lw $a0, hp_inimigo   
    	syscall
    	li $v0, 4
    	la $a0, nova_linha
    	syscall
    	blez $t1, vitoria
    	
    	j loop_batalha      
	
msgEsquiva:
	# exibindo a mensagem de que o jogador não tem mais esquivas disponiveis
	li $v0, 4
	la $a0, msg_esquiva
	syscall
	j loop_batalha

fuga:
    # o jogador foge da batalha
    li $v0, 4
    la $a0, msg_fuga
    syscall
    j game_over

inimigo_ataca:
    # o inimigo ataca o jogador
    lw $t5, hp_jogador          # carrega a vida do jogador
    lw $t6, dano_inimigo       # carrega o dano do inimigo
    sub $t5, $t5, $t6          # reduz a vida do jogador
    sw $t5, hp_jogador

    # exibe mensagem de ataque do inimigo
    li $v0, 4
    la $a0, msg_atacado
    syscall
    
    # exibe a vida do jogador na tela
    li $v0, 4
    la $a0, msg_HP_atual
    syscall
    li $v0, 1 
    lw $a0, hp_jogador   
    syscall
    li $v0, 4
    la $a0, nova_linha
    syscall

    # verifica se o jogador foi derrotado
    blez $t5, derrota
    jr $ra

vitoria:
    # mensagem de vitória
    li $v0, 4
    la $a0, msg_vitoria
    syscall
    j game_over

derrota:
    # mensagem de derrota
    li $v0, 4
    la $a0, msg_derrotado
    syscall
    j game_over

opcao_invalida:
    # mensagem de opção inválida
    li $v0, 4
    la $a0, msg_invalido
    syscall
    j loop_batalha

game_over:
    # finaliza o programa
    li $v0, 10
    syscall
