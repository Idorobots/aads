module utils;

import std.stdio;
import std.container;

string slurp(File f) {
    string output;
    foreach(char[] line; f.byLine()) {
        output ~= line ~ "\n";
    }
    return output[0 .. $-1]; // NOTE Leave out the last newline.
}

void writeMatrix(M)(M m, size_t size) {
    for(size_t i = 0; i < size; ++i) {
        for(size_t j = 0; j < size; ++j) {
            writef("%4  d ", m[j * size + i]);
        }
        writeln();
    }
}

struct Queue(Element) {
    private DList!Element lst;

    bool empty() {
        return lst.empty();
    }

    bool enqueue(Element e) {
        return lst.insertBack(e) == 1;
    }

    Element dequeue() {
        auto e = lst.front();
        lst.removeFront();
        return e;
    }
}

struct ListNode(Element) {
    private ListNode!(Element)* next;
    public Element e;

    struct Range {
        private ListNode!(Element)* current;

        this(ListNode!(Element)* first) {
            current = first;
        }

        bool empty() {
            return current is null;
        }

        Element front() {
            assert(!empty());
            return current.e;
        }

        void popFront() {
            assert(!empty());
            current = current.next;
        }
    }

    this(Element e, ListNode!(Element)* p = null) {
        this.next = p;
        this.e = e;
    }

    size_t length() {
        return next ? 1 + next.length() : 1;
    }

    static ListNode!(Element)* add(Element e, ListNode!(Element)* rest) {
        return new ListNode!(Element)(e, rest);
    }
}


bool contains(Range, Element)(Range r, Element e) {
    foreach(Element el; r) {
        if(el == e) return true;
    }

    return false;
}