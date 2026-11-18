# Classeurs openpyxl 3.1.5 : note faite de seuls blancs ou vide, dont une
# ligne finale qui ne porte qu'une note blanche. Usage : generer_blancs.py <csv> <dossier>
import csv, sys
import openpyxl
src, out = sys.argv[1], sys.argv[2]
rows = list(csv.reader(open(src)))
data = [[float(x) for x in r] for r in rows[1:]]
try:
    import lxml; lx = "lxml " + lxml.__version__
except ImportError:
    lx = "sans lxml"
cas = {"note_un_blanc": [" "] + ["ok"] * 7, "note_trois_blancs": ["   "] + ["ok"] * 7,
       "note_tab": ["\t"] + ["ok"] * 7, "note_chaine_vide": [""] + ["ok"] * 7}
for nom, notes in cas.items():
    wb = openpyxl.Workbook(); ws = wb.active; ws.append(["t", "xt", "yt", "note"])
    for r, n in zip(data, notes): ws.append(r + [n])
    wb.save(f"{out}/{nom}.xlsx")
wb = openpyxl.Workbook(); ws = wb.active; ws.append(["t", "xt", "yt", "note"])
for r in data: ws.append(r + ["ok"])
ws.append([None, None, None, " "]); wb.save(f"{out}/ligne_finale_note_blanche.xlsx")
print("openpyxl", openpyxl.__version__, ";", lx)
