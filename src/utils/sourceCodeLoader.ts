import { CPU } from "../6502.js";
import fs from "node:fs";
import { printer } from "./printer.js";

export default function sourceCodeLoader(processor: CPU, path: string, srcCodePtr: number) {
    let srcCodeLines = fs.readFileSync(path, {
        encoding: "ascii"
    }).split('\n');

    for (let line of srcCodeLines) {
        line = line.trim();
        for (let charPtr = 0; charPtr < line.length; charPtr++) {
            processor.RAM[srcCodePtr] = line.charCodeAt(charPtr);
            srcCodePtr++;
        };
    };

    return srcCodePtr;
};