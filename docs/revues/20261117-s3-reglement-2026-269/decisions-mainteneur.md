# Décisions du mainteneur, S3 (règlement délégué (UE) 2026/269, #504)

## D2, 17/11/2026 : étendue et lectures

Source : réponses du mainteneur à la session principale, le 17/11/2026, après la lecture amont de `regulatory` (`regulatory-lecture-amont.md`) et l'avis d'`actuary-approfondi` (`actuary-avis-etape-2.md`, § 5, questions 1 à 9). Recommandation d'`actuary-approfondi` retenue sur chaque point.

| N° | Question (avis d'`actuary`, § 5) | Décision |
|---|---|---|
| D-S3-1 | Étendue (Q3) | **E-B** : extension au risque de primes. À date de référence ≥ 30.1.2027, facteur NP de 80 % (II-1, II-4, II-5) si une réassurance non proportionnelle est déclarée, 100 % sinon ; méthodes de réserve : déclaration d'une couverture pour développements défavorables (CDD) qualifiante ; si elle est présente, refus motivé (`ok = FALSE`, hors du domaine). E-C reportée. |
| D-S3-2 | Date qui fixe le texte applicable (Q1) | **R1-a** : la date de référence du SCR dans lequel σ_USP est employé ; même convention que la borne M6. Marquée *interprétation* dans la documentation. |
| D-S3-3 | Libellé de la déclaration NP (Q5) | **R2-b et R2-d** : « réassurance non proportionnelle couvrant ce segment, en place pour les douze mois suivant la date de référence et prise en compte comme technique d'atténuation du risque ». Marquée *interprétation*. |
| D-S3-4 | Paramètre de réserve avec CDD (Q6) | **R-3 laissée ouverte** dans S3 : refus motivé en présence d'une CDD qualifiante à date ≥ 30.1.2027 ; question consignée comme ouverte (préférence de fond d'`actuary` : R3-A). |
| D-S3-5 | Forme de la date (Q4) | **Date de référence obligatoire**, sans valeur par défaut, lue au format ISO fixe (`%Y-%m-%d`, indépendant de la locale) ; `Sys.Date()` exclu ; la règle date → texte vit dans le moteur seul. |
| D-S3-6 | Défaut de la déclaration NP (Q5) | Déclaration **obligatoire là où elle agit** (II-1, II-4, II-5, données nettes, date ≥ 30.1.2027), consignée ailleurs sans effet ; à défaut d'obligation, `FALSE` (100 %), jamais `TRUE`. |
| D-S3-7 | σ standard saisi avec CDD déclarée (Q7) | **Refus aussi** (règle de domaine unique). |
| D-S3-8 | Constat R1-c (Q2) | **Oui** : le dossier dit, sous forme de constat chiffré, qu'un σ_USP calculé selon l'ancien texte ne vaut pas tel quel pour un SCR à date ≥ 30.1.2027 ; la nécessité d'une nouvelle approbation reste hors de portée de l'outil. |
| D-S3-9 | Borne inférieure M6 (Q8) | **Oui** : la même date contrôle la borne M6 (#19) ; date antérieure à l'application de M6 → refus motivé. |
| D-S3-10 | Rapport figé (Q9) | **Oui** : la date de référence entre dans l'en-tête du rapport figé ; `docs/exigences.md` § 5.6 est modifié en conséquence. |

**Effet attendu** (avis d'`actuary`, § 3.2, *vérifié* par `run_engine()`) : à date ≥ 30.1.2027, données nettes sans réassurance NP, σ_USP +0,0082 (II-1), +0,00304 (II-4), +0,01148 (II-5), côté prudent ; aucune p-value ni aucun verdict touchés ; six cas de référence inchangés en valeur à date antérieure. **Visa du mainteneur** à donner sur le tableau avant / après du commit qui change le résultat (étape 5).
