# S4, lecteurs II : messages, écrivain, qualité — rapports versés (18/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/lecteurs-messages-et-qualite`, PR brouillon #600, base `3c6af48` (fusion de S3). Issues #568, #569, #580, #558, #595. Plan : soixante-sixième point de `docs/feuille-de-route.md`, fiche « Branche S4 » ; décisions Q-66-1 à Q-66-9 du 18/11, toutes en (a).

## Contenu du dossier

- `actuary-textes-etape-1.md` : textes d'`actuary` (étape 1) pour #595, #568 et #569.
- `sondes-595/` : sonde de #595 (`sonde_595.R`, `resumer.R`), relevés avant et après (`avant2.txt`, `apres2.txt`) et tableau final visé par le mainteneur (`tableau_final.txt`).
- `actuary-validation-etape-8.md` : validation du diff du `.tex` par `actuary-approfondi` (étape 8).

## Synthèse

### Étape 1 : textes d'`actuary` (`actuary-textes-etape-1.md`, `60816a4`)
- `actuary` (fiche de base) : textes des motifs de #595 (cible ambiguë, balise `<Relationship` de forme non reconnue), de #568 (en-têtes en chiffres romains, deux configurations, Q-66-5) et de l'information de #569 (rangement par t), dans la forme constat, cause, action.

### Avis d'`actuary` rendus en compte rendu seulement (résumés)
Les deux avis suivants n'ont été rendus qu'en compte rendu ; leur contenu est reconstitué à partir des messages de commit et des commentaires du code, et confirmé par la remesure de l'étape 8 (`actuary-validation-etape-8.md`, dernière section).
- **Relecture des textes de #595, règle (b)** (`5752c81`) : la recommandation de l'étape 1 (tester le texte brut et le texte collé) est révisée ; la règle porte sur le **seul texte collé**, celui que lit `openxlsx` après `readLines()` puis `paste(collapse = "")`. Sur le texte brut, la forme bien formée « un attribut par ligne » (`<Relationship<LF> Id=`, lue juste par les deux chemins) aurait été refusée à tort ; une fin de ligne suivie directement d'un attribut reste refusée, parce que le collage la rend `<RelationshipId`. Le motif est précisé en conséquence.
- **Règle de l'étape B de #568** (`8d2fe56`) : aucun triangle accepté avant #568 n'est refusé. En configuration 1, le flux continue et le motif dédié ne remplace que celui de `.motifs_colonne_i()` quand celle-ci en émet un ; casse uniforme sur toute la suite ; résidu admis : une colonne I de montants entiers consécutifs est refusée en aval au motif générique. Vérifiée par l'audit sur 20 000 en-têtes aléatoires (aucun passage d'accepté à refusé), puis par l'audit de la revue finale sur 3 000 tableaux (acceptation inchangée dans tous les cas).

### Étapes 2 à 6 : réalisation
- **#580**, écrivain xlsx (`coder`, circuit 3) : `f6d8931`, `a234226` ; reprises accordées par le mainteneur au-delà du plafond (§ 5.2) : `2649962`, `4999b15`, `32f3b21`, `9440415`. Chemin de sortie résolu avant `setwd()`, refus `usp_refus_ecriture` avant toute écriture (caractères hors XML 1.0, UTF-8 invalide, retour chariot en cellule, blancs du nom de feuille (M1, décision du mainteneur), chemins Windows sous unix (« refus explicite »), nom hors `.xlsx`, dossier existant), fichier rendu seulement s'il existe après l'écriture.
- **#595**, lecteur xlsx (`coder-approfondi` d'office, une reprise) : `5752c81`, `cf80595`, `9ace916` (README), `d5fb6bd` (sondes). Refus, avant tout appel d'`openxlsx`, de la cible ambiguë (a1 à a3), de `Type` répété ou préfixé et de la balise `<Relationship>` de forme non reconnue. **Visa du mainteneur le 18/11** sur `sondes-595/tableau_final.txt` (valeur fausse 999 au lieu de 104,2, σ_USP 0,5064392336 au lieu de 0,1114524114, et blocage d'`openxlsx`, remplacés par des refus au même texte sur les deux chemins).
- **#558** (`coder-approfondi`, Q-66-1) : 4a `a01be4e`, `4dcb429` ; 4b `4905d80` ; 4c `5242a8b` ; 4d `c8e3512` (Q-66-2 : seconde décompression justifiée et mesurée, commentaire sur #558). Seul motif changé : « Colonne t incomplete », plafonné à cinq positions.
- **#568** (`coder`, Q-66-7) : `8d2fe56`, `589c6fb` ; une reprise (règle ci-dessus).
- **#569** (`coder-approfondi` d'office, interface entre couches) : `267b55d` (moteur), `f6c1a45` (application), `6422df3` (tests) ; `app-review` légère conforme ; bloc shiny vert en CI (job de parité, shiny 1.8.0, 278 assertions sur `4dcdc2a`, aucune ligne `[saute]`).
- Six cas de référence identiques au seuil 0 après chaque commit ; aucun σ_USP, aucune p-value ni aucun verdict changés ; références ni patchées ni régénérées.

### Étape 7 : règle 9 (`docwriter`, effort de la fiche)
- `8963da1` (#558), `122847a` et `fdbbe22` (#568 ; le second corrige trois écarts de concordance du premier, sans réécriture), `c986b1b` (#569), `4c13502` (#595 ; quatre passages devenus faux retirés et consignés dans `docs/suivi-documentation/I.md`, entrée `sec:controles`), `fdef4b9` (#580, `\versiondoc` 4.1, Q-66-4). Concordance `--strict` à 0, `controle_doc_nd.R --bloquant` sans violation, compilation sans référence indéfinie, 137 ancres de `\label` inchangées.

### Étape 8 : validation (`actuary-validation-etape-8.md`)
- `actuary-approfondi` : **visa avec réserves**, aucun bloquant ni majeur ; affirmations sur `openxlsx` (999, blocage, erreurs R, entrées homonymes) confirmées par échantillon sous `openxlsx` 4.2.5.2 ; huit mineurs (C1 à C7 au mot près, C8 facultatif), **tous portés** par `docwriter` dans `1ae0790`, avec `\datedoc` au 18 novembre 2026 (règle du préambule ; condition de l'avis remplie : question 2580 de l'AEAPP relue le 18/11 à 14:52 UTC, inchangée). Double décompression : mention jugée non nécessaire.

### Étape 9 : revue finale (règle 10, `git diff origin/main...HEAD`)
- `audit` en `high` sur `fdef4b9` : **conforme avec réserves**. Six cas à écart 0 ; concordance `--strict` à 0 ; unitaires par lots 1264 + 1820 + 979 = 4063 assertions, 0 échec ; parité (`openxlsx` 4.2.5.2, shiny 1.8.0, zip 3.0.2) 613 + 100 + 127 + 278, aucune ligne `[saute]` ; différentiels du lecteur de triangle (3 000 tableaux) et des séries (3 000) conformes aux changements annoncés. Quatre mineurs : constats 1 (`\datedoc`) et 2 (`.tex`) couverts par `1ae0790` ; constat 2 (commentaire de `.refus_ecriture()`) corrigé par `77bc40b` ; constat 3 (`CONTEXT.md`, `usp_refus_ecriture`) corrigé par `f9a1c5f` (texte d'`architect`) ; constat 4 écarté.
- `app-review` en Opus : **conforme** ; trois mineurs, écartés.
- Audit léger des correctifs (`fdef4b9..77bc40b`) : **conforme** ; un mineur facultatif, écarté.
- `/code-review` (`high`, 18/11, sur `origin/main...77bc40b`) : dix constats, aucun bloquant ni majeur ; libellé d'assertion de `test_application.R` corrigé (`2709d71`) ; les neuf autres écartés (ADR 0018 ; PR #600).

### Étape 10 : veille et PDF
- Veille du 18/11 (second relevé, 14:17-14:52 UTC), commentaire daté sur #463 seul (Q-66-9) : aucun fait nouveau (AEAPP, orientations de 2015, question 2580 ajoutée à la liste, 2015/498, rectificatifs de 2026/269 (R(01) à R(03)) et de 2015/35 (R(01) à R(14)), R. 352-5, R. 356-19).
- PDF de fin de branche `0b08d1d` (`.tex` de `1ae0790`, pdfTeX-1.40.25, 463 pages, 0 référence indéfinie).

## Constats hors périmètre (ADR 0018)

- Aucune issue nouvelle.
- **Écartés (mineurs)** : voir la PR #600, « Constats mineurs écartés (ADR 0018) ».
