import std.stdio;
import std.getopt;
import std.typecons;
import std.traits;
import std.c.stdlib;

import rk;
import kmp;

alias MatchFun = size_t[] function(string, string);

void test(string pattern, MatchFun f) {
    string text = "";

    foreach(line; stdin.byLine()) {
        text ~= line;
    }

    auto result = f(pattern, text);

    writeln("\"", pattern, "\" found at indeces: ", result);
}

void main(string[] args) {
    enum Algorithm {RabinKarp, KnuthMorrisPratt}

    Algorithm algorithm = Algorithm.RabinKarp;

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS] PATTERN");
        writeln();
        writeln("OPTIONS:");
        writefln("  %-20s%s", "-h --help", "Display this message.");
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
               "help|h", &help);

        if(args.length != 2) {
            help();
        }

        string pattern = args[1];

        switch(algorithm) {
            case Algorithm.KnuthMorrisPratt: return test(pattern, &knuthMorrisPratt);
            default:                         return test(pattern, &rabinKarp);
        }
    } catch (Exception e) {
        writeln("Error: ", e.msg);
        help();
    }
}
