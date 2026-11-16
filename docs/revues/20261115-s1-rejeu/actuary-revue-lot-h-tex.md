# Revue du passage de docwriter sur le lot H (actuary, 16/11/2026)

> *Rédigé par l'agent actuary (IA).* Rapport versé intégralement par la session principale. Revue sur son diff (règle 10) de `git show f46bbd9` (`docs/latex/doc_tests_usp.tex`, `docs/suivi-documentation/I.md`). Comparaison au code de HEAD `db7e3dd` (`.xlsx_controler_relations()`, `.xlsx_controler_designation()`, `.xlsx_fichier_feuille()`, `.xlsx_controler_structure()`, `engine_lire_xlsx()`), aux sorties `sorties/574-lot-h-avant.txt` / `-apres.txt`, à D-S1-37 à D-S1-39 et à `origin/main` (`0d4af02`).

## Verdict : visa avec une réserve majeure (R1), à lever par un commit `docs:` minimal revu sur son diff

R1 tient à la seule phrase de la limite « cible forgée ». Elle énonce mal les conditions et sous-estime la portée de la valeur fausse : ma mesure montre que les deux chemins peuvent lire 999. Le reste du diff est exact, y compris les points (3) et (4) et l'item « Désignation de la feuille lue ». Le `.tex` ajouté ne contient aucune vie du dépôt : aucun numéro d'issue, aucun « D-S1 », aucun SHA, aucune mention d'ADR ni de décision (grep sur les lignes `+`, aucun résultat). Le diff ne change aucun résultat.

## Points soumis par docwriter

**(1) Voie de repli, `x:Target="…sheet2" Target="…sheet1"` → 999 : légitime au `.tex`, et nécessaire.**
- Le guide doit dire toute valeur fausse connue sur un classeur admis. Le cas appartient à la classe que D-S1-38 consigne (« cible forgée »), sans décision nouvelle.
- Le code le produit par construction : `.xlsx_fichier_feuille()` lit la cible par `.xlsx_attribut(liens[l[1L]], "Target")`, qui prend le premier attribut de nom local `Target`, préfixé ou non.
- Je l'ai rejoué sur HEAD : interne 999, σ_USP 0,5064392336, ok = TRUE ; openxlsx 4.2.5.2 « Length of worksheet is 0 ».
- Mais la mesure a révélé R1 ci-dessous. L'issue prévue par D-S1-38/39 doit reprendre R1.

**(2) « un seul de ces écarts connus donne une valeur fausse (cible de la feuille forgée, ci-dessous) » : pas exact en l'état.**
- Compter la cible forgée comme un seul écart à plusieurs sous-cas se défend.
- Mais quand les deux chemins lisent 999 (R1), il n'y a plus d'écart entre chemins. Il y a une valeur fausse commune.
- Formule proposée : « une seule forme connue donne une valeur fausse sur un classeur admis (cible de la feuille forgée, ci-dessous, lue fausse par l'un des chemins ou par les deux) ».

**(3) Règle des positions de `<sheetData>` : exacte, mon m1 du lot G est levé.**
- Code, branche générale de `.xlsx_controler_structure()` : `if (length(sur) && sum(s > 0L) == 1L && !any(genre == "v")) sort(c(sur, nf)) else sort(c(k, sur))`.
- Avec une seule ouvrante, `nf` contient cette ouvrante si et seulement si aucune fermante ne la suit : la somme de suffixe vaut 1 − m, à comparer au maximum postérieur 0.
- Quand il n'y a aucune fermante en surnombre, la seule forme qui reste est l'ouvrante seule, et `k` la cite.
- Le nouvel énoncé (« cette ouvrante quand aucune fermante ne la suit, sinon toutes les ouvrantes et les balises vides ») est donc équivalent au code.
- Il concorde avec les dix XML consignés dans `I.md`. Les citations identiques fusionnées (`<sheetData/>` puis bloc : une citation) restent ma remarque antérieure, sans constat.

**(4) Phrase sur `styles.xml` : exacte et bien bornée.**
- `engine_lire_xlsx()` (l. 10750) appelle `openxlsx::read.xlsx()` sans `detectDates`, dont le défaut est `FALSE`.
- Dans `openxlsx:::read.xlsx.default` 4.2.5.2 (déparsé), `styles.xml` n'est lu, par `getChildlessNode(numFmt)` et `getChildlessNode(xf)`, que dans `if (detectDates)` (lignes déparsées 263-285).
- Hors de ce bloc, `getChildlessNode` n'est appelé que sur les relations (l. 42). Aucune autre partie n'est exposée à la boucle par ce chemin.

## Item « Désignation de la feuille lue » comparé au code : exact

- **Refus de `.xlsx_controler_relations()`.** Le premier contrôle refuse tout `<Relationship>` dont les noms d'attribut de nom local `Id` ne se réduisent pas à `Id`. Le deuxième refuse tout `<sheet>` dont les noms d'attribut de nom local `id` ne se réduisent pas à `r:id`. Le troisième refuse un `Id` en double. Ces trois contrôles passent avant la boucle de choix, ce qui confirme « avant le choix de la feuille ».
- **Refus de `.xlsx_controler_designation()`.** Il compte trois étapes, sur le texte collé (`\r`, `\n` retirés) :
  - le texte `r:id="` hors d'un nom d'attribut ;
  - le rang-ième identifiant lu à la façon d'openxlsx (`<sheet[^>]*>` entre `<sheets>`, `r:id=""` écartés, `(?<= r:id=")[0-9A-Za-z]+`) ;
  - le texte `Id="<id>"` hors de l'attribut retenu.

  Le contrôle passe après la boucle et avant `.xlsx_chemin_sort(cible)`, ce qui confirme « la feuille retenue et avant le choix de sa cible ». Le cas où `rang > length(ox)` n'est pas refusé, ce qui confirme « erreur de R, ce cas n'est pas refusé ».
- **« une autre feuille […] par l'un des deux chemins, ou par les deux pour deux relations de même identifiant ».** C'est vérifié dans `574-lot-h-avant.txt`, cas pour cas :
  - (e) donne 999 sur les deux chemins ;
  - les autres formes donnent 999 sur un seul chemin ;
  - `workbook-nom-chevron` (r:id absent) donne 999 en interne et une erreur d'openxlsx.
- **« à une exception près », la relation sans `Id` lue juste.** C'est cohérent avec le code : ce cas tombe dans le premier refus de `.xlsx_controler_relations()` sans aucun désaccord entre chemins. La mesure de docwriter (`5950e03` : 104,2 / 104,2 ; `28ce0ef` : refus « (aucun) ») est consignée dans `I.md`. Je ne l'ai pas rejouée.

## Constats

**Bloquant** : aucun.

**R1 (majeur) : affirmation inexacte du guide sur une valeur fausse.** Lignes ajoutées au paragraphe « Écarts qui subsistent », limite « cible forgée ».
- **Ce que dit le `.tex`** : la relation forgée « fait lire à l'un des deux chemins […] une autre feuille ». Elle le fait à openxlsx « quand l'attribut de cible est écrit entre apostrophes (`Target='…'`) avant ce texte ». Elle le fait à la voie de repli « quand `x:Target="…"` précède `Target="…"` ».
- **Mesure.** Sonde `sonde_574_lot_h.R` copiée et augmentée de trois cas ; HEAD `db7e3dd`, `LC_ALL=C.UTF-8`, R 4.3.3, voie de repli et openxlsx 4.2.5.2 (bibliothèque du scratchpad de docwriter). Feuille 2 portant 999.

  | Relation de la feuille lue | Interne | openxlsx 4.2.5.2 |
  |---|---|---|
  | `x:Target="…sheet2.xml" Target='…sheet1.xml'` | 999, σ_USP 0,5064392336, ok = TRUE | 999, σ_USP 0,5064392336, ok = TRUE |
  | `Foo='Target="…sheet2.xml"' Target='…sheet1.xml'` | 104,2 | 999, σ_USP 0,5064392336, ok = TRUE |
  | `x:Target="…sheet2.xml" Target="…sheet1.xml"` | 999 | « Length of worksheet is 0 » |
  | `Target='…sheet1.xml' x:Target="…sheet2.xml"` (témoin de la sonde) | 104,2 | 999 |

- **Première erreur : « l'un des deux chemins ».** Elle est fausse. `x:Target="…"` suivi de `Target='…'` fait lire la mauvaise feuille aux deux chemins.
- **Seconde erreur : « avant ce texte » est trop étroit.**
  - openxlsx lit la mauvaise feuille dès que l'attribut de cible est entre apostrophes, que le texte forgé le précède ou le suive. Les quatre ordres sont mesurés.
  - Cela découle de sa lecture : `(?<=Target=").+xml(?=")` part du premier texte `Target="`. Aucune suite `xml"` ultérieure ne prolonge la capture quand la vraie cible finit par `xml'`.
- **Correction proposée.** Elle demande un texte, pas de code.

  > à `openxlsx`, qui lit la cible à partir du premier texte `Target="` de la relation, quand l'attribut de cible est écrit entre apostrophes (`Target='…'`), que ce texte le précède ou le suive ; à la voie de repli, qui lit le premier des deux attributs, préfixé ou non, quand `x:Target="…"` précède l'attribut de cible ; aux deux chemins quand ces deux conditions sont réunies (`x:Target="…"` suivi de `Target='…'`) (première valeur de `xt` lue 999 au lieu de 104,2, mesuré, openxlsx 4.2.5.2)

  Ajuster en conséquence la phrase du point (2) et la trace dans `I.md`.

**Mineurs** : aucun.

## Comparaison à `origin/main`

- `origin/main` disait déjà « sans valeur fausse connue ». La phrase était déjà fausse avant S1 : la cible forgée est un défaut antérieur.
- Le diff corrige ce défaut dans le bon sens. Seule la précision de R1 manque.
- La modification du README (`47bef00`, « une cible de feuille forgée qui mène à une valeur fausse ») ne nomme pas de chemin. Elle reste exacte après R1.

## Retour

- **Statut** : `complet`.
- **Résultat** : visa avec une réserve majeure (R1, texte seul). Les points (1), (3) et (4) sont acceptés. Le point (2) est à reformuler avec R1. L'item « Désignation » est exact, et le `.tex` ne contient aucune vie du dépôt.
- **Preuves**
  - **Vérifiées**
    - Diff `f46bbd9`.
    - Code `R/engine.R` à `db7e3dd` : l. 9106-9131 (`.xlsx_controler_relations()`), 9186-9266 (`.xlsx_controler_designation()`), 9286-9348 (`.xlsx_fichier_feuille()`), 9470-9490 (`.xlsx_controler_structure()`, positions citées) et 10749-10752 (appel `read.xlsx` sans `detectDates`).
    - Déparsé de `openxlsx:::read.xlsx.default` 4.2.5.2 : `getChildlessNode` sur les relations (l. 42) et sur `styles.xml` dans `if (detectDates)` (l. 263-285).
    - `574-lot-h-avant.txt`, résumé cas par cas.
    - Quatre exécutions de la sonde augmentée sur les deux chemins (tableau de R1), copie de travail dans le scratchpad de session (`act-h/s.R`).
  - **Hypothèse** : la règle générale « openxlsx trompé dès que la cible est entre apostrophes ». Elle est déduite de sa lecture de la cible (regex vue dans `I.md`) et confirmée sur quatre ordres. Elle n'est pas démontrée pour toute forme.
  - **Non vérifié** : les numéros de ligne de la source d'openxlsx cités dans `I.md` (`R/readWorkbook.R` l. 150-152, 290-292, 466-494). J'ai lu le code déparsé, pas le fichier source. Je n'ai pas non plus rejoué la boucle sans fin (D-S1-39) ni la relation sans `Id`.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune pour le mainteneur. Le fait nouveau (les deux chemins lisent 999) est à ajouter au corps de l'issue prévue par D-S1-38/39.
- **Critères déclenchés** : aucun changement de résultat. Le fait nouveau est un défaut antérieur à S1, déjà dans le périmètre de l'issue D-S1-38.
- **Constats hors périmètre** : un seul. La valeur fausse commune aux deux chemins par `x:Target="…"` suivi de `Target='…'` relève du critère E1 de l'ADR 0018 (effet sur σ_USP : 0,1114524114 → 0,5064392336, mesuré ci-dessus). Elle est déjà couverte par l'issue prévue par D-S1-38 : à y ajouter, pas d'issue nouvelle.
- **Prochaine action recommandée** : un commit `docs:` minimal de docwriter pour R1 et la phrase du point (2), avec la trace dans `I.md`, revu sur son diff. Ensuite l'ajout du cas à l'issue D-S1-38/39, puis le PDF de branche.
