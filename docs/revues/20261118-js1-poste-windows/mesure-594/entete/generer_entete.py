# Sonde : en-tete lu "xt " (blanc final) ecrit par openpyxl 3.1.5.
# Usage : generer_entete.py <csv> <dossier>
import csv, sys
import openpyxl
src, out = sys.argv[1], sys.argv[2]
wb = openpyxl.Workbook(); ws = wb.active; ws.append(["t", "xt ", "yt"])
for l in list(csv.reader(open(src)))[1:]:
    ws.append([float(x) for x in l])
wb.save(f"{out}/openpyxl_entete_lu_blanc.xlsx")
