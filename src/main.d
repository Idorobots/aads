import core.memory;

import std.c.stdlib;
import std.getopt;
import std.typecons;
import std.traits;
import std.stdio;
import std.algorithm;
import std.string;
import std.conv;
import std.range;
import std.datetime;

import graph;
import algorithms;


void writeMatrix(M)(M m, size_t size) {
    for(size_t i = 0; i < size; ++i) {
        for(size_t j = 0; j < size; ++j) {
            writef("%4  d ", m[j * size + i]);
        }
        writeln();
    }
}

void testFW() {
    writeln("Floyd-Warshall:");

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
    floydWarshall(g1, d, p);
    sw.stop();

    GC.enable();

    auto t1 = sw.peek();

    writeln(typeof(g1).stringof, " time: ", t1.msecs);

    GC.disable();

    sw.reset();
    sw.start();
    floydWarshall(g2, d, p);
    sw.stop();

    GC.enable();

    auto t2 = sw.peek();
    writeln(typeof(g2).stringof, " time: ", t2.msecs);
    writeln("Ratio: ", (1.0 * t1.msecs)/t2.msecs);

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

    // write("O(1) version:");

    // enum graph = import("./g2");
    // enum lines = graph.split("\n");
    // enum g = ListGraph();

    // foreach(line; lines) {
    //     enum a = line.split("; ").map!(to!Vertex);
    //     g.add(a[0]);
    //     g.add(a[1]);
    //     g.add(Edge(a[0], a[1], a[2]));
    // }

    // enum n = g.numVerteces();

    // enum Weight[n*n] ws = void;
    // enum Vertex[n*n] ps = void;

    // sw.reset();
    // sw.start();
    // enum r = floydWarshall(g, ws, ps);
    // sw.stop();

    // writeln(sw.peek().msecs);
}

void testBF() {
    writeln("Bellman-Ford:");

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
    Vertex source = 109;

    d.length = size * size;
    p.length = size * size;


    GC.disable();

    sw.reset();
    sw.start();
    bellmanFord(g1, d, p, source);
    sw.stop();

    GC.enable();

    auto t1 = sw.peek();

    writeln(typeof(g1).stringof, " time: ", t1.msecs);

    GC.disable();

    sw.reset();
    sw.start();
    bellmanFord(g2, d, p, source);
    sw.stop();

    GC.enable();

    auto t2 = sw.peek();
    writeln(typeof(g2).stringof, " time: ", t2.msecs);
    writeln("Ratio: ", (1.0 * t1.msecs)/t2.msecs);

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

void main(string[] args) {
    enum Algorithm {FloydWarshall, BellmanFord};
    Algorithm algorithm;

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS]");
        writeln();
        writeln("OPTIONS:");
        writefln("%-20s%s", "-h --help", "Display this message.");
        writef("%-20s%s", "-a --algorithm", "One of the following algorithms: ");

        foreach(e; EnumMembers!Algorithm) {
            writef("%s, ", e);
        }

        writeln();
        exit(0);
    }

    getopt(args,
           "algorithm|a", &algorithm,
           "help|h", &help);

    switch(algorithm) {
        case Algorithm.FloydWarshall: return testFW();
        case Algorithm.BellmanFord:   return testBF();
        default:                      return help();
    }
}