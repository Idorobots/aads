module algorithms;

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

bool bellmanFord(Graph)(Graph g, Weight[] d, Vertex[]p, Vertex source) if(isGraph!Graph) {

    return true;
}