# Classeurs synthetiques pour la specification amendee de #594.
# Pour chaque scenario : trois ecrivains (xlsxwriter defaut = chaines
# partagees ; openpyxl et xlsxwriter constant_memory = chaines en ligne).
import csv, sys, zipfile, re, os
import openpyxl, xlsxwriter
src, out = sys.argv[1], sys.argv[2]
rows = list(csv.reader(open(src)))
hdr = rows[0]; data = [[float(x) if '.' in x else int(x) for x in r] for r in rows[1:]]
def base():
    return list(hdr) + ["note"], [r + ["n"] for r in data]
sc = {}
h, d = base(); h[1] = "xt "; sc["S2_entete_xt_blanc_fin"] = (h, d)
h, d = base(); h[0] = " t "; sc["S2b_entete_t_borde"] = (h, d)
h, d = base(); h[2] = "yt\t"; sc["S2c_entete_yt_tab"] = (h, d)
h, d = base(); d[0][1] = " 104.2 "; sc["S3_xt_104_2_borde"] = (h, d)
h, d = base(); d[0][1] = "104.2\n"; sc["S3b_xt_104_2_saut_ligne"] = (h, d)
h, d = base(); d[0][1] = "104.2"; sc["S4_xt_104_2_texte_sans_blanc"] = (h, d)
h, d = base(); d[0][1] = " 104.2"; sc["S9_xt_104_2_insecable"] = (h, d)
h, d = base(); d[0][1] = " "; sc["S6_xt_un_blanc"] = (h, d)
h, d = base(); d[0][0] = " 1 "; sc["S3c_t_1_borde"] = (h, d)
h, d = base(); d[3][3] = " "; sc["S5_note_un_blanc"] = (h, d)
h, d = base(); d[3][3] = " fin "; sc["S1_note_bordee"] = (h, d)
h, d = base(); d.append([None, None, None, " "]); sc["S8_ligne_finale_note_blanche"] = (h, d)
h, d = base(); d.append([None, None, None, " x "]); sc["S8b_ligne_finale_note_non_blanche"] = (h, d)
h, d = base(); h[3] = " "; sc["S7_entete_note_blanc"] = (h, d)
for nom, (h, d) in sc.items():
    wb = openpyxl.Workbook(); ws = wb.active; ws.title = "Donnees"; ws.append(h)
    for r in d: ws.append(r)
    wb.save(f"{out}/{nom}__openpyxl.xlsx")
    for mode in ("defaut", "cm"):
        wb = xlsxwriter.Workbook(f"{out}/{nom}__xlsxwriter_{mode}.xlsx", {"constant_memory": mode == "cm"})
        ws = wb.add_worksheet("Donnees")
        for j, v in enumerate(h): ws.write_string(0, j, v)
        for k, r in enumerate(d):
            for j, v in enumerate(r):
                if v is None: continue
                if isinstance(v, str): ws.write_string(k + 1, j, v)
                else: ws.write_number(k + 1, j, v)
        wb.close()
# Formes forgees a partir du classeur openpyxl S1 (note " fin " en D5)
f0 = f"{out}/S1_note_bordee__openpyxl.xlsx"
def forger(nom, avant, apres, compte=1):
    zin = zipfile.ZipFile(f0)
    zout = zipfile.ZipFile(f"{out}/F_{nom}.xlsx", "w", zipfile.ZIP_DEFLATED)
    for it in zin.infolist():
        b = zin.read(it.filename)
        if it.filename == "xl/worksheets/sheet1.xml":
            s = b.decode("utf-8")
            assert s.count(avant) >= 1, (nom, avant)
            s = s.replace(avant, apres, compte); b = s.encode("utf-8")
        zout.writestr(it, b)
    zout.close()
P = '<t xml:space="preserve"> fin </t>'
forger("sans_attribut", P, '<t> fin </t>')
forger("t_blanc", P, '<t > fin </t>')
forger("t_tab", P, '<t\t> fin </t>')
forger("apostrophes", P, "<t xml:space='preserve'> fin </t>")
forger("default", P, '<t xml:space="default"> fin </t>')
forger("prefixe_x", P, '<t x:space="preserve"> fin </t>')
forger("attribut_en_plus", P, '<t xml:space="preserve" a="1"> fin </t>')
forger("blanc_avant_chevron", P, '<t xml:space="preserve" > fin </t>')
forger("deux_espaces", P, '<t  xml:space="preserve"> fin </t>')
forger("valeur_majuscule", P, '<t xml:space="PRESERVE"> fin </t>')
forger("vide_auto", P, '<t xml:space="preserve"/>')
forger("vide_auto_blanc", P, '<t xml:space="preserve" />')
forger("vide_paire", P, '<t xml:space="preserve"></t>')
forger("vide_t", P, '<t/>')
forger("ref_32", P, '<t xml:space="preserve">&#32;fin </t>')
forger("ref_9", P, '<t xml:space="preserve">fin&#9;</t>')
forger("ref_233", P, '<t xml:space="preserve"> f&#233;n </t>')
forger("entite_amp", P, '<t xml:space="preserve"> a&amp;b </t>')
forger("crlf_litteral", P, '<t xml:space="preserve"> a\r\nb </t>')
print("ok", openpyxl.__version__, xlsxwriter.__version__)
