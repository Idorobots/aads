import std.c.stdlib;

import std.stdio;
import std.getopt;
import std.typecons;

import huffman;

void main(string[] args) {
    ubyte chunksize = 2;
    bool comp, decomp;
    string outfile = "", infile = "";

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS & ACTIONS]");
        writeln();
        writeln("OPTIONS:");
        writefln("  %-20s%s", "-h --help", "Display this message.");
        writefln("  %-20s%s", "-i --infile", "Input file name.");
        writefln("  %-20s%s", "-o --outfile", "Output file name.");
        writefln("  %-20s%s", "-s --chunksize", "Specifies the size of encoding chunks.");
        writeln("ACTIONS:");
        writefln("  %-20s%s", "-c --compress", "Compress input.");
        writefln("  %-20s%s", "-d --decompress", "Decompress input.");
        exit(0);
    }

    try {
        getopt(args,
               "infile|i", &infile,
               "outfile|o", &outfile,
               "chunksize|s", &chunksize,
               "compress|c", &comp,
               "decompress|d", &decomp);

        auto input = stdin;
        auto output = stdout;

        if(infile != "") {
            input = File(infile, "rb");
        }

        if(outfile != "") {
            output = File(outfile, "wb");
        }

        if(comp & decomp) {
            writeln("Error: Invalid actions were specified.");
            return help();
        } else if(comp) {
            return compress(chunksize, input, output);
        } else if(decomp) {
            return decompress(input, output);
        } else {
            return help();
        }
   } catch (Exception e) {
        writeln("Error: ", e.msg);
        help();
    }
}