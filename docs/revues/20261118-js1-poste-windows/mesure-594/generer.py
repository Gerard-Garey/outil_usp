import csv, sys, os
import openpyxl, xlsxwriter, pandas as pd
src, out = sys.argv[1], sys.argv[2]
rows = list(csv.reader(open(src)))
hdr = rows[0]; data = [[float(x) if '.' in x else int(x) for x in r] for r in rows[1:]]
notes = [" debut blanc", "fin blanche ", " deux ", "sans", "", "x ", " y", "z"]
def table(avec_blancs):
    h = hdr + ["note"]
    d = [r + [(notes[k] if avec_blancs else notes[k].strip()) or None] for k, r in enumerate(data)]
    return h, d
for blancs in (True, False):
    suf = "blancs" if blancs else "temoin"
    h, d = table(blancs)
    wb = openpyxl.Workbook(); ws = wb.active; ws.title = "Donnees"; ws.append(h)
    for r in d: ws.append(r)
    wb.save(f"{out}/openpyxl_{suf}.xlsx")
    pd.DataFrame(d, columns=h).to_excel(f"{out}/pandas_{suf}.xlsx", index=False, engine="openpyxl", sheet_name="Donnees")
    for mode in ("defaut", "constant_memory"):
        wb = xlsxwriter.Workbook(f"{out}/xlsxwriter_{mode}_{suf}.xlsx", {"constant_memory": mode == "constant_memory"})
        ws = wb.add_worksheet("Donnees"); ws.write_row(0, 0, h)
        for k, r in enumerate(d):
            for j, v in enumerate(r):
                if v is not None: ws.write(k + 1, j, v)
        wb.close()
print("versions", openpyxl.__version__, pd.__version__, xlsxwriter.__version__)
