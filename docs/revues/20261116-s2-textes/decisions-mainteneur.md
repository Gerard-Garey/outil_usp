# Branche S2 : décisions du mainteneur

Décisions prises le 16/11/2026 au soir sur les questions posées par la session principale (PR #596). Pour la phase et le plan, voir `docs/feuille-de-route.md` (soixante-quatrième point, E-16/11 (Q-64)).

| Code | Objet | Décision | Sources |
|---|---|---|---|
| D-S2-1 | **I-1, repère temporel de B(1)(a)** (#586) | **Lecture (ii)**, recommandée par `actuary` : y_t est la somme des paiements faits pendant l'année d'accident t et de la meilleure estimation de la provision pour ces sinistres, établie à la fin de cette même année (année de développement 0 au sens de A(1)(b)). Le `.tex` cite B(1)(a) mot pour mot, puis donne la lecture de l'outil, présentée comme telle. Le contenu de y_t s'ajoute à la liste « Exigences de données non vérifiables par l'outil ». Écartées : la citation seule (préférence de `regulatory`) et la lecture (i), fin de l'année t+1. | `regulatory-lecture-amont.md`, § 2.3 et § 4 ; `actuary-avis-i1-i2.md`, I-1 |
| D-S2-2 | **Réponse de l'EIOPA à la question 2580** | **Citée** dans le `.tex` comme appui de D-S2-1, avec la mention « sans valeur juridique propre », et ajoutée à `sec:biblio` après relecture mot pour mot (faite par la session, ci-dessous). | `actuary-avis-i1-i2.md` |
| D-S2-3 | **I-2, art. 219(1)(b)** (#585) | **Forme seule, précisée**. L'outil vérifie seulement que les séries ou le triangle fournis sont recevables par la méthode (contrôles de `sec:controles`). Il ne vérifie ni que leurs montants sont ceux que définissent B(1), C(1) ou D(1), ni leur indexation par année d'accident (B, D) ou par exercice (C). Texte d'`actuary`. | `regulatory-lecture-amont.md`, § 1.2 ; `actuary-avis-i1-i2.md`, I-2 |
| D-S2-4 | **R46 v3, hauteur de `mw_boot`** (PR #597, Refs #582) | **420 px**, comme `g_boot` et `mw_qq`. Un commit `app:` et son test sur la PR #597, revus sur leur diff. | revue légère d'`app-review` de la PR #597, m-1 |

## Relecture mot pour mot de la réponse de l'EIOPA (D-S2-2)

Relevé de la session principale, 16/11/2026, page `https://www.eiopa.europa.eu/qa-regulation/questions-and-answers-database/2580_en` téléchargée par `curl`, HTTP 200, réduite au texte (balises retirées) sans reformulation.

- Question ID : 2580. Regulation Reference : (EU) No 2015/35. Article : « Article 31; Annex XVII ». Status : Final. Date of submission : 13 Feb 2023.
- Question 1 : « Section B, paragraph 1(a) states: "the payments made and the best estimates of the provision for claims outstanding in segment s after the first development year of the accident year of those claims (aggregated losses)". Do those aggregated losses refer to the payments plus the best estimate of the provision for year of occurrence seen at the end of year zero of evolution? »
- EIOPA answer 1 : « The aggregated losses referred to in Annex XVII B.(1)(a) DR for a given year t should be equal to the claims paid during year t plus the best estimate of the claims outstanding at the year end of the first development year of the accident year t. »
- La même réponse porte une question 2 sur B(2)(f) : les frais inclus dans les pertes agrégées sont « all the expenses listed in Article 31(1), points (a) to (d) of DR ». Cette question est hors du périmètre de D-S2-1. Elle est relevée pour `docwriter`, sans décision.

Les fragments cités par `actuary` sont confirmés à la lettre.
