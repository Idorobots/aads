module utils;

import std.stdio;
import std.array;

ubyte[][] readChunks(File f, size_t chunksize) {
    return f.byChunk(chunksize).array();
}

size_t currPos(File f, size_t pos = 0) {
    if(pos != 0) f.seek(pos);

    return f.tell();
}