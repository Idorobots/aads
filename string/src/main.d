import std.stdio;
import std.getopt;
import std.typecons;
import std.traits;
import std.c.stdlib;

import algorithms.rk;
import algorithms.kmp;

alias MatchFun = size_t[] function(string, string);

void test(bool extraOutput, string pattern, MatchFun f) {
    string text = "";

    foreach(line; stdin.byLine()) {
        text ~= line;
    }

    auto result = f(pattern, text);

    if(result.length) {
        writeln("\"", pattern, "\" found ", result.length, " times at indeces: ", result);

        if(extraOutput) {
            foreach(index; result) {
                writeln(text[0..index],"[", pattern, "]", text[index + pattern.length .. $]);
            }
        }
    } else {
        writeln("\"", pattern, "\" not found.");
    }
}

void main(string[] args) {
    enum Algorithm {RabinKarp, KnuthMorrisPratt}

    Algorithm algorithm = Algorithm.RabinKarp;
    bool verbose = false;

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS] PATTERN");
        writeln();
        writeln("OPTIONS:");
        writefln("  %-20s%s", "-h --help", "Display this message.");
        writefln("  %-20s%s", "-v --verbose", "Display verbose output.");
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
               "help|h", &help);

        if(args.length != 2) {
            help();
        }

        string pattern = args[1];

        switch(algorithm) {
            case Algorithm.KnuthMorrisPratt: return test(verbose, pattern, &knuthMorrisPratt);
            default:                         return test(verbose, pattern, &rabinKarp);
        }
    } catch (Exception e) {
        writeln("Error: ", e.msg);
        help();
    }
}
