module graham;

import std.typecons;
import std.algorithm;
import std.math;
import std.conv;

struct Point {
    float x;
    float y;

    @property float angle(Point other) {
        return atan2(other.y - y, other.x - x);
    }

    string toString() {
        return "(" ~ to!string(x) ~ ", " ~ to!string(y) ~ ")";
    }
}

float ccw(Point p1, Point p2, Point p3) {
    return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);
}

void swap(ref Point[] points, uint i, uint j) {
    auto tmp = points[i];
    points[i] = points[j];
    points[j] = tmp;
}

Point[] convexHull(Point[] points) {
    auto N = points.length;

    points.sort!((p1, p2) => p1.y < p2.y)();
    points.sort!((p1, p2) => p1.x < p1.x)();

    auto p0 = points[0];

    points[1..$].sort!((p1, p2) => p0.angle(p1) < p0.angle(p2));

    auto M = 1;

    for(uint i = 2; i < N; ++i) {
        while(ccw(points[M-1], points[M], points[i]) <= 0) {
            if(M > 1) --M;
            else if(i == N-1) break;
            else ++i;
        }

        ++M;
        points.swap(i, M);
    }

    return points[0..M+1];
}
