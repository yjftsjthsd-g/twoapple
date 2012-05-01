/+
 + d6502/nmosbase.d
 +
 + Copyright: 2012 Gerald Stocker
 + Dual licensed under the MIT or GPL Version 2 licenses.
 +/

import d6502.cpu;

class NmosBase : Cpu
{
    this()
    {
        super();
        spuriousAddress = &badAddress;
    }

    static string RMW(string action)
    {
        return "poke(primaryAddress, (readVal = read(primaryAddress)));\n" ~
            "writeFinal(primaryAddress, flag.zero_ = flag.negative_ = " ~
            action ~ "(readVal));\n";
    }

    mixin(Opcode(mixin(Type2Address(
        "ASL", "Write", [0x06, 0x0E, 0x16, 0x1E])),
        RMW("shiftLeft")));
    mixin(Opcode(mixin(Type2Address(
        "LSR", "Write", [0x46, 0x4E, 0x56, 0x5E])),
        RMW("shiftRight")));
    mixin(Opcode(mixin(Type2Address(
        "ROL", "Write", [0x26, 0x2E, 0x36, 0x3E])),
        RMW("rotateLeft")));
    mixin(Opcode(mixin(Type2Address(
        "ROR", "Write", [0x66, 0x6E, 0x76, 0x7E])),
        RMW("rotateRight")));
    mixin(Opcode(mixin(Type2Address(
        "INC", "Write", [0xE6, 0xEE, 0xF6, 0xFE])),
        RMW("increment")));
    mixin(Opcode(mixin(Type2Address(
        "DEC", "Write", [0xC6, 0xCE, 0xD6, 0xDE])),
        RMW("decrement")));

    /* JMP ($$$$) */
    override void opcode6C()
    {
        ushort vector = readWordOperand();
        programCounter = readWord(vector,
                (vector & 0xFF00) | cast(ubyte)(vector + 1));
        version(CumulativeCycles) ticks(totalCycles);
    }
}
