**Verdict : conforme avec réserves.** Rien de bloquant. Le code gelé est correct et reproductible, et le `.tex` est exact au regard de `R/engine.R` sur tout ce que j'ai pu mesurer. Deux constats majeurs restent, tous deux documentaires et hors du périmètre du gel : le README (« Reproductibilité et tests ») n'est plus à jour, et la synthèse des revues n'est pas à jour. Ils se corrigent par des commits `docs:` avant la sortie du brouillon, sans dégel.

# Revue finale complète (règle 10) de `claude/passage-de-remise`, PR #578

> *Rapport de l'agent `audit` (IA, effort `high`), rendu à la session principale le 14/11/2026 ; versé tel quel par la session principale.*

- Tête `a0fe3e2`, base `origin/main` = `f8ff168`, 34 commits, 30 fichiers. Effort `high`, lecture seule.
- `git status` est propre et je n'ai rien écrit dans le dépôt. Mes essais sont dans le dossier temporaire de la session (`forge.R`, `logi.R`, `xl/`).

## Constats

### M-1 — majeur — `README.md:192-196` et `README.md:227-238` : section « Reproductibilité et tests » périmée (#548, #549, #588)

**Ce qui ne va pas, passage par passage :**
- **l. 192-196.** « La seconde comparaison absorbe volontairement la dérive d'arrondi d'une plateforme à l'autre (écart relatif maximal mesuré 3,5e-07…) ». Cela contredit le `.tex` réécrit (`sec:graines`, l. 2754-2760 : seuil « garde de la CI », « pas une marge calée sur la dérive d'un poste ») et l'annotation de l'ADR 0006 du 14/11. Sur le poste, la dérive va jusqu'à 1,814e-6 : elle n'est donc pas absorbée.
- **l. 233-235.** « l'absence d'effet sur les p-values retenues et les verdicts, attendue, reste à confirmer (#548) ». C'est périmé : le critère a été accepté sur le gel `a2f9c3a` (`etape-3-releve-poste.md`, « Critère accepté »), et le `.tex` dit déjà « le poste ci-dessus satisfait ce critère ».
- **l. 223-227.** « la batterie unitaire … passe sans échec (poste du mainteneur, 11/11/2026) » et « Deux points connus demeurent ». Le relevé de l'étape 3 trouve, avec `openxlsx` 4.2.9, un échec propre à Windows dans `test_controles_entree.R` (assertion #522, octet 0x81). Il est suivi par #588 et absent du README.
- **l. 236-238.** La puce Git Bash et `pdftotext` « en attendant #549 » est périmée :
  - #549 est fermée, `completed`, par la PR #552 (R41) le 11/11 (vérifié, `mcp__github__issue_read`).
  - `tests/unitaires/test_controle_doc_nd.R:855-858` saute désormais la passe de mesure quand `pdftotext` n'est pas poppler (`nd$nd_pdftotext_poppler()`), au lieu d'échouer au chargement.

**Mesures :** `grep -n "548\|reste à confirmer" README.md` → l. 235 ; lecture de `etape-3-releve-poste.md` ; `mcp__github__issue_read` #549 → `state: closed`, `closed_by_pull_requests` #552 ; lecture de `test_controle_doc_nd.R:855-858`.

**Correction proposée** (commit `docs:`, `Refs #548`, `Refs #588`) :
- Remplacer l. 192-196 par :
  > La seconde comparaison est une garde de la CI, plateforme de production des références : la CI reproduit ses références au bit près (depuis M34, BLAS et LAPACK de référence ; deux exécutions successives y sont identiques au bit près), et un écart au-delà du seuil y est un changement de résultat à identifier et à expliquer (ADR 0006, annoté le 14/11/2026, et ADR 0011). Le seuil n'est pas une marge calée sur la dérive d'un poste de travail, qui peut le dépasser sans défaut (voir ci-dessous) :
- Remplacer l. 223-238 (paragraphe et deux puces) par :
  > Sous Windows, la batterie unitaire lancée sous PowerShell passe (poste du mainteneur, R 4.3.3 ucrt) depuis la correction du lancement des processus fils (#477), de la langue des sorties de `summary.lm()` (#478) et de l'affichage de `fmt_p()` sous la bibliothèque C de Windows (#479). Deux points connus demeurent :
  >
  > - `tests/test_reproductibilite.R` rend `premium_interieur` non conforme : deux valeurs de `bootstrap$stats_boot`, celles des statistiques `BP` et `BP79` d'une même réplication, s'écartent de la référence au-delà du seuil 1e-6 (1,81e-6 au plus). C'est une dérive de plateforme entre le poste et la CI. Sous Windows, la batterie est jugée par le critère d'effet de l'ADR 0006 (annotation du 14/11/2026). Mesurée le 14/11/2026 sur le code gelé `a2f9c3a`, elle le satisfait : aucune valeur de `parametre_final` ni aucune p-value au-delà du seuil, p-values Monte-Carlo identiques au bit près, aucun verdict ni libellé modifié (#548 ; relevé : `docs/revues/20261114-passage-de-remise/etape-3-releve-poste.md`).
  > - Avec `openxlsx` installé, `tests/unitaires/test_controles_entree.R` compte un échec propre à Windows (#588) : un octet 0x81 déclaré Latin-1 est cité `\u0081` au lieu de `<81>` dans un motif de refus d'import. Aucun nombre, verdict ni σ_USP n'est touché.
  >
  > Lancée depuis Git Bash, dont le `pdftotext` (xpdf) ne connaît pas `-bbox`, `tests/unitaires/test_controle_doc_nd.R` saute la passe de mesure du remplissage au lieu d'échouer (#549).
- Une réserve sur ce texte : le « passe » de la première phrase n'a pas été remesuré depuis le 11/11 hors `openxlsx`. Garder la date si le mainteneur le préfère.
- Hors README, même défaut, déjà suivi : `.claude/rules/moteur.md:24` (« seuil ≈ 3 fois ce maximum ») → #589 ; `tests/comparer_references.R` → #590.

### M-2 — majeur — `docs/revues/20261114-passage-de-remise/README.md:10` et `:33-34` : synthèse des revues arrêtée à `f179ce2`

- Le fichier n'a pas été touché depuis `f179ce2`, antérieur aux commits `e185b9a` (étape 3) et `244d67f` (étape 8).
- Il annonce « Restant : Étape 3 (poste), puis 7 à 12 ; décisions du mainteneur sur E-L1-1, les deux majeurs (issue ou dégel) et les issues proposées ». Or l'étape 3 est faite, les étapes 7 et 8 aussi, et les issues #579 à #590 sont créées.
- Trois rapports versés n'ont aucune entrée de synthèse : `etape-3-releve-poste.md`, `actuary-etape-8-tex.md`, `regulatory-etape-8-aval.md`.
- La l. 10 « **En attente** : visa du mainteneur » subsiste, alors que la l. 11 donne le visa.

CLAUDE.md (« Revues périodiques ») exige que ces rapports soient versés avec une synthèse avant la sortie du brouillon.

**Correction proposée** (commit `docs:` de la session) : supprimer la l. 10 ; ajouter « Étape 3 : relevé du poste », « Étapes 7 et 8 », « Issues créées » (#579 à #590, m1 en commentaire de #574) ; remplacer « Restant » par les étapes 9 à 12.

### m-1 — mineur — `docs/feuille-de-route.md:3829` (fiche « Branche KR », liste à cocher)

- La liste porte « [ ] 3 (#548, poste) — … — [ ] 7 — [ ] 8 », alors que les étapes 3, 7 et 8 sont faites. Ce n'est pas bloquant : `architect` met à jour au point d'étape, mais l'état écrit contredit la branche.
- Correction : cocher 3, 7 et 8 à la prochaine écriture de la feuille de route par la session ou `architect`.

### m-2 — mineur — `docs/revues/20261114-passage-de-remise/etape-2/mesure_575.sh:3`

- Le script lit `$(dirname $0)/forge.xlsx`, qui n'est pas versé. La mesure versée ne se rejoue donc pas depuis le dossier.
- Correction : décrire en tête du script la construction de `forge.xlsx` (une cellule `t="s"` d'indice 5, une table d'une seule chaîne), ou renvoyer à l'issue #575.

### m-3 — mineur — message de `244d67f`

- Le sujet commence par un BOM UTF-8. Aucune réécriture n'est permise (Q-43-13) : à noter seulement. Vérifier que l'outil de saisie des messages sur le poste n'ajoute plus de BOM.

## Points vérifiés sans constat

**1. Code de l'étape 1 (#573)**
- `git diff a2f9c3a HEAD -- R/ app.R DESCRIPTION tests/` est vide : le gel tient.
- `phrase_res2` retirée des deux formes, commentaire aligné, `Version` 2.1.0. Oracles `motif188()` et `motif227()` alignés. La nouvelle assertion (`test_controles_entree.R:4810-4821`) ferait échouer la batterie si la phrase revenait.
- `grep -rn "reste ouverte"` sur `R/`, `tests/` (hors `reference/`), `app.R`, `README.md`, `.tex`, `docs/specifications/` et `CONTEXT.md` ne trouve que le test de #573, le corps historique de la spécification (`fc-validation-ajustement.md:113`, couvert par l'annotation datée l. 381) et l'annotation elle-même. Aucune occurrence dans `tests/reference/`.
- Motif réel par `run_engine()` en reserve1 (`yt = 0.7 xt`) : « … point d)). Verifier que y_t est observe (C(1)(a)) … », sans la phrase.

**2. Code ↔ documentation, mesuré sur le moteur gelé, voie de repli seule**
- Colonne `t="b"` : lue « TRUE »/« FALSE », puis refusée. Conforme au `.tex` l. 4733-4736 et au README.
- Deux cellules de référence `C4` : la dernière l'emporte (`yt[3] = 999`, `ok = TRUE`), sans message. Conforme au `.tex` l. 4704-4706.
- Indice partagé 5 dans une table d'une seule chaîne : cellule lue `NA`, puis refusée. Conforme (#575).
- Table des chaînes en UTF-8 invalide : aucune chaîne lue, refus en aval, sans valeur fausse. Conforme au `.tex` l. 4691-4694.
- Colonne logique passée à `engine_lire_donnees_csv()` : `ok = TRUE`, `yt = 1 0 1 1 0 1 1 1` ; dans `engine_lire_triangle()`, lue 1. Conforme aux lignes d'inventaire l. 833-836 et 881. L'application lit le CSV en `colClasses = "character"` (`app.R:280`).
- `engine_empreinte()` (`R/engine.R:9144-9188`) conforme au `.tex` l. 4709-4714 ; table « Empreintes » : `R/display_helpers.R:3263`.
- `engine_valider_serie_retenue()` (`R/engine.R:9431-9464`) conforme à l'inventaire l. 749-755.
- E-L1-1 : `ANNEXE_II$np_standard` (`R/engine.R:98`) vaut 0,8 pour les segments 1, 4 et 5, sans condition. Conforme à `sec:segments`.
- `sec:graines` : chiffres concordants avec le relevé de l'étape 3 (3,454e-08, 4,545e-16, 8 sur 18 725, 1,814e-6 et 1,779e-6) ; écarts absolus recalculés à 2,87e-8 et 4,23e-9.
- « Un troisième appui » (`sec:mw`) cohérent.
- `CONTEXT.md`, « Refus motivé » : classes et sites d'appel de `.refus_lecture()` concordants.

**3. Messages de commit et PR**
- Mots-clés de fermeture : trois faux positifs seulement (« préfixées », « fixée par l'art. 2 », « R45 close (PR #577 »).
- Corps de la PR #578 : trois lignes `Closes #548`, `Closes #559`, `Closes #573`, une par ligne.
- Préfixes conformes (sauf le BOM, m-3). 34 commits d'auteur `Claude <noreply@anthropic.com>` avec `Co-Authored-By` ; 18 portent `Claude-Session`, les autres viennent de la session du poste.

**4. Traçabilité des constats de l'étape 4 et suivantes**
- Audit (ii) : M1 → #579 ; m1 → commentaire sur #574 ; m2 et m3 → #580. Audit (i) : → #581. `app-review` : M1 → #582 ; mineurs → #583 et #584. `regulatory` : #585, #586, #587. Étape 3 → #588 ; `moteur.md` → #589 ; `comparer_references.R` → #590.
- Aucun constat ouvert sans issue ni trace dans la documentation.

## Vérifications exécutées (sous `LC_ALL=C.UTF-8`, R 4.3.3, sans `openxlsx`)

| Vérification | Résultat |
|---|---|
| `Rscript tests/test_unitaires.R` | **3815 / 3815 ok**, rc 0 |
| `Rscript tests/test_reproductibilite.R` | **OK, 6 cas CONFORMES**, écart maximal 0 ; σ_USP 0,1114524114 / 0,1073524114 / 0,0497764613 / 0,1483524114 / 0,1032524114 / 0,0871308679 |
| `Rscript tests/unitaires/test_controles_entree.R` (isolé) | 428 / 428 ok |
| `Rscript tests/concordance_doc_moteur.R --strict` | **0 écart** |
| `Rscript tests/controle_doc_nd.R --bloquant` | **non exécutable ici** (`.aux` et `.log` absents, pas de `pdflatex`) ; mode avertissement : 0 occurrence de la liste A, 0 violation de plafond |
| `git diff a2f9c3a HEAD -- R/ app.R DESCRIPTION tests/` | vide |

**Non mesuré par moi** : le chemin `openxlsx` (non installé dans mon environnement) — colonne booléenne lue 1 et 0, arrêt du processus (#575), erreur R d'`openxlsx` 4.2.9 sur une table en UTF-8 invalide, « la dernière l'emporte » sous `openxlsx`. Ces points reposent sur les mesures de `fa2918d`, de l'étape 2 et de l'audit (ii). Ni la compilation du PDF ni les mesures du poste Windows n'ont été rejouées.

## Questions pour `actuary`
Aucune.
