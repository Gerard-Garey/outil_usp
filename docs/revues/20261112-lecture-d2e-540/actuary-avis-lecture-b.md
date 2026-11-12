# Avis d'`actuary` sur la lecture (B) de #540 (triangle à I > J)

> *Rédigé par l'agent actuary (IA), fiche de base.* Avis rendu hors branche le 12/11/2026, dans la suite de #540 et de Q-60-8 (a), à la demande du mainteneur. Versé intégralement par la session principale sur la branche K3b (Refs #540). L'agent n'a rien écrit dans le dépôt et n'a créé aucune issue.

**Recommandation en bref.** Pour la remise, garder la lecture (A), c'est-à-dire le refus MW-04, en en précisant le motif et la documentation à KR. La lecture (B) est la bonne cible actuarielle, mais elle relève d'un circuit 1 + 2 complet à mener après la remise.

## Lu

- La matrice de `regulatory` et sa synthèse (`docs/revues/20261112-lecture-d2e-540/`), ainsi que #540 (corps et commentaire du 12/11).
- L'ADR 0005 (l. 70 : « convention non prescrite »).
- Dans `R/engine.R` : l'en-tête l. 9773-9779, `mw_valider_triangle()` l. 9846-9851, `mw_ajuster()`, `mw_msep()`, `mw_parametre()`, `mw_residus()`, `.mw_un_moins_h()`, `.mw_simuler_triangle_etat()`, `.mw_triangle_incomplet()` et `mw_bootstrap()`.
- Dans le `.tex` : l. 4721-4725, l'encadré l. 14607-14614, la fiche `mw:m6sig` et la bibliographie.
- Le texte consolidé, D(2)(d) et (e), extraits en texte courant (pas de formule).
- Merz et Wüthrich (2008), *CAS E-Forum*, automne 2008, PDF officiel CAS (https://www.casact.org/pubs/forum/08fforum/21merz_wuetrich.pdf), texte extrait avec `pdftotext`. Seule de la prose en est citée.

## 1. Sous (B), la MSEP restreinte est-elle celle de Merz-Wüthrich pour un trapèze ?

**Ce que dit l'article (vérifié)**, au § 2.1, p. 546 :
- « This means that the ultimate claim for accident year i is given by C_{i,J}. »
- « For simplicity, we assume that I = J (note that all our results can be generalized to the case I > J). »

Deux conséquences :
- Les auteurs annoncent que leurs résultats s'étendent au cas I > J, mais **n'impriment pas la formule de ce cas**. Wüthrich et Merz (2008, Wiley) et Merz, Wüthrich et Lysenko (2009) n'ont pas été consultés : on ne sait pas si l'un d'eux l'imprime.
- Dans le modèle, la charge ultime **est** C(i,J) par définition. Il n'y a ni facteur ni variance au-delà de J.

**Raisonnement de l'agent**, élémentaire, mais ni une citation ni un calcul vérifié :
- Pour i ≤ I−J, C(i,J) appartient à D_I. Les prédictions de la charge ultime en I et en I+1 sont toutes deux égales à C(i,J). Le CDR de ces années est donc nul presque sûrement.
- Leur contribution à la MSEP conditionnelle du CDR agrégé est donc nulle, termes croisés compris.
- Pour les autres termes, f̂_j, S_j, S′_j et σ̂²_j (j ≤ J−2) s'étendent naturellement à toutes les lignes. Pour i ≥ I−J+1, les termes C(I−j,j) avec j ≤ J−1 et Q̂_{I−i} avec I−i ≤ J−1 restent définis.
- La convention (B), qui fait partir les sommes de i = I−J+1, est donc l'extension naturelle de la formule à un an au trapèze, **sous le modèle**.

**Ce qu'il reste à établir.** L'égalité n'est ni lue dans une source qui imprime le cas I > J, ni contrôlée numériquement. Avant toute extension, il faut l'établir :
- par une comparaison à une implémentation indépendante sur un trapèze (par exemple `ChainLadder::CDR`, si elle accepte cette forme : non vérifié) ;
- ou par une simulation directe du CDR.

**« Aucune queue au-delà de J » : une hypothèse du modèle, et non une convention propre à (B).**
- Elle est déjà présente pour I = J : Ĉ(i,J) y est pris pour la charge ultime de toutes les années.
- Le texte n'en fait une exigence de données que pour la première année : D(2)(d) demande que le cumul de la dernière année de développement inclue tous les paiements, « à quelque différence non significative près ».
- Pour les années 1..I−J, cela découle de D(2)(d) et des facteurs communs de D(2)(h). Ce n'est pas un contrôle que l'outil peut faire.

Lecture de l'agent :
- l'outil applique la convention, parce que c'est le modèle de la section D ;
- l'outil la **déclare** comme hypothèse dans le motif et dans la documentation ;
- l'entreprise la justifie, de la même façon qu'elle justifie D(2)(d) et la qualité des données (art. 19).

L'outil ne doit pas la présenter comme établie.

## 2. Règle de minimum de σ̂²_{J−1} imposée même quand I > J

**Ce qui est vérifié.** Merz et Wüthrich (2008, p. 561) motivent l'extrapolation de Mack par l'absence de données : « Since we do not have enough data to estimate σ_7² (recall I = J) ». Le règlement reprend cette règle **sans condition sur I** (lecture de `regulatory`, D(5)(d)(ii)). Pour I > J, il écarte donc un estimateur direct disponible, qui aurait I−J degrés de liberté.

**Conséquences statistiques** (raisonnement, non chiffré) :
1. **Biais vers le bas.** Si σ̂²_{J−2} et σ̂²_{J−3} sont sans biais, l'inégalité de Jensen donne E[min] ≤ min des espérances. La règle suppose en outre une décroissance géométrique de σ²_j. Si la variance de fin de développement ne décroît pas, Q̂_{J−1} est sous-estimé. Q̂_{J−1} entre dans Δ_i pour toutes les années i ≥ I−J+1 et dans le terme de processus de l'année I−J+1. Le sens attendu est une MSEP plus faible, donc un σ_USP plus faible : ce n'est pas prudent. L'ampleur n'est pas connue à T = 8 : aucune simulation n'est faite.
2. **Bruit de l'estimateur direct.** Avec I−J ∈ {1, 2, 3} à T = 8 (trapèzes 8×7, 8×6, 8×5, J ≥ 4 imposé par D(2)(c)), l'estimateur direct est lui-même très bruité. Aucune littérature retrouvée ne permet de dire lequel des deux est le meilleur à T = 8.
3. **Conséquence pratique.** Garder la lettre : calculer σ̂²_{J−1} par la première ligne serait un écart, comme le note R-4 de `regulatory`. La fiche M6 deviendrait alors un vrai diagnostic, en restituant pour information l'estimateur direct (I−J degrés de liberté) à côté de la valeur imposée.
4. **Incohérence interne des résidus.** Point actuariel, traité au § 3.

## 3. Effets sur le reste de la méthode n° 2 en cas d'extension

- **`mw_ajuster()` et `mw_msep()`.**
  - Sur un trapèze, `derniers` lit `tri[i+1, I-i+1]` hors bornes, d'où l'erreur R mesurée par `regulatory`.
  - `Delta(i)` lirait `Q[I-i+1]` au-delà de J, ce qui donne NA.
  - Les sommes en i doivent partir de I−J+1 et `reserve_par_annee` doit être nul pour i ≤ I−J.
- **Résidus de la colonne J−1.**
  - Pour I = J, la colonne n'a aucun résidu, car elle n'a qu'un facteur (`mw_residus()`, `length(idx) < 2`).
  - Pour I > J, elle aurait I−J+1 ≥ 2 résidus, réduits par un σ̂_{J−1} **qui ne vient pas de cette colonne** (règle de minimum).
  - L'identité Σ_i r²_ij = n_j − 1 et la variance unitaire des résidus redressés, qui fondent le vivier du bootstrap (`.mw_un_moins_h()`, commentaire de `mw_residus_redresses()`), ne tiennent plus pour cette colonne.
  - Son sort est à spécifier par `actuary` : exclue du vivier et des tests fondés sur les résidus, ou réduite par son propre estimateur pour les seuls diagnostics.
  - Lignes touchées : M2 (variance unitaire, hétéroscédasticité), M3 (Durbin-Watson, test des suites, homogénéité entre années de survenance), M4 (résidus studentisés, ESD), M5.
- **Simulation.** `.mw_simuler_triangle_etat()` fonctionne en I > J, mais simule la colonne J−1 avec le σ de la règle de minimum. Cela reste cohérent avec la MSEP, à documenter. `.mw_triangle_incomplet()` (contrôle des tests) suppose explicitement un carré : sur un trapèze, il balaie i + j ≤ J et non i + j ≤ I. Il est à corriger.
- **Lois exactes et planchers p_min** (M1, M3 calendaire, corrélation, Fisher, Kruskal-Wallis). Les effectifs par colonne passent de J−j à I−j, et les diagonales calendaires sont tronquées autrement. Il faut revoir les tables, les seuils d'identifiabilité et l'ensemble figé `.mw_ensembles_figes()`.
- **Niveau des tests.** Les mesures de niveau sur triangles carrés (par exemple #119) ne valent pas pour un trapèze. Il faudrait une campagne de simulation sur 8×5, 8×6 et 8×7.
- **Autres points.** Comparaison externe de `sec:verif` à étendre. Prédicat de colonne dégénérée pour J−1, aujourd'hui trivialement vrai. M6 « concentration de la réserve » : sens inchangé.

## 4. Recommandation

**Pour la remise : (A).** Raisons :
1. Les six cas de référence sont carrés : (A) ne change rien.
2. Sous (B), l'égalité avec Merz et Wüthrich n'est pas établie par une source imprimée ni par une mesure (§ 1).
3. L'extension touche la MSEP, le vivier du bootstrap et une dizaine de lignes M (§ 3). Sous (B), un trapèze recevrait un σ_USP et ses verdicts sans étude de niveau à T = 8. C'est incompatible avec une échéance proche.

**À KR, sans changement de chiffre :**
- **R-1.** N'émettre MW-04 que si D(2)(e) est rempli (I > J). MW-03 suffit pour I < J. Ce changement porte sur la liste des motifs de refus, pas sur les références : les cas sont carrés. Mettre à jour `tests/unitaires/test_controles_entree.R` (l. 1666, 2134-2137 : texte du motif cité), sans régénération ni patch de `tests/reference/`.
- **R-2.** Unifier la qualification dans le motif, dans le `.tex` (l. 4722-4725 et 14607-14614, fiche `mw:m6sig`) et dans l'ADR 0005 (l. 70, par annotation datée). Formulation proposée :
  - « les formules de D(4)-D(5) ne se calculent à la lettre que si I = J ;
  - le domaine de l'outil est plus étroit que celui de D(2)(e), qui admet I > J ;
  - se ramener à un carré exclut des données et doit être justifié (art. 19(1)(b)), à défaut de quoi la méthode n° 1 reste ouverte ;
  - Merz et Wüthrich (2008, p. 546) supposent I = J par simplicité et annoncent l'extension au cas I > J sans en imprimer la formule. »

  La dernière phrase est citable, vérifiée ci-dessus. Le `.tex` est modifié par `docwriter` en fin de branche (règle 9).
- R-3 sans objet sous (A).

**Après la remise : (B)**, en circuit 1 + 2, avec ces critères d'acceptation :
- les six références sont identiques au bit (`identical()`) ;
- la MSEP du trapèze est confrontée à une implémentation ou à une simulation indépendante ;
- la règle de minimum est gardée, avec l'estimateur direct restitué pour information (M6) ;
- le sort des résidus de la colonne J−1 est spécifié ;
- le niveau des tests est mesuré par simulation sur 8×5, 8×6 et 8×7 ;
- la durée G(3)(c) vaut I + 1 ;
- le refus de R̂ ≤ 0 (M4) est gardé.

L'argument de l'art. 19(1)(b) plaide pour (B) à terme.

## 5. Effets possibles sur σ_USP et circuit

- **(A) avec R-1 et R-2** : aucun σ_USP, aucune p-value, aucun verdict ne change. Seuls les textes de motif et les tests unitaires changent. Circuit 3 (`coder` puis `audit`) pour le moteur, et `docwriter` pour le `.tex` et l'annotation de l'ADR 0005.
- **(B)** : aucun σ_USP des références ne change, à condition que le chemin I = J reste identique au bit. Pour un trapèze aujourd'hui refusé, tout devient calculé :
  - réserve, MSEP, √MSEP, `sigma_estime` ;
  - crédibilité c, avec T = I + 1 au lieu de J + 1 pour un carré tronqué ;
  - `sigma_usp`, `variation_relative`, tables de calibration ;
  - `sigma_boot` et intervalle bootstrap ;
  - toutes les p-values et tous les verdicts M1 à M6.

  Par rapport à la solution de repli d'une entreprise (troncature au carré), f̂_j, σ̂²_j, Ĉ et c changent tous. Il faut le circuit 2 (`regulatory` est déjà passé, puis `actuary`, puis décision du mainteneur sur σ_USP et les verdicts) combiné au circuit 1 (spécification par `actuary`, `coder-approfondi`, `audit`, `docwriter`, validation par `actuary`), et un contrôle de conformité par `regulatory`.

## Retour

- **Statut** : `partiel`. Les § 2 à 5 sont complets. Au § 1, l'égalité entre la MSEP restreinte et l'erreur à un an de Merz et Wüthrich sur un trapèze repose sur le raisonnement de l'agent. Elle n'est confrontée ni à une formule imprimée pour I > J, ni à une mesure. La recommandation pour la remise n'en dépend pas.
- **Résultat** : (A) pour la remise, avec R-1 et R-2 à KR. (B) après la remise, en circuit 1 + 2, avec les critères ci-dessus.
- **Preuves**
  - *Vérifié* :
    - Merz et Wüthrich (2008), p. 546 (charge ultime = C_{i,J} ; « we assume that I = J (note that all our results can be generalized to the case I > J) ») et p. 561 (extrapolation motivée par I = J), texte du PDF CAS ;
    - D(2)(d) du texte consolidé ;
    - code lu : erreurs hors bornes de `mw_ajuster()` et `mw_msep()` en I > J, colonne J−1 sans résidu seulement si I = J, `.mw_triangle_incomplet()` limité au carré, texte de MW-04 cité par les tests unitaires.
  - *Hypothèses* : CDR nul pour i ≤ I−J (raisonnement) ; sens du biais de la règle de minimum (Jensen, sous l'hypothèse d'estimateurs sans biais).
  - *Non vérifié* : la formule pour I > J chez Wüthrich et Merz (2008, Wiley) ou chez Merz, Wüthrich et Lysenko (2009) ; le fait que `ChainLadder::CDR` accepte un trapèze ; l'ampleur du biais et le niveau des tests à T = 8.
- **Informations manquantes** : aucune source retrouvée qui imprime la MSEP à un an pour I > J ; aucune simulation.
- **Décisions non résolues** (le mainteneur) : (A) ou (B) pour la remise ; si (A), inscription de R-1 et R-2 à KR et ouverture d'une issue de suite pour (B) après la remise.
- **Critères déclenchés** : lecture à deux sens (déjà signalée par `regulatory`) ; validité de (B) à T = 8 qu'aucun résultat exact ni aucune simulation ne tranche ; changement de σ_USP et de verdicts pour une classe d'entrées sous (B). Aucun désaccord avec `regulatory`, avec qui l'agent est d'accord sur R-1 à R-4.
- **Prochaine action recommandée** : décision du mainteneur au soixante et unième point. Si (A) est retenue, inscrire R-1 et R-2 au périmètre de KR et rédiger, pour accord, une issue « extension au trapèze (lecture B), après la remise » reprenant les critères du § 4.
