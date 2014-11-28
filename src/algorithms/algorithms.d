module algorithms;

import std.algorithm;

import graph;

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

auto path(Weight[] d, Vertex[] p, Vertex source, Vertex goal) {
    struct Path {
        private Weight[] d;
        private Vertex[] p;
        private Vertex current;
        private Vertex goal;

        this(Weight[] d, Vertex[] p, Vertex source, Vertex goal) {
            this.d = d;
            this.p = p;
            this.current = goal;
            this.goal = source;
        }

        bool empty() {
            auto next = p[current];
            return current == goal || next == Vertex.max;
        }

        Edge front() {
            auto next = p[current];
            assert(next != Vertex.max, "Bad path!");

            auto size = p.length;
            return Edge(current, next, d[next]);
        }

        void popFront() {
            assert(!this.empty(), "End of path!");
            current = p[current];
        }
    }

    return Path(d, p, source, goal);
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
bool fordFulkerson(Graph)(Graph g, Weight[] c, Flow[] f, Vertex source, Vertex goal) if (isGraph!Graph) {
    auto size =  g.numVerteces();

    foreach(Edge e; g.edges) {
        c[e.v2() * size + e.v1()] = e.w();
        f[e.v2() * size + e.v1()] = 0;
    }

    Weight[] d;
    Vertex[] p;

    d.length = size;
    p.length = size;

    bool findPath(Graph g, Vertex source, Vertex goal) {
        bellmanFord(g, d, p, source);

        auto pt = path(d, p, source, goal);

        for(;;) {
            if(pt.empty) return false;

            auto e = pt.front;

            if(c[e.v2() * size + e.v1()] == 0) return false;
            if(e.v2() == source) return true;

            pt.popFront();
        }

        assert(0, "Bad path");
    }

    bool compare(Edge e1, Edge e2) {
        return c[e1.v2() * size + e1.v1()] < c[e2.v2() * size + e2.v1()];
    }

    while(findPath(g, source, goal)) {
        auto minE = minCount!(compare)(path(d, p, source, goal));
        auto minC = minE[0].w();

        foreach(Edge e; path(d, p, source, goal)) {
            f[e.v2() * size + e.v1()] += minC;
            f[e.v1() * size + e.v2()] -= minC;
        }
    }

    return true;
}