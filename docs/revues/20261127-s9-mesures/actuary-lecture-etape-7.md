# S9, étape 7 : lecture des cinq tableaux de l'étape 6 contre les critères écrits d'avance (#421, #420, #367, #379, #494)

> *Rédigé par l'agent actuary (IA), fiche `actuary-approfondi`, le 27/11/2026, sur `claude/mesures-t8` à la tête `0c04d7a`, arbre propre. Je n'ai écrit aucun fichier, ouvert aucune issue ni posté aucun commentaire. Marqueurs : [V] vérifié (source citée, ou commande exécutée et sortie relevée), [H] hypothèse. Versé intégralement par la session principale (Q-54-10).*

## Synthèse

| Issue | Verdict au critère | Nature | PM-3 |
|---|---|---|---|
| #421 | K421-1 à K421-5 **satisfaits** | L₋ : résultat exact ; puissance et L₊ : quadrature d'une quantité exacte ; recoupement : simulation | **non** |
| #420 | critère du § 2.4 (complété par Q1 et Q2) **satisfait** : « quasi-redondance sous H0 établie » | approximation Monte-Carlo d'une fonctionnelle de la loi bootstrap, conditionnelle à θ̂ | **non** |
| #367 | **indécidable ALERTE/OK** (l'intervalle à 99 % contient α) | Monte-Carlo pur sur une quantité exacte, p_∞ | **non**, et aucun signal au mainteneur |
| #379 | classes établies pour chaque cellule. PM-3 cas 1 : un seul signal nominal, **non retenu**. PM-3 cas 2 : **non déclenché** (calcul fait ici) | simulation sous plan | **non** |
| #494 | classes établies. PM-3 cas 1 : « compatible » partout. PM-3 cas 2 : identité mécanique, qui ne peut pas se déclencher | simulation sous plan | **non** |

Aucune mesure ne contredit une phrase du `.tex` au-delà de son incertitude. Aucune ne révèle de défaut du moteur : tous les contrôles d'intégrité sont OK dans les cinq tableaux. Plusieurs phrases sont en revanche **périmées ou incomplètes** ; elles sont listées par issue, avec la consigne pour `docwriter` à l'étape 8.

---

## 1. #421 — Durbin-Watson au voisinage de ρ = ±1, T de 4 à 100

**Tableau** : `docs/tableaux/20261127-issue421-dw-rho-negatif.md` (commit `6e0c7b6`, md5 du moteur `c7b767f5…`).

### Verdict par critère [V, § 3 et § 4 du tableau]

- **K421-1 (limite ρ → −1) : satisfait.**
  - 26 couples décidés sur 26, aucun indécidable.
  - L₋ = 0 pour (4 ; 0,10), (4 ; 0,05) et (5 ; 0,05). Les marges m valent 0,120, 0,170 et 6,042e-4, toutes au-delà du seuil de 10⁻⁶ ; la dernière le dépasse d'un facteur 600.
  - L₋ = 1 partout ailleurs, dont (5 ; 0,10), avec m = −0,0494.
  - Conséquence prévue par le critère : « hypothèse non vérifiée » est remplacée par ce résultat.
- **K421-2 (simulé contre Imhof) : satisfait.**
  - 0 cellule signalée sur 130, aucun désaccord.
  - À T = 8, les quatre lignes ajoutées (ρ = −0,9999 et la garde) s'écartent d'au plus 0,34 erreur-type.
- **K421-3 (vitesse, constat) :**
  - 19 couples stables, 3 en régime non atteint, 4 sans objet.
  - Les 3 couples en régime non atteint : T = 5 à α = 0,10 (écart relatif 1,091e-3, avec sa valeur, comme prévu par la trace M42) ; T = 5 à α = 0,05 (1,754) ; T = 6 à α = 0,05 (1,1e-2).
  - Les 4 sans objet : T = 50 et T = 100, aux deux seuils (garde de 10⁻⁶ décidée avant l'exécution).
  - Ce n'est pas un échec.
- **K421-4 (ρ → 1) : satisfait.**
  - Rang T − 1 de M K M pour tous les T.
  - Écart maximal 1,154e-6, sous le seuil de signalement de 10⁻⁵.
  - L₊(8 ; 0,10) = 0,5899175 : c'est la valeur du commentaire du moteur.
- **K421-5 (non-régression) : satisfait**, 31 lignes de T = 8 identiques au tableau du 31/10.

**Constats de forme (§ 1 ter), qui valent sur la grille seulement** :
- à T = 4, la puissance passe sous α sur 6 points ρ < 0 (α = 0,10), jusqu'à 0,0006 à la garde : le test est biaisé contre un AR(1) fortement négatif, ce que la limite L₋ = 0 impose ;
- à T = 5, α = 0,05, la puissance n'est pas monotone : 0,402 à −0,999, puis 0,106 à la garde. La simulation indépendante confirme cette valeur à la garde (0,10497 contre 0,10572, −1,56 ET) : c'est une propriété du test, non une défaillance de la quadrature.

### Phrases du `.tex` et consignes pour `docwriter`

- **l. 1329-1331** (index, `dw_puissance_ar1()`) : « mesure non versionnée ; son versionnement est un travail postérieur à la remise ».
  - Cette mention est **soldée**. Renvoyer à `tests/mesure_dw_rho_negatif_t8.R` et au tableau du 27/11.
  - Garder la liste des T et α, et ajouter que les deux seuils sont mesurés pour tous ces T.
  - « hors de ces T, non mesurée » (l. 1333) reste vrai.
- **l. 1339-1342** : « la puissance tend vers 0 quand ρ → −1, sans signature de défaillance (hypothèse non vérifiée … établir la puissance limite est un travail postérieur à la remise) ».
  - Remplacer par le résultat exact : L₋ = 1{dw_p_exacte(v_T) < α}, v_T vecteur alterné, DW(v_T) = 4(T − 1)/T si T est pair et 4T/(T + 1) si T est impair. L₋ = 0 pour (4 ; 0,10), (4 ; 0,05) et (5 ; 0,05) ; L₋ = 1 dès T = 6 pour les deux seuils, et à (5 ; 0,10).
  - Dire que la **valeur** de L₋ dépend du signe d'une marge évaluée par quadrature (m = 6,042e-4 au cas le plus serré).
  - **À ajouter obligatoirement** (avis de l'étape 1, § 1.5, K421-3) : à T = 5, α = 0,05, la convergence n'est pas atteinte dans le domaine gardé ; la puissance vaut 0,106 à la garde après un maximum de 0,402, valeur recoupée par simulation. À T = 4, la puissance est inférieure à α pour ρ ≤ −0,99 (α = 0,10).
  - Le test unitaire de la limite est à citer, sous le nom fixé par `coder`.
- **l. 1334-1338** (T = 8, coefficients 1,219 et 1,815) : inchangée, les valeurs sont confirmées (1,2188 et 1,8153). On peut ajouter que la loi en (1 − |ρ|)^½ est stable sur 19 couples, reste un constat non démontré, et n'est pas atteinte dans les trois cas listés plus haut.
- **l. 1339** : « au-delà de la garde, le comportement du calcul n'est pas évalué par une mesure versionnée » reste vrai.
  - Ajouter que la limite ρ → 1 est obtenue sans franchir la garde : L₊ par Imhof sous M K M (0,5899175 à T = 8, α = 0,10).
  - Les trois valeurs de #170 sont historiques et **non reproduites**.
- **l. 1351-1353** (sortie du 31/10, « recoupement par simulation à ρ = 0, −0,9 et −0,99 ») et **section l. 9886 et suivantes** : ajouter le tableau du 27/11, qui étend le recoupement à −0,9999 et à la garde pour tous les T.
- **Fiche Durbin-Watson, l. 13008** : « les valeurs à ρ ≤ −0,999 n'étant pas recoupées » est **périmée** pour −0,9999 et la garde à T = 8 (écarts de −0,30 et +0,34 ET) ; −0,999 lui-même reste non recoupé. « À moins de 1,8 erreur-type » reste vrai (maximum 1,73).
- **Exemple à reprendre tel quel s'il est cité** : sous la règle bilatérale de K421-2, un seul non-rejet sur 4·10⁵ à Imhof tronqué donne p ≈ **8,0e-4 (bilatéral)** : cellule signalée, sans désaccord. Ce n'est pas la valeur unilatérale 4,0e-4 (avis 421, point 2, corrigé par Q10).
- **Hors S9** : le commentaire du moteur (`R/engine.R` l. 2948-2952 et 2982-2993) reste tel quel (Q-S9-3 (a), S10). Le `.tex` ne doit pas le citer comme à jour.

**PM-3 : non.** « Tend vers 0 » est exact comme limite. Le cas T = 5, α = 0,05 complète la phrase sans la contredire, et l'avis de l'étape 1 l'avait prévu (§ 1.5). Aucun désaccord en K421-2.

---

## 2. #420 — Dépendance de W² et A² sous la loi bootstrap

**Tableau** : `docs/tableaux/20261127-issue420-correlation-cvm-ad.md` (B = 9 999, graine 20260831, aucun ex aequo).

### Verdict [V, T3 et T5]

**Critère satisfait sur J1 et J2 : quasi-redondance sous H0 établie.**

| Grandeur | J1 | J2 | Seuil |
|---|---|---|---|
| ρ_S | 0,9779 ± 0,00061 | 0,9763 ± 0,00044 | — |
| ρ_S − 2 ET | 0,9766 | 0,9754 | ≥ 0,90 |
| P(rejet CvM \| rejet AD), α = 0,10 | 0,8999 ± 0,0072 | 0,8809 ± 0,0091 | — |
| la même, moins 2 ET | 0,8856 | 0,8626 | ≥ 0,75 |

- La marge reste large même si l'ET est sous-estimé de 16 % (incertitude du jackknife à G = 20, Q3).
- Grandeurs secondaires :
  - Pearson : 0,984 et 0,980 ;
  - conditionnelle à α = 0,05 : 0,874 et 0,870 ;
  - rejet conjoint à α = 0,10 : 0,090 et 0,088, pour un repère de 0,10 sous comonotonie.

### Phrases du `.tex` et consignes pour `docwriter`

- **l. 12499-12501** : « La dépendance entre les deux statistiques … n'est chiffrée par aucun script versionné ni ici ; la chiffrer est un travail postérieur à la remise ».
  - Remplacer par les valeurs ci-dessus (estimation ± ET jackknife, erreur Monte-Carlo seule).
  - Nature : approximation Monte-Carlo d'une fonctionnelle de la loi bootstrap, conditionnelle aux paramètres ajustés, sur deux jeux, à T = 8.
  - Seuils 0,90 et 0,75 : conventions déclarées, sans fondement théorique.
  - Renvoyer à `tests/mesure_correlation_cvm_ad_t8.R` et au tableau.
- **l. 12493** (« presque deux fois la même information ») : la phrase peut rester. La chiffrer : sous H0, environ 88 à 90 % des rejets d'AD sont aussi des rejets de CvM.
- **Portée à écrire** : la mesure ne dit rien sous les alternatives, où la pondération des queues de A² les distingue. Elle ne dit pas qu'un seul verdict suffit en puissance.

**PM-3 : non** : on est dans la première branche du critère, sans phrase à nuancer.

---

## 3. #367 — Grubbs sur `premium_interieur`, p_∞

**Tableau** : `docs/tableaux/20261127-issue367-grubbs-interieur.md`.

### Verdict [V, T1 et T2]

- **Indécidable ALERTE/OK.** Lecture sur l'agrégat des quatre graines secondaires (Q7) :
  - K/N = 4 019 / 39 996, p̂_∞ = 0,10049 (ET binomiale 0,0015) ;
  - intervalle de Clopper–Pearson à 99 % : [0,09665 ; 0,10442], qui contient α = 0,10.
- **ECHEC exclu** : la borne basse dépasse α/2 = 0,05 de très loin.
- **Contrôles** :
  - (g2) : g_obs, δ̂, γ̂, σ̂ et σ_USP sont identiques au bit près entre les graines ;
  - χ² d'homogénéité : p asymptotique 0,686 (aucune anomalie grossière) ;
  - les 5 graines donnent la même classification, à titre d'information.
- **Par graine à B = 9 999** : 2 OK (0,1026 et 0,1022) et 2 ALERTE (0,0987 et 0,0988) ; la graine du dossier donne 0,0975, ALERTE, rapportée à part. Le verdict de la ligne dépend donc de la graine même à B = 9 999.
- La fiche prévoit un signal au mainteneur seulement si p_∞ < 0,10 est établi : **ce n'est pas le cas, aucun signal**.
- **Pour information [H]** : si p_∞ valait 0,1005, trancher à 99 % demanderait environ (2,576 × 0,30 / 0,0005)² ≈ 2,4·10⁶ tirages retenus. Aucun B praticable ne fixerait ce verdict sur ces données.

### Phrases du `.tex` et consignes pour `docwriter`

- **l. 8024-8025** (Grubbs sur `premium_interieur`, p = 0,105, err_mc = 0,0097, OK, phrase de #244, à B = 999) : la phrase reste **vraie** pour le dossier à B = 999.
  - Ajouter : à B infini, p_∞ est estimée à 0,1005, intervalle à 99 % [0,0967 ; 0,1044] (quatre graines secondaires, 39 996 tirages retenus, Monte-Carlo pur), donc indécidable entre ALERTE et OK ; ECHEC est exclu.
  - Nature : la mesure réduit l'erreur Monte-Carlo, non celle de l'approximation bootstrap (plug-in, T = 8). Elle ne dit pas si Grubbs est juste à T = 8.
- **Fiche Grubbs, l. 13989-13992** (« verdict fragile … bascule vers ALERTE possible, non vers ECHEC ») : **confirmée et chiffrée** par la mesure. Elle peut renvoyer au tableau.
- **À ne pas écrire** : que le OK du dossier soit faux, ou qu'il soit confirmé. Le chiffre de B = 4 999 (0,0926, ALERTE) reste du contexte (#325, même graine du dossier, effet de sélection, Q7).

**PM-3 : non** : aucune phrase n'est contredite.

---

## 4. #379 — Puissance des p de famille et de la p globale

**Tableaux** : `docs/tableaux/20261127-issue379-familles-ln.md` (lognormal) et `docs/tableaux/20261127-issue379-issue494-puissance-mw.md` (Merz-Wüthrich, F1).

### 4.1 Classes à α = 0,10 (taux [IC 95 %] ; classe) [V, F1]

**Lognormal**, famille visée par chaque scénario :

| Scénario | Famille visée | J1 | J2 |
|---|---|---|---|
| A(0,5) | E. | 0,227 [0,181 ; 0,278], faible | 0,180 [0,138 ; 0,228], faible |
| T(2) | B. | 0,377 [0,322 ; 0,434], faible | 0,177, faible |
| R(4,2) | F. | 0,520 [0,462 ; 0,578], intermédiaire | 0,500 [0,442 ; 0,558], intermédiaire |

Ligne globale LC :

| Scénario | J1 | J2 |
|---|---|---|
| A | 0,243 | 0,183 |
| T | 0,223 | 0,130, **non distinguée** du niveau (McNemar bilatéral 0,126) |
| R | 0,397 | 0,307 |

**Merz-Wüthrich** :
- M1 sous CST20 : 0,757 [0,704 ; 0,804], **substantielle**.
- M3 :
  - DCAL : 0,267, faible ;
  - AR(0,3) : 0,200, faible ;
  - AR(0,5) : 0,432 sous P1 et 0,418 sous P2, faibles.
- LC :
  - CST20 : 0,583, substantielle ;
  - DCAL : 0,423 ;
  - AR(0,3) : 0,164 ;
  - AR(0,5) : 0,292 sous P1 et 0,340 sous P2.
- M2 : non distinguée partout, sauf P2.AR05 à 0,10 (0,124, McNemar 0,044). M2 n'est visée par aucun scénario.

**Constats descriptifs à porter** :
1. **Les familles ne sont pas spécifiques.**
   - Sous A et sous T, sur J1, B. réagit plus que la famille visée (sous A : B. 0,337, E. 0,227).
   - Sous DCAL, M1 réagit plus que M3 (0,560 contre 0,267).
   - Une p de famille faible ne localise donc pas l'hypothèse en défaut. Le `.tex` ne l'affirme nulle part (`grep` sur les fiches des l. 19503-19700), mais la lecture doit le dire.
2. **Prix en puissance du contrôle de l'erreur**, lu en excès sur le niveau (avis § 5.3) :
   - sous alternative forte, π − π(H0) approche Û − Û(H0) ou le dépasse (CST20, M1 : +0,667 contre +0,632) ;
   - ailleurs, il reste en deçà (J1, R, F. : +0,393 contre +0,520).

### 4.2 Premier cas de PM-3 (signal mécanique : J1, point A, famille D., α = 0,10)

Recalculé sur le brut [V] : π̂ = 0,070 contre π̂(N) = 0,110 ; n01 = 14, n10 = 26 ; McNemar unilatéral 0,0403, identique au tableau.

**Je ne le retiens pas**, pour trois raisons.

1. **Multiplicité.**
   - 60 comparaisons unilatérales en lognormal (2 jeux × 3 scénarios × 5 lignes × 2 α), 100 avec Merz-Wüthrich.
   - Bonferroni : 0,0403 × 60 = 2,4. Restreint aux 12 cellules de D. : 0,48.
   - Sous l'hypothèse globale d'absence de biais, on attend jusqu'à environ 3 signaux nominaux sur 60 (McNemar exact, conservateur ; comparaisons corrélées). En observer un seul est compatible avec le hasard.
2. **Pas de reproduction.**
   - Même cellule sur J2 : 20 / 24, unilatéral 0,326.
   - J1 à α = 0,05 : 0,212.
   - J1 sous R : 0,072 ; J1 sous T : 0,329.
3. **Hors de l'objet du critère.**
   - Le § 5.6 vise un « test biaisé contre le scénario visé ». A vise E., non D.
   - Sous A, l'erreur reste marginalement gaussienne : l'hypothèse de D. (normalité) y est vraie au sens marginal. Le taux de D. sous A est donc un niveau sous dépendance de nuisance, non une puissance.
   - Constat descriptif [V, brut] : sur J1, les six membres de D. ont un taux plus bas sous A qu'en N (de JB 0,113 → 0,067 à D'Agostino 0,120 → 0,057). Le mécanisme n'est pas établi ; je n'en propose aucun.

### 4.3 Second cas de PM-3 (niveau sous H0 contre T-F1 de #297)

Ce calcul était prévu à l'étape 7 par l'avis de l'étape 5 (Q5). Il n'était dans aucun des deux tableaux : je l'ai fait.

**Conditions de Q5** :
1. m est fixé par la méthode : 20 en lognormal (J1 et J2 × B., D., E., F., LC × 2 α) ; 8 en Merz-Wüthrich (P1 contre la loi N × M1, M2, M3, LC × 2 α).
   - P2.H0 n'a pas de référence dans #297, dont le DGP est celui de P1.
   - M4, C. et G. n'ont pas de ligne.
2. La commande est citée avec sa sortie (ci-dessous). Elle sera versionnée par le versement de cet avis.
3. Le DGP de la loi N de #297 est celui de P1 **[V]** : f̂, σ̂² et première colonne (300 ; … ; 380) identiques entre le T0 de `docs/tableaux/20261026-issue297-calibration-famille-mw.md` (l. 7) et le T0 de S9 (l. 12).

Commande (R 4.3.3, `LC_ALL=C.UTF-8`, exécutée dans `/tmp`) :

```r
ln <- data.frame(jeu=rep(c("J1","J2"),each=10), fam=rep(rep(c("B.","D.","E.","F.","LC"),each=2),2),
 a=rep(c(0.10,0.05),10),
 kS9=c(37,17,33,12,34,17,38,18,34,18, 27,15,31,15,27,16,36,20,27,12), nS9=300,
 k297=c(219,117,186,94,186,104,199,109,215,105, 166,80,196,85,192,111,204,109,198,83), n297=2000)
mw <- data.frame(jeu="P1/N", fam=rep(c("M1","M2","M3","LC"),each=2), a=rep(c(0.10,0.05),4),
 kS9=c(45,20,43,17,42,18,37,14), nS9=500, k297=c(185,79,176,75,192,88,143,73), n297=2000)
f <- function(d,m){ d$p <- mapply(function(a,b,c,e) fisher.test(matrix(c(a,b-a,c,e-c),2))$p.value,
 d$kS9,d$nS9,d$k297,d$n297); d$p_bonf<-pmin(1,d$p*m); d}
r1 <- f(ln,20); r2 <- f(mw,8)
```

Sortie :
- lognormal : la plus petite p brute vaut **0,154** (J1, F., 0,10 : 38/300 contre 199/2000) ; p Bonferroni = 1 pour les 20 comparaisons ;
- Merz-Wüthrich : la plus petite p brute vaut **0,414** (LC, 0,05 : 14/500 contre 73/2000) ; p Bonferroni = 1 pour les 8 ;
- les taux sont lus sur F1 de S9 (point N et P1.H0) et sur T-F1 de #297 (`…-ln.md` l. 115-128, `…-mw.md` l. 162-166).

**Cas non déclenché**, même sans correction. La mesure ne contredit pas la phrase du `.tex` sur le niveau (« compatible ou en écart mineur conservateur »).

### 4.4 Phrases du `.tex` et consignes pour `docwriter`

**Passages à reprendre** :
- l. 8288-8292 : « leur puissance n'est pas mesurée (travail postérieur à la remise) » ;
- l. 8799 (tableau de nature des p) ;
- l. 19622 (fiche p de famille, « Puissance : non mesurée à T = 8 ») ;
- l. 19683 ;
- l. 19698 (fiche p globale) ;
- l. 22443-22444 (lecture conjointe).

**Ce qu'il faut y mettre** :
1. Les taux mesurés pour les familles et scénarios couverts, avec leurs intervalles de Clopper–Pearson (erreur d'échantillonnage, fonction de R).
2. La procédure à B = 999 : l'erreur Monte-Carlo fait partie de la procédure mesurée, la puissance à B infini n'est pas mesurée.
3. Le plan : J1 et J2, volet B, R = 300 ; Merz-Wüthrich P1 (et P2 pour AR(0,5)), DGP de `reserve2`.
4. La nature : constat de simulation sous plan, sans transposition ; p plug-in non exactes.
5. **Garder et chiffrer** « une p élevée n'atteste pas l'adéquation ». Elle vaut pour toutes les cellules, sauf M1 et LC sous CST20, M1 sous DCAL, et F. sous R (à 0,50 ou 0,52).
6. **Déclarer non mesurées** : D. (aucun scénario non normal), M2 (aucun scénario d'hétéroscédasticité retenu sous P1), C., G. et M4 (pas de ligne).
7. La non-spécificité des familles (§ 4.1, constat 1).
8. La convention du dénominateur (n = lignes présentes, comme T-F1 de #297 ; T-F3 prend toutes les réplications), Q4 de l'étape 5.
9. Facultatif : le constat sur D. sous A en J1, avec la mention « non significatif après prise en compte des 60 comparaisons ; D. n'est visée par aucun scénario ».

**PM-3 : non.**

---

## 5. #494 — CorrDev contre une persistance AR(1) dans l'année d'accident

**Tableau** : `docs/tableaux/20261127-issue379-issue494-puissance-mw.md`, sections F3 et F4.

### Verdict [V]

**Classes du § 4.5** (CorrDev ; McNemar apparié contre la cellule H0 du plan) :

| Cellule | α = 0,10 | α = 0,05 |
|---|---|---|
| P1.AR(0,3) | 0,238 [0,201 ; 0,278], faible | 0,146 [0,116 ; 0,180], faible |
| P1.AR(0,5) | 0,474 [0,429 ; 0,519], **intermédiaire** (l'intervalle contient 0,5) | 0,334, faible |
| P2.AR(0,5) | 0,432 [0,388 ; 0,477], faible | 0,346 [0,304 ; 0,390], faible |

Toutes ces cellules sont distinguées du niveau (p bilatérale ≤ 1,2e-9).

**DW sur résidus de Mack** : non distingué du niveau dans 5 cellules sur 6. Seule exception : P1.AR(0,3) à 0,05 (0,070 contre 0,048, McNemar bilatéral 0,043), non confirmée à ρ = 0,5 ni sous P2. Constat : DW ne corrobore pas CorrDev contre cette alternative ; le mécanisme n'est pas établi.

**PM-3, premier cas** : taux de CorrDev des cellules H0 « compatible » avec la taille ρ de #309, dans les quatre cellules (F4).

**PM-3, second cas** : identité mécanique. On obtient n01 = n10 = 0 et p = 1 sur les 500 paires, car obs:CorrDev et p_mc sont identiques au brut de #309, triangle par triangle (avis 5 bis, Q3). **Ce cas ne pouvait pas se déclencher.** Il atteste que la chaîne CorrDev (statistique, DGP, règle « ≥ » d'`engine_p_mc()`) n'a pas changé depuis #309. Ce n'est pas une confirmation indépendante du niveau.

### Phrases du `.tex` et consignes pour `docwriter`

**Passages** :
- l. 10528 (tableau de la section des limites, « puissance non étudiée … travail postérieur à la remise ») ;
- **l. 9991** (tableau de puissance, ligne CorrDev : « Non étudiée (taux … d'une autre famille, non repris) ») ;
- **l. 18540** (fiche `mw:m3cor`, rubrique 7 : « mesure de puissance dont aucun scénario ne vise la dépendance que teste la ligne ; cette mesure est un travail postérieur à la remise »).

Les deux derniers ne figurent pas dans la liste de la fiche S9. **La l. 9768 citée par la fiche concerne le volet lognormal**, et non CorrDev.

**Ce qu'il faut y mettre** :
1. Les taux ci-dessus, avec intervalles et classes (seuils 0,5 : convention déclarée).
2. Le plan : P1 et P2, R = 500, nombres aléatoires communs, P3 non mesuré.
3. Le scénario : AR(1) sur l'erreur standardisée des transitions d'une même année d'accident, variance marginale 1.
4. La procédure : B = 999.
5. La nature : constat de simulation sous un seul DGP (Mack gaussien ajusté à `reserve2`, géométrie 8 × 8, première colonne fixée) et une seule forme de dépendance.
6. Le constat sur DW.
7. Le lien à D(2)(h)(ii), repris de l'issue et non vérifié par moi : à ne citer que tel que la documentation l'établit déjà (l. 18573).
8. Pour le niveau sous P2, garder la lecture de #309 sur 1 000 triangles (0,119, écart mineur libéral). Le « compatible » de F4 porte sur le sous-ensemble b = 1..500 des **mêmes** triangles : ce n'est pas une mesure nouvelle du niveau.

**PM-3 : non.**

---

## Retour

- **Statut** : `complet`. Chaque issue a reçu son verdict contre les critères écrits d'avance, avec les corrections tracées dans la trace M42. Le seul calcul que les tableaux ne portaient pas (#379, second cas de PM-3) a été exécuté ici, avec sa commande et sa sortie.
- **Résultat** :
  - #421 : K421-1 à K421-5 satisfaits ;
  - #420 : quasi-redondance sous H0 établie ;
  - #367 : indécidable ALERTE/OK, ECHEC exclu, aucun signal ;
  - #379 : classes établies, un signal nominal non retenu (multiplicité, hors objet), second cas non déclenché ;
  - #494 : classes établies, PM-3 non déclenché ; le second cas ne pouvait pas l'être.
  - **Pas de PM-3**, pas de défaut du moteur. Phrases du `.tex` à faire évoluer à l'étape 8 : l. 1329-1342, 1351-1353, 9886 et suivantes, 13008 (#421) ; 12493 et 12499-12501 (#420) ; 8024-8025 et 13989-13992 (#367) ; 8288-8292, 8799, 19622, 19683, 19698, 22443-22444 (#379) ; 9991, 10528, 18540 (#494).
- **Preuves** :
  - *[V]* lecture intégrale des cinq tableaux et des six documents de `docs/revues/20261127-s9-mesures/` ;
  - *[V]* McNemar de la famille D. recalculé sur `20261127-issue379-familles-ln-brut.tsv` pour les 12 cellules de D. (identique au tableau ; taux des six membres) ;
  - *[V]* Fisher du second cas de #379, commande et sortie au § 4.3 ;
  - *[V]* DGP P1 = loi N de #297 (deux T0) ;
  - *[V]* passages du `.tex` lus aux lignes citées, et texte du `detail` de CorrDev (`R/engine.R` l. 17246-17259).
  - *[H]* nombre de tirages nécessaires pour trancher #367 ; nombre de faux signaux attendus sous l'hypothèse globale (comparaisons corrélées, McNemar discret) ; absence de mécanisme établi pour D. sous A et pour DW sous AR(1).
- **Informations manquantes** : aucune pour ces verdicts. La commande du § 4.3 n'est dans aucun script : elle n'est versionnée que par le versement de cet avis (condition 2 de Q5, remplie de cette façon).
- **Décisions non résolues** : aucune pour le mainteneur (pas de PM-3, pas de signal #367). Information, sans décision demandée : relever B ne trancherait pas le verdict Grubbs de `premium_interieur` (Q-Ff-5).
- **Critères déclenchés** (`routage.md`, § 4) : aucun changement de résultat du moteur ; aucun désaccord avec `audit` ni avec un ADR. Un écart de méthode à tracer : le second cas de PM-3 de #379 a été calculé par actuary à l'étape 7, et non par un script.
- **Constats hors périmètre** (ADR 0018) :
  1. La fiche S9 (constats, « #494 : l. 9768 et 10528 ») cite la l. 9768, qui concerne le volet lognormal ; les passages CorrDev sont les l. 9991, 10528 et 18540. Critère : aucun (précision du plan ; la consigne pour `docwriter` le corrige).
  2. Dans le tableau de #379, la colonne « classe (par. 4.5) » renvoie au § 4.5, alors que le critère lognormal est au § 5.6, qui reprend les classes du § 4.5. Critère : aucun.
  - Aucun constat marquant.
- **Prochaine action recommandée** : la session verse cet avis dans `docs/revues/20261127-s9-mesures/` et complète `synthese.md` (étape 7 : aucun PM-3). Puis passage unique de `docwriter` en `high` (étape 8), avec les consignes ci-dessus, un commit `docs:` par issue, et la vie du dépôt dans `docs/suivi-documentation/`.
