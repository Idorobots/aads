#! /bin/sh

for CHUNK in `seq -w 1 100`; do
    more seneca.txt | ../huffman -s$CHUNK -c -o "seneca.huf$CHUNK"
done;

# du -b seneca.huf* | sed s/seneca.huf// | awk '{ print $2 "\t" $1}' >> test.out
