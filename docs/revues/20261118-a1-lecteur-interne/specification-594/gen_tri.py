import csv, sys, openpyxl, xlsxwriter
src, out = sys.argv[1], sys.argv[2]
rows = list(csv.reader(open(src)))
h = rows[0]
def conv(x):
    if x in ("", "NA"): return None
    return float(x) if '.' in x else int(x)
d = [[conv(x) for x in r] for r in rows[1:]]
d[0][2] = " " + str(d[0][2]) + " "
wb = openpyxl.Workbook(); ws = wb.active; ws.append(h)
for r in d: ws.append(r)
wb.save(f"{out}/T_cellule_bordee__openpyxl.xlsx")
wb = xlsxwriter.Workbook(f"{out}/T_cellule_bordee__xlsxwriter_defaut.xlsx"); ws = wb.add_worksheet()
for j, v in enumerate(h): ws.write_string(0, j, v)
for k, r in enumerate(d):
    for j, v in enumerate(r):
        if v is None: continue
        (ws.write_string if isinstance(v, str) else ws.write_number)(k + 1, j, v)
wb.close()
print(repr(d[0][2]))
