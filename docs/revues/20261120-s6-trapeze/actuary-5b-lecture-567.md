# S6, étape 5 (b), #567 : lecture de l'étude de niveau des tests de Merz-Wüthrich sur 8×5, 8×6 et 8×7, préparation du point d'arrêt D2

> *Rédigé par l'agent actuary (IA).* Consultation de jugement en lecture seule, sur `claude/merz-wuthrich-trapeze`, tête `5297cd8` ; commit mesuré `425c1c9`. Je n'ai rien écrit dans le dépôt : ni fichier, ni issue, ni commentaire.
>
> Mes calculs sont des scripts R de lecture placés dans le dossier temporaire de la session (`…/scratchpad/lecture567/`, texte intégral en annexe). Ils lisent :
> - le brut versé ;
> - le brut de #297 ;
> - l'oracle non versionné `oracle.tsv` du dossier de travail de la mesure (`…/scratchpad/issue567-travail-L0/`), dont le md5 `5bdafe15…` est égal au T0.
>
> Aucun nouveau triangle n'a été tiré. Deux exceptions, toutes deux à des graines du protocole et sans extension de R :
> - une régénération de contrôle des statistiques observées ;
> - un diagnostic de mécanisme, qui relance le bootstrap sur 300 triangles déjà mesurés (§ 4).
>
> Légende : **[V]** vérifié (source relue ou commande exécutée), **[H]** hypothèse, **[NV]** non vérifié.

## 0. Synthèse

1. **K3 (témoins oracle, Θ0 mécanique).**
   - Les trois cellules « non expliqué » ne forment que **deux événements**. HomogF a une statistique observée **identique au bit** sur 8×5, 8×6 et 8×7, et des oracles identiques [V]. Les cellules 8×5 E et 8×6 E HomogF 0,05 sont donc un seul calcul, compté deux fois.
   - Ni l'un ni l'autre n'est imputable à l'implémentation du trapèze :
     - le témoin n'emploie ni le bootstrap ni le code propre au trapèze ;
     - les triangles mesurés et l'oracle sortent de la même fonction, avec les mêmes paramètres ;
     - j'ai régénéré indépendamment 600 triangles de contrôle, à l'identique [V].
   - La discrétude n'explique pas le signal HomogF E. C'est la vérification prévue d'avance par l'annotation du 05/11 de #206, point 4, qui se déclenche ici :
     - la masse de la valeur seuil vaut 1/20 000 ;
     - la discrétude ne peut produire qu'un déficit de rejets, alors que le signal est un excès.
   - Reste une **fluctuation d'échantillonnage** :
     - p brutes bêta-binomiales 0,0032 et 0,0038, parmi 156 cellules ;
     - la réunion avec l'échantillon indépendant de #297 donne une p bêta-binomiale de 0,305 pour HomogF E.
   - Réserve : sous E, les échantillons de #567 et de #297 diffèrent entre eux sur HomogF et Runs (permutation *post hoc*). Aucun mécanisme trouvé ne l'explique (§ 2.5).
   - **Jugement : expliqué quant à l'implémentation.** Je recommande que le mainteneur lève Θ0 avec ce motif (précédent du 05/11/2026).
2. **K-T6 (Runs E 0,05, 8×7 contre 8×8) : expliqué, aucun défaut d'implémentation.**
   - L'écart vient entièrement de la **composition des deux échantillons** sur les atomes extrêmes de Runs. À atome égal, les décisions du moteur sont les mêmes sur 8×7 et sur 8×8 (Cochran-Mantel-Haenszel exact, p = 0,69) [V].
   - Sous N, l'écart est de sens opposé et non significatif.
   - Runs est d'ailleurs une ligne de **diagnostic** (#312), sans verdict.
3. **Constat nouveau, majeur, dans le périmètre de #567 : PenteIntra est trop libéral sur le 8×7.**
   - La comparaison appariée « moteur contre test idéal » sur les mêmes triangles montre que le bootstrap rejette nettement plus que le témoin sur le 8×7 :
     - à 0,05, 72 contre 49 sous N et 75 contre 49 sous E ;
     - McNemar p ≈ 5·10⁻⁶ ;
     - l'excès est de 2 points de plus que sur le carré de #297 (p = 1,2·10⁻⁴ sous N) [V].
   - **Mécanisme**, [H] forte, appuyée par un diagnostic à nombres aléatoires communs [V] :
     - la colonne J−1 est simulée avec σ̂ de la règle (Q-2a-2) ;
     - or la pente relative pondère les colonnes par 1/σ̂_j², et n'est donc **pas invariante d'échelle par colonne** ;
     - en simulant J−1 avec l'estimateur direct, le moteur retrouve le témoin (N : 6 = 6 à 0,05).
   - Ma spécification se trompait ici (§ 0 point 2 et § 3 de `actuary-2a-specification-567.md`). Le niveau du 8×7 n'est pas « égal en loi à celui de #297 » pour PenteIntra.
   - Classe K1 du 8×7 : « non tranché » côté libéral (N 0,072, E 0,075 à 0,05, contre ρ = 0,048).
4. **Profil après levée de Θ0 : Θ2** (MinP4 N 0,05 non tranché, côté conservateur, sur 8×5 et 8×6), **plus la réserve PenteIntra 8×7**, hors de la grille Θ.
   - **Recommandation pour D2 : option (a′)**, extension avec réserves documentées.
   - Le choix entre (a′), (b), (c) et (d) revient au mainteneur (§ 5).
5. **K-T4 et K-T7 : rien d'alarmant pour un verdict.**
   - Pour σ_USP, la règle de minimum (prescrite) donne, sur le 8×7 de ce plan, une √MSEP inférieure de plus de 10 % à celle de l'estimateur direct dans 37 à 42 % des triangles. C'est une propriété de la formule réglementaire sous ce plan, pas de l'implémentation. Elle est à documenter.
   - Taux de M4 : 0 partout.
6. **Seuil « macro » atteint à D2** si l'extension est retenue (moteur et application changent d'interface) : Fable est **à proposer** au mainteneur.
   - L'**ADR 0005 est à annoter** par `architect` dans tous les cas : (A) → (B) avec la forme consolidée seule, ou refus motivé.

## 1. Provenance et intégrité (vérifiées)

- md5 à la tête `5297cd8`, égaux au JOURNAL :
  - `.md` `adf5de22…` ;
  - brut `9fcb59cd…` ;
  - script `tests/niveau_mw_trapeze_t8.R` `d7d1a0e6…` ;
  - `R/engine.R` `faf36c54…` ;
  - protocole `00317e14…`.
- `git diff --stat 425c1c9 HEAD -- R/ tests/` est vide. Les commits postérieurs sont `docs:` et `tests:` (sorties).
- `INTEGRITE OK` ; contrôles (1), (a), (m4), (g), (g′), (c1), (r297), (o), (t), (graines), (m), (i1) et (rep) à OK [V, lecture du rapport].
- Recalculs indépendants sur le brut, égaux au rapport [V] :
  - les k des cellules K1 citées ici ;
  - les p bêta-binomiales brutes des deux signaux (0,003173 × 13 = 0,0412 ; 0,003776 × 13 = 0,0491) ;
  - K-T4 (`a4`).
- **Régénération indépendante** (`a6`) : générateur réécrit dans mon script, aux graines de P3 amendé, statistiques par `.mw_stats()` ; comparaison à 17 chiffres [V] :

  | Échantillon | Triangles égaux sur les 13 clés |
  |---|---|
  | mesurés 8×5 E | 150 / 150 |
  | mesurés 8×7 E | 100 / 100 |
  | oracle 8×5 E | 150 / 150 |
  | oracle 8×7 E | 100 / 100 |
  | mesurés 8×5 N | 50 / 50 |
  | oracle 8×5 N | 50 / 50 |

## 2. Question 1 : signaux K3 sous E

### 2.1 Ce que teste le témoin K3, et ce qu'il ne peut pas tester

- p_or confronte la statistique observée d'un triangle mesuré à l'oracle de N0 = 20 000 triangles de même DGP. Le témoin n'emploie **ni B ni le bootstrap**.
- Ses erreurs sont donc :
  - celle de R (échantillon de triangles) ;
  - celle de N0 (oracle réalisé).
- La règle bêta-binomiale du 05/11 rend compte des deux, de façon exacte pour une statistique continue.
- Il ne dit rien de l'erreur à T = 8 du test bootstrap (τ − ρ, K1).
- Il détecte une différence de loi entre triangles mesurés et oracle : génération, admission ou chemin de calcul. Ici :
  - même fonction `triangle_G()` pour les deux, avec la même DGP [V, script l. 442 et 646] ;
  - admission à 100 % des deux côtés ;
  - (g), (i1) et ma régénération (§ 1) [V].

### 2.2 HomogF : une statistique invariante par géométrie

- `mw_test_homogeneite_f()` ne retient que les colonnes à au moins 4 facteurs (`length(idx) < 4`, `R/engine.R` l. 15295) [V], soit j = 0..3 dans **toutes** les géométries 8×5 à 8×8.
- Elle ne lit que des facteurs : aucun σ, donc ni la règle ni l'estimateur direct.
- Statistiques observées et oracles identiques au bit [V, `a1`, `a7`] :
  - entre 8×5 et 8×6 : 2 000 / 2 000 sous N et sous E ;
  - le 8×7 est égal aux 1 000 premières.
- Il en va de même pour ExpVar, Courbure et MinP4. CorrDev, BP, Origine et Alpha sont identiques entre 8×6 et 8×7 seulement.
- Conséquences :
  - les cellules « 8×5 E HomogF 0,05 » et « 8×6 E HomogF 0,05 » sont **un seul événement** (mêmes 132 / 2 000, mêmes p) ;
  - le 8×7 en est la première moitié (67 / 1 000, p de Holm bêta-binomiale 0,296) ;
  - le code propre au trapèze (colonne J−1, σ̂ direct, vivier) **n'intervient pas** dans ce signal.

### 2.3 Vérification prévue d'avance par l'annotation du 05/11 de #206, point 4 : déclenchée et faite

Condition : « à la prochaine campagne sur des triangles indépendants, un signal d'HomogF à 0,05 (Holm binomiale < 0,05) ouvre une analyse de la discrétude d'HomogF et du traitement des ex æquo. Cette analyse relève la masse de la valeur seuil S_(N − c1) de l'oracle. »

- **Déclenchée.** Triangles indépendants de #297 (graines disjointes) ; p de Holm binomiale 0,0222.
- **Masse de la valeur seuil** [V, `a1`] : oracle 8×5 E, c1 = 999, S_(N−c1) = 13,04452856, **masse 1 / 20 000**. Aucune des 2 000 valeurs mesurées ne lui est égale. Même ordre de grandeur à 0,10, 0,025 et 0,01 (1 à 3 / 20 000).
- **Ex æquo** :
  - 10 975 valeurs distinctes sur 20 000 dans l'oracle ;
  - 1 350 des 2 000 valeurs mesurées sont égales à une valeur de l'oracle.
  - L'aplatissement (`engine_aplatir_ex_aequo`) est appliqué par le même code aux mesures et à l'oracle : il ne peut pas créer de différence de loi entre eux.
- **Sens de l'erreur** (annotation du 05/11, point 3, établi) : la discrétude rend k stochastiquement plus petit que sous la loi bêta-binomiale. Elle ne peut pas produire un **excès** de rejets. Or le signal E est un excès (τ_or = 0,066 pour une taille de 0,050).
- **Conclusion** : la discrétude d'HomogF n'explique pas ce signal.

### 2.4 Multiplicité, réplication indépendante, comparaison appariée

**p exactes par permutation** (`a5`, échangeabilité mesures / oracle, 4 000 permutations, erreur Monte-Carlo ≈ 0,001) :
- HomogF E 0,05 : p = 0,0040 ;
- Runs 8×7 E 0,05 : p = 0,0050.

Elles confirment les p bêta-binomiales brutes (0,0032 et 0,0038). La classe mécanique « non expliqué » est donc robuste à l'approximation bêta-binomiale.

**Multiplicité** :
- 156 cellules K3 (6 (G, loi) × 13 clés × 2 α), réparties en 12 familles de Holm.
- Avec une correction sur toutes les cellules, aucun des deux signaux ne subsiste (156 × 0,0032 ≈ 0,5), même en ne comptant qu'une centaine de cellules distinctes.
- Ce n'est pas la règle de P7, qui corrige par 13. Je le donne comme élément de jugement, comme l'annotation du 05/11, point 4 (« Holm sur 52 »).

**Réplication indépendante** (`a1`, `a2`) :
- L'échantillon E de #297 (2 000 carrés, même loi d'HomogF, colonnes 0..3) donne, contre l'oracle de #567, 84 / 2 000 = 0,042 (p bêta-binomiale 0,123).
- La réunion des deux (4 000 triangles) donne 216 / 4 000 = 0,054 (p 0,305).
- Les deux moitiés de l'échantillon de #567 sont homogènes (0,067 et 0,065).

**Comparaison appariée moteur / témoin** (`a2`, `a8`), sur les mêmes triangles. Elle sépare l'erreur de R de l'erreur à T = 8 du test bootstrap.
- HomogF E 0,05, 8×5 : moteur 121, témoin 132 (5 rejets du moteur seul, 16 du témoin seul).
- Le τ de K1 (0,0605, « écart mineur ») est donc un **effet de l'échantillon** (erreur de R). Il ne vient pas d'une erreur à T = 8 : à triangles égaux, le moteur est même légèrement plus conservateur que le test idéal.

### 2.5 Réserve : dispersion entre campagnes sous E (non expliquée)

- **Permutation** sur la réunion (`a5`, *post hoc*, Holm sur 13 par loi) : l'échantillon E de #567 et celui de #297, de même loi, diffèrent face au même oracle :
  - HomogF : 0,066 contre 0,042, p = 0,001, Holm 0,012 ;
  - Runs : 0,045 contre 0,022, p = 0,00025, Holm 0,003.
- Sous N, aucune clé ne diffère (p de Holm ≥ 0,92).
- **KS** : HomogF E, #567 contre oracle p = 0,012, #297 contre oracle p = 0,157 ; sous N, 0,82 et 0,68.
- **Témoins HomogF à 0,05 sur les quatre évaluations indépendantes** :

  | Campagne | Loi | Taux | Référence |
  |---|---|---|---|
  | #297 | N | 0,0355 | son oracle |
  | #297 | E | 0,042 | son oracle |
  | #567 | N | 0,0525 | |
  | #567 | E | 0,066 | |

  Le taux moyen est voisin de 0,05, avec une dispersion plus forte que ne le prévoit la loi bêta-binomiale.
- **Ces p sont calculées après sélection** sur les cellules qui ont signalé : elles ne valent pas test.
- Je n'ai trouvé aucun mécanisme :
  - même générateur, mêmes paramètres, régénération exacte ;
  - une dépendance entre triangles d'un même échantillon toucherait toutes les clés, or 8 des 10 clés comparables sont homogènes.
- Une propriété du générateur aléatoire sur ces plages de graines n'est **pas vérifiée** [NV].
- **Le point ne concerne pas le code du trapèze.** Le même type de signal existait sur le carré (#297 : N HomogF et E Runs).

### 2.6 Runs 8×7 E 0,05 (K3)

- Région réalisée par l'oracle [V, `a2`, valeurs exactes] : {−2,40 ; −2,00 ; −1,60 ; 2,80 ; 3,20 ; 3,60 ; 4,00}, m_r = 555 / 20 000 = 0,0278. L'atome 2,40 est à cheval et non rejeté.
- Taux : 45 / 1 000 (#567) ; 44 / 2 000 (#297, contre le même oracle) ; réunion 89 / 3 000 = 0,0297.
- La région est **robuste** : les queues cumulées de l'oracle (156 en bas, 399 en haut) sont loin du seuil c = 499. Il n'y a donc aucun effet de sélection de la région.
- L'excès se concentre sur deux atomes :
  - −1,60 : 14 observés, 6,05 attendus ;
  - 2,80 : 22 observés, 14,2 attendus.
- Sur toute la loi, khi-deux #567 contre oracle p = 0,13 ; homogénéité à trois échantillons p = 0,35 (`a1`). C'est une fluctuation de queue d'un échantillon de 1 000.
- Runs est une ligne de **diagnostic** sans verdict (`R/engine.R` l. ~17035, « Diagnostic par decision, sans verdict ni p-value retenue », #312) [V].

### 2.7 Jugement (question 1)

Les signaux K3 sous E ne viennent **ni d'un défaut d'implémentation ni de la discrétude**. Ce sont des fluctuations de l'échantillon de triangles (erreur de R), rendues visibles par une correction de multiplicité limitée à chaque famille de 13.

La classe mécanique « non expliqué » de la règle bêta-binomiale reste exacte et ne doit pas être réécrite. Mon jugement, au sens de Θ0 (« implémentation à revoir »), est : **expliqué**. Réserve : la dispersion entre campagnes sous E du § 2.5.

## 3. Question 2 : K-T6, Runs E 0,05 (8×7 contre 8×8)

- **Test publié** : 43 / 1 000 contre 45 / 2 000, Fisher p = 0,0026, Holm 0,034.
- **Stratification par atome** (`a2`) : les décisions du moteur à atome donné sont identiques :

  | Atome | 8×7 | 8×8 |
  |---|---|---|
  | −1,60 | 14 / 14 | 10 / 10 |
  | 2,80 | 20 / 22 | 20 / 22 |
  | −1,20 | 0 / 13 | 3 / 35 |

  - CMH exact sur les atomes informatifs : p = 0,689.
  - Taux du 8×7 repondéré à la composition du 8×8 : 0,0210, contre 0,0225 observé sur le 8×8.
- **Concordance moteur / témoin** :
  - 8×7 : 43 rejets communs, 0 du moteur seul, 2 du témoin seul ;
  - 8×8 : 42, 3 et 2.
- **Sous N** :
  - 21 / 1 000 contre 55 / 2 000, p = 0,325, écart de sens opposé ;
  - CMH p = 0,53 ; taux repondéré 0,0286 contre 0,0275.
- **Jugement** : l'écart est **expliqué** par la composition des échantillons, qui est le même phénomène que le signal K3 du § 2.6. Ce n'est ni un défaut d'implémentation ni un effet de géométrie, et cela ne touche aucun verdict (ligne de diagnostic).
- **Limite du contrôle.** Un Fisher non apparié entre échantillons indépendants de triangles est à la fois peu puissant et confondu par la composition pour une statistique à atomes. Le K-T6 tel que fixé n'a pas vu l'effet réel du § 4. La comparaison appariée moteur / témoin est le bon instrument (constat m3).

## 4. Constat nouveau (majeur, dans le périmètre de #567) : PenteIntra sur le 8×7

**Mesure appariée** (`a8`, `a8b`, `a9`) :

| Échantillon | α | N : moteur / témoin (moteur seul / témoin seul) | E : moteur / témoin (moteur seul / témoin seul) |
|---|---|---|---|
| 8×7 | 0,05 | 72 / 49 (25 / 2) | 75 / 49 (29 / 3) |
| 8×7 | 0,10 | 120 / 95 (28 / 3) | 128 / 99 (30 / 1) |
| 8×8 de #297, témoin contre l'oracle du 8×7 | 0,05 | 122 / 114 (15 / 7) | 109 / 80 (31 / 2) |
| 8×5 | 0,05 | 97 / 99 | 102 / 104 |
| 8×6 | 0,05 | 95 / 102 | 107 / 101 |

- McNemar sur le 8×7 : de 3·10⁻⁸ à 5,6·10⁻⁶.
- Excès apparié du 8×7 sur le carré : +0,019 sous N (Wilcoxon p = 1,2·10⁻⁴) ; +0,0115 sous E (p = 0,041).
- Rien sur 8×5 et 8×6.
- K1 du 8×7 à 0,05 : N 0,072 [0,057 ; 0,090], E 0,075 [0,059 ; 0,093], contre ρ = 0,048 et 3ρ/2 = 0,072 : **« écart non tranché », côté libéral**. Le carré de #297 était à 0,061 (N) et 0,0545 (E).

**Mécanisme** :
- `.mw_pente_relative()` (`R/engine.R` l. 14661) pondère par w = C f̂² / σ̂_j² [V, lecture]. La loi du t sous H0 dépend donc des σ relatifs des colonnes quand les σ̂_j sont bruités. Elle n'est **pas** invariante d'échelle par colonne.
- Sur le 8×7, la colonne J−1 = 5 (2 facteurs) entre dans PenteIntra et est simulée avec σ̂ de la règle (Q-2a-2). Sous ce plan, la règle vaut en médiane 0,09 fois le vrai σ²_{J−1} (K-T4). Le monde bootstrap ne reproduit donc pas la loi observée.
- Sur le carré, la colonne à 2 facteurs est simulée avec son σ̂ direct, et J−1 (un facteur) n'entre pas dans PenteIntra.

**Diagnostic** (`a10`, `a11`) :
- Conditions : 150 triangles 8×7 par loi, déjà mesurés ; **même graine de bootstrap** ; seule différence, σ²_{J−1} de simulation remplacé par l'estimateur direct.
- Contrôle : les p « règle » recalculées sont égales au brut sur les 13 clés.

| Loi | α | Moteur (règle) | Moteur (direct) | Témoin |
|---|---|---|---|---|
| N | 0,05 | 9 | 6 | 6 |
| N | 0,10 | 14 | 11 | 11 |
| E | 0,05 | 20 | 17 | 13 |
| E | 0,10 | 28 | 25 | 23 |

- Écart médian |Δp| : 0,024 (N) et 0,026 (E).
- **Aucune autre clé** ne change de nombre de rejets, à 0,10 ni à 0,05, sur ces 300 triangles. Les autres p n'ont pas été comparées une à une.
- Ce diagnostic est petit (150 triangles par loi). Il est **cohérent** avec le mécanisme et ne constitue pas une mesure de niveau.

**Correction de ma spécification** (`actuary-2a-specification-567.md`) :
- § 0, point 2 (« son niveau doit donc égaler, en loi, celui de #297 ») et § 3 (invariance d'échelle par colonne, [H]) sont **faux pour PenteIntra**. Les statistiques observées du 8×7 sont bien celles du 8×8, mais pas la loi bootstrap de référence.
- L'effet existe parce que J−1 entre dans PenteIntra dès que n_{J−1} ≥ 2, c'est-à-dire pour tout trapèze. Son ampleur et son **signe dépendent du profil** des σ : ici la règle sous-estime fortement sur le 8×7, et en moyenne surestime sur 8×6 et 8×5, où rien n'est mesuré en apparié.
- Le constat ne se généralise pas à d'autres triangles.
- σ_boot et l'intervalle du trapèze dépendent du même choix (simulation avec σ̂ de la règle). Leur couverture sur trapèze n'est pas mesurée (Q-2b-6 (a)) [H : sous ce plan, l'intervalle du 8×7 serait trop étroit ; NV].

## 5. Question 3 : profil après explication, et options pour D2

**Lecture des profils dans l'ordre fixé :**
- Θ0 : levé si le mainteneur suit le § 2.7 et le § 3 ;
- Θ5 : absent ;
- Θ4 : absent (8×5, 8×6) ;
- Θ3 : absent ;
- **Θ2 : présent.** MinP4 N 0,05 est « non tranché » côté conservateur : 8×5 0,021 [0,015 ; 0,028], 8×6 0,022, pour ρ/2 = 0,0245.
  - Ce conservatisme existe sur le carré : #297 donne 0,029, « écart mineur ».
  - En apparié, le moteur rejette environ deux fois moins que le test idéal dans toutes les géométries, carré compris (8×8 N 0,05 : 58 contre 117).
  - Il s'accentue un peu quand J diminue (`a3` : p de MinP4 plus grande de 0,012 sur le 8×5 que sur le 8×6, sous N).
  - Pour MinP4, un OK est une preuve faible ; ce n'est pas propre au trapèze.
- **Hors grille** : PenteIntra sur le 8×7 (§ 4). Le protocole ne classait le 8×7 qu'en contrôle K-T6. Or la prémisse de ce contrôle est fausse pour cette clé. Je porte donc le point au mainteneur.

**Options pour D2 :**

| | Option | Effet | Coût | Avis |
|---|---|---|---|---|
| **(a′)** | **Étendre** : MW-04 levé pour I > J ; lecture Θ2 ; trois réserves écrites dans les fiches (MinP4 conservateur ; PenteIntra sur trapèze, ALERTE et ECHEC qui surestiment la preuve sous ce plan, mécanisme et dépendance au profil ; statut épistémique) ; issue gardée (critère E3) pour réexaminer Q-2a-2, avec une mesure | σ_USP et verdicts rendus sur trapèze, ce que prévoit l'étape 6 (a) | aucun calcul nouveau avant D2 | **recommandée** |
| (b) | Amender Q-2a-2 avant de lever la garde : simuler J−1 avec σ̂ direct pour les tests (pour tout, ou par une seconde simulation) ; amendement de spécification ; `coder-approfondi`, `audit` ; nouvelle mesure 5 (b) au moins sur PenteIntra des trois géométries | corrige probablement PenteIntra sur le 8×7 (§ 4, diagnostic) ; change σ_boot et l'intervalle (champ restitué) ; touche aussi 8×5 et 8×6 sans mesure à ce jour | environ un jour, une mesure de 10 à 16 h | défendable ; je ne la recommande pas en l'état |
| (c) | Étendre avec PenteIntra en diagnostic sur trapèze | évite l'excès sur 8×7 et retire de la puissance sur 8×5 et 8×6, où rien n'est mesuré | spécification, code, tests | déconseillée : règle ad hoc |
| (d) | Maintenir le refus (`git revert`, #567 `not planned`) | aucun σ_USP sur trapèze | faible | déconseillée : la MSEP est confrontée à l'implémentation de l'auteur, et le niveau sur 8×5 et 8×6 est comparable au carré |

**Motifs de (a′) :**
- L'écart PenteIntra est « non tranché » et non une distorsion matérielle, d'ampleur et de signe propres à ce plan.
- La correction (b) échangerait une distorsion mesurée et documentée contre une variante non mesurée sur 8×5 et 8×6, qui touche aussi σ_boot.
- Q-2a-2 a été tranché pour la cohérence avec la MSEP. Un réexamen demande une mesure, et non un raisonnement.

**Ce que le mainteneur doit trancher :**
1. La levée de Θ0, avec ce motif : signaux K3 sans lien avec l'implémentation ; discrétude écartée par la vérification prévue d'avance ; réserve du § 2.5.
2. L'option de D2.
3. Sous (a′) : le texte des réserves (étape 8), et la création de l'issue sur Q-2a-2 (accord requis ; rattachement par `architect`).
4. Sous (b) : l'amendement de Q-2a-2 et le budget d'une nouvelle mesure.

## 6. Question 4 : K-T4 et K-T7

**K-T4** (recalculé, `a4`) [V] :

| G | Règle / vrai : médiane | Règle / vrai : moyenne | Direct / vrai : moyenne | √MSEP règle / directe : 5 % | médiane | 95 % |
|---|---|---|---|---|---|---|
| 8×5 | 0,99 à 1,45 | 1,18 à 1,45 | ≈ 1,0 | 0,77 à 0,83 | 1,02 à 1,05 | 1,21 à 1,22 |
| 8×6 | 0,92 à 1,33 | 1,63 à 1,71 | ≈ 1,0 | 0,88 à 0,91 | 1,01 à 1,02 | 1,18 à 1,19 |
| 8×7 | 0,09 à 0,11 | 0,22 à 0,24 | ≈ 1,0 (direct / vrai : 5 % = 0,005, 95 % = 3,9) | 0,64 à 0,65 | 0,94 à 0,95 | 1,09 à 1,10 |

- Sur le 8×7, 37 à 42 % des triangles ont une √MSEP de la règle inférieure de plus de 10 % à la directe.
- Le sens suit le profil des σ (spécification § 0, point 3). Sous ce plan (σ²₄ < σ²₅), la règle sous-estime sur le 8×7.
- L'estimateur direct à ν = 1 est lui-même très bruité. Aucune littérature retrouvée ne départage les deux à T = 8.
- **Pour σ_USP** : la règle est prescrite (D(5)(d)(ii), lecture de `regulatory`). Ce n'est pas un défaut. Le champ d'information de M6 (Q-2a-4) est la bonne réponse, et le constat chiffré, conditionnel au plan, est à écrire dans la fiche M6.
- R̂ ≤ 0 et refus M4 : 0 partout.

**K-T7** :
- Les p de famille et la p globale sont dans les bornes du carré. La p globale (LC) est conservatrice : 0,068 à 0,093 à 0,10, et 0,031 à 0,042 à 0,05. #297 donnait N 0,0715 / 0,0365 et E 0,086 / 0,037.
- M4 n'a pas de ligne de famille, comme sur le carré.
- Aucune famille n'est en excès libéral. M1, qui contient PenteIntra, est à 0,080 à 0,104 sur le 8×7.
- **Rien d'alarmant pour un verdict.**

## 7. Question 5 : seuil « macro » et ADR 0005

- **Seuil « macro »** (`docs/agents/routage.md` § 4.3, premier tiret) : **atteint** si D2 étend.
  - Interface du moteur : domaine de `run_engine()` ; objet `usp_engine` avec `sigma2_Jm1_direct`, contrat partagé (§ 4.2).
  - Interface de l'application : grille I × J, refus de dimension sur I et J, T lu dans l'objet.
  - C'est ce que prévoyait le plan de S6 (« probablement atteint à D2 »). La session doit donc **proposer** Fable au mainteneur (une question oui / non).
  - Mon avis : le fond de D2 est tranché par mesure et diagnostic, et un Fable n'y ajouterait guère. Son apport porterait sur la forme de l'étape 6. Neutre.
  - Aucun critère du § 4.1 n'est rempli : pas de désaccord entre agents, pas d'échec d'Opus.
- **ADR 0005 : annotation par `architect` à D2, dans tous les cas.**
  - **Si extension** :
    - lecture (A) → (B) ;
    - MSEP restreinte sous la **forme consolidée seule**, la forme de 2015 n'étant pas transposable (constat 5 de `regulatory`) ;
    - règle de minimum gardée pour j = J−1 ; T = I + 1 ; refus de R̂ ≤ 0 gardé ;
    - qualification du 13/11 (bis) : les points 1 à 3 deviennent sans objet pour I > J, et MW-04 tombe ;
    - avertissement de Q-2a-6 ;
    - références : confrontation C1 et étude de niveau.
  - **Si refus** : annotation motivée.
  - Ce n'est pas un ADR d'architecture : pas de Fable d'office au titre du § 4.1.3.

## 8. Erreurs à distinguer

- **B** (Monte-Carlo de la p du moteur, err_mc ≈ 0,007 à p = 0,05, B = 999) : pour HomogF, ExpVar et Courbure, les p du moteur d'une géométrie à l'autre, sur les mêmes triangles, ne diffèrent que par ce bruit (écart-type des z ≈ 1, `a3`).
- **R** (échantillon de triangles) : signaux K3 et K-T6.
- **N0** (oracle réalisé) : pris en compte par la loi bêta-binomiale.
- **T = 8** (τ − ρ du test bootstrap à paramètres estimés), mesuré en apparié contre le témoin :
  - conservateur dans 113 cellules sur 156 (MinP4 fortement ; BP, Origine, Courbure modérément) ;
  - libéral pour PenteIntra sur 8×7, et pour Runs à 0,10 (atomes ; diagnostic).
- **Substitution** (plan et loi au lieu de la vérité) : non quantifiée, inhérente au protocole.

## 9. Limites

- Les analyses des § 2.4, 2.5, 3 et 4 sont **ajoutées après lecture**. Elles ne changent aucune classe mécanique, et leurs p ne sont pas des tests préspécifiés.
- Le diagnostic `a10` porte sur 150 triangles par loi, sur le 8×7 seul.
- Le constat ne se transpose ni à d'autres paramètres ni à d'autres géométries (statut épistémique de P1 à P8).

## 10. Constats classés (ADR 0018)

| N° | Gravité | Périmètre | Constat | Critère, preuve |
|---|---|---|---|---|
| M1 | **majeur** | #567 | PenteIntra libéral sur le 8×7, par la simulation de J−1 avec σ̂ de la règle (§ 4) | E3 et E2 s'il était hors périmètre ; `a8`, `a9`, `a10`, `a11` |
| M2 | **majeur** | #567 | Ma spécification, § 0 point 2 et § 3 : invariance supposée [H], fausse pour PenteIntra | à annoter par la session avant l'étape 8 ; même preuve |
| m1 | mineur | #567 | Spécification § 7 : HomogF et ExpVar classés « n ≥ 3 » avec un p_min changé sur le 8×5. Le code retient n ≥ 4 (l. 15295 ; ExpVar `nd < 4`) dans toutes les géométries, et leurs statistiques sont identiques sur 8×5 à 8×8 : aucun p_min ne change | aucun aujourd'hui ; E5 s'il passait dans le `.tex` ; `a7`, lecture du code. À corriger avant l'étape 8 |
| m2 | mineur | #567 | La ligne Θ0 du rapport compte comme deux cellules un seul événement (HomogF identique sur 8×5 et 8×6) | aucun ; `a1` |
| m3 | mineur | protocoles futurs | Le K-T6 non apparié est confondu par la composition et aveugle à PenteIntra ; la comparaison appariée moteur / témoin est préférable | aucun ; § 3, § 4 |
| m4 | mineur | hors périmètre | Témoins récurrents sur Runs et HomogF d'une campagne à l'autre, et dispersion entre campagnes sous E inexpliquée (§ 2.5) | aucun ; `a5` ; à reprendre aux protocoles de S9 |
| m5 | mineur | hors périmètre | MinP4 environ deux fois plus conservateur que le test idéal, carré compris | aucun : propriété déjà mesurée (#297, « écart mineur ») ; texte du `.tex` non relu [NV] |
| m6 | mineur | lecture | Dans `a1`, la ligne « masse de la région » de Runs est fausse (artefact d'arrondi à 10 chiffres) ; elle est remplacée par le calcul exact de `a2`, seul cité | aucun |

Aucun constat bloquant.

## Retour

- **Statut** : `revue requise`. La lecture est complète ; la levée de Θ0 et D2 reviennent au mainteneur.
- **Résultat** :
  - K3 : expliqué quant à l'implémentation, avec réserve ;
  - K-T6 : expliqué ;
  - profil Θ2 après levée, plus la réserve PenteIntra sur le 8×7 ;
  - D2 : (a′) recommandée.
  - Verdicts par test :
    - PenteIntra sur trapèze : **fragile** sur le 8×7 sous ce plan (libéral, non tranché) ; pertinent sur 8×5 et 8×6 ;
    - MinP4 : **à compléter** (conservateur ; OK = preuve faible) ;
    - HomogF et les autres clés : pertinents au niveau mesuré.
- **Preuves** :
  - *vérifiées* :
    - md5 et SHA de provenance ;
    - recalculs (`a1` à `a11`) ;
    - régénération 600 / 600 ;
    - code lu : `mw_test_homogeneite_f()` l. 15286-15328, `.mw_pente_relative()` l. 14661-14686, `engine_p_mc()` l. 4736-4759, Runs comme diagnostic l. ~17035 ;
    - script de mesure l. 400-470 et 1300-1480 ;
    - annotation du 05/11 de la spécification de #206 ;
    - ADR 0005 (annotations du 13/11) ;
    - `routage.md` § 4.1 à 4.3 ;
    - fiche S6 ;
  - *hypothèses* :
    - mécanisme PenteIntra (forte, diagnostic cohérent) ;
    - intervalle du 8×7 trop étroit ;
    - accentuation de MinP4 par le vivier ;
  - *non vérifiés* :
    - propriété du générateur aléatoire sur les plages de graines ;
    - texte du `.tex` sur MinP4 ;
    - couverture sur trapèze.
- **Informations manquantes** : aucune pour D2. L'oracle de #297 n'est pas versionné : les comparaisons entre campagnes emploient l'oracle de #567.
- **Décisions non résolues** (mainteneur) :
  - levée de Θ0 ;
  - option de D2 ;
  - réserves et issue Q-2a-2 sous (a′) ;
  - proposition de Fable (seuil « macro ») ;
  - annotation de l'ADR 0005 confiée à `architect`.
- **Critères déclenchés** :
  - changement de résultat après D2 (σ_USP et verdicts sur trapèze) ;
  - validité à T = 8 tranchée par simulation seulement ;
  - correction de ma propre spécification (M2, m1) ;
  - une décision du mainteneur (Q-2a-2) a une conséquence non prévue : je la signale sans la contester, et aucun désaccord avec un ADR, avec `audit` ou avec un autre agent ;
  - seuil « macro » atteint si D2 étend ;
  - aucune double lecture d'une source.
- **Constats hors périmètre** : m4 et m5, critère « aucun » (§ 10).
- **Prochaine action recommandée** :
  1. Verser ce rapport (et l'annexe) dans `docs/revues/20261120-s6-trapeze/actuary-5b-lecture-567.md`.
  2. Annoter la spécification (M2, m1) avant l'étape 8.
  3. Porter au mainteneur : Θ0, D2 (options du § 5) et la proposition de Fable.
  4. Après décision : annotation de l'ADR 0005 par `architect` ; étape 6 sous (a′), ou amendement de spécification sous (b).

**termine avec questions** : levée de Θ0, option de D2, issue Q-2a-2, Fable, adressées au mainteneur au § 5.

---

## Annexe : scripts de lecture (texte intégral)

Exécutés sous `LC_ALL=C.UTF-8` par `Rscript <script> /home/user/outil_usp <dossier de travail> [...]`, R 4.3.3, à `5297cd8`. Le dossier de travail est `…/scratchpad/issue567-travail-L0` (oracle.tsv, md5 `5bdafe159cd5624fee6ba906896d4f40`). Les scripts sont dans `…/scratchpad/lecture567/`. `a10` prend en arguments `/home/user/outil_usp 150 <dossier des scripts>`, `a11` `<dépôt> <travail> <dossier des scripts>`.

### a1_temoins.R
```r
# Lecture actuary 5b (#567), hors depot. Analyse des temoins K3 sous E.
# Arguments : chemin du depot, chemin du dossier de travail (oracle.tsv).
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]
setwd(DEP); source("R/charger_moteur.R"); charger_moteur()
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv")
B297 <- lire("docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv")
OR <- lire(file.path(TRV, "oracle.tsv"))
cat("md5 oracle :", tools::md5sum(file.path(TRV, "oracle.tsv")), "\n")
# 1. Identite des statistiques HomogF entre geometries (meme graine de triangle)
for (loi in c("N", "E")) {
  g <- function(G, s) { d <- BR[BR$G == G & BR$loi == loi, ]; d <- d[order(as.integer(d$b)), ]; setNames(d[[paste0("obs:", s)]], d$b) }
  for (s in c("HomogF", "Runs", "ExpVar", "Courbure", "MinP4")) {
    a5 <- g("8x5", s); a6 <- g("8x6", s); a7 <- g("8x7", s)
    cat(sprintf("%s %-9s : 8x5==8x6 (b<=2000) %d/2000 ; 8x6==8x7 (b<=1000) %d/1000 ; 8x5==8x7 %d/1000\n", loi, s,
                sum(a5 == a6), sum(a6[names(a7)] == a7), sum(a5[names(a7)] == a7)))
  }
  o <- function(G, s) { d <- OR[OR$G == G & OR$loi == loi, ]; d <- d[order(as.integer(d$k)), ]; d[[paste0("obs:", s)]] }
  cat(sprintf("%s oracle HomogF : 8x5==8x6 %d/20000 ; 8x6==8x7 %d/20000\n", loi,
              sum(o("8x5","HomogF") == o("8x6","HomogF")), sum(o("8x6","HomogF") == o("8x7","HomogF"))))
  cat(sprintf("%s oracle Runs : 8x7 vs 8x6 egal %d/20000\n", loi, sum(o("8x7","Runs") == o("8x6","Runs"))))
}
# 2. HomogF E : temoin, seuil, masse de la valeur seuil (verification prespecifiee, #206 annot. 05/11, point 4)
cn <- function(a, N) ceiling(round(a * (N + 1), 9)) - 2
S0 <- num(OR[OR$G == "8x5" & OR$loi == "E", "obs:HomogF"]); N <- length(S0); Ss <- sort(S0)
obs5 <- num(BR[BR$G == "8x5" & BR$loi == "E", "obs:HomogF"])
obs297E <- num(B297[B297$type == "rep" & B297$loi == "E", "obs:HomogF"])
obs297N <- num(B297[B297$type == "rep" & B297$loi == "N", "obs:HomogF"])
obs5N <- num(BR[BR$G == "8x5" & BR$loi == "N", "obs:HomogF"])
S0N <- num(OR[OR$G == "8x5" & OR$loi == "N", "obs:HomogF"])
por <- function(S, v, q) vapply(v, function(x) engine_p_mc(S, x, q)$p_mc, 1)
for (a in c(0.10, 0.05, 0.025, 0.01)) {
  c1 <- cn(a, N); thr <- Ss[N - c1]
  cat(sprintf("HomogF E a=%.3f : c1=%d ; S_(N-c1)=%.10g ; masse de la valeur seuil dans l'oracle %d/%d ; valeurs = seuil parmi 2000 mesures %d\n",
              a, c1, thr, sum(S0 == thr), N, sum(obs5 == thr)))
}
cat("HomogF E : mesures egales a une valeur de l'oracle :", sum(obs5 %in% S0), "/ 2000 ; distinctes mesures :", length(unique(obs5)), "\n")
tab <- function(lbl, S, v, q) {
  p <- por(S, v, q)
  cat(sprintf("%-38s n=%4d ", lbl, length(v)), paste(sprintf("a=%.3f:%4d (%.4f)", c(.2,.1,.05,.025,.01),
       sapply(c(.2,.1,.05,.025,.01), function(a) sum(p < a)), sapply(c(.2,.1,.05,.025,.01), function(a) mean(p < a))), collapse = " "), "\n")
  invisible(p)
}
cat("\n-- HomogF (queue haute), taux de rejet du temoin contre l'oracle 8x5 de la loi --\n")
tab("E, mesures #567 (b=1..2000)", S0, obs5, "haut")
tab("E, mesures #567 (b=1..1000)", S0, obs5[1:1000], "haut")
tab("E, mesures #567 (b=1001..2000)", S0, obs5[1001:2000], "haut")
tab("E, mesures #297 (8x8, 2000)", S0, obs297E, "haut")
tab("E, #567 + #297 (4000)", S0, c(obs5, obs297E), "haut")
tab("N, mesures #567 (2000)", S0N, obs5N, "haut")
tab("N, mesures #297 (8x8, 2000)", S0N, obs297N, "haut")
# Comparaisons de lois entieres (KS a deux echantillons, ex aequo : p approchee)
ks <- function(x, y) suppressWarnings(stats::ks.test(x, y)$p.value)
cat(sprintf("\nKS HomogF E : #567 vs oracle p=%.3f ; #297 vs oracle p=%.3f ; #567 vs #297 p=%.3f\n", ks(obs5, S0), ks(obs297E, S0), ks(obs5, obs297E)))
cat(sprintf("KS HomogF N : #567 vs oracle p=%.3f ; #297 vs oracle p=%.3f\n", ks(obs5N, S0N), ks(obs297N, S0N)))
# Queue haute : quantiles
qq <- c(.8,.9,.95,.975,.99)
cat("Quantiles HomogF E oracle :", signif(quantile(S0, qq), 5), "\n")
cat("Quantiles HomogF E #567   :", signif(quantile(obs5, qq), 5), "\n")
cat("Quantiles HomogF E #297   :", signif(quantile(obs297E, qq), 5), "\n")
# 3. Runs 8x7 E : distribution sur les atomes
cat("\n-- Runs (bilateral), 8x7 et 8x8 (meme loi sous (c)) --\n")
for (loi in c("E", "N")) {
  R0 <- num(OR[OR$G == "8x7" & OR$loi == loi, "obs:Runs"])
  r7 <- num(BR[BR$G == "8x7" & BR$loi == loi, "obs:Runs"])
  r8 <- num(B297[B297$type == "rep" & B297$loi == loi, "obs:Runs"])
  v <- sort(unique(round(c(R0, r7, r8), 10)))
  T <- rbind(oracle = table(factor(round(R0, 10), v)), m567 = table(factor(round(r7, 10), v)), m297 = table(factor(round(r8, 10), v)))
  colnames(T) <- signif(v, 4)
  cat("loi", loi, "\n"); print(T)
  # regroupement des cellules a effectif attendu < 5 pour le khi-deux
  pr <- colSums(T) / sum(T)
  cat(sprintf("Khi-deux d'homogeneite (3 echantillons, p par Monte-Carlo, 1e5) : p = %.4f\n",
      { set.seed(1); stats::chisq.test(T, simulate.p.value = TRUE, B = 1e5)$p.value }))
  cat(sprintf("Khi-deux m567 vs oracle : p = %.4f ; m297 vs oracle : p = %.4f\n",
      { set.seed(2); stats::chisq.test(T[c(1,2),], simulate.p.value = TRUE, B = 1e5)$p.value },
      { set.seed(3); stats::chisq.test(T[c(1,3),], simulate.p.value = TRUE, B = 1e5)$p.value }))
  tab(paste(loi, "Runs, #567 8x7 (1000)"), R0, r7, "deux")
  tab(paste(loi, "Runs, #297 8x8 (2000)"), R0, r8, "deux")
  tab(paste(loi, "Runs, #567 + #297 (3000)"), R0, c(r7, r8), "deux")
  # region realisee a 0,05 : valeurs rejetees par l'oracle
  pv <- por(R0, v, "deux"); rej <- v[pv < 0.05]
  cat("valeurs rejetees a 0,05 par l'oracle 8x7 :", signif(rej, 5), "\n")
  cat(sprintf("masse de la region : oracle %.5f (%d/20000) ; #567 %.5f ; #297 %.5f ; oracle #297 (taille temoin publiee 0,05) : %s\n",
              mean(round(R0,10) %in% round(rej,10)), sum(round(R0,10) %in% round(rej,10)), mean(round(r7,10) %in% round(rej,10)), mean(round(r8,10) %in% round(rej,10)),
              if (loi == "E") "0,03639" else "0,02814"))
}
```
*(La dernière ligne, « masse de la région », est fausse par artefact d'arrondi : constat m6, remplacée par `a2`.)*

### a2_kt6_concordance.R
```r
# Lecture actuary 5b (#567), hors depot. K-T6 Runs (stratifie par atome), concordance bootstrap / temoin,
# p beta-binomiales brutes, MinP4 contre #297.
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]
setwd(DEP); source("R/charger_moteur.R"); charger_moteur()
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv")
B297 <- lire("docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv")
OR <- lire(file.path(TRV, "oracle.tsv"))
por <- function(S, v, q) vapply(v, function(x) engine_p_mc(S, x, q)$p_mc, 1)
cn <- function(a, N) ceiling(round(a * (N + 1), 9)) - 2
p_betabinom <- function(k, n, a, b) {
  x <- 0:n; lp <- lchoose(n, x) + lbeta(x + a, n - x + b) - lbeta(a, b)
  lse <- function(z) { m <- max(z); m + log(sum(exp(z - m))) }
  min(1, 2 * exp(min(lse(lp[seq_len(k + 1L)]), lse(lp[(k + 1L):(n + 1L)]))))
}
mr <- function(S, q, a) { p <- por(S, sort(unique(S)), q); v <- sort(unique(S)); sum(S %in% v[p < a]) }
# 1. Runs : region realisee exacte de l'oracle 8x7 (valeurs exactes, sans arrondi)
for (loi in c("E", "N")) {
  R0 <- num(OR[OR$G == "8x7" & OR$loi == loi, "obs:Runs"])
  v <- sort(unique(R0)); pv <- por(R0, v, "deux"); cnt <- tabulate(match(R0, v), length(v))
  cat(sprintf("\nRuns %s, oracle 8x7 : %d valeurs exactes distinctes ; region de rejet a 0,05 = {%s} ; m_r = %d ; a 0,10 = {%s} ; m_r = %d\n", loi,
      length(v), paste(signif(v[pv < .05], 5), collapse = ", "), sum(cnt[pv < .05]), paste(signif(v[pv < .10], 5), collapse = ", "), sum(cnt[pv < .10])))
  r7 <- num(BR[BR$G == "8x7" & BR$loi == loi, "obs:Runs"]); p7 <- num(BR[BR$G == "8x7" & BR$loi == loi, "p:Runs"])
  b8 <- B297[B297$type == "rep" & B297$loi == loi, ]; r8 <- num(b8[["obs:Runs"]]); p8 <- num(b8[["pR:Runs"]])
  o7 <- por(R0, r7, "deux"); o8 <- por(R0, r8, "deux")
  for (a in c(.10, .05)) {
    cat(sprintf("  a=%.2f : 8x7 boot %d/1000, temoin %d/1000, concordance (b&t, b seul, t seul) = (%d, %d, %d) ; 8x8 #297 boot %d/2000, temoin (oracle 8x7) %d/2000, (%d, %d, %d)\n",
        a, sum(p7 < a), sum(o7 < a), sum(p7 < a & o7 < a), sum(p7 < a & o7 >= a), sum(p7 >= a & o7 < a),
        sum(p8 < a), sum(o8 < a), sum(p8 < a & o8 < a), sum(p8 < a & o8 >= a), sum(p8 >= a & o8 < a)))
    # CMH stratifie par valeur exacte de la statistique observee (atome)
    z <- c(r7, r8); g <- factor(c(rep("8x7", length(r7)), rep("8x8", length(r8)))); y <- factor(c(p7 < a, p8 < a), c(FALSE, TRUE))
    st <- factor(z); keep <- tapply(seq_along(z), st, function(i) length(unique(g[i])) == 2 & length(unique(y[i])) == 2)
    ok <- st %in% names(keep)[keep]
    tb <- table(g[ok], y[ok], droplevels(st[ok]))
    cm <- if (dim(tb)[3] >= 2) stats::mantelhaen.test(tb, exact = TRUE) else { f <- stats::fisher.test(tb[, , 1]); list(estimate = f$estimate, p.value = f$p.value) }
    # taux attendu du 8x7 si sa composition en atomes etait celle du 8x8 (repondération)
    t7 <- tapply(p7 < a, factor(r7, levels = sort(unique(z))), mean); w8 <- table(factor(r8, levels = sort(unique(z)))) / length(r8)
    cat(sprintf("    CMH exact (strates = atomes, %d strates informatives) : OR commun %.3f, p = %.3f ; taux du 8x7 repondere a la composition du 8x8 : %.4f (8x8 observe %.4f)\n",
        dim(tb)[3], cm$estimate, cm$p.value, sum(t7 * w8, na.rm = TRUE), mean(p8 < a)))
    # par atome de la region
    if (a == .05) {
      vv <- sort(unique(z)); 
      d <- data.frame(v = signif(vv, 5), n7 = as.vector(table(factor(r7, vv))), k7 = as.vector(tapply(p7 < a, factor(r7, vv), sum)),
                      n8 = as.vector(table(factor(r8, vv))), k8 = as.vector(tapply(p8 < a, factor(r8, vv), sum)))
      d[is.na(d)] <- 0; d$taux7 <- round(d$k7 / pmax(d$n7, 1), 3); d$taux8 <- round(d$k8 / pmax(d$n8, 1), 3)
      print(d[d$k7 + d$k8 > 0, ], row.names = FALSE)
    }
  }
}
# 2. Concordance bootstrap / temoin pour HomogF E (8x5, 8x6, 8x7) et McNemar
cat("\n-- HomogF E : concordance de la p du moteur et de la p du temoin --\n")
S0 <- num(OR[OR$G == "8x5" & OR$loi == "E", "obs:HomogF"])
for (G in c("8x5", "8x6", "8x7")) {
  d <- BR[BR$G == G & BR$loi == "E", ]; o <- por(S0, num(d[["obs:HomogF"]]), "haut"); p <- num(d[["p:HomogF"]])
  for (a in c(.10, .05)) {
    b <- sum(p < a & o >= a); c_ <- sum(p >= a & o < a)
    cat(sprintf("  %s a=%.2f : moteur %d, temoin %d, discordances (moteur seul %d, temoin seul %d), McNemar exact p = %.3f\n",
        G, a, sum(p < a), sum(o < a), b, c_, stats::binom.test(b, b + c_)$p.value))
  }
}
# 3. p beta-binomiales brutes des signaux et Bonferroni sur les cellules
cat("\n-- p beta-binomiales brutes --\n")
bb <- function(G, loi, s, q, a, n_use = NULL) {
  S <- num(OR[OR$G == G & OR$loi == loi, paste0("obs:", s)]); N <- length(S)
  ob <- num(BR[BR$G == G & BR$loi == loi, paste0("obs:", s)]); if (!is.null(n_use)) ob <- ob[seq_len(n_use)]
  k <- sum(por(S, ob, q) < a); m <- mr(S, q, a); t <- if (q == "deux") 2 else 1
  c(k = k, n = length(ob), m_r = m, p_bb = p_betabinom(k, length(ob), m + t, N + 1 - m - t))
}
print(rbind(`8x5 E HomogF 0,05` = bb("8x5", "E", "HomogF", "haut", .05), `8x7 E Runs 0,05` = bb("8x7", "E", "Runs", "deux", .05),
            `8x5 E HomogF 0,10` = bb("8x5", "E", "HomogF", "haut", .10)))
# meme statistique HomogF, echantillon independant #297 E contre cet oracle
o297 <- por(S0, num(B297[B297$type == "rep" & B297$loi == "E", "obs:HomogF"]), "haut")
cat(sprintf("#297 E HomogF contre l'oracle 8x5 E : k = %d / 2000 a 0,05 ; p BB = %.3f\n", sum(o297 < .05), p_betabinom(sum(o297 < .05), 2000, 999 + 1, 20001 - 1000)))
k4 <- 132 + sum(o297 < .05)
cat(sprintf("Reunion #567 + #297 (4000) : k = %d ; p BB = %.3f\n", k4, p_betabinom(k4, 4000, 1000, 20001 - 1000)))
# 4. MinP4 N 0,05 : 8x5, 8x6, 8x7 contre 8x8 (#297)
cat("\n-- MinP4 N et E : tau des geometries et du carre (#297) --\n")
for (loi in c("N", "E")) for (a in c(.10, .05)) {
  k8 <- sum(num(B297[B297$type == "rep" & B297$loi == loi, "pR:MinP4"]) < a)
  for (G in c("8x5", "8x6", "8x7")) {
    p <- num(BR[BR$G == G & BR$loi == loi, "p:MinP4"]); k <- sum(p < a); n <- length(p)
    cat(sprintf("  %s %s a=%.2f : %d/%d = %.4f ; 8x8 %d/2000 = %.4f ; Fisher p = %.3f\n", loi, G, a, k, n, k / n, k8, k8 / 2000,
                stats::fisher.test(matrix(c(k, n - k, k8, 2000 - k8), 2))$p.value))
  }
}
```

### a3_invariants.R
```r
# Lecture actuary 5b (#567), hors depot. Cles a statistique observee identique entre geometries :
# ecart des p du moteur entre 8x5, 8x6 et 8x7 sur les memes triangles (bootstraps de graines distinctes).
args <- commandArgs(TRUE); DEP <- args[1]; setwd(DEP)
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv")
for (loi in c("N", "E")) for (s in c("HomogF", "ExpVar", "Courbure", "MinP4")) {
  p <- function(G) { d <- BR[BR$G == G & BR$loi == loi, ]; d <- d[order(as.integer(d$b)), ]; num(d[[paste0("p:", s)]]) }
  p5 <- p("8x5"); p6 <- p("8x6"); p7 <- p("8x7")
  z <- function(a, b) { m <- (a + b) / 2; (a - b) / sqrt(pmax(2 * m * (1 - m) / 1000, 1e-12)) }
  z56 <- z(p5, p6); z57 <- z(p5[1:1000], p7)
  cat(sprintf("%s %-8s : 8x5-8x6 (2000) moy dp %+.4f, sd z %.2f, |z|>3 %d ; decisions 0,05 discordantes %d ; 8x5-8x7 (1000) moy dp %+.4f, sd z %.2f\n",
      loi, s, mean(p5 - p6), sd(z56), sum(abs(z56) > 3), sum((p5 < .05) != (p6 < .05)), mean(p5[1:1000] - p7), sd(z57)))
}
```

### a4_kt4.R
```r
# Lecture actuary 5b (#567), hors depot. Recalcul de K-T4 sur le brut ; parts du rapport des sqrt(MSEP) hors [0,9 ; 1,1].
args <- commandArgs(TRUE); setwd(args[1])
BR <- utils::read.delim("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv", stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
vrai <- c("8x5" = 0.314779, "8x6" = 0.0973248, "8x7" = 0.189674)
for (G in names(vrai)) for (loi in c("N", "E")) {
  d <- BR[BR$G == G & BR$loi == loi & BR$statut == "admis", ]
  rr <- num(d$s2_regle) / vrai[[G]]; rd <- num(d$s2_dir) / vrai[[G]]; q <- sqrt(num(d$msep) / num(d$msep_dir))
  cat(sprintf("%s %s n=%d : regle/vrai med %.4f moy %.4f ; direct/vrai med %.4f moy %.4f ; sqrt ratio q05 %.4f med %.4f q95 %.4f ; part < 0,9 : %.3f ; part > 1,1 : %.3f ; R_hat <= 0 : %d\n",
      G, loi, nrow(d), median(rr), mean(rr), median(rd), mean(rd), quantile(q, .05), median(q), quantile(q, .95), mean(q < .9), mean(q > 1.1), sum(num(d$R_hat) <= 0)))
}
```

### a5_permutation.R
```r
# Lecture actuary 5b (#567), hors depot. Tests de permutation du temoin K3 (echangeabilite mesure / oracle),
# sans l'approximation beta-binomiale ; dispersion entre campagnes (#567 et #297, meme loi).
# Graine du tirage de permutation : 20261121 (lecture, hors plages reservees ; aucun effet sur la mesure).
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]; setwd(DEP)
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv")
B297 <- lire("docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv")
OR <- lire(file.path(TRV, "oracle.tsv"))
QUEUE <- c(Calendrier = "bas", CorrDev = "deux", BP = "haut", MinP4 = "bas", DW = "deux", Runs = "deux", PenteIntra = "deux",
           Origine = "haut", HomogF = "haut", Courbure = "haut", Alpha = "haut", ExpVar = "haut", KruskalAcc = "haut")
# p_or vectorisee, regle d'engine_p_mc() (>= et <=, (1 + #)/(N + 1), bilaterale doublee, plafond 1)
p_or <- function(S, v, q) {
  Ss <- sort(S); N <- length(Ss)
  ge <- N - findInterval(v, Ss, left.open = TRUE); le <- findInterval(v, Ss)
  ph <- (1 + ge) / (N + 1); pb <- (1 + le) / (N + 1)
  pmin(switch(q, haut = ph, bas = pb, deux = 2 * pmin(ph, pb)), 1)
}
kw <- function(S, v, q, a) sum(p_or(S, v, q) < a)
set.seed(20261121); NP <- 4000
perm1 <- function(S, v, q, a) {           # p bilaterale de permutation de k (echantillon v contre oracle S)
  k0 <- kw(S, v, q, a); X <- c(S, v); n <- length(v)
  kk <- replicate(NP, { i <- sample.int(length(X), n); kw(X[-i], X[i], q, a) })
  c(k = k0, moy = mean(kk), p = min(1, 2 * min(mean(kk >= k0), mean(kk <= k0)) + 2 / NP))
}
cat("-- K3 par permutation (NP = 4000) --\n")
S <- num(OR[OR$G == "8x5" & OR$loi == "E", "obs:HomogF"]); v <- num(BR[BR$G == "8x5" & BR$loi == "E", "obs:HomogF"])
print(round(perm1(S, v, "haut", .05), 4))
S <- num(OR[OR$G == "8x7" & OR$loi == "E", "obs:Runs"]); v <- num(BR[BR$G == "8x7" & BR$loi == "E", "obs:Runs"])
print(round(perm1(S, v, "deux", .05), 4))
# Dispersion entre deux echantillons mesures de meme loi contre un meme oracle : D = |kA/nA - kB/nB|
cat("\n-- Ecart entre echantillons (#567 contre #297), meme oracle de #567, permutation sur la reunion --\n")
disp <- function(S, A, B, q, a) {
  d0 <- abs(kw(S, A, q, a) / length(A) - kw(S, B, q, a) / length(B)); X <- c(S, A, B); nA <- length(A); nB <- length(B)
  dd <- replicate(NP, { i <- sample.int(length(X)); ia <- i[1:nA]; ib <- i[nA + 1:nB]; o <- X[-c(ia, ib)]
    abs(kw(o, X[ia], q, a) / nA - kw(o, X[ib], q, a) / nB) })
  c(dA = kw(S, A, q, a) / length(A), dB = kw(S, B, q, a) / length(B), p = mean(dd >= d0 - 1e-12))
}
out <- NULL
for (loi in c("N", "E")) for (s in names(QUEUE)) {
  invariant <- s %in% c("HomogF", "ExpVar", "Courbure", "MinP4")
  G <- if (invariant) "8x5" else "8x7"
  S <- num(OR[OR$G == G & OR$loi == loi, paste0("obs:", s)])
  A <- num(BR[BR$G == G & BR$loi == loi, paste0("obs:", s)])
  Bv <- num(B297[B297$type == "rep" & B297$loi == loi, paste0("obs:", s)])
  r <- disp(S, A, Bv, QUEUE[[s]], .05)
  out <- rbind(out, data.frame(loi = loi, cle = s, G = G, nA = length(A), tauA = r[["dA"]], tau297 = r[["dB"]], p_perm = r[["p"]]))
}
out$p_holm13 <- ave(out$p_perm, out$loi, FUN = function(p) p.adjust(p, "holm"))
print(out, row.names = FALSE, digits = 4)
```

### a6_regeneration.R
```r
# Lecture actuary 5b (#567), hors depot. Regeneration independante d'un sous-ensemble des statistiques
# observees (mesures et oracle) aux graines du protocole (P3 amende), comparees au brut et a oracle.tsv.
# Generateur reecrit independamment dans ce script (meme recursion que gen_triangle_h0() du script de mesure).
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]; setwd(DEP)
source("tests/outils_tests.R"); source("R/charger_moteur.R"); charger_moteur()
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv"); OR <- lire(file.path(TRV, "oracle.tsv"))
tri0 <- as.matrix(utils::read.csv("tests/donnees/triangle_mw.csv", check.names = FALSE)[, -1])
cat("dim triangle_mw :", dim(tri0), "\n")
AJ8 <- mw_ajuster(tri0); POOL0 <- .mw_pool_residus(AJ8, .mw_colonnes_degenerees(AJ8))
POOL_E <- POOL0 / sqrt(mean((POOL0 - mean(POOL0))^2))
dgp <- function(J) list(I = AJ8$I, J = J, tri = AJ8$tri[, seq_len(J + 1L), drop = FALSE], f = AJ8$f[seq_len(J)], sigma2 = AJ8$sigma2[seq_len(J)])
JG <- c("8x5" = 4L, "8x6" = 5L, "8x7" = 6L)
CLES <- names(MW_CATALOGUE_MC)
gen <- function(G, loi, graine) {
  d <- dgp(JG[[G]])
  # tirage par colonne, meme ordre de consommation des epsilon que le script de mesure
  engine_sous_graine(graine, {
    I <- d$I; J <- d$J; tri <- matrix(NA_real_, I + 1, J + 1); tri[, 1] <- d$tri[, 1]
    for (j in 0:(J - 1)) { idx <- 0:(I - j - 1); sg <- sqrt(d$sigma2[j + 1])
      e <- if (loi == "N") stats::rnorm(length(idx)) else sample(POOL_E, length(idx), replace = TRUE)
      Cij <- tri[idx + 1, j + 1]; tri[idx + 1, j + 2] <- Cij * d$f[j + 1] + e * sg * sqrt(Cij) }
    tri })
}
st <- function(tri) { aj <- mw_ajuster(tri); unlist(.mw_stats(aj, .mw_ensembles_figes(aj, .mw_colonnes_degenerees(aj)))[CLES]) }
set.seed(7)
chk <- function(G, loi, type, ids) {
  ok <- 0L
  for (i in ids) {
    if (type == "mesure") { g <- 567000000 + 100000 * (loi == "E") + i; ref <- num(unlist(BR[BR$G == G & BR$loi == loi & BR$b == as.character(i), paste0("obs:", CLES)])) }
    else { g <- 570500000 + 100000 * (loi == "E") + i; ref <- num(unlist(OR[OR$G == G & OR$loi == loi & OR$k == as.character(i), paste0("obs:", CLES)])) }
    s <- st(gen(G, loi, g)); ok <- ok + isTRUE(all(s == ref | (is.na(s) & is.na(ref))))
  }
  cat(sprintf("%s %s %-6s : %d / %d triangles aux 13 statistiques egales (comparaison a 17 chiffres)\n", G, loi, type, ok, length(ids)))
}
chk("8x5", "E", "mesure", sample(2000, 150)); chk("8x7", "E", "mesure", sample(1000, 100))
chk("8x5", "E", "oracle", sample(20000, 150)); chk("8x7", "E", "oracle", sample(20000, 100))
chk("8x5", "N", "mesure", sample(2000, 50)); chk("8x5", "N", "oracle", sample(20000, 50))
```

### a7_invariance_cles.R
```r
# Lecture actuary 5b (#567), hors depot. Cles dont la statistique observee est identique entre geometries (meme graine).
args <- commandArgs(TRUE); setwd(args[1])
BR <- utils::read.delim("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv", stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
CLES <- sub("^obs:", "", grep("^obs:", names(BR), value = TRUE))
for (loi in c("N", "E")) {
  g <- function(G) { d <- BR[BR$G == G & BR$loi == loi, ]; d[order(as.integer(d$b)), ] }
  d5 <- g("8x5"); d6 <- g("8x6"); d7 <- g("8x7")
  r <- sapply(CLES, function(s) c(`8x5=8x6` = mean(d5[[paste0("obs:", s)]] == d6[[paste0("obs:", s)]]),
                                  `8x6=8x7` = mean(d6[1:1000, paste0("obs:", s)] == d7[[paste0("obs:", s)]])))
  cat("loi", loi, "\n"); print(round(r, 3))
}
```

### a8_apparie.R
```r
# Lecture actuary 5b (#567), hors depot. Comparaison appariee, triangle par triangle, de la decision du moteur
# (p_mc < a) et de celle du temoin oracle (p_or < a) : isole l'erreur du test bootstrap a T = 8 de la
# fluctuation de l'echantillon de triangles (R). McNemar exact (binomial sur les discordances), descriptif.
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]; setwd(DEP)
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv"); OR <- lire(file.path(TRV, "oracle.tsv"))
QUEUE <- c(Calendrier = "bas", CorrDev = "deux", BP = "haut", MinP4 = "bas", DW = "deux", Runs = "deux", PenteIntra = "deux",
           Origine = "haut", HomogF = "haut", Courbure = "haut", Alpha = "haut", ExpVar = "haut", KruskalAcc = "haut")
p_or <- function(S, v, q) { Ss <- sort(S); N <- length(Ss)
  ge <- N - findInterval(v, Ss, left.open = TRUE); le <- findInterval(v, Ss)
  ph <- (1 + ge) / (N + 1); pb <- (1 + le) / (N + 1); pmin(switch(q, haut = ph, bas = pb, deux = 2 * pmin(ph, pb)), 1) }
out <- NULL
for (G in c("8x5", "8x6", "8x7")) for (loi in c("N", "E")) for (s in names(QUEUE)) {
  S <- num(OR[OR$G == G & OR$loi == loi, paste0("obs:", s)]); d <- BR[BR$G == G & BR$loi == loi, ]
  po <- p_or(S, num(d[[paste0("obs:", s)]]), QUEUE[[s]]); pm <- num(d[[paste0("p:", s)]])
  for (a in c(.10, .05)) {
    b <- sum(pm < a & po >= a); c_ <- sum(pm >= a & po < a)
    out <- rbind(out, data.frame(G = G, loi = loi, a = a, cle = s, n = nrow(d), k_moteur = sum(pm < a), k_temoin = sum(po < a),
                                 moteur_seul = b, temoin_seul = c_, p_mcnemar = if (b + c_) stats::binom.test(b, b + c_)$p.value else 1))
  }
}
out$p_holm <- ave(out$p_mcnemar, out$G, out$loi, out$a, FUN = function(p) p.adjust(p, "holm"))
print(out[out$p_holm < 0.05, ], row.names = FALSE, digits = 4)
cat("\nCellules (sur", nrow(out), ") : moteur > temoin", sum(out$k_moteur > out$k_temoin), "; moteur < temoin", sum(out$k_moteur < out$k_temoin), "; egal", sum(out$k_moteur == out$k_temoin), "\n")
cat("Signaux apparies (Holm sur 13 < 0,05) par cle :\n"); print(table(out$cle[out$p_holm < 0.05]))
```

### a8b_apparie_pente.R
```r
# Lecture actuary 5b (#567), hors depot. Variante de a8 : lignes PenteIntra, Alpha et MinP4 de toutes les geometries.
# (p_mc < a) et de celle du temoin oracle (p_or < a) : isole l'erreur du test bootstrap a T = 8 de la
# fluctuation de l'echantillon de triangles (R). McNemar exact (binomial sur les discordances), descriptif.
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]; setwd(DEP)
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv"); OR <- lire(file.path(TRV, "oracle.tsv"))
QUEUE <- c(Calendrier = "bas", CorrDev = "deux", BP = "haut", MinP4 = "bas", DW = "deux", Runs = "deux", PenteIntra = "deux",
           Origine = "haut", HomogF = "haut", Courbure = "haut", Alpha = "haut", ExpVar = "haut", KruskalAcc = "haut")
p_or <- function(S, v, q) { Ss <- sort(S); N <- length(Ss)
  ge <- N - findInterval(v, Ss, left.open = TRUE); le <- findInterval(v, Ss)
  ph <- (1 + ge) / (N + 1); pb <- (1 + le) / (N + 1); pmin(switch(q, haut = ph, bas = pb, deux = 2 * pmin(ph, pb)), 1) }
out <- NULL
for (G in c("8x5", "8x6", "8x7")) for (loi in c("N", "E")) for (s in names(QUEUE)) {
  S <- num(OR[OR$G == G & OR$loi == loi, paste0("obs:", s)]); d <- BR[BR$G == G & BR$loi == loi, ]
  po <- p_or(S, num(d[[paste0("obs:", s)]]), QUEUE[[s]]); pm <- num(d[[paste0("p:", s)]])
  for (a in c(.10, .05)) {
    b <- sum(pm < a & po >= a); c_ <- sum(pm >= a & po < a)
    out <- rbind(out, data.frame(G = G, loi = loi, a = a, cle = s, n = nrow(d), k_moteur = sum(pm < a), k_temoin = sum(po < a),
                                 moteur_seul = b, temoin_seul = c_, p_mcnemar = if (b + c_) stats::binom.test(b, b + c_)$p.value else 1))
  }
}
out$p_holm <- ave(out$p_mcnemar, out$G, out$loi, out$a, FUN = function(p) p.adjust(p, "holm"))
print(out[out$cle %in% c("PenteIntra", "Alpha", "MinP4"), ], row.names = FALSE, digits = 3)
cat("\nCellules (sur", nrow(out), ") : moteur > temoin", sum(out$k_moteur > out$k_temoin), "; moteur < temoin", sum(out$k_moteur < out$k_temoin), "; egal", sum(out$k_moteur == out$k_temoin), "\n")
cat("Signaux apparies (Holm sur 13 < 0,05) par cle :\n"); print(table(out$cle[out$p_holm < 0.05]))
```

### a9_apparie_297.R
```r
# Lecture actuary 5b (#567), hors depot. Meme comparaison appariee moteur / temoin sur le carre 8x8 de #297
# (p_mc du pool redresse, pR:<cle>), temoin contre l'oracle 8x7 de #567 (meme loi des statistiques observees
# sous (c), controle (o)) ; comparaison avec le 8x7.
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]; setwd(DEP)
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv"); OR <- lire(file.path(TRV, "oracle.tsv"))
B297 <- lire("docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv")
QUEUE <- c(Calendrier = "bas", CorrDev = "deux", BP = "haut", MinP4 = "bas", DW = "deux", Runs = "deux", PenteIntra = "deux",
           Origine = "haut", HomogF = "haut", Courbure = "haut", Alpha = "haut", ExpVar = "haut", KruskalAcc = "haut")
p_or <- function(S, v, q) { Ss <- sort(S); N <- length(Ss)
  ge <- N - findInterval(v, Ss, left.open = TRUE); le <- findInterval(v, Ss)
  ph <- (1 + ge) / (N + 1); pb <- (1 + le) / (N + 1); pmin(switch(q, haut = ph, bas = pb, deux = 2 * pmin(ph, pb)), 1) }
f <- function(k_m, k_t, b, c) sprintf("%4d %4d (%3d/%3d, p=%.2g)", k_m, k_t, b, c, if (b + c) stats::binom.test(b, b + c)$p.value else 1)
cat("cle, loi, a : 8x8 #297 [moteur temoin (moteur seul/temoin seul, McNemar)] | 8x7 #567 [idem]\n")
for (loi in c("N", "E")) for (s in names(QUEUE)) for (a in c(.10, .05)) {
  S <- num(OR[OR$G == "8x7" & OR$loi == loi, paste0("obs:", s)])
  b8 <- B297[B297$type == "rep" & B297$loi == loi, ]; po8 <- p_or(S, num(b8[[paste0("obs:", s)]]), QUEUE[[s]]); pm8 <- num(b8[[paste0("pR:", s)]])
  d7 <- BR[BR$G == "8x7" & BR$loi == loi, ]; po7 <- p_or(S, num(d7[[paste0("obs:", s)]]), QUEUE[[s]]); pm7 <- num(d7[[paste0("p:", s)]])
  cat(sprintf("%-10s %s %.2f : %s | %s\n", s, loi, a,
      f(sum(pm8 < a), sum(po8 < a), sum(pm8 < a & po8 >= a), sum(pm8 >= a & po8 < a)),
      f(sum(pm7 < a), sum(po7 < a), sum(pm7 < a & po7 >= a), sum(pm7 >= a & po7 < a))))
}
# Excès apparie (moteur seul - temoin seul)/n, 8x7 contre 8x8, PenteIntra et Alpha : test de difference des excès
for (loi in c("N", "E")) for (s in c("PenteIntra", "Alpha")) for (a in c(.10, .05)) {
  S <- num(OR[OR$G == "8x7" & OR$loi == loi, paste0("obs:", s)])
  b8 <- B297[B297$type == "rep" & B297$loi == loi, ]; d7 <- BR[BR$G == "8x7" & BR$loi == loi, ]
  e8 <- (num(b8[[paste0("pR:", s)]]) < a) - (p_or(S, num(b8[[paste0("obs:", s)]]), QUEUE[[s]]) < a)
  e7 <- (num(d7[[paste0("p:", s)]]) < a) - (p_or(S, num(d7[[paste0("obs:", s)]]), QUEUE[[s]]) < a)
  w <- stats::wilcox.test(e7, e8)
  cat(sprintf("%s %s %.2f : exces apparie 8x7 %+.4f, 8x8 %+.4f ; difference %+.4f ; Wilcoxon p = %.3g\n", s, loi, a, mean(e7), mean(e8), mean(e7) - mean(e8), w$p.value))
}
```

### a10_mecanisme.R
```r
# Lecture actuary 5b (#567), hors depot, DIAGNOSTIC DE MECANISME (ni mesure de niveau, ni extension de R).
# 8x7 : bootstrap du moteur relance a la MEME graine que la mesure, la seule difference etant la variance de
# simulation de la colonne J-1 : sigma2 de la regle (moteur, Q-2a-2) remplacee par l'estimateur direct
# (aj$sigma2_Jm1_direct). Les statistiques observees ne changent pas (option (c)). Nombres aleatoires communs.
args <- commandArgs(TRUE); DEP <- args[1]; NB <- as.integer(args[2]); setwd(DEP)
source("R/charger_moteur.R"); charger_moteur()
lire <- function(f) utils::read.delim(f, stringsAsFactors = FALSE, colClasses = "character", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
BR <- lire("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv")
tri0 <- as.matrix(utils::read.csv("tests/donnees/triangle_mw.csv", check.names = FALSE)[, -1])
AJ8 <- mw_ajuster(tri0); POOL0 <- .mw_pool_residus(AJ8, .mw_colonnes_degenerees(AJ8)); POOL_E <- POOL0 / sqrt(mean((POOL0 - mean(POOL0))^2))
d <- list(I = AJ8$I, J = 6L, tri = AJ8$tri[, 1:7], f = AJ8$f[1:6], sigma2 = AJ8$sigma2[1:6])
gen <- function(loi, graine) engine_sous_graine(graine, {
  I <- d$I; J <- d$J; tri <- matrix(NA_real_, I + 1, J + 1); tri[, 1] <- d$tri[, 1]
  for (j in 0:(J - 1)) { idx <- 0:(I - j - 1); sg <- sqrt(d$sigma2[j + 1])
    e <- if (loi == "N") stats::rnorm(length(idx)) else sample(POOL_E, length(idx), replace = TRUE)
    Cij <- tri[idx + 1, j + 1]; tri[idx + 1, j + 2] <- Cij * d$f[j + 1] + e * sg * sqrt(Cij) }
  tri })
CLES <- names(MW_CATALOGUE_MC)
un <- function(loi, b) {
  tri <- gen(loi, 567000000 + 100000 * (loi == "E") + b); aj <- mw_ajuster(tri); figes <- .mw_ensembles_figes(aj)
  gb <- 568000000 + 2000000 + 100000 * (loi == "E") + b
  aj2 <- aj; aj2$sigma2[aj$J] <- aj$sigma2_Jm1_direct
  b1 <- mw_bootstrap(aj, B = 999, seed = gb, figes = figes); b2 <- mw_bootstrap(aj2, B = 999, seed = gb, figes = figes)
  pm <- function(bt) vapply(CLES, function(s) engine_p_mc(bt$stats_boot[, s], bt$stats_obs[[s]], MW_CATALOGUE_MC[[s]]$queue)$p_mc, 1)
  c(b = b, regle = pm(b1), direct = pm(b2), s2r = aj$sigma2[aj$J], s2d = aj$sigma2_Jm1_direct)
}

lois <- c(rep("N", NB), rep("E", NB)); bs <- c(seq_len(NB), seq_len(NB))
t0 <- proc.time()[["elapsed"]]
R <- parallel::mclapply(seq_along(lois), function(i) c(loi = lois[i], un(lois[i], bs[i])), mc.cores = 4)
cat("duree", round(proc.time()[["elapsed"]] - t0), "s\n")
M <- do.call(rbind, R); D <- as.data.frame(M, stringsAsFactors = FALSE)
for (nm in names(D)[-1]) D[[nm]] <- as.numeric(D[[nm]])
saveRDS(D, file.path(args[3], "a10_resultats.rds"))
# controle : p "regle" recalculee = p du brut
for (loi in c("N", "E")) {
  x <- D[D$loi == loi, ]; br <- BR[BR$G == "8x7" & BR$loi == loi, ]; br <- br[match(x$b, as.integer(br$b)), ]
  eg <- sapply(CLES, function(s) mean(abs(x[[paste0("regle.", s)]] - num(br[[paste0("p:", s)]])) < 1e-12))
  cat(loi, ": part des p (regle) egales au brut, par cle :", paste(sprintf("%s %.2f", CLES, eg), collapse = " ; "), "\n")
  for (s in CLES) for (a in c(.10, .05)) {
    r <- x[[paste0("regle.", s)]] < a; dd <- x[[paste0("direct.", s)]] < a
    if (sum(r) != sum(dd)) cat(sprintf("  %s %-10s a=%.2f : rejets regle %d, direct %d (regle seule %d, direct seule %d) ; moy(p_direct - p_regle) = %+.4f\n",
        loi, s, a, sum(r), sum(dd), sum(r & !dd), sum(!r & dd), mean(x[[paste0("direct.", s)]] - x[[paste0("regle.", s)]])))
  }
}
```
Sortie (durée 2 217 s, 4 processus) : p « règle » égales au brut, 1,00 pour les 13 clés, N et E. Seule PenteIntra change de nombre de rejets : N 0,10 : 14 → 11 ; N 0,05 : 9 → 6 ; E 0,10 : 28 → 25 ; E 0,05 : 20 → 17.

### a11_mecanisme_lecture.R
```r
# Lecture actuary 5b (#567), hors depot. Lecture de a10 : PenteIntra, moteur (regle), moteur (direct) et temoin
# oracle sur les memes 150 triangles 8x7 par loi.
args <- commandArgs(TRUE); DEP <- args[1]; TRV <- args[2]; RES <- args[3]; setwd(DEP)
D <- readRDS(file.path(RES, "a10_resultats.rds"))
OR <- utils::read.delim(file.path(TRV, "oracle.tsv"), colClasses = "character", check.names = FALSE)
BR <- utils::read.delim("docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv", colClasses = "character", check.names = FALSE)
p_or2 <- function(S, v) { Ss <- sort(S); N <- length(Ss); ge <- N - findInterval(v, Ss, left.open = TRUE); le <- findInterval(v, Ss)
  pmin(2 * pmin((1 + ge) / (N + 1), (1 + le) / (N + 1)), 1) }
for (loi in c("N", "E")) {
  x <- D[D$loi == loi, ]; br <- BR[BR$G == "8x7" & BR$loi == loi, ]; br <- br[match(x$b, as.integer(br$b)), ]
  po <- p_or2(as.numeric(OR[OR$G == "8x7" & OR$loi == loi, "obs:PenteIntra"]), as.numeric(br[["obs:PenteIntra"]]))
  for (a in c(.10, .05)) {
    r <- x$regle.PenteIntra < a; dd <- x$direct.PenteIntra < a; t <- po < a
    cat(sprintf("%s a=%.2f (n=%d) : moteur regle %d, moteur direct %d, temoin %d ; regle hors temoin %d, direct hors temoin %d\n",
        loi, a, nrow(x), sum(r), sum(dd), sum(t), sum(r & !t), sum(dd & !t)))
  }
  cat(sprintf("%s : correlation des p (regle, direct) %.4f ; mediane |difference| %.4f\n", loi, cor(x$regle.PenteIntra, x$direct.PenteIntra), median(abs(x$regle.PenteIntra - x$direct.PenteIntra))))
}
```

## Décisions du mainteneur au point d'arrêt D2 (21/11/2026)

- **Θ0 levé**, avec le motif du § 2.7 et du § 3 : signaux K3 sans lien avec l'implémentation (régénération 600 / 600, discrétude écartée par la vérification prévue d'avance), K-T6 Runs E expliqué par la composition des échantillons ; réserve du § 2.5 maintenue. Profil retenu : **Θ2**, plus la réserve PenteIntra sur le 8×7 (§ 4), hors grille.
- **D2 : option (a′), extension** : MW-04 levée pour I > J à l'étape 6 (`app:` puis `moteur:`, seul commit qui change un résultat, visa du mainteneur) ; trois réserves écrites dans les fiches à l'étape 8 (MinP4 conservateur ; PenteIntra libéral sur trapèze sous ce plan, mécanisme et dépendance au profil des σ ; statut épistémique) ; issue créée pour réexaminer Q-2a-2 par une mesure, rattachée au plan par `architect` ; `Closes #567` maintenu.
- **Q-A1 : forme (ii)** (`actuary-qa1-deux-sigma-trapeze.md`) : le moteur restitue les deux σ de la colonne J−1 d'un trapèze avec leur usage (colonne `sigma_residus` en fin de `plots_data$facteurs`, libellé d'usage lu dans l'objet) ; l'application trace le second point et corrige sa légende ; phrase dans la fiche M6 à l'étape 8.
- **Seuil « macro »** (`routage.md` § 4.3) : consultation Fable autorisée, une, sur la forme de l'étape 6 (Fable : 1 sur 3 pour S6).
- Suites : annotation de l'ADR 0005 par `architect` (lecture (A) → (B), forme consolidée seule) ; annotation de la spécification par `actuary` (constats M2 et m1) avant l'étape 8.
