module huffman;

import std.array;
import std.stdio;
import std.bitmanip;
import std.exception;
import std.algorithm;

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

    output.rawWrite(decode(buildTree(f), input.toBytes())[0..length]);
}

struct HuffmanTree {
    Frequency f;
    const Chunk c;
    HuffmanTree* left, right;

    this(Frequency f, const Chunk c = null, HuffmanTree* left = null, HuffmanTree* right = null) {
        this.f = f;
        this.left = left;
        this.right = right;
        this.c = c;
    }
}

struct HuffmanEncoding {
    struct BitArrayWrapper {
        BitArray ba;

        const int opCmp(ref const BitArrayWrapper baw) {
            return ba.opCmp(baw.ba.dup);
        }

        const bool opEquals(ref const BitArrayWrapper baw) {
            return ba.opEquals(baw.ba);
        }

        const size_t toHash() {
            return ba.toHash();
        }
    }

    Chunk[BitArrayWrapper] chunks;
    BitArray[Chunk] prefixes;

    this(HuffmanTree* t) {
        void treeWalk(HuffmanTree* node, BitArray ba) {
            if(node.c !is null) {
                auto baw = BitArrayWrapper(ba);
                chunks[BitArrayWrapper(ba)] = node.c.dup;
                prefixes[node.c] = ba;
            } else {
                treeWalk(node.left, ba.dup ~ false);
                treeWalk(node.right, ba.dup ~ true);
            }
        }

        treeWalk(t, BitArray());
    }

    BitArray opIndex(Chunk c) {
        return prefixes[c];
    }

    Chunk opIndex(BitArray b) {
        return chunks[BitArrayWrapper(b)];
    }

    bool contains(BitArray b) {
        return (BitArrayWrapper(b) in chunks) !is null;
    }

    bool contains(Chunk c) {
        return (c in prefixes) !is null;
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

ubyte[] decode(HuffmanEncoding tree, ubyte[] data) {
    auto result = appender!(ubyte[])();

    BitArray ba;
    ba.init(data, data.length * size_t.sizeof);

    BitArray prefix;
    foreach(bit; ba) {
        prefix ~= bit;

        if(tree.contains(prefix)) {
            result ~= tree[prefix];
            prefix = BitArray();
        }
    }

    return result.data;
}

alias Frequency = size_t;
alias FrequencyTable = Frequency[Chunk];

HuffmanEncoding buildTree(FrequencyTable f) {
    HuffmanTree*[] nodes;

    foreach(k, v; f) {
        nodes ~= new HuffmanTree(v, k);
    }

    nodes.sort!((e1, e2) => e1.c < e2.c)();

    while(nodes.length > 1) {
        nodes.sort!((e1, e2) => e1.f < e2.f)();
        auto node = new HuffmanTree(nodes[0].f + nodes[1].f, null, nodes[0], nodes[1]);
        nodes = nodes[2..$] ~ node;
    }

    return HuffmanEncoding(nodes[0]);
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
