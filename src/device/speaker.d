/+
 + device/speaker.d
 +
 + Copyright: 2012 Gerald Stocker
 + Dual licensed under the MIT or GPL Version 2 licenses.
 +/

module device.speaker;

import std.c.string;

import device.base;
import memory;
import timer;

class Speaker
{
    bool muted;
    Timer.Cycle cycle;

    int sampleTicks;
    ushort sample;

    uint lastToggleTick;
    bool toggled;

    short[] mainBuffer;
    short[] extraBuffer;
    uint mainIndex, extraIndex;

    this()
    {
        sample = 0x8000;
        mainBuffer.length = 8192;
    }

    void setTiming(uint hertz, int sampleFreq, Timer.Cycle deviceCycle)
    {
        extraBuffer.length = sampleTicks = (hertz / sampleFreq);
        cycle = deviceCycle;
    }

    mixin(InitSwitches("", [
        mixin(MakeSwitch([0xC030], "R0W", "toggleSpeaker"))
    ]));

    uint processExtraBuffer(uint elapsed)
    {
        uint newElapsed = elapsed;
        
        if (extraIndex != 0)
        {
            for (; extraIndex < extraBuffer.length; ++extraIndex)
            {
                if (newElapsed == 0) break;
                extraBuffer[extraIndex] = sample;
                --newElapsed;
            }
            if (extraIndex == extraBuffer.length)
            {
                extraIndex = 0;
                long sampleMean = 0;
                for (uint i = 0; i < extraBuffer.length; ++i)
                    sampleMean += cast(long)extraBuffer[i];
                sampleMean /= cast(long)extraBuffer.length;

                if (mainIndex < (mainBuffer.length - 1))
                {
                    mainBuffer[mainIndex++] = 
                        (muted ? 0 : cast(short)sampleMean);
                }
            }
        }

        return newElapsed;
    }

    void updateExtraBuffer(uint extraTicks)
    {
        if (extraTicks == 0) return;

        for (extraIndex = 0; extraIndex < extraTicks; ++extraIndex)
        {
            extraBuffer[extraIndex] =
                (muted ? 0 : sample);
        }
    }

    void update()
    {
        uint elapsedSinceToggle = cycle.currentVal() - lastToggleTick;
        lastToggleTick = cycle.currentVal();
        elapsedSinceToggle = processExtraBuffer(elapsedSinceToggle);
        
        uint samples = elapsedSinceToggle / sampleTicks;
        uint extraTicks = elapsedSinceToggle % sampleTicks;

        // update main buffer
        for (; mainIndex < (mainBuffer.length - 1); ++mainIndex)
        {
            if (samples == 0) break;
            mainBuffer[mainIndex] =
                (muted ? 0 : sample);
            --samples;
        }

        updateExtraBuffer(extraTicks);
    }

    void toggleSpeaker()
    {
        toggled = true;
        update();
        sample = ~sample; 
    }

    void clearBuffer()
    {
        mainIndex = 0;
        lastToggleTick = 0;
        toggled = false;
    }
}
