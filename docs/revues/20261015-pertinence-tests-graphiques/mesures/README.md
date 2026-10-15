# Scripts de mesure de la revue du 15/10/2026

> *Rédigé par la session principale (IA).*

Ces scripts ont été écrits et exécutés par les six consultations d'`actuary-approfondi`, à `c645926`, dans le répertoire de travail de la session cloud. Ils sont versionnés ici **pour la traçabilité** des chiffres cités dans les rapports de bloc (`../bloc-N.md`) et dans le rapport consolidé. Leur statut est celui de constats de simulation hors CI :

- la session principale ne les a pas relancés, à l'exception des deux contrôles qu'elle cite dans le rapport consolidé (§ 1.4) ;
- seules modifications : les chemins absolus du dépôt et du répertoire de travail sont rendus relatifs ;
- ils se lancent depuis la racine du dépôt, sous `LC_ALL=C.UTF-8`, par `Rscript docs/revues/20261015-pertinence-tests-graphiques/mesures/bloc-N/<script>.R` ;
- avant toute citation d'un de leurs chiffres dans `docs/latex/doc_tests_usp.tex`, la mesure est à reprendre dans un script de `tests/`, avec ses graines, son commit et sa sortie datée sous `docs/tableaux/` (règle de #164).

Une sortie n'est conservée en fichier que lorsque l'agent l'a écrite ; sinon, elle est citée dans le rapport du bloc.

| Bloc | Script | Objet | Graine, taille | Sortie conservée |
|---|---|---|---|---|
| 1 | `bloc-1/refs.R` | lignes réelles de `premium`, `premium_interieur`, `reserve2` (types, natures, verdicts, p_min) | sans aléa | non (citée § 8 de `bloc-1.md`) |
| 2 | `bloc-2/verdicts.R` | lignes B et C des cinq cas lognormaux | sans aléa | non |
| 2 | `bloc-2/mesures1.R` | puissance exacte d'un F(4,4) ; énumération des 8! ordres (Mann-Kendall contre Spearman-temps) | sans aléa | non (§ 4.10 de `bloc-2.md`) |
| 2 | `bloc-2/mesures2.R` | puissance des six lignes H2 et de RESET sur les volumes de J1 | graines 1 à 5 et 7 ; R = 250 et 2 000 | non (§ 4.10) |
| 2 | `bloc-2/multiplicite.R` | taux familiaux d'ECHEC et d'ALERTE depuis les valeurs brutes de #166 | sans aléa | non (§ 4.10 (c)) |
| 3 | `bloc-3/sim_bloc3.R` | redondance et puissance des tests de normalité ; Bartels contre suites et Durbin-Watson | graine 20261015 ; R = 20 000, 5 000, 3 000 ; moins de 25 min | `sim_bloc3.out` |
| 4 | `bloc-4/verdicts.R`, `verdicts2.R` | lignes F et G, `plots_data` | sans aléa | non |
| 4 | `bloc-4/sim.R` | loi exacte de Grubbs et borne de Bonferroni ; niveau d'ESD ; puissance de sup-F, CUSUM, Grubbs ; lissage du spread-plot | graine 20261015 ; R = 100 000, 50 000, 20 000 | non (§ 4 de `bloc-4.md`) |
| 4 | `bloc-4/sim2.R` | détails des lignes F et G ; σ* par régime de δ̂* ; taux d'alerte familial | graine 1 ; R = 60 000 | non |
| 4 | `bloc-4/biais.R`, `biais2.R` | biais de la loi bootstrap de σ̂, intervalles percentile et basic | sans aléa | non (§ 4.8) |
| 5 | `bloc-5/mesures.R` | parts par colonne de la pente intra-colonne, effet minimal détectable de l'ordonnée, famille α, structure de Breusch-Pagan, vivier | sans aléa | non (§ 4 de `bloc-5.md`) |
| 5 | `bloc-5/bp_variante.R` | Breusch-Pagan à effets fixes de colonne, p Monte-Carlo par le bootstrap du moteur | graine 20260831 ; B = 999 | non (§ 4.7) |
| 5 | `bloc-5/puissance.R` | sonde de puissance M1-M2 (20 triangles par alternative) | graines 5001 à 5020 et 6001 à 6020 ; B = 199 ; 4,5 min | `puissance.txt` |
| 6 | `bloc-6/puissance_m3m4.R` | niveau et puissance des lignes M3-M4 sous six scénarios ; Rosner | graines 31 000 000 + … ; R = 60, B = 199 (arguments de la ligne de commande) | `puissance_sortie.txt`, `puissance_brut.tsv` |
