import std.stdio;
import std.conv;
import std.algorithm;
import std.string;

import graham;

void main(string[] args) {

    Point[] points;

    foreach(line; stdin.byLine()) {
        auto a = line.split(", ").map!(to!double);
        points ~= Point(a[0], a[1]);
    }

    auto hull = convexHull(points);
    foreach(p; hull) {
        writeln(p.x, ", ", p.y);
    }

    writeln(hull[0].x, ", ", hull[0].y);
}