import std.stdio;
import std.getopt;
import std.typecons;
import std.traits;
import std.c.stdlib;
import std.algorithm;

import algorithms.rk;
import algorithms.kmp;

alias MatchFun = size_t[] function(string, string);

void test(bool verbose, uint context, string pattern, MatchFun f) {
    string text = "";

    foreach(chunk; stdin.byChunk(1024)) {
        text ~= chunk;
    }

    auto result = f(pattern, text);

    if(result.length) {
        writeln("\"", pattern, "\" found ", result.length, " times at indeces: ", result);

        if(verbose) {
            foreach(index; result) {
                auto lower = max(0, cast(long) index - cast(long) context);
                auto upper = min(text.length, index + pattern.length + context);

                writeln(text[lower..index],"[", pattern, "]", text[index + pattern.length .. upper]);
            }
        }
    } else {
        writeln("\"", pattern, "\" not found.");
    }
}

void main(string[] args) {
    enum Algorithm {RabinKarp, KnuthMorrisPratt}

    Algorithm algorithm = Algorithm.RabinKarp;
    uint context = 10;
    bool verbose = false;

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS] PATTERN");
        writeln();
        writeln("OPTIONS:");
        writefln("  %-20s%s", "-h --help", "Display this message.");
        writefln("  %-20s%s", "-v --verbosity", "Display CONTEXT surrounding output bytes.");
        writefln("  %-20s%s", "-c --context", "Set number of context bytes.");
        writef("  %-20s%s", "-a --algorithm", "One of the following algorithms: ");

        foreach(e; EnumMembers!(Algorithm)[0 .. $]) {
            writef("%s, ", e);
        }

        writeln();
        exit(0);
    }

    try {
        getopt(args,
               "algorithm|a", &algorithm,
               "verbose|v", &verbose,
               "context|c", &context,
               "help|h", &help);

        if(args.length != 2) {
            help();
        }

        string pattern = args[1];

        switch(algorithm) {
            case Algorithm.KnuthMorrisPratt: return test(verbose, context, pattern, &knuthMorrisPratt);
            default:                         return test(verbose, context, pattern, &rabinKarp);
        }
    } catch (Exception e) {
        writeln("Error: ", e.msg);
        help();
    }
}
