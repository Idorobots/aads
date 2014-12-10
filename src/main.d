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
import utils;

void testFW(string graph, Vertex source, Vertex goal) {
    writeln("Floyd-Warshall:");

    StopWatch sw;

    sw.start();
    auto g1 = ListGraph();
    auto g2 = MatrixGraph();

    foreach(line; graph.split("\n")) {
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

    sw.reset();
    sw.start();
    floydWarshall(g1, d, p);
    sw.stop();

    auto distance = d[goal * size + source];

    auto t1 = sw.peek();

    writeln(typeof(g1).stringof, " time: ", t1.msecs);

    sw.reset();
    sw.start();
    floydWarshall(g2, d, p);
    sw.stop();
    assert(d[goal * size + source] == distance);

    auto t2 = sw.peek();
    writeln(typeof(g2).stringof, " time: ", t2.msecs);
    writeln("Ratio: ", (1.0 * t1.msecs)/t2.msecs);

    writeln("Distance: ", distance);

    write("Predecessors: ");

    auto current = goal;
    while(current != source) {
        write(current, " -> ");
        current = p[current * size + source];
    }
    writeln(current);
}

void testBF(string graph, Vertex source, Vertex goal) {
    writeln("Bellman-Ford:");

    StopWatch sw;

    sw.start();
    auto g1 = ListGraph();
    auto g2 = MatrixGraph();

    foreach(line; graph.split("\n")) {
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

    d.length = size;
    p.length = size;

    sw.reset();
    sw.start();
    bellmanFord(g1, d, p, source);
    sw.stop();

    auto distance = d[goal];

    auto t1 = sw.peek();

    writeln(typeof(g1).stringof, " time: ", t1.msecs);

    sw.reset();
    sw.start();
    bellmanFord(g2, d, p, source);
    sw.stop();
    assert(d[goal] == distance);

    auto t2 = sw.peek();
    writeln(typeof(g2).stringof, " time: ", t2.msecs);
    writeln("Ratio: ", (1.0 * t1.msecs)/t2.msecs);

    writeln("Distance: ", distance);

    write("Predecessors: ");

    auto current = goal;
    while(current != source) {
        write(current, " -> ");
        current = p[current];
    }
    writeln(current);
}

void testFF(string graph, Vertex source, Vertex goal) {
    writeln("Ford-Fulkerson:");

    StopWatch sw;

    sw.start();
    auto g1 = ListGraph();
    auto g2 = MatrixGraph();

    foreach(line; graph.split("\n")) {
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

    sw.reset();
    sw.start();
    auto flow = fordFulkerson(g1, source, goal);
    sw.stop();

    auto t1 = sw.peek();

    writeln(typeof(g1).stringof, " time: ", t1.msecs);

    sw.reset();
    sw.start();
    auto f = fordFulkerson(g2, source, goal);
    sw.stop();
    assert(f == flow);

    auto t2 = sw.peek();
    writeln(typeof(g2).stringof, " time: ", t2.msecs);
    writeln("Ratio: ", (1.0 * t1.msecs)/t2.msecs);

    Flow sourceMax, goalMax;
    foreach(Edge e; g1.edges) {
        if(e.v1() == source) sourceMax += e.w();
        if(e.v2() == goal) goalMax += e.w();
    }

    writeln("Flow: ", sourceMax, " >= ", flow, " <= ", goalMax);
}

void main(string[] args) {
    enum Algorithm {FloydWarshall, BellmanFord, FordFulkerson, All}

    Algorithm algorithm = Algorithm.All;
    Vertex source;
    Vertex goal;
    bool noGC = false;
    string filename = "";

    void help() {
        writeln("Usage: ", args[0], " [OPTIONS]");
        writeln();
        writeln("OPTIONS:");
        writefln("  %-20s%s", "-h --help", "Display this message.");
        writefln("  %-20s%s", "-f --filename", "Read graph data from file.");
        writefln("  %-20s%s", "-s --source", "Source vertex.");
        writefln("  %-20s%s", "-g --goal", "Goal vertex.");
        writef("  %-20s%s", "-a --algorithm", "One of the following algorithms: ");

        foreach(e; EnumMembers!(Algorithm)[0 .. $-1]) {
            writef("%s, ", e);
        }

        writeln();
        writefln("  %-20s%s", "   --no-gc", "Disable GC for the test.");

        exit(0);
    }

    try {
        getopt(args,
               "filename|f", &filename,
               "algorithm|a", &algorithm,
               "source|s", &source,
               "goal|g", &goal,
               "help|h", &help,
               "no-gc", &noGC);

        if(noGC) {
            writeln("GC is disabled.");
            GC.disable();
        }

        auto file = stdin;

        if(filename != "") {
            file = File(filename, "r");
        }

        auto graph = slurp(file);

        switch(algorithm) {
            case Algorithm.FloydWarshall: return testFW(graph, source, goal);
            case Algorithm.BellmanFord:   return testBF(graph, source, goal);
            case Algorithm.FordFulkerson: return testFF(graph, source, goal);
            default: {

                testFW(graph, source, goal);
                testBF(graph, source, goal);
                testFF(graph, source, goal);
                return;
            }
        }
    } catch (Exception e) {
        return help();
    }
}