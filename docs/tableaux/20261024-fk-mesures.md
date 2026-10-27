## Mesures de la spécification D1-Fk : p-value de famille, lignes des six cas, coût et taille (Q-D1-Fk-11)

> *Établi par la session principale (IA)* le 25/10/2026, en commit `docs:` préparatoire avant le code de #297, sur décision du mainteneur (Q-D1-Fk-11, 25/10/2026 ; encadré en tête de `docs/specifications/fk-lecture-conjointe.md`). Pièce versionnée que cite la spécification (annexe C, § 0) et dont `docwriter` tirera les chiffres de la fiche de la p-value de famille.

**Origine.** Scripts écrits et exécutés par `actuary-approfondi` pendant la consultation D1-Fk du 24/10/2026 (lecture seule), reproduits à la lettre dans l'annexe C de la spécification ; leurs sorties, restées dans le scratchpad de cette session, n'avaient pas été conservées. **Réexécution** par la session principale le 25/10/2026 (14:04 à 14:07 UTC), sur le même moteur `1efa88b` (`R/engine.R`, md5 `8e7feb47744a191c15b2ff59862d5886`, identique à celui de la consultation), dans un worktree détaché à `1efa88b`, R 4.3.3, `LC_ALL=C.UTF-8`, depuis la racine du worktree, dans l'ordre de l'annexe C ; chaque script s'est terminé avec le code 0. Les md5 des scripts extraits de l'annexe C sont ceux que cite la spécification. Pour rejouer un script : le copier hors du dépôt, définir `D` (dossier de sortie, hors du dépôt) et lancer `LC_ALL=C.UTF-8 Rscript <fichier>` depuis la racine d'un worktree à `1efa88b`, `b_capture.R` en premier.

**Concordance avec la consultation.** Deux sorties sur cinq ont exactement le md5 cité par la spécification (`c_lignes.txt`, `f_compte.txt`). Les trois autres impriment des durées d'exécution (`b_capture.txt` : durée par cas ; `d_proto.txt` : colonne `duree_s` ; `e_cout_exact.txt` : durées de `dw_p_exacte` et `runs_p_exacte`), qui changent d'une exécution à l'autre : leur md5 diffère, et les sorties de la consultation n'étant pas conservées, la session ne peut pas montrer que seules ces durées diffèrent [H]. Les sorties déterministes qui les accompagnent sont cohérentes avec la spécification : les six cas sont conformes à leur référence (écart maximal 0), et les tailles sérialisées de la matrice des réplications (191 542 octets par cas lognormal à δ̂ au bord, 191 371 pour `premium_interieur`, 81 178 pour `reserve2`) sont celles qui fondent l'estimation de +1,04 Mo du § 9. Les p de famille de `reserve2` citées par la spécification et par le commentaire `6395430599` de #297 sont retrouvées à l'identique dans `d_proto.txt` : p globale 0,024 en rang symétrique et 0,010 en rang « parmi les autres » (`p_loo`) ; famille M3, 0,008 et 0,003. La sortie `g_decomptes.txt` de la spécification venait d'une commande `Rscript -e` non conservée : elle n'est pas reproduite ici ; les décomptes qu'elle portait sont repris par `c_lignes.txt`.

**Statut.** Constats mesurés sur les réplications bootstrap des six références, à T = 8 ; aucun théorème. Les p de famille de `d_proto` sont celles d'un prototype hors moteur ; celles du moteur seront produites par `engine_p_famille()` (#297, étape 4).

| Script (md5) | Objet | Sortie de la réexécution (md5) | md5 de la consultation |
|---|---|---|---|
| `b_capture.R` (`457943b75202e6cc90c05cf296ab0c8a`) | rejoue les six cas de référence en capturant, par enveloppe d'`add()` et de `.mc_p_values()`, le `mc_nom` de chaque ligne et la matrice passée à `.mc_p_values()` (§ 0, § 9) | `b_capture.txt` (`50e58233ae381bbe7ef458819ce28f41`) | `a8b5324d188462f0e038f126237fe349` (durées, voir ci-dessus) |
| `c_lignes.R` (`2b76f14b2e5eff5f4b6f90d5c6c30dee`) | table des lignes par cas : type, variante, sens, nature, p, `mc_nom` (§ 1, § 6) | `c_lignes.txt` (`cfdbbf0910f8a349bcc0a7c2d6ba9c0b`) | `cfdbbf0910f8a349bcc0a7c2d6ba9c0b` (identique) |
| `d_proto.R` (`0e08253f715450817d1f4ac45da25086`) | prototype hors moteur de la p de famille, deux constructions (rang symétrique, rang parmi les autres réplications), durées, taille sérialisée (§ 1.5, § 2.1, § 9) | `d_proto.txt` (`fe81d6e643e0822d938f2d351e6fa44e`) | `6bb21555e429a38f3a820fbdff3554ae` (durées, voir ci-dessus) |
| `e_cout_exact.R` (`9032da72230a87689299885dec81b025`) | coût du recalcul des p exactes par réplication (option (ii) de S-Fk-2 (a), § 2.2) | `e_cout_exact.txt` (`f25f51ae0ac5ec69df9f357c7cef25ce`) | `a739686b5497ed3c28c9de5098d675ea` (durées, voir ci-dessus) |
| `f_compte.R` (`d4755bf4b477a4b443ee2c8359276074`) | variante « nombre de lignes à p < α » de la ligne globale (§ 1.5, Q-D1-Fk-3 (C)) | `f_compte.txt` (`b9cb169f40d8502ba5460ff57d8d1389`) | `b9cb169f40d8502ba5460ff57d8d1389` (identique) |

### `b_capture` — rejoue les six cas de référence en capturant, par enveloppe d'`add()` et de `.mc_p_values()`, le `mc_nom` de chaque ligne et la matrice passée à `.mc_p_values()` (§ 0, § 9)

```r
# Capture, hors depot, de mc_nom par ligne et de la matrice des replications
# retenues passee a .mc_p_values(), pour les six cas de reference.
suppressMessages(source("tests/outils_tests.R"))
CAPT <- new.env()
.orig_reg <- engine_registre_tests
engine_registre_tests <- function(boot, catalogue, alpha, nature_mc) {
  reg <- .orig_reg(boot, catalogue, alpha, nature_mc)
  a0 <- reg$add
  reg$add <- function(fam, nom, ref, ..., mc_nom = NA_character_, p_mc_ext = NA_real_) {
    CAPT$lignes[[length(CAPT$lignes) + 1]] <- list(famille = fam, test = nom,
      mc_nom = mc_nom, ext = !is.na(p_mc_ext))
    if (missing(ref)) a0(fam, nom, ..., mc_nom = mc_nom, p_mc_ext = p_mc_ext)
    else a0(fam, nom, ref, ..., mc_nom = mc_nom, p_mc_ext = p_mc_ext)
  }
  reg
}
.orig_mcp <- .mc_p_values
.mc_p_values <- function(sim, obs, catalogue, e = NULL) {
  CAPT$sim <- sim; CAPT$obs <- obs
  .orig_mcp(sim, obs, catalogue, e)
}
out <- list()
for (cas in names(CAS)) {
  CAPT$lignes <- list(); CAPT$sim <- NULL
  t0 <- proc.time()[["elapsed"]]
  res <- executer_cas(cas)
  dt <- proc.time()[["elapsed"]] - t0
  ref <- readRDS(chemin_reference(cas))
  cmp <- comparer_objets(ref, res); cmp_ok <- if (is.data.frame(cmp)) nrow(cmp) == 0 else NA
  cat(sprintf("%s : %.1f s ; comparaison a la reference : %s ; lignes capturees %d, res$tests %d\n",
              cas, dt, if (isTRUE(cmp_ok)) "OK" else paste(capture.output(str(cmp, max.level=1)), collapse=" "),
              length(CAPT$lignes), length(res$tests)))
  out[[cas]] <- list(res = res, lignes = CAPT$lignes, sim = CAPT$sim, obs = CAPT$obs, duree = dt)
}
saveRDS(out, file.path(Sys.getenv("D"), "capture.rds"))
```

Sortie :

```
premium : 21.1 s ; comparaison a la reference : List of 10  $ conforme     : logi TRUE  $ tolerance    : num 1e-06  $ n_feuilles   : int 23715  $ n_differentes: int 0  $ n_ecarts     : int 0  $ ecart_max    : num 0  $ feuille_max  : chr NA  $ mesure_max   : chr NA  $ ecarts       :'data.frame':	0 obs. of  7 variables:  $ structure    : chr(0)  ; lignes capturees 47, res$tests 47
reserve1 : 15.9 s ; comparaison a la reference : List of 10  $ conforme     : logi TRUE  $ tolerance    : num 1e-06  $ n_feuilles   : int 23714  $ n_differentes: int 0  $ n_ecarts     : int 0  $ ecart_max    : num 0  $ feuille_max  : chr NA  $ mesure_max   : chr NA  $ ecarts       :'data.frame':	0 obs. of  7 variables:  $ structure    : chr(0)  ; lignes capturees 47, res$tests 47
reserve2 : 42.5 s ; comparaison a la reference : List of 10  $ conforme     : logi TRUE  $ tolerance    : num 1e-06  $ n_feuilles   : int 4547  $ n_differentes: int 0  $ n_ecarts     : int 0  $ ecart_max    : num 0  $ feuille_max  : chr NA  $ mesure_max   : chr NA  $ ecarts       :'data.frame':	0 obs. of  7 variables:  $ structure    : chr(0)  ; lignes capturees 21, res$tests 21
premium_ii6 : 17.2 s ; comparaison a la reference : List of 10  $ conforme     : logi TRUE  $ tolerance    : num 1e-06  $ n_feuilles   : int 23715  $ n_differentes: int 0  $ n_ecarts     : int 0  $ ecart_max    : num 0  $ feuille_max  : chr NA  $ mesure_max   : chr NA  $ ecarts       :'data.frame':	0 obs. of  7 variables:  $ structure    : chr(0)  ; lignes capturees 47, res$tests 47
premium_net : 18.2 s ; comparaison a la reference : List of 10  $ conforme     : logi TRUE  $ tolerance    : num 1e-06  $ n_feuilles   : int 23715  $ n_differentes: int 0  $ n_ecarts     : int 0  $ ecart_max    : num 0  $ feuille_max  : chr NA  $ mesure_max   : chr NA  $ ecarts       :'data.frame':	0 obs. of  7 variables:  $ structure    : chr(0)  ; lignes capturees 47, res$tests 47
premium_interieur : 31.8 s ; comparaison a la reference : List of 10  $ conforme     : logi TRUE  $ tolerance    : num 1e-06  $ n_feuilles   : int 23715  $ n_differentes: int 0  $ n_ecarts     : int 0  $ ecart_max    : num 0  $ feuille_max  : chr NA  $ mesure_max   : chr NA  $ ecarts       :'data.frame':	0 obs. of  7 variables:  $ structure    : chr(0)  ; lignes capturees 47, res$tests 47
```

### `c_lignes` — table des lignes par cas : type, variante, sens, nature, p, `mc_nom` (§ 1, § 6)

```r
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
pref <- function(f) sub("^([A-G]\\.|M[0-9]).*$", "\\1", f)
for (cas in names(cap)) {
  x <- cap[[cas]]; L <- x$res$tests
  stopifnot(identical(vapply(L, `[[`, "", "test"), vapply(x$lignes, `[[`, "", "test")))
  d <- data.frame(
    pf = pref(vapply(L, `[[`, "", "famille")),
    test = substr(vapply(L, `[[`, "", "test"), 1, 44),
    type = substr(vapply(L, `[[`, "", "type"),1,5),
    var = substr(vapply(L, `[[`, "", "variante"),1,4),
    base = vapply(L, `[[`, "", "base"),
    verd = vapply(L, `[[`, "", "verdict"),
    nat = substr(vapply(L, function(l) as.character(l$nature_p), ""),1,12),
    p_ex = signif(vapply(L, `[[`, 0, "p_exacte"),3),
    p_mc = signif(vapply(L, `[[`, 0, "p_mc"),3),
    e_mc = signif(vapply(L, `[[`, 0, "err_mc"),2),
    p_as = signif(vapply(L, `[[`, 0, "p_asymptotique"),3),
    mc = vapply(x$lignes, function(l) as.character(l$mc_nom), ""),
    ext = vapply(x$lignes, `[[`, TRUE, "ext"),
    sens = substr(vapply(L, function(l) as.character(l$sens), ""),1,6),
    stringsAsFactors = FALSE)
  cat("\n=====", cas, ": lignes", nrow(d), "; matrice", nrow(x$sim), "x", ncol(x$sim),
      "; lignes finies (toutes colonnes) ", sum(stats::complete.cases(x$sim)),
      "; lignes non toutes NA", sum(rowSums(is.finite(x$sim))>0), "\n")
  print(d, row.names = FALSE, width = 250)
}
```

Sortie :

```

===== premium : lignes 47 ; matrice 999 x 31 ; lignes finies (toutes colonnes)  999 ; lignes non toutes NA 999 
 pf                                         test  type  var   base   verd          nat  p_ex  p_mc   e_mc   p_as        mc   ext   sens
 B. Nullite de la constante (proportionnalite st  test prin commun     OK Monte-Carlo     NA 0.964 0.0320 0.9490 Intercept FALSE ne pas
 B.    Equivalence de la constante a zero (TOST) diagn prin commun   INFO         <NA>    NA    NA     NA 0.4650      <NA> FALSE   <NA>
 B. Test de Pitman sur la pente (lien positif pe  test prin commun ALERTE exacte par p 0.111    NA     NA 0.1070      <NA> FALSE rejete
 B.     Test de Fisher (significativite globale) diagn prin commun   INFO         <NA>    NA    NA     NA 0.2130      <NA> FALSE   <NA>
 B.              Coefficient de determination R2 diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 B.                  RESET (forme fonctionnelle)  test prin commun     OK Monte-Carlo     NA 0.996 0.0020 0.9950     RESET FALSE ne pas
 B.             Independance ratio S/P vs volume  test prin commun     OK       exacte 0.882 0.878 0.0310 0.8670  SpearVol FALSE ne pas
 B.               Correlation ratio S/P vs temps diagn prin commun   INFO         <NA> 0.840 0.872 0.0310 0.8230  SpearTps FALSE   <NA>
 B.               Tendance monotone du ratio S/P  test prin commun     OK       exacte 0.720 0.758 0.0310 0.7110        MK FALSE ne pas
 B.             Tendance par signes du ratio S/P diagn prin commun   INFO         <NA> 1.000 1.000 0.0000     NA CoxStuart FALSE   <NA>
 C. Heteroscedasticite vs volume - Breusch-Pagan  test prin commun  ECHEC Monte-Carlo     NA 0.018 0.0042 0.0242        BP FALSE ne pas
 C. Heteroscedasticite vs volume - Breusch-Pagan diagn seco commun   INFO         <NA>    NA 0.090 0.0091 0.1440      BP79 FALSE   <NA>
 C.       Heteroscedasticite (forme quadratique) diagn prin commun   INFO         <NA>    NA 0.067 0.0079 0.0784     White FALSE   <NA>
 C. Egalite des variances petits vs gros volumes diagn prin commun   INFO         <NA>    NA 0.190 0.0190 0.2030        GQ FALSE   <NA>
 C.        Homogeneite des dispersions (mediane) diagn prin commun   INFO         <NA>    NA 0.104 0.0097 0.0913        BF FALSE   <NA>
 C. Egalite des lois petits vs gros volumes (2 e diagn prin commun   INFO         <NA> 0.771 0.765 0.0130     NA   Smirnov FALSE   <NA>
 C.                 Position de delta dans [0,1] diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 D.        Shapiro-Wilk sur residus standardises  test prin commun     OK Monte-Carlo     NA 0.620 0.0150 0.5900        SW FALSE ne pas
 D.                              Shapiro-Francia  test prin commun     OK Monte-Carlo     NA 0.686 0.0150 0.7080        SF FALSE ne pas
 D.                             Anderson-Darling  test prin commun     OK Monte-Carlo     NA 0.566 0.0160 0.5270        AD FALSE ne pas
 D.                             Cramer-von Mises diagn prin commun   INFO         <NA>    NA 0.476 0.0160 0.4800       CvM FALSE   <NA>
 D.             Kolmogorov-Smirnov contre N(0,1) diagn seco commun   INFO         <NA>    NA 0.267 0.0140 0.7700        KS FALSE   <NA>
 D.         Lilliefors (KS a parametres estimes)  test prin commun     OK Monte-Carlo     NA 0.269 0.0140 0.2550    Lillie FALSE ne pas
 D.                                  Jarque-Bera  test prin commun     OK Monte-Carlo     NA 0.674 0.0150 0.7760        JB FALSE ne pas
 D.               Asymetrie (D'Agostino, T >= 8)  test prin commun     OK Monte-Carlo     NA 0.708 0.0300 0.7250      DAgo FALSE ne pas
 D.      Aplatissement (Anscombe-Glynn, T >= 20) non a prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.    Autocorrelation d'ordre 1 (Durbin-Watson)  test prin      z     OK       exacte 0.565 0.558 0.0280     NA        DW FALSE ne pas
 E.                         Ljung-Box (retard 2)  test prin commun     OK Monte-Carlo     NA 0.188 0.0120 0.1830       LB2 FALSE ne pas
 E.       Test des suites (aleatoire des signes)  test prin      z     OK       exacte 0.743 0.762 0.0310 0.4450      Runs FALSE ne pas
 E.            Centrage des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.   Variance unitaire des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.                    Rupture de niveau (sup-F)  test prin      z     OK Monte-Carlo     NA 0.840 0.0120     NA      supF FALSE ne pas
 F.                Stabilite cumulee (OLS-CUSUM)  test prin      z     OK Monte-Carlo     NA 0.817 0.0120 0.9670     CUSUM FALSE ne pas
 F.             Valeur aberrante isolee (Grubbs)  test prin      z     OK Monte-Carlo     NA 0.861 0.0110 1.0000    Grubbs FALSE ne pas
 F. Valeurs aberrantes multiples (ESD generalise diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.          Points influents (distance de Cook) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E. Autocorrelation d'ordre 1 (Durbin-Watson) su diagn prin      r   INFO         <NA>    NA 0.566 0.0290     NA       DWr FALSE   <NA>
 E.             Test des suites sur ratios bruts diagn prin      r   INFO         <NA> 0.743 0.768 0.0310     NA     Runsr FALSE   <NA>
 F.   Rupture de niveau (sup-F) sur ratios bruts diagn prin      r   INFO         <NA>    NA 0.931 0.0080     NA     supFr FALSE   <NA>
 F. Stabilite cumulee (OLS-CUSUM) sur ratios bru diagn prin      r   INFO         <NA>    NA 0.756 0.0140     NA    CUSUMr FALSE   <NA>
 F. Valeur aberrante isolee (Grubbs) sur ratios  diagn prin      r   INFO         <NA>    NA 0.777 0.0130     NA   Grubbsr FALSE   <NA>
 F.                         Leviers (hat values) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Sensibilite au retrait d'une annee (jackknif diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G.       Largeur relative de l'IC bootstrap 90% diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Largeur relative de l'IC bootstrap 90% (delt diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Rapport de vraisemblance : delta = 0 (varian diagn prin commun   INFO         <NA>    NA 0.034 0.0057 0.2290      <NA>  TRUE   <NA>
 G. Rapport de vraisemblance : delta = 1 (varian diagn prin commun   INFO         <NA>    NA 1.000 0.0000 1.0000      <NA>  TRUE   <NA>

===== reserve1 : lignes 47 ; matrice 999 x 31 ; lignes finies (toutes colonnes)  999 ; lignes non toutes NA 999 
 pf                                         test  type  var   base   verd          nat  p_ex  p_mc   e_mc   p_as        mc   ext   sens
 B. Nullite de la constante (proportionnalite st  test prin commun     OK Monte-Carlo     NA 0.964 0.0320 0.9490 Intercept FALSE ne pas
 B.    Equivalence de la constante a zero (TOST) diagn prin commun   INFO         <NA>    NA    NA     NA 0.4650      <NA> FALSE   <NA>
 B. Test de Pitman sur la pente (lien positif pe  test prin commun ALERTE exacte par p 0.111    NA     NA 0.1070      <NA> FALSE rejete
 B.     Test de Fisher (significativite globale) diagn prin commun   INFO         <NA>    NA    NA     NA 0.2130      <NA> FALSE   <NA>
 B.              Coefficient de determination R2 diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 B.                  RESET (forme fonctionnelle)  test prin commun     OK Monte-Carlo     NA 0.996 0.0020 0.9950     RESET FALSE ne pas
 B.             Independance ratio S/P vs volume  test prin commun     OK       exacte 0.882 0.878 0.0310 0.8670  SpearVol FALSE ne pas
 B.               Correlation ratio S/P vs temps diagn prin commun   INFO         <NA> 0.840 0.872 0.0310 0.8230  SpearTps FALSE   <NA>
 B.               Tendance monotone du ratio S/P  test prin commun     OK       exacte 0.720 0.758 0.0310 0.7110        MK FALSE ne pas
 B.             Tendance par signes du ratio S/P diagn prin commun   INFO         <NA> 1.000 1.000 0.0000     NA CoxStuart FALSE   <NA>
 C. Heteroscedasticite vs volume - Breusch-Pagan  test prin commun  ECHEC Monte-Carlo     NA 0.018 0.0042 0.0242        BP FALSE ne pas
 C. Heteroscedasticite vs volume - Breusch-Pagan diagn seco commun   INFO         <NA>    NA 0.090 0.0091 0.1440      BP79 FALSE   <NA>
 C.       Heteroscedasticite (forme quadratique) diagn prin commun   INFO         <NA>    NA 0.067 0.0079 0.0784     White FALSE   <NA>
 C. Egalite des variances petits vs gros volumes diagn prin commun   INFO         <NA>    NA 0.190 0.0190 0.2030        GQ FALSE   <NA>
 C.        Homogeneite des dispersions (mediane) diagn prin commun   INFO         <NA>    NA 0.104 0.0097 0.0913        BF FALSE   <NA>
 C. Egalite des lois petits vs gros volumes (2 e diagn prin commun   INFO         <NA> 0.771 0.765 0.0130     NA   Smirnov FALSE   <NA>
 C.                 Position de delta dans [0,1] diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 D.        Shapiro-Wilk sur residus standardises  test prin commun     OK Monte-Carlo     NA 0.620 0.0150 0.5900        SW FALSE ne pas
 D.                              Shapiro-Francia  test prin commun     OK Monte-Carlo     NA 0.686 0.0150 0.7080        SF FALSE ne pas
 D.                             Anderson-Darling  test prin commun     OK Monte-Carlo     NA 0.566 0.0160 0.5270        AD FALSE ne pas
 D.                             Cramer-von Mises diagn prin commun   INFO         <NA>    NA 0.476 0.0160 0.4800       CvM FALSE   <NA>
 D.             Kolmogorov-Smirnov contre N(0,1) diagn seco commun   INFO         <NA>    NA 0.267 0.0140 0.7700        KS FALSE   <NA>
 D.         Lilliefors (KS a parametres estimes)  test prin commun     OK Monte-Carlo     NA 0.269 0.0140 0.2550    Lillie FALSE ne pas
 D.                                  Jarque-Bera  test prin commun     OK Monte-Carlo     NA 0.674 0.0150 0.7760        JB FALSE ne pas
 D.               Asymetrie (D'Agostino, T >= 8)  test prin commun     OK Monte-Carlo     NA 0.708 0.0300 0.7250      DAgo FALSE ne pas
 D.      Aplatissement (Anscombe-Glynn, T >= 20) non a prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.    Autocorrelation d'ordre 1 (Durbin-Watson)  test prin      z     OK       exacte 0.565 0.558 0.0280     NA        DW FALSE ne pas
 E.                         Ljung-Box (retard 2)  test prin commun     OK Monte-Carlo     NA 0.188 0.0120 0.1830       LB2 FALSE ne pas
 E.       Test des suites (aleatoire des signes)  test prin      z     OK       exacte 0.743 0.762 0.0310 0.4450      Runs FALSE ne pas
 E.            Centrage des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.   Variance unitaire des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.                    Rupture de niveau (sup-F)  test prin      z     OK Monte-Carlo     NA 0.840 0.0120     NA      supF FALSE ne pas
 F.                Stabilite cumulee (OLS-CUSUM)  test prin      z     OK Monte-Carlo     NA 0.817 0.0120 0.9670     CUSUM FALSE ne pas
 F.             Valeur aberrante isolee (Grubbs)  test prin      z     OK Monte-Carlo     NA 0.861 0.0110 1.0000    Grubbs FALSE ne pas
 F. Valeurs aberrantes multiples (ESD generalise diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.          Points influents (distance de Cook) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E. Autocorrelation d'ordre 1 (Durbin-Watson) su diagn prin      r   INFO         <NA>    NA 0.566 0.0290     NA       DWr FALSE   <NA>
 E.             Test des suites sur ratios bruts diagn prin      r   INFO         <NA> 0.743 0.768 0.0310     NA     Runsr FALSE   <NA>
 F.   Rupture de niveau (sup-F) sur ratios bruts diagn prin      r   INFO         <NA>    NA 0.931 0.0080     NA     supFr FALSE   <NA>
 F. Stabilite cumulee (OLS-CUSUM) sur ratios bru diagn prin      r   INFO         <NA>    NA 0.756 0.0140     NA    CUSUMr FALSE   <NA>
 F. Valeur aberrante isolee (Grubbs) sur ratios  diagn prin      r   INFO         <NA>    NA 0.777 0.0130     NA   Grubbsr FALSE   <NA>
 F.                         Leviers (hat values) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Sensibilite au retrait d'une annee (jackknif diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G.       Largeur relative de l'IC bootstrap 90% diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Largeur relative de l'IC bootstrap 90% (delt diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Rapport de vraisemblance : delta = 0 (varian diagn prin commun   INFO         <NA>    NA 0.034 0.0057 0.2290      <NA>  TRUE   <NA>
 G. Rapport de vraisemblance : delta = 1 (varian diagn prin commun   INFO         <NA>    NA 1.000 0.0000 1.0000      <NA>  TRUE   <NA>

===== reserve2 : lignes 21 ; matrice 999 x 13 ; lignes finies (toutes colonnes)  999 ; lignes non toutes NA 999 
 pf                                         test  type  var   base   verd          nat p_ex  p_mc   e_mc   p_as         mc   ext   sens
 M1 Absence de tendance des facteurs avec le cum  test prin commun ALERTE Monte-Carlo    NA 0.090 0.0130 0.0985 PenteIntra FALSE ne pas
 M1 Nullite de l'ordonnee a l'origine, colonne p  test prin commun ALERTE Monte-Carlo    NA 0.085 0.0088 0.0850    Origine FALSE ne pas
 M1 Homogeneite de f_j entre annees de survenanc  test prin commun ALERTE Monte-Carlo    NA 0.080 0.0086 0.1520     HomogF FALSE ne pas
 M1         Absence de courbure de la regression  test prin commun  ECHEC Monte-Carlo    NA 0.030 0.0054 0.0208   Courbure FALSE ne pas
 M1 Stabilite du facteur selon la ponderation (f  test prin commun  ECHEC Monte-Carlo    NA 0.005 0.0022     NA      Alpha FALSE ne pas
 M1 Identifiabilite intra-colonne (dispersion de diagn prin commun   INFO         <NA>   NA    NA     NA     NA       <NA> FALSE   <NA>
 M2       Heteroscedasticite residuelle vs cumul  test prin commun     OK Monte-Carlo    NA 0.285 0.0140 0.2310         BP FALSE ne pas
 M2 Adequation de l'exposant de variance, colonn  test prin commun     OK Monte-Carlo    NA 0.428 0.0160 0.5440     ExpVar FALSE ne pas
 M2        Variance unitaire des residus de Mack diagn prin commun   INFO         <NA>   NA    NA     NA     NA       <NA> FALSE   <NA>
 M3     Effets d'annee calendaire (test de Mack)  test prin commun  ECHEC Monte-Carlo    NA 0.002 0.0014 0.0002 Calendrier FALSE ne pas
 M3 Effets d'annee calendaire par diagonale (rep diagn prin commun   INFO         <NA>   NA    NA     NA     NA       <NA> FALSE   <NA>
 M3 Homogeneite des residus entre annees de surv  test prin commun     OK Monte-Carlo    NA 0.300 0.0140 0.2250 KruskalAcc FALSE ne pas
 M3 Correlation entre annees de developpement ad  test prin commun     OK Monte-Carlo    NA 0.170 0.0180     NA    CorrDev FALSE ne pas
 M3  Autocorrelation des residus (Durbin-Watson)  test prin commun  ECHEC Monte-Carlo    NA 0.032 0.0079     NA         DW FALSE ne pas
 M3      Test des suites sur les residus de Mack diagn seco commun   INFO         <NA>   NA 0.374 0.0250 0.6890       Runs FALSE   <NA>
 M4 Cellule aberrante du triangle (residus stude  test prin commun     OK Monte-Carlo    NA 0.898 0.0096 1.0000      MinP4 FALSE ne pas
 M4 Cellules aberrantes multiples (ESD generalis diagn prin commun   INFO         <NA>   NA    NA     NA     NA       <NA> FALSE   <NA>
 M5         Shapiro-Wilk sur les residus de Mack diagn prin commun   INFO         <NA>   NA    NA     NA 0.0714       <NA> FALSE   <NA>
 M5           Lilliefors sur les residus de Mack diagn seco commun   INFO         <NA>   NA    NA     NA 0.4570       <NA> FALSE   <NA>
 M6 Extrapolation de sigma pour la derniere anne diagn prin commun   INFO         <NA>   NA    NA     NA     NA       <NA> FALSE   <NA>
 M6 Part de la reserve portee par la derniere an diagn prin commun   INFO         <NA>   NA    NA     NA     NA       <NA> FALSE   <NA>

===== premium_ii6 : lignes 47 ; matrice 999 x 31 ; lignes finies (toutes colonnes)  999 ; lignes non toutes NA 999 
 pf                                         test  type  var   base   verd          nat  p_ex  p_mc   e_mc   p_as        mc   ext   sens
 B. Nullite de la constante (proportionnalite st  test prin commun     OK Monte-Carlo     NA 0.964 0.0320 0.9490 Intercept FALSE ne pas
 B.    Equivalence de la constante a zero (TOST) diagn prin commun   INFO         <NA>    NA    NA     NA 0.4650      <NA> FALSE   <NA>
 B. Test de Pitman sur la pente (lien positif pe  test prin commun ALERTE exacte par p 0.111    NA     NA 0.1070      <NA> FALSE rejete
 B.     Test de Fisher (significativite globale) diagn prin commun   INFO         <NA>    NA    NA     NA 0.2130      <NA> FALSE   <NA>
 B.              Coefficient de determination R2 diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 B.                  RESET (forme fonctionnelle)  test prin commun     OK Monte-Carlo     NA 0.996 0.0020 0.9950     RESET FALSE ne pas
 B.             Independance ratio S/P vs volume  test prin commun     OK       exacte 0.882 0.878 0.0310 0.8670  SpearVol FALSE ne pas
 B.               Correlation ratio S/P vs temps diagn prin commun   INFO         <NA> 0.840 0.872 0.0310 0.8230  SpearTps FALSE   <NA>
 B.               Tendance monotone du ratio S/P  test prin commun     OK       exacte 0.720 0.758 0.0310 0.7110        MK FALSE ne pas
 B.             Tendance par signes du ratio S/P diagn prin commun   INFO         <NA> 1.000 1.000 0.0000     NA CoxStuart FALSE   <NA>
 C. Heteroscedasticite vs volume - Breusch-Pagan  test prin commun  ECHEC Monte-Carlo     NA 0.018 0.0042 0.0242        BP FALSE ne pas
 C. Heteroscedasticite vs volume - Breusch-Pagan diagn seco commun   INFO         <NA>    NA 0.090 0.0091 0.1440      BP79 FALSE   <NA>
 C.       Heteroscedasticite (forme quadratique) diagn prin commun   INFO         <NA>    NA 0.067 0.0079 0.0784     White FALSE   <NA>
 C. Egalite des variances petits vs gros volumes diagn prin commun   INFO         <NA>    NA 0.190 0.0190 0.2030        GQ FALSE   <NA>
 C.        Homogeneite des dispersions (mediane) diagn prin commun   INFO         <NA>    NA 0.104 0.0097 0.0913        BF FALSE   <NA>
 C. Egalite des lois petits vs gros volumes (2 e diagn prin commun   INFO         <NA> 0.771 0.765 0.0130     NA   Smirnov FALSE   <NA>
 C.                 Position de delta dans [0,1] diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 D.        Shapiro-Wilk sur residus standardises  test prin commun     OK Monte-Carlo     NA 0.620 0.0150 0.5900        SW FALSE ne pas
 D.                              Shapiro-Francia  test prin commun     OK Monte-Carlo     NA 0.686 0.0150 0.7080        SF FALSE ne pas
 D.                             Anderson-Darling  test prin commun     OK Monte-Carlo     NA 0.566 0.0160 0.5270        AD FALSE ne pas
 D.                             Cramer-von Mises diagn prin commun   INFO         <NA>    NA 0.476 0.0160 0.4800       CvM FALSE   <NA>
 D.             Kolmogorov-Smirnov contre N(0,1) diagn seco commun   INFO         <NA>    NA 0.267 0.0140 0.7700        KS FALSE   <NA>
 D.         Lilliefors (KS a parametres estimes)  test prin commun     OK Monte-Carlo     NA 0.269 0.0140 0.2550    Lillie FALSE ne pas
 D.                                  Jarque-Bera  test prin commun     OK Monte-Carlo     NA 0.674 0.0150 0.7760        JB FALSE ne pas
 D.               Asymetrie (D'Agostino, T >= 8)  test prin commun     OK Monte-Carlo     NA 0.708 0.0300 0.7250      DAgo FALSE ne pas
 D.      Aplatissement (Anscombe-Glynn, T >= 20) non a prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.    Autocorrelation d'ordre 1 (Durbin-Watson)  test prin      z     OK       exacte 0.565 0.558 0.0280     NA        DW FALSE ne pas
 E.                         Ljung-Box (retard 2)  test prin commun     OK Monte-Carlo     NA 0.188 0.0120 0.1830       LB2 FALSE ne pas
 E.       Test des suites (aleatoire des signes)  test prin      z     OK       exacte 0.743 0.762 0.0310 0.4450      Runs FALSE ne pas
 E.            Centrage des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.   Variance unitaire des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.                    Rupture de niveau (sup-F)  test prin      z     OK Monte-Carlo     NA 0.840 0.0120     NA      supF FALSE ne pas
 F.                Stabilite cumulee (OLS-CUSUM)  test prin      z     OK Monte-Carlo     NA 0.817 0.0120 0.9670     CUSUM FALSE ne pas
 F.             Valeur aberrante isolee (Grubbs)  test prin      z     OK Monte-Carlo     NA 0.861 0.0110 1.0000    Grubbs FALSE ne pas
 F. Valeurs aberrantes multiples (ESD generalise diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.          Points influents (distance de Cook) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E. Autocorrelation d'ordre 1 (Durbin-Watson) su diagn prin      r   INFO         <NA>    NA 0.566 0.0290     NA       DWr FALSE   <NA>
 E.             Test des suites sur ratios bruts diagn prin      r   INFO         <NA> 0.743 0.768 0.0310     NA     Runsr FALSE   <NA>
 F.   Rupture de niveau (sup-F) sur ratios bruts diagn prin      r   INFO         <NA>    NA 0.931 0.0080     NA     supFr FALSE   <NA>
 F. Stabilite cumulee (OLS-CUSUM) sur ratios bru diagn prin      r   INFO         <NA>    NA 0.756 0.0140     NA    CUSUMr FALSE   <NA>
 F. Valeur aberrante isolee (Grubbs) sur ratios  diagn prin      r   INFO         <NA>    NA 0.777 0.0130     NA   Grubbsr FALSE   <NA>
 F.                         Leviers (hat values) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Sensibilite au retrait d'une annee (jackknif diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G.       Largeur relative de l'IC bootstrap 90% diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Largeur relative de l'IC bootstrap 90% (delt diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Rapport de vraisemblance : delta = 0 (varian diagn prin commun   INFO         <NA>    NA 0.034 0.0057 0.2290      <NA>  TRUE   <NA>
 G. Rapport de vraisemblance : delta = 1 (varian diagn prin commun   INFO         <NA>    NA 1.000 0.0000 1.0000      <NA>  TRUE   <NA>

===== premium_net : lignes 47 ; matrice 999 x 31 ; lignes finies (toutes colonnes)  999 ; lignes non toutes NA 999 
 pf                                         test  type  var   base   verd          nat  p_ex  p_mc   e_mc   p_as        mc   ext   sens
 B. Nullite de la constante (proportionnalite st  test prin commun     OK Monte-Carlo     NA 0.964 0.0320 0.9490 Intercept FALSE ne pas
 B.    Equivalence de la constante a zero (TOST) diagn prin commun   INFO         <NA>    NA    NA     NA 0.4650      <NA> FALSE   <NA>
 B. Test de Pitman sur la pente (lien positif pe  test prin commun ALERTE exacte par p 0.111    NA     NA 0.1070      <NA> FALSE rejete
 B.     Test de Fisher (significativite globale) diagn prin commun   INFO         <NA>    NA    NA     NA 0.2130      <NA> FALSE   <NA>
 B.              Coefficient de determination R2 diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 B.                  RESET (forme fonctionnelle)  test prin commun     OK Monte-Carlo     NA 0.996 0.0020 0.9950     RESET FALSE ne pas
 B.             Independance ratio S/P vs volume  test prin commun     OK       exacte 0.882 0.878 0.0310 0.8670  SpearVol FALSE ne pas
 B.               Correlation ratio S/P vs temps diagn prin commun   INFO         <NA> 0.840 0.872 0.0310 0.8230  SpearTps FALSE   <NA>
 B.               Tendance monotone du ratio S/P  test prin commun     OK       exacte 0.720 0.758 0.0310 0.7110        MK FALSE ne pas
 B.             Tendance par signes du ratio S/P diagn prin commun   INFO         <NA> 1.000 1.000 0.0000     NA CoxStuart FALSE   <NA>
 C. Heteroscedasticite vs volume - Breusch-Pagan  test prin commun  ECHEC Monte-Carlo     NA 0.018 0.0042 0.0242        BP FALSE ne pas
 C. Heteroscedasticite vs volume - Breusch-Pagan diagn seco commun   INFO         <NA>    NA 0.090 0.0091 0.1440      BP79 FALSE   <NA>
 C.       Heteroscedasticite (forme quadratique) diagn prin commun   INFO         <NA>    NA 0.067 0.0079 0.0784     White FALSE   <NA>
 C. Egalite des variances petits vs gros volumes diagn prin commun   INFO         <NA>    NA 0.190 0.0190 0.2030        GQ FALSE   <NA>
 C.        Homogeneite des dispersions (mediane) diagn prin commun   INFO         <NA>    NA 0.104 0.0097 0.0913        BF FALSE   <NA>
 C. Egalite des lois petits vs gros volumes (2 e diagn prin commun   INFO         <NA> 0.771 0.765 0.0130     NA   Smirnov FALSE   <NA>
 C.                 Position de delta dans [0,1] diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 D.        Shapiro-Wilk sur residus standardises  test prin commun     OK Monte-Carlo     NA 0.620 0.0150 0.5900        SW FALSE ne pas
 D.                              Shapiro-Francia  test prin commun     OK Monte-Carlo     NA 0.686 0.0150 0.7080        SF FALSE ne pas
 D.                             Anderson-Darling  test prin commun     OK Monte-Carlo     NA 0.566 0.0160 0.5270        AD FALSE ne pas
 D.                             Cramer-von Mises diagn prin commun   INFO         <NA>    NA 0.476 0.0160 0.4800       CvM FALSE   <NA>
 D.             Kolmogorov-Smirnov contre N(0,1) diagn seco commun   INFO         <NA>    NA 0.267 0.0140 0.7700        KS FALSE   <NA>
 D.         Lilliefors (KS a parametres estimes)  test prin commun     OK Monte-Carlo     NA 0.269 0.0140 0.2550    Lillie FALSE ne pas
 D.                                  Jarque-Bera  test prin commun     OK Monte-Carlo     NA 0.674 0.0150 0.7760        JB FALSE ne pas
 D.               Asymetrie (D'Agostino, T >= 8)  test prin commun     OK Monte-Carlo     NA 0.708 0.0300 0.7250      DAgo FALSE ne pas
 D.      Aplatissement (Anscombe-Glynn, T >= 20) non a prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.    Autocorrelation d'ordre 1 (Durbin-Watson)  test prin      z     OK       exacte 0.565 0.558 0.0280     NA        DW FALSE ne pas
 E.                         Ljung-Box (retard 2)  test prin commun     OK Monte-Carlo     NA 0.188 0.0120 0.1830       LB2 FALSE ne pas
 E.       Test des suites (aleatoire des signes)  test prin      z     OK       exacte 0.743 0.762 0.0310 0.4450      Runs FALSE ne pas
 E.            Centrage des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E.   Variance unitaire des residus standardises diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.                    Rupture de niveau (sup-F)  test prin      z     OK Monte-Carlo     NA 0.840 0.0120     NA      supF FALSE ne pas
 F.                Stabilite cumulee (OLS-CUSUM)  test prin      z     OK Monte-Carlo     NA 0.817 0.0120 0.9670     CUSUM FALSE ne pas
 F.             Valeur aberrante isolee (Grubbs)  test prin      z     OK Monte-Carlo     NA 0.861 0.0110 1.0000    Grubbs FALSE ne pas
 F. Valeurs aberrantes multiples (ESD generalise diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 F.          Points influents (distance de Cook) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 E. Autocorrelation d'ordre 1 (Durbin-Watson) su diagn prin      r   INFO         <NA>    NA 0.566 0.0290     NA       DWr FALSE   <NA>
 E.             Test des suites sur ratios bruts diagn prin      r   INFO         <NA> 0.743 0.768 0.0310     NA     Runsr FALSE   <NA>
 F.   Rupture de niveau (sup-F) sur ratios bruts diagn prin      r   INFO         <NA>    NA 0.931 0.0080     NA     supFr FALSE   <NA>
 F. Stabilite cumulee (OLS-CUSUM) sur ratios bru diagn prin      r   INFO         <NA>    NA 0.756 0.0140     NA    CUSUMr FALSE   <NA>
 F. Valeur aberrante isolee (Grubbs) sur ratios  diagn prin      r   INFO         <NA>    NA 0.777 0.0130     NA   Grubbsr FALSE   <NA>
 F.                         Leviers (hat values) diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Sensibilite au retrait d'une annee (jackknif diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G.       Largeur relative de l'IC bootstrap 90% diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Largeur relative de l'IC bootstrap 90% (delt diagn prin commun   INFO         <NA>    NA    NA     NA     NA      <NA> FALSE   <NA>
 G. Rapport de vraisemblance : delta = 0 (varian diagn prin commun   INFO         <NA>    NA 0.034 0.0057 0.2290      <NA>  TRUE   <NA>
 G. Rapport de vraisemblance : delta = 1 (varian diagn prin commun   INFO         <NA>    NA 1.000 0.0000 1.0000      <NA>  TRUE   <NA>

===== premium_interieur : lignes 47 ; matrice 999 x 31 ; lignes finies (toutes colonnes)  999 ; lignes non toutes NA 999 
 pf                                         test  type  var   base   verd          nat     p_ex  p_mc   e_mc     p_as        mc   ext   sens
 B. Nullite de la constante (proportionnalite st  test prin commun     OK Monte-Carlo        NA 0.670 0.0300 7.21e-01 Intercept FALSE ne pas
 B.    Equivalence de la constante a zero (TOST)  test prin commun ALERTE sous le mode       NA    NA     NA 1.31e-01      <NA> FALSE rejete
 B. Test de Pitman sur la pente (lien positif pe  test prin commun     OK exacte par p 2.48e-05    NA     NA 2.95e-06      <NA> FALSE rejete
 B.     Test de Fisher (significativite globale) diagn prin commun   INFO         <NA>       NA    NA     NA 5.91e-06      <NA> FALSE   <NA>
 B.              Coefficient de determination R2 diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 B.                  RESET (forme fonctionnelle)  test prin commun     OK Monte-Carlo        NA 0.958 0.0063 6.08e-01     RESET FALSE ne pas
 B.             Independance ratio S/P vs volume  test prin commun     OK Monte-Carlo        NA 0.690 0.0300 6.93e-01  SpearVol FALSE ne pas
 B.               Correlation ratio S/P vs temps diagn prin commun   INFO         <NA>       NA 0.866 0.0310 7.36e-01  SpearTps FALSE   <NA>
 B.               Tendance monotone du ratio S/P  test prin commun     OK Monte-Carlo        NA 0.830 0.0310 7.11e-01        MK FALSE ne pas
 B.             Tendance par signes du ratio S/P diagn prin commun   INFO         <NA>       NA 1.000 0.0000       NA CoxStuart FALSE   <NA>
 C. Heteroscedasticite vs volume - Breusch-Pagan  test prin commun     OK Monte-Carlo        NA 0.377 0.0150 7.84e-01        BP FALSE ne pas
 C. Heteroscedasticite vs volume - Breusch-Pagan diagn seco commun   INFO         <NA>       NA 0.271 0.0140 8.14e-01      BP79 FALSE   <NA>
 C.       Heteroscedasticite (forme quadratique) diagn prin commun   INFO         <NA>       NA 0.429 0.0160 5.47e-01     White FALSE   <NA>
 C. Egalite des variances petits vs gros volumes diagn prin commun   INFO         <NA>       NA 0.018 0.0060 4.43e-01        GQ FALSE   <NA>
 C.        Homogeneite des dispersions (mediane) diagn prin commun   INFO         <NA>       NA 0.417 0.0160 6.75e-01        BF FALSE   <NA>
 C. Egalite des lois petits vs gros volumes (2 e diagn prin commun   INFO         <NA>       NA 1.000 0.0000       NA   Smirnov FALSE   <NA>
 C.                 Position de delta dans [0,1] diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 D.        Shapiro-Wilk sur residus standardises  test prin commun     OK Monte-Carlo        NA 0.738 0.0140 7.28e-01        SW FALSE ne pas
 D.                              Shapiro-Francia  test prin commun     OK Monte-Carlo        NA 0.650 0.0150 7.16e-01        SF FALSE ne pas
 D.                             Anderson-Darling  test prin commun     OK Monte-Carlo        NA 0.795 0.0130 6.94e-01        AD FALSE ne pas
 D.                             Cramer-von Mises diagn prin commun   INFO         <NA>       NA 0.823 0.0120 7.46e-01       CvM FALSE   <NA>
 D.             Kolmogorov-Smirnov contre N(0,1) diagn seco commun   INFO         <NA>       NA 0.695 0.0150 9.60e-01        KS FALSE   <NA>
 D.         Lilliefors (KS a parametres estimes)  test prin commun     OK Monte-Carlo        NA 0.606 0.0150 6.36e-01    Lillie FALSE ne pas
 D.                                  Jarque-Bera  test prin commun     OK Monte-Carlo        NA 0.862 0.0110 8.62e-01        JB FALSE ne pas
 D.               Asymetrie (D'Agostino, T >= 8)  test prin commun     OK Monte-Carlo        NA 0.334 0.0240 5.04e-01      DAgo FALSE ne pas
 D.      Aplatissement (Anscombe-Glynn, T >= 20) non a prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 E.    Autocorrelation d'ordre 1 (Durbin-Watson)  test prin      z     OK Monte-Carlo        NA 0.390 0.0250       NA        DW FALSE ne pas
 E.                         Ljung-Box (retard 2)  test prin commun     OK Monte-Carlo        NA 0.220 0.0130 1.95e-01       LB2 FALSE ne pas
 E.       Test des suites (aleatoire des signes)  test prin      z     OK Monte-Carlo        NA 1.000 0.0320 1.00e+00      Runs FALSE ne pas
 E.            Centrage des residus standardises diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 E.   Variance unitaire des residus standardises diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 F.                    Rupture de niveau (sup-F)  test prin      z     OK Monte-Carlo        NA 0.911 0.0090       NA      supF FALSE ne pas
 F.                Stabilite cumulee (OLS-CUSUM)  test prin      z     OK Monte-Carlo        NA 0.954 0.0066 9.96e-01     CUSUM FALSE ne pas
 F.             Valeur aberrante isolee (Grubbs)  test prin      z     OK Monte-Carlo        NA 0.105 0.0097 3.36e-01    Grubbs FALSE ne pas
 F. Valeurs aberrantes multiples (ESD generalise diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 F.          Points influents (distance de Cook) diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 E. Autocorrelation d'ordre 1 (Durbin-Watson) su  test prin      r     OK Monte-Carlo        NA 0.392 0.0250       NA       DWr FALSE ne pas
 E.             Test des suites sur ratios bruts  test prin      r     OK Monte-Carlo        NA 1.000 0.0320       NA     Runsr FALSE ne pas
 F.   Rupture de niveau (sup-F) sur ratios bruts  test prin      r     OK Monte-Carlo        NA 0.821 0.0120       NA     supFr FALSE ne pas
 F. Stabilite cumulee (OLS-CUSUM) sur ratios bru  test prin      r     OK Monte-Carlo        NA 0.924 0.0084       NA    CUSUMr FALSE ne pas
 F. Valeur aberrante isolee (Grubbs) sur ratios   test prin      r     OK Monte-Carlo        NA 0.204 0.0130       NA   Grubbsr FALSE ne pas
 F.                         Leviers (hat values) diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 G. Sensibilite au retrait d'une annee (jackknif diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 G.       Largeur relative de l'IC bootstrap 90% diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 G. Largeur relative de l'IC bootstrap 90% (delt diagn prin commun   INFO         <NA>       NA    NA     NA       NA      <NA> FALSE   <NA>
 G. Rapport de vraisemblance : delta = 0 (varian diagn prin commun   INFO         <NA>       NA 0.289 0.0140 3.42e-01      <NA>  TRUE   <NA>
 G. Rapport de vraisemblance : delta = 1 (varian diagn prin commun   INFO         <NA>       NA 0.411 0.0160 3.54e-01      <NA>  TRUE   <NA>
```

### `d_proto` — prototype hors moteur de la p de famille, deux constructions (rang symétrique, rang parmi les autres réplications), durées, taille sérialisée (§ 1.5, § 2.1, § 9)

```r
# Prototype hors moteur de la p de famille (minP sur les rangs Monte-Carlo),
# sur les matrices capturees par b_capture.R. Aucune ecriture dans le depot.
suppressMessages(source("R/engine.R"))
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
pref <- function(f) sub("^([A-G]\\.|M[0-9]).*$", "\\1", f)
# numerateurs entiers des p de rang de chaque item (lignes de A) dans sa colonne
num_p <- function(v, queue) {
  N <- length(v)
  up <- rank(-v, ties.method = "max"); dn <- rank(v, ties.method = "max")
  switch(queue, haut = up, bas = dn, deux = pmin(2 * pmin(up, dn), N))
}
famille_p <- function(S, obs, cols, queues, variante = c("sym", "loo")) {
  variante <- match.arg(variante)
  X <- S[, cols, drop = FALSE]
  ok <- apply(is.finite(X), 1L, all); X <- X[ok, , drop = FALSE]; n <- nrow(X)
  o <- vapply(cols, function(c) obs[[c]], 0)
  if (variante == "sym") {
    A <- rbind(o, X); N <- n + 1
    P <- vapply(seq_along(cols), function(j) num_p(A[, j], queues[[j]]), numeric(N))
    P <- matrix(P, nrow = N)
    m <- apply(P, 1L, min)
    list(p = (sum(m[-1] <= m[1]) + 1) / (n + 1), m_obs = m[1] / N, B_eff = n,
         p_obs = P[1, ] / N)
  } else {
    # rangs des replications parmi les autres replications seulement (texte de #297)
    Pr <- vapply(seq_along(cols), function(j) {
      v <- X[, j]; up <- rank(-v, ties.method = "max"); dn <- rank(v, ties.method = "max")
      # (1 + #{autres >= v_b}) / n = up / n
      switch(queues[[j]], haut = up, bas = dn, deux = pmin(2 * pmin(up, dn), n)) }, numeric(n))
    Pr <- matrix(Pr, nrow = n)
    po <- vapply(seq_along(cols), function(j) {
      r <- engine_p_mc(X[, j], o[[j]], queues[[j]]); r$p_mc }, 0)
    mb <- apply(Pr, 1L, min) / n
    list(p = (sum(mb <= min(po)) + 1) / (n + 1), m_obs = min(po), B_eff = n, p_obs = po)
  }
}
res_tab <- list()
for (cas in names(cap)) {
  x <- cap[[cas]]; L <- x$res$tests
  cat_mc <- if (x$res$metadata$methode == "reserve2") MW_CATALOGUE_MC else USP_CATALOGUE_MC
  info <- data.frame(pf = pref(vapply(L, `[[`, "", "famille")),
                     type = vapply(L, `[[`, "", "type"),
                     var = vapply(L, `[[`, "", "variante"),
                     sens = vapply(L, function(l) as.character(l$sens), ""),
                     p_mc = vapply(L, `[[`, 0, "p_mc"),
                     mc = vapply(x$lignes, function(l) as.character(l$mc_nom), ""),
                     ext = vapply(x$lignes, `[[`, TRUE, "ext"), stringsAsFactors = FALSE)
  memb <- info$type == "test" & info$var == "principale" & info$sens %in% "ne pas rejeter" &
    !is.na(info$mc) & !info$ext & is.finite(info$p_mc)
  hors <- info$type == "test" & info$var == "principale" & !memb
  fams <- c(sort(unique(info$pf[memb])), "GLOBAL")
  for (f in fams) {
    sel <- memb & (f == "GLOBAL" | info$pf == f)
    cols <- info$mc[sel]; q <- lapply(cols, function(c) cat_mc[[c]]$queue)
    t0 <- proc.time()[["elapsed"]]
    a <- famille_p(x$sim, x$obs, cols, q, "sym")
    dt <- proc.time()[["elapsed"]] - t0
    b <- famille_p(x$sim, x$obs, cols, q, "loo")
    repro <- isTRUE(all(a$p_obs == info$p_mc[sel]))
    res_tab[[length(res_tab) + 1]] <- data.frame(cas = cas, famille = f, k = length(cols),
      exclus_test = if (f == "GLOBAL") sum(hors) else sum(hors & info$pf == f),
      B_eff = a$B_eff, m_obs = signif(a$m_obs, 4), p_fam = round(a$p, 4),
      err = round(sqrt(a$p * (1 - a$p) / a$B_eff), 4), p_loo = round(b$p, 4),
      p_obs_identiques = repro, duree_s = round(dt, 3), stringsAsFactors = FALSE)
  }
}
tab <- do.call(rbind, res_tab)
print(tab, row.names = FALSE)
# Bonferroni pour memoire (k * m_obs, borne a 1)
tab$bonf <- pmin(1, tab$k * tab$m_obs)
cat("\nBonferroni k*m_obs (repere) :\n"); print(tab[, c("cas","famille","k","m_obs","p_fam","bonf")], row.names = FALSE)
saveRDS(tab, file.path(Sys.getenv("D"), "proto_tab.rds"))
# taille de la matrice serialisee
for (cas in names(cap)) {
  f <- tempfile(fileext = ".rds"); saveRDS(cap[[cas]]$sim, f)
  cat(sprintf("%s : matrice %d x %d, rds %d octets\n", cas, nrow(cap[[cas]]$sim), ncol(cap[[cas]]$sim), file.size(f)))
  unlink(f)
}
```

Sortie :

```
               cas famille  k exclus_test B_eff m_obs p_fam    err p_loo
           premium      B.  4           1   999 0.758 0.950 0.0069 0.950
           premium      C.  1           0   999 0.018 0.018 0.0042 0.018
           premium      D.  6           0   999 0.269 0.438 0.0157 0.437
           premium      E.  3           0   999 0.188 0.316 0.0147 0.314
           premium      F.  3           0   999 0.817 0.961 0.0061 0.961
           premium  GLOBAL 17           1   999 0.018 0.131 0.0107 0.123
          reserve1      B.  4           1   999 0.758 0.950 0.0069 0.950
          reserve1      C.  1           0   999 0.018 0.018 0.0042 0.018
          reserve1      D.  6           0   999 0.269 0.438 0.0157 0.437
          reserve1      E.  3           0   999 0.188 0.316 0.0147 0.314
          reserve1      F.  3           0   999 0.817 0.961 0.0061 0.961
          reserve1  GLOBAL 17           1   999 0.018 0.131 0.0107 0.123
          reserve2      M1  5           0   999 0.005 0.023 0.0047 0.020
          reserve2      M2  2           0   999 0.285 0.471 0.0158 0.470
          reserve2      M3  4           0   999 0.002 0.008 0.0028 0.003
          reserve2      M4  1           0   999 0.898 0.898 0.0096 0.898
          reserve2  GLOBAL 12           0   999 0.002 0.024 0.0048 0.010
       premium_ii6      B.  4           1   999 0.758 0.950 0.0069 0.950
       premium_ii6      C.  1           0   999 0.018 0.018 0.0042 0.018
       premium_ii6      D.  6           0   999 0.269 0.438 0.0157 0.437
       premium_ii6      E.  3           0   999 0.188 0.316 0.0147 0.314
       premium_ii6      F.  3           0   999 0.817 0.961 0.0061 0.961
       premium_ii6  GLOBAL 17           1   999 0.018 0.131 0.0107 0.123
       premium_net      B.  4           1   999 0.758 0.950 0.0069 0.950
       premium_net      C.  1           0   999 0.018 0.018 0.0042 0.018
       premium_net      D.  6           0   999 0.269 0.438 0.0157 0.437
       premium_net      E.  3           0   999 0.188 0.316 0.0147 0.314
       premium_net      F.  3           0   999 0.817 0.961 0.0061 0.961
       premium_net  GLOBAL 17           1   999 0.018 0.131 0.0107 0.123
 premium_interieur      B.  4           2   999 0.670 0.955 0.0066 0.955
 premium_interieur      C.  1           0   999 0.377 0.377 0.0153 0.377
 premium_interieur      D.  6           0   999 0.334 0.579 0.0156 0.578
 premium_interieur      E.  5           0   999 0.220 0.423 0.0156 0.423
 premium_interieur      F.  6           0   999 0.105 0.290 0.0144 0.289
 premium_interieur  GLOBAL 22           2   999 0.105 0.650 0.0151 0.648
 p_obs_identiques duree_s
             TRUE   0.091
             TRUE   0.006
             TRUE   0.015
             TRUE   0.009
             TRUE   0.010
             TRUE   0.019
             TRUE   0.009
             TRUE   0.004
             TRUE   0.006
             TRUE   0.010
             TRUE   0.005
             TRUE   0.015
             TRUE   0.009
             TRUE   0.004
             TRUE   0.010
             TRUE   0.003
             TRUE   0.009
             TRUE   0.006
             TRUE   0.004
             TRUE   0.014
             TRUE   0.007
             TRUE   0.007
             TRUE   0.017
             TRUE   0.008
             TRUE   0.006
             TRUE   0.010
             TRUE   0.008
             TRUE   0.008
             TRUE   0.018
             TRUE   0.008
             TRUE   0.006
             TRUE   0.016
             TRUE   0.010
             TRUE   0.009
             TRUE   0.012

Bonferroni k*m_obs (repere) :
               cas famille  k m_obs p_fam  bonf
           premium      B.  4 0.758 0.950 1.000
           premium      C.  1 0.018 0.018 0.018
           premium      D.  6 0.269 0.438 1.000
           premium      E.  3 0.188 0.316 0.564
           premium      F.  3 0.817 0.961 1.000
           premium  GLOBAL 17 0.018 0.131 0.306
          reserve1      B.  4 0.758 0.950 1.000
          reserve1      C.  1 0.018 0.018 0.018
          reserve1      D.  6 0.269 0.438 1.000
          reserve1      E.  3 0.188 0.316 0.564
          reserve1      F.  3 0.817 0.961 1.000
          reserve1  GLOBAL 17 0.018 0.131 0.306
          reserve2      M1  5 0.005 0.023 0.025
          reserve2      M2  2 0.285 0.471 0.570
          reserve2      M3  4 0.002 0.008 0.008
          reserve2      M4  1 0.898 0.898 0.898
          reserve2  GLOBAL 12 0.002 0.024 0.024
       premium_ii6      B.  4 0.758 0.950 1.000
       premium_ii6      C.  1 0.018 0.018 0.018
       premium_ii6      D.  6 0.269 0.438 1.000
       premium_ii6      E.  3 0.188 0.316 0.564
       premium_ii6      F.  3 0.817 0.961 1.000
       premium_ii6  GLOBAL 17 0.018 0.131 0.306
       premium_net      B.  4 0.758 0.950 1.000
       premium_net      C.  1 0.018 0.018 0.018
       premium_net      D.  6 0.269 0.438 1.000
       premium_net      E.  3 0.188 0.316 0.564
       premium_net      F.  3 0.817 0.961 1.000
       premium_net  GLOBAL 17 0.018 0.131 0.306
 premium_interieur      B.  4 0.670 0.955 1.000
 premium_interieur      C.  1 0.377 0.377 0.377
 premium_interieur      D.  6 0.334 0.579 1.000
 premium_interieur      E.  5 0.220 0.423 1.000
 premium_interieur      F.  6 0.105 0.290 0.630
 premium_interieur  GLOBAL 22 0.105 0.650 1.000
premium : matrice 999 x 31, rds 191542 octets
reserve1 : matrice 999 x 31, rds 191542 octets
reserve2 : matrice 999 x 13, rds 81178 octets
premium_ii6 : matrice 999 x 31, rds 191542 octets
premium_net : matrice 999 x 31, rds 191542 octets
premium_interieur : matrice 999 x 31, rds 191371 octets
```

### `e_cout_exact` — coût du recalcul des p exactes par réplication (option (ii) de S-Fk-2 (a), § 2.2)

```r
suppressMessages(source("R/engine.R"))
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
zb <- cap$premium$res$bootstrap$z_boot
ok <- apply(is.finite(zb), 1, all)
cat("lignes finies de z_boot (premium) :", sum(ok), "\n")
t0 <- proc.time()[["elapsed"]]; pdw <- apply(zb[ok, ], 1, dw_p_exacte); t1 <- proc.time()[["elapsed"]]
pru <- apply(zb[ok, ], 1, runs_p_exacte); t2 <- proc.time()[["elapsed"]]
cat(sprintf("dw_p_exacte x %d : %.2f s ; runs_p_exacte : %.2f s\n", sum(ok), t1 - t0, t2 - t1))
cat("DW exacte NA :", sum(!is.finite(pdw)), " ; Runs exacte NA :", sum(!is.finite(pru)), "\n")
# coherence : DW de la replication = colonne DW de la matrice ?
cat("DW(z_boot) identique a la colonne DW de la matrice :",
    isTRUE(all.equal(apply(zb[ok, ], 1, stat_dw), unname(cap$premium$sim[ok, "DW"]), tolerance = 0)), "\n")
cat("premium_interieur, variante :", cap$premium_interieur$res$bootstrap$p_mc_regime$variante,
    "retenus V1 :", cap$premium_interieur$res$bootstrap$p_mc_regime$retenus_v1,
    "retenus :", cap$premium_interieur$res$bootstrap$p_mc_regime$retenus,
    "tirages :", cap$premium_interieur$res$bootstrap$p_mc_regime$tirages, "\n")
```

Sortie :

```
lignes finies de z_boot (premium) : 999 
dw_p_exacte x 999 : 1.06 s ; runs_p_exacte : 0.25 s
DW exacte NA : 0  ; Runs exacte NA : 0 
DW(z_boot) identique a la colonne DW de la matrice : TRUE 
premium_interieur, variante : V3b retenus V1 : 203 retenus : 999 tirages : 4490
```

### `f_compte` — variante « nombre de lignes à p < α » de la ligne globale (§ 1.5, Q-D1-Fk-3 (C))

```r
# Variante "compte" (nombre de lignes membres a p < alpha), construction symetrique.
suppressMessages(source("R/engine.R"))
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
pref <- function(f) sub("^([A-G]\\.|M[0-9]).*$", "\\1", f)
num_p <- function(v, queue) { N <- length(v)
  up <- rank(-v, ties.method = "max"); dn <- rank(v, ties.method = "max")
  switch(queue, haut = up, bas = dn, deux = pmin(2 * pmin(up, dn), N)) }
for (cas in c("premium", "reserve2", "premium_interieur")) {
  x <- cap[[cas]]; L <- x$res$tests
  cat_mc <- if (x$res$metadata$methode == "reserve2") MW_CATALOGUE_MC else USP_CATALOGUE_MC
  ty <- vapply(L, `[[`, "", "type"); va <- vapply(L, `[[`, "", "variante")
  se <- vapply(L, function(l) as.character(l$sens), ""); mc <- vapply(x$lignes, function(l) as.character(l$mc_nom), "")
  ext <- vapply(x$lignes, `[[`, TRUE, "ext"); pm <- vapply(L, `[[`, 0, "p_mc")
  memb <- ty == "test" & va == "principale" & se %in% "ne pas rejeter" & !is.na(mc) & !ext & is.finite(pm)
  cols <- mc[memb]
  X <- x$sim[, cols, drop = FALSE]; ok <- apply(is.finite(X), 1, all); X <- X[ok, , drop = FALSE]
  A <- rbind(vapply(cols, function(c) x$obs[[c]], 0), X); N <- nrow(A)
  P <- sapply(seq_along(cols), function(j) num_p(A[, j], cat_mc[[cols[j]]]$queue)) / N
  for (a in c(0.10, 0.05)) {
    cnt <- rowSums(P < a)
    cat(sprintf("%s alpha %.2f : k = %d, N_obs = %d, P*(N >= N_obs) = %.4f ; E*[N] = %.2f ; P*(N >= 1) = %.3f\n",
                cas, a, length(cols), cnt[1], mean(cnt >= cnt[1]), mean(cnt[-1]), mean(cnt[-1] >= 1)))
  }
}
```

Sortie :

```
premium alpha 0.10 : k = 17, N_obs = 1, P*(N >= N_obs) = 0.5090 ; E*[N] = 1.60 ; P*(N >= 1) = 0.509
premium alpha 0.05 : k = 17, N_obs = 1, P*(N >= N_obs) = 0.2990 ; E*[N] = 0.78 ; P*(N >= 1) = 0.298
reserve2 alpha 0.10 : k = 12, N_obs = 7, P*(N >= N_obs) = 0.0030 ; E*[N] = 1.18 ; P*(N >= 1) = 0.658
reserve2 alpha 0.05 : k = 12, N_obs = 4, P*(N >= N_obs) = 0.0100 ; E*[N] = 0.58 ; P*(N >= 1) = 0.403
premium_interieur alpha 0.10 : k = 22, N_obs = 0, P*(N >= N_obs) = 1.0000 ; E*[N] = 2.05 ; P*(N >= 1) = 0.630
premium_interieur alpha 0.05 : k = 22, N_obs = 0, P*(N >= N_obs) = 1.0000 ; E*[N] = 0.95 ; P*(N >= 1) = 0.372
```
