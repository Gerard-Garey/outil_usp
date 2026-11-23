# Lecture de #608 — créneau A2, étape 1b

*Rapport de l'agent `audit` (fiche de base, lecture seule), 23/11/2026, sur `claude/creneau-a2` (`R/engine.R` identique à `main` `8d7bf2f`, md5 `0f8167e59e3507dd40bd8a87d122e189`). Versé par la session principale (Q-54-10).*

**Conclusion : conforme avec réserves.** Le code actuel résout la cible avant `setwd()`. Il ne reste qu'un cas ouvert : un dossier absent du lecteur de l'appelant mais présent sur celui de `tempdir()`. Ce cas dépend du repli de `normalizePath()`, non vérifié, et se mesure à l'étape W avec le script spécifié au § 3. Le commentaire de `engine.R:8950` est à corriger quel que soit le résultat de la mesure.

Sources lues :
- #608 et ses deux commentaires (tri du 19/11, relevé de S5 du 19/11) ;
- la fiche A2 de `docs/feuille-de-route.md` ;
- `R/engine.R`, lignes 8922 à 9040 et 9192 à 9312 ;
- `docs/revues/20261119-s5-rejeu-windows/rejeu_windows.R` (l. 103-143) et `sortie_rejeu.txt` (l. 26-32) ;
- `?normalizePath` (R 4.3.3).

## 1. Ordre réel entre résolution et `setwd()`

- **Vérifié par lecture : la cible est résolue avant `setwd()`.**
  - `engine.R:9218` : `cible <- .xlsx_chemin_sortie(chemin, getwd())`.
  - `engine.R:9221` : test `dir.exists(cible)`.
  - `engine.R:9290` : `setwd(d)`.
  - Sous Windows, `\d\f.xlsx` et `/d/f.xlsx` sont absolus pour `.xlsx_chemin_absolu()` (l. 8932). `normalizePath(dirname(...), winslash = "/", mustWork = FALSE)` est donc appelé pendant que le dossier courant est encore celui de l'appelant.
  - La phrase de l'issue « résolue après `setwd()` » ne décrit pas le code actuel.
- **Vérifié par lecture : le mécanisme de #608 reste possible à une condition**, que `normalizePath()` rende un chemin **sans lettre de lecteur**.
  - Après `setwd(d)`, `zip::zipr(cible, …)` ou `utils::zip(cible, …)` interpréteraient alors `cible` contre le lecteur de `tempdir()`.
  - La rubrique « Value » de `?normalizePath` l'admet : « If an input is not a real path the result is system-dependent […] It will be either the corresponding input element or a transformation of it into an absolute path. »
- **Hypothèse non vérifiée (source C de R non lue) sur le repli de R 3.6.** Ce repli enchaîne `GetFullPathName` puis `GetLongPathName`. Deux issues sont possibles quand `GetLongPathName` échoue :
  - il rend `Z:\d` : le constat n'est pas reproduit, et l'écriture échoue avec un refus annoncé ;
  - il rend l'entrée inchangée : le constat est reproduit.

## 2. Cas d'un chemin à barre initiale unique sous Windows (`/d/f.xlsx` ou `\d\f.xlsx`)

| `\d` sur le lecteur de l'appelant | sur celui de `tempdir()` | `normalizePath()` | Effet attendu | Couvert par S5 |
|---|---|---|---|---|
| présent | absent | `GetFinalPathNameByHandle` réussit : chemin complet avec lecteur | fichier sur le lecteur de l'appelant | **oui** (l. 28, 30) |
| présent | présent | idem | idem | **oui** (l. 29, 31) |
| absent | absent | échec, puis repli R 3.6 : `Z:/d` ou entrée inchangée | refus « Echec de la creation » dans les deux cas | non |
| absent | présent | échec, puis repli R 3.6 : **`Z:/d`, refus ; entrée inchangée, fichier écrit sur le lecteur de `tempdir()` (mécanisme de #608)** | **seul cas qui tranche** | **non** |

Statut de chaque ligne :
- **Lignes 1 et 2 : vérifiées** au poste par le relevé de S5.
- **Ligne 3 : hypothèse.**
  - Sous Linux, un dossier absent donne bien le refus `usp_refus_ecriture` (statut zip 15) : mesuré.
  - Le comportement de `zip::zipr` n'est pas vérifié, faute du paquet dans cette session.
- **Ligne 4 : non vérifiée.**

Pourquoi S5 n'a couvert que les lignes 1 et 2 : `dir.create(file.path("Z:/", nom))` (l. 125) précède les quatre essais. Le relevé de S5 n'a donc jamais essayé le cas où le dossier manque sur le lecteur de l'appelant.

Pour mesurer la ligne 4, un lecteur `subst` suffit *si* le repli se comporte sur un lecteur `subst` comme sur un lecteur physique (*hypothèse*).

La branche Windows de `.xlsx_chemin_sortie()` lit `.Platform$OS.type`, non un argument `systeme`. Le cas ne se simule donc pas sous Linux (*vérifié*, l. 8954).

## 3. Spécification du script de mesure (pour `coder`)

**Forme.** Script propre `docs/revues/20261123-a2-creneau/mesure_608.R`, et non une option de `rejeu_windows.R`, pour ne pas toucher un relevé déjà versé.
- Usage : `Rscript docs/revues/20261123-a2-creneau/mesure_608.R <racine du depot>`.
- Le moteur se charge par `charger_moteur()`.
- Hors Windows, le script affiche « sans objet » et s'arrête.

**Contexte imprimé :**
- `HEAD` ;
- `git diff --stat <main d'A2> HEAD -- R/engine.R`, qui doit être vide ;
- `R.version.string`, `getwd()`, `tempdir()` ;
- la présence du paquet `zip` et de la commande zip, et la voie prise.

**Sécurité :**
- Nom unique : `nom <- basename(tempfile("usp608_a2_"))`.
- `cible_t <- file.path(substr(tempdir(), 1, 2), nom)`. Si ce dossier existe déjà, abandon sans rien écrire.
- Lettre de lecteur libre choisie comme dans S5.
- `racine_virt <- tempfile("p608_")`.
- Les drapeaux `cree_cible_t` et `subst_pose` ne sont posés qu'après succès.
- `on.exit` est enregistré avant le `subst`. Il fait, dans l'ordre :
  1. `setwd(ancien)` ;
  2. `subst L: /D`, si `subst_pose` ;
  3. `unlink(racine_virt)` ;
  4. `unlink(cible_t)`, seulement si `cree_cible_t`.
- En fin de script : vérifier et imprimer que `L:` et `cible_t` n'existent plus.
- Aucune autre écriture que dans `racine_virt` et `cible_t`.

**Mesures**, après `setwd("L:/")`, **sans** créer `L:/<nom>` :
- **(a) Sonde pure, sans écriture.** Pour `\<nom>\f.xlsx` et `/<nom>/f.xlsx`, imprimer :
  - `normalizePath("/<nom>", winslash = "/", mustWork = FALSE)` ;
  - `.xlsx_chemin_sortie(chemin, getwd())` ;
  - si la cible commence par une lettre de lecteur, `grepl("^[A-Za-z]:", cible)`.
  - La sonde est faite deux fois : `cible_t` absent, puis `cible_t` créé.
- **(b) Écriture.** Avec `cible_t` créé, `engine_ecrire_xlsx(d, chemin)` sous `tryCatch`, avec `tests/donnees/donnees_ln.csv`, pour les deux chemins. Imprimer :
  - le rendu, ou la classe et le message de l'erreur ;
  - `file.exists` sur `L:/<nom>/f.xlsx` et sur `<cible_t>/f.xlsx`.
- **(c) Témoin d'effacement.** Déposer un `f.xlsx` témoin de contenu connu dans `cible_t` avant un nouvel appel. Imprimer s'il existe encore et si son md5 a changé. Motif : l. 9291, `unlink(cible)` après `setwd(d)`.
- **(d) Témoin négatif.** Mêmes appels avec `cible_t` absent : refus attendu.

**Ligne de lecture imprimée (règle Q-73-2 (a)) :**
- **REPRODUIT** si, pour l'un des deux chemins, l'une de ces conditions est vraie :
  - (a) donne une cible sans lettre de lecteur ;
  - un fichier apparaît dans `cible_t` ;
  - le témoin est effacé ou modifié.
- **NON REPRODUIT** si les trois conditions suivantes sont réunies :
  - (a) donne `L:/<nom>/f.xlsx` pour les deux chemins ;
  - (b) donne un refus `usp_refus_ecriture` pour les deux, sans fichier dans `cible_t` ;
  - (c) laisse le témoin intact.
- **INDÉTERMINÉ** sinon, avec le détail.

La lecture de S5 (« un fichier sur C: ou une erreur confirme le constat ») ne doit pas être reprise : une erreur y est le comportement *non reproduit*.

## 4. Autres défauts relevés (non triés)

**Dans le périmètre de #608 :**
- **(i) `engine.R:8950`, `.xlsx_chemin_sortie()`.** La phrase du commentaire « Le resultat ne depend pas de getwd() » est fausse sous Windows pour une barre initiale unique.
  - *Vérifié* par le relevé de S5 : la cible est résolue via `Z:`, qui est le `getwd()`.
  - À corriger dans les deux issues de la mesure.
- **(ii) `engine.R:9291`, `engine_ecrire_xlsx()`.** Si le constat est reproduit, `unlink(cible)`, exécuté après `setwd(d)`, effacerait un fichier existant sur le lecteur de `tempdir()`.
  - Même nature : `dir.exists(cible)` (l. 9221) est évalué avant `setwd()`, l'écriture après.
  - *Hypothèse* conditionnelle, mesurée par (c).
  - Le refus de l'étape 5 couvre les deux points.

**Hors périmètre, sans critère ADR 0018 :**
- **(iii) `engine.R:8959`.** `.xlsx_chemin_sortie("/f.xlsx")` rend `"//f.xlsx"` (mesuré sous Linux). Sous Windows, `"Z://f.xlsx"` est attendu (*hypothèse*). Mineur, cosmétique.
- **(iv) `engine.R:8954`.** La branche Windows de `.xlsx_chemin_sortie()` ne se teste que sous Windows (`test_controles_entree.R:7435`, conditionnel). Mineur, couverture.
- **(v) `rejeu_windows.R:141-142`.** La règle de lecture est inexacte pour l'erreur. Sans effet sur le relevé de S5. Mineur.

## Vérifications exécutées

- `gh api` sur #608 et ses commentaires.
- Lecture du code et du script de S5.
- Rubriques « Details » et « Value » de `?normalizePath`.
- Sous Linux (`LC_ALL=C.UTF-8`) :
  - `.xlsx_chemin_sortie("/f.xlsx")` rend `"//f.xlsx"` ;
  - `.xlsx_chemin_sortie("/nexistepas/f.xlsx")` rend l'entrée ;
  - écriture dans un dossier absent : `usp_refus_ecriture`, statut zip 15 ;
  - `.xlsx_defaut_chemin()` avec `systeme = "windows"` admet aujourd'hui `\d\f.xlsx`, `/d/f.xlsx` et l'UNC.
- Aucune batterie lancée : l'étape ne modifie pas de code.
