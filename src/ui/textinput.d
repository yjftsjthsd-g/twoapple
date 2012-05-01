/+
 + ui/textinput.d
 +
 + Copyright: 2012 Gerald Stocker
 + Dual licensed under the MIT or GPL Version 2 licenses.
 +/

module ui.textinput;

import std.stream;

import gtkglc.glgdktypes;
import gtk.Widget;

class TextInput
{
    File file;
    int pos;
    string line;
    void delegate() onFinish;
    bool eol;

    this(string filename, void delegate() finished)
    {
        onFinish = finished;
        file = new File(filename);
    }

    ~this()
    {
        delete file;
    }

    bool getLine()
    {
        if (file.eof())
        {
            onFinish();
            return false;
        }
        line = file.readLine() ~ x"0D";
        pos = 0;
        return true;
    }

    ubyte read()
    {
        if (line is null)
        {
            if (!getLine())
                return 0;
        }
        return cast(ubyte)line[pos];
    }

    void advancePos()
    {
        if (line is null) return;
        if (++pos >= line.length)
        {
            getLine();
        }
    }
}
