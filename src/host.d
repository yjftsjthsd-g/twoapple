/+
 + host.d
 +
 + Copyright: 2012 Gerald Stocker
 + Dual licensed under the MIT or GPL Version 2 licenses.
 +/

module host;

import std.c.time;
import std.c.linux.linux;
import std.stdio;

import derelict.sdl.sdl;
import derelict.util.exception;

static this()
{
    delay = new Delay();

    try
    {
        DerelictSDL.load();
        writefln("Loaded lib = %s", DerelictSDL.libName);
    }
    catch (DerelictException e)
    {
        writefln("%s", e.msg);
        return;
    }
    if (SDL_Init(0) == -1)
    {
        writefln("%s", std.string.toString(SDL_GetError()));  
        return;
    }
    SDL = true;
}

static ~this()
{
    if (SDL) SDL_Quit();
}

bool SDL;

class Delay
{
    timeval timeNow, timeShould, timeDiff, timeCheck;
    uint checkCycles;
    static float speedCorrection = 1000000.0 / 1020478.0;
    bool delegate() soundCardActive;
    bool delegate() soundCardHasEnoughData;

    void sleep()
    {
        if (soundCardActive())
            sleepAudio();
        else
            sleepNoAudio();
    }

    void sleepAudio()
    {
        while (soundCardHasEnoughData())
        {
            usleep(1000); 
        }
    }

    void nap()
    {
        usleep(1000);
    }

    void sleepNoAudio()
    {
        if (timeShould.tv_usec >= 990_000)
        {
            ++timeShould.tv_sec;
            timeShould.tv_usec -= 1_000_000;
        }
        timeShould.tv_usec += 10_000;

        gettimeofday(&timeNow, null);

        // Assume that tv_sec = 0;
        if (timeCompare(&timeShould, &timeNow, &timeDiff))
            usleep(timeDiff.tv_usec);
    }

    void reset()
    {
        gettimeofday(&timeShould, null);
        resetSpeedCheck();
    }

    void resetSpeedCheck()
    {
        gettimeofday(&timeCheck, null);
        checkCycles = 0;
    }

    float checkSpeedPercent(uint cycles)
    {
        checkCycles += cycles;
        if (checkCycles > 1020478) // do calculation at least once per "second"
        {
            gettimeofday(&timeNow, null);
            timeCompare(&timeNow, &timeCheck, &timeDiff);
            uint elapsed = (timeDiff.tv_sec * 1000000) + timeDiff.tv_usec;
            if (elapsed >= 1000000)
            {
                float percent = cast(float)checkCycles / cast(float)elapsed;
                resetSpeedCheck();
                return percent * speedCorrection;
            }
        }
        return -1.0;
    }
}

bool timeCompare(timeval* later, timeval* earlier, timeval* diff)
{
    if (later.tv_usec < earlier.tv_usec) {
        int nsec = (earlier.tv_usec - later.tv_usec) / 1000000 + 1;
        earlier.tv_usec -= 1000000 * nsec;
        earlier.tv_sec += nsec;
    }
    if (later.tv_usec - earlier.tv_usec > 1000000) {
        int nsec = (later.tv_usec - earlier.tv_usec) / 1000000;
        earlier.tv_usec += 1000000 * nsec;
        earlier.tv_sec -= nsec;
    }

    if (later.tv_sec >= earlier.tv_sec)
    {
        diff.tv_sec = later.tv_sec - earlier.tv_sec;
        diff.tv_usec = later.tv_usec - earlier.tv_usec;
        return true;
    }
    else
        return false;
}

Delay delay;
