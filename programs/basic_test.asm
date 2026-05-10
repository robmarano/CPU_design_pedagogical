# basic_test.asm
# A simple program to test basic CPU functionality (Single-Cycle and Multi-Cycle)
# It writes 7 to address 84 (0x54)

main:
    addi $t0, $zero, 5      # $t0 = 5
    addi $t1, $zero, 2      # $t1 = 2
    add  $t2, $t0, $t1      # $t2 = 5 + 2 = 7
    sw   $t2, 84($zero)     # Store 7 to memory address 84 (0x54)
end:
    j end
