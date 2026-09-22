###############################################################################
#  R/display_helpers.R  --  COUCHE D'AFFICHAGE
#
#  Ce fichier ne contient AUCUN calcul statistique, actuariel ou de calibration.
#  Il se limite a :
#    - formater des nombres, des libelles et des tableaux ;
#    - tracer des graphiques a partir de quantites DEJA calculees par
#      run_engine() et exposees dans res$plots_data ;
#    - produire des messages et des regroupements de presentation.
#
#  Les graphiques utilisent plotly lorsque le paquet est disponible, et
#  retombent sinon sur les graphiques de base R, SANS changer les donnees
#  tracees. Le moteur graphique est un choix de presentation, pas de methode.
###############################################################################

COUL <- list(trait = "#B03A2E", pt = "#00468C", env = "#C8DCFA",
             ref = "#7F8C8D", vert = "#00B450", fond = "#FFFFFF")

.plotly_dispo <- function() requireNamespace("plotly", quietly = TRUE)

fmt_nb <- function(v, d = 4) ifelse(is.finite(v), formatC(v, format = "f", digits = d), "\u2013")
fmt_p  <- function(v) ifelse(is.finite(v), formatC(v, format = "f", digits = 4), "\u2013")
fmt_pc <- function(v, d = 1) ifelse(is.finite(v),
                                    paste0(formatC(100 * v, format = "f", digits = d), " %"), "\u2013")

# --- Regroupement des tests par grande hypothese -----------------------------
# engine.R prefixe chaque famille par une lettre. On la traduit ici en libelle
# lisible : c'est une pure convention d'affichage, sans effet sur les calculs.
GROUPES <- list(
  "B." = list(cle = "H1", titre = "H1 \u2014 Lin\u00e9arit\u00e9 et proportionnalit\u00e9",
              sous = "E[Y_t] = beta \u00b7 x_t, sans constante, beta stable dans le temps",
              ref  = "annexe XVII, B/C(2)(f)(i)"),
  "C." = list(cle = "H2", titre = "H2 \u2014 Structure de variance quadratique",
              sous = "Var(Y_t) = sigma\u00b2 [(1-delta) \u00b7 xbar \u00b7 x_t + delta \u00b7 x_t\u00b2]",
              ref  = "annexe XVII, B/C(2)(f)(ii)"),
  "D." = list(cle = "H3", titre = "H3 \u2014 Lognormalit\u00e9 des pertes agr\u00e9g\u00e9es",
              sous = "test\u00e9e comme la normalit\u00e9 des r\u00e9sidus normalis\u00e9s z_t",
              ref  = "annexe XVII, B/C(2)(f)(iii)"),
  "E." = list(cle = "H4", titre = "H4 \u2014 Ind\u00e9pendance et validit\u00e9 du maximum de vraisemblance",
              sous = "absence d'autocorr\u00e9lation des Y_t conditionnellement aux x_t",
              ref  = "annexe XVII, B/C(2)(f)(iv)"),
  "F." = list(cle = "STAB", titre = "Stabilit\u00e9, ruptures et points aberrants",
              sous = "hors hypoth\u00e8ses r\u00e9glementaires, mais conditionne leur lecture",
              ref  = "diagnostics compl\u00e9mentaires"),
  "G." = list(cle = "ROB", titre = "Robustesse de l'estimation",
              sous = "diagnostics num\u00e9riques et de sensibilit\u00e9",
              ref  = "diagnostics compl\u00e9mentaires"),
  # --- Familles propres a la methode Merz-Wuthrich (annexe XVII, section D).
  # Meme principe de presentation que H1 a H4 : une famille par hypothese du
  # modele, afin que la lecture des deux methodes soit strictement parallele.
  "M1" = list(cle = "M1", titre = "M1 \u2014 Proportionnalit\u00e9 des cumul\u00e9s",
              sous = "E[C(i,j+1) | C(i,j)] = f_j \u00b7 C(i,j)",
              ref  = "annexe XVII, D(2)(h)(iii)"),
  "M2" = list(cle = "M2", titre = "M2 \u2014 Variance proportionnelle au cumul",
              sous = "Var[C(i,j+1) | C(i,j)] = sigma_j\u00b2 \u00b7 C(i,j)",
              ref  = "annexe XVII, D(2)(h)(iv)"),
  "M3" = list(cle = "M3", titre = "M3 \u2014 Ind\u00e9pendance",
              sous = "ann\u00e9es de survenance et montants incr\u00e9mentaux ind\u00e9pendants",
              ref  = "annexe XVII, D(2)(h)(i) et (ii)"),
  "M4" = list(cle = "M4", titre = "M4 \u2014 Points aberrants et stabilit\u00e9",
              sous = "cellules atypiques du triangle",
              ref  = "diagnostics compl\u00e9mentaires"),
  "M5" = list(cle = "M5", titre = "M5 \u2014 Normalit\u00e9 des r\u00e9sidus",
              sous = "diagnostic seulement : le mod\u00e8le ne sp\u00e9cifie que les deux premiers moments",
              ref  = "hors annexe XVII, D(2)(h)"),
  "M6" = list(cle = "M6", titre = "M6 \u2014 Robustesse de l'estimation",
              sous = "diagnostics num\u00e9riques et de concentration",
              ref  = "diagnostics compl\u00e9mentaires")
)

groupe_de <- function(famille) {
  g <- GROUPES[[substr(famille, 1, 2)]]
  if (is.null(g)) list(cle = "AUTRE", titre = famille, sous = "", ref = "") else g
}
cles_groupes <- function() unname(vapply(GROUPES, function(g) g$cle, character(1)))

# --- Selection des tests restitues (personnalisation de l'affichage) ---------
# La selection est un data.frame aligne ligne a ligne sur engine_table_tests() :
#   cle   = libelle du test (controle d'alignement),
#   garde = TRUE si l'utilisateur conserve le test dans la restitution,
#   base  = base de residus choisie ("z" ou "r"), "commun" pour les tests a
#           base unique.
# Elle ne modifie aucun calcul : le moteur a produit toutes les lignes, la
# selection ne fait que choisir celles qui sont affichees.

# Selection par defaut : variantes principales uniquement, base "z" pour les
# tests disponibles dans les deux bases. C'est le parametrage retenu tant que
# l'utilisateur n'a rien modifie.
selection_defaut <- function(tb) {
  data.frame(
    cle = tb$test,
    garde = tb$variante == "principale" & tb$base %in% c("commun", "z"),
    base = ifelse(tb$base == "commun", "commun", "z"),
    stringsAsFactors = FALSE)
}

# Regle unique definissant un "test retenu" : conserve par l'utilisateur ET
# calcule sur la base de residus choisie pour ce test (ou a base unique).
# Renvoie le vecteur logique des lignes de tb retenues ; sa negation designe
# les tests exclus. Utilisee par l'onglet Tests et par le rapport fige.
filtrer_selection <- function(tb, s) {
  s$garde & (tb$base == "commun" | tb$base == s$base)
}

badge_verdict <- function(v) {
  coul <- switch(v, "OK" = "#1E8449", "ALERTE" = "#B9770E", "ECHEC" = "#922B21", "#5D6D7E")
  sprintf(paste0("<span style='background:%s;color:#fff;padding:2px 9px;",
                 "border-radius:10px;font-size:11px;font-weight:600'>%s</span>"), coul, v)
}

badge_nature <- function(n) {
  if (is.na(n)) return("\u2013")
  if (grepl("^exacte", n))      return("<span style='color:#1E8449;font-weight:600'>exacte</span>")
  if (grepl("^quasi", n))       return("<span style='color:#1E8449;font-weight:600'>quasi-exacte</span>")
  if (grepl("^Monte-Carlo", n)) return("<span style='color:#00468C;font-weight:600'>Monte-Carlo</span>")
  "<span style='color:#B9770E;font-weight:600'>asymptotique</span>"
}

avertissement_T <- function(T) {
  if (T >= 15) return(NULL)
  sprintf(paste("Profondeur T = %d. Les lois asymptotiques ne sont pas fiables \u00e0 cette",
                "taille : les p-values exactes, lorsqu'elles existent, et les p-values de",
                "Monte-Carlo priment. Une p-value \u00e9lev\u00e9e ne d\u00e9montre pas la validit\u00e9 de",
                "l'hypoth\u00e8se : elle ne permet pas de la rejeter."), T)
}

# --- Tableaux (mise en forme seule) -----------------------------------------
table_synthese_groupe <- function(tb) {
  # unname() et row.names = NULL sont indispensables : vapply() conserve les
  # noms de son vecteur d'entree, et data.frame() les promeut en noms de
  # lignes. Des verdicts dupliques ou une nature de p-value manquante (cas des
  # diagnostics) produisaient alors une erreur de construction du tableau.
  data.frame(
    Verdict = unname(vapply(tb$verdict, badge_verdict, character(1))),
    Test    = paste0("<span style='font-weight:600;color:#1B2631'>", tb$test, "</span>"),
    `Statistique` = ifelse(is.finite(tb$statistique),
        paste0("<code>", tb$nom_statistique, "</code> = ", fmt_nb(tb$statistique)), "\u2013"),
    Estimation = ifelse(is.finite(tb$estimation),
        paste0(tb$nom_estimation, " = ", fmt_nb(tb$estimation)), "\u2013"),
    `p retenue` = fmt_p(tb$p_retenue),
    Nature = unname(vapply(tb$nature_p, badge_nature, character(1))),
    check.names = FALSE, stringsAsFactors = FALSE, row.names = NULL)
}

table_detail_groupe <- function(tb) {
  data.frame(
    Test = paste0("<span style='font-weight:600;color:#1B2631'>", tb$test, "</span>"),
    H0 = tb$H0, H1 = tb$H1,
    `Loi sous H0` = tb$loi_sous_H0,
    `p exacte` = fmt_p(tb$p_exacte),
    `p asympt.` = fmt_p(tb$p_asymptotique),
    `p Monte-Carlo` = fmt_p(tb$p_monte_carlo),
    `erreur MC` = ifelse(is.finite(tb$erreur_MC), paste0("\u00b1 ", fmt_nb(tb$erreur_MC)), "\u2013"),
    Sens = tb$sens_du_test, Reference = tb$reference,
    check.names = FALSE, stringsAsFactors = FALSE, row.names = NULL)
}

html_table <- function(d, classe = "table table-condensed data") {
  paste0("<table class='", classe, "'><thead><tr>",
         paste0("<th>", names(d), "</th>", collapse = ""), "</tr></thead><tbody>",
         paste(apply(d, 1, function(l)
           paste0("<tr><td>", paste(l, collapse = "</td><td>"), "</td></tr>")), collapse = ""),
         "</tbody></table>")
}

# =============================================================================
#  GRAPHIQUES  --  representation de res$plots_data uniquement
# =============================================================================

.mep <- function(p, titre, xlab, ylab) {
  plotly::layout(p, title = list(text = titre, font = list(size = 14, color = COUL$pt)),
                 xaxis = list(title = xlab, zeroline = FALSE, gridcolor = "#EEEEEE"),
                 yaxis = list(title = ylab, zeroline = FALSE, gridcolor = "#EEEEEE"),
                 paper_bgcolor = COUL$fond, plot_bgcolor = COUL$fond,
                 margin = list(t = 45), showlegend = FALSE)
}
.cadre <- function() graphics::par(mar = c(4.2, 4.2, 3, 1), bg = COUL$fond,
                                   cex.main = 1, font.main = 1, col.main = COUL$pt)

plot_ajustement <- function(pd) {
  if (is.null(pd$ajustement)) return(.vide())
  d <- pd$ajustement
  if (!.plotly_dispo()) {
    .cadre(); plot(d$x, d$y, pch = 19, col = COUL$pt, xlab = "x_t", ylab = "y_t",
                   main = "Ajustement E[Y] = beta x")
    graphics::abline(0, pd$beta, col = COUL$trait, lwd = 2); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = range(d$x), y = pd$beta * range(d$x),
        line = list(color = COUL$trait, width = 2), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = d$x, y = d$y, marker = list(size = 9, color = COUL$pt),
        hovertemplate = "x = %{x:.2f}<br>y = %{y:.2f}<extra></extra>")
  .mep(p, sprintf("Ajustement E[Y] = beta x   (beta = %.4f)", pd$beta), "x_t", "y_t")
}

plot_ratio <- function(pd) {
  if (is.null(pd$ratio)) return(.vide())
  d <- pd$ratio
  if (!.plotly_dispo()) {
    .cadre(); plot(d$t, d$ratio, type = "b", pch = 19, col = COUL$pt,
                   xlab = "annee t", ylab = "y/x", main = "Ratio observe dans le temps")
    graphics::abline(h = d$niveau[1], col = COUL$trait, lty = 2); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = range(d$t), y = rep(d$niveau[1], 2),
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_trace(p, x = d$t, y = d$ratio, type = "scatter", mode = "lines+markers",
        line = list(color = COUL$pt), marker = list(size = 9, color = COUL$pt),
        hovertemplate = "t = %{x}<br>y/x = %{y:.4f}<extra></extra>")
  .mep(p, "Ratio observe dans le temps", "annee t", "y_t / x_t")
}

plot_qqnorm <- function(pd) {
  if (is.null(pd$qqline)) return(.vide())
  d <- pd$qqnorm; o <- order(d$theorique)
  if (!.plotly_dispo()) {
    .cadre(); plot(d$theorique, d$empirique, pch = 19, col = COUL$pt,
                   xlab = "quantiles N(0,1)", ylab = "residus", main = "QQ-plot normal")
    graphics::polygon(c(d$theorique[o], rev(d$theorique[o])),
                      c(d$env_bas[o], rev(d$env_haut[o])), col = COUL$env, border = NA)
    graphics::points(d$theorique, d$empirique, pch = 19, col = COUL$pt)
    graphics::abline(pd$qqline[["ordonnee"]], pd$qqline[["pente"]], col = COUL$trait, lwd = 2)
    return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_trace(p, x = d$theorique[o], y = d$env_haut[o], type = "scatter",
        mode = "lines", line = list(width = 0), hoverinfo = "skip")
  p <- plotly::add_trace(p, x = d$theorique[o], y = d$env_bas[o], type = "scatter",
        mode = "lines", fill = "tonexty", fillcolor = "rgba(200,220,250,0.7)",
        line = list(width = 0), hoverinfo = "skip")
  p <- plotly::add_lines(p, x = range(d$theorique),
        y = pd$qqline[["ordonnee"]] + pd$qqline[["pente"]] * range(d$theorique),
        line = list(color = COUL$trait, width = 2), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = d$theorique, y = d$empirique,
        marker = list(size = 9, color = COUL$pt),
        hovertemplate = "theorique = %{x:.3f}<br>observe = %{y:.3f}<extra></extra>")
  .mep(p, "QQ-plot normal (H3) \u2014 enveloppe de simulation 90 %",
       "quantiles theoriques N(0,1)", "residus standardises")
}

plot_qq2ech <- function(pd) {
  d <- pd$qq2ech
  if (is.null(d)) return(.vide("QQ-plot a deux echantillons indisponible"))
  lim <- range(c(d$faible, d$fort))
  if (!.plotly_dispo()) {
    .cadre(); plot(d$faible, d$fort, pch = 19, col = COUL$pt, xlim = lim, ylim = lim,
                   xlab = "faible volume", ylab = "fort volume", main = "QQ-plot 2 echantillons")
    graphics::abline(0, 1, col = COUL$trait, lty = 2, lwd = 2); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = lim, y = lim,
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = d$faible, y = d$fort,
        marker = list(size = 9, color = COUL$pt),
        hovertemplate = "faible = %{x:.3f}<br>fort = %{y:.3f}<extra></extra>")
  .mep(p, "QQ-plot a deux echantillons (H2)",
       "quantiles \u2014 faible volume", "quantiles \u2014 fort volume")
}

plot_spread <- function(pd) {
  if (is.null(pd$spread)) return(.vide())
  if (!.plotly_dispo()) {
    .cadre(); plot(pd$spread$x, pd$spread$racine_abs_z, pch = 19, col = COUL$pt,
                   xlab = "x_t", ylab = "sqrt(|z_t|)", main = "Dispersion-niveau")
    graphics::lines(pd$spread_lisse$x, pd$spread_lisse$y, col = COUL$trait, lwd = 2)
    return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = pd$spread_lisse$x, y = pd$spread_lisse$y,
        line = list(color = COUL$trait, width = 2), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = pd$spread$x, y = pd$spread$racine_abs_z,
        marker = list(size = 9, color = COUL$pt),
        hovertemplate = "x = %{x:.1f}<br>sqrt|z| = %{y:.3f}<extra></extra>")
  .mep(p, "Dispersion-niveau (H2) \u2014 lissage local", "x_t", "sqrt(|z_t|)")
}

plot_residus <- function(pd) {
  if (is.null(pd$residus$z)) return(.vide())
  d <- pd$residus
  if (!.plotly_dispo()) {
    .cadre(); plot(d$x, d$z, pch = 19, col = COUL$pt, xlab = "x_t", ylab = "z_t",
                   main = "Residus vs volume")
    graphics::abline(h = 0, col = COUL$trait, lty = 2); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = range(d$x), y = c(0, 0),
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = d$x, y = d$z, text = paste("annee", d$t),
        marker = list(size = 10, color = COUL$pt),
        hovertemplate = "%{text}<br>x = %{x:.1f}<br>z = %{y:.3f}<extra></extra>")
  .mep(p, "Residus standardises vs volume", "x_t", "z_t")
}

plot_profil_delta <- function(pd) {
  if (is.null(pd$profil_delta)) return(.vide())
  d <- pd$profil_delta
  if (!.plotly_dispo()) {
    .cadre(); plot(d$delta, d$objectif, type = "l", lwd = 2, col = COUL$pt,
                   xlab = "delta", ylab = "objectif profile", main = "Profil en delta")
    graphics::abline(v = pd$delta_estime, col = COUL$trait, lty = 2); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = d$delta, y = d$objectif,
        line = list(color = COUL$pt, width = 2),
        hovertemplate = "delta = %{x:.3f}<br>objectif = %{y:.4f}<extra></extra>")
  p <- plotly::add_lines(p, x = rep(pd$delta_estime, 2), y = range(d$objectif),
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  .mep(p, sprintf("Profil de vraisemblance en delta (estime = %.4f)", pd$delta_estime),
       "delta", "objectif profile")
}

# --- Surface de la fonction objectif (delta, gamma) --------------------------
# Toutes les valeurs viennent de engine_surface_objectif(). L'interet principal
# est de voir, lorsque delta est au bord, si la surface presente un plateau :
# dans ce cas la structure de variance n'est pas identifiee par les donnees.
plot_surface_objectif <- function(pd) {
  if (is.null(pd$surface)) return(.vide())
  S <- pd$surface
  titre <- sprintf("Fonction objectif -2 log L%s",
                   if (isTRUE(S$au_bord)) "   \u2014   delta est AU BORD" else "")
  if (!.plotly_dispo()) {
    .cadre()
    graphics::image(S$delta, S$gamma, S$objectif, xlab = "delta", ylab = "gamma",
                    main = titre, col = grDevices::hcl.colors(40, "Blues", rev = TRUE))
    graphics::contour(S$delta, S$gamma, S$objectif, add = TRUE, col = "grey40")
    graphics::points(S$delta_opt, S$gamma_opt, pch = 4, lwd = 3, col = COUL$trait)
    return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_surface(p, x = S$gamma, y = S$delta, z = S$objectif,
        colorscale = "Blues", reversescale = TRUE, showscale = TRUE,
        contours = list(z = list(show = TRUE, usecolormap = TRUE,
                                 project = list(z = TRUE))),
        hovertemplate = paste0("gamma = %{x:.3f}<br>delta = %{y:.3f}",
                               "<br>objectif = %{z:.4f}<extra></extra>"))
  p <- plotly::add_trace(p, x = S$gamma_opt, y = S$delta_opt, z = S$objectif_opt,
        type = "scatter3d", mode = "markers",
        marker = list(size = 6, color = COUL$trait),
        hovertemplate = "optimum<br>delta = %{y:.4f}<br>gamma = %{x:.4f}<extra></extra>")
  plotly::layout(p,
    title = list(text = titre,
                 font = list(size = 14,
                             color = if (isTRUE(S$au_bord)) COUL$trait else COUL$pt)),
    scene = list(xaxis = list(title = "gamma"), yaxis = list(title = "delta"),
                 zaxis = list(title = "objectif"),
                 camera = list(eye = list(x = 1.6, y = -1.5, z = 0.9))),
    margin = list(t = 45), showlegend = FALSE)
}

# --- Coupe de la surface a gamma optimal (lecture 2D de la platitude) --------
plot_coupe_delta <- function(pd) {
  if (is.null(pd$surface)) return(.vide())
  S <- pd$surface
  j <- which.min(abs(S$gamma - S$gamma_opt))
  v <- S$objectif[, j]
  if (!.plotly_dispo()) {
    .cadre(); plot(S$delta, v, type = "l", lwd = 2, col = COUL$pt,
                   xlab = "delta", ylab = "objectif", main = "Coupe a gamma optimal")
    graphics::abline(v = S$delta_opt, col = COUL$trait, lty = 2); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = S$delta, y = v, line = list(color = COUL$pt, width = 2),
        hovertemplate = "delta = %{x:.3f}<br>objectif = %{y:.4f}<extra></extra>")
  p <- plotly::add_lines(p, x = rep(S$delta_opt, 2), y = range(v),
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  .mep(p, sprintf("Coupe a gamma optimal \u2014 amplitude = %.4f", S$amplitude_delta),
       "delta", "objectif")
}

plot_boot_sigma <- function(pd) {
  v <- pd$sigma_boot
  if (!length(v)) return(.vide("Aucune replication bootstrap exploitable"))
  if (!.plotly_dispo()) {
    .cadre(); graphics::hist(v, breaks = 30, col = COUL$env, border = "white",
                             xlab = "sigma simule", main = "Distribution bootstrap de sigma")
    return(invisible())
  }
  p <- plotly::plot_ly(x = v, type = "histogram", nbinsx = 40,
        marker = list(color = COUL$env, line = list(color = "white", width = 1)),
        hovertemplate = "sigma = %{x:.4f}<br>effectif = %{y}<extra></extra>")
  .mep(p, "Distribution bootstrap de sigma", "sigma simule", "effectif")
}

plot_calibration <- function(cand) {
  etiq <- c("standard", "estime seul", "USP retenu")
  lab  <- formatC(cand$valeur, format = "f", digits = 4)
  # Les trois valeurs sont proches : on cadre l'axe avec une marge haute
  # suffisante pour que les etiquettes placees au-dessus des barres restent
  # dans la zone de trace.
  ymax <- max(cand$valeur) * 1.22
  coul <- ifelse(cand$retenu, COUL$trait, COUL$env)
  if (!.plotly_dispo()) {
    .cadre()
    h <- graphics::barplot(cand$valeur, names.arg = etiq, col = coul, border = NA,
                           ylab = "ecart-type", ylim = c(0, ymax),
                           main = "Valeurs candidates")
    graphics::text(h, cand$valeur, labels = lab, pos = 3, cex = 0.95,
                   col = COUL$pt, font = 2)
    return(invisible())
  }
  p <- plotly::plot_ly(x = etiq, y = cand$valeur, type = "bar",
        marker = list(color = coul,
                      line = list(color = COUL$pt, width = 1)),
        text = lab, textposition = "outside",
        # Sans textfont explicite, plotly colore l'etiquette "outside" avec la
        # couleur de la barre : sur les barres bleu pale, elle devient
        # illisible. On force donc une couleur de texte contrastee.
        textfont = list(color = COUL$pt, size = 13),
        cliponaxis = FALSE,
        hovertemplate = "%{x}<br>sigma = %{y:.5f}<extra></extra>")
  p <- plotly::layout(p,
        title = list(text = "Valeurs candidates et parametre retenu",
                     font = list(size = 14, color = COUL$pt)),
        xaxis = list(title = "", zeroline = FALSE, gridcolor = "#EEEEEE"),
        yaxis = list(title = "ecart-type", range = c(0, ymax),
                     zeroline = TRUE, gridcolor = "#EEEEEE"),
        uniformtext = list(minsize = 11, mode = "show"),
        paper_bgcolor = COUL$fond, plot_bgcolor = COUL$fond,
        margin = list(t = 55), showlegend = FALSE)
  p
}

# =============================================================================
#  GRAPHIQUES DE LA METHODE MERZ-WUTHRICH
#  Comme pour la methode lognormale, toutes les quantites proviennent de
#  res$plots_data (calculees par mw_plots_data dans engine.R).
# =============================================================================

.nuage <- function(x, y, titre, xlab, ylab, ligne0 = TRUE) {
  if (!.plotly_dispo()) {
    .cadre(); plot(x, y, pch = 19, col = COUL$pt, xlab = xlab, ylab = ylab, main = titre)
    if (ligne0) graphics::abline(h = 0, col = COUL$trait, lty = 2)
    return(invisible())
  }
  p <- plotly::plot_ly()
  if (ligne0) p <- plotly::add_lines(p, x = range(x), y = c(0, 0),
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = x, y = y, marker = list(size = 9, color = COUL$pt),
        hovertemplate = paste0(xlab, " = %{x}<br>", ylab, " = %{y:.3f}<extra></extra>"))
  .mep(p, titre, xlab, ylab)
}

plot_mw_residus_dev <- function(pd) {
  if (is.null(pd$residus_dev)) return(.vide())
  .nuage(pd$residus_dev$j, pd$residus_dev$residu,
         "Residus de Mack par annee de developpement (M2)", "annee de developpement j", "residu") }

plot_mw_residus_acc <- function(pd) {
  if (is.null(pd$residus_acc)) return(.vide())
  .nuage(pd$residus_acc$i, pd$residus_acc$residu,
         "Residus de Mack par annee d'accident (M3)", "annee d'accident i", "residu") }

plot_mw_residus_cal <- function(pd) {
  if (is.null(pd$residus_cal)) return(.vide())
  .nuage(pd$residus_cal$calendrier, pd$residus_cal$residu,
         "Residus de Mack par annee calendaire (M3)", "annee calendaire i + j", "residu") }

plot_mw_residus_C <- function(pd) {
  if (is.null(pd$residus_C)) return(.vide())
  .nuage(pd$residus_C$C, pd$residus_C$residu,
         "Residus de Mack vs cumul C(i,j) (M1 et M2)", "C(i,j)", "residu") }

plot_mw_qq <- function(pd) {
  if (is.null(pd$qqnorm)) return(.vide())
  d <- pd$qqnorm
  if (!.plotly_dispo()) {
    .cadre(); stats::qqnorm(d$empirique, main = "QQ-plot des residus de Mack (M5)",
                            pch = 19, col = COUL$pt)
    stats::qqline(d$empirique, col = COUL$trait); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = range(d$theorique), y = range(d$theorique),
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = d$theorique, y = d$empirique,
        marker = list(size = 8, color = COUL$pt),
        hovertemplate = "theorique = %{x:.3f}<br>observe = %{y:.3f}<extra></extra>")
  .mep(p, "QQ-plot des residus de Mack (M5, diagnostic)",
       "quantiles theoriques N(0,1)", "residu standardise")
}

plot_mw_facteurs <- function(pd) {
  if (is.null(pd$facteurs)) return(.vide())
  d <- pd$facteurs
  if (!.plotly_dispo()) {
    .cadre(); plot(d$j, d$f, type = "b", pch = 19, col = COUL$pt,
                   xlab = "annee de developpement j", ylab = "f_j",
                   main = "Facteurs de developpement chain-ladder")
    graphics::abline(h = 1, col = COUL$trait, lty = 2); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = range(d$j), y = c(1, 1),
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_trace(p, x = d$j, y = d$f, type = "scatter", mode = "lines+markers",
        line = list(color = COUL$pt), marker = list(size = 9, color = COUL$pt),
        hovertemplate = "j = %{x}<br>f = %{y:.5f}<extra></extra>")
  .mep(p, "Facteurs de developpement chain-ladder", "annee de developpement j", "f_j")
}

plot_mw_reserve <- function(pd) {
  if (is.null(pd$reserve_par_annee)) return(.vide())
  d <- pd$reserve_par_annee
  if (!.plotly_dispo()) {
    .cadre(); graphics::barplot(d$reserve, names.arg = d$i, col = COUL$env, border = NA,
                                xlab = "annee d'accident", ylab = "reserve",
                                main = "Reserve par annee d'accident"); return(invisible())
  }
  p <- plotly::plot_ly(x = d$i, y = d$reserve, type = "bar",
        marker = list(color = COUL$env, line = list(color = COUL$pt, width = 1)),
        hovertemplate = "annee %{x}<br>reserve = %{y:,.0f}<extra></extra>")
  .mep(p, "Reserve par annee d'accident", "annee d'accident i", "reserve")
}

# =============================================================================
#  GRAPHIQUES D'INFLUENCE ET DE LEVIER
#  Toutes les quantites (leviers, distances de Cook, contours, DFBETA, ecarts
#  jackknife) sont calculees dans engine.R et seulement representees ici.
# =============================================================================

# Renvoie TRUE si la table d'influence est celle de la methode lognormale.
# Les deux methodes exposent un champ `influence`, mais de colonnes distinctes :
# residu_std / cook / levier pour la regression, i / j / dfbeta pour le
# triangle. Les fonctions ci-dessous verifient donc explicitement la structure
# recue plutot que de supposer la methode.
.influence_ln <- function(pd)
  !is.null(pd$influence) && all(c("residu_std", "cook", "levier", "seuil_cook") %in%
                                names(pd$influence))
.influence_mw <- function(pd)
  !is.null(pd$influence) && all(c("dfbeta_relatif", "levier", "residu") %in%
                                names(pd$influence))
# Graphique vide, renvoye lorsqu'une quantite n'est pas disponible pour la
# methode courante. Le type de trace est specifie explicitement : sans cela,
# plotly tente de l'inferer et emet un avertissement a chaque rendu.
.vide <- function(message = "Graphique non disponible pour cette methode") {
  if (.plotly_dispo()) {
    p <- plotly::plotly_empty(type = "scatter", mode = "markers")
    return(plotly::layout(p,
      xaxis = list(visible = FALSE), yaxis = list(visible = FALSE),
      paper_bgcolor = COUL$fond, plot_bgcolor = COUL$fond,
      annotations = list(list(text = message, showarrow = FALSE,
                              xref = "paper", yref = "paper", x = 0.5, y = 0.5,
                              font = list(size = 12, color = COUL$ref)))))
  }
  .cadre(); plot.new()
  graphics::text(0.5, 0.5, message, col = COUL$ref, cex = 0.95)
  invisible()
}

# --- Methode lognormale : residus standardises vs levier -------------------
# Equivalent du 5e graphique de plot.lm : les courbes en pointilles sont les
# iso-distances de Cook, une observation situee au-dela etant influente.
plot_influence_levier <- function(pd) {
  if (!.influence_ln(pd)) return(.vide())
  d <- pd$influence; cc <- pd$contours_cook
  lim <- range(c(d$residu_std, -d$residu_std, 2.5, -2.5))
  if (!.plotly_dispo()) {
    .cadre()
    plot(d$levier, d$residu_std, pch = 19, col = ifelse(d$influent, COUL$trait, COUL$pt),
         xlim = c(0, max(d$levier, d$seuil_levier[1]) * 1.15), ylim = lim,
         xlab = "levier h_t", ylab = "residu standardise",
         main = "Residus vs levier (iso-distances de Cook)")
    for (n in unique(cc$niveau)) for (sg in c("+", "-")) {
      k <- cc[cc$niveau == n & cc$signe == sg, ]
      graphics::lines(k$levier, k$residu, lty = 3, col = COUL$ref)
    }
    graphics::abline(h = 0, col = COUL$ref, lty = 2)
    graphics::abline(v = d$seuil_levier[1], col = COUL$trait, lty = 2)
    graphics::text(d$levier, d$residu_std, labels = d$t, pos = 3, cex = 0.8)
    return(invisible())
  }
  p <- plotly::plot_ly()
  for (n in unique(cc$niveau)) for (sg in c("+", "-")) {
    k <- cc[cc$niveau == n & cc$signe == sg, ]
    k <- k[k$residu >= lim[1] & k$residu <= lim[2], ]
    if (nrow(k) > 1)
      p <- plotly::add_lines(p, x = k$levier, y = k$residu,
            line = list(color = COUL$ref, dash = "dot", width = 1),
            hovertemplate = paste0("Cook = ", n, "<extra></extra>"))
  }
  p <- plotly::add_lines(p, x = c(0, max(d$levier) * 1.15), y = c(0, 0),
        line = list(color = COUL$ref, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_lines(p, x = rep(d$seuil_levier[1], 2), y = lim,
        line = list(color = COUL$trait, dash = "dash"),
        hovertemplate = "seuil de levier 2k/T<extra></extra>")
  p <- plotly::add_markers(p, x = d$levier, y = d$residu_std,
        text = paste("annee", d$t),
        marker = list(size = 11, color = ifelse(d$influent, COUL$trait, COUL$pt)),
        hovertemplate = paste0("%{text}<br>levier = %{x:.4f}",
                               "<br>residu std = %{y:.3f}<extra></extra>"))
  p <- plotly::layout(p, yaxis = list(range = lim))
  .mep(p, "Residus standardises vs levier (iso-distances de Cook)",
       "levier h_t", "residu standardise")
}

# --- Methode lognormale : distance de Cook par annee ------------------------
plot_influence_cook <- function(pd) {
  if (!.influence_ln(pd)) return(.vide())
  d <- pd$influence
  if (!.plotly_dispo()) {
    .cadre()
    graphics::barplot(d$cook, names.arg = d$t, border = NA,
                      col = ifelse(d$influent, COUL$trait, COUL$env),
                      xlab = "annee t", ylab = "distance de Cook",
                      main = "Distance de Cook par annee")
    graphics::abline(h = d$seuil_cook[1], col = COUL$trait, lty = 2)
    return(invisible())
  }
  p <- plotly::plot_ly(x = d$t, y = d$cook, type = "bar",
        marker = list(color = ifelse(d$influent, COUL$trait, COUL$env),
                      line = list(color = COUL$pt, width = 1)),
        hovertemplate = "annee %{x}<br>Cook = %{y:.4f}<extra></extra>")
  p <- plotly::add_lines(p, x = range(d$t), y = rep(d$seuil_cook[1], 2),
        line = list(color = COUL$trait, dash = "dash"),
        hovertemplate = "seuil 4/T<extra></extra>")
  .mep(p, "Distance de Cook par annee (seuil 4/T)", "annee t", "distance de Cook")
}

# --- Methode lognormale : influence sur le parametre final ------------------
# Mesure la plus directement interpretable pour le dossier : de combien
# sigma_USP se deplace si l'annee t est retiree (jackknife).
plot_influence_sigma <- function(pd) {
  if (!.influence_ln(pd)) return(.vide())
  d <- pd$influence
  if (is.null(d$ecart_sigma)) return(.vide())
  v <- 100 * d$ecart_sigma
  if (!.plotly_dispo()) {
    .cadre()
    graphics::barplot(v, names.arg = d$t, border = NA,
                      col = ifelse(abs(v) > 10, COUL$trait, COUL$env),
                      xlab = "annee retiree", ylab = "ecart sur sigma_USP (%)",
                      main = "Influence du retrait d'une annee sur sigma_USP")
    graphics::abline(h = 0, col = COUL$pt)
    return(invisible())
  }
  p <- plotly::plot_ly(x = d$t, y = v, type = "bar",
        marker = list(color = ifelse(abs(v) > 10, COUL$trait, COUL$env),
                      line = list(color = COUL$pt, width = 1)),
        hovertemplate = "sans l'annee %{x}<br>ecart = %{y:+.2f} %<extra></extra>")
  p <- plotly::add_lines(p, x = range(d$t), y = c(0, 0),
        line = list(color = COUL$pt), hoverinfo = "skip")
  .mep(p, "Influence du retrait d'une annee sur sigma_USP (jackknife)",
       "annee retiree", "ecart relatif (%)")
}

# --- Merz-Wuthrich : levier des cellules du triangle -----------------------
plot_mw_levier <- function(pd) {
  if (!.influence_mw(pd)) return(.vide())
  d <- pd$influence
  if (!.plotly_dispo()) {
    .cadre()
    plot(d$levier, d$residu, pch = 19, col = ifelse(d$fort_levier, COUL$trait, COUL$pt),
         xlab = "levier dans f_j", ylab = "residu de Mack",
         main = "Residus vs levier des cellules")
    graphics::abline(h = 0, col = COUL$ref, lty = 2)
    return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = range(d$levier), y = c(0, 0),
        line = list(color = COUL$ref, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = d$levier, y = d$residu,
        text = paste0("i = ", d$i, ", j = ", d$j),
        marker = list(size = 10, color = ifelse(d$fort_levier, COUL$trait, COUL$pt)),
        hovertemplate = paste0("%{text}<br>levier = %{x:.4f}",
                               "<br>residu = %{y:.3f}<extra></extra>"))
  .mep(p, "Residus de Mack vs levier de la cellule dans f_j",
       "levier h(i,j) = C(i,j) / S_j", "residu standardise")
}

# --- Merz-Wuthrich : DFBETA sur les facteurs de developpement ---------------
plot_mw_dfbeta <- function(pd) {
  if (!.influence_mw(pd)) return(.vide())
  d <- pd$influence; v <- 100 * d$dfbeta_relatif
  etiq <- paste0("(", d$i, ",", d$j, ")")
  if (!.plotly_dispo()) {
    .cadre()
    plot(seq_along(v), v, type = "h", col = ifelse(abs(v) > 2, COUL$trait, COUL$pt),
         lwd = 2, xlab = "cellule (i, j)", ylab = "variation de f_j (%)",
         main = "Influence de chaque cellule sur f_j")
    graphics::abline(h = 0, col = COUL$ref)
    return(invisible())
  }
  p <- plotly::plot_ly(x = seq_along(v), y = v, type = "bar",
        text = etiq,
        marker = list(color = ifelse(abs(v) > 2, COUL$trait, COUL$env),
                      line = list(color = COUL$pt, width = 1)),
        hovertemplate = paste0("cellule %{text}<br>variation de f_j = ",
                               "%{y:+.3f} %<extra></extra>"))
  # inherit = FALSE : sans cela, la trace herite de l'attribut `text` du trace
  # barre (une etiquette par cellule) alors qu'elle n'a que deux points, ce que
  # plotly refuse de recycler.
  p <- plotly::add_lines(p, x = range(seq_along(v)), y = c(0, 0),
        line = list(color = COUL$pt), hoverinfo = "skip", inherit = FALSE)
  .mep(p, "Influence de chaque cellule sur son facteur f_j (DFBETA)",
       "cellule du triangle", "variation relative de f_j (%)")
}

# --- Merz-Wuthrich : contribution des annees de survenance -----------------
plot_mw_contributions <- function(pd) {
  d <- pd$contributions
  if (is.null(d)) return(.vide("Contributions indisponibles"))
  if (!.plotly_dispo()) {
    .cadre()
    graphics::barplot(rbind(100 * d$part_reserve, 100 * d$part_terme_variance),
                      beside = TRUE, names.arg = d$i, border = NA,
                      col = c(COUL$env, COUL$trait),
                      xlab = "annee de survenance", ylab = "part (%)",
                      main = "Contribution a la reserve et a la variance")
    graphics::legend("topleft", bty = "n", fill = c(COUL$env, COUL$trait),
                     legend = c("reserve", "terme de variance"))
    return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_trace(p, x = d$i, y = 100 * d$part_reserve, type = "bar",
        name = "reserve", marker = list(color = COUL$env),
        hovertemplate = "annee %{x}<br>reserve : %{y:.1f} %<extra></extra>")
  p <- plotly::add_trace(p, x = d$i, y = 100 * d$part_terme_variance, type = "bar",
        name = "terme de variance", marker = list(color = COUL$trait),
        hovertemplate = "annee %{x}<br>variance : %{y:.1f} %<extra></extra>")
  p <- plotly::layout(p, barmode = "group", showlegend = TRUE,
        title = list(text = "Contribution de chaque annee de survenance",
                     font = list(size = 14, color = COUL$pt)),
        xaxis = list(title = "annee de survenance i", gridcolor = "#EEEEEE"),
        yaxis = list(title = "part (%)", gridcolor = "#EEEEEE"),
        paper_bgcolor = COUL$fond, plot_bgcolor = COUL$fond,
        margin = list(t = 45))
  p
}

# --- Régressions par année de développement (M1) ------------------------------
# Petits multiples : pour chaque colonne j, le nuage C(i,j+1) contre C(i,j), la
# droite de proportionnalite y = f_j x (celle du reglement, sans constante) et
# la droite ajustee avec constante. L'ecart entre les deux droites est la
# traduction visuelle du test de nullite de l'ordonnee a l'origine.
# Fenetre d'affichage d'un panneau de regression. Le trace centre sur le nuage
# de points plutot que sur l'origine : forcer l'axe a partir de zero comprime
# les observations dans un coin, alors que les cumules sont eloignes de zero.
# L'information sur l'ordonnee a l'origine reste lisible dans l'ECART entre les
# deux droites, qui traversent toute la fenetre.
.fenetre_regression <- function(C0, C1) {
  ex <- diff(range(C0)); if (!is.finite(ex) || ex == 0) ex <- max(abs(C0)) * 0.1 + 1
  ey <- diff(range(C1)); if (!is.finite(ey) || ey == 0) ey <- max(abs(C1)) * 0.1 + 1
  list(x = c(max(0, min(C0) - 0.28 * ex), max(C0) + 0.15 * ex),
       y = c(max(0, min(C1) - 0.28 * ey), max(C1) + 0.15 * ey))
}

plot_mw_regressions <- function(pd, max_panneaux = 9) {
  L <- pd$regressions
  if (is.null(L) || !length(L)) return(.vide("Regressions indisponibles"))
  L <- L[seq_len(min(length(L), max_panneaux))]
  if (!.plotly_dispo()) {
    op <- graphics::par(mfrow = c(ceiling(length(L) / 3), 3),
                        mar = c(3.4, 3.4, 2.2, 0.8), mgp = c(2, 0.7, 0),
                        bg = COUL$fond, col.main = COUL$pt, cex.main = 0.95)
    on.exit(graphics::par(op))
    for (e in L) {
      w <- .fenetre_regression(e$C0, e$C1)
      plot(e$C0, e$C1, pch = 19, col = COUL$pt, xlim = w$x, ylim = w$y,
           xlab = "C(i,j)", ylab = "C(i,j+1)",
           main = sprintf("j = %d  (n = %d)", e$j, e$n))
      graphics::abline(0, e$f, col = COUL$trait, lwd = 2)
      if (is.finite(e$a)) graphics::abline(e$a, e$b, col = COUL$ref, lty = 2)
    }
    return(invisible())
  }
  ps <- lapply(L, function(e) {
    w <- .fenetre_regression(e$C0, e$C1)
    xr <- w$x                                   # les droites traversent la fenetre
    p <- plotly::plot_ly()
    p <- plotly::add_lines(p, x = xr, y = e$f * xr,
          line = list(color = COUL$trait, width = 2), showlegend = FALSE,
          hovertemplate = paste0("f = ", round(e$f, 4), "<extra></extra>"))
    if (is.finite(e$a))
      p <- plotly::add_lines(p, x = xr, y = e$a + e$b * xr,
            line = list(color = COUL$ref, dash = "dash"), showlegend = FALSE,
            hovertemplate = "ajustement avec constante<extra></extra>")
    p <- plotly::add_markers(p, x = e$C0, y = e$C1, text = paste("i =", e$i),
          marker = list(size = 7, color = COUL$pt), showlegend = FALSE,
          hovertemplate = "%{text}<br>C(i,j) = %{x:,.0f}<br>C(i,j+1) = %{y:,.0f}<extra></extra>")
    plotly::layout(p,
      xaxis = list(range = w$x, gridcolor = "#EEEEEE", zeroline = FALSE),
      yaxis = list(range = w$y, gridcolor = "#EEEEEE", zeroline = FALSE),
      annotations = list(list(text = sprintf("j = %d  (n = %d)", e$j, e$n),
        showarrow = FALSE, xref = "paper", yref = "paper", x = 0.02, y = 0.97,
        font = list(size = 11, color = COUL$pt))))
  })
  p <- plotly::subplot(ps, nrows = ceiling(length(ps) / 3), margin = 0.045,
                       titleX = FALSE, titleY = FALSE)
  plotly::layout(p, title = list(
      text = "Regressions par annee de developpement : trait plein = f_j (sans constante), pointille = avec constante",
      font = list(size = 12, color = COUL$pt)),
    paper_bgcolor = COUL$fond, plot_bgcolor = COUL$fond,
    margin = list(t = 55), showlegend = FALSE)
}

# --- Ordonnee a l'origine par colonne, avec son intervalle -------------------
plot_mw_origine <- function(pd) {
  d <- pd$origine
  if (is.null(d) || !nrow(d)) return(.vide("Ordonnees a l'origine indisponibles"))
  bas <- d$a - 1.96 * d$se_a; haut <- d$a + 1.96 * d$se_a
  sig <- d$p < 0.10
  if (!.plotly_dispo()) {
    .cadre()
    plot(d$j, d$a, pch = 19, col = ifelse(sig, COUL$trait, COUL$pt),
         ylim = range(c(bas, haut, 0)), xlab = "annee de developpement j",
         ylab = "ordonnee a l'origine a_j", main = "Ordonnee a l'origine par colonne (M1)")
    graphics::arrows(d$j, bas, d$j, haut, angle = 90, code = 3, length = 0.04,
                     col = ifelse(sig, COUL$trait, COUL$pt))
    graphics::abline(h = 0, col = COUL$ref, lty = 2)
    return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = range(d$j), y = c(0, 0),
        line = list(color = COUL$ref, dash = "dash"), hoverinfo = "skip")
  p <- plotly::add_trace(p, x = d$j, y = d$a, type = "scatter", mode = "markers",
        error_y = list(type = "data", array = 1.96 * d$se_a, color = COUL$pt),
        marker = list(size = 10, color = ifelse(sig, COUL$trait, COUL$pt)),
        text = paste0("p = ", formatC(d$p, format = "f", digits = 4)),
        hovertemplate = "j = %{x}<br>a = %{y:,.0f}<br>%{text}<extra></extra>")
  .mep(p, "Ordonnee a l'origine par colonne, intervalle a 95 % (M1)",
       "annee de developpement j", "ordonnee a l'origine a_j")
}

# --- Famille alpha : sensibilite du facteur a la ponderation -----------------
plot_mw_alpha <- function(pd) {
  d <- pd$alpha
  if (is.null(d) || !nrow(d)) return(.vide("Famille alpha indisponible"))
  if (!.plotly_dispo()) {
    .cadre()
    matplot(d$j, cbind(d$f0, d$f1, d$f2), type = "b", pch = 19, lty = 1,
            col = c(COUL$env, COUL$trait, COUL$ref), xlab = "annee de developpement j",
            ylab = "facteur estime", main = "Facteur selon la ponderation (famille alpha)")
    graphics::legend("topright", bty = "n", lty = 1, pch = 19,
                     col = c(COUL$env, COUL$trait, COUL$ref),
                     legend = c("alpha = 0", "alpha = 1 (chain-ladder)", "alpha = 2"))
    return(invisible())
  }
  p <- plotly::plot_ly()
  for (k in seq_along(list(1, 2, 3))) {
    v <- list(d$f0, d$f1, d$f2)[[k]]
    nm <- c("alpha = 0 (moyenne simple)", "alpha = 1 (chain-ladder)",
            "alpha = 2 (volume au carre)")[k]
    cl <- c(COUL$env, COUL$trait, COUL$ref)[k]
    p <- plotly::add_trace(p, x = d$j, y = v, type = "scatter", mode = "lines+markers",
          name = nm, line = list(color = cl, width = if (k == 2) 2.5 else 1.5),
          marker = list(size = 8, color = cl),
          hovertemplate = paste0(nm, "<br>j = %{x}<br>f = %{y:.5f}<extra></extra>"))
  }
  plotly::layout(p, title = list(text = "Facteur estime selon la ponderation (famille alpha)",
      font = list(size = 14, color = COUL$pt)),
    xaxis = list(title = "annee de developpement j", gridcolor = "#EEEEEE"),
    yaxis = list(title = "facteur estime", gridcolor = "#EEEEEE"),
    paper_bgcolor = COUL$fond, plot_bgcolor = COUL$fond,
    margin = list(t = 45), showlegend = TRUE)
}
