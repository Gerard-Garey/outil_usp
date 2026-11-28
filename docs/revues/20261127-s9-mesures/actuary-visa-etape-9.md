# S9, étape 9 : visa unique du diff du `.tex` (règle 9, ADR 0010)

> *Rédigé par l'agent actuary (IA), fiche `actuary-approfondi`, le 27/11/2026, sur `claude/mesures-t8` à la tête `1494d2c`, arbre propre. Je n'ai écrit aucun fichier et créé aucune issue. Périmètre lu : `git diff 0bc9ed5 1494d2c -- docs/latex/doc_tests_usp.tex docs/suivi-documentation/`, soit les cinq commits `6600567` (#421), `62b9271` (#420), `f45a364` (#367), `dade61c` (#379) et `1494d2c` (#494). J'ai vérifié chaque chiffre porté contre les tableaux `docs/tableaux/20261127-issue*.md`. Versé intégralement par la session principale (Q-54-10).*

## Verdict global : **validé avec corrections**

Les chiffres portés concordent avec les tableaux. La nature de chaque valeur est déclarée correctement : exact, quadrature d'une quantité exacte, simulation sous plan, Monte-Carlo pur ; l'erreur Monte-Carlo (fonction de B) est séparée de l'erreur d'échantillonnage (fonction de R) et de l'erreur en T. Aucune affirmation non fondée à T = 8.

Cinq corrections du `.tex` restent exigées, plus une du suivi :
- trois sont des inexactitudes de méthode ou de portée : C1, C2, C3 ;
- deux sont des cohérences internes : C4, C5 ;
- la dernière (C6) aligne `docs/suivi-documentation/`.

Aucune ne touche un résultat du moteur. Chacune se fait par un nouveau commit `docs:` rattaché à son issue (pas de réécriture), puis compilation de contrôle et `tests/concordance_doc_moteur.R --strict`.

## Corrections exigées

**C1 — #421 (`6600567`) : le décompte « 19 sur 26 » ne porte pas sur le déficit**
- Problème : le tableau 1 bis définit le coefficient comme |puissance − L₋| / (1 − |ρ|)^½. Aux deux couples de T = 4, comptés « stables », L₋ = 0 : la quantité stable est la puissance elle-même, pas le déficit 1 − puissance. Celui-ci vaut 0,9944 à 10⁻⁴ et 0,9994 à la garde, donc ses rapports (99 puis 999) ne sont pas stables. Le texte attribue au déficit une loi qui, pour ces couples, porte sur l'écart à la limite.
- l. 1339, remplacer « cette loi, non démontrée, est stable sur 19 des 26 couples » par : « rapportée à l'écart à la limite $|\mathrm{puissance} - L_-|$ (le déficit quand $L_- = 1$), cette loi, non démontrée, est stable sur 19 des 26 couples ».
- l. 9944-9946, remplacer « sur les 26 couples $(T, \alpha)$, 19 tiennent ce critère » par : « sur les 26 couples $(T, \alpha)$, l'écart à la limite $|\mathrm{puissance} - L_-|$ rapporté de même (le déficit quand $L_- = 1$, la puissance quand $L_- = 0$), 19 tiennent ce critère ».

**C2 — #379 (`dade61c`) : le test de classe n'est pas toujours McNemar**
- Problème : l. 19577 dit « test exact de McNemar apparié contre le point nul ». Or les cellules Merz-Wüthrich P1.CST20 et P1.DCAL sont tirées sous des graines distinctes de P1.H0 ; leur classe vient d'un test exact de Fisher bilatéral. C'est la note de F1 du tableau MW : « pour une cellule à graines distinctes (CST20, DCAL …), test exact de Fisher ».
- Insérer après « contre le point nul » : « (test exact de Fisher bilatéral pour l'ordonnée à l'origine et la dérive calendaire, tirées sous des graines distinctes de la cellule nulle) ».

**C3 — #379 (`dade61c`) : seuil manquant dans la fiche p globale**
- l. 19802, remplacer « \emph{Puissance} à $T = 8$ (tête de section)~: de » par « \emph{Puissance} à $T = 8$ (tête de section), au seuil $0{,}10$~: de ».
- Motif : les bornes 0,130–0,397 et 0,164–0,583 ne valent qu'à α = 0,10. À 0,05, la plage est autre (LC de 0,067 à 0,403). Le suivi dit bien « à α = 0,10 », pas le `.tex`. La fiche fait 5 929 caractères : la marge est large.

**C4 — #379 (`dade61c`) : cohérence avec les textes T-1 et T-2 cités mot pour mot**
- Problème : en tête de section, le `.tex` cite mot pour mot « (puissance non mesuree) » des textes T-1 et T-2. Quelques lignes plus bas, il dit la puissance mesurée sous plans. Un relecteur y lira une contradiction.
- Après « où [k] est le nombre de membres. » (vers la l. 19508), ajouter : « « Puissance non mesurée » s'entend des données traitées~: les mesures sous plan de la puissance (plus bas) ne s'y transposent pas, et celle de D., M2, C., G. et M4 n'est mesurée sous aucun plan. »
- Passage en tête de section, donc hors plafond.

**C5 — #494 (`1494d2c`) : nuancer la rubrique 6 de `mw:m3cor` (question ouverte 1)**
- l. 18588, remplacer « ce qui rend le test très peu puissant. » par « ce qui limite sa puissance (mesurée en rubrique~7). »
- Motif : « très peu puissant » est démenti, dans la même fiche, par 0,474 [0,429 ; 0,519] (classe intermédiaire) à ρ = 0,5 sous P1. La fiche fait 8 067 caractères ; la nouvelle phrase est plus courte.

**C6 — suivi (`docs/suivi-documentation/III-M.md`, entrée `sec:lecture-conjointe`)**
- Le suivi annonce dans le paragraphe la « convention du dénominateur (… ; T-F3 prend toutes les réplications, Q4 de l'étape 5) ». Le `.tex` ne porte que la première moitié. Retirer la clause T-F3 du suivi, ou la noter « non reprise ».
- Remplacer « écart signalé à `coder` (hors S9) » par la décision de tri ci-dessous (mineur, écarté, clause C4 posée au `.tex`).

## Décision sur les écarts déclarés par docwriter

1. **#421, T = 4 : « six points de ρ = −0,98 à la garde » : accepté.** Le tableau donne à α = 0,10 : 0,0737 (−0,98), 0,0539, 0,0176, 0,0056, 0,0018, 0,0006, tous sous 0,10. À −0,95, la puissance vaut 0,1062. Le § 1 ter dit 6. Mon « ρ ≤ −0,99 » de l'étape 7 était faux.
2. **#421, −0,999 et −0,99999 non recoupés : accepté.** Le recoupement couvre {0 ; −0,9 ; −0,99 ; −0,9999 ; garde}. J'avais omis −0,99999. Une reformulation facultative lèverait une lecture a contrario : « dans la zone ρ ≤ −0,999, les valeurs à −0,999 et −0,99999 ne sont pas recoupées ». Les autres points de la grille (−0,98, −0,95, …) ne sont pas recoupés par cette simulation non plus ; la liste explicite des points recoupés suffit à l'exactitude.
3. **#421, fichier du 31/10 remplacé par celui du 27/11 : accepté.** K421-5 donne 31 lignes de T = 8 identiques. Il ne reste aucune occurrence de `20261031-issue164` dans le `.tex`, le fichier du 31/10 reste versionné, et le remplacement est tracé en I, II et III-H.
4. **#367, fiche Grubbs inchangée, chiffres en `sec:nature` : accepté.** La rubrique 6 de la fiche reste vraie et est confirmée. Aucune réserve n'est réduite (CONVENTIONS § 1, « le fond l'emporte »), et `sec:nature` renvoie à `fiche:grubbs`.
   - **La phrase des « de l'ordre de 2,4·10⁶ tirages » est à garder.** C'est un calcul conditionnel, déclaré comme tel (« si elle valait 0,1005 », « approximation normale »), refait par docwriter : (2,576·√(p(1−p))/|p − α|)² = 2,40·10⁶. Il dit utilement qu'aucun B praticable ne fixe ce verdict.
5. **#379, sixième cellule à taux ≥ 0,5 (B. sous R, J1, 0,503 [0,445 ; 0,561], intermédiaire) : accepté.** Elle est dans F1 de J1. Au seuil 0,10, les six cellules sont M1/CST20, M1/DCAL, LC/CST20, F./R (J1 et J2) et B./R (J1) ; toutes les autres cellules mesurées sont sous 0,5. J'avais omis la sixième.
6. **#379, non-spécificité reprise pour A seul, complétée par R sur J1 : accepté.** Sous T, B. est la famille visée ; mon « sous A et sous T » était une erreur. B. 0,503 contre F. 0,520 sous R sur J1 est exact.
7. **#379, chiffres en tête de `sec:lecture-conjointe`, constat facultatif sur D. sous A non repris : accepté.** La fiche p de famille fait 10 451 caractères sur 3 pages, au plafond ; la tête de section est hors plafond. Le constat sur D. était facultatif, non significatif après multiplicité, et reste tracé dans mon avis de l'étape 7 versé.
8. **#494, lien à D(2)(h)(ii) non ajouté, DW cité en décompte (1 cellule sur 6) : accepté.** La rubrique 2 de `mw:m3cor` porte déjà « lecture de D(2)(h)(ii) retenue par l'outil, non sa lettre » (l. 18557), ce qui remplit ma consigne 7. Le décompte est exact (P1.AR03 à 0,05, McNemar 0,043) et le détail est au suivi III-M.

## Questions ouvertes de docwriter

- **`mw:m3cor`, rubrique 6 : à nuancer.** C'est la correction C5.
- **L₋ comme « argument élémentaire de convergence dominée, sans référence » : acceptable.**
  - Sous ρ → −1, la covariance de l'AR(1) stationnaire tend vers v_T v_Tᵀ. Le vecteur centré tend vers ξ M v_T, avec ξ ≠ 0 presque sûrement et M v_T ≠ 0. DW est invariant d'échelle et continu en M v_T ; la p-value bilatérale est continue, car la loi nulle est continue.
  - DW(v_T) est intérieur au support : par exemple, à T = 4, 3 < 2 + 2 cos(π/4) ≈ 3,41. La convergence dominée donne donc la puissance → 1{p_v < α} dès que p_v ≠ α.
  - « Sans référence » est honnête.
  - Précision facultative : « presque sûrement » suppose la construction récursive du tableau (z₁ = e₁, z_t = ρ z_{t−1} + √(1−ρ²) e_t) ; « en loi » suffirait.

## Constat hors périmètre de docwriter (T-1/T-2, « (puissance non mesuree) »)

**Mineur, écarté. Critère ADR 0018 : aucun.**
- E5 vise une documentation qui « dit que le code fait une chose qu'il ne fait pas ». Or « puissance non mesurée » énonce l'état de la preuve, pas un comportement du code (`R/engine.R` l. 5543 et 5559-5560).
- Pour les données traitées, l'énoncé reste vrai : les mesures sont des constats sous plan, sans transposition, et cinq familles ne sont mesurées sous aucun plan.
- Aucun effet sur σ_USP, un verdict, une p-value, la conformité ou la reproductibilité.
- La seule gêne, une contradiction apparente avec le `.tex`, est levée côté documentation par C4, sans toucher au code gelé.

## Retour

- **Statut** : `complet`.
- **Résultat** : **validé avec corrections** (C1 à C6 ci-dessus). Les huit écarts déclarés sont acceptés. Question 1 : nuancer (C5). Question 2 : acceptable.
- **Preuves** :
  - *Vérifié* (diff relu et chiffres recoupés) :
    - #421 : tableau §§ 1, 1 bis, 1 ter, 2 (T = 8 : −1,73 à +0,34 ET, 0 signalé sur 130, 67 négatifs), 3 (L₋, marge 6,042e-4, L₊ 0,5899175, écart maximal 1,154e-6), 4 (19 / 3 / 4) et 115 contrôles ;
    - #420 : T3 (0,9779 ± 0,00061 ; 0,9763 ± 0,00044 ; 0,8999 ± 0,0072 ; 0,8809 ± 0,0091) ;
    - #367 : avis de l'étape 7, § 3 (4 019 / 39 996, [0,09665 ; 0,10442]) ;
    - #379 : F1 LN (J1 et J2) et F1 MW ligne à ligne ; méthode Fisher de CST20 et DCAL (note de F1) ;
    - #494 : F3 et F4 ;
    - `tests/unitaires/test_dw_limite_rho.R` existe et couvre T = 4, 5 et 8 ;
    - taille des fiches touchées mesurée sur la source : DW 10 396, p-famille 10 451, p-globale 5 929, `mw:m3cor` 8 067, Grubbs 8 807, CvM 5 832 caractères ;
    - `mw_stat_correlation_dev()` (`R/engine.R` l. 14848 et suivantes) : `idx <- 0:(I - k - 1)` et `if (length(idx) < 3) next`.
  - *Hypothèses* : aucune nouvelle. Le calcul des 2,4·10⁶ tirages est conditionnel et déclaré comme tel.
  - *Non vérifié* : compilation et pagination après C1 à C5. À contrôler par la skill `compiler-doc` et `tests/controle_doc_nd.R` ; seule la fiche p-globale (C3) est touchée parmi les fiches, avec une marge large.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : le sort du constat hors périmètre 2 ci-dessous (issue, ou correction dans la série #494 de S9) revient à la session, puis au mainteneur.
- **Critères déclenchés** (`routage.md`, § 4) : aucun changement de résultat, aucun désaccord avec `audit` ni avec un ADR. Quatre erreurs de mon avis de l'étape 7, relevées par docwriter, sont reconnues : −0,98, −0,99999, « sous T », sixième cellule. Ce sont des autocorrections, pas un désaccord entre agents.
- **Constats hors périmètre** (ADR 0018) :
  1. T-1/T-2 « (puissance non mesuree) » : **aucun critère, mineur, écarté**. Motifs ci-dessus ; levé par C4.
  2. **l. 10574** (tableau des tests fragiles, ligne « Corrélation entre années de développement », cellule hors diff dans une rangée modifiée par `1494d2c`) : « Cinq à six paires de colonnes seulement comptent au moins trois observations à $T = 8$ ».
     - Sur un 8 × 8, le code retient au plus **quatre** paires : `mw_stat_correlation_dev()`, I = 7, k = 1..4.
     - La fiche dit de même : l. 18587, « seules quatre paires », et l. 18594, n_k = 6, 5, 4, 3.
     - **Critère E5** (affirmation fausse sur le code), donc marquant. Réserve : la phrase serait juste pour certains trapèzes, mais elle ne le dit pas.
     - Correction proposée : « Quatre paires de colonnes au plus comptent au moins trois facteurs sur le triangle $8\times 8$ ». Elle est faisable en un commit `docs:` minimal si la session et le mainteneur le rattachent à S9 ; sinon, une issue.
  3. l. 8330 (`sec:nature`) : « l'ensemble du dispositif reste très peu puissant ». C'est un cadrage global, désormais nuancé par des taux de 0,56 à 0,76 dans trois cellules. **Aucun critère, mineur, écarté.**
  4. Erreurs de mon avis de l'étape 7 (écarts 1, 2, 5, 6) : **aucun critère, mineur**, corrigées par docwriter.
- **Prochaine action recommandée** : `docwriter` applique C1 (commit `docs:` Refs #421), C2 à C4 (Refs #379), C5 (Refs #494) et C6 (suivi, avec le commit de l'issue concernée). Compilation de contrôle et `concordance_doc_moteur.R --strict`. La session décide du constat 2 (E5). Puis je relis le seul diff de ces corrections (revue sur diff, règle 10), sans nouveau visa intégral.

---

# Revue sur diff des corrections (`git diff ba70146 6bda833`)

> *Rédigé par l'agent actuary (IA), même fiche, le 27/11/2026. Versé intégralement par la session principale.*

Les six corrections sont conformes à mon texte. **Le visa de l'étape 9 est acquis**, sous réserve de la compilation de contrôle et de `concordance_doc_moteur.R --strict`, que je n'ai pas lancées.

**Chaque correction contre mon texte :**
- **C1 (`ee1ea80`, Refs #421) : oui.**
  - Le texte demandé est posé aux deux endroits, l. 1339-1340 (inventaire) et l. 9946-9948 (protocole).
  - La reformulation facultative (« Dans la zone ρ ≤ −0,999 … ») n'est appliquée qu'au paragraphe de protocole. C'est admissible : la fiche Durbin-Watson et la ligne du tableau de traçabilité gardent une liste explicite des points recoupés, qui reste exacte.
- **C2 (`393b6fd`, Refs #379) : oui.** La parenthèse sur Fisher est insérée à l'endroit demandé (l. 19582-19583), au mot près.
- **C3 (`393b6fd`) : oui.** « au seuil $0{,}10$ » est ajouté l. 19807.
- **C4 (`393b6fd`) : oui.** La clause est posée après la citation de T-2 (l. 19510-19512), au mot près.
- **C5 (`6bda833`, Refs #494) : oui.**
  - Une redondance vient de mon propre texte : la phrase porte deux fois « rubrique~7 » (« … trois facteurs (rubrique~7), ce qui limite sa puissance (mesurée en rubrique~7). »).
  - C'est sans effet sur le fond. Si la session veut la retirer, une retouche facultative suffit : « … ce qui limite sa puissance, mesurée en même rubrique. » Elle n'est pas exigée.
- **C6 (`393b6fd`, suivi III-M) : oui.**
  - La clause T-F3 est marquée « n'est pas reprise dans le guide ».
  - La mention « écart signalé à `coder` (hors S9) » est remplacée par le tri : « constat mineur, écarté (ADR 0018, aucun critère) », levé par la clause C4.
  - Les corrections C1 et C5 sont tracées en I, II et III-M avec renvoi au visa.

Le constat 2 (l. 10574, critère E5) n'est pas corrigé, ce qui est volontaire et noté : il est soumis au mainteneur et n'empêche pas le visa.

## Retour (abrégé)
- **Statut** : `complet` pour la relecture du diff ; la compilation n'est pas vérifiée par moi.
- **Résultat** : C1 à C6 conformes ; **visa de l'étape 9 acquis**.
- **Preuves** : *vérifié* par lecture intégrale de `git diff ba70146 6bda833 -- docs/latex/doc_tests_usp.tex docs/suivi-documentation/` (commits `ee1ea80`, `393b6fd`, `6bda833`). *Non vérifié* : compilation, pagination, `controle_doc_nd.R` et `concordance_doc_moteur.R --strict` (à faire par la skill `compiler-doc`).
- **Décisions non résolues** : constat 2 (l. 10574, critère E5), à trancher par le mainteneur : issue, ou commit `docs:` minimal dans S9.
- **Critères déclenchés** : aucun.
- **Constats hors périmètre** : la double mention « rubrique~7 » de C5 relève du critère « aucun » : mineure, écartée.
- **Prochaine action recommandée** : compilation de contrôle et `concordance_doc_moteur.R --strict`, puis la session poursuit la fiche S9 (verser cette revue dans `docs/revues/20261127-s9-mesures/`, décision du mainteneur sur le constat 2).
