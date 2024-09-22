# Refernce : https://www.geeksforgeeks.org/the-painters-partition-problem-using-binary-search/
.data
.align 4

# ==============testcase1==============
arr: .word 10, 20, 30, 40
n: .word 4
k: .word 2
str: .string "output: "
# output: 60
# =====================================

# ==============testcase2==============
# arr: .word 1, 2, 3, 4, 5, 6, 7, 8, 9
# n: .word 9
# k: .word 3
# str: .string "output: "
# output: 17
# =====================================

.text
.global _start
# Start your coding below, don't change anything upper except testing different testcase
# ------------------------------------------------------------
# int main()
_start:
    # & $env:RV64_GCC_PATH\riscv64-unknown-elf-gcc.exe -march=rv64im -mabi=lp64 -s -static -nostdlib -o PPPBS_template.elf PPPBS_template.S


    # cout << "output: "
    la a0, str
    li a7, 4
    ecall

    # a0 = int arr[]
    # a1 = int n
    # a2 = int k
    la a0, arr
    lw a1, n
    lw a2, k
    # t1 = a0 = partition(arr, n, k)
    jal partition

    # cout << partition(arr, n, k)
    li a7, 1
    ecall
    
    j end
# ------------------------------------------------------------
# int partition(int arr[], int n, int k)
partition:
    # a0 = int arr[]
    # a1 = int n
    # a2 = int k
    # t1 = lo
    # t2 = hi
    # t3 = mid
    # t4 = requiredPainters

    # enter stack
    addi sp, sp, -28
    # store stack
    sw a0, 24(sp) # int arr[]
    sw a1, 20(sp) # int n
    sw a2, 16(sp) # int k
    sw ra, 12(sp) # return address

    # t1 = lo = getMax
    jal getMax
    mv t1, a0
    # store stack
    sw t1, 8(sp) # lo
    
    # restore stack
    lw a0, 24(sp) # int arr[]
    # t2 = hi = getSum
    jal getSum
    mv t2, a0
    # store stack
    sw t2, 4(sp) # hi

  whileLoop:
    # restore stack
    lw t1, 8(sp) # lo
    lw t2, 4(sp) # hi

    bge t1, t2, breakWhileLoop # breakWhileLoop if lo >= hi
    # t3 = mid
    sub t3, t2, t1 # mid = hi - lo
    srai t3, t3, 1 # mid = (hi - lo) / 2
    add t3, t1, t3 # mid = lo + (hi - lo) / 2
    # store stack
    sw t1, 8(sp) # lo
    sw t2, 4(sp) # hi
    sw t3, 0(sp) # mid
    
    # restore stack
    lw a0, 24(sp) # int arr[]
    lw a1, 20(sp) # int n
    mv a2, t3 # int maxLen
    # t4 = requiredPainters = numberOfPainters(arr, n, mid)
    jal numberOfPainters
    mv t4, a0
    
    # restore stack
    lw a2, 16(sp) # int k
    lw t1, 8(sp) # lo
    lw t2, 4(sp) # hi
    lw t3, 0(sp) # mid
    # requiredPainters > k
    bgt t4, a2, lo_mid_1

    # requiredPainters <= k
    mv t2, t3 # hi = mid
    # store stack
    sw t2, 4(sp) # hi

    beq zero, zero, whileLoop # loop

  lo_mid_1:
    addi t1, t3, 1 # lo = mid + 1
    # store stack
    sw t1, 8(sp) # lo

    beq zero, zero, whileLoop # loop

  breakWhileLoop:
    mv a0, t1 # put return value in a0

    # restore stack
    lw ra, 12(sp) # return address
    jr ra
# ------------------------------------------------------------
# int getMax(int arr[], int n)
getMax:
    # a0 = int arr[]
    # a1 = int n
    # t1 = max
    # t2 = i
    # t3 = arr[i]

    li t1, -2147483648 # max = INT_MIN

    li t2, 0 # i = 0
  forLoop1:
    bge t2, a1, breakForLoop1 # breakForLoop1 if i >= n

    # t3 = arr[i]
    slli  t3, t2, 2 # mul i by 4 (1 << 2 = 4)
    add   t3, a0, t3 # memory address
    lw    t3, 0(t3) # dereference address

    # arr[i] <= max
    ble t3, t1, bottom1
    # arr[i] > max
    mv t1, t3 # max = t3 = arr[i]

  bottom1:
    addi t2, t2, 1 # i += 1
    beq zero, zero, forLoop1 # loop

  breakForLoop1:
    mv a0, t1 # put return value in a0
    # Debug
    # li a7, 1
    # ecall
    jr ra
# ------------------------------------------------------------
# int getSum(int arr[], int n)
getSum:
    # a0 = int arr[]
    # a1 = int n
    # t1 = total
    # t2 = i
    # t3 = arr[i]

    li t1, 0 # total = 0

    li t2, 0 # i = 0
  forLoop2:
    bge t2, a1, breakForLoop2 # breakForLoop1 if i >= n

    # t3 = arr[i]
    slli  t3, t2, 2 # mul i by 4 (1 << 2 = 4)
    add   t3, a0, t3 # memory address
    lw    t3, 0(t3) # dereference address

    add   t1, t1, t3 # total += arr[i]

    addi t2, t2, 1 # i += 1
    beq zero, zero, forLoop2 # loop

  breakForLoop2:
    mv a0, t1 # put return value in a0
    # Debug
    # li a7, 1
    # ecall
    jr ra
# ------------------------------------------------------------
# int numberOfPainters(int arr[], int n, int maxLen)
numberOfPainters:
    # a0 = int arr[]
    # a1 = int n
    # a2 = int maxLen (mid)
    # t1 = total
    # t2 = numPainters
    # t3 = i
    # t4 = arr[i]

    li t1, 0 # total = 0
    li t2, 1 # numPainters = 1
    
    li t3, 0 # i = 0
  forLoop3:
    bge t3, a1, breakForLoop3 # breakForLoop1 if i >= n

    # t4 = arr[i]
    slli  t4, t3, 2 # mul i by 4 (1 << 2 = 4)
    add   t4, a0, t4 # memory address
    lw    t4, 0(t4) # dereference address

    add   t1, t1, t4 # total += arr[i]

    # total <= maxLen (mid)
    ble t1, a2, bottom3

    # total > maxLen (mid)
    mv t1, t4 # total = t4 = arr[i]
    addi t2, t2, 1 # numPainters++

  bottom3:
    addi t3, t3, 1 # i += 1
    beq zero, zero, forLoop3 # loop

  breakForLoop3:
    mv a0, t2 # put return value in a0
    # Debug
    # li a7, 1
    # ecall
    jr ra
# ------------------------------------------------------------
# end of program
end:
    # Exit program
    li a7, 10
    ecall
# ------------------------------------------------------------