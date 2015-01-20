module algorithms.rk;

import std.algorithm;

size_t hash(string str) {
    return str.reduce!((h, c) => (h << 1) + c)();
}

size_t rehash(char first, char last, size_t hash, size_t discriminant) {
    return ((cast(long) hash - first * cast(long) discriminant) << 1) + last;
}

size_t[] rabinKarp(string pattern, string text) {
    if(text.length == 0 || pattern.length == 0) return [];
    if(text.length < pattern.length) return [];

    size_t[] indeces;

    size_t d = 1 << (pattern.length - 1);
    auto pHash = hash(pattern);
    auto tHash = hash(text[0 .. pattern.length]);

    size_t i = 0;

    for(;;) {
        if(pHash == tHash && pattern == text[i .. pattern.length + i]) {
            indeces ~= i;
        }

        if(i < text.length - pattern.length) {
            tHash = rehash(text[i], text[i + pattern.length], tHash, d);
        } else {
            break;
        }
        ++i;
    }

    return indeces;
}