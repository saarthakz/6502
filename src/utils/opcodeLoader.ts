import { CPU } from "../6502.js";
import { printer } from "./printer.js";

const opCodeMemTableEntries = [
    ['LDAM', 'AD', '2'],
    ['LDAI', 'A9', '1'],
    ['LDAZPI', 'B2', '1'],
    ['LDXM', 'AE', '2'],
    ['LDXI', 'A2', '1'],
    ['LDYM', 'AC', '2'],
    ['LDYI', 'A0', '1'],
    ['STA', '8D', '2'],
    ['STAZPI', '92', '1'],
    ['STX', '8E', '2'],
    ['STY', '8C', '2'],
    ['ADCM', '6D', '2'],
    ['ADCI', '69', '1'],
    ['SBCM', 'ED', '2'],
    ['SBCI', 'E9', '1'],
    ['INCM', 'EE', '2'],
    ['INCA', '1A', '0'],
    ['INX', 'E8', '0'],
    ['INY', 'C8', '0'],
    ['DECM', 'CE', '2'],
    ['DECA', '3A', '0'],
    ['DEX', 'CA', '0'],
    ['DEY', '88', '0'],
    ['TAX', 'AA', '0'],
    ['TAY', 'A8', '0'],
    ['TXA', '8A', '0'],
    ['TYA', '98', '0'],
    ['ANDM', '2D', '2'],
    ['ANDI', '29', '1'],
    ['EORM', '4D', '2'],
    ['EORI', '49', '1'],
    ['ORAM', '0D', '2'],
    ['ORAI', '09', '1'],
    ['CMPM', 'CD', '2'],
    ['CMPI', 'C9', '1'],
    ['CMPZPI', 'D2', '1'],
    ['CPXM', 'EC', '2'],
    ['CPXI', 'E0', '1'],
    ['CPYM', 'CC', '2'],
    ['CPYI', 'C0', '1'],
    ['ASLM', '0E', '2'],
    ['ASLA', '0A', '0'],
    ['LSRM', '4E', '2'],
    ['LSRA', '4A', '0'],
    ['ROLM', '2E', '2'],
    ['ROLA', '2A', '0'],
    ['RORM', '6E', '2'],
    ['RORA', '6A', '0'],
    ['JMP', '4C', '2'],
    ['BCC', '90', '1'],
    ['BCS', 'B0', '1'],
    ['BEQ', 'F0', '1'],
    ['BNE', 'D0', '1'],
    ['BMI', '30', '1'],
    ['BPL', '10', '1'],
    ['BVC', '50', '1'],
    ['BVS', '70', '1'],
    ['CLC', '18', '0'],
    ['CLV', 'B8', '0'],
    ['SEC', '38', '0'],
    ['JSR', '20', '2'],
    ['RTS', '60', '0'],
];

// Loading opcode memory entries from the location 0 in the RAM
export function opCodeLoader(processor: CPU, memPtr: number) {
    for (const [mnemonic, opcodeHex, operandBytes] of opCodeMemTableEntries) {
        // Loading the mnemonic characters into memory
        for (let charIdx = 0; charIdx < mnemonic.length; charIdx++) {
            processor.RAM[memPtr] = mnemonic.charCodeAt(charIdx);
            memPtr++;
        };
        memPtr++; //Skipping a mem location in between to keep in track where the mnemonic entry ended

        const opCodeDecimal = parseInt(opcodeHex, 16); // Converting the Hexadecimal String into it's decimal number
        processor.RAM[memPtr] = opCodeDecimal; // Loading the opcode into the memory
        memPtr++;
        processor.RAM[memPtr] = Number(operandBytes); // Loading, the number of bytes to be accepted after the opcode, into memory
        memPtr += 2;
    };

    return memPtr;
};