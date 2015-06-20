module icu.icu;

import std.algorithm;
import std.conv : to;
import std.exception : assumeUnique;
import std.stdio;
import std.string : toStringz, indexOf;
import std.traits;
import std.typecons : scoped;

import icu.c.ucnv;

class ICU
{
    private string _encoding;
    private UErrorCode _error;
    private UConverter* _conv;
    private size_t _minCharSize;
    private size_t _maxCharSize;

    invariant()
    {
        assert(_error == UErrorCode.U_ZERO_ERROR, "_error = " ~ _error.to!string);
        assert(_conv !is null);
        assert(_minCharSize != 0);
        assert(_maxCharSize != 0);
    }

    this(string encoding)
    {
        _error = UErrorCode.U_ZERO_ERROR;

        _encoding = encoding;
        _conv = ucnv_open(encoding.toStringz, &_error);

        if (_conv is null)
        {
            return;
        }

        _minCharSize = ucnv_getMinCharSize(_conv);
        _maxCharSize = ucnv_getMaxCharSize(_conv);
    }

    ~this()
    {
        ucnv_close(_conv);
    }

    auto encoding() @property @safe nothrow pure const
    {
        return _encoding;
    }

    wstring decode(immutable(ubyte)[] str) @trusted
    {
        auto sourceLength = str.length;
        auto source = cast(const(ubyte)*)str.ptr;

        auto targetLength = sourceLength / _minCharSize;

        auto utf16 = new wchar[targetLength];
        utf16[] = '\u0000';

        auto target = utf16.ptr;

        ucnv_toUnicode(_conv,
                       &target, target + targetLength,
                       &source, source + sourceLength,
                       null, true, &_error);

        auto len = utf16.indexOf('\u0000');
        if (len == -1) len = utf16.length;

        return assumeUnique(utf16[0 .. len]);
    }

    immutable(ubyte)[] encode(wstring str) @trusted nothrow
    {
        auto sourceLength = str.length;
        auto source = cast(const(wchar)*)str.ptr;

        auto targetLength = sourceLength * _maxCharSize;

        auto bytes = new ubyte[targetLength];
        auto target = bytes.ptr;

        ucnv_fromUnicode(_conv,
                         &target, target + targetLength,
                         &source, source + sourceLength,
                         null, true, &_error);

        return assumeUnique(bytes.findSplitBefore([0x00, 0x00])[0]);
    }

    void write(S...)(S args)
    {
        foreach (arg; args)
        {
            alias T = typeof(arg);

            static if (is(T == wstring))
            {
                std.stdio.write(cast(string)encode(arg));
            }
            else
            {
                std.stdio.write(arg);
            }
        }
    }

    void writeln(S...)(S args)
    {
        write(args, '\n');
    }
}

wstring decode(immutable(ubyte)[] str, string encoding)
{
    return scoped!ICU(encoding).decode(str);
}

immutable(ubyte)[] encode(wstring str, string encoding)
{
    return scoped!ICU(encoding).encode(str);
}

version (unittest) void main() {}

unittest
{
    auto conv = new ICU("sjis");

    immutable(ubyte)[] sjis = [
        0x82, 0xB1,     // こ
        0x82, 0xF1,     // ん
        0x82, 0xC9,     // に
        0x82, 0xBF,     // ち
        0x82, 0xCD,     // は
        0x81, 0x41,     // 、
              0x44,     // D
        0x8C, 0xBE,     // 言
        0x8C, 0xEA,     // 語
              0x21      // !
    ];

    assert(conv.decode(sjis) == "こんにちは、D言語!"w);
    assert(sjis.decode("sjis") == "こんにちは、D言語!"w);
    assert(sjis.decode("sjis").encode("sjis") == sjis);

    conv.writeln(conv.decode(sjis));
}
