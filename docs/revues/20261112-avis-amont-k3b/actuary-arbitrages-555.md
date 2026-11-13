# K3b, étape 8 (#555) : arbitrages d'`actuary` sur les choix non fixés

> *Avis de l'agent actuary (IA), fiche de base, le 12/11/2026, sur le diff non commité de #555 (commité ensuite en `21561e0`, avec la puce de commentaire replacée par la session).* Versé intégralement par la session principale (Refs #555).

**K3b, étape 8 (#555) : arbitrages d'`actuary` sur le diff non commité.** Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue.

Les six choix sont gardés. Les textes sont repris mot pour mot. Il reste deux réserves, sur le point 6 et sur un commentaire du moteur mal placé.

| Point | Décision | Texte ou précision |
|---|---|---|
| 1. V3 cite toutes les lignes qui portent une valeur répétée | **Garder** | Rien ne permet de dire quelle occurrence est fautive. Citer toutes les lignes en cause est plus juste que citer les « occurrences en trop », qui désignerait arbitrairement la seconde. Le texte « (ligne(s) de donnees %s) » convient tel quel. |
| 2. V4 cite la ligne k dont la valeur est inférieure à celle de k−1 | **Garder** | Le libellé « ligne(s) de donnees %s » est fixé : il exclut les paires, réservées à V5 (« entre les lignes »). La convention est déterministe. `docwriter` devra l'écrire au `.tex` : « ligne citée : celle dont la valeur est inférieure à celle de la ligne précédente ». |
| 3. Ordre du cumul : t en double, xt en double, yt en double, puis colonnes manquantes ; « Colonnes presentes » donne les noms reçus | **Garder** | Ma source ne fixait que le cumul. L'ordre suit les colonnes attendues t, xt, yt, puis la règle d'ensemble. Citer les noms avant renommage (`T, yt`) est correct : le message doit décrire le fichier de l'utilisateur, pas un état interne. |
| 4. H1 avec `i` + `" i "` : « i,  i » en CSV, « i, i » en classeur | **Garder** | Mon texte dit « en-tetes cites tels que recus ». Chaque lecteur cite ce qu'il reçoit (le lecteur du classeur retire déjà les blancs) et le refus est le même. La divergence ne porte que sur la citation, sans effet sur la décision. |
| 5. Colonne de nom NA qui porte les années (appel direct) : lue comme colonne de développement, d'où « Triangle non carre » | **Garder** | C'est l'application exacte de la décision 2 (NA = en-tête absent, jamais `i`). Le refus n'est pas silencieux et le cas ne se produit qu'en appel direct. Pas de motif dédié. |
| 6. Décision 10 : relecture de la première ligne non codée | **Garder, avec réserve** | La décision 10 est conditionnelle (« si openxlsx dédoublonne lui-même »). La condition étant mesurée fausse, il n'y a rien à coder. Mais la mesure n'est pas reproductible ici, et le test qui détecterait un changement n'est jamais exécuté (voir ci-dessous). |

**Réserve du point 6.**
- `openxlsx` n'est pas installé dans cette session (`requireNamespace` → `FALSE`).
- La CI n'installe que `shiny` et `plotly` (`.github/workflows/ci.yml` l. 222).
- Le test de parité est donc sauté partout, et ne détecterait rien en CI.
- À faire :
  - consigner dans le commit ou la PR la mesure du réalisateur (version 4.2.9, commande, sortie) ;
  - écrire dans la PR que la parité avec `openxlsx` repose sur cette seule mesure ;
  - faire rejouer la mesure par `audit` si le paquet devient disponible ;
  - rédiger une issue, à créer sur accord du mainteneur, pour installer `openxlsx` dans un lot de CI.

**Textes mot pour mot.** Les textes concordent avec mes sources : H1, V1 à V5, « t en double », « xt / yt en double », les quatre messages de lignes vides, « Colonne t : annees non consecutives », les deux commentaires du moteur (l. 7696 et suivantes, l. 7726 et suivantes) et les cinq sites de test (commentaire l. 1800, libellés et assertions l. 1983/1987 et l. 2032/2038). Le test `identical()` du message de la colonne `t` à trou est présent.

**Constat mineur à corriger par `coder`.** Dans l'en-tête de commentaire d'`engine_lire_donnees_csv()` (R/engine.R, vers l. 7703-7710), la nouvelle puce « - en-tetes (#555 …) » est insérée au milieu de la puce sur la colonne `t`. Du coup, « Sinon le fichier est refuse : aucun tri ni comblement silencieux » se rattache à la mauvaise puce. Il faut déplacer la nouvelle puce après « Les tests de la famille H3 supposent des annees equidistantes ; ». C'est un commentaire seulement, sans effet sur le calcul.

## Retour
- **Statut** : `complet`, sauf la parité avec `openxlsx`, que je n'ai pas pu mesurer (paquet absent).
- **Résultat** : points 1 à 5 gardés ; point 6 gardé avec réserve de traçabilité et de couverture en CI ; textes conformes mot pour mot ; un commentaire du moteur à replacer.
- **Preuves** :
  - *Vérifié, par lecture* :
    - `git diff -- R/engine.R tests/`, comparé à `actuary-textes-555.md` (§ 1.3 et § 2.2), `actuary-textes-555-colonne-t.md` (i), `actuary-avis-amont.md` (§ 6 et tableau V1-V4) et `decisions-mainteneur.md` (décisions 2, 5, 9, 10) ;
    - CI : seuls `shiny` et `plotly` sont installés (ci.yml l. 222).
  - *Vérifié, par mesure* :
    - `LC_ALL=C.UTF-8 Rscript tests/unitaires/test_controles_entree.R` → 391 assertions, 0 échec ;
    - chemin `openxlsx` sauté ;
    - `requireNamespace("openxlsx")` → `FALSE`.
  - *Non vérifié* : la mesure du réalisateur sur openxlsx 4.2.9 (doublons conservés).
- **Informations manquantes** : `openxlsx` absent, donc décision 10 et parité H1 non mesurées par moi.
- **Décisions non résolues** : faut-il installer `openxlsx` dans un lot de CI ? Issue à rédiger, création sur accord du mainteneur.
- **Critères déclenchés** : aucun changement de σ_USP, de p-value ni de verdict. Les changements de comportement hors références (fichiers jusqu'ici refusés désormais acceptés, doublons désormais refusés) sont déjà couverts par les décisions 7 à 10.
- **Prochaine action recommandée** : `coder` replace la puce de commentaire et trace la mesure openxlsx dans le commit ; puis `audit` sur le diff ; puis contrôle des textes par `regulatory` (décision 6) ; enfin, en fin de branche, `docwriter` reprend la convention de citation de V3 et V4.
