import core.memory;

import std.typecons;
import std.stdio;
import std.algorithm;
import std.string;
import std.conv;
import std.range;
import std.datetime;

import graph;

bool warshalFloyd(Graph)(Graph g, Weight[] d, Vertex[] p) if(isGraph!(Graph)) {
    auto size = g.numVerteces();

    for(Vertex x = 0; x < size; ++x) {
        for(Vertex y = 0; y < size; ++y) {
            p[y * size + x] = -1;
            d[y * size + x] = Weight.max;
        }
        d[x * size + x] = 0;
    }

    foreach(Edge e; g.edges) {
        d[e.v2() * size + e.v1()] = e.w();
        p[e.v2() * size + e.v1()] = e.v1();
    }

    for(Vertex u = 0; u < size; ++u) {
        for(Vertex v1 = 0; v1 < size; ++v1) {
            for(Vertex v2 = 0; v2 < size; ++v2) {
                if(d[u * size + v1] != Weight.max && d[v2 * size + u] != Weight.max) {
                    Weight dist = d[u * size + v1] + d[v2 * size + u];

                    if(d[v2 * size + v1] > dist) {
                        d[v2 * size + v1] = dist;
                        p[v2 * size + v1] = p[v2 * size + u];
                    }
                }
            }
        }
    }

    return true;
}

void main() {
    StopWatch sw;

    sw.start();
    auto g1 = ListGraph();
    auto g2 = MatrixGraph();

    foreach(line; stdin.byLine()) {
        auto a = line.split("; ").map!(to!Vertex);
        g1.add(a[0]);
        g1.add(a[1]);
        g1.add(Edge(a[0], a[1], a[2]));
        g2.add(a[0]);
        g2.add(a[1]);
        g2.add(Edge(a[0], a[1], a[2]));
    }
    sw.stop();

    writeln("Build time: ", sw.peek().msecs);

    auto size = g1.numVerteces();
    writeln("Size: ", size);

    Weight[] d;
    Vertex[] p;

    d.length = size * size;
    p.length = size * size;

    GC.disable();

    sw.reset();
    sw.start();
    warshalFloyd(g1, d, p);
    sw.stop();

    GC.enable();

    auto t1 =  sw.peek();

    writeln("ListGraph time: ", t1.msecs);

    GC.disable();

    sw.reset();
    sw.start();
    warshalFloyd(g2, d, p);
    sw.stop();

    GC.enable();

    auto t2 = sw.peek();
    writeln("MatrixGraph time: ", t2.msecs);
    writeln("Ratio: ", (1.0 * t1.msecs)/t2.msecs);

    void writeMatrix(M)(M m, size_t size) {
        for(uint i = 0; i < size; ++i) {
            for(uint j = 0; j < size; ++j) {
                writef("%4  d ", m[j * size + i]);
            }
            writeln();
        }
    }

    Vertex source = 109;
    Vertex goal = 609;

    writeln("Distance:");
    //writeMatrix(d, size);
    writeln(d[goal * size + source]);

    writeln("Predecessors:");
    //writeMatrix(p, size);

    auto current = goal;
    while(current != source) {
        write(current, " -> ");
        current = p[current * size + source];
    }
    writeln(current);
}