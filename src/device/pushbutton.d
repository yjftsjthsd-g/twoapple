/+
 + device/pushbutton.d
 +
 + Copyright: 2012 Gerald Stocker
 + Dual licensed under the MIT or GPL Version 2 licenses.
 +/

module device.pushbutton;

import device.base;
import memory;

class Pushbuttons
{
    bool buttons[3];

    void reboot()
    {
        buttons[0..3] = false;
    }

    void update(int btn, bool isDown)
    {
        buttons[btn] = isDown;
    }

    ubyte read(int btn)
    {
        return (buttons[btn] ? 0x80 : 0);
    }

    ubyte readPB0()
    {
        return read(0);
    }

    ubyte readPB1()
    {
        return read(1);
    }

    ubyte readPB2()
    {
        return read(2);
    }

    mixin(InitSwitches("", [
        mixin(MakeSwitch([0xC061, 0xC069], "R7", "readPB0")),
        mixin(MakeSwitch([0xC062, 0xC06A], "R7", "readPB1")),
        mixin(MakeSwitch([0xC063, 0xC06B], "R7", "readPB2"))
    ]));
}
