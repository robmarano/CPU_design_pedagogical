# cache_test.asm
# A program designed to demonstrate spatial and temporal locality.
# It initializes an array of 16 words, then iterates over it to sum the values.
# Expected behavior: Without cache, every lw/sw triggers a main memory latency penalty.
# With an L1 Direct-Mapped Cache, the sum loop will hit the cache 100% of the time.

main:
    addi $t0, $zero, 0      # $t0 = loop counter (i) = 0
    addi $t1, $zero, 64     # $t1 = max byte offset (16 words * 4 = 64)
    addi $t2, $zero, 128    # $t2 = base address of array in memory (0x80)
    addi $t4, $zero, 0      # $t4 = sum accumulator = 0

init_loop:
    beq  $t0, $t1, sum_prep # if i == 64, array initialized, jump to sum
    add  $t3, $t2, $t0      # $t3 = base_address + offset
    sw   $t0, 0($t3)        # array[i] = i (writes 0, 4, 8, 12...)
    addi $t0, $t0, 4        # i += 4 bytes
    j    init_loop          # repeat initialization

sum_prep:
    addi $t0, $zero, 0      # reset loop counter (i) = 0

sum_loop:
    beq  $t0, $t1, end      # if i == 64, summation complete, jump to end
    add  $t3, $t2, $t0      # $t3 = base_address + offset
    lw   $t5, 0($t3)        # load array[i] into $t5. (CACHE TEST HAPPENS HERE)
    add  $t4, $t4, $t5      # sum += array[i]
    addi $t0, $t0, 4        # i += 4 bytes
    j    sum_loop           # repeat summation

end:
    sw   $t4, 200($zero)    # store final sum (480) into memory address 200
