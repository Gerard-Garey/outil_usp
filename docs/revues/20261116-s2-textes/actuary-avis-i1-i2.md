<!-- Rapport de l'agent actuary (routine), branche S2, avis sur les interpretations I-1 et I-2 de la lecture amont de regulatory, 16/11/2026, verse integralement par la session principale. -->

# Avis actuary : interprétations I-1 et I-2 de la lecture amont de `regulatory` (branche S2, PR #596)

Je n'ai rien écrit dans le dépôt et créé aucune issue. J'ai lu `/home/user/outil_usp/docs/revues/20261116-s2-textes/regulatory-lecture-amont.md` en entier, en particulier les § 1.2, 2.2, 2.3 et 4. J'ai relu aussi :
- la prose de l'annexe XVII, A(1), B(1), B(3), D(2) et D(3), et celle de l'art. 219(1), extraites du XHTML consolidé ; c'est de la prose, pas des formules ;
- dans `docs/latex/doc_tests_usp.tex` : les notations (l. 3446-3456 et 3712-3724), la lecture de A(1)(b) déjà écrite dans le document (l. 4061-4081) et la liste « Exigences de données non vérifiables » (l. 5512-5536) ;
- dans `R/engine.R` : `engine_valider_donnees()` (l. 10943) et `mw_valider_triangle()` (l. 11977), pour savoir ce que l'outil contrôle réellement.

## I-1 : repère temporel de B(1)(a)

**Mon avis : c'est la lecture (ii) qu'il faut retenir.** y_t, ce sont les paiements faits pendant l'année d'accident t, plus la meilleure estimation de la provision pour ces sinistres établie à la fin de cette même année. Je ne suis donc pas d'accord avec `regulatory`, qui juge la lecture (i) « la plus naturelle » (§ 2.3). Quatre arguments.

1. **Le texte, lu avec A(1)(b).** A(1)(b) définit l'« année de développement » comme « la différence entre l'année de ce paiement et l'année de l'accident auquel il correspond ».
   - Les paiements faits pendant l'année d'accident relèvent donc de l'année de développement 0, qui est la *première* année de développement.
   - Le `.tex` le dit déjà pour la section D (l. 4076-4081). La section D numérote d'ailleurs à partir de 0 : D(3)(a) fait commencer les années d'accident à 0, et D(5) écrit « j = 0,…, (J – 2) ».
   - La lecture (i) oblige à ne pas compter l'année d'accident comme une année de développement, ce qui contredit A(1)(b). Il faut alors comprendre « suivant » comme « qui suit », alors que le mot peut aussi vouloir dire « relative à ».
2. **La version anglaise, citée dans la question 2580 de la base de questions-réponses de l'EIOPA**, ne laisse pas cette ambiguïté : « after the first development year of the accident year of those claims ». Je n'ai pas vérifié ce texte sur le JOUE en anglais.
3. **La réponse de l'EIOPA à cette question 2580** (statut « Final », question déposée le 13.02.2023) suit la lecture (ii). Je l'ai lue en trois fragments consécutifs : « The aggregated losses referred to in Annex XVII B.(1)(a) DR for a given year t » / « should be equal to the claims paid during year t plus the best estimate of the claims outstanding » / « at the year end of the first development year of the accident year t. »
   - « Claims paid during year t » vise la seule année d'accident. Si la provision était prise à la fin de t+1, les paiements de t+1 manqueraient : la réponse ne serait pas cohérente avec la lecture (i).
   - À ma connaissance, ces questions-réponses ne sont pas juridiquement contraignantes. Je ne l'ai pas vérifié ici.
4. **Le fond actuariel.** Le risque de primes est la variation, sur un an, de la charge des sinistres qui surviendront dans les douze mois à venir (B(2)(a)). Au bout de cet horizon, cette charge vaut les paiements de l'année plus la meilleure estimation de clôture : c'est la lecture (ii).
   - La lecture (i) ajoute une année de liquidation de la provision. Or cette liquidation relève du risque de réserve, que mesurent les sections C et D.
   - Elle mélangerait donc les deux risques et compterait deux fois la première année de liquidation.
   - Hypothèse non vérifiée : cela gonflerait en général la volatilité de y_t/x_t.

**En pratique (triangles annuels, première diagonale)**
- Avec la lecture (ii), on prend dans chaque triangle par année d'accident la colonne « 12 mois », soit l'année de développement 0, comme dans le S.19.01. L'année d'accident la plus récente, celle qui se clôt à la date de référence, est utilisable dès que sa meilleure estimation de clôture existe.
- Avec la lecture (i), cette dernière année n'est pas disponible : pour obtenir T = 8, il faut neuf années d'accident closes. À historique égal, T baisse d'une unité, ce qui joue à la fois sur √((T+1)/(T−1)) et sur la crédibilité de la section G.
- **Dans les deux lectures**, la meilleure estimation à retenir est celle *établie à la date historique*, et non une réestimation actuelle. Prendre la charge ultime vue d'aujourd'hui (la diagonale courante) fausserait y_t. C'est l'erreur de données la plus probable. Elle impose d'archiver les meilleures estimations par année d'accident à chaque clôture, ce qui peut être difficile pour les années anciennes ; c'est à l'entreprise de le traiter.
- Si les triangles sont trimestriels, il faut les agréger en années d'accident civiles et lire la colonne à 12 mois.

**Recommandation (a)**
- Citer B(1)(a) mot pour mot, comme le propose `regulatory`.
- **Y ajouter la lecture retenue par l'outil, (ii), présentée comme telle**, avec ses appuis : A(1)(b), la numérotation de la section D et la réponse de l'EIOPA à la question 2580.
- Ajouter le contenu de y_t à la liste « Exigences de données non vérifiables ».

**Options écartées**
- **(b) Citation seule, sans lecture** (recommandation de `regulatory`). Le dossier resterait muet sur la donnée d'entrée qui pèse le plus sur σ̂ : le contrôleur poserait la question et chaque entreprise trancherait sans le dire.
- **(c) Retenir la lecture (i).** Elle contredit A(1)(b) et la réponse de l'EIOPA, et mélange risque de primes et risque de réserve.
- **(d) Laisser le choix à l'entreprise.** Deux séries y_t différentes donneraient deux σ_USP pour les mêmes sinistres, sans règle commune.

**Effet sur le dossier ACPR**
- Aucun changement de calcul ni de résultat de référence : le moteur ne voit que les montants fournis.
- En revanche, la lecture retenue détermine les séries que l'entreprise fournit, donc son σ_USP. Le dossier doit afficher cette lecture comme une interprétation de l'outil, non comme la lettre du texte.
- Le mainteneur tranche (CLAUDE.md).

**Texte proposé à `docwriter` (étape 6), après décision du mainteneur**, à placer dans les notations (l. 3452) ou à l'endroit que la grille impose :

```latex
Les pertes agrégées $y_t$ sont, selon B(1)(a), «~les paiements effectués et les meilleures
estimations de la provision pour sinistres à payer dans le segment~$s$ après la première année de
développement suivant l'année d'accident de ces sinistres (pertes agrégées)~» (\emph{Journal
officiel} L~12 du 17.1.2015, p.~272). L'outil lit cette première année de développement comme
l'année d'accident elle-même, numérotée~0 par A(1)(b), qui définit l'année de développement d'un
paiement comme «~la différence entre l'année de ce paiement et l'année de l'accident auquel il
correspond~»~; c'est aussi la numérotation de la section~D (D(3), D(5)). $y_t$ est donc la somme
des paiements effectués pendant l'année d'accident~$t$ et de la meilleure estimation, établie à la
fin de cette année, de la provision pour les sinistres survenus pendant celle-ci~; une estimation
révisée ultérieurement n'en tient pas lieu. Cette lecture est celle de la réponse de l'EIOPA à la
question~2580 de sa base de questions-réponses, qui n'a pas de valeur juridique propre~; la lecture
qui situerait la mesure à la fin de l'année suivant l'année d'accident n'est pas retenue. Le moteur
ne voit que les montants fournis et n'en dépend pas~; le contenu de $y_t$ est à établir par
l'entreprise.
```

- Dans la liste des l. 5512-5536, ajouter : « B(1)(a) (pertes agrégées mesurées à la fin de l'année d'accident, meilleure estimation de cette date) ».
- Avant de citer la réponse de l'EIOPA, `docwriter` ou la session doit **la relire verbatim** et l'ajouter à `sec:biblio`. Mon extrait vient d'un outil de lecture qui reformule.

## I-2 : art. 219(1)(b)

**Mon avis : la lecture « l'outil n'en contrôle que la forme » est juste, à condition de dire ce que recouvre cette forme.**
- L'art. 219(1) distingue (b), « les données peuvent être intégrées aux méthodes standardisées », de (d), « toute autre exigence supplémentaire en matière de données nécessaire à l'utilisation de chaque méthode standard ». Le contenu relève de (a) et (d) ; (b) vise d'abord l'aptitude des données à entrer dans la méthode.
- Cette aptitude, l'outil la contrôle réellement. `engine_valider_donnees()` refuse une série incomplète, de longueurs inégales, hors du domaine numérique, ou qui ne compte pas assez d'années consécutives (B/C(2)(b)). `mw_valider_triangle()` refuse un triangle non recevable.
- Il ne peut pas vérifier que ce sont bien les montants de B(1), C(1) ou D(1), ni qu'ils sont indexés par année d'accident et non par année de souscription.

**Recommandation (a)** : garder la phrase de `regulatory` (§ 1.2), en précisant ce qui est contrôlé et ce qui ne l'est pas. Options écartées :
- « l'outil n'en contrôle rien » : ce serait une affirmation fausse du `.tex` sur le code (critère E5 de l'ADR 0018), puisque les contrôles de `sec:controles` existent ;
- « l'outil vérifie l'art. 219(1)(b) » : c'est trop dire. Le dossier laisserait croire que l'outil certifie que les données sont appropriées, alors qu'elles restent à la charge de l'entreprise.

**Effet sur le dossier** : aucun effet numérique. Le dossier situe correctement la frontière entre ce que l'outil contrôle et ce que l'entreprise doit démontrer.

**Texte proposé à `docwriter`** : remplacer le segment du point b) de la phrase du § 1.2 par :

```latex
les données peuvent être intégrées aux méthodes standardisées (paragraphe~1, point~b))~: l'outil
vérifie seulement que les séries ou le triangle fournis sont recevables par la méthode (contrôles
du §\ref{sec:controles}), non que leurs montants soient ceux que définissent B(1), C(1) ou D(1), ni
qu'ils soient indexés par année d'accident (B, D) ou par exercice (C)~;
```

Le reste de la phrase de `regulatory` (points c) et 2 a) à e), « 2009/13/CE ») est inchangé.

## Équivalence « année de survenance = année d'accident »

**Elle est juste, et sa limitation aux sections B et D aussi.**
- « Année de survenance » est le terme français courant pour l'année au cours de laquelle l'événement assuré s'est produit, ce qui correspond exactement à A(1)(a).
- La section C indexe des exercices (C(3)(a)), pas des années d'accident. Le `.tex` respecte déjà cette distinction (l. 448 « de survenance ou d'exercice », l. 14844).
- Précision utile : il faut écrire que l'année de survenance n'est **ni l'année de souscription ni l'année de déclaration** (A(1)(c)). Beaucoup de triangles français sont tenus par exercice de souscription (construction, réassurance acceptée). Une série tenue ainsi ne relève pas de B(1)(a) et modifie σ̂. La phrase d'équivalence peut l'ajouter en une incise.

---

## Retour

- **Statut** : `revue requise`. Les deux avis sont rendus, mais I-1 est une interprétation que le mainteneur tranche, et mon avis s'écarte de la préférence de `regulatory`.
- **Résultat** :
  - I-1 : lecture (ii), citation littérale plus lecture explicite de l'outil, texte ci-dessus.
  - I-2 : « forme seulement », précisée.
  - Équivalence survenance = accident : juste pour B et D, à compléter par l'exclusion des années de souscription et de déclaration.
- **Preuves vérifiées**
  - Prose de A(1)(a)-(b), B(1)(a), B(3)(a)-(d), D(2)(c)-(d), D(3)(a)-(d) et de l'art. 219(1)(a)-(e), extraite du XHTML consolidé (prose, pas formule ; `regulatory` a vérifié B(1)(a) sur l'image, p. 272).
  - `.tex` l. 3446-3456, 4061-4081, 5512-5536.
  - `R/engine.R` l. 10943 et suivantes, 11977.
  - Réponse de l'EIOPA à la question 2580 : https://www.eiopa.europa.eu/qa-regulation/questions-and-answers-database/2580_en (fragments cités ci-dessus).
- **Hypothèses**
  - La lecture (i) gonflerait en général la volatilité de y_t/x_t.
  - Les questions-réponses de l'EIOPA ne sont pas contraignantes.
- **Non vérifié**
  - Le texte anglais au JOUE : EUR-Lex est trop volumineux pour être lu, et `legislation.gov.uk` ne se résout pas dans la session ; il faut autoriser ce domaine dans les réglages réseau pour le consulter.
  - La réponse de l'EIOPA verbatim : je l'ai lue par un outil qui reformule, il faut la relire avant de la citer.
  - D'autres versions linguistiques (DE, IT).
- **Informations manquantes** : le JOUE en anglais, p. 272.
- **Décisions non résolues**
  - Le mainteneur : choix entre (i) et (ii) pour I-1, et choix entre lecture explicite et citation seule.
  - Le mainteneur : autoriser ou non la citation de la réponse de l'EIOPA dans le `.tex` et dans `sec:biblio`.
- **Critères déclenchés (§ 4)**
  - Deux lectures d'une source (I-1). Ce n'est pas seulement un problème de documentation disponible : la version anglaise, si elle est confirmée, lèverait l'ambiguïté.
  - Désaccord avec un autre expert : `regulatory` préfère (i) et recommande la citation sans paraphrase ; je recommande (ii) avec une lecture explicite.
  - Aucun changement de résultat.
- **Constats hors périmètre**
  - Le `.tex` ne dit nulle part que les séries B et D sont par année de survenance et non de souscription (l. 3450 et liste l. 5512-5536). Mineur, critère « aucun » : c'est une lacune, pas une affirmation fausse ; rattachable à #586.
  - Le § 2.3 de `regulatory` présente la lecture (i) comme l'« année de développement 1 au sens de A(1)(b) ». C'est exact, mais cela ne fait pas d'elle la « première » année de développement au sens de A(1)(b). Mineur, critère « aucun » : c'est une remarque sur un rapport de revue, pas sur un livrable.
- **Prochaine action recommandée** : soumettre au mainteneur le choix I-1 (ii) contre (i), avec ce rapport et le § 2.3 de `regulatory`. Ensuite, relire verbatim la réponse de l'EIOPA à la question 2580 et, si possible, le JOUE en anglais p. 272. Enfin, transmettre les textes ci-dessus à `docwriter` pour l'étape 6.
