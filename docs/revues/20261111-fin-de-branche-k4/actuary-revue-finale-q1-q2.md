# K4, revue finale (règle 10) : avis d'actuary sur deux questions de fond

Branche `claude/textes-du-moteur`, tête `c90e65a`, 11/11/2026. Aucun fichier du dépôt n'a été écrit. Les scripts de mesure sont dans le dossier de cet avis : `mesure_q1.R`, `repro_q2.R` et `essai_q2.R`. Le correctif de Q2 a été essayé sur une copie de la fonction chargée en mémoire, pas dans le dépôt.

## Q1. « puissance non mesuree a T = 8 » dans DETAIL_P_FAMILLE et DETAIL_P_GLOBALE

### Verdict : ce n'était pas voulu ; c'est un défaut mineur de ma spécification amont (§ 2)

J'ai repris la formule des fiches (« non mesurée à T = 8 », `fiche:p-famille` et `fiche:p-globale`, rubrique 6). Je n'ai pas tenu compte d'un fait : le `detail` s'imprime pour tout T (lognormale) et aussi pour `reserve2`. Dans `reserve2`, T n'est pas une dimension du résultat. La convention du document (« T = 8 » pour un triangle 8 × 8) ne se lit pas dans la table des tests.

Prise à la lettre, la phrase reste vraie : la puissance n'est mesurée nulle part. Mais elle induit le lecteur en erreur. Sur une série à T = 12, ou sur un triangle de taille quelconque, elle laisse entendre que la puissance a été mesurée ailleurs qu'à T = 8, ou que la réserve ne vaut qu'à T = 8.

D'autres phrases du moteur portent aussi « a T = 8 » (l. 6739, 7116, 7452, 7478). Elles rapportent un constat de simulation fait à T = 8 et le situent : leur portée est exacte pour tout T. Elles restent telles quelles.

### Formulations écartées

- **Gabarit « a T = %d »** : écarté.
  - La puissance n'est mesurée à aucun T. Le qualificatif n'apporte donc rien, et il suggère toujours qu'une mesure existe ailleurs.
  - En `reserve2`, il faudrait un argument propre à la méthode (nombre d'années du triangle ?) qui ne désigne pas la même chose.
  - Il ajouterait un nombre lié aux données dans un texte fixe et dans ses fixtures.
- **Formulation propre à Merz-Wüthrich** : inutile. La forme sans qualificatif est vraie pour les deux méthodes.

### Texte cible, mot pour mot

La seule modification est la suppression de « a T = 8 » dans chacun des deux gabarits. Elle a été vérifiée par `identical()` contre `sub(" a T = 8)", ")", ...)`.

```r
DETAIL_P_FAMILLE <- paste(
  "Diagnostic sans verdict : une p de famille faible signale qu'au moins une",
  "hypothese de la famille est mise en cause sous le modele ajuste (p plug-in non",
  "exacte), une p elevee n'atteste pas l'adequation (puissance non mesuree).",
  "Tests de la famille (cles mc_nom) : [%s], voir aussi \"p globale (minP, lecture",
  "conjointe de la batterie)\".")

DETAIL_P_GLOBALE <- paste(
  "Diagnostic sans verdict : une p globale faible signale qu'au moins une hypothese",
  "de la batterie est mise en cause sous le modele ajuste, compte tenu des %d tests",
  "et de leur dependance (p plug-in non exacte, sur les p Monte-Carlo et non les p",
  "retenues). Une p elevee n'atteste pas l'adequation du modele (puissance non",
  "mesuree), voir les lignes \"p de famille (minP, lecture conjointe)\".")
```

Les deux textes sont alignés sur le tableau 2 (`.tex` l. 7192 : « puissance non mesurée ») et sur la rubrique 6 de `fiche:p-globale` (l. 17865 : « (puissance non mesurée) »).

### Mesures (vérifié : `mesure_q1.R`, `texte_propre()` et `compter_phrases()` de `tests/unitaires/outils_unitaires.R`, sous LC_ALL=C.UTF-8)

| | Avant (phrases / caractères) | Après |
|---|---|---|
| Gabarit famille | 341 | 333 |
| Gabarit globale | 393 | 385 |
| Famille, 5 cas lognormaux (20 lignes) | 2 / 352 à 382 | 2 / 344 à 374 |
| Famille, `reserve2` (3 lignes) | 2 / 349 à 383 | 2 / 341 à 375 |
| Globale, 6 cas | 2 / 393 | 2 / 385 |
| Globale à k = 99 | 2 / 393 | 2 / 385 |
| Pire famille théorique (B. à six membres) | 2 / 390 | 2 / 382 |

La règle #514 est tenue partout. La marge de la ligne globale passe de 7 à 15 caractères.

### Le .tex doit-il suivre ?

- **Oui, pour les citations à la lettre** : texte T-1 et texte T-2 en tête de section, l. 17620-17633 à `c90e65a` (et non 17553-17563). Le fragment « \code{mesuree a} \code{T = 8).} » devient « \code{mesuree).} » dans T-1. Le fragment « \code{mesuree a} \code{T = 8), voir} » devient « \code{mesuree), voir} » dans T-2.
- **Non, pour les fiches** : la rubrique 6 de `fiche:p-famille` et celle de `fiche:p-globale` (« Puissance : non mesurée à T = 8 (travail postérieur à la remise) ») restent telles quelles. Le document a T = 8 pour cadre (triangle 8 × 8 pour Merz-Wüthrich), et la phrase renvoie à un programme de mesure à T = 8.

### Références (vérifié par readRDS)

Le fragment « mesuree a T = 8 » figure dans 29 lignes : 5 dans chacun des cinq cas lognormaux, 4 dans `reserve2`. Il faut un patch non numérique du champ `detail` (`tests/patcher_reference.R`). Aucune p-value, aucun verdict ni σ_USP ne change : ces lignes sont des diagnostics INFO.

## Q2. Motif AJ-04 quand aucune fonction du moteur n'est dans la pile

### Constat (vérifié : `repro_q2.R`)

Le défaut est reproduit. Le motif affirme « du moteur » pour des fonctions qui n'en sont pas :
- `stats::lm(y~x, data=data.frame(x=1))` donne « dans la fonction eval() du moteur » ;
- `vapply(1:2, function(i) stop("x"), 1)` donne « dans la fonction FUN() du moteur » ;
- `data.frame(a=1:2, b=1:3)` donne « dans la fonction data.frame() du moteur ».

Le dernier cas peut se produire en production. L'expression protégée est évaluée dans le cadre de `run_engine()` ou de `.run_engine_mw()`, et elle appelle directement `data.frame()`, des fonctions de stats et des `vapply()` anonymes.

Le défaut touche aussi le champ `erreur_r$origine`, et il est antérieur à #527. Le `.tex` (sec:controles, l. ~3910-3912) et `CONTEXT.md` (entrée « Défaut de calcul intercepté », l. 198) définissent `origine` comme la « dernière fonction de cette pile définie dans le moteur ». Le code, lui, se replie sur le dernier cadre de la pile, quel qu'il soit : la documentation ne dit pas ce que fait le code.

### Verdict : pas de troisième forme du motif ; aligner `origine` sur sa définition documentée

Formulations écartées :
- **« de R »** : fausse pour `FUN` (fonction anonyme d'un `vapply()`), pour « (fonction anonyme) » et pour une fonction d'un autre paquet ;
- **sans qualificatif** : imprime « FUN() » ou « (fonction anonyme)() », sans valeur pour rapporter le défaut, et nomme « fonction d'origine » ce qui n'en est pas une au sens documenté.

La forme neutre existante est vraie dans tous les cas. Le diagnostic complet reste dans `validation$erreur_r$pile`, dont le dernier élément est le cadre fautif.

**Texte cible pour ce cas**, déjà produit par le moteur sans origine, inchangé mot pour mot :

`Defaut de calcul intercepte : aucun resultat n'est produit ; diagnostic technique dans le champ validation$erreur_r du resultat.`

**Code cible** (`R/engine.R`, gestionnaire `error` de `.engine_calcul_protege()`, ~l. 13484-13485) :

```r
      origine <- if (any(du_moteur)) pile[max(which(du_moteur))] else NA_character_
```

au lieu de

```r
      origine <- if (any(du_moteur)) pile[max(which(du_moteur))]
                 else if (length(pile)) pile[length(pile)] else NA_character_
```

La construction du motif ne change pas. Le commentaire « sans origine, le motif ne nomme rien » devient exact. Il reste à préciser dans le commentaire du code : « origine : derniere fonction du moteur de la pile ; aucune (NA) si la pile n'en contient pas, la pile restant dans erreur_r ».

Le correctif a été essayé sur une copie en mémoire (`essai_q2.R`, vérifié) :
- les cas `lm`, `vapply`, `data.frame` et `stop()` donnent le motif neutre, avec `origine` à NA et la pile conservée ;
- `usp_ajuster(c(1,2,3), "a")` garde « dans la fonction usp_ajuster() du moteur ».

### Le .tex doit-il citer une troisième forme ?

Non. Avec ce correctif, le `.tex` (l. ~3907-3913) est exact sans modification : deux formes, la seconde « sans fonction d'origine identifiée », et `origine` défini comme dernière fonction de la pile définie dans le moteur. `CONTEXT.md` l. 198 est exact sur `origine`. Il cite toujours l'ancien motif « (erreur R dans f()) » : c'est le point Q-E de l'avis amont, renvoyé à `architect`, toujours ouvert à `c90e65a`.

### Références (vérifié par readRDS)

Aucune des six références ne contient « Defaut de calcul » (0 occurrence ; ce sont des résultats `ok = TRUE`, et `generer_references.R` refuse `ok = FALSE`). Aucun patch n'est nécessaire.

L'application écrit « origine : NA » au seul journal (`app.R:859`), jamais à l'écran. L'interface ne change pas.

## Fichiers à toucher

| Fichier | Q1 | Q2 |
|---|---|---|
| `R/engine.R` | deux gabarits l. 4974-4993 et commentaires (393 → 385, marge 15 ; « sans qualificatif de T : texte imprime pour tout T et pour reserve2 ») | une ligne l. ~13484-13485 et commentaire |
| `tests/unitaires/test_p_famille.R` | l. 175-181 (texte complet de DETAIL_P_GLOBALE) et l. 186 (fragment « (puissance non mesuree). Tests ») | — |
| `tests/unitaires/test_controles_entree.R` | — | un test : `.engine_calcul_protege("premium", Sys.time(), list(ok = TRUE, erreurs = character(0)), data.frame(a = 1:2, b = 1:3))` donne `origine` identique à `NA_character_`, `"data.frame" %in% pile` et le motif neutre complet (cas déterministe, base R) |
| `tests/reference/*.rds` | patch non numérique, 29 champs `detail` (`tests/patcher_reference.R`) | aucun |
| `docs/latex/doc_tests_usp.tex` | citations T-1 et T-2, l. 17620-17633 seulement (`docwriter`, commit `docs:` Refs #506) | aucun |
| `CONTEXT.md` | — | aucun (Q-E déjà renvoyée à `architect`) |
| `docs/revues/20261111-avis-amont-k4/` | archive : ne pas réécrire ; verser le présent avis à côté | idem |

Commits suggérés :
- Q1 : un `moteur:` (Refs #506), avec le tableau avant / après non numérique (29 `detail`, aucune p-value, aucun verdict, aucun σ_USP), puis le `docs:` de `docwriter` (Refs #506) ;
- Q2 : un `moteur:` (Refs #527), sans changement de résultat.

`audit` revoit le diff. `app-review` n'est pas requis.
