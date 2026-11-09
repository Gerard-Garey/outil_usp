#!/bin/bash
cd /home/user/outil_usp
export LC_ALL=C.UTF-8
out=/tmp/duree-ci/seq
mkdir -p $out
: > /tmp/duree-ci/durees_seq.tsv
for f in tests/unitaires/test_*.R; do
  b=$(basename $f .R)
  l0=$(cut -d' ' -f1 /proc/loadavg)
  s=$(date +%s.%N)
  Rscript $f > $out/$b.log 2>&1
  st=$?
  e=$(date +%s.%N)
  echo -e "$b\t$(echo "$e - $s" | bc)\t$st\t$l0" >> /tmp/duree-ci/durees_seq.tsv
done
s=$(date +%s.%N)
Rscript tests/test_reproductibilite.R > $out/repro.log 2>&1
e=$(date +%s.%N)
echo -e "test_reproductibilite\t$(echo "$e - $s" | bc)\t$?" >> /tmp/duree-ci/durees_seq.tsv
echo FIN >> /tmp/duree-ci/durees_seq.tsv
