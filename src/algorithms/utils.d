module utils;

import std.stdio;

void writeMatrix(M)(M m, size_t size) {
    for(size_t i = 0; i < size; ++i) {
        for(size_t j = 0; j < size; ++j) {
            writef("%4  d ", m[j * size + i]);
        }
        writeln();
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