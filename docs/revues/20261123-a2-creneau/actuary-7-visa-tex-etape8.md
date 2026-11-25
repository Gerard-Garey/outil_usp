# Étape 8 d'A2 : visa du diff du `.tex` (`c99d708`, `ea3bcff`), 25/11/2026

> `actuary-approfondi`, consultation du 25/11/2026. Rapport versé intégralement par la session principale (Q-54-10). Les décisions du mainteneur qui ont suivi sont rappelées en fin de document.

## Verdict

**Refus en l'état, avec une reprise ciblée.** Il y a trois constats majeurs et six mineurs. La quasi-totalité des chiffres se retrouve bien dans le tableau de mesure ou dans le code ; les exceptions sont la borne 0,124 (m1) et la sélection du premier quartile (M2). Mais trois énoncés de fond sont contredits par ce tableau ou par le calcul. Le point supplémentaire de la session (K d'ExpVar) change le jugement de la spécification de #615 ; il est traité en dernière partie.

## Les six points soumis par `docwriter`

1. **« Mécanisme appuyé par une mesure appariée sous le plan » : accepté.** Le K2′ est significatif sur les quatre cellules après Holm (tableau, l. 165-170). La dépendance monotone de l'excès de V0 au rapport r va de +0,062 (Q1) à +0,013 (Q4) (l. 618-621). « Appuyé », et non « démontré », est la bonne force.
2. **+0,024 : le chiffre est exact, mais il ne soutient pas la phrase.** Il figure au tableau, l. 618 : V2 − T, Q1, 0,02400 [0,01634 ; 0,02728], 26 contre 2. Voir M2.
3. **Retrait des parts de la queue haute et de la borne de K4 : accepté**, sous réserve de m2. **Retrait de σ_A^vrai : non accepté tel quel**, une fois (iv) corrigé (voir M1).
4. **Justification de P1 placée en `sec:mw` : la place est bonne, le contenu non** (voir M3).
5. **Réserve sur K d'ExpVar : insuffisante.** Le sens de l'effet est connu (voir M3 et la dernière partie).
6. **« Marge fixée avant la mesure » : vérifié.** Le md5 du protocole, 70176c2e…, est identique à celui approuvé à PA-1 (contrôle (t), tableau l. 61). Alpha 8×6 E 0,10 passe K3 par la seconde branche : 0,0135 ≤ 0,0045 + 0,010.

## Constats majeurs

**M1. `.tex` l. 16101-16104 (encadré, (iv)) et l. 16233 : sous-couverture affirmée là où elle n'existe pas.**
- « nettement inférieure au nominal, comme sur le carré » et « La sous-couverture vient presque entière de la queue haute » sont faux pour la loi E sur 8×6 et 8×7. La non-couverture y vaut 0,109 [0,096 ; 0,123] et 0,094 [0,082 ; 0,108] : l'intervalle contient 0,10, la couverture est au nominal.
- L'ordre de grandeur n'est pas non plus « comme sur le carré ». Sur le carré, le percentile ne couvre que 0,573 et 0,617 (`.tex` l. 6694-6695), soit une non-couverture de 0,38 à 0,43, contre 0,09 à 0,35 ici.
- La cible pèse lourd sur 8×7. Contre σ_A^vrai, la non-couverture vaut 0,3625 (N) et 0,3345 (E) (tableau l. 229 et 231). Dire « proche du nominal » sans cette précision induirait en erreur.
- Correction proposée pour (iv) : « …mesurée sous le même plan sans résultat exact, est inférieure au nominal sous N sur les trois trapèzes et sous E sur 8×5, au nominal sous E sur 8×6 et 8×7 ; elle dépend de la cible (σ_A^vrai : 0,36 et 0,33 sur 8×7), et elle est insensible à la simulation de la colonne J−1 ».
- l. 16233 : remplacer par « La sous-couverture, là où elle existe, vient presque entière de la queue haute… », et retirer « comme sur le carré » ou le borner.

**M2. `.tex` l. 16203-16207 : le chiffre cité ne mesure pas le « reste ».**
- La phrase parle d'un reste par rapport au carré, et cite +0,024, qui est un excès par rapport au témoin. Or le carré a lui-même +0,011 dans Q1.
- Le lecteur qui consulte le tableau trouve aussi Q4 : V2 − T = +0,027, contre +0,013 sous V0 (l. 621). Sans le carré par quartile, rien n'y justifie de distinguer Q1, et V2 y paraît pire que V0. Le carré par quartile n'existe que par `strat.R`, non versionné ; ses chiffres sont recopiés dans `actuary-4`.
- Deux corrections possibles : (i) verser `strat.R` et sa sortie, et citer V2 − carré = +0,013 [0,007 ; 0,015] dans Q1 ; (ii) s'en tenir au tableau : « par quart du rapport (lecture descriptive faite après la mesure, N et E réunis, à 0,05), l'excès sur le témoin passe de +0,062 à +0,024 dans le premier quart et de +0,013 à +0,027 dans le dernier », sans parler de « reste ».

**M3. `.tex` l. 15825-15828 et l. 17790-17791 : la prémisse de P1 est fausse, et le sens de l'effet sur ExpVar est connu.**
- « les résidus d'une telle colonne n'y seraient qu'un bruit d'arrondi normé » est faux pour le mécanisme mesuré.
- Calcul simple en double précision : facteurs f(1+δ_i), dispersion relative de 5e-13 à 1e-11. Les écarts F − f̂ y gardent une erreur relative de 1,9e-4 à 2,7e-6, et leurs rangs sont exacts. Ce sont donc de vrais tirages du modèle, avec environ quatre chiffres significatifs, et non de l'arrondi. Le vrai bruit d'arrondi est le cas de la l. 15815 (σ̂² = 4,9e-22), c'est-à-dire une colonne figée.
- « effet non mesuré » (l. 17791) est incomplet : pour ExpVar, l'effet va dans le sens libéral, de façon certaine (voir la dernière partie).
- La rédaction dépend de la décision du mainteneur sur P1.

## Constats mineurs

- **m1. l. 16229 : borne de Clopper-Pearson fausse.** 0,124 doit être 0,123 : `binom.test(218, 2000)` donne [0,09567 ; 0,12349]. Les cinq autres intervalles sont justes. Critère : aucun.
- **m2. l. 16236-16237 : le seuil ne porte pas sur l'écart lui-même.** Dans « écart apparié … de −0,002 à 0, pour un seuil de +0,02 », le seuil de K4 s'applique à la borne haute de l'intervalle à 90 %, qui vaut au plus 0,0016. Ajouter « sur la borne haute à 90 % (au plus 0,0016) ». Critère : aucun.
- **m3. l. 6580 : formulation contradictoire.** « n'estime pas la variance de la colonne » contredit l. 16165 (« la règle surestime σ²_{J−1} »). Remplacer par « n'est pas tirée des facteurs de cette colonne et peut s'en écarter fortement ». Critère : aucun.
- **m4. l. 16409 : parenthèse trop étroite.** « (entrées ExpVar et KruskalAcc …) », accolée aux résidus des réplications, laisse croire que seules ces deux entrées les lisent. Or BP, DW, Runs et PenteIntra lisent aussi `e$res` ou `e$r`. Remplacer par « (contexte de `.mw_contexte_mc()`, lu par les six entrées fondées sur les résidus) ». Critère : E5, faiblement. La même restriction existe déjà dans l'index, l. 1494-1500, hors du diff.
- **m5. l. 6588 : « laisse la couverture … inchangée ».** Écrire « pratiquement inchangée » (écart de −0,002 à 0). Critère : aucun.
- **m6. l. 16212 : renvoi flou et statut non dit.** L'antécédent de « ce rapport » est dans la puce précédente. La lecture stratifiée d'Alpha est descriptive, et la phrase ne le dit pas. Critère : aucun.

## Vérifié sans constat

- Chiffres retrouvés dans le tableau : PenteIntra (0,0605, ρ = 0,048, « écart mineur » ; excès +0,008 et +0,0175 ; V0 +0,0195 et +0,0275 ; carré +0,0075 et +0,0125 ; K2b tenu dans les quatre cellules) ; MinP4 (0,021, 0,022, 0,023 ; carré 0,023 ; bloc D 0,014 [0,008 ; 0,023], conservateur) ; Alpha (+0,0135 [0,004 ; 0,022] et +0,0045) ; aucune distorsion matérielle sur les trois trapèzes, aucune distorsion libérale dans le bloc D ; 396 réplications sur 999 dans la sonde ; err_mc 0,0069 ; les six taux de non-couverture.
- Code : `.mw_simulation_sigma_direct()`, `.mw_cas_sigma_direct()` (trois cas), `.mw_sigma2_residus()`, `mw_residus()`, `.mw_contexte_mc()` (`numeric(0)`), `mw_bootstrap()`. Texte de M6 conforme aux gabarits. `MW_TOL_SIGMA_SIMULATION` absente du code et du `.tex`. Aucun terme de la vie du dépôt dans le diff.
- Statuts exact, asymptotique, approximation et observé par simulation distingués correctement, à T = 8.

## Point supplémentaire : K d'ExpVar sous P1 (#615)

**Ce constat change le jugement de `actuary-5`, § 1.**
- Pour ExpVar, l'effet est certain et libéral : chaque p_j ne dépend que des résidus de sa colonne ; quand une réplication est touchée, X*_P1 = X*_avant − (−2 log p_{j*}) ≤ X*_avant, à graine égale, la statistique observée étant inchangée. Donc p_mc(P1) ≤ p_mc(avant #615), sans exception.
- Pas de compensation : une colonne dégénérée à l'observé est figée et exclue partout (K constant).
- Pour KruskalAcc, BP, PenteIntra, DW et Runs, le sens n'est pas déterminé. La sonde borne l'ampleur : jusqu'à 0,094 (3,19 err_mc) pour PenteIntra, 0,022 (1,43 err_mc) pour ExpVar.
- La prémisse de P1 est réfutée (M3) : avant #615, ces résidus étaient de vrais tirages valables et K restait constant (doctrine de M1). La règle du constat (1) détectait un écart entre deux variantes ; elle ne disait pas laquelle est juste.
- Avis : (a) en l'état, insuffisant ; **(b) correction recommandée : retour à la règle d'avant #615**, en gardant la garde `numeric(0)` (K constant, résidus valables, aucun coût en B_eff ; la mesure L-A a été produite sous cette règle, moteur `5bffa72…`) ; la variante P3 (« K* < K_obs non défini ») se défend, mais coûte jusqu'à 40 % de B_eff et n'est pas mesurée ; (c) une mesure n'est pas un préalable au retour.
- Cas de référence : l'effet n'a pas joué (seuil 0 de `e4ecb16` sur les sept cas).
- Zone concernée : dispersions relatives d'environ 1e-12 à 3e-10, hors des données réelles (*hypothèse* : des montants arrondis au centime donnent environ 1e-9 ou plus).
- Classement ADR 0018 : dans le périmètre ; G (majeur), E3, E5.

## Suites (session principale)

- **Décisions du mainteneur du 25/11/2026** : retour à la règle d'avant #615 avec la garde `numeric(0)` (commit `b50a5e0`, audit léger conforme avec réserves) ; M2 corrigé en forme (ii).
- L'erreur relative de 1,9e-4 à 2,7e-6 citée en M3 vaut pour le montage de l'auteur. Mesurée élément par élément sur deux colonnes de `tests/donnees/triangle_mw.csv`, elle atteint 2,0e-3 sur le facteur central d'une colonne de cinq facteurs à 5e-13 ; rapportée au plus grand écart de la colonne, elle reste sous 1e-4. Rangs exacts partout. Voir `mesure-ecarts-615/`.
- Reprise par `docwriter` de M1, M2 (ii), M3, m1 à m6 et des passages écrits pour P1, puis nouveau visa sur ce diff seul.
