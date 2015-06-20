module icu.c.ucnv;

import std.stdint;

enum UErrorCode
{
    U_ZERO_ERROR = 0
}

struct UConverter;

extern(C) UConverter* ucnv_open_53(const(char)* converterName, UErrorCode* err) nothrow;
extern(C) void ucnv_close_53(UConverter* converter) nothrow;

extern(C) int8_t ucnv_getMinCharSize_53(const(UConverter)* converter) nothrow;
extern(C) int8_t ucnv_getMaxCharSize_53(const(UConverter)* converter) nothrow;

extern(C) void ucnv_toUnicode_53(UConverter* converter,
                                 wchar** target,
                                 const(wchar)* targetLimit,
                                 const(ubyte)** source,
                                 const(ubyte)* sourceLimit,
                                 int32_t* offsets,
                                 bool flush,
                                 UErrorCode* err) nothrow;

extern(C) void ucnv_fromUnicode_53(UConverter* converter,
                                   ubyte** target,
                                   const(ubyte)* targetLimit,
                                   const(wchar)** source,
                                   const(wchar)* sourceLimit,
                                   int32_t* offsets,
                                   bool flush,
                                   UErrorCode* err) nothrow;

alias ucnv_open = ucnv_open_53;
alias ucnv_close = ucnv_close_53;
alias ucnv_getMinCharSize = ucnv_getMinCharSize_53;
alias ucnv_getMaxCharSize = ucnv_getMaxCharSize_53;
alias ucnv_toUnicode = ucnv_toUnicode_53;
alias ucnv_fromUnicode = ucnv_fromUnicode_53;
