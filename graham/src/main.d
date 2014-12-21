import std.c.stdlib;
import std.stdio;
import std.getopt;
import std.conv;
import std.algorithm;
import std.string;

import graham;

void main(string[] args) {
    bool completeHull = false;
    string infile;
    string outfile;

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS]");
        writeln();
        writeln("OPTIONS:");
        writefln("  %-20s%s", "-h --help", "Display this message.");
        writefln("  %-20s%s", "-i --infile", "Input file name.");
        writefln("  %-20s%s", "-o --outfile", "Output file name.");
        writefln("  %-20s%s", "-c --complete", "Specifies whether convex hull shuld begin and end at the same point.");
        exit(0);
    }

    try {
        getopt(args,
               "infile|i", &infile,
               "outfile|o", &outfile,
               "complete|c", &completeHull,
               "help|h", &help);

        auto input = stdin;
        auto output = stdout;

        if(infile != "") {
            input = File(infile, "rb");
        }

        if(outfile != "") {
            output = File(outfile, "wb");
        }

        Point[] points;

        foreach(line; input.byLine()) {
            auto a = line.split(", ").map!(to!double);
            points ~= Point(a[0], a[1]);
        }

        auto hull = convexHull(points);
        foreach(p; hull) {
            output.writeln(p.x, ", ", p.y);
        }

        if(completeHull) output.writeln(hull[0].x, ", ", hull[0].y);

    } catch(Exception e) {
        writeln("Error: ", e.msg);
        help();
    }
}
