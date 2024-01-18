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

4000: LDAI 0;
4002: STA  0;
4005: LDAI 1;
4007: STA  1; // memPtrStart: This loads the value 256, in bytes 00, 01

4010: LDAI 0;
4012: STA  02;
4015: LDAI 192;
4017: STA  03; // codePtr: This loads the value 49152 (2^15 * 1.5) in bytes 02, 03

4020: LDAI 0;
4022: STA  17;
4025: LDAI 128;
4027: STA  18; // compiledPtr: This loads the value 32768 (2^15) in bytes 17, 18

// Run till the end of the source code
// Assembly loop
4030: LDAZPI 02; // A = processor.RAM[codePtr]
4032: CLC; // C = 0
4033: ADCI 1; // A = A + 1
4035: CMPI 0; // Comparing Accumulator with 0
4037: BNE 4; // Branch 4 Bytes ahead if not zero
4039: JMP 4479; // Jump to the end of the program

4042: LDAM 02; // A = LB codePtr
4045: STA  04; // 
4048: LDAM 03; // A = HB codePtr
4051: STA  05; // codeLineStart = codePtr: 04, 05

4054: LDAM 00; // A = LB codePtr
4057: STA  06; // 
4060: LDAM 01; // A = HB codePtr
4063: STA  07; // opCodePtr = memPtrStart: 06, 07

// Mnemonic Loop
4066: LDAZPI 02; // A = processor.RAM[codePtr]
4068: CMPI 32; // 32 is the ASCII code of ' '
4070: BNE 4;
4072: JMP 4198; // The opcode mnemonic was found and matched, jump to the end of the loop

// If all the opcodes are exhausted and the src mnemonic was still not matched, the src mnemonic is invalid/incorrect
4075: LDAZPI 06; // A = processor.RAM[opCodePtr]
4077: CLC; // C = 0
4078: ADCI 1; // A = A + 1
4080: CMPI 0; // Comparing A with 0
4082: BEQ 4; // Branch if A is zero
4084: JMP 4090; // Skip this conditional statement
4087: JMP 4030; // Skip to the next code line

// If the mnemonic, at any character doesn't before it's end, the current opcode is the not the one required
4090: LDAZPI 02; // A = processor.RAM[codePtr]
4092: CMPZPI 06; // A - processor.RAM[opCodePtr]
4094: BNE 4; // If they are not equal, branch past the jump statement
4096: JMP 4161; // Jump to the end of the conditional statement

4099: LDAM 04;
4102: STA  02;
4105: LDAM 05;
4108: STA  03; // codePtr = codeLineStart

// Skipping all the remaining mnemonic bytes and the other info in the opcode entry for the current opcode
4111: LDAZPI 06; // A = processor.RAM[opCodePtr]
4113: CLC; // C = 0
4114: ADCI; // A = A + 1
4116: BNE 4; // Branch ahead of the jump statement 
4118: JMP 4141; // Jump out of the current 'skipping mnemonic' loop

// opCodePtr++
4121: CLC;
4122: LDAM 06;
4125: ADCI 1;
4127: STA  06;
4130: LDAM 07;
4133: ADCI 0;
4135: STA  07;

4138: JMP 4111; // Jump to the initial condition for the 'skip mnemonic loop'

// opCodePtr += 4
4141: CLC;
4142: LDAM 06;
4145: ADCI 4;
4147: STA  06;
4150: LDAM 07;
4153: ADCI 0;
4155: STA  07;

4158: JMP 4066; // Start the mnemonic loop again

// opCodePtr++
4161: CLC;
4162: LDAM 06;
4165: ADCI 1;
4167: STA  06;
4170: LDAM 07;
4173: ADCI 0;
4175: STA  07;

// codePtr++
4178: CLC;
4179: LDAM 02;
4182: ADCI 1;
4184: STA  02;
4187: LDAM 03;
4190: ADCI 0;
4192: STA  03;

4195: JMP 4030; // Start the mnemonic loop again

// Mnemonic loop ends here

// opCodePtr points to -1 and 
// opCodePtr++ for opCode
4198: CLC;
4199: LDAM 06;
4202: ADCI 1;
4204: STA  06;
4207: LDAM 07;
4210: ADCI 0;
4212: STA  07;

// opCodePtr points to the opCode
4215: LDAZPI 06; // A = processor.RAM[opCodePtr]
4217: STAZPI 17; // processor.RAM[compiledPtr] = processor.RAM[opCodePtr]

// compiledPtr++
4219: CLC;
4220: LDAM 17;
4223: ADCI 1;
4225: STA  17;
4228: LDAM 18;
4231: ADCI 0;
4233: STA  18;

// opCodePtr++ for operandBytes
4236: CLC;
4237: LDAM 06;
4240: ADCI 1;
4242: STA  06;
4245: LDAM 07;
4248: ADCI 0;
4250: STA  07;

// opCodePtr + 2 points to the number of operand bytes
4253: LDAZPI 06; // A = processor.RAM[opCodePtr]
4255: STA 09; // opCode = processor.RAM[opCodePtr]

// codePtr++
// codePtr, after increment now points to the highest digit of the operand or to the next line.
4258: CLC;
4259: LDAM 02;
4262: ADCI 1;
4264: STA  02;
4267: LDAM 03;
4270: ADCI 0;
4272: STA  03;

// If the operand bytes are zero, this means that codePtr in fact points to the next line and we need to restart the assembly loop

4275: LDAM 09; // A = operandBytes
4278: CMPI 0; // operandBytes == 0 ? 
4280: BNE 4; // Branch 4 bytes ahead if not equal
4282: JMP 4030; // Jump to the start of the assembly loop

4285: LDAI 0;
4287: STA 10; // LB num = 0
4290: STA 11; // HB num = 0

4293: LDAI 10;
4295: STA 15; // LB multiplier = 10
4298: LDAI 0;
4300: STA 16; // HB multiplier = 0

// While you haven't encountered the EOF character ';', run the operand loop
// Operand loop starts
4303: LDAZPI 02;
4305: CMPI 59;
4307: BNE 4; // Branch 4 bytes ahead if not equal
4309: JMP 4409; //Skip the entire operand loop

4312: LDAZPI 02; // A = processor.RAM[codePtr]
4314: SEC;
4315: SBCI 48; //ASCII Code for '0' is 48 so to get the numeric value of the digit, we subtract 48
4317: STA 14; // currentDigit

4320: LDAI 0       ;Initialize RESULT to 0;
4322: STA 12; // RESULT+2
4325: LDXI 16      ;There are 16 bits in NUM2;
4327: LSRM 16; // NUM2+1   ;[L1] Get low bit of NUM2 
4330: RORM 15; // NUM2
4333: BCC 4;
4335: JMP 4353; // 0 or 1?
4338: TAY; // If 1, add NUM1 (hi byte of RESULT is in A)
4339: CLC;
4340: LDAM 10; // NUM1
4343: ADCM 12; // RESULT+2
4346: STA 12; // RESULT+2
4349: TYA;
4350: ADCM 11; // NUM1+1
4353: RORA; // [L2]"Stairstep" shift
4354: RORM 12; // RESULT+2
4357: RORM 11; // RESULT+1
4360: RORM 10; // RESULT
4363: DEX;
4364: BNE 4;
4366: JMP 4327; //L1
4369: STA 13; // RESULT+3

// After the above multiplication loop, num = num * multiplier

4372: CLC;
4373: LDAM 10;
4376: ADCM 14;
4379: STA 10;
4382: LDAM 11;
4385: ADCI 0;
4387: STA 11; // num = num + currentDigit

// codePtr++
4390: LDAM 02;
4393: ADCI 1;
4395: STA  02;
4398: LDAM 03;
4401: ADCI 0;
4403: STA  03;

4406: JMP 4303; // Jump to the beginning of the operand loop

// Post operand loop, codePtr increment
// codePtr++
4409: LDAM 02;
4412: ADCI 1;
4414: STA  02;
4417: LDAM 03;
4420: ADCI 0;
4422: STA  03;

4425: LDAM 10; // A = LB num
4428: STAZPI 17; // processor.RAM[compiledPtr] = LB num

// compiledPtr++
4430: CLC;
4431: LDAM 17;
4434: ADCI 1;
4436: STA  17;
4439: LDAM 18;
4442: ADCI 0;
4444: STA  18;

4447: LDAM 11; // A = HB num
4450: CMPI 0; // HB num == 0 ?
4452: BNE 4; // Branch 4 Bytes ahead, if the result is not zero, storing of the HB num as well
4454: JMP 4030; // Jump to the start of the assembler loop if the HB num is zero

4457: STAZPI 17; // processor.RAM[compiledPtr] = HB num

// compiledPtr++
4459: CLC;
4460: LDAM 17;
4463: ADCI 1;
4465: STA  17;
4468: LDAM 18;
4471: ADCI 0;
4473: STA  18;


4476: JMP 4030; // Jump to the start of the assembler loop