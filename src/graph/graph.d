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

struct VRange(ERange) {
    ERange r;
    alias r this;

    this(ERange r) {
        this.r = r;
    }

    Vertex front() {
        return r.front().v2();
    }
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
        if(edges.map!(edge => edge == e).any()) {
            auto fun = (Edge edge) => edge != e;

            verts[e.v1()] = verts[e.v1()].filter!(fun).array();
            edges = edges.filter!(fun).array();

            // NOTE Remove vertex iff no more edges point to it when it doesn't have any outgoing edges.
            if(this.edgesOf(e.v1()).empty && edges.map!(edge => edge.v2() == e.v1()).any()) {
                this.remove(e.v1());
            }
            return true;
        }
        return false;
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

struct MatrixGraph {
    size_t size;
    size_t numVerts;
    Weight[] verts;
    Edge[] edges;

    private void resize(size_t n) {
        if(n > size) {
            Weight[] newVerts;
            newVerts.length = n*n;

            for(Vertex x = 0; x < n; ++x) {
                for(Vertex y = 0; y < n; ++y) {
                    if(x < size && y < size) {
                         newVerts[y * n + x] = verts[y * size + x];
                    } else {
                        newVerts[y * n + x] = Weight.max;
                    }
                }
            }

            verts = newVerts;
            size = n;
        }
    }

    private bool contained(Vertex v) {
        return v < size && verts[v * size + v] == 0;
    }

    bool add(Vertex v) {
        if(contained(v)) return false;

        resize(v+1);

        for(Vertex i = 0; i < size; ++i) {
            verts[i * size + v] = Weight.max;
            verts[v * size + i] = Weight.max;
        }

        verts[v * size + v] = 0; // NOTE Indicates that a vertex is in the graph.
        numVerts++;

        return true;

    }

    bool remove(Vertex v) {
        if(!contained(v)) return false;

        for(Vertex i = 0; i < size; ++i) {
            verts[i * size + v] = Weight.max;
            verts[v * size + i] = Weight.max;
        }
        verts[v * size + v] = Weight.max; // NOTE Indicates that a vertex is removed from the graph.

        edges = edges.filter!(edge => edge.v1() == v || edge.v2() == v).array();
        numVerts--;

        return true;
    }

    bool add(Edge e) {
        if(!contained(e.v1()) || !contained(e.v2())) return false;

        verts[e.v2() * size + e.v1()] = e.w();
        edges ~= e;

        return true;
    }

    bool remove(Edge e) {
        if(edges.map!(edge => edge == e).any()) {
            verts[e.v2() * size + e.v1()] = Weight.max;
            edges = edges.filter!(edge => edge != e).array();

            // NOTE Remove vertex iff no more edges point to it when it doesn't have any outgoing edges.
            if(this.edgesOf(e.v1()).empty && edges.map!(edge => edge.v2() == e.v1()).any()) {
                this.remove(e.v1());
            }

        }
        return false;
    }

    alias Edges = Edge[];
    Edges edgesOf(Vertex v) {
        Edges es;

        for(Vertex u = 0; u < size; ++u) {
            auto w = verts[u * size + v];

            if(u != v && contained(u) && w < Weight.max) {
                es ~= Edge(v, u, w);
            }
        }

        return es;
    }

    alias Verteces = VRange!(Edges);
    Verteces neighboursOf(Vertex v) {
        return Verteces(this.edgesOf(v));
    }

    size_t numVerteces() {
        return numVerts;
    }

    size_t numEdges() {
        return edges.length;
    }

    bool neighbours(Vertex v1, Vertex v2) {
        if(v1 < size && v2 < size) {
            return verts[v2 * size + v1] != Weight.max;
        }
        return false;
    }
}

