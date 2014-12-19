module graham;

import std.typecons;
import std.algorithm;
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

void swap(ref Point[] points, uint i, uint j) {
    auto tmp = points[i];
    points[i] = points[j];
    points[j] = tmp;
}

Point[] convexHull(Point[] points) {
    auto N = points.length;

    points.sort!((p1, p2) => (p1.y != p2.y) ? p1.y < p2.y : p1.x < p2.x)();

    auto p0 = points[0];

    points.sort!((p1, p2) {
            auto a1 = p0.angle(p1);
            auto a2 = p0.angle(p2);
            return (a1 != a2) ? a1 < a2 : p0.distance(p2) >= p0.distance(p1);
        });

    // FIXME Filter out the collinear points.

    auto M = 1;

    for(uint i = 2; i < N; ++i) {
        while(ccw(points[M-1], points[M], points[i]) < 0) {
            if(M > 1) --M;
            else if(i == N-1) break;
            else ++i;
        }

        points.swap(i, ++M);
    }

    return points[0..M+1];
}
