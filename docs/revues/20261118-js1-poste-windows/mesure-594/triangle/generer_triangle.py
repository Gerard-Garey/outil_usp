# Mesure du § 3.3 de la specification de #594 : triangle openpyxl avec une
# colonne note, sans blancs (temoin) et bordee de blancs (_blancs).
# Usage : python3 generer_triangle.py tests/donnees/triangle_mw.csv <sortie>
import csv, os, sys
from openpyxl import Workbook
src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
with open(src, newline="") as f:
    rows = list(csv.reader(f))
entete, corps = rows[0], rows[1:]
for suffixe, note in (("temoin", lambda k: f"note{k}"), ("blancs", lambda k: f" note{k} ")):
    wb = Workbook(); ws = wb.active
    ws.append(entete + ["note"])
    for k, r in enumerate(corps, 1):
        ws.append([float(x) if x != "" else None for x in r] + [note(k)])
    wb.save(os.path.join(out, f"openpyxl_triangle_note_{suffixe}.xlsx"))
