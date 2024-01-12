import { CPU } from "./6502.js";
import { opCodeLoader } from "./opcodeLoader.js";
import sourceCodeLoader from "./sourceCodeLoader.js";
import { printer } from "./utils/printer.js";
import { writeFile } from "fs/promises";
import { opCodeToMnemonic } from "./utils/opCodeReference.js";

const processor = new CPU(new Array(2 ** 16).fill(-1)); //64KB Memory space

async function runAssembler(processor: CPU) {

    // First 256 Bytes (0-255) of Memory are reserved for 'Zero Page Indirect Instructions'

    let memPtrStart = 256;
    let memPtrEnd = opCodeLoader(processor, memPtrStart); //Location of the memory pointer after the opcode memory table has been loaded.
    let srcCodePtrStart = 2 ** 15;
    let srcCodePtrEnd = sourceCodeLoader(processor, 'src.asm', srcCodePtrStart); //Location of the memory pointer after the source code has been loaded

    let codePtr = srcCodePtrStart;
    let code = '';

    let idx = 0;
    // Run till the end of the source code
    while (codePtr != srcCodePtrEnd) {
        let codeLineStart = codePtr;
        // Each src code line starts with a mnemonic
        // While you haven't reached the end of the mnemonic

        let opCodePtr = memPtrStart;
        while (processor.RAM[codePtr] != ' '.charCodeAt(0)) {
            // If all the opcodes are exhausted and the src mnemonic was still not matched, the src mnemonic is invalid/incorrect
            if (processor.RAM[opCodePtr] == -1) {
                break; // Skip to the next code line
            };

            // If the mnemonic, at any character doesn't before it's end, the current opcode is the not the one required, hence set the flag as false
            if (processor.RAM[codePtr] != processor.RAM[opCodePtr]) {
                codePtr = codeLineStart; //Reset the source code pointer to point at the beginning again

                // Skipping all the remaining mnemonic bytes and the other info in the opcode entry for the current opcode
                while (processor.RAM[opCodePtr] != -1) opCodePtr++;
                opCodePtr += 4; //Moving the pointer to the start of the next opcode
                continue; //Start the loop again
            };

            opCodePtr++;
            codePtr++;
        };

        // Opcode mnemonic was found and matched

        // opCodePtr points to -1 and 
        opCodePtr++; // opCodePtr + 1 points to the opCode 
        let opCode = processor.RAM[opCodePtr];

        opCodePtr++; // opCodePtr + 2 points to the number of operand bytes
        let operandBytes = processor.RAM[opCodePtr];

        // codePtr points to the ' ' [Space] character or points to the end of line character ';' if it is a one byte instruction,

        codePtr++; // codePtr, after increment now points to the highest digit of the operand or to the next line.
        // If the operand bytes are zero, this means that codePtr infact points to the next line and we need to restart the assembly loop
        if (!operandBytes) {
            code += `${opCode.toString(16)}\n`;
            continue;
        };

        let num = 0;
        while (processor.RAM[codePtr] != ';'.charCodeAt(0)) {
            let currentDigit = processor.RAM[codePtr];
            currentDigit -= 48; //ASCII Code for '0' is 48 so to get the numeric value of the digit, we subtract 48
            num = num * 10; //Moving the number to accommodate the next digit
            num = num + currentDigit; // Inserting the new digit into the number
            codePtr++;
        };

        // When the above loop ends, the codePtr will be pointing to the end of line character ';'
        codePtr++; // Now the codePtr points to the first byte of the next line

        let assembledCode = `${opCode.toString(16)} ${num.toString(16)}\n`;
        code += assembledCode;

    };

    await writeFile('Output.txt', code);
};

runAssembler(processor);