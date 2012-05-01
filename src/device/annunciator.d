/+
 + device/annunciator.d
 +
 + Copyright: 2012 Gerald Stocker
 + Dual licensed under the MIT or GPL Version 2 licenses.
 +/

module device.annunciator;

import device.base;
import memory;

class Annunciator
{
    bool[4] ann;

    void reboot()
    {
        ann[0..4] = false;
    }

    void activate(int index)
    {
        if (!ann[index])
        {
            ann[index] = true;
        }
    }

    void deactivate(int index)
    {
        if (ann[index])
        {
            ann[index] = false;
        }
    }

    void ann_0_On()
    {
        activate(0);
    }

    void ann_1_On()
    {
        activate(1);
    }

    void ann_2_On()
    {
        activate(2);
    }

    void ann_3_On()
    {
        activate(3);
    }

    void ann_0_Off()
    {
        deactivate(0);
    }

    void ann_1_Off()
    {
        deactivate(1);
    }

    void ann_2_Off()
    {
        deactivate(2);
    }

    void ann_3_Off()
    {
        deactivate(3);
    }

    mixin(EmptyInitSwitches());
}

class Annunciator_II : Annunciator
{
    mixin(InitSwitches("super", [
        mixin(MakeSwitch([0xC058], "R0W", "ann_0_Off")),
        mixin(MakeSwitch([0xC059], "R0W", "ann_0_On")),
        mixin(MakeSwitch([0xC05A], "R0W", "ann_1_Off")),
        mixin(MakeSwitch([0xC05B], "R0W", "ann_1_On")),
        mixin(MakeSwitch([0xC05C], "R0W", "ann_2_Off")),
        mixin(MakeSwitch([0xC05D], "R0W", "ann_2_On")),
        mixin(MakeSwitch([0xC05E], "R0W", "ann_3_Off")),
        mixin(MakeSwitch([0xC05F], "R0W", "ann_3_On"))
    ]));
}

// NOTE: IIe uses Annunciator (the switches are handled by the IOU)
// NOTE: IIc has no annunciators
