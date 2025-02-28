# Trabalho final AOC I - 2024/2 
# RPG .....
# Gabriela Rickes e Vitória Santa Lucia

.data
    # Mensagens de interface
    class_menu: .asciiz "\nEscolha sua classe:\n1. Guerreiro (Vida: 120, Dano: 25)\n2. Mago (Vida: 80, Dano: 35)\n3. Arqueiro (Vida: 100, Dano: 30)\nEscolha: "
    menu: .asciiz "\nEscolha sua ação:\n1. Atacar\n2. Usar Poção\n3. Fugir\nEscolha: "
    msgAttack: .asciiz "Você atacou o inimigo!\n"
    msgPotion: .asciiz "Você usou uma poção e restaurou vida!\n"
    msgFlee: .asciiz "Você fugiu da batalha!\n"
    msgEnemyAttack: .asciiz "O inimigo atacou você!\n"
    msgWin: .asciiz "Você derrotou o inimigo!\n"
    msgLose: .asciiz "Você foi derrotado!\n"
    msgInvalid: .asciiz "Opção inválida!\n"
    newline: .asciiz "\n"
    msgEnemyHP: .asciiz "Vida restante do inimigo:\n"
    msgPlayerHP: .asciiz "Vida atual:\n"

    # Variáveis do jogador
    player_hp: .word 100          # Vida do jogador
    player_damage: .word 20       # Dano do jogador
    player_potions: .word 3       # Poções disponíveis

    # Variáveis do inimigo
    enemy_hp: .word 80            # Vida do inimigo
    enemy_attack: .word 15        # Dano do inimigo

.text
    .globl main

main:
    # Escolha da classe do personagem
    li $v0, 4
    la $a0, class_menu
    syscall

    li $v0, 5  # Ler entrada do usuário
    syscall
    move $t0, $v0  # Armazena a escolha da classe

    beq $t0, 1, set_warrior   # Guerreiro
    beq $t0, 2, set_mage      # Mago
    beq $t0, 3, set_archer    # Arqueiro
    j main  # Caso inválido, pede novamente

set_warrior:
    li $t1, 120  # Vida
    li $t2, 25   # Dano
    j set_class

set_mage:
    li $t1, 80   # Vida
    li $t2, 35   # Dano
    j set_class

set_archer:
    li $t1, 100  # Vida
    li $t2, 30   # Dano
    j set_class

set_class:
    sw $t1, player_hp       # Define a vida do jogador
    sw $t2, player_damage   # Define o dano do jogador
    j battle_loop

battle_loop:
    # Exibe o menu para o jogador
    li $v0, 4
    la $a0, menu
    syscall

    # Lê a escolha do jogador
    li $v0, 5
    syscall
    move $t0, $v0  # Armazena a opção escolhida

    # Verifica a ação escolhida
    beq $t0, 1, player_attack  # Atacar
    beq $t0, 2, use_potion     # Usar poção
    beq $t0, 3, flee           # Fugir
    j invalid_option           # Caso inválido

player_attack:
    # O jogador ataca o inimigo
    lw $t1, enemy_hp           # Carrega a vida do inimigo
    lw $t2, player_damage      # Carrega o dano do jogador
    sub $t1, $t1, $t2          # Reduz a vida do inimigo
    sw $t1, enemy_hp           # Atualiza a vida do inimigo

    # Exibe mensagem de ataque
    li $v0, 4
    la $a0, msgAttack
    syscall
    
    #Exibe a vida do inimigo na tela
    li $v0, 4
    la $a0, msgEnemyHP
    syscall
    li $v0, 1 
    lw $a0, enemy_hp   
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Verifica se o inimigo foi derrotado
    blez $t1, player_win
    jal enemy_turn
    j battle_loop

use_potion:
    # O jogador usa uma poção
    lw $t3, player_potions     # Carrega o número de poções
    blez $t3, battle_loop      # Se não houver poções, volta ao menu

    addi $t3, $t3, -1          # Reduz o número de poções
    sw $t3, player_potions
    lw $t4, player_hp          # Carrega a vida do jogador
    addi $t4, $t4, 20          # Restaura 20 pontos de vida
    sw $t4, player_hp

    # Exibe mensagem de uso da poção
    li $v0, 4
    la $a0, msgPotion
    syscall
    
    #Exibe a vida do jogador na tela
    li $v0, 4
    la $a0, msgPlayerHP
    syscall
    li $v0, 1 
    lw $a0, player_hp   
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Turno do inimigo
    jal enemy_turn
    j battle_loop

flee:
    # O jogador foge da batalha
    li $v0, 4
    la $a0, msgFlee
    syscall
    j game_over

enemy_turn:
    # O inimigo ataca o jogador
    lw $t5, player_hp          # Carrega a vida do jogador
    lw $t6, enemy_attack       # Carrega o dano do inimigo
    sub $t5, $t5, $t6          # Reduz a vida do jogador
    sw $t5, player_hp

    # Exibe mensagem de ataque do inimigo
    li $v0, 4
    la $a0, msgEnemyAttack
    syscall
    
    #Exibe a vida do jogador na tela
    li $v0, 4
    la $a0, msgPlayerHP
    syscall
    li $v0, 1 
    lw $a0, player_hp   
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Verifica se o jogador foi derrotado
    blez $t5, player_lose
    jr $ra

player_win:
    # Mensagem de vitória
    li $v0, 4
    la $a0, msgWin
    syscall
    j game_over

player_lose:
    # Mensagem de derrota
    li $v0, 4
    la $a0, msgLose
    syscall
    j game_over

invalid_option:
    # Mensagem de opção inválida
    li $v0, 4
    la $a0, msgInvalid
    syscall
    j battle_loop

game_over:
    # Finaliza o programa
    li $v0, 10
    syscall
