module graham;

import std.typecons;
import std.algorithm;
import std.array;
import std.math;
import std.conv;

struct Point {
    double x;
    double y;

    @property double angle(Point other) {
        return atan2(other.y - y, other.x - x);
    }

    @property double distance (Point other) {
        return sqrt((other.x - x)^^2 + (other.y - y)^^2);
    }

    string toString() {
        return "(" ~ to!string(x) ~ ", " ~ to!string(y) ~ ")";
    }
}

double ccw(Point p1, Point p2, Point p3) {
    return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);
}

Point[] convexHull(Point[] points) {
    // Sort points by coords.
    points.sort!((p1, p2) => (p1.y != p2.y) ? p1.y < p2.y : p1.x < p2.x)();

    auto p0 = points[0];

    // Sort points by polar coords to p0.
    points.sort!((p1, p2) {
            auto a1 = p0.angle(p1);
            auto a2 = p0.angle(p2);
            return (a1 != a2) ? a1 < a2 : p0.distance(p2) >= p0.distance(p1);
        });

    // Remove duplicates for good measure.
    points = points.uniq().array();

    auto N = points.length;

    // Skip colinear points.
    uint i;
    for(i = 2; i < N; ++i) {
        if(ccw(p0, points[1], points[i]) != 0) break;
    }

    auto hull = [p0, points[i - 1]];

    // ???
    for(uint j = i; j < N; ++j) {
        Point top;

        do {
            top = hull[$-1];
            hull = hull[0..$-1];
        } while(ccw(hull[$-1], top, points[j]) <= 0);

        hull ~= top;
        hull ~= points[j];
    }

    // PROFIT!
    return hull;
}
