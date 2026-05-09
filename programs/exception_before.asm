# exception_before.asm
# A program to demonstrate execution WITHOUT Coprocessor 0 exceptions.
# It executes a syscall, but since there is no exception hardware, it falls through
# and continues execution as if it was a NOP.

main:
    addi $t0, $zero, 0      # $t0 = 0
    addi $t1, $zero, 5      # $t1 = 5

loop:
    addi $t0, $t0, 1        # $t0 += 1
    bne  $t0, $t1, loop     # if $t0 != 5, loop
    
do_sys:
    syscall                 # Trigger exception (Without CP0, this is a NOP)
    addi $t2, $zero, 99     # If syscall doesn't trap, this sets $t2 = 99
    
end:
    sw   $t2, 200($zero)    # Store result to mem address 200 (0xC8)
    j    end                # Halt
