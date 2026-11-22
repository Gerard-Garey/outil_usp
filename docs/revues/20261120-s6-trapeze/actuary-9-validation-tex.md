# Validation du diff du `.tex` de S6 (étape 9, règle 9) : avis d'`actuary`

> *Rédigé par l'agent actuary-approfondi (IA) le 22/11/2026 ; versé intégralement par la session principale.* Branche `claude/merz-wuthrich-trapeze`, tête `7d107ab` ; objet : `git diff c8840d4...7d107ab -- docs/latex/doc_tests_usp.tex` (425 lignes ajoutées, 124 retirées). Essais hors dépôt (dossier temporaire de session) : `inv9.R`, `charg.R`, `ch/ch.txt`. **Tri de la session (22/11/2026) : M-a, M-b et les mineurs m-1 à m-6 retenus, corrigés par un commit `docs:` minimal de `docwriter`, relu par `actuary` sur son seul diff.** Ce rapport vaut erratum de l'avis `actuary-10-avis-m1-bootstrap-jm1.md` (paragraphe « Fait décisif », invariance à k = 1e4).

Je n'ai rien écrit dans le dépôt : ni fichier, ni issue, ni commentaire.

## Verdict : **validé avec réserves**

Sur le fond, le document est juste et rigoureux à T = 8. Il sépare partout le constat de simulation, l'argument algébrique, la concordance numérique et l'hypothèse. Il distingue l'erreur Monte-Carlo, qui dépend du nombre de triangles et de B, de l'erreur d'approximation en T. Je n'ai trouvé aucune référence fabriquée.

Il rend fidèlement les quatre décisions :
- **D2 (a′)** : extension avec trois réserves. MinP4 est conservateur (fiche `mw:m4gr`, rubrique 7). PenteIntra est libéral sur trapèze (`mw:m1`, rubrique 6). Le statut épistémique est dit dans `sec:trapeze-niveau` et dans l'encadré, point (iii).
- **D3 (a)** : le constat est porté sans restitution (« aucun de ces intervalles n'est restitué par le moteur »).
- **Q-A1 (ii)** : les deux σ de la colonne J−1 sont restitués avec leur usage (index, `plots_data`, graphiques, `mw:m6sig`).
- **M-1 (b)** : le paragraphe de `sec:boot-mw` reprend le prédicat, son statut de convention non réglementaire, la MSEP et σ_USP inchangés, et le statut à T = 8.

Deux constats **majeurs** sont à corriger avant la sortie du brouillon. Ce sont deux affirmations inexactes, chacune réparable en une phrase, sans effet sur aucun résultat. Le visa vaut sous réserve de leur correction par un commit `docs:` minimal, relu par moi sur son seul diff (règle 10).

## Constats

### Majeurs

**M-a. Couverture des intervalles calibrés par bootstrap imbriqué, l. 9253-9254 et l. 6692-6694.**
- *Ce que dit le texte* : à la l. 9253-9254 (tableau 2), « ni aucun intervalle calibré par bootstrap imbriqué $0{,}729$ ». Or le percentile calibré C0, mesuré à titre descriptif dans le même fichier, couvre **0,739** à 90 % sous N, et C1-99 couvre 0,731. Les deux sont des intervalles calibrés par bootstrap imbriqué (`docs/tableaux/20261120-issue610-couverture-ic-sigma-mw-imbrique.md`, T2 : P2, C0, 0,7390 [0,7106 ; 0,7660] ; P2, C1-99, 0,7310).
- *Formulation ambiguë* : à la l. 6692, « Un percentile calibré est exclu par construction » se lit comme si ce percentile n'avait pas été mesuré. Il a été mesuré, et seule sa candidature a été exclue. La formule vient de ma lecture `actuary-5-lecture-610.md`, § 7, que `docwriter` a suivie fidèlement : l'erreur est la mienne.
- La conclusion (« ne rétablit pas le niveau nominal ») reste vraie.
- *Corrections proposées* :
  - l. 9253-9254 : « …ni aucun intervalle calibré par bootstrap imbriqué $0{,}739$ ».
  - l. 6692-6694 : « Le percentile calibré n'est pas candidat : ses bornes restent dans $[\min\sigma^{*} ; \max\sigma^{*}]$, et $\sigma_A$ dépasse $\max\sigma^{*}$ dans $0{,}187$ (E) et $0{,}181$ (N) des triangles ; mesuré à titre descriptif, il couvre $0{,}704$ (E) et $0{,}739$ (N) à 90 %. »

**M-b. Portée du test du champ `loi`, l. 4439.**
- *Ce que dit le texte* : « aussi sur six des sept cas de référence (tous sauf `reserve2_trapeze`) ».
- *Pourquoi c'est faux* : depuis `f26d84a`, postérieur à `ddb7b0f`, `tests/unitaires/test_non_applicable.R`, l. 147-158, couvre les **sept** cas. Le message de `f26d84a` déclarait pourtant « Surface d'impact documentaire : aucune ».
- *Gravité* : critère E5 de l'ADR 0018, affirmation fausse de la documentation sur le code.
- *Correction* : « et, pour `loi`, aussi sur les sept cas de référence ».

### Mineurs (corrections proposées ; la session trie)

- **m-1, l. 6551-6557.** « Mêmes tirages (mêmes appels à `sample()`) » est plus fort que le code. Le commentaire de `mw_bootstrap()`, `R/engine.R` l. 16378-16387, dit : « pour chaque triangle tiré, mêmes appels… le retirage d'un triangle à cumul non strictement positif peut en dépendre ».
  - Proposition : « Pour chaque triangle tiré, mêmes appels à `sample()`, dans le même ordre ; seul le retirage d'un triangle simulé à cumul non strictement positif peut dépendre de l'écart type de la colonne J−1. »
  - Après « …n'en dépendent pas », ajouter : « (propriété d'échelle des statistiques, tant que ce retirage n'en dépend pas) ».
- **m-2, l. 16129.** « Le niveau est comparable à celui du carré » reprend la lecture du profil Θ1. Or le profil retenu est Θ2, et aucun test direct ne compare 8×5 ou 8×6 au carré.
  - Proposition : « Sur 8×5 et 8×6, aucune distorsion matérielle n'est classée, le seul écart non tranché étant celui de la cellule aberrante ; deux réserves : ».
  - Ce qui le fonde : tableau de niveau, ligne Θ2 (l. 716 du fichier), où le seul non tranché est MinP4 sous N à 0,05.
- **m-3, l. 15747-15756.** Le paragraphe écarte un repli en partie parce qu'il « introduirait une discontinuité ». Juste après, il annonce la convention M-1 (b), qui garde une discontinuité au seuil 1e-10 pour PenteIntra, la famille α et `sigma_boot` (`sec:boot-mw`, l. 6561).
  - Proposition, après « (section~\ref{sec:boot-mw}) » : « ; cette convention, qui ne touche ni la MSEP ni $\sigma_{\mathrm{USP}}$, garde au seuil de la règle négligeable une discontinuité pour la pente relative, la famille $\alpha$ et `sigma_boot` ».
- **m-4, l. 6685 et l. 21210-21212.**
  - l. 6685 : « est celui de J. Chang et P. Hall » attribue au texte la paternité de la calibration, qui remonte à Hall (1986) et Beran (1987) (cités par l'article, p. 2, non relus). Proposition : « est celui que décrivent J. Chang et P. Hall ».
  - Bibliographie : les ordres $\mathcal{O}(n^{-1/2})$ et $\mathcal{O}(n^{-1})$ sont **rappelés** par l'article, p. 1, comme résultats de la littérature. Le cadre de la fonction lisse d'une moyenne, éq. (1) et (2), est celui où l'article se place. Proposition : « rappelés p. 1, et valables dans le cadre où se place l'article, un estimateur fonction lisse d'une moyenne (éq. (1) et (2), p. 2-3) ».
- **m-5, l. 16114 (facultatif).** « 42 % (E) » : la valeur brute est 0,4150. Écrire « 41,5 % ».
- **m-6, `mw:m1`, rubrique 7 (l. ~16552, facultatif).** « Ligne de type test sur le triangle 8×8 » : la fiche `mw:m4gr` dit, elle, « et sur un trapèze ». Par symétrie, proposer « …sur le triangle $8\times8$ et sur un trapèze (niveau sur trapèze : rubrique 6) », sans nouveau `\ref` (CONVENTIONS, § 9 : un `\ref` par fiche).
- *Écarté sans suite* : la suppression, l. 18675, de la frontière « années $i = 0$ et 1 » (condensation admise par CONVENTIONS, § 6 ; le fond « la frontière dépend des cellules perturbées » est gardé).

## Réponses aux quatre points de `docwriter`

**1. Mécanisme de PenteIntra sur 8×7 écrit comme hypothèse.** C'est **suffisant**, et c'est le bon statut. Il n'est pas nécessaire de verser le diagnostic à nombres aléatoires communs (`a10`, `a11`) dans `docs/tableaux/`, pour trois raisons :
- Le diagnostic est petit (150 triangles par loi) et n'est pas une mesure de niveau (`actuary-5b-lecture-567.md`, § 4). Ses scripts sont déjà reproduits en annexe de cette lecture.
- Le caractère libéral se lit sur le seul tableau versé : à 0,05, l'IC de Clopper-Pearson [0,057 ; 0,090] (N) et [0,059 ; 0,093] (E) est entièrement au-dessus de ρ = 0,048.
- La prémisse « la règle sous-estime fortement sur 8×7 » est mesurée (K-T4 : médiane 0,0871 sous N, 0,1103 sous E). Le poids $C\hat f^2/\hat\sigma_j^2$ est lu dans le code : `.mw_pente_relative()`, l. 14872, avec `res$sigma_j` donné par `.mw_sigma2_residus()`.
- Mon balayage `inv9.R` du jour le corrobore : sur (s2), PenteIntra p_mc vaut 0,01 quand le σ simulé de J−1 est multiplié par 1e-4 ou 1e-2, contre 0,09 à 1.

**2. Niveaux sur trapèze en rubrique 7 et dans `tab:tracabilite-puissance`.** **Non.**
- CONVENTIONS, § 6 : un chiffre n'est cité qu'une fois, et la rubrique 6 en tire la conséquence en mots. C'est ce que font les deux fiches, avec renvoi à `sec:trapeze-niveau`, qui donne plan, R, B, script, fichier et statut.
- `tab:tracabilite-puissance` trace les chiffres des rubriques 7 : aucun n'est ajouté, donc aucune ligne n'est due.
- Seul ajustement utile : la mention « et sur un trapèze » dans la rubrique 7 de `mw:m1` (m-6).

**3. Formulations.**
- « Niveau comparable à celui du carré » : à reformuler (m-2).
- C1 et C2 : la description est fidèle au protocole (`actuary-2b-protocole-610.md`, § 2.1 et 2.2). « Construction de l'outil » pour la calibration de chaque borne est exact (le protocole dit « ma construction »).
- Chang et Hall (2015), lu sur arXiv:1408.6327v1 : **vérifié** sur le texte de la prépublication.
  - Référence publiée : *Biometrika* 102(1), p. 203-214, relevée sur la notice arXiv.
  - Ordres $\mathcal{O}(n^{-1/2})$ et $\mathcal{O}(n^{-1})$ : p. 1.
  - Éq. (1), p. 2, et (2), p. 3.
  - Éq. (9) à (11) : p. 6, écrites pour la variante à une réplication de second niveau.
  - « Does not reduce the order of magnitude of coverage error » : p. 2.
  - σ̂ remplacé par σ̂* et σ̂** pour une racine studentisée : p. 6.
  - Section numérique : n ≥ 20, donc aucune couverture à n = 8.
  - Seule réserve : la nuance d'attribution de m-4.

**4. Paragraphe « Colonne J−1 d'un trapèze à règle nulle ou négligeable ».**
- *Phrase sur le mécanisme de l'invariance* : **juste**. Mesure du jour (`inv9.R`, cas (s2), B = 199, graine 20260831), σ simulé de J−1 multiplié par k ∈ {1e-4, 1e-2, 1, 1e2} :
  - pour 11 clés, les statistiques répliquées sont égales à celles de k = 1 à au plus 2,5e-8 en relatif (0 pour 8 clés), et les p_mc sont identiques ;
  - PenteIntra (écart relatif jusqu'à 4·10³) et Alpha (0,41 ; 36,6 à k = 1e2) changent.
  - L'algèbre le confirme : écarts $F - \hat f$ et racine de l'estimateur direct de la réplication proportionnels à k ; colonne J sans successeur.
  - À compléter seulement par le statut et la condition sur le retirage (m-1).
- *Discontinuité au seuil pour PenteIntra et Alpha* : **juste** (PenteIntra 0,01 à k ≤ 1e-2 contre 0,09 à k = 1). À relier au paragraphe du repli (m-3).
- *« Le document n'en mesure pas le niveau »* : **bon choix**. Ma mesure `niveau.R` de l'avis actuary-10 (400 triangles, B = 199, comparée à α nominal et non à ρ) n'est ni versionnée ni produite par un script de `tests/`. Le `.tex` ne doit pas la citer. Si une mesure est voulue, elle relève du périmètre de #612 (protocole avant tirage, M42).
- *k = 1e4* : **`docwriter` a raison, et mon avis actuary-10 était inexact.** À k = 1e4, le retirage des cumuls non positifs est déclenché (`cumuls_retires` TRUE) et les 13 clés changent (Calendrier 0,005 → 0,035, Origine 0,09 → 0,125…). L'invariance n'est établie qu'à retirage inchangé, vérifiée de k = 1e-4 à 1e2. Ce rapport, versé dans `docs/revues/20261120-s6-trapeze/`, vaut erratum de l'avis actuary-10 (paragraphe « Fait décisif »). Le `.tex`, qui écrit « à tirages égaux », n'est pas atteint par l'erreur.

## Retour

- **Statut** : `complet`. Toutes les preuves prévues sont citées ou mesurées.
- **Résultat** : **validé avec réserves** : M-a et M-b à corriger, mineurs m-1 à m-6 à trier par la session.
- **Preuves**
  - *Vérifiées* :
    - diff entier relu ;
    - chiffres de `sec:trapeze-niveau` confrontés au tableau de niveau (K1, K-T6, K-T4, profil Θ2). La part de √MSEP inférieure de plus de 10 % a été recalculée sur le brut : 0,372 (N) et 0,415 (E) ;
    - chiffres de C1 et C2 confrontés au tableau de #610 (T1, T2, T6) ;
    - lignes de `reserve2_trapeze` (err_mc, p_min, `mc_nom` 13/25, `p_min_mc` 5, B effectif 999 × 13) lues dans `tests/reference/reserve2_trapeze.rds` ;
    - identité $\sum_i r^2 = n_j - 1$ (écart 8,9e-16) ; MSEP du trapèze (4,2e-16, tableau `msep-trapeze`) ;
    - « sept cas identiques sous chargeur et sous `source()` » : mesuré par `charg.R` sur `reserve2_trapeze`, `identical()` TRUE ;
    - prédicat et boucle de `mw_bootstrap()` lus (`R/engine.R` l. 13845-13866, 16376-16411) ;
    - balayage d'invariance `inv9.R` ;
    - Chang et Hall relu (texte de la prépublication) ;
    - `concordance_doc_moteur.R --strict` : 0 écart ;
    - le constat de niveau reste valable pour le moteur courant : sur les 10 000 triangles de l'étude, la règle n'est jamais nulle (σ² minimal 7,2e-10, soit σ ≈ 2,7e-5, au-dessus du seuil de l'ordre de 1e-8), donc `.mw_simulation_sigma_direct()` y vaut FALSE.
  - *Hypothèses* :
    - le mécanisme de PenteIntra sur 8×7, bien étiqueté comme tel ;
    - la constance de l'invariance hors du triangle (s2), qui repose sur l'algèbre et n'a été vérifiée que sur ce triangle.
  - *Non vérifiés* :
    - les passages de lecture réglementaire (convention (B), D(5)(d)(ii) « par prescription », forme 2015 de la MSEP), du ressort de `regulatory` (`regulatory-8-conformite-tex.md`) ;
    - la compilation et la pagination.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : tri des mineurs (session) ; aucune décision du mainteneur requise.
- **Critères déclenchés** : correction de mon propre avis actuary-10 sur k = 1e4, sans désaccord avec `docwriter` (qui l'a relevée) ni avec `audit`. Validité à T = 8 établie par simulation seulement (inhérent, déclaré). Aucun changement de résultat.
- **Constats hors périmètre** (ADR 0018)
  1. Message de `f26d84a` : « Surface d'impact documentaire : aucune » était faux (cause de M-b). Critère : aucun (processus).
  2. `actuary-10-avis-m1-bootstrap-jm1.md`, paragraphe « Fait décisif » : invariance affirmée à k = 1e4, réfutée par `inv9.R`. Critère : aucun (document de revue, pas le `.tex`) ; erratum porté par ce rapport.
  3. Régime σ_règle ≪ σ_dir non nul, hors prédicat :
     - sur le plan 8×7, σ²_règle descend à 7,2e-10 (brut du tableau de niveau) ;
     - sur GenIns 10×9, règle 24,37 contre direct 1 147 (tableau `msep-trapeze`) ;
     - PenteIntra y est très sensible (p = 0,01 contre 0,09 sur (s2)).
     Critère E3, déjà suivi par #612 : je recommande d'y ajouter ces deux données en commentaire, sur accord du mainteneur.
- **Prochaine action recommandée** : commit `docs:` minimal de `docwriter` pour M-a et M-b, plus les mineurs retenus par la session ; ma relecture de ce seul diff ; puis l'étape 10.

Sources consultées par l'agent : arXiv:1408.6327v1 (Chang et Hall, *Double-bootstrap methods that use a single double-bootstrap simulation*), texte PDF de la prépublication ; notice RePEc de la version publiée, *Biometrika* 102(1), 203-214.
