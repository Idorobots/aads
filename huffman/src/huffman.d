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
    auto f = readFrequencies(input);

    output.rawWrite(decode(buildTree(f), input.toChunks(chunksize)));
}

alias HuffmanTree = BitArray[Chunk];

ubyte[] encode(HuffmanTree tree, Chunk[] data) {
    // TODO
    return [];
}

ubyte[] decode(HuffmanTree tree, Chunk[] data) {
    // TODO
    return [];
}

alias Frequency = size_t;
alias FrequencyTable = Frequency[Chunk];

HuffmanTree buildTree(FrequencyTable f) {
    // TODO
    return null;
}

FrequencyTable computeFrequencies(Chunk[] data) {
    // TODO
    return null;
}

void writeFrequencies(File output, FrequencyTable f) {
    // TODO
}

FrequencyTable readFrequencies(File input) {
    // TODO
    return null;
}