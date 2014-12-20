import std.stdio;
import std.getopt;
import std.conv;
import std.algorithm;
import std.string;

import graham;

void main(string[] args) {
    bool completeHull = false;

    getopt(args,
           "complete|c", &completeHull);
    Point[] points;

    foreach(line; stdin.byLine()) {
        auto a = line.split(", ").map!(to!double);
        points ~= Point(a[0], a[1]);
    }

    auto hull = convexHull(points);
    foreach(p; hull) {
        writeln(p.x, ", ", p.y);
    }

    if(completeHull) writeln(hull[0].x, ", ", hull[0].y);
}