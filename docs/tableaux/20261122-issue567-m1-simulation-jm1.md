# Tableau avant / après — constat M-1 de la revue finale de #567 : simulation de la colonne J−1 d'un trapèze quand la règle de minimum est nulle ou négligeable (option (b)), et constat m-1 (mention M6 et légendes `usage_sigma` par cas)

| Grandeur | Valeur |
| --- | --- |
| Date | 2026-11-22 |
| Décision | Mainteneur, 22/11/2026 : option (b), prédicat à trois conditions, `MW_TOL_SIGMA_SIMULATION = 1e-10`, dérogation à Q-2a-2 dans ce seul cas, verdicts changés acceptés sur la classe d'entrées visée (avis d'actuary `docs/revues/20261120-s6-trapeze/actuary-10-avis-m1-bootstrap-jm1.md`) |
| Commande | `LC_ALL=C.UTF-8 Rscript tableau_m1.R engine_avant.R engine_apres.R` (racine du dépôt ; script hors dépôt, reproduit en annexe, md5 `1a99f23beb5e2cdd658c8d64d6a48c6b`) |
| Moteur avant | `R/engine.R` de `4c96c79` (`git show 4c96c79:R/engine.R`), md5 `c54a2b97e3653d99f35d96622d3bbb53` |
| Moteur après | `R/engine.R` de l'arbre de travail (commit `moteur:` de ce tableau), md5 `3b34c8ca9f1471c0f276997986624854` (mesures faites sur la version md5 `a0b88f0e8d823c0b7e0c42273da86566`, qui n'en diffère que par deux commentaires de `.mw_simulation_sigma_direct()`) |
| R, plateforme | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 |
| Appels | `run_engine(methode = "reserve2", triangle, segment = 1, annexe = "II", date_reference = "2026-01-01", B = 999, seed = 20260831)`, alpha = 0,10 (défaut) |
| Triangles | 8 x 6 du cas `reserve2_trapeze` (colonnes 0..5 de `tests/donnees/triangle_mw.csv`) ; **(s2)** de l'audit : facteurs de la colonne j = 2 (J−3) posés exactement à 1,07, colonnes suivantes reconstruites avec les facteurs individuels d'origine (`identical()` au `t2.rds` d'actuary) ; **variante J−2 dégénérée** : facteurs de la colonne j = 3 (J−2) posés exactement à 1,03, même reconstruction. Hors références. |

## 1. Références : les sept cas inchangés

Aucun cas de `CAS` n'emprunte le nouveau chemin : `.mw_simulation_sigma_direct()` vaut FALSE sur `reserve2` (carré, cas « carre ») et sur `reserve2_trapeze` (cas « general », règle non nulle, 0,1419278 ; aucune colonne J−3 ou J−2 dégénérée) ; les cinq cas lognormaux n'appellent pas `mw_bootstrap()`.

Mesure : `LC_ALL=C.UTF-8 Rscript tests/comparer_references.R --seuil 0` (arbre de travail, moteur md5 `a0b88f0e…`, puis `3b34c8ca…`), code de sortie 0 :

| Cas | Feuilles | Non strictement identiques | Écart maximal |
| --- | --- | --- | --- |
| `premium` | 57022 | 0 | 0.000e+00 |
| `reserve1` | 57021 | 0 | 0.000e+00 |
| `reserve2` | 18746 | 0 | 0.000e+00 |
| `premium_ii6` | 57022 | 0 | 0.000e+00 |
| `premium_net` | 57022 | 0 | 0.000e+00 |
| `premium_interieur` | 57022 | 0 | 0.000e+00 |
| `reserve2_trapeze` | 18573 | 0 | 0.000e+00 |

`LC_ALL=C.UTF-8 Rscript tests/test_reproductibilite.R` : « OK : reproductibilite et non-regression verifiees pour 7 cas », σ_USP inchangés (dont `reserve2` 0,0497764613 et `reserve2_trapeze` 0,0475797067). Aucune régénération de référence.

## 2. Cas (s2) et variante J−2 dégénérée, B = 999 (visa du mainteneur : deux verdicts changent par cas)

σ_USP, MSEP, ajustement, résidus et statistiques observées sont identiques au bit (`identical()`) avant et après : seule la loi simulée de la colonne J−1 change. Lignes listées : toutes celles qui ont une p Monte-Carlo, et celles qui changent ; les autres lignes sont identiques.

### Cas s2

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,04596181746 | 0,04596181746 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| MSEP | 6356,543909 | 6356,543909 |
| `ajustement`, `msep`, `residus` identical() | TRUE | |
| σ²_{J−1} règle ; direct (degrés de liberté) | 0 ; 0,0786829 (2) | idem |
| Colonne dégénérée qui annule la règle | J−3 (j = 2) | idem |
| `.mw_simulation_sigma_direct()` | (absente) | TRUE |
| `bootstrap$stats_obs` identical() | TRUE | |
| B effectif d'Origine (autres clés : 999) | 0 | 999 |
| Clés à B effectif = 999 | 12 / 13 | 13 / 13 |
| `ic_bootstrap` (2,5 ; 5 ; 50 ; 95 ; 97,5 %) | 0,0432185 ; 0,0435975 ; 0,0458171 ; 0,0479557 ; 0,0482016 | 0,0432167 ; 0,0436129 ; 0,0458059 ; 0,0479622 ; 0,0482224 |
| `plots_data$usage_sigma["sigma"]` | sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP et simulation | sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP |
| `plots_data$usage_sigma["sigma_residus"]` | sigma_(J-1) estime directement : residus de Mack et tests | sigma_(J-1) estime directement : residus, tests et simulation |

| # | Famille | Test | p_mc avant | p_mc après | nature avant | nature après | p retenue avant | p retenue après | verdict avant | verdict après | ligne |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | M1 | Absence de tendance des facteurs avec le cumul, a colonne donnee | 0,084 | 0,078 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,084 | 0,078 | ALERTE | ALERTE | modifiée |
| 2 | M1 | Nullite de l'ordonnee a l'origine, colonne par colonne | — | 0,123 | — | Monte-Carlo (bootstrap de residus) | — | 0,123 | INFO | **OK** | **verdict change** |
| 3 | M1 | Homogeneite de f_j entre annees de survenance | 0,114 | 0,114 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,114 | 0,114 | OK | OK | identique |
| 4 | M1 | Absence de courbure de la regression | 0,221 | 0,221 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,221 | 0,221 | OK | OK | identique |
| 5 | M1 | Stabilite du facteur selon la ponderation (famille alpha) | 0,025 | 0,030 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,025 | 0,030 | ECHEC | ECHEC | modifiée |
| 7 | M2 | Heteroscedasticite residuelle vs cumul | 0,540 | 0,555 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,540 | 0,555 | OK | OK | modifiée |
| 8 | M2 | Adequation de l'exposant de variance, colonne par colonne | 0,570 | 0,570 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,570 | 0,570 | OK | OK | identique |
| 10 | M3 | Effets d'annee calendaire (test de Mack) | 0,024 | 0,014 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,024 | 0,014 | ECHEC | ECHEC | modifiée |
| 12 | M3 | Homogeneite des residus entre annees de survenance | 0,343 | 0,343 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,343 | 0,343 | OK | OK | identique |
| 13 | M3 | Correlation entre annees de developpement adjacentes | 0,646 | 0,686 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,646 | 0,686 | OK | OK | modifiée |
| 14 | M3 | Autocorrelation des residus (Durbin-Watson) | 0,054 | 0,028 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,054 | 0,028 | ALERTE | **ECHEC** | **verdict change** |
| 15 | M3 | Test des suites sur les residus de Mack | 0,560 | 0,494 | — | — | — | — | INFO | INFO | modifiée |
| 16 | M4 | Cellule aberrante du triangle (residus studentises externes) | 0,844 | 0,844 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,844 | 0,844 | OK | OK | identique |
| 20 | M6 | Extrapolation de sigma pour la derniere annee de developpement | — | — | — | — | — | — | INFO | INFO | modifiée |
| 22 | M1 | p de famille (minP, lecture conjointe) | 0,083 | 0,116 | — | — | — | — | INFO | INFO | modifiée |
| 23 | M2 | p de famille (minP, lecture conjointe) | 0,755 | 0,774 | — | — | — | — | INFO | INFO | modifiée |
| 24 | M3 | p de famille (minP, lecture conjointe) | 0,081 | 0,054 | — | — | — | — | INFO | INFO | modifiée |
| 25 | LC | p globale (minP, lecture conjointe de la batterie) | 0,207 | 0,145 | — | — | — | — | INFO | INFO | modifiée |

Lignes : 25 ; identiques : 12 ; modifiées : 13 ; verdicts changés : 2.

### Cas jm2

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,04642563149 | 0,04642563149 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| MSEP | 9020,159319 | 9020,159319 |
| `ajustement`, `msep`, `residus` identical() | TRUE | |
| σ²_{J−1} règle ; direct (degrés de liberté) | 0 ; 0,0865463 (2) | idem |
| Colonne dégénérée qui annule la règle | J−2 (j = 3) | idem |
| `.mw_simulation_sigma_direct()` | (absente) | TRUE |
| `bootstrap$stats_obs` identical() | TRUE | |
| B effectif d'Origine (autres clés : 999) | 0 | 999 |
| Clés à B effectif = 999 | 12 / 13 | 13 / 13 |
| `ic_bootstrap` (2,5 ; 5 ; 50 ; 95 ; 97,5 %) | 0,0436016 ; 0,0440056 ; 0,0464455 ; 0,0484035 ; 0,0487813 | 0,0436399 ; 0,0440182 ; 0,0464243 ; 0,0484136 ; 0,0487727 |
| `plots_data$usage_sigma["sigma"]` | sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP et simulation | sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP |
| `plots_data$usage_sigma["sigma_residus"]` | sigma_(J-1) estime directement : residus de Mack et tests | sigma_(J-1) estime directement : residus, tests et simulation |

| # | Famille | Test | p_mc avant | p_mc après | nature avant | nature après | p retenue avant | p retenue après | verdict avant | verdict après | ligne |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | M1 | Absence de tendance des facteurs avec le cumul, a colonne donnee | 0,052 | 0,042 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,052 | 0,042 | ALERTE | **ECHEC** | **verdict change** |
| 2 | M1 | Nullite de l'ordonnee a l'origine, colonne par colonne | — | 0,057 | — | Monte-Carlo (bootstrap de residus) | — | 0,057 | INFO | **ALERTE** | **verdict change** |
| 3 | M1 | Homogeneite de f_j entre annees de survenance | 0,056 | 0,056 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,056 | 0,056 | ALERTE | ALERTE | identique |
| 4 | M1 | Absence de courbure de la regression | 0,031 | 0,031 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,031 | 0,031 | ECHEC | ECHEC | identique |
| 5 | M1 | Stabilite du facteur selon la ponderation (famille alpha) | 0,005 | 0,005 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,005 | 0,005 | ECHEC | ECHEC | identique |
| 7 | M2 | Heteroscedasticite residuelle vs cumul | 0,504 | 0,506 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,504 | 0,506 | OK | OK | modifiée |
| 8 | M2 | Adequation de l'exposant de variance, colonne par colonne | 0,495 | 0,495 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,495 | 0,495 | OK | OK | identique |
| 10 | M3 | Effets d'annee calendaire (test de Mack) | 0,003 | 0,001 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,003 | 0,001 | ECHEC | ECHEC | modifiée |
| 12 | M3 | Homogeneite des residus entre annees de survenance | 0,225 | 0,244 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,225 | 0,244 | OK | OK | modifiée |
| 13 | M3 | Correlation entre annees de developpement adjacentes | 0,114 | 0,114 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,114 | 0,114 | OK | OK | identique |
| 14 | M3 | Autocorrelation des residus (Durbin-Watson) | 0,038 | 0,020 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,038 | 0,020 | ECHEC | ECHEC | modifiée |
| 15 | M3 | Test des suites sur les residus de Mack | 0,326 | 0,244 | — | — | — | — | INFO | INFO | modifiée |
| 16 | M4 | Cellule aberrante du triangle (residus studentises externes) | 0,836 | 0,836 | Monte-Carlo (bootstrap de residus) | Monte-Carlo (bootstrap de residus) | 0,836 | 0,836 | OK | OK | identique |
| 20 | M6 | Extrapolation de sigma pour la derniere annee de developpement | — | — | — | — | — | — | INFO | INFO | modifiée |
| 22 | M1 | p de famille (minP, lecture conjointe) | 0,015 | 0,021 | — | — | — | — | INFO | INFO | modifiée |
| 23 | M2 | p de famille (minP, lecture conjointe) | 0,706 | 0,719 | — | — | — | — | INFO | INFO | modifiée |
| 24 | M3 | p de famille (minP, lecture conjointe) | 0,009 | 0,002 | — | — | — | — | INFO | INFO | modifiée |
| 25 | LC | p globale (minP, lecture conjointe de la batterie) | 0,027 | 0,009 | — | — | — | — | INFO | INFO | modifiée |

Lignes : 25 ; identiques : 13 ; modifiées : 12 ; verdicts changés : 2.

## 3. Explication de chaque écart

- **Cause unique.** Avant : `mw_bootstrap()` tirait la colonne J−1 avec la valeur de la règle de minimum, ici exactement nulle (colonne J−3, resp. J−2, dégénérée) ; la colonne J−1 simulée était déterministe (F(i,J−1) = f_{J−1}) alors que la colonne observée est dispersée (σ̂²_dir = 0,0786829, resp. 0,0865463). Après : `.mw_simulation_sigma_direct(aj)` est vrai et les triangles sont tirés sur une copie `aj_sim` dont σ²_{J−1} est l'estimateur direct ; vivier, contexte et statistiques observés, ensembles figés, ajustement et MSEP des réplications restent sur `aj` (code : `mw_bootstrap()`). Pour chaque triangle tiré, mêmes appels à `sample()`, dans le même ordre.
- **Origine (ligne 2)** : avant, B effectif = 0 (motif « aucune replication finie (B_effectif = 0) ») ; dans chaque réplication la colonne J−1 sort dégénérée au sens de `.mw_colonne_degeneree()` (mesure : boucle de `mw_bootstrap()` reproduite à B = 99 sur (s2), 99 réplications sur 99, assertion « temoin » de `tests/unitaires/test_merz_wuthrich_trapeze.R`), sans appartenir à l'ensemble figé à l'observé, et `mw_test_ordonnee_origine()` rend alors `na_stat()` (prédicat de la réplication, `degeneres_aj`). La ligne était un diagnostic sans p-value (INFO). Après : 999 réplications, p_mc 0,123 ± 0,010 (s2, OK) et 0,057 ± 0,007 (variante, ALERTE, à moins de deux erreurs Monte-Carlo du seuil 0,05 : phrase de #244 dans le détail).
- **Autres lignes modifiées** (DW, Calendrier, Runs, BP, PenteIntra, et selon le triangle CorrDev, KruskalAcc, Alpha) : avant, la colonne J−1 de chaque réplication est dégénérée ; après, aucune ne l'est et chacune garde ses 3 résidus de la colonne J−1, comme l'observé (mesure : boucle reproduite à B = 99 sur (s2), assertion « boucle reproduite » du même fichier) ; d'où les p_mc modifiées. Verdicts changés : DW de (s2) ALERTE (0,054 ± 0,010) → ECHEC (0,028 ± 0,007) ; PenteIntra de la variante ALERTE (0,052 ± 0,010) → ECHEC (0,042 ± 0,009).
- **Lignes identiques** (`identical()` de la ligne, constat de mesure, mécanisme non analysé statistique par statistique) : HomogF, Courbure, ExpVar, MinP4 sur les deux triangles ; KruskalAcc sur (s2) ; CorrDev et Alpha sur la variante.
- **Lignes de lecture conjointe (minP, #297)** : recalculées sur les réplications modifiées ; diagnostics sans verdict.
- **Ligne M6** (constat m-1) : la mention finale du détail est celle du cas « simulation » (`FORMAT_MENTION_MW_SIGMA_DIRECT_SIMULATION`) au lieu du gabarit général, qui écrivait à tort « sans entrer dans la MSEP ni dans la simulation » ; `estim` inchangé (valeur de la règle, 0).
- **`plots_data$usage_sigma`** : légendes du cas « simulation » (`MW_USAGE_SIGMA_SIMULATION`).
- **σ_boot et `ic_bootstrap`** : quantiles déplacés d'au plus 4e-5 en valeur absolue sur σ_USP ; σ_USP lui-même inchangé.

Erreurs Monte-Carlo (`err_mc`) : celles du champ `bootstrap$err_mc` des objets mesurés. Validité à T = 8 : p-values Monte-Carlo d'un bootstrap semi-paramétrique à paramètres estimés ; aucun théorème ; niveau observé par simulation sous un seul plan (avis d'actuary, § « Niveau sous H0 »).

## 4. Constat m-1 : mention et légendes par cas (sans changement numérique)

Cas lu par `.mw_cas_sigma_direct(aj)` : « carre » (champ `sigma2_Jm1_direct` absent : mention vide, `MW_USAGE_SIGMA`), « degenere » (colonne J−1 dégénérée : `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE`, `MW_USAGE_SIGMA_DEGENERE`), « simulation » (prédicat vrai : `FORMAT_MENTION_MW_SIGMA_DIRECT_SIMULATION`, `MW_USAGE_SIGMA_SIMULATION`), « general » sinon (gabarit et légendes inchangés). Le cas (s1) de l'audit (colonne J−1 à facteurs exactement 2) passe du gabarit général au gabarit « degenere » ; aucune p-value ni aucun verdict n'en dépend (assertions « m-1 (s1) » de `tests/unitaires/test_merz_wuthrich_trapeze.R`).

## Annexe : script de mesure (hors dépôt)

```r
# Tableau avant / apres du constat M-1 (#567) : moteur de 4c96c79 (git show)
# contre l'arbre de travail ; cas (s2) de l'audit et variante J-2 degeneree,
# B = 999, graine 20260831. Usage (racine du depot) :
#   LC_ALL=C.UTF-8 Rscript tableau_m1.R <engine_avant.R> <engine_apres.R>
a <- commandArgs(TRUE)
source("R/charger_moteur.R")
mav <- charger_moteur(a[1], dans = NULL); map <- charger_moteur(a[2], dans = NULL)
df <- utils::read.csv("tests/donnees/triangle_mw.csv")
car <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(car) <- "double"; car <- unname(car)
fixer <- function(t0, jc, Fv) {
  t <- t0; I <- nrow(t0) - 1L; J <- ncol(t0) - 1L; idx <- seq_len(I - jc)
  t[idx, jc + 2] <- Fv * t[idx, jc + 1]
  if (jc + 2L <= J) for (j in (jc + 2L):J) {
    id <- which(!is.na(t0[, j + 1])); t[id, j + 1] <- t[id, j] * (t0[id, j + 1] / t0[id, j]) }
  t[row(t) + col(t) - 2L > I] <- NA
  t
}
t86 <- car[, 1:6]; t86[row(t86) + col(t86) - 2L > 7L] <- NA
jeux <- list(s2 = fixer(t86, 2L, rep(1.07, 5)), jm2 = fixer(t86, 3L, rep(1.03, 4)))
appel <- function(m, t) m$run_engine(methode = "reserve2", triangle = t, segment = 1, annexe = "II",
                                     date_reference = "2026-01-01", B = 999, seed = 20260831)
num <- function(x, d = 3) ifelse(is.na(x), "—", gsub(".", ",", formatC(x, format = "f", digits = d), fixed = TRUE))
sig <- function(x, d = 10) gsub(".", ",", format(x, digits = d), fixed = TRUE)
nat <- function(x) ifelse(is.na(x), "—", x)
for (nm in names(jeux)) {
  ra <- appel(mav, jeux[[nm]]); rb <- appel(map, jeux[[nm]])
  e <- environment(map$run_engine); aj <- rb$ajustement; ex <- e$mw_extrapolation_sigma2(aj)
  cat(sprintf("\n### Cas %s\n\n", nm))
  cat("| Grandeur | Avant | Après |\n| --- | --- | --- |\n")
  cat(sprintf("| ok | %s | %s |\n", ra$ok, rb$ok))
  cat(sprintf("| σ_USP | %s | %s |\n", sig(ra$parametre$sigma_usp), sig(rb$parametre$sigma_usp)))
  cat(sprintf("| σ_USP, `parametre` et `parametre_final` identical() | %s | |\n",
              identical(ra$parametre, rb$parametre) && identical(ra$parametre_final, rb$parametre_final)))
  cat(sprintf("| MSEP | %s | %s |\n", sig(ra$msep$msep), sig(rb$msep$msep)))
  cat(sprintf("| `ajustement`, `msep`, `residus` identical() | %s | |\n",
              identical(ra$ajustement, rb$ajustement) && identical(ra$msep, rb$msep) && identical(ra$residus, rb$residus)))
  cat(sprintf("| σ²_{J−1} règle ; direct (degrés de liberté) | %s ; %s (%d) | idem |\n",
              sig(aj$sigma2[aj$J]), sig(aj$sigma2_Jm1_direct, 6), aj$I - aj$J))
  cat(sprintf("| Colonne dégénérée qui annule la règle | %s | idem |\n",
              if (isTRUE(ex$degeneree_Jm3)) "J−3 (j = 2)" else if (isTRUE(ex$degeneree_Jm2)) "J−2 (j = 3)" else "aucune"))
  cat(sprintf("| `.mw_simulation_sigma_direct()` | (absente) | %s |\n", e$.mw_simulation_sigma_direct(aj)))
  cat(sprintf("| `bootstrap$stats_obs` identical() | %s | |\n", identical(ra$bootstrap$stats_obs, rb$bootstrap$stats_obs)))
  cat(sprintf("| B effectif d'Origine (autres clés : 999) | %s | %s |\n",
              ra$bootstrap$B_effectif[["Origine"]], rb$bootstrap$B_effectif[["Origine"]]))
  cat(sprintf("| Clés à B effectif = 999 | %d / 13 | %d / 13 |\n",
              sum(unlist(ra$bootstrap$B_effectif) == 999), sum(unlist(rb$bootstrap$B_effectif) == 999)))
  q <- function(r) paste(sig(unname(r$ic_bootstrap), 6), collapse = " ; ")
  cat(sprintf("| `ic_bootstrap` (2,5 ; 5 ; 50 ; 95 ; 97,5 %%) | %s | %s |\n", q(ra), q(rb)))
  cat(sprintf("| `plots_data$usage_sigma[\"sigma\"]` | %s | %s |\n", ra$plots_data$usage_sigma[["sigma"]], rb$plots_data$usage_sigma[["sigma"]]))
  cat(sprintf("| `plots_data$usage_sigma[\"sigma_residus\"]` | %s | %s |\n", ra$plots_data$usage_sigma[["sigma_residus"]], rb$plots_data$usage_sigma[["sigma_residus"]]))
  ta <- map$engine_table_tests(ra); tb <- map$engine_table_tests(rb)
  stopifnot(identical(ta$test, tb$test))
  cat("\n| # | Famille | Test | p_mc avant | p_mc après | nature avant | nature après | p retenue avant | p retenue après | verdict avant | verdict après | ligne |\n")
  cat("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n")
  for (i in seq_len(nrow(ta))) {
    same <- identical(ta[i, ], tb[i, ])
    if (same && is.na(ta$p_monte_carlo[i])) next
    vch <- !identical(ta$verdict[i], tb$verdict[i])
    cat(sprintf("| %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s%s | %s |\n", i, substr(ta$famille[i], 1, 2), ta$test[i],
                num(ta$p_monte_carlo[i]), num(tb$p_monte_carlo[i]), nat(ta$nature_p[i]), nat(tb$nature_p[i]),
                num(ta$p_retenue[i]), num(tb$p_retenue[i]), ta$verdict[i], if (vch) paste0("**", tb$verdict[i], "**") else tb$verdict[i], "",
                if (vch) "**verdict change**" else if (same) "identique" else "modifiée"))
  }
  cat(sprintf("\nLignes : %d ; identiques : %d ; modifiées : %d ; verdicts changés : %d.\n", nrow(ta),
              sum(vapply(seq_len(nrow(ta)), function(i) identical(ta[i, ], tb[i, ]), logical(1))),
              sum(!vapply(seq_len(nrow(ta)), function(i) identical(ta[i, ], tb[i, ]), logical(1))),
              sum(ta$verdict != tb$verdict)))
}
```
