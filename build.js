import * as esbuild from 'esbuild';
import { readdir } from "node:fs/promises";
import path from 'node:path';

let dir = await readdir('src', {
    recursive: true
});

dir = dir.filter((path) => path.includes('.ts') || path.includes('.js')).map((filePath) => path.join('src', filePath));
await esbuild.build({
    entryPoints: dir,
    outdir: 'build',
});