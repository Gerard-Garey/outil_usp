###############################################################################
#  tests/unitaires/test_incertitude_bootstrap.R  --  DISTRIBUTION BOOTSTRAP
#  DE SIGMA_USP ET INTERVALLE "BASIC" SUR L'ECHELLE LOGARITHMIQUE (issue
#  #305 ; specification docs/specifications/fn-incertitude-bootstrap.md,
#  par. 3, 4, 7.2 et 8 ; decisions du mainteneur du 27/10/2026, D1-Fn et
#  D2-Fn, docs/specifications/fn-d2-lecture-couverture.md : Q-D2-Fn-1 a
#  Q-D2-Fn-7, toutes (A))
#
#  Champs plots_data$sigma_usp_boot, $regime_boot, $boot_reperes de
#  engine_plots_data() et mw_plots_data() ; res$ic_bootstrap_basic_log
#  (usp_ic_basic_log()) ; detail et reference des deux lignes de l'IC
#  bootstrap de usp_tests() ; plot_boot_sigma() (base R et plotly),
#  textes_ic_bootstrap() et section 4 du rapport fige (R/display_helpers.R).
#  References independantes :
#    - sigma_USP simules recalcules depuis bootstrap$sigma_boot et
#      parametre_final par l'expression de l'annexe XVII ;
#    - quantiles de type 7 recalcules par interpolation en clair (q7) ;
#    - regime de delta* recalcule par comparaison directe a TOL_DELTA_BORD ;
#    - oracles de l'intervalle "basic" (specification par. 4, au millieme)
#      et ecriture independante a sigma_hat^2 / q.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_incertitude_bootstrap.R")

PROBS <- c(.025, .05, .5, .95, .975)
NOM_IC <- "Largeur relative de l'IC bootstrap 90%"
NOM_IC_R <- "Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime)"
# Textes de Q-D2-Fn-4 (A), Q-D2-Fn-4 bis, Q-D2-Fn-5 (A) et Q-D2-Fn-5 bis, a la lettre.
DETAIL_IC <- paste0("Intervalle bootstrap de percentile du parametre retenu, niveau nominal 90 % : ",
                    "res$ic_bootstrap. A T = 8, couverture inferieure au niveau nominal sous les ",
                    "modeles simules (constat de simulation, voir la documentation). Intervalle ",
                    "basic sur l'echelle logarithmique en regard : res$ic_bootstrap_basic_log.")
REF_IC <- "Efron (1979), Ann. Statist. 7 ; Davison et Hinkley (1997), sections 5.2 et 5.3"
DETAIL_IC_R <- paste0("Bootstrap parametrique a delta fixe a sa valeur estimee (seul gamma ",
                      "reajuste), memes replications que l'IC complet ; une replication dont le ",
                      "reajustement contraint echoue est ecartee du seul bootstrap restreint ",
                      "(res$bootstrap$n_echec_restreint). Incertitude conditionnelle a la ",
                      "structure de variance retenue. Couverture inferieure au niveau nominal a ",
                      "T = 8 sous les modeles simules, comme l'intervalle complet (voir la ",
                      "documentation). Andrews (2000) montre que le bootstrap n'est pas convergent ",
                      "quand le parametre est au bord, dans un modele de moyenne contrainte ; sa ",
                      "transposition a l'estimateur de delta n'est pas demontree, et l'effet sur ",
                      "sigma n'est pas etabli. Bornes : res$ic_bootstrap_restreint.")
# Quantile de type 7 en clair : h = 1 + (n - 1) p, interpolation entre les
# statistiques d'ordre floor(h) et floor(h) + 1.
q7 <- function(v, p) {
  v <- sort(v); n <- length(v); h <- 1 + (n - 1) * p; lo <- floor(h)
  if (lo >= n) return(v[n])
  v[lo] + (h - lo) * (v[lo + 1] - v[lo])
}

# --- Six cas de reference, recalcules (CAS de tests/outils_tests.R) ----------
outils305 <- new.env(parent = globalenv())
sys.source(file.path(if (exists("RACINE", inherits = TRUE)) RACINE else ".", "tests", "outils_tests.R"),
           envir = outils305)
CAS_LN <- c("premium", "reserve1", "premium_ii6", "premium_net", "premium_interieur")
CAS6 <- c(CAS_LN, "reserve2")
set.seed(305); graine0 <- .Random.seed
R6 <- lapply(stats::setNames(CAS6, CAS6), outils305$executer_cas)
verifier("Six cas : run_engine() laisse .Random.seed de l'appelant intact (aucune source d'alea nouvelle)",
         identical(graine0, .Random.seed))

verifier("Six cas : quantile(plots_data$sigma_usp_boot, c(.025, .05, .5, .95, .975)) identical() a res$ic_bootstrap",
         all(vapply(R6, function(r)
           identical(unname(stats::quantile(r$plots_data$sigma_usp_boot, PROBS)),
                     unname(r$ic_bootstrap)), logical(1))))
verifier("Six cas : sigma_usp_boot = c sigma* corr + (1 - c) sigma_std (lognormal), c sigma* + (1 - c) sigma_std (Merz-Wuthrich), recalcule depuis bootstrap$sigma_boot et parametre_final ; longueur 999",
         all(vapply(names(R6), function(nm) {
           r <- R6[[nm]]; p <- r$parametre_final; sb <- r$bootstrap$sigma_boot
           att <- if (nm == "reserve2") p$credibilite * sb + (1 - p$credibilite) * p$sigma_standard
                  else p$credibilite * sb * p$correction_taille + (1 - p$credibilite) * p$sigma_standard
           identical(r$plots_data$sigma_usp_boot, att) && length(att) == 999L
         }, logical(1))))
verifier("Six cas : plots_data$sigma_boot (sigma* brut) conserve tel quel",
         all(vapply(R6, function(r) identical(r$plots_data$sigma_boot, r$bootstrap$sigma_boot), logical(1))))
verifier("Champs ajoutes en fin : lognormal ... spread_enveloppe, sigma_usp_boot, regime_boot, boot_reperes ; Merz-Wuthrich ... qqline, sigma_usp_boot, boot_reperes (sans regime_boot)",
         all(vapply(R6[CAS_LN], function(r)
           identical(utils::tail(names(r$plots_data), 4),
                     c("spread_enveloppe", "sigma_usp_boot", "regime_boot", "boot_reperes")) &&
             is.null(r$plots_data$regime_boot_motif), logical(1))) &&
           identical(utils::tail(names(R6$reserve2$plots_data), 3),
                     c("qqline", "sigma_usp_boot", "boot_reperes")) &&
           !("regime_boot" %in% names(R6$reserve2$plots_data)))

# --- boot_reperes ------------------------------------------------------------
NOMS_REP <- c("echelle", "niveau", "sigma_usp", "ic_bas", "ic_haut", "moyenne", "sigma_standard")
verifier("Six cas : boot_reperes$sigma_usp identical() a parametre_final$sigma_usp ; ic_bas, ic_haut = ic[2], ic[4] ; moyenne = mean(sigma_usp_boot) ; sigma_standard ; echelle 'sigma_USP', niveau IC_BOOT_NIVEAU_REPERES (0,90)",
         identical(IC_BOOT_NIVEAU_REPERES, 0.90) &&
         all(vapply(names(R6), function(nm) {
           r <- R6[[nm]]; b <- r$plots_data$boot_reperes; ic <- r$ic_bootstrap
           noms <- if (nm == "reserve2") NOMS_REP else c(NOMS_REP, "basic_log_bas", "basic_log_haut")
           identical(names(b), noms) && identical(b$echelle, "sigma_USP") &&
             identical(b$niveau, IC_BOOT_NIVEAU_REPERES) &&
             identical(b$sigma_usp, r$parametre_final$sigma_usp) &&
             identical(b$ic_bas, unname(ic[2])) && identical(b$ic_haut, unname(ic[4])) &&
             identical(b$moyenne, mean(r$plots_data$sigma_usp_boot)) &&
             identical(b$sigma_standard, r$parametre_final$sigma_standard)
         }, logical(1))))
verifier("Cinq cas lognormaux : boot_reperes$basic_log_bas et basic_log_haut identical() aux bornes 90 % de res$ic_bootstrap_basic_log",
         all(vapply(R6[CAS_LN], function(r) {
           b <- r$plots_data$boot_reperes; bl <- r$ic_bootstrap_basic_log
           identical(b$basic_log_bas, unname(bl[["bas_90"]])) &&
             identical(b$basic_log_haut, unname(bl[["haut_90"]]))
         }, logical(1))))
verifier(".engine_boot_reperes() sans intervalle (ic NULL) : ic_bas, ic_haut, basic_log_* NA ; vecteur vide : moyenne NA",
         {
           b <- .engine_boot_reperes(numeric(0), NULL, 0.1, 0.1, NULL, lognormal = TRUE)
           is.na(b$ic_bas) && is.na(b$ic_haut) && is.na(b$moyenne) &&
             is.na(b$basic_log_bas) && is.na(b$basic_log_haut) && identical(b$sigma_usp, 0.1)
         })

# --- regime_boot -------------------------------------------------------------
# Effectifs du par. 7.2 de la specification ; regime recalcule par
# comparaison directe a TOL_DELTA_BORD.
EFF <- list(premium = c(463, 46, 490), premium_interieur = c(419, 203, 377))
regime_direct <- function(d) ifelse(d <= TOL_DELTA_BORD, "bord0",
                                    ifelse(d >= 1 - TOL_DELTA_BORD, "bord1", "interieur"))
verifier("Cinq cas lognormaux : regime_boot de la longueur de sigma_usp_boot, valeurs bord0 / interieur / bord1, egal au regime recalcule depuis bootstrap$delta_boot",
         all(vapply(R6[CAS_LN], function(r) {
           g <- r$plots_data$regime_boot
           is.character(g) && length(g) == length(r$plots_data$sigma_usp_boot) &&
             all(g %in% c("bord0", "interieur", "bord1")) &&
             identical(g, regime_direct(r$bootstrap$delta_boot))
         }, logical(1))))
verifier(sprintf("Effectifs de regime_boot (bord0, interieur, bord1) : premium et ses trois variantes %s ; premium_interieur %s (par. 7.2)",
                 paste(EFF$premium, collapse = "/"), paste(EFF$premium_interieur, collapse = "/")),
         all(vapply(CAS_LN, function(nm) {
           att <- if (nm == "premium_interieur") EFF$premium_interieur else EFF$premium
           identical(as.numeric(table(factor(R6[[nm]]$plots_data$regime_boot,
                                             c("bord0", "interieur", "bord1")))), att)
         }, logical(1))))

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
f1 <- usp_ajuster(x, y); prof1 <- usp_profil(f1)
verifier("Volumes constants : regime_boot NULL (champ present), regime_boot_motif 'volumes constants : regime de delta non identifie' ; sigma_usp_boot et boot_reperes presents (run_engine(), B = 99)",
         {
           rc <- run_engine(xt = rep(100, 8), yt = y, methode = "premium", segment = 1, annexe = "II",
                            B = 99, nature_donnees = "brutes")
           pd <- rc$plots_data
           isTRUE(rc$ok) && "regime_boot" %in% names(pd) && is.null(pd$regime_boot) &&
             identical(pd$regime_boot_motif, "volumes constants : regime de delta non identifie") &&
             identical(utils::tail(names(pd), 4),
                       c("sigma_usp_boot", "regime_boot", "regime_boot_motif", "boot_reperes")) &&
             identical(unname(stats::quantile(pd$sigma_usp_boot, PROBS)), unname(rc$ic_bootstrap))
         })
verifier("refit = FALSE (appel direct, delta_boot vide) : regime_boot NULL, motif 'refit = FALSE : delta** non reestime'",
         {
           b <- usp_bootstrap(f1, B = 30, refit = FALSE)
           pd <- engine_plots_data(f1, b, prof1)
           length(b$delta_boot) == 0L && length(b$sigma_boot) == 30L &&
             is.null(pd$regime_boot) && identical(pd$regime_boot_motif, "refit = FALSE : delta** non reestime")
         })
verifier("Longueurs de sigma_boot et delta_boot differentes : regime_boot NULL, motif ; appel direct sans sigma_usp_boot : ni sigma_usp_boot ni boot_reperes, regime_boot aligne sur sigma_boot",
         {
           b <- usp_bootstrap(f1, B = 30)
           pd <- engine_plots_data(f1, b, prof1)
           b2 <- b; b2$delta_boot <- b2$delta_boot[-1]
           pd2 <- engine_plots_data(f1, b2, prof1)
           is.null(pd$sigma_usp_boot) && is.null(pd$boot_reperes) &&
             identical(pd$regime_boot, regime_direct(b$delta_boot)) &&
             is.null(pd2$regime_boot) &&
             identical(pd2$regime_boot_motif,
                       "sigma_boot et delta_boot de longueurs differentes : regime non aligne")
         })

# --- Intervalle "basic" sur l'echelle logarithmique ---------------------------
# Oracles 90 % de la specification (par. 4, Q-D2-Fn-2), au millieme et plus.
ORACLES <- list(premium = c(0.09272, 0.18605), premium_interieur = c(0.07638, 0.13652))
verifier(sprintf("res$ic_bootstrap_basic_log, oracles 90 %% : premium [%s], premium_interieur [%s] (ecart < 1e-5)",
                 paste(ORACLES$premium, collapse = " ; "), paste(ORACLES$premium_interieur, collapse = " ; ")),
         all(vapply(names(ORACLES), function(nm) {
           bl <- R6[[nm]]$ic_bootstrap_basic_log
           all(abs(unname(bl[c("bas_90", "haut_90")]) - ORACLES[[nm]]) < 1e-5)
         }, logical(1))))
verifier("Cinq cas lognormaux : ic_bootstrap_basic_log = c(bas_95, bas_90, haut_90, haut_95), dernier element de l'objet ; = c corr sigma_hat^2 / q + (1 - c) sigma_std, q quantiles de type 7 en clair de sigma* (1e-12 relatif) ; bornes ordonnees",
         all(vapply(R6[CAS_LN], function(r) {
           bl <- r$ic_bootstrap_basic_log; p <- r$parametre_final; sb <- r$bootstrap$sigma_boot
           q <- vapply(c(.975, .95, .05, .025), function(pr) q7(sb, pr), numeric(1))
           att <- p$credibilite * p$correction_taille * p$sigma_estime_brut^2 / q +
             (1 - p$credibilite) * p$sigma_standard
           identical(utils::tail(names(r), 1), "ic_bootstrap_basic_log") &&
             identical(names(bl), c("bas_95", "bas_90", "haut_90", "haut_95")) &&
             isTRUE(proche(unname(bl), att, rel = 1e-12)) && !is.unsorted(bl)
         }, logical(1))))
verifier("Merz-Wuthrich : pas de res$ic_bootstrap_basic_log (lognormal seulement, #387)",
         !("ic_bootstrap_basic_log" %in% names(R6$reserve2)))

# --- Lignes de diagnostic de l'IC (usp_tests()) ------------------------------
verifier("Cinq cas lognormaux : ligne 'Largeur relative de l'IC bootstrap 90%', detail et reference a la lettre (Q-D2-Fn-4 (A)) ; nom inchange",
         all(vapply(R6[CAS_LN], function(r) {
           tb <- engine_table_tests(r); i <- which(tb$test == NOM_IC)
           length(i) == 1L && identical(tb$commentaire[i], DETAIL_IC) && identical(tb$reference[i], REF_IC)
         }, logical(1))))
verifier("Cinq cas lognormaux : ligne de l'IC restreint, detail a la lettre (Q-D2-Fn-5 (A))",
         all(vapply(R6[CAS_LN], function(r) {
           tb <- engine_table_tests(r); i <- which(tb$test == NOM_IC_R)
           length(i) == 1L && identical(tb$commentaire[i], DETAIL_IC_R)
         }, logical(1))))
verifier("Regle #76 : aucun nombre dans les deux detail hors des libelles fixes (niveau nominal 90 %, T = 8, Andrews 2000)",
         {
           sans <- gsub("90 %|T = 8|2000", "", c(DETAIL_IC, DETAIL_IC_R))
           !any(grepl("[0-9]", sans))
         })
verifier("Estimation de la ligne de l'IC inchangee : (ic[4] - ic[2]) / sigma_USP (Q-D2-Fn-7 (A))",
         all(vapply(R6[CAS_LN], function(r) {
           tb <- engine_table_tests(r)
           identical(tb$estimation[tb$test == NOM_IC],
                     unname((r$ic_bootstrap[4] - r$ic_bootstrap[2]) / r$parametre_final$sigma_usp))
         }, logical(1))))

# --- Chemins existants conformes aux references -------------------------------
# ic_bootstrap, ic_bootstrap_restreint, parametre_final et bootstrap$sigma_boot
# contre tests/reference/<cas>.rds, par comparer_objets() a TOLERANCE (seul
# comparateur aux references, ADR 0006, second amendement).
champs <- c("ic_bootstrap", "parametre_final")
comp <- vapply(CAS6, function(nm) {
  ref <- readRDS(outils305$chemin_reference(nm)); obt <- R6[[nm]]
  ch <- intersect(c(champs, "ic_bootstrap_restreint"), names(ref))
  isTRUE(outils305$comparer_objets(ref[ch], obt[ch])$conforme) &&
    isTRUE(outils305$comparer_objets(ref$bootstrap["sigma_boot"], obt$bootstrap["sigma_boot"])$conforme)
}, logical(1))
verifier("Six cas : ic_bootstrap, ic_bootstrap_restreint, parametre_final et bootstrap$sigma_boot conformes aux references a TOLERANCE",
         all(comp))

# --- Affichage : plot_boot_sigma(), textes_ic_bootstrap(), rapport ------------
.racine305 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
source(file.path(.racine305, "R", "display_helpers.R"), local = TRUE)
# Releve, en base R sur pdf(NULL), des libelles d'axes et du titre
# (title(), appele par plot.default() ; une trace de plot.default() ne
# survit pas a un premier untrace() dans la session, mesure), des libelles de legende, du sous-titre
# (mtext) et des positions des reperes verticaux (abline).
releve_base305 <- function(pd) {
  r <- new.env(); r$axes <- NULL; r$leg <- character(0); r$v <- numeric(0); r$sous <- character(0)
  ns <- asNamespace("graphics")
  suppressMessages({
    trace("title", tracer = bquote(assign("axes", c(xlab = xlab, ylab = ylab, main = main),
                                          envir = .(r))), where = ns, print = FALSE)
    trace("legend", tracer = bquote(assign("leg", c(get("leg", envir = .(r)), legend), envir = .(r))),
          where = ns, print = FALSE)
    trace("abline", tracer = bquote(assign("v", c(get("v", envir = .(r)), v), envir = .(r))),
          where = ns, print = FALSE)
    trace("mtext", tracer = bquote(assign("sous", c(get("sous", envir = .(r)), text), envir = .(r))),
          where = ns, print = FALSE)
  })
  on.exit(suppressMessages(for (f in c("title", "legend", "abline", "mtext")) untrace(f, where = ns)))
  option <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
  on.exit({ grDevices::dev.off(); options(option) }, add = TRUE)
  suppressWarnings(plot_boot_sigma(pd))
  as.list(r)
}
LIB_REG <- c("δ** au bord 0", "δ** intérieur", "δ** au bord 1")
LIB_REP <- c("sigma_USP retenu", "percentile, nominal 90 %", "basic (échelle log), nominal 90 %",
             "moyenne des sigma_USP simulés", "sigma standard")
pdi <- R6$premium_interieur$plots_data
rbi <- releve_base305(pdi)
verifier("plot_boot_sigma(), base R, premium_interieur : axes 'sigma_USP simule' et 'effectif', titre 'Distribution bootstrap de sigma_USP' ; legende : trois regimes puis reperes (niveau du moteur) ; sept reperes verticaux lus dans boot_reperes",
         {
           b <- pdi$boot_reperes
           identical(unname(rbi$axes), c("sigma_USP simulé", "effectif", "Distribution bootstrap de sigma_USP")) &&
             identical(rbi$leg, c(LIB_REG, LIB_REP)) &&
             identical(rbi$v, c(b$sigma_usp, b$ic_bas, b$ic_haut, b$basic_log_bas, b$basic_log_haut,
                                b$moyenne, b$sigma_standard))
         })
verifier("plot_boot_sigma(), base R, niveau forge a 0,95 : legendes 'nominal 95 %', aucun 90 %",
         {
           pd <- pdi; pd$boot_reperes$niveau <- 0.95
           l <- releve_base305(pd)$leg
           any(l == "percentile, nominal 95 %") && any(l == "basic (échelle log), nominal 95 %") &&
             !any(grepl("90", l, fixed = TRUE))
         })
MOTIF_VC <- "volumes constants : regime de delta non identifie"
verifier("plot_boot_sigma(), base R, regime_boot NULL avec motif (#305, App-review C2) : motif restitue tel quel en sous-titre (mtext), un seul histogramme sans legende de regime ; sans motif ou avec regimes tracables, aucun sous-titre",
         {
           pd <- pdi; pd["regime_boot"] <- list(NULL); pd$regime_boot_motif <- MOTIF_VC
           r <- releve_base305(pd)
           identical(r$sous, MOTIF_VC) && !any(r$leg %in% LIB_REG) && identical(r$leg, LIB_REP) &&
             !length(releve_base305(pdi)$sous) &&
             !length(releve_base305(replace(pd, "regime_boot_motif", list(NULL)))$sous)
         })
rb2 <- releve_base305(R6$reserve2$plots_data)
verifier("plot_boot_sigma(), base R, reserve2 : axe 'effectif', sans regime ni basic ; cinq reperes",
         identical(unname(rb2$axes[2]), "effectif") &&
           identical(rb2$leg, LIB_REP[-3]) && length(rb2$v) == 5L)
verifier("plot_boot_sigma(), base R, objet anterieur a #305 (sans sigma_usp_boot) : repli sur sigma_boot, axe 'effectif', sans repere",
         {
           pd <- pdi[setdiff(names(pdi), c("sigma_usp_boot", "regime_boot", "boot_reperes"))]
           r <- releve_base305(pd)
           identical(unname(r$axes), c("sigma simule", "effectif", "Distribution bootstrap de sigma")) &&
             !length(r$v) && !length(r$leg)
         })
if (requireNamespace("plotly", quietly = TRUE)) {
  bp <- plotly::plotly_build(plot_boot_sigma(pdi))$x
  verifier("plot_boot_sigma(), plotly, premium_interieur : trois histogrammes empiles (bingroup commun, barmode stack), sept reperes, axes 'sigma_USP simule' / 'effectif', titre",
           {
             ty <- vapply(bp$data, function(t) t$type, "")
             h <- bp$data[ty == "histogram"]
             identical(sum(ty == "histogram"), 3L) &&
               identical(vapply(h, function(t) t$name, ""), LIB_REG) &&
               all(vapply(h, function(t) identical(as.numeric(t$bingroup), 1), logical(1))) &&
               identical(bp$layout$barmode, "stack") && sum(ty == "scatter") == 7L &&
               identical(bp$layout$xaxis$title, "sigma_USP simulé") &&
               identical(bp$layout$yaxis$title, "effectif") &&
               identical(bp$layout$title$text, "Distribution bootstrap de sigma_USP") &&
               identical(unique(vapply(bp$data[ty == "scatter"], function(t) t$name, "")), LIB_REP)
           })
  verifier("plot_boot_sigma(), plotly, regime_boot NULL avec motif (#305, App-review C2) : motif en sous-titre du titre, comme plot_spread() ; titre inchange sans motif",
           {
             pd <- pdi; pd["regime_boot"] <- list(NULL); pd$regime_boot_motif <- MOTIF_VC
             t1 <- plotly::plotly_build(plot_boot_sigma(pd))$x$layout$title$text
             identical(t1, paste0("Distribution bootstrap de sigma_USP<br><sup>", MOTIF_VC, "</sup>")) &&
               identical(bp$layout$title$text, "Distribution bootstrap de sigma_USP")
           })
} else cat("  note : plotly absent ; branche plotly de plot_boot_sigma() non exercee (attendu en CI, issue #53).\n")

NOTE_LN <- paste("Niveaux nominaux. À T = 8, sous les modèles ajustés à deux jeux de",
                 "référence, l'intervalle de percentile couvre nettement moins que son niveau",
                 "nominal (σ sous-estimé, borne haute dépassée) ; l'intervalle « basic »",
                 "sur l'échelle logarithmique couvre près de son niveau nominal. Constat de",
                 "simulation : voir la documentation, fiche de l'intervalle bootstrap.")
NOTE_MW <- "Couverture à T = 8 non mesurée pour cette méthode."
fb <- function(v) sub(".", ",", sprintf("%.4f", v), fixed = TRUE)
verifier("textes_ic_bootstrap(), lognormal (premium) : ligne de percentile, ligne basic log, note (Q-D2-Fn-3 (A)) ; virgule decimale",
         {
           r <- R6$premium; ic <- r$ic_bootstrap; bl <- r$ic_bootstrap_basic_log
           t <- textes_ic_bootstrap(r)
           identical(t$lignes, c(
             sprintf("Intervalle bootstrap de percentile, niveau nominal 90 %% : [%s ; %s] &nbsp;|&nbsp; 95 %% : [%s ; %s]",
                     fb(ic[2]), fb(ic[4]), fb(ic[1]), fb(ic[5])),
             sprintf("Intervalle bootstrap « basic » sur l'échelle logarithmique, niveau nominal 90 %% : [%s ; %s] &nbsp;|&nbsp; 95 %% : [%s ; %s]",
                     fb(bl[["bas_90"]]), fb(bl[["haut_90"]]), fb(bl[["bas_95"]]), fb(bl[["haut_95"]])))) &&
             identical(t$note, NOTE_LN)
         })
NOTE_LN_ANT <- paste("Niveaux nominaux. À T = 8, sous les modèles ajustés à deux jeux de",
                     "référence, l'intervalle de percentile couvre nettement moins que son niveau",
                     "nominal (σ sous-estimé, borne haute dépassée). Constat de simulation : voir",
                     "la documentation, fiche de l'intervalle bootstrap.")
verifier("textes_ic_bootstrap(), lognormal, objet anterieur a #305 (sans ic_bootstrap_basic_log) : ligne de percentile seule, note du percentile seul",
         {
           r <- R6$premium; r$ic_bootstrap_basic_log <- NULL
           t <- textes_ic_bootstrap(r)
           length(t$lignes) == 1L &&
             startsWith(t$lignes, "Intervalle bootstrap de percentile, niveau nominal 90 % : [") &&
             identical(t$note, NOTE_LN_ANT)
         })
verifier("textes_ic_bootstrap(), Merz-Wuthrich : ligne de percentile seule, note 'Couverture a T = 8 non mesuree pour cette methode.' ; sans intervalle : NULL",
         {
           r <- R6$reserve2; t <- textes_ic_bootstrap(r); r0 <- r; r0["ic_bootstrap"] <- list(NULL)
           length(t$lignes) == 1L &&
             startsWith(t$lignes, "Intervalle bootstrap de percentile, niveau nominal 90 % : [") &&
             identical(t$note, NOTE_MW) && is.null(textes_ic_bootstrap(r0))
         })
verifier("Rapport fige (rapport_html(), PNG), premium et reserve2 : lignes de textes_ic_bootstrap() et note grise en section 4 ; ancien libelle absent",
         {
           ok <- TRUE
           for (nm in c("premium", "reserve2")) {
             f <- tempfile(fileext = ".html")
             invisible(rapport_html(R6[[nm]], NULL, f, interactif = FALSE))
             h <- paste(readLines(f, encoding = "UTF-8", warn = FALSE), collapse = "\n")
             t <- textes_ic_bootstrap(R6[[nm]])
             ok <- ok && all(vapply(t$lignes, grepl, logical(1), x = h, fixed = TRUE)) &&
               grepl(sprintf("<div class='gris' style='margin-top:4px'>%s</div>", .echap_html(t$note)), h, fixed = TRUE) &&
               !grepl("Intervalle bootstrap 90 %", h, fixed = TRUE)
             unlink(f)
           }
           ok
         })

fin_fichier()
