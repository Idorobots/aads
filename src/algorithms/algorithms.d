module algorithms;

import std.algorithm;

import graph;
import utils;

void floydWarshall(Graph)(Graph g, Weight[] d, Vertex[] p) if(isGraph!Graph) {
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
}

void bellmanFord(Graph)(Graph g, Weight[] d, Vertex[] p, Vertex source) if(isGraph!Graph) {
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
}

alias Flow = long;
Flow fordFulkerson(Graph)(Graph g, Vertex source, Vertex goal) if (isGraph!Graph) {
    auto size = g.numVerteces();

    Flow[] f;
    f.length = size * size;

    foreach(Edge e; g.edges) {
        f[e.v2() * size + e.v1()] = 0;
    }

    bool[] marked;
    Edge[] edgeTo;

    edgeTo.length = size;
    marked.length = size;

    alias Queue = Vertex[];

    bool findPath() {
        for(size_t i = 0; i < marked.length; ++i) {
            marked[i] = false;
        }

        Queue queue;
        queue ~= source;

        marked[source] = true;

        while(queue.length != 0) {
            auto v1 = queue[0];
            queue = queue[1 .. $];

            foreach(Edge e; g.edgesOf(v1)) {
                auto v2 = e.v2();
                auto residual = (cast(Flow) e.w()) - f[v2 * size + v1];

                if(residual > 0) {
                    if(!marked[v2]) {
                        edgeTo[v2] = e;
                        marked[v2] = true;
                        queue ~= v2;
                    }
                }
            }
        }

        return marked[goal];
    }

    Flow maxFlow;

    while(findPath()) {
        Flow flow = Flow.max;

        for(Vertex v = goal; v != source; v = edgeTo[v].v1()) {
            auto e = edgeTo[v];
            auto residual = (cast(Flow) e.w()) - f[e.v2() * size + e.v1()];
            flow = min(flow, residual);
        }

        for(Vertex v = goal; v != source; v = edgeTo[v].v1()) {
            auto e = edgeTo[v];
            f[e.v2() * size + e.v1()] += flow;
            f[e.v1() * size + e.v2()] -= flow;
        }

        maxFlow += flow;
    }

    return maxFlow;
}