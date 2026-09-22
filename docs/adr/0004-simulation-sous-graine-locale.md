---
status: accepted
date: 2026-09-21
---

# Toute simulation s'exécute sous graine locale et restaure l'état du générateur ; aucun aléa hors calcul

## Contexte

Le moteur tire des nombres aléatoires en quatre endroits, avec quatre conventions incompatibles sur `.Random.seed` : `usp_bootstrap()` et `mw_bootstrap()` posent la graine reçue de `run_engine()` sans restaurer l'état ; `sw_loi_nulle()` pose une graine propre (20260901), met en cache et restaure l'état seulement s'il existait ; `engine_plots_data()` pose une graine fixe (20260831) sans restaurer ; `engine_lire_xlsx()` / `engine_ecrire_xlsx()` tirent un `runif()` sans graine pour nommer un dossier temporaire. La sous-section « Reproductibilité et gestion des graines » de la documentation décrit un seul de ces quatre cas (issue #1). Effets concrets (issue #4, piste 2) : l'état du générateur de l'appelant est écrasé par `run_engine()` ; le « nom aléatoire » du dossier xlsx est le même après chaque calcul, les dossiers ne sont jamais supprimés, et dans le repli sans `openxlsx` un `sharedStrings.xml` résiduel peut produire des libellés faux. La reproductibilité au bit près n'est pas en cause aujourd'hui, mais elle ne tient que parce que l'ordre des appels dans `run_engine()` est figé : toute nouvelle simulation (bootstrap restreint sous H0, issue #5) décalerait les flux existants si elle prenait place dans le même flux.

## Décision

1. **Une fonction unique** du moteur exécute une expression sous graine locale : elle sauvegarde `.Random.seed` de l'environnement global (ou note son absence), pose la graine, évalue, puis restaure l'état initial (ou retire `.Random.seed` s'il n'existait pas), y compris en cas d'erreur.
2. **Toute simulation passe par elle** : `usp_bootstrap()` et `mw_bootstrap()` (graine `seed` de `run_engine()`), `sw_loi_nulle()` (graine propre 20260901, cache conservé), `engine_plots_data()` (graine fixe actuelle, jusqu'à ce que l'enveloppe soit construite à partir des réplications du bootstrap, issue #5 chantier 6), et toute simulation future, avec une graine explicite qui lui est propre et qui figure dans `metadata`.
3. **Propriété garantie et testée** : `run_engine()` laisse l'état du générateur de l'appelant intact ; deux appels à paramètres égaux restent identiques au bit près quel que soit l'état du générateur avant l'appel.
4. **Aucun aléa hors calcul** : les fichiers et dossiers temporaires viennent de `tempfile()` et sont supprimés par `on.exit(unlink(…, recursive = TRUE))`.
5. La sous-section « Reproductibilité et gestion des graines » de la documentation est réécrite à partir de l'état final du code, avec la liste exhaustive des fonctions qui tirent, leur graine, leur portée et la restauration (issue #1) ; elle suit le code, jamais l'inverse.

## Considered Options

- **Une graine unique dérivée pour tout `run_engine()`** (un seul `set.seed()` en tête, chaque simulation consommant le flux à la suite) : écarté ; toute simulation ajoutée ou déplacée changerait toutes les p_mc, et `sw_loi_nulle()` (loi nulle indépendante du modèle, mise en cache) n'a aucune raison de dépendre de la graine du calcul.
- **Laisser chaque fonction gérer sa graine et documenter les quatre conventions** : écarté ; la documentation décrirait une fragilité au lieu d'une garantie, et l'état de l'appelant resterait écrasé.

## Conséquences

Résultats strictement inchangés : mêmes graines, mêmes flux à l'intérieur de chaque simulation ; critère d'acceptation : `tests/test_reproductibilite.R` vert sans régénération. Les deux échecs attendus « état du générateur » de `tests/unitaires/test_defauts_connus.R` deviennent des tests ordinaires. Une simulation ajoutée ensuite (bootstrap restreint, enveloppe du QQ-plot) n'affecte aucune p-value existante. `CLAUDE.md` (« Reproductibilité ») et la documentation LaTeX décrivent la règle unique au lieu des quatre cas. Issues : #1, #4 (piste 2), #5 (chantiers 2 et 6) ; feuille de route, jalon J2.
