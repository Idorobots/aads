module huffman;

import std.stdio;
import std.bitmanip;
import std.exception;

import utils;

enum HEADER = "ZAiSD";

void compress(ubyte chunksize, File input, File output) {
    output.write(HEADER);

    auto i = input.readChunks(chunksize);
    auto f = computeFrequencies(i);

    output.rawWrite((&chunksize)[0..1]);
    output.writeFrequencies(f);
    output.rawWrite(encode(buildTree(f), i));
}

void decompress(File input, File output) {
    char[] h;
    h.length = HEADER.length;
    h = input.rawRead(h); // The heck D File API?

    enforce(h == HEADER, "Cannot decompress non-" ~ HEADER ~ " files.");

    ubyte chunksize;
    input.rawRead((&chunksize)[0..1]);

    auto f = readFrequencies(input);
    output.rawWrite(decode(buildTree(f), input.readChunks(chunksize)));
}

alias Chunk = ubyte[];
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