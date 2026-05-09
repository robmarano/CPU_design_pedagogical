# exception_after.asm
# Demonstrates precise exceptions with Coprocessor 0.
# Triggers a syscall, jumps to the handler at 0x80,
# handles it by setting a flag, and returns using eret to the instruction AFTER syscall.

main:
    addi $t0, $zero, 0      # $t0 = 0
    addi $t1, $zero, 5      # $t1 = 5
    addi $t2, $zero, 0      # $t2 = 0

loop:
    addi $t0, $t0, 1        # $t0 += 1
    bne  $t0, $t1, loop     # if $t0 != 5, loop

do_sys:
    syscall                 # Exception! Hardware jumps to 0x80.
    addi $t2, $t2, 100      # Executed AFTER returning from exception ($t2 = 1 + 100 = 101)
    
end:
    sw   $t2, 200($zero)    # Store $t2 (101) to memory 200
    j    end                # Halt

# ---------------------------------------------------------
# EXCEPTION HANDLER
# ---------------------------------------------------------
.org 0x80                   # Places the next instruction at word 32 (byte 128 = 0x80)

handler:
    mfc0 $t3, 14            # Read EPC (Exception Program Counter) into $t3
    addi $t2, $zero, 1      # Set flag $t2 = 1 to prove we were here
    addi $t3, $t3, 4        # Add 4 to EPC so we return to the instruction AFTER syscall
    mtc0 $t3, 14            # Write the new EPC back to CP0 register 14
    eret                    # Return from exception
