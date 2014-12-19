import std.stdio;
import std.getopt;

import graham;

void main(string[] args) {

    Point[] points1 = [Point(0, 3),
                       Point(1, 1),
                       Point(2, 2),
                       Point(4, 4),
                       Point(0, 0),
                       Point(1, 2),
                       Point(3, 1),
                       Point(3, 3)];

    writeln(points1);
    writeln(convexHull(points1));

    Point[] points2 = [Point(-1, -1),
                       Point(-1, 1),
                       Point(0, 0),
                       Point(1, -1),
                       Point(1, 1)];

    writeln(points2);
    writeln(convexHull(points2));
}