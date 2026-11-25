# Mesure de #617 (JS2, étape 2b)

Script de mesure de la question « la colonne J-1 dégénérée d'un trapèze reste-t-elle dégénérée dans les réplications de `mw_bootstrap()` ? » et de l'effet sur la famille Alpha.

- **Protocole** : `../actuary-1-protocole-617.md`. Le script suit son § 5 ; la règle de décision est celle de son § 4 (figée avant l'exécution, décision O1 du § 4.4 comprise). Rien n'y est réglé ailleurs.
- **Commande**, depuis la racine du dépôt :

  ```
  LC_ALL=C.UTF-8 Rscript docs/revues/20261125-js2-jalon/mesure-617/mesure_617.R > docs/revues/20261125-js2-jalon/mesure-617/sortie_mesure_617.txt 2>&1
  ```

  Options (défauts) : `--B=999`, `--graine=20260831`, `--triangles=T1,T2,T0`. Avec `--B` < 999, l'en-tête porte « ESSAI, NON VERSABLE ».
- **Montage** : moteur chargé par `charger_moteur()` (ADR 0016) ; deux crochets de lecture (`.mw_stats`, `.mw_tirer_triangle_valide`) posés dans `environment(run_engine)` pour la seule seconde exécution et retirés en toute circonstance ; aucun tirage hors de `mw_bootstrap()` ; aucun fichier de `R/`, `tests/` ni `app.R` modifié (contrôle I5 dans la sortie).
- **Sortie** : texte ASCII sans accents, `sortie_mesure_617.txt`, produite par la session principale après l'audit léger du script.
