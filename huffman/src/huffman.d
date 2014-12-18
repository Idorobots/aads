module huffman;

import std.stdio;
import std.bitmanip;
import std.exception;

import utils;

enum HEADER = "ZAiSD";

void compress(ubyte chunksize, File input, File output) {
    output.write(HEADER);

    auto b = input.toBytes();
    auto i = b.toChunks(chunksize);
    auto f = computeFrequencies(i);

    output.writeInt(chunksize);
    output.writeInt(b.length);

    output.writeFrequencies(f);

    output.rawWrite(encode(buildTree(f), i));
}

void decompress(File input, File output) {
    char[] h;
    h.length = HEADER.length;
    h = input.rawRead(h); // The heck D File API?

    enforce(h == HEADER, "Cannot decompress non-" ~ HEADER ~ " files.");

    auto chunksize = input.readInt!ubyte();
    auto length = input.readInt!size_t();

    auto f = readFrequencies(input, chunksize);

    output.rawWrite(decode(buildTree(f), input.toWords())[0..length]);
}

    output.rawWrite(decode(buildTree(f), input.toWords()));
}

struct HuffmanEncoding {
    // TODO

    BitArray opIndex(Chunk c) {
        return BitArray();
    }

    Chunk opIndex(BitArray b) {
        return null;
    }

    bool contains(BitArray b) {
        return false;
    }

    bool contains(Chunk c) {
        return false;
    }
}

size_t[] encode(HuffmanEncoding tree, Chunk[] data) {
    BitArray ba;

    foreach(chunk; data) {
        enforce(tree.contains(chunk), "Malformed Huffman encoding table has been produced.");
        ba ~= tree[chunk];
    }

    return cast(size_t[]) ba;
}

ubyte[] decode(HuffmanEncoding tree, size_t[] data) {
    ubyte[] result;

    BitArray ba;
    ba.init(data, data.length * size_t.sizeof * 8);

    BitArray prefix;
    foreach(bit; ba) {
        prefix ~= bit;

        if(tree.contains(prefix)) {
            result ~= tree[prefix];
            prefix = BitArray();
        }
    }

    return result;
}

alias Frequency = size_t;
alias FrequencyTable = Frequency[Chunk];

HuffmanEncoding buildTree(FrequencyTable f) {
    // TODO
    return HuffmanEncoding();
}

FrequencyTable computeFrequencies(Chunk[] data) {
    FrequencyTable f;

    foreach(Chunk c; data) {
        f[c.idup]++;
    }

    return f;
}

void writeFrequencies(File output, FrequencyTable f) {
    output.writeInt(f.length);

    foreach(k, v; f) {
        output.rawWrite(k);
        output.writeInt(v);
    }
}

FrequencyTable readFrequencies(File input, ubyte chunksize) {
    FrequencyTable f;

    auto length = input.readInt!size_t();

    ubyte[] buffer;
    buffer.length = chunksize;

    for(size_t i = 0; i < length; ++i) {
        input.rawRead(buffer);

        auto freq = input.readInt!Frequency();

        f[buffer.idup] = freq;
    }

    return f;
}
