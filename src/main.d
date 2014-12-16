import std.c.stdlib;

import std.stdio;
import std.getopt;
import std.typecons;

import huffman;

void main(string[] args) {
    bool comp, decomp;
    string outfile = "", infile = "";

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS & ACTIONS]");
        writeln();
        writeln("OPTIONS:");
        writefln("  %-20s%s", "-h --help", "Display this message.");
        writefln("  %-20s%s", "-i --infile", "Input file name.");
        writefln("  %-20s%s", "-o --outfile", "Output file name.");
        writeln("ACTIONS:");
        writefln("  %-20s%s", "-c --compress", "Compress input.");
        writefln("  %-20s%s", "-d --decompress", "Decompress input.");
        exit(0);
    }

    try {
        getopt(args,
               "infile|i", &infile,
               "outfile|o", &outfile,
               "compress|c", &comp,
               "decompress|d", &decomp);

        auto input = stdin;
        auto output = stdout;

        if(infile != "") {
            input = File(infile, "r");
        }

        if(outfile != "") {
            output = File(outfile, "w");
        }

        if(comp & decomp) {
            writeln("Error: Invalid actions were specified.");
            return help();
        } else if(comp) {
            return compress(input, output);
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