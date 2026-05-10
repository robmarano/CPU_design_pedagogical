# quake3.asm
# Computes Fast Inverse Square Root of 2.0 (0x40000000)

main:
    # We will manually seed the constants in memory at byte addresses 0..12
    lw $t0, 0($zero)        # $t0 = number (2.0f)
    lw $t1, 4($zero)        # $t1 = 0.5f
    lw $t2, 8($zero)        # $t2 = 1.5f
    lw $t3, 12($zero)       # $t3 = 0x5f3759df
    
    # x2 = number * 0.5F;
    mul.s $t4, $t0, $t1     # $t4 = x2
    
    # y = number; (y is $t0)
    # i = * ( long * ) &y; (i is just $t0, no type conversion needed!)
    
    # i = 0x5f3759df - ( i >> 1 );
    addi $t5, $zero, 1      # $t5 = 1 (shift amount)
    srlv $t6, $t0, $t5      # $t6 = i >> 1
    sub  $t7, $t3, $t6      # $t7 = 0x5f3759df - (i >> 1). This is our new 'y'!
    
    # y = * ( float * ) &i; (y is just $t7)
    
    # Newton iteration: y = y * ( threehalfs - ( x2 * y * y ) );
    mul.s $s0, $t7, $t7     # $s0 = y * y
    mul.s $s1, $t4, $s0     # $s1 = x2 * (y * y)
    sub.s $s2, $t2, $s1     # $s2 = threehalfs - (x2 * y * y)
    mul.s $s3, $t7, $s2     # $s3 = y * (threehalfs - (x2 * y * y))
    
    # Store result to mem address 16 (0x10)
    sw   $s3, 16($zero)     # Expected result: ~0.707 (0x3f3504f3)
    
end:
    j    end                # Halt
