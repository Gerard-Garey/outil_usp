# JS1 : relevés du poste Windows (18/11/2026)

> Versement de l'étape 5 de la fiche « Jalon JS1 et créneau d'absorption A1 » (`docs/feuille-de-route.md`, Q-67-5 (a)). Les étapes 2 et 4 ont été exécutées par la session principale (IA), en session locale de Claude Code sur le poste du mainteneur, à la demande de celui-ci.
>
> Toutes ont tourné au **SHA de la batterie `c75a112`**, en tête détachée, sur un arbre propre (hors `?? prompt-poste-local.md`, fichier du mainteneur hors dépôt). Après le `/code-review` de l'étape 6, les sondes et la mesure du corpus ont été reprises à la tête `8022501`, dont le code est identique. Les sorties de l'étape 4 et de l'étape 2 (i) sont celles de `c75a112`.

## Plateforme

| Élément | Valeur |
|---|---|
| Système | Windows 11 x64, build 26300 |
| R | `R version 4.3.3 (2024-02-29 ucrt)` |
| Locale | `French_France.utf8` (`LC_NUMERIC=C`) |
| Paquets R | `openxlsx` 4.2.9, `zip` 2.3.0 |
| md5 | `R/engine.R` `26220144141d922f4ea85d259004f093`, `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11` |
| Python (corpus) | 3.14.7 ; openpyxl 3.1.5, pandas 3.0.6, XlsxWriter 3.3.1, lxml 6.1.3 |
| Tableurs | ni Excel ni LibreOffice installés |

## Synthèse

| Étape | Relevé | Critère | Verdict |
|---|---|---|---|
| 2 (i) | `etape-2-i-controles-entree.md` | aucun échec | **non tenu** : 2 échecs sur 608 (avec `openxlsx`) et sur 592 (sans), propres à Windows, sur l'écrivain xlsx de #580 |
| 2 (ii) | `etape-2-ii-corpus.md` ; corpus dans `mesure-594/poste-windows/` | aucune valeur fausse, aucun classeur refusé à tort hors #594 | **tenu** pour openpyxl, pandas et XlsxWriter ; Excel et LibreOffice **non couverts** |
| 2 (iii) | `etape-2-iii-chemin-de-lecteur.md` | refus motivé, ou fichier dans le dossier courant de `C:` | **non tenu** : succès annoncé, fichier écrit dans le dossier temporaire de l'appel puis effacé |
| 4 | `etape-4-batterie.md` | ADR 0006, annotation du 14/11 | **accepté** : relevé identique à celui de KR |

Points saillants :
- **σ_USP, p-values et verdicts** : aucun changé. Les six σ_USP sont ceux de KR.
- **#594** : le comportement mesuré sous `openxlsx` 4.2.5.2 se reproduit sous 4.2.9. L'hypothèse qui fonde l'option (b) bornée tient sous la version du poste.
- **Q-67-8 (a)** : la batterie est acceptée et aucun classeur ordinaire n'est refusé à tort. Aucune issue urgente ne naît de JS1. Les deux constats gardés ci-dessous sont **courants** et ne retiennent ni la sortie du brouillon ni l'étiquette.
- Les échecs de 2 (i) et le résultat de 2 (iii) ne sont pas des conditions de l'étiquette dans la fiche. Le mainteneur en décide.

## Tri ADR 0018

### Constats gardés : issues courantes, rattachées à A1 (même module, § 5.2)

Les deux issues sont rédigées ici et seront créées sur accord du mainteneur.

**Proposition d'issue 1 — « moteur: écrivain xlsx sous Windows, saut de ligne d'une cellule écrit `\r\n`, relu `\r\n` par le lecteur interne et `\n` par openxlsx »**
- **Constat** (étape 2 (i), échec 2) :
  - `engine_ecrire_xlsx()` écrit `xl/worksheets/sheet1.xml` par `writeLines(..., useBytes = TRUE)` sur une connexion en mode texte. Sous Windows, chaque `\n` du texte d'une cellule ou d'un en-tête devient `\r\n` dans le XML ;
  - le lecteur interne relit `"a\r\nb"` ; `openxlsx` 4.2.9 relit `"a\nb"`, car il normalise les fins de ligne selon XML 1.0, § 2.11 ;
  - l'assertion de `test_controles_entree.R` l. 7064 échoue sous Windows et passe sous Linux.
- **Critères ADR 0018** :
  - affirmation fausse sur le code : le commentaire de `.xlsx_defaut_texte()` refuse le retour chariot parce qu'il « ne survit pas a la relecture », et l'écrivain l'introduit lui-même ;
  - deux lectures différentes d'un même classeur, écrit par l'outil (D-S1-31).
- **Portée** : textes seuls ; aucun nombre, aucun verdict ni aucun σ_USP.
- **Pistes**, à décider en A1 :
  - écriture en binaire (`writeBin()` des octets UTF-8, ou connexion `"wb"`) ;
  - normalisation `\r\n` → `\n`, puis `\r` → `\n`, dans le lecteur interne (§ 2.11), pour les classeurs tiers. Elle porte sur les fins de ligne **littérales** du XML, **avant** le décodage des références de caractère : un `&#13;` décodé reste un retour chariot, comme chez un analyseur conforme. L'appliquer au texte décodé recréerait deux lectures, dans l'autre sens.
- **Mesure** : `etape-2-i/sonde_tab.R`.

**Proposition d'issue 2 — « moteur: `engine_ecrire_xlsx(df, "C:f.xlsx")` sous Windows, lecteur de `tempdir()`, succès annoncé, fichier écrit dans le dossier temporaire puis effacé »**
- **Constat** (étape 2 (iii)) :
  - un chemin de lecteur sans barre (`X:f.xlsx`) est tenu pour absolu par `.xlsx_chemin_absolu()`, et `dirname()` vaut `"."` ;
  - `.xlsx_chemin_sortie()` le rend tel quel ; après `setwd(d)`, l'archive est écrite dans `d`, le contrôle `file.exists()` réussit, puis `unlink(d)` l'efface ;
  - la fonction rend `"C:f.xlsx"`.
- **Condition** : `X:` est le lecteur de `tempdir()` (ici `C:`), car `setwd(d)` ne change que le dossier courant de ce lecteur. Pour un autre lecteur, la cible reste relative à son propre dossier courant et l'écriture devrait aboutir ; ce cas n'est **pas mesuré**, le poste n'ayant que `C:`. Le défaut touche donc le cas courant, puisque `tempdir()` est d'ordinaire sous `C:`.
- **Critère ADR 0018** (fiche JS1, étape 5) : fichier écrit ailleurs sous un succès annoncé. C'est une affirmation fausse de la documentation sur le code : index du `.tex` et en-tête d'`engine_ecrire_xlsx()`.
- **Portée** : usage sans Shiny seulement ; l'application passe un chemin absolu. Aucune donnée écrasée.
- **Pistes**, à décider en A1, après mesure sur un poste à deux lecteurs :
  - refus motivé de la forme `X:` sans barre ;
  - ou résolution par `normalizePath()` du chemin avant `setwd()`.
- **Mesure** : `etape-2-iii/scenario_c.R`.

### Constats mineurs écartés (ADR 0018)

- `test_controles_entree.R` l. 6960 : sous Windows, `.xlsx_chemin_sortie("//serveur/partage/f.xlsx", wd)` rend `"\\\\serveur/partage/f.xlsx"`, parce que `dirname()` réécrit la tête UNC en barres inverses. Le chemin désigne le même partage, absolu et non préfixé. L'écart est de forme, dans l'attente du test mesurée sous Linux, et ne remplit aucun critère. Le test pourra être aligné lors du codage de la proposition 2, qui touche la même fonction.
- Deux lignes « [saute] » de plateforme dans `test_controles_entree.R` (locale `C.UTF-8` indisponible, `HOME` non redirigeable) : propres à Windows, connues et sans critère.

## Reste ouvert

- Corpus Excel et LibreOffice (étape 2 (ii)), à produire sur un poste qui porte ces tableurs avant le codage d'A1 (§ 3 de la spécification de #594).
