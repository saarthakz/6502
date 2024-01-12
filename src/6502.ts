class CPU {
    RAM: Array<number>;
    memSize: number;
    A: number = 0;
    X: number = 0;
    Y: number = 0;
    PC: number = 0;

    constructor(RAM: Array<number>) {
        this.RAM = RAM;
        this.memSize = RAM.length;
    };

};

export { CPU };