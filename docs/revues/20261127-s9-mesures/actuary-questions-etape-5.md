# S9, étape 5 : réponses aux cinq questions de précision du mode `--familles` (#379, #494)

> *Rédigé par l'agent actuary (IA), fiche `actuary-approfondi`, le 27/11/2026, sur `claude/mesures-t8`. Diff lu au commit `c92b1bb` (`git diff 10cd9ca c92b1bb -- tests/puissance_t8.R tests/puissance_mw_t8.R`). Aucun fichier écrit. Marqueurs : [V] vérifié (lecture du code ou du tableau cité, ou raisonnement élémentaire donné ici), [H] hypothèse. Versé intégralement par la session principale (Q-54-10). La session confirme qu'aucune campagne n'a été exécutée et qu'aucun taux de l'étape 6 n'a été vu.*

Ces réponses ne touchent ni au périmètre, ni aux graines, ni aux R, ni à l'enveloppe adoptés (Q-S9-1 (a), Q-S9-2 (a)). Elles corrigent en revanche deux choix de test de mon avis (§ 4.5 et § 5.6), avant tout résultat de campagne. La session les trace dans `synthese.md` comme corrections de l'avis.

**Q1, graine de la matrice e : 20260931 confirmée. Code inchangé.**
- La campagne réutilise le volet B, et le volet B tire sa matrice e sous `--graine + 1` [V : `tirer_e(OPT_GRAINE + 1, OPT_R_CHAINE)` à `10cd9ca`]. Le « 20260930 » de mon § 5.4 désignait la valeur par défaut de `--graine` : c'était une imprécision, l'intention était bien de reprendre le volet B.
- `tirer_e()` remplit la matrice ligne par ligne (`byrow = TRUE`). Les 300 premières lignes sont donc celles du tirage à R = 500 de #274 [V]. Avec les graines de bootstrap `--graine-ic + 1000 b`, cela fonde le contrôle face à la chaîne réduite.

**Q2, lognormal : le McNemar exact apparié fonde la classe. Fisher est retiré. Le code change.**
- Les points d'une même réplication b sont des fonctions de la même ligne e_b et de la même graine de bootstrap. D'une réplication à l'autre, les paires sont i.i.d. [V].
- Fisher suppose deux échantillons indépendants :
  - si la corrélation intra-paire est positive, Fisher est conservateur ;
  - si elle est négative, il est libéral ;
  - rien ne garantit le signe ligne par ligne.
- McNemar teste P(10) = P(01), c'est-à-dire l'égalité des marges. Il reste exact quel que soit ce signe [V, élémentaire ; McNemar (1947), *Psychometrika* 12(2), 153-157].
- Modifications à faire dans `puissance_t8.R` :
  - paires = réplications b où la ligne est présente au point N et au point s ;
  - le McNemar bilatéral fixe la classe ;
  - le McNemar unilatéral π(s) < π(N) fixe le signal PM-3 ;
  - les colonnes Fisher disparaissent ;
  - la légende et l'en-tête sont mis à jour.

**Q3, CST20 et DCAL : Fisher fonde la classe. Les graines de #309 sont gardées. Le code change.**
- Les graines diffèrent de celles de P1.H0 (rangs 2 et 11, décalage 20 000) : les deux échantillons sont indépendants [V].
- Un McNemar apparié par l'indice b est exact, mais il a deux défauts :
  - son résultat dépend d'un appariement arbitraire : permuter les b le change ;
  - il n'utilise que 300 des 500 triangles de P1.H0.
- Le test exact de Fisher utilise tous les triangles de P1.H0 et ne dépend d'aucun appariement [V, élémentaire].
- Reprendre les graines de P1.H0 couplerait fortement DCAL, qui applique des incréments à `gen_triangle_h0()`. Mais cela perdrait le recoupement triangle par triangle avec `docs/tableaux/20261021-issue309-puissance-mw-brut.tsv` (colonnes `obs:*`, 1 000 lignes pour B-P1.CST20 et 500 pour B-P1.DCAL [V]) et contredirait le protocole adopté. Je ne le recommande pas.
- Modifications à faire dans `puissance_mw_t8.R`, quand le rang diffère de celui de P1.H0 :
  - le Fisher bilatéral fixe la classe ;
  - le Fisher unilatéral (`alternative = "less"`, cellule en première ligne) fixe le signal PM-3 ;
  - les colonnes McNemar affichent « — ».
- Pour les cellules à graines communes, rien ne change. `audit` vérifie l'orientation de n01 dans `mcnemar(d1, d2)`.

**Q4, dénominateur : validé. Code inchangé.**
- Le protocole compare p_f et U_f sur les mêmes membres et les mêmes réplications (§ 5.1). Quand la ligne est absente (k ≤ 1), U_f n'a pas de sens. Le choix n = lignes présentes, T-3b compté comme non-rejet, est donc le bon. C'est aussi la convention de T-F1 de #297 [V : colonnes « n (ligne présente) » et « abs. T-3b », légende « présente sans p si B effectif < 50 »].
- La convention diffère de T-F3 de #297, où le dénominateur est l'ensemble des réplications : à dire dans le rapport. La colonne des absences, déjà présente, permet de reconstituer le taux non conditionnel de p_f.

**Q5, comparaison du niveau à #297 : acceptable sous trois conditions. Code inchangé.**
- Les échantillons sont bien indépendants :
  - Merz-Wüthrich : graines de #297 à partir de 20 840 001, celles de #309 à partir de 32 000 001, plages disjointes [V] ;
  - lognormal : seules b = 1 et 2 partagent une graine de bootstrap avec les réplications b′ = 1 000 et 2 000 de #297, sur des jeux différents [V, arithmétique]. Dépendance négligeable [H].
- Conditions :
  1. m (Bonferroni) est fixé dès maintenant. Par méthode, m = nombre de triplets (jeu, ligne présente des deux côtés, familles et globale, α).
  2. Le calcul de l'étape 7 se fait par une commande versionnée citée avec sa sortie (`fisher.test` sur k et n de T-F1), jamais à la lecture.
  3. Pour Merz-Wüthrich, la référence est la loi N de #297. On suppose que son DGP (Mack ajusté à `reserve2`) est celui de P1 [H : à confirmer à l'étape 7].

**#494 : le McNemar apparié est le bon test, mais un second critère de PM-3 est à corriger.**
- AR(0,3) et AR(0,5) contre P1.H0, graines communes : oui [V]. Les paires sont les b admis dans les deux cellules où la ligne est présente. Les refus d'admission sont rapportés par cellule.
- **Correction du § 4.5, second cas de PM-3.** La cellule P1.H0 de S9 réutilise les graines de #309 pour b = 1..500 [V : `graine_tri_B()` et `graine_boot_B()`, rang 1]. Elle n'est donc pas indépendante du taux 0,087 de #309, mesuré sur b = 1..1000 : le test de Fisher y est invalide.
- À la place :
  - McNemar exact apparié sur b = 1..500 contre `p:CorrDev` du TSV brut de #309, versionné [V : 1 000 lignes B-P1.H0] ;
  - avec un contrôle que `obs:CorrDev` est identique, preuve que les triangles sont les mêmes.
- Ce calcul est à automatiser lors de l'intégration des cellules AR, ou à faire à l'étape 7 par une commande versionnée.

## Retour

- **Statut** : `complet`.
- **Résultat** :
  - Q1 confirmée et Q4 validée, sans changement de code ;
  - Q2 et Q3 : changements de code (McNemar pour le lognormal ; Fisher pour CST20 et DCAL) ;
  - Q5 acceptable sous trois conditions ;
  - #494 : McNemar confirmé, second cas de PM-3 du § 4.5 corrigé.
- **Preuves** :
  - *Vérifiées* : code aux commits `10cd9ca` et `c92b1bb` ; T-F1 et T-F3 de #297 ; TSV brut de #309 ; plages de graines ; raisonnements élémentaires ci-dessus ; référence McNemar (1947) retrouvée (https://link.springer.com/doi/10.1007/BF02295996).
  - *Hypothèses* : aucun résultat de campagne n'a été vu (confirmé par la session) ; P1 = loi N de #297 ; dépendance négligeable de b = 1 et 2.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune pour le mainteneur. Les corrections des § 4.5 et § 5.6 ne changent ni le périmètre ni l'enveloppe. Il peut s'y opposer s'il juge qu'elles modifient le protocole adopté.
- **Critères déclenchés** : correction d'un protocole adopté (choix des tests), à tracer par la session.
- **Constats hors périmètre** : aucun.
- **Prochaine action recommandée** : `coder-approfondi` applique Q2 et Q3, puis `audit` contrôle l'orientation des tests unilatéraux.
