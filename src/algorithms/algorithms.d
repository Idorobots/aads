module algorithms;

import std.algorithm;

import graph;
import utils;

bool floydWarshall(Graph)(Graph g, Weight[] d, Vertex[] p) if(isGraph!Graph) {
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

bool bellmanFord(Graph)(Graph g, Weight[] d, Vertex[]p, Vertex source) if(isGraph!Graph) {
    auto size =  g.numVerteces();

    for(Vertex v = 0; v < size; ++v) {
        d[v] = Weight.max;
        p[v] = -1;
    }

    d[source] = 0;

    bool changed = true;

    for(size_t i = 0; i < size && changed; ++i) {
        changed = false;

        foreach(Edge e; g.edges) {
            if(d[e.v1()] != Weight.max) {
                if(d[e.v1()] + e.w() < d[e.v2()]) {
                    d[e.v2()] = d[e.v1()] + e.w();
                    p[e.v2()] = e.v1();
                    changed = true;
                }
            }
        }
    }

    foreach(Edge e; g.edges) {
        if(d[e.v1()] + e.w() < d[e.v2()]) {
            assert(0, "Graph contains negative-weight cycle!");
        }
    }

    return true;
}

alias Flow = long;
bool fordFulkerson(Graph)(Graph g, Flow[] f, Vertex source, Vertex goal) if (isGraph!Graph) {
    auto size = g.numVerteces();

    foreach(Edge e; g.edges) {
        f[e.v2() * size + e.v1()] = 0;
    }

    alias Path = ListNode!(Edge)*;

    Path findPath(Vertex source, Vertex goal, Path acc = null) {
        if(source == goal) return acc;

        // FIXME Try adjusting the ordering of edges...
        foreach(Edge e; g.edgesOf(source)) {
            auto residual = (cast(Flow) e.w()) - f[e.v2() * size + e.v1()];

            if(residual > 0 && !Path.Range(acc).contains(e)) {
                auto result = findPath(e.v2(), goal, Path.add(e, acc));
                if(result !is null) return result;
            }
        }

        return null;
    }

    Path path;

    while((path = findPath(source, goal)) !is null) {
        auto flow = Path.Range(path)
                .map!(e => (cast(Flow) e.w()) - f[e.v2() * size + e.v1()])()
                .reduce!min();

        foreach(Edge e; Path.Range(path)) {
            f[e.v2() * size + e.v1()] += flow;
            f[e.v1() * size + e.v2()] -= flow;
        }
    }

    return true;
}