# Q-66-3 : mesure des écarts entre les deux chemins de lecture des classeurs (premier temps de Q-67-7 (a))

*Mesure faite par la session principale (IA) le 18/11/2026, hors branche, sur `main` `c013568` (fusion de JS1, étiquette `v3.0.0`). Le code du moteur est celui du SHA de la batterie `c75a112`.*

## Objet

Q-66-3 examine la lecture des classeurs par le **lecteur interne seul**, c'est-à-dire la suppression du chemin `openxlsx::read.xlsx()` d'`engine_lire_xlsx()`. Q-67-7 (a) fixe quatre temps : (1) la session mesure les écarts entre les deux chemins sur le corpus de l'étape 2 de JS1, sous `openxlsx` 4.2.5.2 ; (2) `actuary` donne son avis ; (3) `architect-approfondi` est consulté avec Fable d'office et propose l'ADR ; (4) le mainteneur décide. Ce dossier porte le temps (1).

## Conditions

- Linux, R 4.3.3, `LC_ALL=C.UTF-8`.
- Chemin openxlsx : `openxlsx` 4.2.5.2 (archive CRAN, version du job de parité de la CI), avec `zip` 3.0.2, dans une bibliothèque de session (`R_LIBS`).
- Chemin interne : même commande, sans `R_LIBS` (aucun `openxlsx` dans les bibliothèques du système).
- Moteur chargé par `charger_moteur()` (ADR 0016).

## Corpus (42 classeurs)

- Les **36 classeurs versés** de `docs/revues/20261118-js1-poste-windows/mesure-594/` :
  - `classeurs/` (8) ;
  - `blancs/classeurs/` (5) et `blancs/classeurs_sans_lxml/` (7) ;
  - `entete/` (1) ;
  - `poste-windows/classeurs/` (15, corpus de l'étape 2 (ii) de JS1).

  Ils couvrent openpyxl avec et sans lxml, pandas (moteurs openpyxl et xlsxwriter) et XlsxWriter (par défaut et `constant_memory`), pour des séries témoins, des séries à colonne `note` bordée de blancs ou faite de seuls blancs, et des triangles témoins.
- **6 classeurs supplémentaires** (`generer_suppl.R`), non versés :
  - écrits par l'écrivain interne (`engine_ecrire_xlsx()`) et par `openxlsx::write.xlsx()` ;
  - séries de `tests/donnees/donnees_ln.csv`, triangle de `tests/donnees/triangle_mw.csv` ;
  - une série de 5 000 lignes (graine 1), pour la durée.

  Leurs md5 sont dans `md5_suppl.txt`. Ceux d'`openxlsx::write.xlsx()` ne sont pas reproductibles, parce que le classeur porte sa date de création ; ceux de l'écrivain interne le sont.
- Excel et LibreOffice ne sont pas couverts (décision du mainteneur du 18/11/2026 : pas de corpus Excel ni LibreOffice).

## Reproduction

Depuis la racine du dépôt :
1. `Rscript docs/revues/20261118-q66-3-lecteur-interne/generer_suppl.R <suppl>`, avec `openxlsx` installé ;
2. `R_LIBS=<bibliothèque avec openxlsx 4.2.5.2> Rscript docs/revues/20261118-q66-3-lecteur-interne/lire_corpus.R openxlsx.rds <classeurs>` ;
3. `Rscript docs/revues/20261118-q66-3-lecteur-interne/lire_corpus.R interne.rds <classeurs>`, sans `openxlsx` ;
4. `Rscript docs/revues/20261118-q66-3-lecteur-interne/comparer.R openxlsx.rds interne.rds`.

Pour chaque classeur, `lire_corpus.R` enregistre :
- le retour d'`engine_lire_xlsx()` (data.frame, ou classe et message du refus) ;
- le retour d'`engine_lire_donnees_csv()` (séries) ou d'`engine_lire_triangle()` (triangle) appliqué au data.frame lu ;
- la médiane de sept durées de lecture.

`comparer.R` compare les deux chemins par `identical()`. Sorties : `sortie_openxlsx.txt`, `sortie_interne.txt` et `comparaison.txt`.

## Résultats

| Mesure | Résultat |
|---|---|
| Retour d'`engine_lire_xlsx()` identique sur les deux chemins | **42 sur 42** : 29 lus, 13 refusés (`usp_refus_lecture`, même message) |
| Retour du lecteur aval identique | **42 sur 42** |
| Durée | égale à la précision de la mesure : 14 à 31 ms pour 8 lignes ; 2,97 s contre 2,97 s (écrivain interne) et 3,24 s contre 3,27 s (`openxlsx::write.xlsx()`) pour 5 000 lignes |

Sur ce corpus, la suppression du chemin `openxlsx` ne change donc aucun retour du moteur. Elle ne change pas non plus la durée de lecture de façon mesurable : l'admission par `.xlsx_admettre()`, commune aux deux chemins, prend l'essentiel du temps (en-tête d'`engine_lire_xlsx()`, mesure de #558).

## Emprise d'`openxlsx` dans le dépôt (relevé par `grep -c`, à `c013568`)

| Fichier | Occurrences | Nature |
|---|---|---|
| `R/engine.R` | 204 | **un seul embranchement de code** (`requireNamespace("openxlsx")`, l. 11654) ; le reste est fait de commentaires de parité et de mesures |
| `tests/unitaires/test_controles_entree.R` | 226 | tests de parité des deux chemins |
| `tests/unitaires/test_outdec.R` | 14 | idem |
| `tests/unitaires/test_application.R` | 1 | |
| `docs/latex/doc_tests_usp.tex` | 74 | |
| `.github/workflows/ci.yml` | 14 | job « Parité des lecteurs de classeur » |
| `README.md`, `DESCRIPTION`, `CLAUDE.md` | 4, 1, 1 | `CLAUDE.md` : invariant « Architecture », exception `openxlsx` |
| `app.R`, `R/display_helpers.R` | 0 | |

## Constats

1. **Parité mesurée** : sur les 42 classeurs, les deux chemins rendent des objets identiques au bit près, refus compris. C'est attendu : depuis S1, `.xlsx_admettre()` refuse avant `openxlsx` tout classeur hors du contrat fermé, et chaque écart mesuré entre les deux interprètes a été traité par une issue (#572, #579, lots G et H de #574, #594, #595).
2. **Sur le corpus mesuré, `openxlsx` n'apporte aucune lecture** que le lecteur interne ne fasse pas à l'identique. La réciproque n'est pas observable sur ce corpus, où le seul cas connu, #594, est refusé par l'admission sur les deux chemins : `openxlsx` y lit faussement un texte en ligne sous `xml:space="preserve"` (colonne `note`, mesure de JS1, sous 4.2.5.2 comme sous 4.2.9). Elle est en revanche **consignée hors de ce corpus**, sur des formes forgées que l'admission laisse passer. Le lecteur interne les lit juste, et `openxlsx` s'y arrête sur une erreur R :
   - balises `<sheet>` et `<Relationship>` préfixées ;
   - attributs entre apostrophes ;
   - cible `./worksheets/…` ;
   - seconde entrée de même nom dans un autre dossier.

   Ces formes sont décrites au `.tex`, l. 5470-5495, et dans l'en-tête d'`engine_lire_xlsx()`. Elles n'ont pas été remesurées ici. *Correction apportée à la suite de l'avis d'`actuary` (`actuary-avis.md`, § 5) : la première rédaction étendait à tort ce constat au-delà du corpus mesuré.*
3. **Effet sur #594 (option (b) bornée)** : cette mesure ne tranche pas Q-66-3 ; elle en donne le terrain. Si `openxlsx` est gardé, l'option (b) bornée admet une colonne non lue que `openxlsx` lit faussement : le `data.frame` rendu porte alors une colonne fausse, sans effet sur `t`, `xt` et `yt` (spécification d'`actuary-approfondi`, limite du `data.frame` rendu). Si `openxlsx` est retiré, cette limite disparaît, et la prémisse de D-S1-31 (deux lectures du même classeur) tombe.
4. **Durée** : aucun gain mesurable. L'argument de la double décompression (#558) est qualitatif, non quantitatif (0,1 % à 4,5 % de la lecture, mesure de #558).
5. **Coût d'une suppression** : l'embranchement de code est unique, mais il entraîne une reprise des tests de parité (240 occurrences), du job de parité de la CI, de 74 occurrences du `.tex` et de l'invariant « Architecture » de `CLAUDE.md`. C'est un ADR d'architecture (Fable d'office, `docs/agents/routage.md` § 4.1.3).

## Limites

- Plateforme : Linux et `C.UTF-8` seulement. Le corpus du poste Windows a été lu sous Windows avec `openxlsx` 4.2.9, avec une concordance des deux chemins sur ses quinze classeurs (`../20261118-js1-poste-windows/etape-2-ii-corpus.md`).
- Écrivains : openpyxl, pandas, XlsxWriter, `openxlsx` et l'écrivain interne. Excel et LibreOffice ne sont pas couverts (décision du mainteneur).
- La concordance est un **comportement observé** sur un corpus fini, non une preuve d'équivalence des deux interprètes. Elle complète le job de parité de la CI, sans le remplacer.
- La piste `loadWorkbook(dossier, isUnzipped = TRUE)` (une seule décompression en gardant `openxlsx`) n'est pas mesurée. Elle passe par `read.xlsx.Workbook()`, un autre interprète que celui du job de parité (en-tête d'`engine_lire_xlsx()`). Elle est versée à l'examen comme option.
