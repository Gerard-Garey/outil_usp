# Loi de l'écart de var(r) à la référence (N − k)/(N − 1) sous trois exposants de variance (issue #503)

| Grandeur | Valeur |
|---|---|
| Date | 2026-11-11 |
| Commande | `LC_ALL=C.UTF-8 Rscript tests/mesure_m2var_exposants_mw.R --coeurs 4 --sortie docs/tableaux/20261111-issue503-m2var-exposants.md` (depuis la racine du dépôt) |
| Script | `tests/mesure_m2var_exposants_mw.R`, md5 `0053b7dff1f3201f1de04dc01c1b6cda` |
| Moteur | `R/engine.R`, md5 `c5fa9141b295d2c0099391ec01552031` |
| Commit de base | `d6bbd74fb40dc7ba7d2b86e675c98feca975126a` (arbre de travail modifié : script et moteur identifiés par leur md5) |
| R, plateforme | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Graines | triangle b du plan p (P1 = 1, P2 = 2) : 20261111 + 10000 (p − 1) + b, commune aux trois exposants ; volet R : 20260831 |
| Effectifs | 2000 triangles tirés par cellule (plan, exposant), soit 12000 tirages ; volet R : B = 999 |
| Processus | 4 |
| Durée | 25 s |

Statut : constat de simulation sous un plan (modèle de Mack gaussien ajusté à `reserve2`, géométrie 8 × 8) ; aucun théorème.
Les IC de Clopper–Pearson et les p de T2b ne mesurent que l'incertitude due au nombre fini de triangles tirés (2 000 par cellule) ; ils ne disent rien d'un autre plan ni d'une autre géométrie.
Modèle : C(i,j+1) = f_j C(i,j) + e σ_j √(C(i,j)^κ Cb_j^(1−κ)), e ~ N(0,1), Cb_j = moyenne des C(0..I−j−1, j) simulés de la colonne ; f_j et σ_j² de `reserve2` ;
κ ∈ {0, 1, 2}. Plans de `tests/puissance_mw_t8.R` : P1, première colonne de `reserve2` ; P2, première colonne mean(C0) + 3,4 (C0 − mean(C0)).
**Les trois exposants d'un même plan partagent les mêmes graines (nombres aléatoires communs) : leurs colonnes ne sont pas indépendantes, et la comparaison est appariée.**
Écart = var(r) − (N − k)/(N − 1) = − N moyenne(r)²/(N − 1) (identité exacte de la fiche `mw:m2var`), calculé comme `mw_tests()` sur les résidus de `mw_residus()`.
Quantiles de |écart| : type 7 de `stats::quantile()`. IC : Clopper–Pearson à 95 %. Nombres : notation scientifique, virgule décimale.

## Contrôles (tous bloquants)

| Contrôle | Résultat | Détail |
|---|---|---|
| (copie) | OK | 4 fonctions et 4 constantes de tests/puissance_mw_t8.R (md5 0e825b10de930e8cd097600c40c6c008) identiques (formals, corps ; valeur) à celles de ce script |
| (sc) | OK | à K = 1, gen_triangle_scen() = gen_triangle_h0() sous la même graine, identical(), sur 100 / 100 graines de P1 et 100 / 100 de P2 (b = 1..100) |
| (r2) | OK | reserve2 : N = 27, k = 6 ; référence recalculée 0.807692 (detail : 0.807692), moyenne des résidus recalculée -0.0151 (detail : -0.0151) |
| (id) | OK | défaut d'identité maximal sur les 12000 triangles admis : 3,22e-16 (seuil 1e-12) |
| (flux) | OK | sigma_boot recalculé sur le flux du volet R identique (identical()) à mw_bootstrap(aj, B = 999, seed = 20260831)$sigma_boot, sur 999 valeurs |
| (id, volet R) | OK | volet R : défaut d'identité maximal 2,57e-16 sur 999 triangles (seuil 1e-12) |

## T1 — Loi de l'écart par plan et par exposant

| Plan | κ | Tirés | Admis | max \|écart\| | q50 | q90 | q99 | écart moyen | \|écart\| > 1e-3 | Part | IC 95 % de la part | Défaut d'identité max |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P1 | 0 | 2000 | 2000 | 3,68e-04 | 1,38e-05 | 7,41e-05 | 1,84e-04 | -2,79e-05 | 0 | 0,00000 | [0,00000 ; 0,00184] | 3,22e-16 |
| P1 | 1 | 2000 | 2000 | 3,69e-04 | 1,33e-05 | 7,50e-05 | 1,83e-04 | -2,76e-05 | 0 | 0,00000 | [0,00000 ; 0,00184] | 2,49e-16 |
| P1 | 2 | 2000 | 2000 | 3,69e-04 | 1,30e-05 | 7,55e-05 | 1,80e-04 | -2,74e-05 | 0 | 0,00000 | [0,00000 ; 0,00184] | 2,39e-16 |
| P2 | 0 | 2000 | 2000 | 6,17e-03 | 1,91e-04 | 1,12e-03 | 2,63e-03 | -4,13e-04 | 252 | 0,12600 | [0,11176 ; 0,14134] | 2,65e-16 |
| P2 | 1 | 2000 | 2000 | 5,76e-03 | 1,79e-04 | 1,06e-03 | 2,48e-03 | -3,86e-04 | 224 | 0,11200 | [0,09851 ; 0,12664] | 2,63e-16 |
| P2 | 2 | 2000 | 2000 | 5,42e-03 | 1,73e-04 | 9,84e-04 | 2,41e-03 | -3,73e-04 | 196 | 0,09800 | [0,08532 ; 0,11188] | 2,64e-16 |

Refus par motif (admettre()) :

Aucun refus : tous les triangles tirés sont admis.

## T2 — Comparaison appariée entre exposants (triangles admis sous les trois exposants)

| Plan | Triangles appariés | max \|écart(κ=0) − écart(κ=1)\| | max \|écart(κ=2) − écart(κ=1)\| | D de KS, \|écart\| κ=0 contre κ=1 | D de KS, κ=2 contre κ=1 | Critère de l'avis amont : IC de T1 disjoints (appariement ignoré) |
|---|---|---|---|---|---|---|
| P1 | 2000 | 2,99e-05 | 4,36e-05 | 0,010 | 0,011 | non |
| P2 | 2000 | 6,41e-04 | 8,96e-04 | 0,025 | 0,017 | non |

### T2b — Parts à |écart| > 1e-3 : comparaison appariée

| Plan | Comparaison | Seul au-delà du seuil : 1er exposant | Seul au-delà du seuil : 2e exposant | p bilatéral du test exact de McNemar (indicatif) |
|---|---|---|---|---|
| P1 | κ=0 contre κ=1 | 0 | 0 | — |
| P1 | κ=2 contre κ=1 | 0 | 0 | — |
| P1 | κ=0 contre κ=2 | 0 | 0 | — |
| P2 | κ=0 contre κ=1 | 44 | 16 | 3,94e-04 |
| P2 | κ=2 contre κ=1 | 17 | 45 | 4,97e-04 |
| P2 | κ=0 contre κ=2 | 89 | 33 | 4,04e-07 |

T2b : triangles appariés (mêmes graines). Test exact de McNemar : loi binomiale de paramètre 1/2 sur les triangles discordants. Le p est indicatif : trois comparaisons par plan, sans seuil ni correction de multiplicité pré-spécifiés. Il porte sur le modèle de simulation, non sur des données observées : un p petit dit que le décalage des parts entre exposants ne s'explique pas par le nombre fini de triangles tirés, non qu'il est grand ; sa taille se lit dans T1.
D de KS : statistique descriptive entre les lois empiriques de |écart| de deux exposants (échantillons non indépendants : aucune p-value n'en est tirée).
La dernière colonne est la lecture mécanique du critère de l'avis amont de K4 (§ 5.3) : « oui » si deux des trois IC de Clopper–Pearson de la part à |écart| > 1e-3 sont disjoints au sein du plan. Ce critère ignore l'appariement et est conservateur : « non » ne signifie pas l'absence de différence entre exposants ; la comparaison appariée est en T2b.

## T3 — Volet R : bootstrap de résidus de `reserve2` (support de la rubrique 4 de `mw:m2var`)

999 triangles par `.mw_tirer_triangle_valide()` sur le vivier de `.mw_pool_residus()`, `engine_sous_graine(20260831, ...)` ; var(r) recalculée sur chacun, colonnes dégénérées figées à l'observé.

| Grandeur | Valeur |
|---|---|
| Triangles tirés (retirés compris) / retenus | 999 / 999 |
| Échecs de `mw_ajuster()` | 0 |
| Plafond de retirage atteint | non |
| (N, k) observés | (27, 6) |
| Référence (N − k)/(N − 1) de `reserve2` | 0,807692 |
| min var(r) | 0,80740 |
| max var(r) | 0,80769 |
| Étendue | 2,90e-04 |

**Tous les contrôles tiennent.**
