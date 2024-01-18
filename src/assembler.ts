import { CPU } from "./6502.js";
import { opCodeLoader } from "./utils/opcodeLoader.js";
import sourceCodeLoader from "./utils/sourceCodeLoader.js";
import { printer } from "./utils/printer.js";
import { writeFile } from "fs/promises";
import { opCodeToMnemonic } from "./utils/opCodeReference.js";
import sourceCodeInspector from "./utils/sourceCodeInspector.js";

const processor = new CPU(new Array(2 ** 16).fill(-1)); //64KB Memory space

async function runAssembler(processor: CPU) {

    // First 256 Bytes (0-255) of Memory are reserved for 'Zero Page Indirect Instructions'

    let memPtrStart = 256;
    opCodeLoader(processor, memPtrStart); //Location of the memory pointer after the opcode memory table has been loaded.
    let codePtr = 2 ** 15 * 1.5;
    let compiledPtr = 2 ** 15;
    sourceCodeLoader(processor, 'src.asm', codePtr);

    // Run till the end of the source code
    while (processor.RAM[codePtr] + 1 != 0) {
        let codeLineStart = codePtr;
        // Each src code line starts with a mnemonic
        // While you haven't reached the end of the mnemonic

        let opCodePtr = memPtrStart;

        // Mnemonic loop
        while (processor.RAM[codePtr] != ' '.charCodeAt(0)) {
            // If all the opcodes are exhausted and the src mnemonic was still not matched, the src mnemonic is invalid/incorrect
            if (processor.RAM[opCodePtr] + 1 == 0) {
                break; // Skip to the next code line
            };

            // If the mnemonic, at any character doesn't before it's end, the current opcode is the not the one required
            if (processor.RAM[codePtr] != processor.RAM[opCodePtr]) {
                codePtr = codeLineStart; //Reset the source code pointer to point at the beginning again

                // Skipping all the remaining mnemonic bytes and the other info in the opcode entry for the current opcode
                while (processor.RAM[opCodePtr] + 1 != 0)
                    opCodePtr++;

                opCodePtr += 4; //Moving the pointer to the start of the next opcode
                continue; //Start the mnemonic loop again
            };

            opCodePtr++;
            codePtr++;
        };

        // Opcode mnemonic was found and matched

        // opCodePtr points to -1 and 
        opCodePtr++; // opCodePtr + 1 points to the opCode 
        processor.RAM[compiledPtr] = processor.RAM[opCodePtr];

        compiledPtr++; // Move to the next space in memory to store the operand if any
        opCodePtr++; // opCodePtr + 2 points to the number of operand bytes
        let operandBytes = processor.RAM[opCodePtr];

        // codePtr points to the ' ' [Space] character or points to the end of line character ';' if it is a one byte instruction,

        codePtr++; // codePtr, after increment now points to the highest digit of the operand or to the next line.

        // If the operand bytes are zero, this means that codePtr in fact points to the next line and we need to restart the assembly loop
        if (operandBytes == 0) {
            continue;
        };

        let num = 0;
        // CharCode of ';' is 59
        let multiplier = 10;

        // Operand loop
        while (processor.RAM[codePtr] != ';'.charCodeAt(0)) {
            let currentDigit = processor.RAM[codePtr];
            currentDigit -= 48; //ASCII Code for '0' is 48 so to get the numeric value of the digit, we subtract 48

            num = num * multiplier; //Moving the number to accommodate the next digit
            num = num + currentDigit; // Inserting the new digit into the number
            codePtr++;
        };

        let str = num.toString(16).split('').reverse();

        let lowByte = 0;
        let highByte = 0;

        for (let idx = 0; idx < 2; idx++)
            lowByte += map[str[idx]] * (16 ** idx);


        processor.RAM[compiledPtr] = lowByte;

        for (let idx = 2; idx < str.length; idx++)
            highByte += map[str[idx]] * (16 ** (idx - 2));

        if (highByte !== 0) {
            processor.RAM[compiledPtr] = highByte;
            compiledPtr++;
        };

        // When the above loop ends, the codePtr will be pointing to the end of line character ';'
        codePtr++; // Now the codePtr points to the first byte of the next line

    };
};

runAssembler(processor);