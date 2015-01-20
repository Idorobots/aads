module algorithms.ff;

import std.algorithm;

import graph;
import utils;

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

    bool findPath() {
        for(size_t i = 0; i < marked.length; ++i) {
            marked[i] = false;
        }

        Queue!Vertex queue;

        queue.enqueue(source);
        marked[source] = true;

        while(!queue.empty()) {
            auto v1 = queue.dequeue();

            foreach(Edge e; g.edgesOf(v1)) {
                auto v2 = e.v2();
                auto residual = (cast(Flow) e.w()) - f[v2 * size + v1];

                if(residual > 0) {
                    if(!marked[v2]) {
                        edgeTo[v2] = e;
                        marked[v2] = true;
                        queue.enqueue(v2);
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