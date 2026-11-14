import re,sys,unicodedata,glob
S=sys.argv[1]
def lits(p):
    t=open(p,encoding='utf-8').read()
    out=set()
    for m in re.finditer(r'"((?:[^"\\\n]|\\.){25,})"',t):
        out.add(m.group(1))
    return out
o,n=lits(S+'/old.R'),lits(S+'/new.R')
gone=sorted(o-n)
def norm(x):
    x=re.sub(r'\\(textsuperscript|code|emph|textbf|og|fg)\b','',x)
    x=x.replace('~',' ').replace('{','').replace('}','').replace('\\_','_').replace('\\','')
    x=unicodedata.normalize('NFKD',x); x=''.join(c for c in x if not unicodedata.combining(c))
    x=x.replace('«','').replace('»','').replace('\u2019',"'")
    return re.sub(r'\s+',' ',x).lower()
tex=norm(open('docs/latex/doc_tests_usp.tex',encoding='utf-8').read())
suivi={f:norm(open(f,encoding='utf-8').read()) for f in glob.glob('docs/suivi-documentation/*.md')}
hits=[]
for s in gone:
    if '%s' in s or '%d' in s: frags=[f for f in re.split(r'%[0-9.]*[sdfg]',s) if len(f)>=25]
    else: frags=[s]
    for f in frags:
        k=norm(f).strip()
        if len(k)<25: continue
        w=[x for x in ([('tex',tex)]+list(suivi.items())) if k in x[1]]
        if w: hits.append((s,[x[0] for x in w]))
print(len(o),len(n),len(gone),'chaines disparues ou modifiees')
for s,w in hits: print('HIT',w,'::',s[:160])
print('=== filtre : cite par le .tex et absent du moteur gele ===')
t=open(S+'/new.R',encoding='utf-8').read()
L=[m.group(1) for m in re.finditer(r'"((?:[^"\\\n]|\\.)*)"',t)]
J1=norm(''.join(L)); J2=norm(' '.join(L))
res=[]
for s,w in hits:
    if 'tex' not in w: continue
    frags=[f for f in re.split(r'%[0-9.]*[sdfg%]',s) if len(norm(f).strip())>=25] or [s]
    absent=[f for f in frags if norm(f).strip() not in J1 and norm(f).strip() not in J2]
    if absent: res.append((s,absent))
for s,a in res: print('REEL ::',s[:200]); print('    absent :',[x[:80] for x in a])
print(len(res),'cas reels')
