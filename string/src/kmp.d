module kmp;

size_t[] knuthMorrisPratt(string pattern, string text) {
    long[] shifts;
    shifts.length = pattern.length + 1;
    shifts[] = 1;

    long shift = 1;
    foreach(i, c; pattern) {
        while(shift <= i && pattern[i - shift] != c) {
            shift += shifts[i - shift];
        }
        shifts[i+1] = shift;
    }

    size_t[] indeces;
    size_t startPos;
    long matchLen;

    foreach(c; text) {
        while(matchLen == pattern.length || matchLen >= 0 && pattern[matchLen] != c) {
            startPos += shifts[matchLen];
            matchLen -= shifts[matchLen];
        }
        ++matchLen;
        if(matchLen == pattern.length) {
            indeces ~= startPos;
        }
    }

    return indeces;
}