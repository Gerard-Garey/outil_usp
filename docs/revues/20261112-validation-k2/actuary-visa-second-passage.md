# K2, étape 10 : visa d'`actuary` sur le second passage de `docwriter` (relance ciblée)

> *Rédigé par l'agent actuary (IA), fiche approfondie, le 12/11/2026. Branche `claude/fichiers-et-point-decimal`, tête `4363f21`. Diff validé : `git diff 54a3d1b..HEAD -- docs/latex/doc_tests_usp.tex README.md` (commits `3036f3d`, `422de6e`, `98dc09a`, `4363f21`). Rien n'a été écrit dans le dépôt. Mesures faites sous `LC_ALL=C.UTF-8`, avec puis sans `openxlsx` 4.2.9 (bibliothèque du scratchpad). Les scripts sont dans `/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/m/` (`m5.R`, `m6.R`).*

## Verdict

**Validé avec une réserve mineure** (R1).
- R1 porte sur la phrase de l'écart de C2 qu'on me demandait de valider : elle est exacte pour le triangle, mais incomplète pour la série.
- Le reste du diff est fidèle au code et son statut épistémique est juste : C1 dans le texte de `regulatory`, C3 à C5, corrections de la revue finale et README.
- Aucun changement de σ_USP, de p-value ni de verdict.

## 1. C1 : ancrage D(1) lu avec A(1)(b) (`.tex` l. 3882-3904)

- **Texte** : repris mot pour mot du § 4 de `regulatory-lecture-annexe-xvii.md` (*vérifié* par comparaison).
- **Citations** : celles de A(1)(b) (« la différence entre l'année de ce paiement et l'année de l'accident auquel il correspond ») et de D(1) (« pour chaque année d'accident et chaque année de développement des paiements ») sont identiques à la version consolidée (*vérifié*, extraction du texte, sans formule).
- **Fond** : le texte répond à mes deux objections du matin.
  - Le rattachement à D(1) est conditionnel : il vaut dans la lecture « colonne 0 vide ». Le texte dit qu'un tableau décalé « satisfait au contraire D(1) sur ce point » et que son refus « relève de la seule précaution ».
  - D(2)(c) est écarté, avec le bon motif : la consécutivité est préservée dans les deux lectures.
- **Statut épistémique** : juste. Le refus est présenté comme une précaution de l'outil et l'ancrage comme un rattachement (« se rattache à »), non comme une exigence du texte.
- **Avis** : je m'étais prononcé contre tout ancrage. Le mainteneur a tranché après une lecture établie par `regulatory`, et le texte retenu n'affirme rien que je conteste. **Aucun désaccord ne subsiste ; pas d'escalade.**

## 2. Écart de C2 (`.tex` l. 4530-4532) : réserve R1, mineure

**Phrase de `docwriter`** : « Un fichier sans aucune valeur n'est pas visé et garde ses refus propres~: tableau vide pour un triangle, colonnes manquantes pour une série (mesuré). »

**Mesuré** :

| Fichier sans aucune valeur | Série | Triangle |
|---|---|---|
| CSV `,,` / `,,` / `,,` (lignes de cellules vides), lu comme par l'application | « Colonne(s) manquante(s) … Colonnes presentes : (vide), (vide), (vide). » | « Fichier vide ou illisible comme tableau. » |
| Classeur à cellules vides (deux chemins) | colonnes manquantes | « Fichier vide… » |
| CSV `,,` seul, sans ligne de données (test l. 2993-2995 de `test_controles_entree.R`) | **« Fichier vide ou illisible comme tableau. »** | « Fichier vide… » |
| Feuille sans aucune cellule (test l. 2880-2885, deux chemins) | **« Fichier vide ou illisible comme tableau. »** | non testé ; même branche de code (`!nrow(df)`) |

**Analyse** :
- L'écart de `docwriter` corrige à juste titre mon texte : pour une série dont le fichier porte des lignes de cellules vides, le motif est bien celui des colonnes manquantes.
- Mais la série reçoit **aussi** le refus de tableau vide quand le fichier n'a aucune ligne de données ou aucune cellule. Ce comportement est vérifié par la batterie. « colonnes manquantes pour une série » est donc trop général.
- Aucun refus n'est manqué : la réserve ne porte que sur la description.

**Correction attendue, mot pour mot** (`docs/latex/doc_tests_usp.tex:4530-4532`) : remplacer « Un fichier sans aucune valeur n'est pas visé et garde ses refus propres~: tableau vide pour un triangle, colonnes manquantes pour une série (mesuré). » par :

> Un fichier sans aucune valeur n'est pas visé et garde ses refus propres~: tableau vide pour un triangle~; pour une série, tableau vide, ou colonnes manquantes si le fichier porte des lignes de cellules vides (mesuré).

## 3. Autres points du diff, vérifiés contre le code ou mesurés

- **Refus de la ligne 1 en CSV et en classeur, option (b)** : `.ligne1_sans_valeur()` (`engine.R:7751-7767`), `MOTIF_LIGNE1_VIDE` (l. 7722) et `.xlsx_controler_ligne_entete()` (l. 8483-8505) sont conformes à l'index (l. 823-853, 905-925) et au récit (l. 4519-4540). Mesuré :
  - CSV `,,` puis `t,xt,yt` : refus au texte de #522 ;
  - CSV ` , ,` : refus ;
  - classeur à ligne 1 `""`, `" "`, `""` : `usp_refus_lecture` au même texte, sur les deux chemins ;
  - espace insécable seule, en CSV comme en classeur : non refusée, citée ` `, en-tête réel ;
  - `read.csv` par défaut, ligne 1 `,,` : noms « X, X.1, X.2 », non visés (README exact).
- **Statut « mesuré sous C.UTF-8 »** (espace insécable hors de `[[:space:]]`, parité des blancs d'en-tête) : juste, la dépendance à la locale est dite.
- **Divergences avec `openxlsx` 4.2.9** (`.tex` l. 880-883 et 4510-4516), mesurées :
  - références en minuscules : la voie de repli lit `t,xt,yt`. Avec `openxlsx`, `engine_lire_xlsx()` s'arrête sur une erreur R levée dans `read.xlsx.default()` (« missing value where TRUE/FALSE needed »), donc message fixe de l'application ;
  - `r:id` entre apostrophes : la voie de repli lit la feuille ; `openxlsx` lève « Workbook has no worksheets ».
  - L'affirmation « s'arrête sur une erreur R » est exacte pour l'appel du moteur.
  - Sur le fond, c'est une divergence de **lecture ou de refus**, jamais de valeurs lues : aucun nombre faux ne peut en sortir.
- **Feuille de graphique en premier onglet, rang transmis à `openxlsx`** : conforme à `.xlsx_fichier_feuille()` (l. 8373-8420). La mesure d'`openxlsx` (« `sheet = k` lit la k-ième balise `<sheet>` ») figure dans le commentaire du code et dans le test l. 2734 et suivantes ; je ne l'ai pas refaite.
- **`.xlsx_chemin_sort()`, `.xlsx_attribut()`, `.xlsx_cellules()`, `.xlsx_indice_partage()`** : descriptions de l'index conformes au code (l. 8314-8448).
- **Repli de compression** (README et `.tex` l. 931-934) : conforme à `engine_ecrire_xlsx()` (l. 8170-8193). Archive partielle effacée, repli par `utils::zip()` si la commande existe, erreur qui nomme l'échec du paquet et le statut ou l'absence de la commande.
- **C3, C4, C5** : appliqués mot pour mot.
- **O3 de mon rapport du matin** (triangle 7 × 8, ligne 1 de blancs) : **caduque**. L'option (b) refuse désormais cette ligne 1 sur les deux chemins.

## 4. Résultats

- `LC_ALL=C.UTF-8 Rscript tests/test_reproductibilite.R` à `4363f21` : 6 cas CONFORMES, écart maximal 0,000e+00.
  - σ_USP inchangés : premium 0,1114524114 ; reserve1 0,1073524114 ; reserve2 0,0497764613 ; premium_ii6 0,1483524114 ; premium_net 0,1032524114 ; premium_interieur 0,0871308679.
- `tests/concordance_doc_moteur.R --strict` : 0 écart.
- **Aucun changement de σ_USP ni de verdict n'est à soumettre au mainteneur.**
- Le seul comportement nouveau hors références depuis le matin : un CSV ou un classeur à ligne 1 de séparateurs ou de blancs, auparavant refusé par un autre motif, reçoit maintenant le refus de #522. Ce changement est décidé (option (b), extension aux CSV).

## Retour

- **Statut** : `complet`.
- **Résultat** : **validé avec une réserve mineure** (R1, correction mot pour mot au § 2). La correction est à porter par `docwriter` dans un commit `docs:` minimal. Elle ne demande pas de nouvelle validation de fond : la session peut contrôler sur le diff que le texte est repris à l'identique.
- **Preuves** :
  - ***Vérifié*** :
    - texte de C1 identique à celui de `regulatory` ; citations de A(1)(b) et D(1) conformes au consolidé ;
    - refus de la ligne 1 en CSV et en classeur, espace insécable, noms « X… », fichiers sans valeur : exécutés sur les deux chemins ;
    - divergences `openxlsx` sur les minuscules et les apostrophes : mesurées ;
    - descriptions de l'index : comparées au code ;
    - reproductibilité 6/6 et concordance `--strict` à `4363f21`.
  - ***Repris sans remesure*** : rang des feuilles de graphique pour `openxlsx` (commentaire du code et test l. 2734 et suivantes) ; parité des blancs sous `C.UTF-8` sur le plan multilingue de base (commentaire du code).
  - ***Non vérifié*** : comportement sous Windows (dit tel quel dans le `.tex`) ; compilation du PDF (hors de mon rôle).
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune. C1 a été tranché par le mainteneur et le texte retenu est accepté.
- **Critères déclenchés** :
  - désaccord avec une décision : aucun subsistant (C1 accepté après la lecture de `regulatory`) ;
  - changement de résultat : hors références seulement, décidé (option (b)).
- **Prochaine action recommandée** : `docwriter` applique R1 ; la session contrôle le diff ; puis commit du PDF et sortie du brouillon selon la fiche.
