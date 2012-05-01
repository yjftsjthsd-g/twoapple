/+
 + peripheral/base.d
 +
 + Copyright: 2012 Gerald Stocker
 + Dual licensed under the MIT or GPL Version 2 licenses.
 +/

module peripheral.base;

import memory;
import device.base;
import timer;

import gtk.Box;
import gtk.VBox;

VBox peripheralStatus;

class Peripheral
{
    Box statusBox;

    ubyte[] ioSelectROM;
    ubyte[] ioStrobeROM;

    void plugIn(int slotNum, SoftSwitchPage switches, Timer timer)
    {
       initSwitches(switches, slotNum);
       initTimer(timer);

       if (statusBox !is null)
       {
           peripheralStatus.packStart(statusBox, false, false, 0);
       }
    }

    void reset() {}
    void reboot() {}
    void updateStatus() {}
    void initTimer(Timer timer) {}

    mixin(EmptyInitSwitches());
}

