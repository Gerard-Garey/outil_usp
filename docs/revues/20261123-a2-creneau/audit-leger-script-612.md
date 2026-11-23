# Audit léger du script de mesure de #612 (A2, étape 2)

*Rapport de l'agent `audit`, 23/11/2026. Il porte sur le commit `22ec8a9` (`tests/simulation_jm1_trapeze_t8.R`, md5 `b21d58c9…`). Versé par la session principale (Q-54-10), en synthèse fidèle.*

## Verdict

**Conforme avec réserves.** Aucun constat bloquant ni majeur.

## Essai

`--essai` a été exécuté une fois (460 s, 4 processus). Il a fini sur `INTEGRITE ECHEC`, code 1.

- **Cause unique : le contrôle « (1) fin » sur le SHA.** Le commit `2b5afdb` a été fait sur la branche pendant l'exécution. C'est une détection correcte du script, pas un défaut du code.
- **Les 22 autres contrôles sont OK** : (a) à tol = 0, (v0) et (v2) 13/13 × 6, (r567) 6/6, (al) 8/8 et 8/8, (rep) 24/24.
- **Nettoyage** : dossier temporaire supprimé, arbre propre.

## Points vérifiés

- **Écritures.** Le script écrit seulement dans `tempfile()`, dans le dossier de travail (refusé s'il est sous le dépôt) et dans `docs/tableaux/`. Cette dernière écriture exige cinq conditions : `--ecrire`, INTEGRITE OK, aucun chemin absolu, commit propre revérifié, `garde_ecrasement()`.
- **Substitutions.** Elles sont faites dans `environment(run_engine)` seulement, avec `on.exit` et `identical()`. Elles sont aussi vérifiées dans les fils.
- **Tirages.** Tous passent par `engine_sous_graine()`, avec les graines du § 6, sans collision.
- **Reprise.** L'écriture des tranches est atomique. Le contexte, l'en-tête, la ligne `#FIN` et les identifiants sont contrôlés : ni double comptage ni perte.
- **Parallélisme.** Les graines sont fixées par ligne, et (rep) 24/24 est recalculé hors groupe.
- **Encodage.** ASCII.
- **Dix écarts déclarés.** Ils sont codés comme annoncés.

## Constats mineurs

1. **Code de sortie et dernière ligne discordants sous `--ecrire`** (l. 2194-2212). Un refus d'écriture sort en code 1, mais la dernière ligne reste `INTEGRITE OK`.
2. **En-tête inexact** (l. 104-105). Une sortie en code 1 par refus d'option ou par erreur R ne finit pas par `INTEGRITE ECHEC`, contrairement à ce qu'annonce l'en-tête. Les codes eux-mêmes sont justes.
3. **Ligne `[1] TRUE` parasite à la console** (l. 2178). Elle vient d'un `file.copy` laissé au premier niveau.
4. **Clé arbitraire** (l. 1943, colonne `cle_max` de la sonde). Quand tous les rapports valent 0, `which.max` désigne la première clé.

## Réserve opérationnelle pour l'étape 3

Le SHA fait partie du contexte des tranches. Tout commit sur la branche pendant un segment le fait échouer. Il fait aussi refuser le journal à la reprise du segment suivant.

La mesure doit donc tourner depuis un arbre figé au commit de mesure, par exemple un `git worktree` détaché.
