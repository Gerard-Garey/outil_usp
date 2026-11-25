import sys
from fractions import Fraction as Fr
for line in open(sys.argv[1]):
    p=line.strip().split("|")
    if len(p)<6: continue
    C0=[Fr(float.fromhex(x)) for x in p[3].split(",")]
    C1=[Fr(float.fromhex(x)) for x in p[4].split(",")]
    ec=[float.fromhex(x) for x in p[5].split(",")]
    f=sum(C1)/sum(C0); ex=[c1/c0-f for c0,c1 in zip(C0,C1)]
    m=max(abs(b) for b in ex)
    print(p[0],p[1],"ex/f:",["%.2e"%float(b/f) for b in ex],"rel:",["%.1e"%float(abs((Fr(a)-b)/b)) for a,b in zip(ec,ex)],"err/max|ex| %.1e"%float(max(abs(Fr(a)-b) for a,b in zip(ec,ex))/m))
