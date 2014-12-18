module utils;

import std.stdio;
import std.array;

T readInt(T)(File f) {
    ubyte[T.sizeof] buffer;
    f.rawRead(buffer);
    return *cast(T*) buffer.ptr;
}

void writeInt(T)(File f, T v) {
    ubyte[T.sizeof] buffer;
    buffer = (cast(ubyte*) &v)[0..T.sizeof];
    f.rawWrite(buffer);
}

alias Chunk = ubyte[];
alias toChunks = toX!Chunk;
alias toBytes = toX!ubyte;
alias toWords = toX!size_t;

X[] toX(X)(File f, size_t chunksize = X.sizeof) {
    auto arr = appender!(X[])();

    foreach(chunk; f.byChunk(chunksize)) {
        arr ~= chunk.dup;
    }

    return arr.data;
}

Chunk[] toChunks(ubyte[] bytes, size_t chunksize) {
    auto chunks = appender!(Chunk[])();

    while(bytes.length > chunksize) {
        chunks ~= bytes[0..chunksize].dup;
        bytes = bytes[chunksize..$];
    }
    chunks ~= bytes[0..chunksize].dup;

    return chunks.data;
}

size_t currPos(File f, size_t pos = 0) {
    if(pos != 0) f.seek(pos);

    return f.tell();
}