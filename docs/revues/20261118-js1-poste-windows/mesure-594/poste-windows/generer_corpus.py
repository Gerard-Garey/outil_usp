# Corpus d'acceptation de JS1, etape 2 (ii), poste Windows (18/11/2026).
# Usage : python generer_corpus.py <donnees_ln.csv> <triangle_mw.csv> <sortie>
# Series : t, xt, yt (+ note : _temoin sans blancs, _blancs bordee de blancs) ;
# triangle : i, j0..j7, temoin. Outils : openpyxl, pandas (moteurs openpyxl et
# xlsxwriter), XlsxWriter (mode par defaut et constant_memory).
import csv, sys, os
import openpyxl, xlsxwriter, pandas as pd, lxml.etree
src, tri, out = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(out, exist_ok=True)

def nombre(x):
    if x == "":
        return None
    return float(x) if any(c in x for c in ".eE") else int(x)

rows = list(csv.reader(open(src, encoding="utf-8")))
hdr = rows[0]; data = [[nombre(x) for x in r] for r in rows[1:]]
trows = list(csv.reader(open(tri, encoding="utf-8")))
thdr = trows[0]; tdata = [[nombre(x) for x in r] for r in trows[1:]]
notes = [" debut blanc", "fin blanche ", " deux ", "sans", "", "x ", " y", "z"]

def series(avec_blancs):
    h = hdr + ["note"]
    d = [r + [(notes[k] if avec_blancs else notes[k].strip()) or None] for k, r in enumerate(data)]
    return h, d

def ecrire(nom, h, d):
    wb = openpyxl.Workbook(); ws = wb.active; ws.title = "Donnees"; ws.append(h)
    for r in d: ws.append(r)
    wb.save(f"{out}/openpyxl_{nom}.xlsx")
    for moteur in ("openpyxl", "xlsxwriter"):
        pd.DataFrame(d, columns=h).to_excel(f"{out}/pandas-{moteur}_{nom}.xlsx", index=False,
                                            engine=moteur, sheet_name="Donnees")
    for mode in ("defaut", "constant_memory"):
        wb = xlsxwriter.Workbook(f"{out}/xlsxwriter-{mode}_{nom}.xlsx", {"constant_memory": mode == "constant_memory"})
        ws = wb.add_worksheet("Donnees"); ws.write_row(0, 0, h)
        for k, r in enumerate(d):
            for j, v in enumerate(r):
                if v is not None: ws.write(k + 1, j, v)
        wb.close()

h, d = series(False); ecrire("series_temoin", h, d)
h, d = series(True); ecrire("series_blancs", h, d)
ecrire("triangle_temoin", thdr, tdata)
print("versions : openpyxl", openpyxl.__version__, "; pandas", pd.__version__, "; XlsxWriter", xlsxwriter.__version__,
      "; lxml", ".".join(map(str, lxml.etree.LXML_VERSION)), "; Python", sys.version.split()[0])
