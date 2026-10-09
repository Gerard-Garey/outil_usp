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

# ref : lignes de reference (gris moyen) ; ref_texte : texte qui les libelle,
# gris fonce plus contraste sur fond blanc (#162).
COUL <- list(trait = "#B03A2E", pt = "#00468C", env = "#C8DCFA",
             ref = "#7F8C8D", vert = "#00B450", fond = "#FFFFFF",
             env_sim = "#E8F0FC", ref_texte = "#4D5656")

# L'option usp.graphiques_base force les branches base R des plot_*() meme si
# plotly est installe. Elle n'est posee que par rapport_html() (graphiques
# figes en PNG), qui la restaure en sortie ; l'application ne la pose jamais.
.plotly_dispo <- function()
  !isTRUE(getOption("usp.graphiques_base")) && requireNamespace("plotly", quietly = TRUE)

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
              ref  = "annexe XVII, B(2)(g)(i) ; C(2)(e)(i)"),
  "C." = list(cle = "H2", titre = "H2 \u2014 Structure de variance quadratique",
              sous = "Var(Y_t) = sigma\u00b2 [(1-delta) \u00b7 xbar \u00b7 x_t + delta \u00b7 x_t\u00b2]",
              ref  = "annexe XVII, B(2)(g)(ii) ; C(2)(e)(ii)"),
  "D." = list(cle = "H3", titre = "H3 \u2014 Lognormalit\u00e9 de la variable mod\u00e9lis\u00e9e",
              sous = "test\u00e9e comme la normalit\u00e9 des r\u00e9sidus normalis\u00e9s z_t",
              ref  = "annexe XVII, B(2)(g)(iii) ; C(2)(e)(iii)"),
  "E." = list(cle = "H4", titre = "H4 \u2014 Ind\u00e9pendance et validit\u00e9 du maximum de vraisemblance",
              sous = "absence d'autocorr\u00e9lation des Y_t conditionnellement aux x_t",
              ref  = "annexe XVII, B(2)(g)(iv) ; C(2)(e)(iv)"),
  "F." = list(cle = "STAB", titre = "Stabilit\u00e9, ruptures et points aberrants",
              sous = "hors hypoth\u00e8ses r\u00e9glementaires, mais conditionne leur lecture",
              ref  = "diagnostics compl\u00e9mentaires"),
  # Les controles numeriques (condition du premier ordre, multi-demarrages)
  # ne sont plus dans la table des tests mais dans res$controles (#22).
  "G." = list(cle = "ROB", titre = "Robustesse de l'estimation",
              sous = "diagnostics de sensibilit\u00e9 (jackknife, IC bootstrap)",
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

# Citation reglementaire d'un groupe (issue #92). Le moteur ecrit la citation
# du point de l'annexe XVII dans le champ famille, selon la methode appliquee
# (par exemple "(annexe XVII B(2)(g)(i))" pour premium, "(annexe XVII
# C(2)(e)(i))" pour reserve1) : l'affichage la lit la, pour n'avoir qu'une
# source. Extraction de chaine seulement : renvoie "annexe XVII, B(2)(g)(i)",
# ou NA si la famille ne se termine pas par une parenthese "(annexe XVII ...)".
citation_de <- function(famille) {
  m <- regmatches(famille, regexec("\\(annexe XVII ([^ ].*)\\)\\s*$", famille))[[1]]
  if (length(m) == 2L) paste0("annexe XVII, ", m[2]) else NA_character_
}

# Groupe d'affichage d'une famille. ref : citation lue dans la famille si elle
# y figure (citation_de()), sinon GROUPES$ref (repli : F., G., M4 a M6).
groupe_de <- function(famille) {
  g <- GROUPES[[substr(famille, 1, 2)]]
  if (is.null(g)) g <- list(cle = "AUTRE", titre = famille, sous = "", ref = "")
  cit <- citation_de(famille)
  if (!is.na(cit)) g$ref <- cit
  g
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
  # Natures du modele auxiliaire pondere (#215, decision P3 du mainteneur du
  # 07/10/2026 : TOST, poids estimes, loi de Student approchee) : p retenue
  # hors hierarchie ; badge distinct de "exacte", par sa couleur comme par
  # son libelle. Les natures "sous le modele auxiliaire MCO" (TOST avant
  # #215 ; pente et Fisher avant #169) ne sont plus posees par le moteur :
  # leur badge est garde pour un objet anterieur relu. La nature "exacte par
  # permutation" du test de Pitman (#169) recoit le badge "exacte".
  if (grepl("^sous le modele auxiliaire pondere", n))
    return("<span style='color:#7D3C98;font-weight:600'>mod\u00e8le pond\u00e9r\u00e9</span>")
  if (grepl("^sous le modele auxiliaire MCO", n))
    return("<span style='color:#7D3C98;font-weight:600'>mod\u00e8le MCO</span>")
  if (grepl("^exacte", n))      return("<span style='color:#1E8449;font-weight:600'>exacte</span>")
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

# --- Type et motif d'une ligne (#124) ----------------------------------------
# Libelle court du type de la ligne, lu dans tb$type (engine_table_tests()).
# Un test inoperant (regle R1, #44) est repere par la colonne logique
# inoperant de engine_table_tests(), posee par la seule fonction add() de
# engine_registre_tests() (#129, point 3) : la distinction est une lecture de
# ce champ, sans calcul ni lecture du commentaire. Colonne absente ou NA
# (objet anterieur au champ) : la ligne garde son type. Table sans colonne
# type (objet anterieur) : NA partout, rien n'est affiche.
type_ligne <- function(tb) {
  n <- nrow(tb)
  if (is.null(tb$type)) return(rep(NA_character_, n))
  inop <- if (is.null(tb$inoperant)) rep(FALSE, n) else tb$inoperant %in% TRUE
  lib <- c("test" = "test", "diagnostic" = "diagnostic",
           "non applicable" = "non applicable",
           "procedure de decision" = "proc\u00e9dure de d\u00e9cision")
  out <- unname(lib[tb$type])
  out[is.na(out) & !is.na(tb$type)] <- tb$type[is.na(out) & !is.na(tb$type)]
  out[inop] <- "test inop\u00e9rant"
  out
}

# Libelle du type sous le badge de verdict (vue Synthese) : seulement pour
# les lignes qui ne sont pas des tests ordinaires, qui expliquent un INFO
# ou une decision sans p-value. Texte echappe.
.sous_badge_type <- function(tb) {
  ty <- type_ligne(tb)
  ifelse(is.na(ty) | ty == "test", "",
         paste0("<br><span style='color:#5D6D7E;font-size:10.5px;font-style:italic'>",
                .txt(ty), "</span>"))
}

# Repere de renvoi (#215, ADR 0003 annotation du 07/10/2026) : lu dans la
# colonne renvoi de engine_table_tests(), calculee par usp_renvois() du
# moteur ; aucun calcul ici. Colonne absente (objet anterieur) ou NA : rien.
# Texte fixe sous le nom du test, dans la colonne Test des vues Synthese et
# Detail ; gris neutre #5D6D7E (celui de .sous_badge_type()), 11 px, pour ne
# pas se confondre avec le violet du badge "modele pondere".
.repere_renvoi <- function(tb) {
  if (is.null(tb$renvoi)) return(rep("", nrow(tb)))
  ifelse(is.na(tb$renvoi), "",
         paste0("<br><span style='color:#5D6D7E;font-size:11px;font-style:italic'>",
                .txt("voir aussi Spearman ratio / volume (p exacte si delta = 1)"),
                "</span>"))
}

# --- Tableaux (mise en forme seule) -----------------------------------------
# Les colonnes textuelles venant du moteur (test, noms de statistique et
# d'estimation, H0, H1, loi, sens, reference) sont echappees ICI, source unique
# pour l'onglet Tests et le rapport fige : elles contiennent des caracteres
# HTML (ex. H1 = "|a| < Delta"). Les badges et balises construits ci-dessous
# ne le sont pas. L'appelant passe donc la table brute du moteur.
table_synthese_groupe <- function(tb) {
  # unname() et row.names = NULL sont indispensables : vapply() conserve les
  # noms de son vecteur d'entree, et data.frame() les promeut en noms de
  # lignes. Des verdicts dupliques ou une nature de p-value manquante (cas des
  # diagnostics) produisaient alors une erreur de construction du tableau.
  data.frame(
    Verdict = paste0(unname(vapply(tb$verdict, badge_verdict, character(1))),
                     .sous_badge_type(tb)),
    Test    = paste0("<span style='font-weight:600;color:#1B2631'>", .txt(tb$test), "</span>",
                     .repere_renvoi(tb)),
    `Statistique` = ifelse(is.finite(tb$statistique),
        paste0("<code>", .txt(tb$nom_statistique), "</code> = ", fmt_nb(tb$statistique)), "\u2013"),
    Estimation = ifelse(is.finite(tb$estimation),
        paste0(.txt(tb$nom_estimation), " = ", fmt_nb(tb$estimation)), "\u2013"),
    `p retenue` = fmt_p(tb$p_retenue),
    Nature = unname(vapply(tb$nature_p, badge_nature, character(1))),
    check.names = FALSE, stringsAsFactors = FALSE, row.names = NULL)
}

# Commentaire du moteur replie (#178, point 1) : les commentaires longs (600 a
# 842 caracteres) donnaient des cellules tres hautes dans la vue Detail. Au-dela
# de `seuil` caracteres, le texte est coupe au dernier espace avant le seuil (a
# defaut, au seuil) : le debut va dans le <summary> d'un <details>, la suite
# dans son corps, deplie au clic. Aucun texte n'est retire : debut et suite,
# rejoints par l'espace de coupure, rendent le commentaire entier (cet espace
# est remplace par la frontiere entre le <summary> et le corps). Mise en forme
# seule, chaque partie echappee ; NA : tiret, comme .txt().
.commentaire_replie <- function(com, seuil = 200L) {
  vapply(com, function(x) {
    if (is.na(x)) return("\u2013")
    if (nchar(x) <= seuil) return(.echap_html(x))
    tete <- substr(x, 1L, seuil)
    esp <- gregexpr(" ", tete, fixed = TRUE)[[1]]
    k <- if (any(esp > 1L)) max(esp) else seuil + 1L
    debut <- substr(x, 1L, k - 1L)
    suite <- substr(x, if (k <= seuil) k + 1L else k, nchar(x))
    paste0("<details class='com'><summary>", .echap_html(debut), "</summary>",
           .echap_html(suite), "</details>")
  }, character(1), USE.NAMES = FALSE)
}

# Colonnes Type et "Motif / commentaire" (#124) : le commentaire du moteur est
# restitue pour TOUTES les lignes, pas seulement les INFO : sur une ligne de
# type "test", il porte aussi des elements de lecture du verdict (ECHEC
# inatteignable, ECHEC possible - regle R1 sans p exacte -, controle sans
# objet, loi de reference non exacte). Vide :
# tiret. Colonne commentaire absente (objet anterieur) : tiret.
# replier = TRUE (vue Detail de l'onglet Tests, #178) : commentaire long replie
# par .commentaire_replie() ; FALSE (defaut, rapport fige) : texte entier
# affiche, le document fige ne dependant pas d'un clic pour etre lu ou imprime.
# Colonne Fonction (#178, point 3) : champ fonction pose par add() (#111),
# provenance de la ligne ; colonne absente ou NA (objet anterieur) : tiret.
table_detail_groupe <- function(tb, replier = FALSE) {
  com <- if (is.null(tb$commentaire)) rep(NA_character_, nrow(tb)) else tb$commentaire
  com[!is.na(com) & !nzchar(trimws(com))] <- NA_character_
  fon <- if (is.null(tb$fonction)) rep(NA_character_, nrow(tb)) else tb$fonction
  data.frame(
    Test = paste0("<span style='font-weight:600;color:#1B2631'>", .txt(tb$test), "</span>",
                  .repere_renvoi(tb)),
    Type = .txt(type_ligne(tb)),
    H0 = .txt(tb$H0), H1 = .txt(tb$H1),
    `Loi sous H0` = .txt(tb$loi_sous_H0),
    `p exacte` = fmt_p(tb$p_exacte),
    `p asympt.` = fmt_p(tb$p_asymptotique),
    `p Monte-Carlo` = fmt_p(tb$p_monte_carlo),
    `erreur MC` = ifelse(is.finite(tb$erreur_MC), paste0("\u00b1 ", fmt_nb(tb$erreur_MC)), "\u2013"),
    # p-value minimale atteignable (loi de reference discrete, #44) ; colonne
    # absente d'une table anterieure au champ : tiret. Trois chiffres
    # significatifs : 2/8! = 5,0e-5 s'afficherait 0.0000 avec fmt_p().
    `p min` = if (is.null(tb$p_min)) rep("\u2013", nrow(tb))
              else ifelse(is.finite(tb$p_min), formatC(tb$p_min, format = "g", digits = 3), "\u2013"),
    Sens = .txt(tb$sens_du_test),
    `Motif / commentaire` = if (replier) .commentaire_replie(com) else .txt(com),
    Reference = .txt(tb$reference),
    Fonction = ifelse(is.na(fon), "\u2013", paste0("<code>", .txt(fon), "</code>")),
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

# Enveloppe du QQ-plot (issue #47) : bande simultanee (exterieure, plus
# claire) puis bande ponctuelle, lues dans pd$qqnorm (env_sim_bas,
# env_sim_haut, env_bas, env_haut) ; libelles et seuil de la bande
# simultanee (B_min_simultane) tires de pd$qq_enveloppe
# (engine_enveloppe_qq()). Aucun calcul : une bande dont les bornes sont NA
# n'est pas tracee, et le sous-titre le dit. Sans pd$qq_enveloppe (objet
# anterieur a l'issue #47, dont les colonnes env_bas / env_haut portaient une
# autre enveloppe), aucune bande n'est tracee ni legendee.
# Niveaux des bandes lus dans pd$qq_enveloppe (niveau_ponctuel,
# niveau_simultane), jamais ecrits ici (#162) : " 90 %" pour 0,90, chaine
# vide si le niveau n'est pas un nombre fini (le libelle omet alors le niveau).
.qq_niveau_txt <- function(niveau) {
  if (length(niveau) != 1L || !is.numeric(niveau) || !is.finite(niveau)) return("")
  paste0(" ", format(100 * niveau, digits = 4, decimal.mark = ",", trim = TRUE), " %")
}
.qq_lib_sim <- function(e)
  paste0("bande simultan\u00e9e", .qq_niveau_txt(e$niveau_simultane),
         " (tous les points \u00e0 la fois)")
.qq_lib_ponct <- function(e)
  paste0("bande ponctuelle", .qq_niveau_txt(e$niveau_ponctuel), " (point par point)")
.qq_bandes <- function(pd) {
  d <- pd$qqnorm
  if (is.null(pd$qq_enveloppe)) return(c(sim = FALSE, ponct = FALSE))
  c(sim = !is.null(d$env_sim_bas) && any(is.finite(d$env_sim_bas)),
    ponct = !is.null(d$env_bas) && any(is.finite(d$env_bas)))
}
# Titre : niveau des bandes tracees s'il leur est commun, aucun niveau sinon
# (la legende donne alors celui de chaque bande).
.qq_titre <- function(pd) {
  b <- .qq_bandes(pd)
  if (!any(b)) return("QQ-plot normal (H3) \u2014 enveloppe indisponible")
  e <- pd$qq_enveloppe
  niv <- unique(c(if (b[["sim"]]) .qq_niveau_txt(e$niveau_simultane),
                  if (b[["ponct"]]) .qq_niveau_txt(e$niveau_ponctuel)))
  paste0("QQ-plot normal (H3) \u2014 enveloppe de simulation",
         if (length(niv) == 1L) niv else "")
}
.qq_sous_titre <- function(pd) {
  e <- pd$qq_enveloppe
  if (is.null(e)) return("")
  b <- .qq_bandes(pd)
  seuil <- if (is.null(e$B_min_simultane)) "" else
    sprintf(" (B_eff < %s)", e$B_min_simultane)
  quoi <- if (b[["sim"]])
            sprintf("bande ponctuelle et bande simultan\u00e9e (rang k = %s sur %s r\u00e9plications)",
                    e$k, e$B_eff)
          else if (b[["ponct"]])
            sprintf("bande ponctuelle seule sur %s r\u00e9plications, bande simultan\u00e9e indisponible%s",
                    e$B_eff, seuil)
          else sprintf("enveloppe indisponible (%s r\u00e9plications)", e$B_eff)
  sprintf("bootstrap param\u00e9trique sous le mod\u00e8le ajust\u00e9, %s", quoi)
}
.qq_bande_base <- function(x, bas, haut, col) {
  o <- order(x)
  if (any(is.finite(bas)))
    graphics::polygon(c(x[o], rev(x[o])), c(bas[o], rev(haut[o])), col = col, border = NA)
}
.qq_bande_plotly <- function(p, x, bas, haut, couleur) {
  if (!any(is.finite(bas))) return(p)
  o <- order(x)
  p <- plotly::add_trace(p, x = x[o], y = haut[o], type = "scatter",
        mode = "lines", line = list(width = 0), hoverinfo = "skip")
  plotly::add_trace(p, x = x[o], y = bas[o], type = "scatter",
        mode = "lines", fill = "tonexty", fillcolor = couleur,
        line = list(width = 0), hoverinfo = "skip")
}

plot_qqnorm <- function(pd) {
  if (is.null(pd$qqline)) return(.vide())
  d <- pd$qqnorm
  b <- .qq_bandes(pd); sim <- b[["sim"]]; ponct <- b[["ponct"]]
  st <- .qq_sous_titre(pd); ti <- .qq_titre(pd)
  if (!.plotly_dispo()) {
    yl <- range(c(d$empirique, if (ponct) c(d$env_bas, d$env_haut),
                  if (sim) c(d$env_sim_bas, d$env_sim_haut)), na.rm = TRUE)
    .cadre(); plot(d$theorique, d$empirique, pch = 19, col = COUL$pt, ylim = yl,
                   xlab = "quantiles N(0,1)", ylab = "residus", main = ti)
    if (nzchar(st)) graphics::mtext(st, side = 3, line = 0.15, cex = 0.7, col = COUL$ref)
    if (sim) .qq_bande_base(d$theorique, d$env_sim_bas, d$env_sim_haut, COUL$env_sim)
    if (ponct) .qq_bande_base(d$theorique, d$env_bas, d$env_haut, COUL$env)
    graphics::points(d$theorique, d$empirique, pch = 19, col = COUL$pt)
    graphics::abline(pd$qqline[["ordonnee"]], pd$qqline[["pente"]], col = COUL$trait, lwd = 2)
    if (sim || ponct)
      graphics::legend("topleft", bty = "n", cex = 0.75,
                       legend = c(.qq_lib_sim(pd$qq_enveloppe),
                                  .qq_lib_ponct(pd$qq_enveloppe))[c(sim, ponct)],
                       fill = c(COUL$env_sim, COUL$env)[c(sim, ponct)],
                       border = c(COUL$ref, COUL$ref)[c(sim, ponct)])
    return(invisible())
  }
  p <- plotly::plot_ly()
  if (sim) p <- .qq_bande_plotly(p, d$theorique, d$env_sim_bas, d$env_sim_haut,
                                 "rgba(232,240,252,0.9)")
  if (ponct) p <- .qq_bande_plotly(p, d$theorique, d$env_bas, d$env_haut,
                                   "rgba(200,220,250,0.7)")
  p <- plotly::add_lines(p, x = range(d$theorique),
        y = pd$qqline[["ordonnee"]] + pd$qqline[["pente"]] * range(d$theorique),
        line = list(color = COUL$trait, width = 2), hoverinfo = "skip")
  p <- plotly::add_markers(p, x = d$theorique, y = d$empirique,
        marker = list(size = 9, color = COUL$pt),
        hovertemplate = "theorique = %{x:.3f}<br>observe = %{y:.3f}<extra></extra>")
  titre <- paste0(ti, if (nzchar(st)) paste0("<br><sup>", st, "</sup>"))
  p <- .mep(p, titre, "quantiles theoriques N(0,1)", "residus standardises")
  # Legende en annotations fixes (.mep() masque la legende plotly).
  ann <- list()
  if (sim) ann[[length(ann) + 1]] <- list(
    text = .qq_lib_sim(pd$qq_enveloppe), x = 0.01, y = 0.99, xref = "paper", yref = "paper",
    xanchor = "left", yanchor = "top", showarrow = FALSE, bgcolor = COUL$env_sim,
    font = list(size = 10, color = COUL$pt))
  if (ponct) ann[[length(ann) + 1]] <- list(
    text = .qq_lib_ponct(pd$qq_enveloppe), x = 0.01, y = if (sim) 0.92 else 0.99, xref = "paper", yref = "paper",
    xanchor = "left", yanchor = "top", showarrow = FALSE, bgcolor = COUL$env,
    font = list(size = 10, color = COUL$pt))
  if (length(ann)) p <- plotly::layout(p, annotations = ann, margin = list(t = 60))
  p
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

# Reperes du rapport de vraisemblance sur delta (issue #45), lus dans
# pd$lr_delta (engine_plots_data()) : ligne pointillee au repere asymptotique
# (quantile a 90 % du melange 1/2 chi2(0) + 1/2 chi2(1), aide de lecture) et
# marques en delta = 0 et delta = 1 au quantile a 90 % du LR simule sous
# chaque borne. Aucun calcul : les hauteurs viennent du moteur.
LIB_LR_ASYMPT <- "rep\u00e8re asymptotique \u00bd\u03c7\u00b2(0) + \u00bd\u03c7\u00b2(1) \u00e0 90 % (Self & Liang 1987), aide de lecture"
# Libelle court du repere asymptotique, ecrit dans le cadre le long de la
# ligne pointillee, hors de toute legende (trace base R et plotly, #162) ; le
# libelle long, avec sa reference, reste au survol (plotly). Debut et fin
# repris par la documentation (doc_tests_usp.tex, index des graphiques).
LIB_LR_ASYMPT_COURT <- "rep\u00e8re asymptotique \u00bd\u03c7\u00b2(0) + \u00bd\u03c7\u00b2(1) \u00e0 90 %, aide de lecture"
LIB_LR_Q90 <- c("quantile 90 % du LR simul\u00e9 sous \u03b4 = 0",
                "quantile 90 % du LR simul\u00e9 sous \u03b4 = 1")
# Annotations fixes courtes des marques bootstrap (trace plotly, ou .mep()
# masque la legende) ; le libelle long reste au survol.
LIB_LR_Q90_COURT <- c("q90 % du LR simul\u00e9 sous \u03b4 = 0",
                      "q90 % du LR simul\u00e9 sous \u03b4 = 1")
# Etendue verticale du trace : courbe et reperes ; marge haute de 30 % quand
# les reperes sont presents, pour loger au-dessus de la ligne du repere
# asymptotique son libelle puis la legende des marques (#162).
.lr_hauteurs <- function(pd, v) {
  L <- pd$lr_delta
  if (is.null(L)) return(range(v, na.rm = TRUE))
  r <- range(c(v, L$seuil_asymptotique, L$q90_bootstrap), na.rm = TRUE)
  c(r[1], r[2] + 0.30 * diff(r))
}
# Cote du cadre ou loger legende et libelle du repere asymptotique : la
# moitie de [0 ; 1] qui ne contient pas delta estime, pour que la ligne
# verticale en delta estime ne traverse ni l'une ni l'autre (#162) ; gauche
# si delta estime n'est pas un nombre fini.
.lr_cote_libre <- function(pd) {
  d0 <- pd$delta_estime
  if (length(d0) == 1L && is.finite(d0) && d0 < 0.5) "droite" else "gauche"
}
# Trace base R : la legende ne porte que les marques ; le repere asymptotique
# est libelle sur sa ligne. Legende et libelle sont loges du cote libre
# (.lr_cote_libre()), entre le bord du cadre (le libelle, au-dela de la marque
# en delta = 0 ou 1) et la ligne verticale en delta estime, avec un ecart
# d'une lettre ; leur taille de police est reduite au besoin pour y tenir (le
# libelle passe d'abord sur deux lignes). Le libelle est au-dessus de la ligne
# si la place libre sous la legende le permet, au-dessous sinon (#162).
.lr_reperes_base <- function(pd) {
  L <- pd$lr_delta
  if (is.null(L)) return(invisible())
  s <- L$seuil_asymptotique
  graphics::abline(h = s, col = COUL$ref, lty = 3, lwd = 1.5)
  q <- unname(L$q90_bootstrap)
  ok <- is.finite(q)
  if (any(ok)) graphics::points(c(0, 1)[ok], q[ok], pch = 17, cex = 1.3, col = COUL$trait)
  u <- graphics::par("usr")
  gauche <- .lr_cote_libre(pd) == "gauche"
  d0 <- pd$delta_estime
  if (length(d0) != 1L || !is.finite(d0)) d0 <- if (gauche) u[2] else u[1]
  ecart <- graphics::strwidth("m", cex = 0.75)
  # Legende : du bord du cadre a la ligne en delta estime, ecart deduit.
  lib_leg <- "quantile 90 % du LR simul\u00e9 sous \u03b4 = 0 / \u03b4 = 1"
  place_leg <- if (gauche) d0 - ecart - u[1] else u[2] - d0 - ecart
  pos_leg <- if (gauche) "topleft" else "topright"
  cex_leg <- 0.75
  for (k in 1:2) {
    w <- graphics::legend(pos_leg, bty = "n", cex = cex_leg, legend = lib_leg,
                          pch = 17, plot = FALSE)$rect$w
    if (w > place_leg) cex_leg <- cex_leg * place_leg / w
  }
  leg <- graphics::legend(pos_leg, bty = "n", cex = cex_leg, legend = lib_leg,
                          pch = 17, col = COUL$trait)
  if (length(s) == 1L && is.finite(s)) {
    # Libelle : au-dela de la marque bootstrap du bord (largeur d'un triangle
    # de cex 1,3) et en deca de la ligne en delta estime.
    # Sur une ligne si la police reste d'au moins 0,65 ; sinon coupe en deux
    # lignes avant « aide de lecture ».
    marque <- graphics::strwidth("M", cex = 1.3)
    zone <- if (gauche) c(max(u[1], 0 + marque), d0 - ecart) else c(d0 + ecart, min(u[2], 1 - marque))
    taille <- function(lib) min(0.7, 0.98 * diff(zone) / graphics::strwidth(lib, cex = 1))
    lib <- LIB_LR_ASYMPT_COURT
    if (taille(lib) < 0.65) lib <- sub(", aide de lecture", ",\naide de lecture", lib, fixed = TRUE)
    cex <- taille(lib)
    h <- graphics::strheight(lib, cex = cex) + graphics::strheight("M", cex = cex)
    dessus <- s + h <= leg$rect$top - leg$rect$h
    graphics::text(mean(zone), s, lib, pos = if (dessus) 3 else 1,
                   offset = 0.3, cex = cex, col = COUL$ref_texte)
  }
  invisible()
}
# Annotations q90 des marques bootstrap du trace plotly (listes de layout,
# sans plotly : la logique de placement se teste hors navigateur). Chaque
# annotation est du cote de sa marque oppose a la ligne du repere
# asymptotique : au-dessus si la marque est sur la ligne ou au-dessus, au-dessous
# sinon ; la ligne horizontale du repere ne la traverse donc jamais (#162 pour
# le cote libre, #195 pour le bord oppose). L'annotation du bord oppose au
# cote libre s'etend vers l'interieur du cadre, du cote de delta estime :
# la largeur du texte n'etant connue que du navigateur, elle a un fond
# opaque, et masque la ligne verticale en delta estime au lieu d'etre
# traversee (#195). q : quantiles en delta = 0 et 1 ; s : seuil du repere ;
# libre : 1 (delta = 0, gauche) ou 2 (delta = 1, droite).
.lr_annotations_q90 <- function(q, s, libre) {
  s_ok <- length(s) == 1L && is.finite(s)
  ann <- list()
  for (k in which(is.finite(q))) {
    haut <- !(s_ok && q[k] < s)
    a <- list(
      text = LIB_LR_Q90_COURT[k], x = c(0, 1)[k], y = q[k], xref = "x", yref = "y",
      showarrow = FALSE, yanchor = if (haut) "bottom" else "top",
      yshift = if (haut) 8 else -8,
      xanchor = if (k == 1) "left" else "right",
      font = list(size = 10, color = COUL$trait))
    if (k != libre) a$bgcolor <- COUL$fond
    ann[[length(ann) + 1]] <- a
  }
  ann
}
.lr_reperes_plotly <- function(p, pd, xlim) {
  L <- pd$lr_delta
  if (is.null(L)) return(p)
  s <- L$seuil_asymptotique
  s_ok <- length(s) == 1L && is.finite(s)
  p <- plotly::add_lines(p, x = xlim, y = rep(s, 2),
        line = list(color = COUL$ref, dash = "dot", width = 1.5),
        text = LIB_LR_ASYMPT, hovertemplate = "%{text}<extra></extra>")
  q <- unname(L$q90_bootstrap)
  ok <- is.finite(q)
  if (any(ok))
    p <- plotly::add_markers(p, x = c(0, 1)[ok], y = q[ok], text = LIB_LR_Q90[ok],
          marker = list(size = 11, symbol = "triangle-up", color = COUL$trait),
          hovertemplate = "%{text}<extra></extra>")
  libre <- if (.lr_cote_libre(pd) == "gauche") 1L else 2L
  ann <- .lr_annotations_q90(q, s, libre)
  # Libelle court du cote libre (.lr_cote_libre()), cale contre la marque du
  # bord (decalage de 10 px) ; du cote de la ligne oppose a cette marque, donc
  # a son annotation q90. La largeur du texte n'etant connue que du navigateur,
  # le libelle a un fond opaque et vient en dernier : dans un cadre trop etroit,
  # il masque la ligne en delta estime ou une annotation q90 au lieu d'etre
  # traverse ou recouvert. Le libelle long reste au survol de la ligne (#162).
  # Le libelle tient sur une ligne (environ 270 px) si le cadre libre fait au
  # moins 95 % de [0 ; 1] (delta estime au bord ou presque), sur trois
  # (environ 110 px) sinon : dans le cadre le plus etroit, celui de
  # l'application (environ 320 px de large), il reste alors en deca de la ligne
  # en delta estime et de l'annotation q90 de l'autre bord (environ 150 px).
  if (s_ok) {
    gauche <- libre == 1L
    dessous <- is.finite(q[libre]) && q[libre] >= s
    d0 <- pd$delta_estime
    part <- if (length(d0) != 1L || !is.finite(d0)) 1 else if (gauche) d0 else 1 - d0
    lib <- LIB_LR_ASYMPT_COURT
    if (part < 0.95)
      lib <- sub("asymptotique ", "asymptotique<br>",
                 sub(", aide de lecture", ",<br>aide de lecture", lib, fixed = TRUE), fixed = TRUE)
    ann[[length(ann) + 1]] <- list(
      text = lib, x = if (gauche) 0 else 1, y = s,
      xref = "x", yref = "y", xanchor = if (gauche) "left" else "right",
      align = if (gauche) "left" else "right", xshift = if (gauche) 10 else -10,
      yanchor = if (dessous) "top" else "bottom", showarrow = FALSE,
      bgcolor = COUL$fond, font = list(size = 10, color = COUL$ref_texte))
  }
  plotly::layout(p, annotations = ann)
}

plot_profil_delta <- function(pd) {
  if (is.null(pd$profil_delta)) return(.vide())
  d <- pd$profil_delta
  # Profil entierement NA (optimize() en echec a chaque point, #161) : aucun
  # trace de reperes sans courbe, message renvoyant aux lignes G.
  if (all(is.na(d$objectif)))
    return(.vide("Profil non calculable pour ces donnees (voir le motif des lignes G dans l'onglet Tests)"))
  yl <- .lr_hauteurs(pd, d$objectif)
  if (!.plotly_dispo()) {
    .cadre(); plot(d$delta, d$objectif, type = "l", lwd = 2, col = COUL$pt, ylim = yl,
                   xlab = "delta", ylab = "objectif profile", main = "Profil en delta")
    graphics::abline(v = pd$delta_estime, col = COUL$trait, lty = 2)
    .lr_reperes_base(pd); return(invisible())
  }
  p <- plotly::plot_ly()
  p <- plotly::add_lines(p, x = d$delta, y = d$objectif,
        line = list(color = COUL$pt, width = 2),
        hovertemplate = "delta = %{x:.3f}<br>objectif = %{y:.4f}<extra></extra>")
  p <- plotly::add_lines(p, x = rep(pd$delta_estime, 2), y = yl,
        line = list(color = COUL$trait, dash = "dash"), hoverinfo = "skip")
  p <- .lr_reperes_plotly(p, pd, range(d$delta))
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
  # Residus standardises ou distances de Cook non finis (#153) : motif pose
  # par le moteur (engine_plots_data()), lu tel quel.
  if (!is.null(pd$influence_motif)) return(.vide(pd$influence_motif))
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
        hovertemplate = "repere de levier 2k/T<extra></extra>")
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
  if (!is.null(pd$influence_motif)) return(.vide(pd$influence_motif))
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
        hovertemplate = "repere 4/T<extra></extra>")
  .mep(p, "Distance de Cook par annee (repere 4/T)", "annee t", "distance de Cook")
}

# --- Methode lognormale : influence sur le parametre final ------------------
# Mesure la plus directement interpretable pour le dossier : de combien
# sigma_USP se deplace si l'annee t est retiree (jackknife).
# Couleur de repere : booleen fort_ecart_sigma, calcule par le moteur
# (engine_influence(), repere REPERE_INFLUENCE_SIGMA ; issue #33).
plot_influence_sigma <- function(pd) {
  if (!.influence_ln(pd)) return(.vide())
  d <- pd$influence
  if (is.null(d$ecart_sigma) || is.null(d$fort_ecart_sigma)) return(.vide())
  v <- 100 * d$ecart_sigma
  if (!.plotly_dispo()) {
    .cadre()
    graphics::barplot(v, names.arg = d$t, border = NA,
                      col = ifelse(d$fort_ecart_sigma, COUL$trait, COUL$env),
                      xlab = "annee retiree", ylab = "ecart sur sigma_USP (%)",
                      main = "Influence du retrait d'une annee sur sigma_USP")
    graphics::abline(h = 0, col = COUL$pt)
    return(invisible())
  }
  p <- plotly::plot_ly(x = d$t, y = v, type = "bar",
        marker = list(color = ifelse(d$fort_ecart_sigma, COUL$trait, COUL$env),
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

# --- Merz-Wuthrich : DFBETAS sur les facteurs de developpement -------------
# Valeurs (dfbetas), reperes de lecture (repere_dfbetas = c/sqrt(n_j)) et
# couleur (fort_dfbetas) calcules par le moteur (mw_influence(), repere
# REPERE_DFBETAS_MW ; issues #33, #89). Les reperes sont traces par colonne j
# (escalier), pour les seules colonnes ayant au moins un DFBETAS defini ; les
# cellules sans DFBETAS (NA : n_j = 2, colonne degeneree ou sigma2_j nul,
# DFBETAS non borne) ne sont pas tracees.
# Libelle du repere c/sqrt(n_j) : c est lu dans la constante du moteur
# REPERE_DFBETAS_MW (engine.R est source avant ce fichier) ; a defaut, le
# libelle reste litteral (c/sqrt(n_j)), sans aucun calcul.
.libelle_repere_dfbetas <- function(d) {
  c0 <- get0("REPERE_DFBETAS_MW", mode = "numeric", ifnotfound = NULL)
  paste0(if (is.null(c0)) "c" else format(signif(c0, 6)), "/&radic;n_j")
}
plot_mw_dfbeta <- function(pd) {
  if (!.influence_mw(pd) || is.null(pd$influence$fort_dfbetas)) return(.vide())
  d <- pd$influence
  if (all(is.na(d$dfbetas))) return(.vide("DFBETAS non definis pour ce triangle"))
  x <- seq_len(nrow(d)); v <- d$dfbetas; ok <- !is.na(v)
  etiq <- paste0("(", d$i, ",", d$j, ")")
  lib <- sub("&radic;n_j", "sqrt(n_j)", .libelle_repere_dfbetas(d), fixed = TRUE)
  # Escalier des reperes : un palier par colonne j ayant au moins un DFBETAS
  # defini, de la premiere a la derniere cellule de la colonne (+/- 0,5),
  # interrompu entre colonnes.
  jr <- unique(d$j[ok])
  pal <- lapply(split(x, d$j)[as.character(jr)], function(k)
    c(min(k) - 0.5, max(k) + 0.5, NA))
  xr <- unlist(pal, use.names = FALSE)
  rr <- unlist(lapply(split(d$repere_dfbetas, d$j)[as.character(jr)],
                      function(r) c(r[1], r[1], NA)), use.names = FALSE)
  if (!.plotly_dispo()) {
    .cadre()
    plot(x[ok], v[ok], type = "h", col = ifelse(d$fort_dfbetas[ok], COUL$trait, COUL$pt),
         lwd = 2, xlab = "cellule (i, j)", ylab = "DFBETAS",
         xlim = range(xr, na.rm = TRUE),
         ylim = range(c(v[ok], rr, -rr), na.rm = TRUE),
         main = "Influence de chaque cellule sur f_j (DFBETAS)")
    graphics::abline(h = 0, col = COUL$ref)
    graphics::lines(xr, rr, col = COUL$ref, lty = 2)
    graphics::lines(xr, -rr, col = COUL$ref, lty = 2)
    return(invisible())
  }
  info <- sprintf("cellule %s<br>DFBETAS = %+.3f (repere +/- %.3f)<br>variation de f_j = %+.3f %%",
                  etiq, v, d$repere_dfbetas, 100 * d$dfbeta_relatif)
  p <- plotly::plot_ly(x = x[ok], y = v[ok], type = "bar",
        text = info[ok], textposition = "none",
        marker = list(color = ifelse(d$fort_dfbetas[ok], COUL$trait, COUL$env),
                      line = list(color = COUL$pt, width = 1)),
        hovertemplate = "%{text}<extra></extra>")
  # inherit = FALSE : sans cela, les traces de repere heriteraient de
  # l'attribut `text` du trace barre (une etiquette par cellule), de longueur
  # differente, ce que plotly refuse de recycler.
  p <- plotly::add_lines(p, x = range(xr, na.rm = TRUE), y = c(0, 0),
        line = list(color = COUL$pt), hoverinfo = "skip", inherit = FALSE)
  p <- plotly::add_lines(p, x = xr, y = rr, line = list(color = COUL$ref, dash = "dash"),
        connectgaps = FALSE, hoverinfo = "skip", inherit = FALSE)
  p <- plotly::add_lines(p, x = xr, y = -rr, line = list(color = COUL$ref, dash = "dash"),
        connectgaps = FALSE, hoverinfo = "skip", inherit = FALSE)
  .mep(p, sprintf("Influence de chaque cellule sur son facteur f_j (DFBETAS, reperes +/- %s)", lib),
       "cellule du triangle", "DFBETAS")
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
# alpha : seuil des verdicts du calcul (res$metadata$alpha), qui colore les
# colonnes a ordonnee significative (issue #4, piste 3 : plus de 0,10 en dur).
plot_mw_origine <- function(pd, alpha) {
  d <- pd$origine
  if (is.null(d) || !nrow(d)) return(.vide("Ordonnees a l'origine indisponibles"))
  bas <- d$a - 1.96 * d$se_a; haut <- d$a + 1.96 * d$se_a
  sig <- d$p < alpha
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

# =============================================================================
#  TEXTES PARTAGES ENTRE L'APPLICATION ET LE RAPPORT FIGE
#  Mise en forme de valeurs deja presentes dans l'objet res ; aucun calcul
#  methodologique. Les comptages et les maxima des notes sont ceux que
#  l'application affichait deja.
# =============================================================================

# Formule du parametre final, propre a chaque methode :
#  - lognormale (sections B et C) : usp_parametre() multiplie sigma(delta,
#    gamma) par la correction de taille finie sqrt((T+1)/(T-1)) ;
#  - Merz-Wuthrich (section D, paragraphe 4) : mw_parametre() rapporte
#    racine(MSEP) a la reserve chain-ladder totale, sans correction de taille
#    finie (res$parametre_final$correction_taille vaut 1) ; la duree de
#    credibilite est I + 1 (section G(3)(c)), soit res$metadata$T.
texte_formule <- function(res) {
  p <- res$parametre_final; m <- res$metadata
  if (identical(m$methode, "reserve2"))
    return(sprintf(paste(
      "Formule appliquee (annexe XVII, section D, paragraphe 4) :",
      "sigma_USP = c x racine(MSEP) / R + (1-c) x sigma_standard,",
      "o\u00f9 R = somme_i (C^(i,J) - C(i,I-i)) est la reserve chain-ladder totale,",
      "sans correction de taille finie, avec c = %.0f %% (bareme %s, duree %d ans)."),
      100 * p$credibilite, m$bareme, as.integer(m$T)))
  sprintf(paste("Formule appliquee : sigma_USP = c x sigma_estime x sqrt((T+1)/(T-1))",
                "+ (1-c) x sigma_standard, avec c = %.0f %% (bareme %s)."),
          100 * p$credibilite, m$bareme)
}

# Tableau "Parametre standard remplace" (onglet Calibration et section 4 du
# rapport fige ; issue #55) : mise en forme de engine_parametre_standard(res),
# qui fournit toutes les valeurs (nature declaree des donnees, point de
# l'art. 218, paragraphe 1, exigence relative aux donnees, sigma de l'annexe,
# NP standard, sigma standard reglementaire et retenu, origine). Une ligne
# porte une valeur, un texte, ou les deux ("valeur (texte)"). Texte brut :
# l'appelant l'echappe s'il l'ecrit en HTML.
table_parametre_standard <- function(res) {
  d <- engine_parametre_standard(res)
  if (is.null(d)) return(NULL)
  val <- ifelse(is.na(d$valeur), NA_character_, fmt_nb(d$valeur, 4))
  txt <- ifelse(is.na(val), d$texte,
                ifelse(is.na(d$texte), val, paste0(val, " (", d$texte, ")")))
  data.frame(Grandeur = d$grandeur, Valeur = txt, stringsAsFactors = FALSE)
}

# Libelle de la derogation portant sur `parametre` ("sigma_standard",
# "bareme" ou "profondeur"), ou NULL s'il n'y en a pas (issue #93) : lecture
# de engine_derogations(res), seul point de lecture des derogations (sigma
# standard saisi, #55 ; bareme de credibilite saisi ou non determine par la
# section G, #93 ; troncature des annees fournies a la profondeur T, #104).
# Aucun calcul.
libelle_derogation <- function(res, parametre) {
  d <- engine_derogations(res)
  if (is.null(d)) return(NULL)
  l <- d$libelle[d$parametre == parametre]
  if (length(l)) l[1] else NULL
}

# Generateur aleatoire et graines fixes consignes dans res$metadata (issue #37,
# decision (iii) du mainteneur du 25/09/2026 : ils sont affiches dans l'onglet
# Donnees et dans l'en-tete du rapport fige). Lecture seule de metadata, aucun
# calcul : un champ absent (objet anterieur a l'issue #37) ne produit pas
# d'element. Rend un vecteur de textes bruts nomme par champ de metadata
# (generateur, seed_loi_nulle_sw ; la graine de l'enveloppe du QQ-plot est
# retiree par l'issue #47, l'enveloppe etant lue dans le bootstrap) ;
# chaque appelant choisit ses libelles (ASCII dans
# l'onglet Donnees, accentues dans le rapport) et echappe s'il ecrit en HTML.
valeurs_generateur <- function(m) {
  out <- character(0)
  g <- m$generateur
  if (!is.null(g))
    out["generateur"] <- paste0("kind = ", g$kind, ", normal.kind = ", g$normal.kind,
                                ", sample.kind = ", g$sample.kind)
  if (!is.null(m$seed_loi_nulle_sw))
    out["seed_loi_nulle_sw"] <- format(m$seed_loi_nulle_sw, scientific = FALSE)
  out
}

# Tableau "Robustesse du calibrage" (onglet Calibration et section 4 du
# rapport fige) : tous les diagnostics des groupes ROB (lognormal) et M6
# (Merz-Wuthrich) de engine_table_tests(), independamment de la selection de
# l'onglet Personnalisation. Texte brut : l'appelant l'echappe s'il l'ecrit en
# HTML.
# Le filtre passe par la CLE de groupe et non par le libelle de famille :
# celui-ci differe selon la methode ("G. Robustesse..." en lognormal,
# "M6. robustesse..." en Merz-Wuthrich). Un filtre litteral renvoyait zero
# ligne en Merz-Wuthrich, et paste0() sur un vecteur vide recycle a la
# longueur 1, d'ou une erreur de construction du data.frame.
table_robustesse <- function(tb) {
  cle <- vapply(tb$famille, function(f) groupe_de(f)$cle, character(1))
  tb <- tb[cle %in% c("ROB", "M6"), , drop = FALSE]
  if (!nrow(tb))
    return(data.frame(Diagnostic = "Aucun diagnostic de robustesse disponible.",
                      stringsAsFactors = FALSE))
  data.frame(Diagnostic = tb$test,
             Estimation = paste0(tb$nom_estimation, " = ", fmt_nb(tb$estimation, 6)),
             Verdict = tb$verdict, Commentaire = tb$commentaire,
             stringsAsFactors = FALSE, row.names = NULL)
}

# Notes contextuelles des onglets graphiques (HTML). NULL si la quantite
# n'existe pas pour la methode du resultat.
note_surface <- function(pd) {
  S <- pd$surface
  if (is.null(S)) return(NULL)
  if (isTRUE(S$au_bord))
    list(alerte = TRUE, html = sprintf(paste(
      "delta est estim&eacute; <b>au bord</b> (%.4f). Amplitude de",
      "l'objectif le long de delta &agrave; gamma optimal : <b>%.4f</b>.",
      "Une amplitude faible confirme un plateau, donc une structure de",
      "variance non identifi&eacute;e."), S$delta_opt, S$amplitude_delta))
  else
    list(alerte = FALSE, html = sprintf(
      "delta = %.4f est int&eacute;rieur au domaine ; amplitude le long de delta : %.4f.",
      S$delta_opt, S$amplitude_delta))
}

# alpha : seuil des verdicts du calcul (res$metadata$alpha), et non 0,10 en
# dur (issue #4, piste 3).
note_m1 <- function(pd, alpha) {
  d <- pd$origine
  if (is.null(d) || !nrow(d)) return(NULL)
  k <- sum(d$p < alpha, na.rm = TRUE)
  w <- d[which.min(d$p), ]
  sprintf(paste(
    "Le r&egrave;glement impose E[C(i,j+1) | C(i,j)] = f_j C(i,j),",
    "soit une droite <b>passant par l'origine</b> (trait plein). Le pointill&eacute;",
    "est la droite ajust&eacute;e avec constante : un &eacute;cart marqu&eacute;",
    "entre les deux signale une composante fixe non pr&eacute;vue par le mod&egrave;le.",
    "<br><b>%d colonne(s) sur %d</b> pr&eacute;sentent une ordonn&eacute;e &agrave;",
    "l'origine significative au seuil alpha = %s, la plus marqu&eacute;e &eacute;tant",
    "<b>j = %d</b> (p = %.4f)."), k, nrow(d), format(alpha), w$j, w$p)
}

note_influence_mw <- function(pd) {
  d <- pd$influence
  if (is.null(d$dfbeta_relatif) || is.null(d$fort_dfbetas)) return(NULL)
  nf <- sum(d$fort_levier, na.rm = TRUE)
  txt <- sprintf(paste(
    "Le levier d'une cellule dans son facteur f_j vaut C(i,j) / S_j ; il somme &agrave; 1",
    "par colonne. <b>%d cellule(s)</b> d&eacute;passent le rep&egrave;re de levier 2/n_j."), nf)
  nb <- if (is.null(d$dfbetas_non_borne)) integer(0) else which(d$dfbetas_non_borne)
  # dfbetas_non_borne (moteur) : le retrait de la cellule laisse dans sa
  # colonne des cellules proportionnelles ou presque ; restitue sans verdict.
  txt_nb <- if (length(nb)) sprintf(paste(
    "DFBETAS non born&eacute; : %s ; le retrait de %s laisse dans sa colonne des",
    "cellules proportionnelles ou presque (C(k,j+1) &asymp; f C(k,j)) : son DFBETAS",
    "est trop grand pour &ecirc;tre restitu&eacute; (influence pratiquement illimit&eacute;e)."),
    paste0("(i = ", d$i[nb], ", j = ", d$j[nb], ")", collapse = ", "),
    if (length(nb) > 1) "chacune de ces cellules" else "cette cellule") else NULL
  if (all(is.na(d$dfbetas)))
    return(paste(c(txt, "Le DFBETAS n'est d&eacute;fini pour aucune cellule de ce triangle.",
                   txt_nb), collapse = " "))
  lib <- .libelle_repere_dfbetas(d)
  nd <- sum(d$fort_dfbetas)
  mx <- d[which.max(abs(d$dfbetas)), ]
  paste(c(txt, sprintf(paste(
    "Le DFBETAS d'une cellule est la variation de f_j au retrait de cette cellule,",
    "exprim&eacute;e en &eacute;carts-types estim&eacute;s de f_j.",
    "<b>%d cellule(s)</b> ont un DFBETAS au-del&agrave; du rep&egrave;re de lecture",
    "%s (sans verdict). Sous le mod&egrave;le (erreurs gaussiennes, leviers &eacute;gaux),",
    "une cellule sans anomalie franchit ce rep&egrave;re avec une probabilit&eacute; qui d&eacute;pend",
    "du nombre n_j de cellules de sa colonne : 35 %% pour n_j = 3, 17 %% pour n_j = 5,",
    "12 %% pour n_j = 7, 9 %% pour n_j = 10, en d&eacute;croissant vers 4,6 %% quand n_j cro&icirc;t.",
    "Plusieurs cellules color&eacute;es sont donc attendues sans anomalie, surtout dans",
    "les colonnes courtes.",
    "La cellule la plus influente est",
    "<b>(i = %d, j = %d)</b> (DFBETAS = %+.2f), dont le retrait d&eacute;placerait f_%d de",
    "<b>%+.2f %%</b>."), nd, lib, mx$i, mx$j, mx$dfbetas, mx$j, 100 * mx$dfbeta_relatif),
    txt_nb), collapse = " ")
}

note_influence <- function(pd) {
  d <- pd$influence
  # La table d'influence du triangle n'a pas les colonnes de la regression
  # lognormale.
  if (is.null(d$cook) || is.null(d$ecart_sigma)) return(NULL)
  # Distances de Cook non finies (#153, motif pose par le moteur) : influent
  # vaut NA, le decompte est remplace par une phrase qui renvoie au motif.
  cook <- if (is.null(pd$influence_motif))
    sprintf("<b>%d</b> observation(s) au-del&agrave; du rep&egrave;re de Cook (4/T = %.3f)",
            sum(d$influent), d$seuil_cook[1])
  else sprintf(paste("Distance de Cook non finie : rep&egrave;re de Cook (4/T = %.3f) sans objet",
                     "(motif dans les graphiques) ;"), d$seuil_cook[1])
  nl <- sum(d$fort_levier)
  sprintf(paste(
    "%s%s <b>%d</b>",
    "au-del&agrave; du rep&egrave;re de levier (2k/T = %.3f). Le retrait de l'ann&eacute;e la plus",
    "influente d&eacute;place sigma_USP de <b>%+.1f %%</b>. Un levier &eacute;lev&eacute;",
    "seul n'est pas probl&eacute;matique : c'est sa combinaison avec un r&eacute;sidu",
    "important, mesur&eacute;e par la distance de Cook, qui l'est."),
    cook, if (is.null(pd$influence_motif)) " et" else "", nl, d$seuil_levier[1],
    100 * d$ecart_sigma[which.max(abs(d$ecart_sigma))])
}

# =============================================================================
#  RAPPORT FIGE (HTML AUTONOME)
#
#  rapport_html() ecrit un document HTML unique, sans aucune ressource
#  externe, qui fige l'objet res renvoye par run_engine() : donnees, controles,
#  parametre, tests retenus par la selection, tests exclus en annexe,
#  graphiques. Il ne relance aucun calcul et ne lit jamais la saisie courante.
#  Aucune primitive Shiny ; htmltools n'est appele que dans la branche des
#  graphiques interactifs.
#
#  Graphiques :
#    - interactif = TRUE et plotly installe : widgets plotly, dont les
#      dependances JavaScript et CSS sont integrees dans le document (balises
#      <script> et <style>), sans pandoc ;
#    - sinon : PNG produits par les branches base R des plot_*(), integres en
#      base64 (encodeur en R base ci-dessous) ;
#    - sans peripherique PNG (capabilities("png") FALSE) : un bandeau explicite
#      remplace les graphiques, sans erreur.
# =============================================================================

# Identite du code : version declaree dans DESCRIPTION et md5 des octets de
# R/engine.R. Relevee par l'application au demarrage, au moment ou elle
# charge le moteur. .gitattributes impose des fins de ligne LF dans l'arbre
# de travail : le md5 porte sur le contenu du fichier versionne.
identite_code <- function(racine = ".") {
  desc <- file.path(racine, "DESCRIPTION")
  eng  <- file.path(racine, "R", "engine.R")
  list(version = if (file.exists(desc)) unname(read.dcf(desc, fields = "Version")[1, 1])
                 else NA_character_,
       md5_engine = if (file.exists(eng)) unname(as.character(tools::md5sum(eng)))
                    else NA_character_,
       releve = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"))
}

# Encodage base64 (RFC 4648, alphabet standard, remplissage "=") en R base.
# Trois octets (24 bits) donnent quatre caracteres de 6 bits.
.B64 <- c(LETTERS, letters, as.character(0:9), "+", "/")
encoder_base64 <- function(octets) {
  v <- as.integer(octets); n <- length(v)
  if (!n) return("")
  reste <- n %% 3L
  if (reste) v <- c(v, rep(0L, 3L - reste))
  m <- matrix(v, nrow = 3L)
  i <- rbind(bitwShiftR(m[1, ], 2L),
             bitwOr(bitwShiftL(bitwAnd(m[1, ], 3L), 4L), bitwShiftR(m[2, ], 4L)),
             bitwOr(bitwShiftL(bitwAnd(m[2, ], 15L), 2L), bitwShiftR(m[3, ], 6L)),
             bitwAnd(m[3, ], 63L))
  s <- .B64[as.vector(i) + 1L]
  if (reste) s[length(s) - seq_len(3L - reste) + 1L] <- "="
  paste(s, collapse = "")
}

.echap_html <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}
.txt <- function(x) ifelse(is.na(x), "\u2013", .echap_html(as.character(x)))

.bandeau_html <- function(texte, classe = "avert")
  sprintf("<div class='%s'>%s</div>", classe, texte)

.table_kv <- function(cles, valeurs) {
  d <- data.frame(a = cles, b = valeurs, stringsAsFactors = FALSE)
  names(d) <- c("\u00c9l\u00e9ment", "Valeur")
  html_table(d, classe = "data kv")
}

# Graphiques, dans l'ordre des onglets de l'application, avec leurs notes.
# h = hauteur en pixels ; plein = pleine largeur (sinon demi-largeur).
.graphiques_rapport <- function(res) {
  pd <- res$plots_data
  g <- function(f, h = 330, plein = FALSE) list(f = f, h = h, plein = plein)
  if (identical(res$metadata$methode, "reserve2")) return(list(
    list(titre = "Ajustement", note = NULL,
         g = list(g(function() plot_mw_facteurs(pd)), g(function() plot_mw_reserve(pd)))),
    list(titre = "M1 - r\u00e9gressions", note = note_m1(pd, res$metadata$alpha),
         g = list(g(function() plot_mw_regressions(pd), 560, TRUE),
                  g(function() plot_mw_origine(pd, res$metadata$alpha)),
                  g(function() plot_mw_alpha(pd)))),
    list(titre = "M2 - variance", note = NULL,
         g = list(g(function() plot_mw_residus_C(pd)), g(function() plot_mw_residus_dev(pd)))),
    list(titre = "M3 - ind\u00e9pendance", note = NULL,
         g = list(g(function() plot_mw_residus_acc(pd)), g(function() plot_mw_residus_cal(pd)))),
    list(titre = "M5 - normalit\u00e9 (diagnostic)", note = NULL,
         g = list(g(function() plot_mw_qq(pd)), g(function() plot_boot_sigma(pd)))),
    list(titre = "Influence et leviers", note = note_influence_mw(pd),
         g = list(g(function() plot_mw_levier(pd), 380), g(function() plot_mw_contributions(pd), 380),
                  g(function() plot_mw_dfbeta(pd), 330, TRUE)))))
  ns <- note_surface(pd)
  list(
    list(titre = "Donn\u00e9es", note = NULL,
         g = list(g(function() plot_ajustement(pd)), g(function() plot_ratio(pd)))),
    list(titre = "H2 - variance", note = NULL,
         g = list(g(function() plot_qq2ech(pd)), g(function() plot_spread(pd)),
                  g(function() plot_residus(pd), 330, TRUE))),
    list(titre = "H3 - normalit\u00e9", note = NULL,
         g = list(g(function() plot_qqnorm(pd), 420, TRUE))),
    list(titre = "Surface objectif",
         note = if (!is.null(ns)) list(html = ns$html, classe = if (ns$alerte) "avert" else "ok"),
         g = list(g(function() plot_surface_objectif(pd), 520, TRUE),
                  g(function() plot_coupe_delta(pd), 250), g(function() plot_profil_delta(pd), 250))),
    list(titre = "Influence et leviers", note = note_influence(pd),
         g = list(g(function() plot_influence_levier(pd), 380), g(function() plot_influence_cook(pd), 380),
                  g(function() plot_influence_sigma(pd), 330, TRUE))),
    list(titre = "Incertitude d'estimation", note = NULL,
         g = list(g(function() plot_boot_sigma(pd), 420, TRUE))))
}

# Un graphique fige en PNG (branche base R), integre en base64. Toute erreur
# de trace est convertie en bandeau : le rapport n'echoue jamais sur un
# graphique.
.graphique_png <- function(gr) {
  largeur <- if (isTRUE(gr$plein)) 1000 else 560
  fichier <- tempfile(fileext = ".png")
  on.exit(unlink(fichier), add = TRUE)
  r <- tryCatch({
    grDevices::png(fichier, width = largeur, height = gr$h)
    dev <- grDevices::dev.cur()
    tryCatch({ gr$f(); TRUE }, finally = grDevices::dev.off(dev))
  }, error = function(e) conditionMessage(e))
  if (!isTRUE(r) || !file.exists(fichier) || !isTRUE(file.info(fichier)$size > 0))
    return(.bandeau_html(paste("Graphique indisponible :", .echap_html(as.character(r)))))
  sprintf("<img class='graphe' alt='graphique' src='data:image/png;base64,%s'>",
          encoder_base64(readBin(fichier, "raw", file.info(fichier)$size)))
}

# Un graphique interactif : l'objet plotly lui-meme, dont la hauteur est fixee.
.graphique_widget <- function(gr) {
  p <- tryCatch(gr$f(), error = function(e) e)
  if (inherits(p, "error"))
    return(.bandeau_html(paste("Graphique indisponible :", .echap_html(conditionMessage(p)))))
  if (!inherits(p, "htmlwidget"))
    return(.bandeau_html("Graphique indisponible : objet plotly attendu."))
  p$height <- gr$h
  p
}

.graphique <- function(gr, mode) {
  cellule <- function(x) list(sprintf("<div class='%s'>", if (isTRUE(gr$plein)) "cel plein" else "cel"),
                              x, "</div>")
  switch(mode,
         plotly = cellule(.graphique_widget(gr)),
         png    = cellule(.graphique_png(gr)),
         list())
}

# Integration inline des dependances resolues d'un rendu htmltools : chaque
# script dans une balise <script>, chaque feuille de style dans <style>. Une
# dependance sans fichier local, avec des pieces jointes (polices, images) ou
# dont le contenu fermerait prematurement sa balise fait echouer l'integration
# (le rapport retombe alors sur les PNG).
.dependances_inline <- function(deps) {
  deps <- htmltools::resolveDependencies(deps)
  out <- character(0)
  lire <- function(base, s) {
    if (is.list(s)) s <- s$src
    f <- file.path(base, s)
    if (!file.exists(f)) stop(sprintf("fichier de dependance absent : %s", f))
    txt <- rawToChar(readBin(f, "raw", file.info(f)$size))
    Encoding(txt) <- "UTF-8"
    txt
  }
  for (d in deps) {
    base <- if (!is.null(d$package)) system.file(d$src$file, package = d$package)
            else d$src$file
    if (is.null(base) || !nzchar(base) || !dir.exists(base))
      stop(sprintf("dependance %s sans copie locale", d$name))
    if (length(d$attachment) || length(d$head))
      stop(sprintf("dependance %s avec pieces jointes ou en-tete brut", d$name))
    etiq <- .echap_html(paste(d$name, d$version))
    for (s in d$stylesheet) {
      txt <- lire(base, s)
      if (grepl("</style", txt, ignore.case = TRUE))
        stop(sprintf("%s contient </style", d$name))
      out <- c(out, sprintf("<style data-dependance=\"%s\">\n%s\n</style>", etiq, txt))
    }
    for (s in d$script) {
      txt <- lire(base, s)
      if (grepl("</script", txt, ignore.case = TRUE))
        stop(sprintf("%s contient </script", d$name))
      out <- c(out, sprintf("<script data-dependance=\"%s\">\n%s\n</script>", etiq, txt))
    }
  }
  out
}

CSS_RAPPORT <- "
body { font-family: 'Segoe UI', Helvetica, Arial, sans-serif; color:#1B2631;
       max-width:1180px; margin:18px auto; padding:0 16px; background:#FDFEFE; }
h1 { color:#00468C; font-size:24px; margin-bottom:4px; }
h2 { color:#00468C; font-size:19px; border-bottom:2px solid #00468C;
     padding-bottom:3px; margin-top:30px; }
h3 { color:#00468C; font-size:15.5px; margin:14px 0 4px; }
.bloc { background:#fff; border:1px solid #E5E8E8; border-radius:6px;
        padding:10px 14px; margin-bottom:12px; }
.cle { font-size:26px; font-weight:700; color:#B03A2E; }
.avert { background:#FEF9E7; border-left:4px solid #B9770E; padding:9px 12px;
         margin:8px 0; font-size:13px; }
.err { background:#FDEDEC; border-left:4px solid #922B21; padding:9px 12px;
       margin:8px 0; font-size:13px; }
.ok { color:#1E8449; margin:8px 0; font-size:13px; }
.gel { background:#EBF5FB; border-left:4px solid #00468C; padding:9px 12px;
       margin:8px 0; font-size:13px; }
.gris { color:#7F8C8D; font-size:12px; }
table.data { border-collapse:collapse; font-size:12.5px; margin:6px 0 10px; width:100%; }
table.data th { background:#EBF5FB; color:#00468C; text-align:left; padding:4px 6px;
                border-bottom:1px solid #AEB6BF; }
table.data td { padding:3px 6px; border-bottom:1px solid #EAECEE; vertical-align:top; }
table.kv td:first-child { width:34%; font-weight:600; }
.entete-groupe { border-left:4px solid #00468C; padding-left:10px; margin:14px 0 6px; }
.grille { display:flex; flex-wrap:wrap; gap:12px; }
.cel { flex:1 1 calc(50% - 12px); min-width:320px; }
.cel.plein { flex-basis:100%; }
img.graphe { max-width:100%; height:auto; border:1px solid #EAECEE; }
code { font-size:12px; }
"

# rapport_html(res, selection, chemin, interactif, identite)
#   res        objet renvoye par run_engine(), ok = TRUE (sinon erreur)
#   selection  data.frame de selection (cle, garde, base), aligne sur
#              engine_table_tests(res) ; NULL = selection_defaut()
#   chemin     fichier HTML a ecrire
#   interactif TRUE = graphiques plotly si le paquet est installe
#   identite   liste (version, md5_engine, releve) de identite_code()
# Valeur (invisible) : chemin, taille en octets, mode graphique effectif
# ("plotly", "png" ou "aucun"), nombre de lignes et de tests retenus,
# empreintes.
rapport_html <- function(res, selection, chemin, interactif = TRUE, identite = NULL) {
  if (!inherits(res, "usp_engine") || !isTRUE(res$ok))
    stop("rapport_html() : resultat absent ou refuse par le moteur ; aucun rapport a figer.")
  tb <- engine_table_tests(res)
  if (is.null(selection)) selection <- selection_defaut(tb)
  if (nrow(selection) != nrow(tb) || !identical(as.character(selection$cle), tb$test))
    stop("rapport_html() : la selection ne correspond pas aux tests de ce resultat.")
  m <- res$metadata; p <- res$parametre_final
  mw <- identical(m$methode, "reserve2")
  empr <- engine_empreinte(res)
  genere <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
  retenu <- filtrer_selection(tb, selection)

  # --- Mode graphique ---------------------------------------------------------
  png_ok <- isTRUE(capabilities("png"))
  mode <- if (isTRUE(interactif) && .plotly_dispo()) "plotly" else if (png_ok) "png" else "aucun"
  note_mode <- NULL
  if (isTRUE(interactif) && mode != "plotly")
    note_mode <- "Graphiques interactifs demand\u00e9s, mais le paquet plotly est absent."

  construire <- function(mode) {
    if (mode == "png") {
      ancien <- options(usp.graphiques_base = TRUE)
      on.exit(options(ancien), add = TRUE)
    }
    B <- list()
    ajout <- function(...) B[[length(B) + 1L]] <<- list(...)

    # --- 1. En-tete de gel ----------------------------------------------------
    libelle_methode <- switch(m$methode,
      premium  = "risque de prime (annexe XVII, section B)",
      reserve1 = "risque de r\u00e9serve n\u00b0 1 (annexe XVII, section C)",
      reserve2 = "risque de r\u00e9serve n\u00b0 2, Merz-W\u00fcthrich (annexe XVII, section D)",
      m$methode)
    cles <- c("Horodatage du calcul (run_engine)", "Dur\u00e9e du calcul",
              "G\u00e9n\u00e9ration du pr\u00e9sent rapport",
              "M\u00e9thode", "P\u00e9rim\u00e8tre", "Segment",
              if (mw) "Profondeur (I + 1 ann\u00e9es de survenance)" else "Profondeur T",
              "R\u00e9plications B",
              paste("Granularit\u00e9 nominale d'une p-value Monte-Carlo unilat\u00e9rale,",
                    "1/(B+1) sur B nominal (bilat\u00e9rale : 2/(B_eff+1), par statistique,",
                    "champ granularite_stat)"),
              "Seuil alpha des verdicts", "Graine (seed)", "Bar\u00e8me de cr\u00e9dibilit\u00e9",
              "sigma standard", "Nature des donn\u00e9es")
    vals <- c(format(m$horodatage, "%Y-%m-%d %H:%M:%S %Z"),
              sprintf("%.2f s", m$duree_sec), genere,
              paste0("<code>", m$methode, "</code> \u2014 ", libelle_methode),
              paste("annexe", m$annexe),
              if (is.null(m$segment)) "\u2013" else paste0(m$segment, " \u2014 ", .txt(m$libelle_segment)),
              paste0(as.character(m$T),
                     if (!is.null(lib_prof <- libelle_derogation(res, "profondeur")))
                       paste0(" \u2014 <b>", .echap_html(lib_prof), "</b>")),
              as.character(m$B),
              format(res$bootstrap$granularite, digits = 6),
              format(m$alpha), format(m$seed, scientific = FALSE),
              paste0(.txt(m$bareme),
                     if (!is.null(lib_bareme <- libelle_derogation(res, "bareme")))
                       paste0(" \u2014 <b>", .echap_html(lib_bareme), "</b>")),
              paste0(format(m$sigma_standard, digits = 10),
                     if (!is.null(lib_sigma <- libelle_derogation(res, "sigma_standard")))
                       paste0(" \u2014 <b>", .echap_html(lib_sigma), "</b>")),
              .txt(table_parametre_standard(res)$Valeur[1]))
    # Generateur et graines fixes (issue #37) : lignes absentes si le champ
    # manque dans metadata.
    gen <- valeurs_generateur(m)
    lib_gen <- c(generateur = "G\u00e9n\u00e9rateur al\u00e9atoire",
                 seed_loi_nulle_sw = "Graine de la loi nulle de Shapiro-Wilk")
    cles <- c(cles, unname(lib_gen[names(gen)])); vals <- c(vals, .txt(unname(gen)))
    if (!mw) {
      cles <- c(cles, "Test d'\u00e9quivalence de la constante")
      vals <- c(vals, if (is.null(m$delta_equiv))
        sprintf("marge = %s de la perte moyenne (theta_equiv)", format(m$theta_equiv))
        else sprintf("marge Delta fix\u00e9e a priori = %s", format(m$delta_equiv)))
    }
    idt <- if (is.null(identite)) list(version = NA, md5_engine = NA, releve = NA) else identite
    cles <- c(cles, "Version de R", "Version de l'outil (DESCRIPTION)")
    vals <- c(vals, .txt(m$version_R), .txt(idt$version))
    empreintes <- data.frame(
      a = c("Donn\u00e9es du calcul", "R\u00e9sultat du moteur", "Code du moteur (R/engine.R)"),
      b = paste0("<code>", c(.txt(empr$donnees), .txt(empr$resultat), .txt(idt$md5_engine)),
                 "</code>"),
      c = c(paste("Texte canonique des donn\u00e9es du calcul (valeurs en %.17g, NA, fins de",
                  "ligne LF) ; ne d\u00e9pend que des valeurs. <code>engine_empreinte()</code>."),
            paste("Objet s\u00e9rialis\u00e9 (saveRDS version 3, sans horodatage ni dur\u00e9e) ;",
                  "stable sur une m\u00eame machine, <b>d\u00e9pend de la plateforme</b> (ADR 0006) :",
                  "ne se compare pas d'une machine \u00e0 l'autre. <code>engine_empreinte()</code>."),
            paste("Octets du fichier (fins de ligne LF impos\u00e9es par .gitattributes),",
                  "relev\u00e9s le", .txt(idt$releve), "au chargement du moteur par l'application.")),
      stringsAsFactors = FALSE)
    names(empreintes) <- c("Objet", "Empreinte md5", "Statut")
    ajout("<h1>Rapport fig\u00e9 \u2014 param\u00e8tres propres \u00e0 l'entreprise (USP)</h1>",
          paste("<div class='gris'>Solvabilit\u00e9 II, r\u00e8glement d\u00e9l\u00e9gu\u00e9 (UE) 2015/35,",
                "art. 218-220 et annexe XVII</div>"),
          paste("<div class='gel'>Ce document fige l'objet renvoy\u00e9 par <code>run_engine()</code>",
                "tel qu'il \u00e9tait en m\u00e9moire lors de sa g\u00e9n\u00e9ration. Il ne relance aucun",
                "calcul ; les donn\u00e9es restitu\u00e9es sont celles du calcul, non la saisie en",
                "cours dans l'application.</div>"),
          "<h2 id='gel'>1. Identification du calcul</h2>", .table_kv(cles, vals),
          "<h3>Empreintes</h3>", html_table(empreintes, classe = "data"))

    # --- 2. Donnees -----------------------------------------------------------
    # as.character() ecrit chaque valeur isolement (15 chiffres significatifs),
    # sans l'alignement des decimales que format() applique a tout le vecteur.
    num <- function(v) ifelse(is.na(v), "\u2013", as.character(v))
    if (mw) {
      tri <- res$triangle
      d <- data.frame(i = seq_len(nrow(tri)) - 1L, matrix(num(tri), nrow(tri)),
                      stringsAsFactors = FALSE)
      names(d) <- c("i \\ j", as.character(seq_len(ncol(tri)) - 1L))
      titre_d <- "Triangle de paiements cumul\u00e9s C(i,j) utilis\u00e9 par le calcul"
    } else {
      dd <- res$donnees
      d <- data.frame(t = dd$t, x_t = num(dd$xt), y_t = num(dd$yt), r = fmt_nb(dd$ratio, 6),
                      stringsAsFactors = FALSE)
      names(d)[4] <- "y_t / x_t"
      titre_d <- "S\u00e9ries x_t et y_t utilis\u00e9es par le calcul"
    }
    sd <- res$statistiques_descriptives
    ajout("<h2 id='donnees'>2. Donn\u00e9es</h2>", paste0("<h3>", titre_d, "</h3>"),
          html_table(d, classe = "data"),
          "<h3>Statistiques descriptives</h3>",
          html_table(data.frame(Grandeur = .txt(sd$grandeur), Valeur = fmt_nb(sd$valeur, 4),
                                stringsAsFactors = FALSE), classe = "data"))

    # --- 3. Controles et validation -------------------------------------------
    v <- res$validation
    ctr <- do.call(base::rbind, lapply(res$controles, function(t)
      data.frame(a = .txt(t$test), b = badge_verdict(t$verdict), c = .txt(t$detail),
                 stringsAsFactors = FALSE)))
    if (!is.null(ctr)) names(ctr) <- c("Contr\u00f4le", "Verdict", "D\u00e9tail")
    liste <- function(x) paste0("<ul>", paste0("<li>", .txt(x), "</li>", collapse = ""), "</ul>")
    ajout("<h2 id='controles'>3. Contr\u00f4les et validation</h2>",
          if (length(v$erreurs)) .bandeau_html(paste0("<b>Erreurs :</b>", liste(v$erreurs)), "err"),
          if (length(v$avertissements))
            .bandeau_html(paste0("<b>Avertissements :</b>", liste(v$avertissements)))
          else "<div class='ok'>Donn\u00e9es valides, sans avertissement.</div>",
          if (!is.null(ctr)) html_table(ctr, classe = "data"))

    # --- 4. Parametre retenu et calibration -----------------------------------
    ic <- res$ic_bootstrap
    cal <- res$calibration; cand <- res$candidats
    ajout("<h2 id='parametre'>4. Param\u00e8tre retenu et calibration</h2>",
          "<div class='bloc'>",
          sprintf("<div><span class='cle'>sigma_USP = %.4f</span></div>", p$sigma_usp),
          sprintf("<div>soit %+.1f %% par rapport au param\u00e8tre standard de %.4f</div>",
                  100 * p$variation_relative, p$sigma_standard),
          if (!is.null(ic)) sprintf(paste(
            "<div style='margin-top:6px'>Intervalle bootstrap 90 %% : [%.4f ; %.4f]",
            "&nbsp;|&nbsp; 95 %% : [%.4f ; %.4f]</div>"), ic[2], ic[4], ic[1], ic[5]),
          sprintf("<div class='gris' style='margin-top:6px'>%s</div>", .echap_html(texte_formule(res))),
          "</div>",
          paste("<h3>Param\u00e8tre standard remplac\u00e9 (art. 218, paragraphe 1) et",
                "bar\u00e8me de cr\u00e9dibilit\u00e9 (annexe XVII, section G)</h3>"),
          # Bandeaux des derogations (issue #93) : une ligne par derogation
          # de engine_derogations() ; partie en gras reprise du libelle du
          # moteur, phrase explicative du sigma standard inchangee.
          if (!is.null(lib_sigma <- libelle_derogation(res, "sigma_standard")))
            .bandeau_html(paste(paste0("<b>", .echap_html(lib_sigma), "</b>"),
                                ": le sigma standard du m\u00e9lange est une",
                                "saisie libre, et non le param\u00e8tre r\u00e9glementaire de l'annexe",
                                "(m\u00eame s'il en \u00e9gale la valeur) ; nature des donn\u00e9es :",
                                paste0(.txt(table_parametre_standard(res)$Valeur[1]), "."))),
          if (!is.null(lib_bareme <- libelle_derogation(res, "bareme")))
            .bandeau_html(paste0("<b>", .echap_html(lib_bareme), "</b>.")),
          # Troncature des annees fournies a la profondeur T (issue #104) :
          # ligne "profondeur" de engine_derogations() (n_fournies > T).
          if (!is.null(lib_prof <- libelle_derogation(res, "profondeur")))
            .bandeau_html(paste0("<b>", .echap_html(lib_prof), "</b>.")),
          html_table(local({ d <- table_parametre_standard(res); d[] <- lapply(d, .txt); d }),
                     classe = "data"),
          "<h3>Cha\u00eene de calibration</h3>",
          html_table(data.frame(Etape = .txt(cal$etape), Valeur = fmt_nb(cal$valeur, 5),
                                stringsAsFactors = FALSE), classe = "data"),
          "<h3>Valeurs candidates</h3>",
          html_table(data.frame(Variante = .txt(cand$variante), Valeur = fmt_nb(cand$valeur, 5),
                                Retenu = ifelse(cand$retenu, "<b>OUI</b>", ""),
                                stringsAsFactors = FALSE), classe = "data"),
          "<div class='grille'>")
    B[[length(B) + 1L]] <- .graphique(list(f = function() plot_calibration(res$candidats),
                                           h = 300, plein = FALSE), mode)
    # Meme tableau que l'onglet Calibration : tous les diagnostics ROB / M6,
    # retenus ou non par la selection.
    rob <- table_robustesse(tb)
    rob[] <- lapply(rob, .txt)
    ajout("</div>",
          "<h3>Robustesse du calibrage</h3>",
          "<section id='section-robustesse'>",
          "<div class='gris'>Tous les diagnostics de robustesse calcul\u00e9s par le moteur,",
          "ind\u00e9pendamment de la s\u00e9lection des tests retenus (comme l'onglet Calibration).</div>",
          html_table(rob, classe = "data"),
          "</section>")

    # --- 5. Tests retenus -----------------------------------------------------
    # Table brute : table_synthese_groupe() et table_detail_groupe() echappent
    # elles-memes les colonnes textuelles (pas de pre-echappement, qui les
    # doublerait en &amp;lt;).
    te <- tb
    te$cle <- vapply(te$famille, function(f) groupe_de(f)$cle, character(1))
    ajout("<h2 id='tests-retenus'>5. Tests retenus</h2>",
          "<section id='section-tests-retenus'>",
          sprintf(paste(
            "<div class='gel'><b>Personnalisation de la restitution, sans effet sur le calcul.</b>",
            "Le moteur a calcul\u00e9 %d lignes (tests et diagnostics) ; la s\u00e9lection de",
            "l'application en restitue %d ci-dessous, les %d autres figurent en annexe avec leur",
            "verdict, le commentaire du moteur et le motif de leur exclusion.</div>"),
            nrow(tb), sum(retenu), sum(!retenu)),
          paste("<div class='gris'>Nature de la p-value retenue :",
                "<b style='color:#1E8449'>exacte</b> &gt; <b style='color:#00468C'>Monte-Carlo</b>",
                "&gt; <b style='color:#B9770E'>asymptotique</b>.",
                "Les p-values <b style='color:#7D3C98'>sous le mod\u00e8le auxiliaire pond\u00e9r\u00e9</b>",
                "(TOST) sont hors hi\u00e9rarchie : elles ne sont retenues que",
                "faute de p exacte ou Monte-Carlo sous le mod\u00e8le r\u00e9glementaire, et ne",
                "sont pas exactes au sens de l'outil. La p du test de Pitman est exacte par",
                sprintf("permutation lorsque l'\u00e9num\u00e9ration est compl\u00e8te (T &lt;= %d),",
                        T_MAX_ENUM_PERMUTATION),
                "Monte-Carlo sinon.</div>"))
    sel <- te[retenu, , drop = FALSE]
    if (!nrow(sel)) ajout(.bandeau_html("Aucun test s\u00e9lectionn\u00e9."))
    for (k in cles_groupes()) {
      sub <- sel[sel$cle == k, , drop = FALSE]
      if (!nrow(sub)) next
      g <- groupe_de(sub$famille[1])
      nb <- table(factor(sub$verdict, levels = c("OK", "ALERTE", "ECHEC", "INFO")))
      ajout("<div class='entete-groupe'>",
            sprintf("<h3>%s</h3>", g$titre),
            sprintf("<div style='color:#555;font-size:12.5px'>%s</div>", .echap_html(g$sous)),
            sprintf("<div class='gris'><i>%s</i></div>", .echap_html(g$ref)),
            sprintf(paste("<div style='margin-top:5px'>%s %d &nbsp; %s %d &nbsp; %s %d &nbsp;",
                          "<span class='gris'>INFO</span> %d</div>"),
                    badge_verdict("OK"), nb[["OK"]], badge_verdict("ALERTE"), nb[["ALERTE"]],
                    badge_verdict("ECHEC"), nb[["ECHEC"]], nb[["INFO"]]),
            "</div>",
            "<div class='gris'>Synth\u00e8se</div>",
            html_table(table_synthese_groupe(sub), classe = "data"),
            "<div class='gris'>D\u00e9tail</div>",
            html_table(table_detail_groupe(sub), classe = "data"))
    }
    ajout("</section>")

    # --- 6. Annexe : tests exclus ---------------------------------------------
    ex <- te[!retenu, , drop = FALSE]; sx <- selection[!retenu, , drop = FALSE]
    nom_base <- c(z = "r\u00e9sidus normalis\u00e9s z_t", r = "ratios bruts", commun = "base unique")
    motif <- ifelse(!sx$garde,
      ifelse(ex$variante == "secondaire",
             "variante secondaire non conserv\u00e9e dans la s\u00e9lection",
             "test non conserv\u00e9 dans la s\u00e9lection"),
      paste0("calcul\u00e9 sur les ", nom_base[ex$base], " ; base retenue pour ce test : ",
             nom_base[sx$base]))
    # Commentaire du moteur (#178, point 2), comme dans la vue Detail de
    # l'onglet Tests ; vide ou colonne absente (objet anterieur) : tiret.
    com_ex <- if (is.null(ex$commentaire)) rep(NA_character_, nrow(ex)) else ex$commentaire
    com_ex[!is.na(com_ex) & !nzchar(trimws(com_ex))] <- NA_character_
    tab_ex <- if (nrow(ex)) {
      d <- data.frame(ex$cle, paste0("<span style='font-weight:600'>", .txt(ex$test), "</span>"),
                      unname(nom_base[ex$base]), .txt(ex$variante),
                      unname(vapply(ex$verdict, badge_verdict, character(1))),
                      fmt_p(ex$p_retenue),
                      unname(vapply(ex$nature_p, badge_nature, character(1))),
                      unname(motif), .txt(com_ex), stringsAsFactors = FALSE, row.names = NULL)
      names(d) <- c("Groupe", "Test", "Base", "Variante", "Verdict", "p retenue", "Nature", "Motif",
                    "Commentaire du moteur")
      html_table(d, classe = "data")
    }
    ajout("<h2 id='annexe-exclus'>6. Annexe \u2014 tests exclus de la restitution</h2>",
          "<section id='section-annexe-exclus'>",
          if (!nrow(ex))
            "<div class='ok'>Aucun test exclu : toutes les lignes calcul\u00e9es sont restitu\u00e9es.</div>"
          else tab_ex,
          "</section>")

    # --- 7. Graphiques --------------------------------------------------------
    ajout("<h2 id='graphiques'>7. Graphiques</h2>",
          if (!is.null(note_mode)) .bandeau_html(note_mode),
          if (mode == "aucun") .bandeau_html(paste(
            "<b>Graphiques non produits.</b> Les graphiques interactifs n'ont pas \u00e9t\u00e9",
            "demand\u00e9s ou plotly est absent, et ce syst\u00e8me R ne dispose pas du",
            "p\u00e9riph\u00e9rique PNG (capabilities(\"png\") vaut FALSE)."), "err"),
          if (mode == "png")
            "<div class='gris'>Graphiques fig\u00e9s en PNG (branches base R des fonctions de trac\u00e9).</div>")
    for (o in .graphiques_rapport(res)) {
      ajout(sprintf("<h3>%s</h3>", o$titre))
      if (!is.null(o$note)) {
        if (is.list(o$note)) ajout(sprintf("<div class='%s'>%s</div>", o$note$classe, o$note$html))
        else ajout(sprintf("<div class='gris'>%s</div>", o$note))
      }
      ajout("<div class='grille'>")
      for (gr in o$g) B[[length(B) + 1L]] <- .graphique(gr, mode)
      ajout("</div>")
    }
    at <- avertissement_T(m$T)
    if (!is.null(at)) ajout(.bandeau_html(at))
    ajout(sprintf(paste("<hr><div class='gris'>Rapport g\u00e9n\u00e9r\u00e9 le %s par",
                        "<code>rapport_html()</code> (R/display_helpers.R) ; graphiques : %s.</div>"),
                  genere, switch(mode,
                    plotly = "interactifs (plotly, biblioth\u00e8ques int\u00e9gr\u00e9es au document)",
                    png = "PNG int\u00e9gr\u00e9s en base64", aucun = "non produits")))
    # Aplatissement : une liste d'elements, chacun chaine HTML ou widget.
    out <- list()
    for (b in B) for (x in b) if (!is.null(x)) out[[length(out) + 1L]] <- x
    out
  }

  # --- Assemblage -------------------------------------------------------------
  assembler <- function(items, mode) {
    tete <- character(0)
    if (mode == "plotly") {
      rt <- htmltools::renderTags(do.call(htmltools::tagList, lapply(items, function(x)
        if (is.character(x)) htmltools::HTML(paste(x, collapse = "\n")) else x)))
      tete <- c(.dependances_inline(rt$dependencies), as.character(rt$head))
      corps <- as.character(rt$html)
    } else {
      corps <- paste(unlist(items), collapse = "\n")
    }
    c("<!DOCTYPE html>", "<html lang=\"fr\">", "<head>", "<meta charset=\"utf-8\">",
      sprintf("<title>Rapport USP fig\u00e9 \u2014 %s, calcul du %s</title>", m$methode,
              format(m$horodatage, "%Y-%m-%d %H:%M:%S")),
      "<style>", CSS_RAPPORT, "</style>", tete, "</head>", "<body>", corps, "</body>", "</html>")
  }

  doc <- tryCatch(assembler(construire(mode), mode), error = function(e) e)
  if (inherits(doc, "error")) {
    if (mode != "plotly") stop(doc)
    # Repli : dependances non integrables -> graphiques figes en PNG.
    note_mode <- paste0("Graphiques interactifs impossibles \u00e0 int\u00e9grer (",
                        .echap_html(conditionMessage(doc)), ").")
    mode <- if (png_ok) "png" else "aucun"
    doc <- assembler(construire(mode), mode)
  }
  writeBin(charToRaw(enc2utf8(paste(doc, collapse = "\n"))), chemin)
  invisible(list(chemin = chemin, octets = file.info(chemin)$size, mode = mode,
                 n_lignes = nrow(tb), n_retenus = sum(retenu),
                 empreintes = empr[c("donnees", "resultat")]))
}
