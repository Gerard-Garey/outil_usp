# Revue finale complète (règle 10) de K3b, `claude/registre-restes`

> *Rapport de l'agent audit (IA), effort `high`, revue finale (règle 10), tête `48f90cf`, le 12-13/11/2026.* Versé intégralement par la session principale (Refs #555).

**Verdict : conforme avec réserves.** Le code est correct et reproductible. Un constat **majeur** reste ouvert (C1) : il ne demande aucune reprise du code. Il porte sur la traçabilité et sur l'approbation d'un changement de résultat hors références. Il doit être levé avant la sortie du brouillon (décision 13 : « revue finale sans constat ouvert »).

**Périmètre**
- Tête revue : `48f90cf`. Base : `origin/main` `a7a2479`. Diff lu : `git diff origin/main...HEAD`, 25 fichiers.
- Le `main` local est périmé (`170737b`). `git diff main...HEAD` y montre à tort `app.R` et `tests/durees_unitaires.tsv`. Contre `origin/main`, ni `app.R` ni `R/display_helpers.R` ne sont touchés.
- Pendant la revue, la tête est passée à `77be237`. Les deux commits ajoutés (`cb4863e`, `77be237`) ne versent que des rapports dans `docs/revues/20261112-fin-de-branche-k3b/`, sans code.
- Je n'ai rien écrit dans le dépôt. Les batteries ont tourné sur une copie, `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/repo`. `git status` du dépôt : propre.

## Batteries (LC_ALL=C.UTF-8, copie à `48f90cf`)

| Script | Résultat |
|---|---|
| `tests/test_reproductibilite.R` | OK, 6 cas. `identical()` et références au seuil 1e-6 : 0 écart, écart maximal 0. σ_USP : premium 0,1114524114 ; reserve1 0,1073524114 ; reserve2 0,0497764613 ; premium_ii6 0,1483524114 ; premium_net 0,1032524114 ; premium_interieur 0,0871308679 |
| `tests/comparer_references.R --seuil 0` | 6 cas, 0 grandeur en écart, écart maximal 0. Références ni régénérées ni patchées (`tests/reference/` hors du diff) |
| `tests/test_unitaires.R --parallele`, sans openxlsx | 3777 / 3777, 0 échec, 0 succès inattendu |
| idem, avec `R_LIBS_USER=.../scratchpad/rlib` (openxlsx 4.2.9) | 3790 / 3790. Les 13 assertions de plus incluent le bloc classeur de #555 par openxlsx, qui n'est plus sauté |
| `tests/concordance_doc_moteur.R --strict` | BILAN : 0 écart |
| `tests/controle_doc_nd.R --bloquant` | 0 occurrence de la liste A, 0 fiche en violation, 0 débordement |
| Garde Q-A2, `tests/unitaires/test_non_applicable.R` | 25 / 25 (dont les l. 158-171) |

Ma relecture et la CI concordent. CI de `48f90cf` : 9 travaux `success` et le lot 2/3 en cours au moment du relevé. « PDF versionné » est `skipped` : l'étape 12 reste à faire.

## Constats

### C1 — majeur : changement de résultat hors références de #555 (en-tête `T` des séries) non tracé, et prémisse inexacte

- **Où** : `R/engine.R:8044-8061`, `engine_lire_donnees_csv()` (renommage en `t` de l'unique colonne d'en-tête `t`/`T` ou ` t `) ; message du commit `21561e0` ; corps de la PR #563.
- **Scénario** : un fichier de séries d'en-tête `T, xt, yt`, lignes dans le désordre. Avant K3b, la colonne `T` était ignorée et la série lue dans l'ordre du fichier. Elle est désormais triée par `T` (décision 8). Ce tri change des verdicts et, à profondeur réduite, σ_USP.
- **Mesures** (moteur `origin/main` contre moteur de la branche, chargés par `charger_moteur()`, CSV lu comme par l'application) :
  1. `T = 3,1,2,5,4,8,6,7` (`adv1.R` et `adv2.R`), `run_engine(premium, segment 1, B = 199, nature_donnees = "brutes")` :
     - σ_USP identique à T = 8 (0,1264065) ;
     - à `T = 6` : σ_USP **0,1280504 → 0,1193536**. Les années retenues ne sont plus les mêmes.
  2. S/P croissant avec t, fichier mélangé (`adv4.R`, B = 499) : σ_USP inchangé (0,1034113), **7 verdicts changent**. Exemples :
     - « Tendance monotone du ratio S/P » OK → ECHEC (p 0,588 → 0,004) ;
     - OLS-CUSUM OK → ECHEC (0,656 → 0,002) ;
     - sup-F OK → ECHEC (0,522 → 0,020) ;
     - les deux tests des suites OK → ALERTE.
  3. `T` à trou (2001, 2003, …) : `ok` TRUE → FALSE.
- **Pourquoi c'est un constat** :
  - Le commit `21561e0` affirme sans restriction « Aucun σ_USP, p-value ni verdict changé » et renvoie le tableau avant / après à la PR #563.
  - Le corps de la PR n'a que la ligne #537 et le statut « étapes 0 à 4 ». Les lignes de #555 manquent.
  - L'avis d'`actuary` qui fonde la décision 8 (`actuary-textes-555.md` l. 34 et 149) dit que « σ_USP ne bouge pas » : c'est faux dès que la profondeur T est inférieure au nombre d'années du fichier.
  - Le nouveau comportement est sans doute le bon (le fichier est enfin lu dans l'ordre de ses années). Mais `CLAUDE.md` soumet au mainteneur tout changement de σ_USP ou de verdict, avec son tableau.
- **Correction suggérée**, sans nouveau commit de code et sans réécriture de commit :
  - compléter le tableau avant / après de la PR avec les lignes de #555 et les deux mesures ci-dessus ;
  - faire confirmer la décision 8 par le mainteneur, en connaissance de l'effet sur σ_USP à profondeur réduite.
- **Qui tranche** : le mainteneur, sur avis d'`actuary`.

### C2 — mineur : message de #537 dépendant de `options(scipen)`

- **Où** : `R/engine.R:4701-4712`, `verifier_p()` d'`add()`.
- **Mesure** : sous `options(scipen = 100)`, le message dit `p_ex = -0.000000001` ; sous `scipen = 0`, il dit `p_ex = -1e-09` (Rscript, `charger_moteur()`). La valeur se relit à l'identique dans les deux cas : le message reste juste, mais son texte varie.
- **Suivi** : la session l'a déjà trié (constat 3 de `/code-review`, « corrigé dans la branche, commit `moteur:` de reprise »). Ce commit n'existe pas à `77be237`. Une fois fait, il doit être audité sur son diff (règle 10), avec un test sous `scipen` élevé.

### C3 — mineur : `.tex` l. ~4603-4607 (#555) inexact sur la batterie

- **Texte en cause** : « mesure faite hors de la batterie de tests, qui n'installe pas ce paquet ».
- **Mesure** : `tests/unitaires/test_controles_entree.R` contient un bloc #555 « classeur » qui exerce openxlsx s'il est installé. Il est sauté sans openxlsx (`[saute] colonne i et en-tetes en double (#555), chemin openxlsx`) et passe avec openxlsx 4.2.9 (3790 / 3790).
- **Correction suggérée** : écrire que la parité est contrôlée par la batterie quand openxlsx est installé, ce que la CI ne fait pas. À joindre au texte de la réserve m2 d'`actuary` (`actuary-validation-tex.md`), qui récrit déjà cette phrase.
- **Qui** : `docwriter`.

## Ce qui a été vérifié et tient

- **#535** (`R/engine.R:4925-4938`, `5008-5015`) : `rang` est posé dans les quatre branches de la hiérarchie. Entre le bloc et le contrôle de `nature_forcee`, seul `detail` change, jamais `p_ex`, `p_mc` ni `p_ret` : la cascade retirée est équivalente. Les trois rangs sont couverts par `test_registre_add.R` l. 161-172.
- **#536** (`R/engine.R:4236-4240`) : les trois sites sont équivalents octet pour octet à l'ancien code, y compris pour `detail` vide et `libelle_p_as` de longueur 0. La branche Q-A2 (`loi <- NA_character_`, l. 4760) compose toujours son propre texte, hors de l'aide.
- **#537** : la boucle 15:17 finit toujours sur une écriture qui se relit à l'identique. `decimal.mark = "."` neutralise `OutDec`.
- **#532** (`R/engine.R:7331-7356`) :
  - la garde `!is.finite(Runsr)` précède l'assertion ;
  - l'assertion est inatteignable avec un bootstrap cohérent : Z finie implique n1, n2 ≥ 1 et (n1, n2) ≠ (1, 1), et `runs_p_exacte()` est alors finie ;
  - le cas « un seul côté de la médiane » reste non applicable avec son motif (test l. 356-380).
- **#534** (`R/engine.R:2418-2431`) : `n < 20` reste testé en premier. `usp_tests()` est le seul appelant (l. 6898), sans chemin Merz-Wüthrich.
- **#555** :
  - `.entete_designe()` ignore les noms `NA` et non UTF-8 ;
  - le refus H1 passe avant `.retirer_lignes_colonnes_vides()` ;
  - les motifs V1/V2 se cumulent, V3/V4/V5 sont exclusifs ;
  - la sélection `%in%` ne propage plus de `NA` ;
  - le lecteur xlsx interne n'emploie plus `make.unique()`, et la conversion numérique va par indice. J'ai mesuré qu'un triangle à en-têtes de développement dupliqués (`i j j j j j j`) donne un triangle identique à l'ancien, et que des séries à `z, z` en trop sont acceptées ;
  - sondes sur la colonne `i` : `1.0`, ` 1`, `1e0` et le départ négatif sont acceptés ; `0x1` est refusé (V2).
- **Architecture** : tout reste dans `R/engine.R`, avec base, utils et stats seulement (`validUTF8`, `utils::head`). Aucun champ `usp_engine`, aucune entrée de catalogue, `GROUPES` inchangé. `app.R` transmet le tableau tel quel aux lecteurs.
- **Reproductibilité** : aucune source d'aléa nouvelle. Aucun nombre issu du bootstrap ou de l'optimiseur n'est ajouté à un `detail`. Les textes nouveaux sont des refus de lecture ou des messages d'erreur.
- **Code ↔ `.tex` ↔ tests** : concordance stricte à 0. Les textes des motifs de #555 sont vérifiés mot pour mot par les tests, et le `.tex` les décrit fidèlement, hors C3 et hors les réserves M1/M2 d'`actuary`.
- **Décisions 1 à 13** :
  - 1, 2, 4, 5 et 7 à 10 sont appliquées. Pour la décision 10, openxlsx 4.2.9 garde les doublons ; le test passe avec openxlsx.
  - 6 est appliquée : il ne reste aucune citation « (2)(b) … exige des annees consecutives » dans le diff.
  - 11 à 13 portent sur la conduite et restent à exécuter par la session.
- **Messages de commit** : aucun mot-clé de fermeture suivi d'un numéro dans `git log origin/main..HEAD --format=%B`. Le corps de PR a six lignes `Closes`, une par ligne. Auteur partout `Claude <noreply@anthropic.com>`. Un commit `moteur:` par issue, et chaque commit de code déclare 0 écart aux références.

## Restes à trier

**Dans le périmètre, avant la sortie du brouillon :**
1. C1 : tableau avant / après de #555 dans la PR, et confirmation du mainteneur.
2. Réserves majeures M1 et M2 d'`actuary` (`actuary-validation-tex.md`) à appliquer mot pour mot par `docwriter`, puis concordance `--strict` et `controle_doc_nd.R --bloquant` à rejouer.
3. Correctif `scipen` de #537 (C2), à auditer sur son diff.
4. C3, à joindre à la réserve m2 d'`actuary`.
5. Correctif `.tex` du constat 5 de `/code-review` (antécédent de « Ce dénominateur »), annoncé dans le tri de la session et non encore commité ; recoupe M2.
6. Commit du PDF (étape 12), cases de la fiche K3b, et corps de PR à jour : statut, contrôles, ligne d'escalade de cette revue.

**Hors périmètre, issues à rédiger** (création sur accord du mainteneur) :
- Message dédié pour des en-têtes en chiffres romains pris pour `I` (constat 1 de `/code-review`).
- Factoriser les listes de positions (`pos()` des colonnes `xt`/`yt`, « Colonne t incomplete » sans plafond) et les contrôles `t` / `i` (constats 7 et 8).
- Divergence CSV / classeur des blancs d'en-tête pour `xt`/`yt` (D3, déjà prévue après la remise).

## Questions pour `actuary`

1. **σ_USP selon l'ordre du fichier.** Ton avis disait que la vraisemblance ne dépend pas de l'ordre, donc que σ_USP ne bouge pas. Je mesure 0,1280504 → 0,1193536 à `T = 6` pour un fichier `T` mélangé, parce que les années retenues changent. Faut-il amender l'avis, et le mainteneur doit-il re-confirmer la décision 8 ?
2. **`b2_non_defini` à l'égalité exacte** (`all(z == z[1])`) plutôt qu'à `TOL_EX_AEQUO`. Le choix est confirmé (décision 4), sans effet à T = 8 puisque n < 20. Faut-il une mention dans la fiche, ou le statu quo suffit-il ? Constat 9 de `/code-review`, consigné par la session.

## Fichiers utiles
- `/home/user/outil_usp/R/engine.R` (l. 2418-2431, 4236-4256, 4701-4712, 4925-5015, 7331-7356, 7780-7860, 8018-8061, 8150-8200, 8869-8877)
- `/home/user/outil_usp/docs/revues/20261112-fin-de-branche-k3b/actuary-validation-tex.md`
- `/home/user/outil_usp/docs/revues/20261112-fin-de-branche-k3b/code-review.md`
- Journaux et scripts de mesure :
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/repro.log`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/cmp.log`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/unit_sans.log`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/unit_avec.log`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/conc.log`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/nd.log`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/adv1.R`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/adv2.R`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/adv3.R`
  - `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/adv4.R`
