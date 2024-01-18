import { CPU } from "../6502.js";
import { printer } from "./printer.js";

export default function sourceCodeInspector(processor: CPU, srcCodePtr: number) {
    let ptr = 0;
    while (processor.RAM[srcCodePtr] != -1) {
        process.stdout.write(`${processor.RAM[srcCodePtr++]} `);
        ptr++;
    };
    printer();
    printer(ptr);
};