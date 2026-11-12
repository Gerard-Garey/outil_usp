# Synthèse : inventaire des redondances de la CI par `audit` (#561, 12/11/2026)

> *Rédigé par la session principale (IA).* Décision Q-60-6 (b) du 12/11/2026 : inventaire par `audit` pendant K3b, hors branche, **sans retrait** ; retraits éventuels après la remise. Rapport intégral : `audit-inventaire-redondances.md`. Mesure préalable : R43 (PR #562, table des durées des lots).

- **Redondance principale** : les six cas de référence (B = 999) sont recalculés dans quatre fichiers unitaires (`test_enveloppe_spread`, `test_incertitude_bootstrap`, `test_detail_deux_phrases`, `test_merz_wuthrich_suite`) alors que `test_reproductibilite.R` les compare déjà en entier ; environ 330 à 350 s CI cumulés.
- **Pas de redondance** dans la concordance `--strict` lancée par la CI et par `test_concordance_doc_moteur.R` (couvertures distinctes) ; aucune assertion littéralement dupliquée ; aucune réduction de B possible sans perte.
- **Redondances internes partielles** (mêmes `run_engine()` refaits dans un fichier) : `test_defauts_connus`, `test_merz_wuthrich` ; environ 40 à 70 s CI, mise en mémoire possible hors des blocs qui contrôlent le générateur.
- **Borne de la durée réelle** : le fichier le plus long de chaque lot (`test_application.R` 234 à 277 s, `test_merz_wuthrich_suite`, `test_p_mc_regime`). Seule la coupe de ces fichiers fait baisser le lot le plus long sous environ 280 s ; les autres gains économisent des minutes de runner.
- **Huit propositions classées** (gain / risque), de « retirer la comparaison aux références de `test_enveloppe_spread.R` » (environ 90 s, risque nul) à « mettre R en cache » (risque élevé, plateforme des références, M34).
- **Décisions du mainteneur, après la remise** : lecture des références (option A, contraire à l'intention de A2 dans `test_detail_deux_phrases.R`) ou cache commun des six cas (option B, recommandée) ; coupe des fichiers longs ; cache de R.
