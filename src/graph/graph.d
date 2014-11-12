module graph;

import std.array;
import std.typecons;
import std.algorithm;

alias Weight = ulong;
alias Vertex = ulong;
alias Edge = Tuple!(Vertex, Vertex, Weight);

auto v1 = (Edge e) => e[0];
auto v2 = (Edge e) => e[1];
auto w = (Edge e) => e[2];

template isGraph(Graph) {
    enum bool isGraph = is(typeof(
        (inout int = 0) {
            Graph g = Graph.init;
            g.add(Vertex.init);
            g.add(Edge.init);
            g.neighbours(Vertex.init, Vertex.init);
            g.neighboursOf(Vertex.init);
            g.edgesOf(Vertex.init);
            g.remove(Edge.init);
            g.remove(Vertex.init);
            g.numVerteces();
            g.numEdges();
            // g.edges; // FIXME Should check for these.
            // g.verteces;
        }));
}

struct ListGraph {
    Edge[][Vertex] verts;
    Edge[] edges; // FIXME This probably should be gone.

    bool add(Vertex v) {
        if(v in verts) return false;
        verts[v] = [];
        return true;
    }

    bool remove(Vertex v) {
        if(v !in verts) return false;
        verts.remove(v);
        // TODO Remove all edges pointing to this vertex.
        return true;
    }

    bool add(Edge e) {
        if(e.v1() in verts && e.v2() in verts) {
            verts[e.v1()] ~= e;
            edges ~= e;
            return true;
        }
        return false;
    }

    bool remove(Edge e) {
        if(e.v1() in verts) {
            auto fun = (Edge edge) => edge != e;

            verts[e.v1()] = verts[e.v1()][].filter!(fun).array();
            edges = edges[].filter!(fun).array();

            // NOTE Remove vertex iff no more edges point to it when it doesn't have any outgoing edges.
            if(verts[e.v1()].length == 0 && edges.map!(edge => edge.v2() == e.v1()).any()) {
                this.remove(e.v1());
            }
            return true;
        }
        return false;
    }

    struct VRange(R) {
        R r;
        alias r this;

        this(R r) {
            this.r = r;
        }

        Vertex front() {
            return r.front().v2();
        }
    }

    alias Edges = Edge[];
    Edges edgesOf(Vertex v) {
        return (v in verts) ? verts[v] : [];
    }

    alias Verteces = VRange!(Edges);
    Verteces neighboursOf(Vertex v) {
        return Verteces(this.edgesOf(v));
    }

    size_t numVerteces() {
        return verts.length;
    }

    size_t numEdges() {
        return edges.length;
    }

    bool neighbours(Vertex a, Vertex b) {
        return verts[a].map!(e => e.v2() == b).any();
    }

    @property Vertex[] verteces() {
        return verts.keys();
    }
}

alias MatrixGraph = ListGraph;

// FIXME Actually implement this...
// struct MatrixGraph {
//     Vertex[] verts;
//     Edge[] edges;

//     bool addVertex(Vertex v) {

//     }

//     bool removeVertex(Vertex v) {

//     }

//     bool addEdge(Edge e) {

//     }

//     bool removeEdge(Edge e) {

//     }


//     Verteces neighbours(Vertex v) {

//     }

//     Edges edges(Vertex v) {

//     }

//     size_t numVertexes() {

//     }

//     size_t numEdges() {

//     }

//     bool areNeighbours(Vertex v1, Vertex v2) {

//     }

//     @property Vertex[] verteces() {

//     }
// }

