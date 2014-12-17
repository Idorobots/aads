module utils;

import std.stdio;
import std.array;

ubyte[][] readChunks(File f, size_t chunksize) {
    auto arr = appender!(ubyte[][])();

    foreach(ubyte[] chunk; f.byChunk(chunksize)) {
        arr ~= chunk.dup;
    }

    return arr.data;
}

size_t currPos(File f, size_t pos = 0) {
    if(pos != 0) f.seek(pos);

    return f.tell();
}