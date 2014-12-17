module huffman;

import std.stdio;
import std.bitmanip;
import std.exception;

import utils;

enum HEADER = "ZAiSD";

void compress(ubyte chunksize, File input, File output) {
    output.write(HEADER);

    auto i = input.toChunks(chunksize);
    auto f = computeFrequencies(i);

    output.writeInt(chunksize);
    output.writeFrequencies(f);
    output.rawWrite(encode(buildTree(f), i));
}

void decompress(File input, File output) {
    char[] h;
    h.length = HEADER.length;
    h = input.rawRead(h); // The heck D File API?

    enforce(h == HEADER, "Cannot decompress non-" ~ HEADER ~ " files.");

    auto chunksize = input.readInt!ubyte();
    auto f = readFrequencies(input, chunksize);

    output.rawWrite(decode(buildTree(f), input.toChunks(chunksize)));
}

    output.rawWrite(decode(buildTree(f), input.toWords()));
}

struct HuffmanTree {
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

size_t[] encode(HuffmanTree tree, Chunk[] data) {
    BitArray ba;

    foreach(chunk; data) {
        enforce(tree.contains(chunk), "Malformed Huffman encoding table has been produced.");
        ba ~= tree[chunk];
    }

    return cast(size_t[]) ba;
}

ubyte[] decode(HuffmanTree tree, size_t[] data) {
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

HuffmanTree buildTree(FrequencyTable f) {
    // TODO
    return HuffmanTree();
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
