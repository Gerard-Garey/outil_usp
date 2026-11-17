<!-- Rapport de l'agent actuary-approfondi, branche S2, étape 8 (validation unique du diff du .tex), 17/11/2026, sur f420184. Versé intégralement par la session principale. -->

# Validation du diff du `.tex` de la branche S2 (étape 8, règle 9)

Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue.

- **Périmètre lu** : `git diff 940f941..f420184 -- docs/latex/doc_tests_usp.tex` (330 lignes), sur la branche `claude/textes-conformite-et-qualifications`.
- **Contexte relu** : `docs/revues/20261116-s2-textes/` (mon avis I-1/I-2, les décisions D-S2-1 à D-S2-4, le contrôle aval de `regulatory`).
- **Vérifications sur le code et les tests** :
  - `R/engine.R` : `usp_pi()`, `usp_noyau()`, `usp_objectif()` et `usp_ajuster()` (l. 1436-1800), `BORNES_GAMMA` (l. 187) ;
  - `tests/unitaires/test_modele_lognormal.R` (l. 31-62) et `test_calibration.R` (l. 261-285) ;
  - l'encadré d'existence de `sec:h4` (l. 12208-12245), le paragraphe « Existence de l'estimateur » de `sec:controles` (l. 4668-4740) et `sec:graines` (l. 2795-2918) ;
  - l'ADR 0011, second amendement, points 2 et 5 (M34) ;
  - la prose de A(1), B(1), B(2)(g), B(3) et D(1), extraite du XHTML consolidé (c'est de la prose, pas une formule).

## Verdict global : **visa sous réserves**

Il n'y a ni bloquant ni majeur. Le fond de chacun des cinq points est conservé ou juste. **Une seule réserve** est à lever avant le commit du PDF : m-1, sur la rigueur de l'énoncé de la minimisation. Les autres mineurs (m-2 à m-4) sont facultatifs.

## Réponses aux cinq questions de `docwriter`

**1. #589, `sec:graines` : le fond est conservé.**
- Ma formulation contenait trois éléments, et les trois y sont :
  - (a) deux exécutions successives de la CI sont identiques au bit près ;
  - (b) c'est une propriété mesurée, non démontrée ;
  - (c) la CI ne s'écarte donc pas de ses références à image constante.
- « depuis M34 » est remplacé par la condition qui le portait, les bibliothèques d'algèbre linéaire de référence. C'est exact : l'ADR 0011, point 5 de M34, établit l'identité par les md5 de deux exécutions sous le BLAS et le LAPACK de référence. Le « ci-après » renvoie au paragraphe « Sous OpenBLAS… » (l. 2903-2909), qui décrit cette mesure et sa limite.
- Le second passage, « la CI ne s'écarte pas de ses références à image constante », reprend sans qualification une propriété qualifiée deux paragraphes plus haut. C'est admissible.
- Remarque de forme facultative : voir m-2.

**2. Texte I-1 adapté : le fond est conservé.**
- Les références D(3)(a) (années d'accident à partir de 0) et D(5)(d)(ii) (j = 0,…,J−2) sont plus précises que mon « D(3), D(5) ». `regulatory` les a vérifiées sur l'image (matrice, ligne 13).
- L'en-tête « Lecture retenue par l'outil » marque bien l'interprétation comme celle de l'outil, conformément à D-S2-1.
- La citation anglaise est identique au relevé `curl` de la session (`decisions-mainteneur.md`).
- « Cette lecture est conforme à la réponse… » est plus juste que mon « est celle de » : la réponse emploie elle-même « first development year » sans dire « année 0 ».
- La phrase de M-1 bis, « La réponse retient les paiements de l'année t elle-même, ce qui situe la meilleure estimation à la fin de l'année d'accident », est une déduction de cohérence : si la provision était prise à la fin de t+1, les paiements de t+1 manqueraient. Elle est présentée comme une lecture de la réponse, non comme sa lettre. C'est mon argument de l'avis I-1, point 3, et je le valide.
- La reprise M-1 (« au titre des sinistres survenus pendant celle-ci … pour ces mêmes sinistres ») lève l'ambiguïté avec l'année civile, sans changer la lecture.

**3. « une série tenue par année de souscription n'est pas celle que définissent B(1) et D(1) » : juste.**
- B(1) se termine ainsi : « Ces pertes agrégées et primes acquises sont disponibles séparément pour chaque année d'accident ».
- D(1) dit : « indiqués séparément pour chaque année d'accident et chaque année de développement ».
- A(1) ne définit pas l'année de souscription.
- Une série par souscription est donc une autre série par construction, même si ses montants peuvent coïncider dans un cas particulier (contrats annuels au 1er janvier). La phrase porte sur la définition, pas sur les valeurs : elle est exacte.
- La phrase sur la section C (« exercices », C(3)(a), A(1)(d) « l'année au cours de laquelle ce paiement est intervenu ») est exacte, vérifiée sur la prose consolidée.

**4. « Équivalence avec le moteur » : juste, avec une réserve de rigueur (m-1).**
- Chaque identité est vérifiée sur le code :
  - `usp_pi()` emploie `log1p` sous la forme commutée ;
  - `ln_beta` est la fraction de l'exposant de B(5), et `sigma = exp(gamma + ln_beta)` ;
  - l'identité γ̂ − ln σ̂ = −ln β̂ rend le montant de B(6) identique à `obj` ;
  - δ est tenu dans [0,1] par `lower`/`upper` de L-BFGS-B et par le renvoi de 1e12 dans `usp_objectif()` ;
  - les tests cités contiennent bien des transcriptions littérales indépendantes (`reg_pi`, `reg_sigma`, `reg_objectif`, à 1e-13, 1e-12 et 1e-11 près en relatif).
- « minimise numériquement » est exact et nécessaire : B(6) définit un minimiseur exact, le moteur l'approche par L-BFGS-B multi-démarrages.
- Le renvoi à `sec:h4` pour l'existence est le bon : l'encadré démontre l'absence de minimiseur si les ratios sont égaux, et son existence sur [0,1] × ℝ sinon.
- **Deux manques**, que corrige m-1 :
  - (i) le paragraphe ne dit pas ce qu'il advient quand le minimiseur existe hors de `BORNES_GAMMA`. Le moteur refuse alors le calcul, et le lecteur qui compare B(6), où γ n'est pas borné, au domaine borné de l'outil se pose précisément cette question ;
  - (ii) « l'optimalité numérique du point retenu [traitée] par les contrôles » peut se lire comme une garantie. Or le document admet lui-même que le critère peut avoir un optimum local distinct de l'optimum global (l. 19420-19421), et les fiches `foc` et `multi-demarrages` contrôlent une condition du premier ordre et un accord entre démarrages, sans certifier l'optimum global.

**5. Rigueur statistique générale à T = 8 : aucune confusion relevée.**
- Le diff n'ajoute ni p-value, ni loi asymptotique, ni affirmation de puissance.
- Ce qui est algébrique est dit « algébriquement identique » ; ce qui est numérique est dit « numériquement » (minimisation, contrôle par les tests) ; ce qui est mesuré est dit « propriété mesurée, non démontrée ».
- « log1p … plus précis pour u petit » est une propriété standard de l'arithmétique flottante, sans enjeu pour le dossier.
- Les interprétations sont marquées comme telles : « lecture retenue par l'outil », « sans valeur juridique propre », « l'outil les lit comme ».
- Aucune référence n'est fabriquée : la Q&R 2580 a été relue mot pour mot par la session, et ses métadonnées reconfirmées par `regulatory` le 17/11.
- Aucune affirmation non sourcée n'est relevée.

## Constats

### Bloquants : aucun. Majeurs : aucun.

### Mineurs

**m-1 (réserve du visa, rigueur, #586, `sec:spec-lognormale`, l. 3652-3653).** Remplacer :
```latex
        L'existence du minimiseur est traitée en section~\ref{sec:h4}, l'optimalité numérique du
        point retenu par les contrôles des fiches~\ref{fiche:foc} et~\ref{fiche:multi-demarrages}~;
```
par :
```latex
        L'existence du minimiseur est traitée en section~\ref{sec:h4}~; quand des démarrages à
        l'optimum ont $\gamma$ sur une borne de \code{BORNES\_GAMMA} sans qu'aucun satisfasse la
        condition de Kuhn et Tucker, le calcul est refusé (\code{usp\_valider\_ajustement()},
        §\ref{sec:controles}). L'optimalité numérique du point retenu est contrôlée, sans garantie
        d'optimum global, par les fiches~\ref{fiche:foc} et~\ref{fiche:multi-demarrages}~;
```
Ce texte reprend la règle de refus telle que la décrit déjà `sec:controles` (l. 4668-4680) et telle que le code l'applique. Il n'y a aucun effet sur les résultats.

**m-2 (facultatif, forme, #589, `sec:graines`, l. 2858).** Dans une même phrase, « bibliothèques de référence » côtoie « ses références » (les fichiers), ce qui crée une homonymie. Remplacer :
```latex
sous les bibliothèques de référence (propriété mesurée, non démontrée, ci-après), ne s'écartant pas
```
par :
```latex
sous le BLAS et le LAPACK de référence (propriété mesurée, non démontrée, ci-après), ne s'écartant pas
```
C'est la forme employée l. 2905 du même paragraphe.

**m-3 (facultatif, rigueur, #586, l. 3632-3633).** Le chapeau « sans approximation des formules » précède le point qui dit « minimise numériquement ». Pour qu'aucune lecture rapide n'étende l'exactitude au minimiseur, remplacer :
```latex
algébriquement identique, sans approximation des formules~:
```
par :
```latex
algébriquement identique, sans approximation des formules, seul le minimiseur de B(6) étant
approché numériquement (troisième point)~:
```

**m-4 (facultatif, précision de paraphrase, #586, paragraphe « Pertes agrégées »).** « relations linéaire et quadratique avec les primes acquises » omet « proportionnelle » et ne nomme pas les objets (B(2)(g)(i)-(ii) : « pertes agrégées attendues … en relation linéaire proportionnelle », « la variance des pertes agrégées est en relation quadratique »). Remplacer :
```latex
(relations linéaire et quadratique avec les primes acquises, loi log-normale)
```
par :
```latex
(espérance en relation linéaire proportionnelle et variance en relation quadratique avec les
primes acquises, loi log-normale)
```

**Forme, signalée à `docwriter` sans réserve.** En `sec:controles`, la phrase « Relèvent aussi de l'entreprise, … les critères de l'article 219 qui ne relèvent pas de l'annexe XVII » répète « relèvent ». On peut écrire « les critères de l'article~219 étrangers à l'annexe~XVII ».

## Constats hors périmètre (ADR 0018) : la session trie

| Emplacement | Constat | Gravité | Critère | Preuve |
|---|---|---|---|---|
| `.tex` l. 14175, fiche `multi-demarrages` | « démarrages atteignant le minimum global » : le code compte les démarrages à `TOL_OPTIMUM` du meilleur objectif *parmi les démarrages* (`abs(vals - best$value) < TOL_OPTIMUM`, `R/engine.R`), ce qui ne garantit pas le minimum global. La formule de κ̂ juste en dessous est exacte (min_{s'}) et le document admet ailleurs des optima locaux (l. 19420). Remplacement proposé : « atteignant le plus petit objectif obtenu parmi les démarrages ». | mineur | E5, à apprécier : c'est le mot « global » qui prête au code ce qu'il ne fait pas, alors que la formule le décrit bien | lignes citées ; `usp_ajuster()` |
| `.tex` l. 2906, `sec:graines` | La mesure d'identité entre exécutions, auquel renvoie le nouveau « ci-après », porte sur « les quatre fichiers » de M34, alors que la garde de la CI couvre aujourd'hui six cas. C'est historiquement exact (ADR 0011, point 5 : quatre `.rds`), mais un relecteur peut y voir une incohérence. Précision possible : « pour les quatre fichiers que comptait alors la référence ». | mineur | aucun (pas d'affirmation fausse) | `ls tests/reference/` : six `.rds` ; ADR 0011, l. 177 |
| Q&R AEAPP 2580, réponse 2 (B(2)(f)) | Déjà relevé par `regulatory` (§ 4 de son contrôle). Je le rapporte sans le réévaluer. | mineur | aucun | `regulatory-controle-aval.md`, § 4 |

## Retour

- **Statut** : `complet`.
- **Résultat** : visa sous réserves. La réserve unique est m-1 (refus hors de `BORNES_GAMMA` et absence de garantie d'optimum global, à dire dans « Équivalence avec le moteur »). m-2 à m-4 sont facultatifs. Questions 1 à 5 : fond conservé ou juste, sans confusion exact / asymptotique / numérique / simulé.
- **Preuves vérifiées** :
  - le diff complet du `.tex` ;
  - `R/engine.R` l. 187, 1436-1470, 1779-1800 ;
  - `test_modele_lognormal.R` l. 31-62 ; `test_calibration.R` l. 261-285 ;
  - `.tex` l. 2795-2918, 4668-4740, 12208-12245, 14162-14200, 19414-19426 ;
  - ADR 0011, points 2 et 5 du second amendement ;
  - prose consolidée de A(1)(a)-(d), B(1), B(2)(g), B(3)(a)-(d) et D(1), par extraction du XHTML (prose seule) ;
  - issue #589 lue.
- **Hypothèses** : aucune nouvelle. La validité de la lecture (ii) repose sur D-S2-1.
- **Non vérifié** :
  - les formules sur l'image : je m'appuie sur le contrôle de `regulatory` (matrice, lignes 3 à 8), sans relecture graphique de ma part ;
  - la compilation du `.tex` et `concordance_doc_moteur.R --strict`, qui relèvent de `docwriter` et de la session ;
  - le JOUE en anglais (déjà signalé).
- **Informations manquantes** : aucune pour ce visa.
- **Décisions non résolues** : la session décide d'appliquer m-2 à m-4 ; elle trie les constats hors périmètre (le mainteneur décide).
- **Critères déclenchés (§ 4)** : aucun. Il n'y a ni changement de résultat, ni désaccord avec `regulatory` (ses mineurs appliqués sont validés), ni question de validité à T = 8 dans ce diff.
- **Prochaine action recommandée** : `docwriter` applique m-1 (et, au choix de la session, m-2 à m-4) par un commit `docs:` Refs #586 (Refs #589 pour m-2), puis compile (skill `compiler-doc`). Je relis ensuite ce seul diff, sans nouvelle validation complète. Après cela vient le commit du PDF par la session principale, puis la sortie du brouillon.
