# S1, étape 1 : rejeu des constats de #574, #575, #579, #570 et #588 (15/11/2026)

> *Rédigé par l'agent audit (IA), en lecture seule ; versé par la session principale (Q-54-10), avec les sondes (`sondes/`) et les sorties brutes (`sorties/`).*

**Conclusion d'`audit` : conforme.** Chaque constat se reproduit sur les deux chemins, sauf #588, qui ne s'observe pas sous Linux. Aucun n'a été corrigé entre-temps.

## État et environnement

- **Dépôt** : `main` `abc6ff1` (`abc6ff15931a4f92ae75b77450a555e206f36b2f`). La tête de la branche S1 (`claude/lecteurs-contrat-ferme`) était `76a8c29` au moment du rejeu ; `git diff --stat abc6ff1 76a8c29 -- R/ tests/` est vide.
- **md5** : `R/engine.R` `818f276d8941e5780468382c640f8cfa` ; `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11`.
- **Système** : R 4.3.3 (2024-02-29), Linux 6.18 x86_64, `LC_ALL=C.UTF-8` (`l10n_info()` : UTF-8 = TRUE).
- **Chemin interne** : ni `openxlsx` ni `zip` installés.
- **Chemin `openxlsx`** : bibliothèque temporaire hors dépôt (`R_LIBS`), construite depuis les sources CRAN.

| Paquet | Version | Source | md5 de l'archive |
|---|---|---|---|
| openxlsx | 4.2.5.2 | Archive CRAN | `5d487ff8bb65ab9b284c6e2162ef793b` |
| zip | 2.3.1 | Archive CRAN | `8a8a132cd0456e498d479d21c91facce` |
| Rcpp | 1.1.2 | CRAN courant | `353d35176db9c570705a0a324c06fdca` |
| stringi | 1.8.9 (ICU 74 embarquée) | CRAN courant | `6888a5ac007ad34590ce6afbd0cb2491` |

- **Exécution** : le moteur est chargé par `source("R/charger_moteur.R"); charger_moteur()`. Chaque cas tourne dans un sous-processus `Rscript`, sans `openxlsx` puis avec.

## Sondes (`sondes/`)

Les classeurs sont forgés à la main : paquet minimal, en-têtes `t`, `xt`, `yt` en chaînes en ligne, série de `tests/donnees/donnees_ln.csv`.

| Fichier | Rôle |
|---|---|
| `forge.R` | forge du classeur |
| `sonde.R <depot> <dossier> <cas>` | cas `574-1`, `574-2`, `574-3a`, `574-3b`, `574-4`, `574-5`, `574-m1`, `575`, `579-b`, `579-txt`, `579-tri`, `579-df`, `570`, `588` |
| `rejouer.sh <depot> <bibliotheque> <cas...>` | lance chaque cas sur les deux chemins et relève le code de sortie |
| `sonde_575.R` | #575 seul : appel direct ou par le moteur, indice 5 ou 1000000, avec ou sans relation déclarée pour la table |
| `sonde_574_5_trace.R` | pile des avertissements et des erreurs de la forme 5 |

## Constats

| Issue, forme | Interne | openxlsx 4.2.5.2 | Statut |
|---|---|---|---|
| #574 (1) : `<x:si><x:t>9</x:t></x:si><si><t>11.5</t></si>`, cellule d'indice 0 | 11.5, `ok = TRUE` | 11.5, `ok = TRUE` | reproduit (valeur fausse) |
| #574 (2) : `<r><rPr><b/></rPr><t>1</t></r><r><t>1.5</t></r><x:rPh ...><t>7</t></x:rPh>` | 11.5 (juste) | **11.57**, `ok = TRUE`, sans message | reproduit sous 4.2.5.2 (l'issue cite 4.2.9) |
| #574 (3) : `XFD1048576` | erreur R « cannot allocate vector of size 128.0 Gb » (`matrix()`, l. 9072) | même message, levé dans `openxlsx` (`read_workbook`) | reproduit |
| #574 (3) : `A99999999999` | erreur R « invalid 'nrow' value (too large or NA) » | erreur R « missing value where TRUE/FALSE needed » (`read.xlsx.default`) | reproduit (messages différents) |
| #574 (4) : n `<x:rPh sb="0" eb="1">` non fermés, n = 1000 / 2000 / 4000 | chaîne partagée : 0,22 / 0,77 / 3,72 s ; en ligne : 0,31 / 0,96 / 3,57 s | chaîne partagée : 0,21 / 0,92 / 3,66 s ; en ligne : 0,18 / 0,52 / 1,51 s (cellule lue NA) | reproduit (coût quadratique) |
| #574 (5) : table en UTF-8 invalide (octet 0xFF), formes Q-F, P2 et X1 | contrôles sautés (`grepl` rend FALSE, avertissement « input string 1 is invalid ») ; « stack imbalance » ; cellule lue NA, puis refusée en aval | contrôles sautés ; « stack imbalance » ; erreur R brute « invalid input ... in 'utf8towcs' » (`getSharedStringsFromFile`) | reproduit, sans valeur fausse |
| #574 : deux `<c r="B2">` (104.2 puis 999) | 999, `ok = TRUE` | 999, `ok = TRUE` | reproduit |
| #575 : une seule `<si>`, `<c r="A2" t="s"><v>5</v></c>` | `annee: num NA`, code 0 | deux issues observées : segfault, code 139 (`getCellInfo`), 80 sous-processus sur 80 avec `sonde_575.R` ; erreur R « Value of SET_STRING_ELT() must be a 'CHARSXP' not a 'raw' » (code 0), 10 sur 10 avec `sonde.R`. Dans les deux cas, Rcpp avertit « subscript out of bounds (index 5 >= vector size 1) » | reproduit (lecture hors bornes ; l'issue dépend de l'état de la mémoire) |
| #579 : `xt` en booléens `t="b"` | refus « non numeriques » | `logical`, `xt = 1 ... 1` ; `run_engine` rend `ok = TRUE`, sigma_USP 9.4077602303 | reproduit |
| #579 : `xt` en textes « TRUE » | refus | même résultat, sigma_USP 9.4077602303 | reproduit |
| #579 : triangle 5×5, C(0,4) booléen | refus « Cellule(s) non numerique(s) en (i = 0, j = 4) » | `ok = TRUE`, C(0,4) = 1 ; `run_engine` refuse ensuite pour un motif trompeur (« Reserve chain-ladder totale negative ou nulle (R = -725.062) ») | reproduit |
| #579 : data.frame logique en appel direct, ou `read.csv()` par défaut | `ok = TRUE`, sigma_USP 9.4077602303 | même résultat | reproduit ; l'application n'est pas exposée par ce chemin (`app.R:280`, `colClasses = "character"`) |
| #579 : σ_USP 0,20176 annoncé par l'issue | non reproductible à l'identique : les données `yt` de `p4.R` ne sont pas versionnées ; le rejeu prend `yt` dans `donnees_ln.csv` (premium II-1, brutes) | idem | défaut reproduit, valeur différente |
| #570 : nom de colonne « bytes » placé avant `xt` ou `yt` | erreur R « translating strings with "bytes" encoding is not allowed » (`R/engine.R:8094`, `df$xt`) | idem | reproduit. Placé après `xt` et `yt`, le nom ne cause pas d'erreur ; `engine_lire_triangle()` non plus |
| #588 : octet 0x81 déclaré Latin-1 | l'assertion est vraie : « a<81>b ». `enc2utf8()` rend les octets ASCII `3c 38 31 3e`, alors que `iconv(latin1 → UTF-8)` rend `c2 81` (U+0081, la forme vue sous Windows) | idem | non observable sous Linux ; le constat de Windows ne se rejoue pas ici |

Batterie `tests/unitaires/test_controles_entree.R` :

- sans `openxlsx` : 428/428 ok, 6 lignes `[saute]` (`sorties/test_controles_entree_interne.txt`) ;
- avec `openxlsx` 4.2.5.2 : 444/444 ok, aucun saut (`sorties/test_controles_entree_openxlsx.txt`).

## Observations pour les étapes suivantes

- **#579** :
  - L'assertion des l. 5090-5094 de `test_controles_entree.R` et le commentaire du moteur (l. 8887-8889) disent qu'une colonne logique est relue en logique par `openxlsx`. Ils sont à revoir avec la correction.
  - Le tableau avant / après demande une sonde versionnée : 0,20176 ne se refait pas à partir de ce qui est versionné.
- **#575** : un test en sous-processus doit admettre les deux issues observées (code 139, ou erreur R). Seul un refus posé avant l'appel à `openxlsx` rend l'issue déterministe.
- **#570** : le défaut est déclenché par l'accès `df$xt` / `df$yt`, et seulement si un nom « bytes » précède la colonne.

## Constats mineurs écartés (ADR 0018)

Aucun. Aucun constat hors périmètre.
