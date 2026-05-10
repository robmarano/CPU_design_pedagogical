# terminal.asm
# Interactive Terminal Program
# It waits for keyboard interrupts and echoes characters back to the terminal.

main:
    # 1. Enable hardware interrupts in Coprocessor 0
    # The Status register is at CP0 register 12.
    # Bit 0 is IE (Interrupt Enable).
    addi $t0, $zero, 1      # IE = 1
    mtc0 $t0, 12            # Write 1 to Status register
    
    # 2. Print "READY\n"
    addi $t0, $zero, 82     # 'R'
    sw   $t0, 0x7f0c($zero)
    addi $t0, $zero, 69     # 'E'
    sw   $t0, 0x7f0c($zero)
    addi $t0, $zero, 65     # 'A'
    sw   $t0, 0x7f0c($zero)
    addi $t0, $zero, 68     # 'D'
    sw   $t0, 0x7f0c($zero)
    addi $t0, $zero, 89     # 'Y'
    sw   $t0, 0x7f0c($zero)
    addi $t0, $zero, 10     # '\n'
    sw   $t0, 0x7f0c($zero)
    
    # 3. Enter an infinite sleep loop. 
    # Hardware will wake us up via asynchronous interrupt.
sleep:
    j    sleep

# ---------------------------------------------------------
# INTERRUPT HANDLER (Mapped to 0x80)
# ---------------------------------------------------------
.org 0x80
handler:
    # Read the Cause register (CP0 reg 13)
    mfc0 $t0, 13
    bne  $t0, $zero, end_int # If Cause != 0 (not hw interrupt), exit handler
    
    # Read the Key Data from MMIO RX_DATA (0x00007F04)
    # This read also triggers 'rx_ack' to the Verilator C++ wrapper.
    lw   $t1, 0x7f04($zero)
    
    # Write the Key Data back to MMIO TX_DATA (0x00007F0C) to echo it.
    sw   $t1, 0x7f0c($zero)
    
end_int:
    # Read EPC (CP0 reg 14), which holds the PC of the instruction that was squashed.
    mfc0 $t2, 14
    # Because this is an asynchronous interrupt (not a syscall), the EPC points 
    # directly to the instruction that needs to be re-fetched. We do NOT add 4.
    
    # Return to execution
    eret
