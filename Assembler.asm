// 00, 01: memPtrStart [16 bits]
// 02, 03: codePtr [16 bits]
// 04, 05: codeLineStart [16 bits]
// 06, 07: opCodePtr [16 bits]
// 08: opCode
// 09: operandBytes
// 10, 11, 12, 13: num
// R0, R1, R2, R3: num
// 14: currentDigit
// 15, 16: multiplier
// 17, 18: compiledPtr

LDAI 0
STA  0
LDAI 1
STA  1 // memPtrStart: This loads the value 256, in bytes 00, 01.

LDAI 0
STA  02
LDAI 192
STA  03 // codePtr: This loads the value 49152 (2^15 * 1.5) in bytes 02, 03

LDAI 0
STA  17
LDAI 128
STA  18 // compiledPtr: This loads the value 32768 (2^15) in bytes 17, 18

LDAZPI 02 // A = processor.RAM[codePtr]
CLC // C = 0
ADCI 1 // A = A + 1
CMPI 0 // Comparing Accumulator with 0
BNE 4 // Branch 4 Bytes ahead if not zero
JMP AAAA// Jump to the end of the program

// Run till the end of the source code

LDAM 02 // A = LB codePtr
STA  04 // 
LDAM 03 // A = HB codePtr
STA  05 // codeLineStart = codePtr: 04, 05

LDAM 00 // A = LB codePtr
STA  06 // 
LDAM 01 // A = HB codePtr
STA  07 // opCodePtr = memPtrStart: 06, 07

// Mnemonic Loop
LDAZPI 02 // A = processor.RAM[codePtr]
CMPI 32 // 32 is the ASCII code of ' '
BNE 4 
JMP AAAA // The opcode mnemonic was found and matched, jump to the end of the loop

// If all the opcodes are exhausted and the src mnemonic was still not matched, the src mnemonic is invalid/incorrect
LDAZPI 06 // A = processor.RAM[opCodePtr]
CLC // C = 0
ADC 1 // A = A + 1
CMPI 0 // Comparing A with 0
BEQ 4 // Branch if A is zero
JMP AAAA // Skip this conditional statement
JMP AAAA // Skip to the next code line

// If the mnemonic, at any character doesn't before it's end, the current opcode is the not the one required
LDAZPI 02 // A = processor.RAM[codePtr]
CMPZPI 06 // A - processor.RAM[opCodePtr]
BNE 4 // If they are not equal, branch past the jump statement
JMP AAAA // Jump to the end of the conditional statement

LDAM 04
STA  02
LDAM 05
STA  03 // codePtr = codeLineStart
                
// Skipping all the remaining mnemonic bytes and the other info in the opcode entry for the current opcode
LDAZPI 06 // A = processor.RAM[opCodePtr]
CLC // C = 0
ADCI // A = A + 1
BNE 4 // Branch ahead of the jump statement 
JMP AAAA // Jump out of the current 'skipping mnemonic' loop

// opCodePtr++
CLC
LDAM 06
ADCI 1
STA  06
LDAM 07
ADCI 0
STA  07

JMP AAAA // Jump to the initial condition for the 'skip mnemonic loop'

// opCodePtr += 4
CLC
LDAM 06
ADCI 4
STA  06
LDAM 07
ADCI 0
STA  07

JMP AAAA // Start the mnemonic loop again

// opCodePtr++
CLC
LDAM 06
ADCI 1
STA  06
LDAM 07
ADCI 0
STA  07

// codePtr++
CLC
LDAM 02
ADCI 1
STA  02
LDAM 03
ADCI 0
STA  03

JMP AAAA // Start the mnemonic loop again

// opCodePtr points to -1 and 
// opCodePtr++ for opCode
CLC
LDAM 06
ADCI 1
STA  06
LDAM 07
ADCI 0
STA  07

// opCodePtr points to the opCode
LDAZPI 06 // A = processor.RAM[opCodePtr]
STAZPI 17 // processor.RAM[compiledPtr] = processor.RAM[opCodePtr]

//compiledPtr++
CLC
LDAM 17
ADCI 1
STA  17
LDAM 18
ADCI 0
STA  18

// opCodePtr++ for operandBytes
CLC
LDAM 06
ADCI 1
STA  06
LDAM 07
ADCI 0
STA  07

// opCodePtr + 2 points to the number of operand bytes
LDAZPI 06 // A = processor.RAM[opCodePtr]
STA 09 // opCode = processor.RAM[opCodePtr]

// codePtr++
// codePtr, after increment now points to the highest digit of the operand or to the next line.
CLC
LDAM 02
ADCI 1
STA  02
LDAM 03
ADCI 0
STA  03

// If the operand bytes are zero, this means that codePtr in fact points to the next line and we need to restart the assembly loop

LDAM 09 // A = operandBytes
CMPI 0 // operandBytes == 0 ? 
BNE 4 // Branch 4 bytes ahead if not equal
JMP AAAA // Jump to the start of the assembly loop

LDAI 0
STA 10 // LB num = 0
STA 11 // HB num = 0

LDAI 10
STA 15 // LB multiplier = 10
LDAI 0
STA 16 // HB multiplier = 0

// While you haven't encountered the EOF character ';', run the operand loop
LDAZPI 02
CMPI 59
BNE 4 // Branch 4 bytes ahead if not equal
JMP AAAA //Skip the entire operand loop

LDAZPI 02 // A = processor.RAM[codePtr]
SEC
SBCI 48 //ASCII Code for '0' is 48 so to get the numeric value of the digit, we subtract 48
STA 14 // currentDigit

    LDAI 0       ;Initialize RESULT to 0
    STA 12 // RESULT+2
    LDXI 16      ;There are 16 bits in NUM2
L1  LSRM 16 // NUM2+1   ;Get low bit of NUM2 
    RORM 15 // NUM2
    BCC 4
    JMP L2       ;0 or 1?
    TAY          ;If 1, add NUM1 (hi byte of RESULT is in A)
    CLC
    LDAM 10 // NUM1
    ADCM 12 // RESULT+2
    STA 12 // RESULT+2
    TYA
    ADCM 11 // NUM1+1
L2  RORA        ;"Stairstep" shift
    RORM 12 // RESULT+2
    RORM 11 // RESULT+1
    RORM 10 // RESULT
    DEX
    BNE 4
    JMP L1
    STA 13 // RESULT+3

// After the above multiplication loop, num = num * multiplier

CLC
LDAM 10
ADCM 14
STA 10
LDAM 11
ADCI 0
STA 11 // num = num + currentDigit

// codePtr++
LDAM 02
ADCI 1
STA  02
LDAM 03
ADCI 0
STA  03

JMP AAAA // Jump to the beginning of the operand loop



// Post operand loop, codePtr increment
// codePtr++
LDAM 02
ADCI 1
STA  02
LDAM 03
ADCI 0
STA  03

LDAM 10 // A = LB num
STAZPI 17 // processor.RAM[compiledPtr] = LB num

//compiledPtr++
CLC
LDAM 17
ADCI 1
STA  17
LDAM 18
ADCI 0
STA  18

LDAM 11 // A = HB num
CMPI 0 // HB num == 0 ?
BNE 4 // Branch 4 Bytes ahead, if the result is not zero, storing of the HB num as well
JMP AAAA // Jump to the start of the assembler loop if the HB num is zero

STAZPI 17 // processor.RAM[compiledPtr] = HB num

//compiledPtr++
CLC
LDAM 17
ADCI 1
STA  17
LDAM 18
ADCI 0
STA  18

JMP AAAA // Jump to the start of the assembler loop