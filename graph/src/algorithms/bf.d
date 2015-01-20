module algorithms.bf;

import graph;

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
