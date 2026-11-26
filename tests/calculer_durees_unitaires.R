###############################################################################
#  tests/calculer_durees_unitaires.R  --  TABLE DES DUREES DES TESTS UNITAIRES
#
#  Ecrit tests/durees_unitaires.tsv, lue par tests/test_unitaires.R pour
#  repartir les fichiers en lots (--lot=k/n) et ordonner --parallele (issue
#  #561, Q-72-5 (a)). Procede rejouable : la table n'est jamais retouchee a la
#  main, elle se recalcule, sur de nouvelles executions de la CI, par
#      Rscript tests/calculer_durees_unitaires.R ID [ID ...]
#  avec l'identifiant de chaque execution de ci.yml (nombre apres /runs/ dans
#  l'adresse de l'execution sur GitHub). Options :
#      --depot=proprietaire/nom   (defaut : Gerard-Garey/outil_usp)
#      --sortie=chemin            (defaut : durees_unitaires.tsv a cote du dossier
#                                  unitaires/ resolu depuis ce script, soit
#                                  tests/durees_unitaires.tsv, comme le lit
#                                  tests/test_unitaires.R)
#  Prerequis : la commande gh (GitHub CLI), authentifiee, et l'acces reseau ;
#  R base uniquement. Aucun calcul du moteur, aucun tirage.
#
#  Procede :
#   1. Pour chaque execution, les jobs Tests unitaires (lot k/n), listes sans
#      filtre de conclusion (gh api .../runs/ID/jobs) ; n est lu dans le nom des
#      jobs. L'execution n'est acceptee que si les n lots 1/n a n/n sont tous
#      presents et tous termines avec succes ; sinon (aucun lot : commit sans
#      moteur ; lot en echec, en cours, annule ou manquant) elle est refusee par
#      un message : un lot en echec retire ses fichiers de la moyenne et fausse,
#      selon l'execution, la regle de la coupe (etape 4).
#   2. Pour chaque job, son journal (gh api .../jobs/ID/logs) : les lignes
#      ##### [i/n] fichier.R : OK, N assertions, X s du lanceur en mode
#      --parallele ; X est la duree du fichier sous quatre processus.
#   3. Duree d'un fichier = moyenne arithmetique de ses X sur les executions
#      (une execution par fichier et par lot : un fichier est dans un lot et
#      un seul). Un fichier en echec (ECHEC) dans une execution n'est pas
#      retenu pour cette execution.
#   4. Fichiers issus d'une coupe (PARTAGE ci-dessous) : tant que les journaux
#      ne contiennent aucune partie, la duree du fichier d'origine est repartie
#      entre ses parties au prorata d'une mesure locale (PARTAGE, ci-dessous) ;
#      des que les journaux contiennent les parties
#      (executions posterieures a la coupe), la regle est sans objet et les
#      durees sont celles mesurees. Ne pas melanger dans un meme appel des
#      executions d'avant et d'apres la coupe : la moyenne d'un fichier
#      d'origine mesure en un bloc et en une partie n'aurait pas de sens ; le
#      script le refuse (erreur) quand, pour une origine, une execution porte
#      des parties et une autre n'en porte aucune.
#   5. Controle : chaque fichier tests/unitaires/test_*.R du disque a une
#      duree, et chaque ligne ecrite correspond a un fichier du disque ; sinon
#      erreur, jamais de repli silencieux.
#  La table est ecrite par duree decroissante, nom croissant a egalite ; son
#  en-tete consigne les executions et leur nombre.
###############################################################################

DEPOT_DEFAUT <- "Gerard-Garey/outil_usp"

# Fichiers issus d'une coupe (issue #561, etape 4 de S8) : pour chaque fichier
# d'origine, ses parties (la premiere garde le nom de l'origine) et la fraction
# de sa duree portee par chacune. Fractions = duree de chaque partie rapportee a
# la somme des durees des parties, relevee dans une meme execution du lanceur
# sur les six parties (Rscript tests/test_unitaires.R --parallele
# --fichiers=...), quatre processus, R 4.3.3, 4 coeurs, 26/11/2026 :
#   test_controles_entree.R   104,5 s et 116,9 s (somme 221,4 s) ;
#   test_application.R        117,8 s et 108,2 s (somme 226,0 s) ;
#   test_p_mc_regime.R         70,7 s et  73,1 s (somme 143,8 s).
PARTAGE <- list(
  test_controles_entree.R = c(test_controles_entree.R = 0.472, test_controles_entree_partie_2.R = 0.528),
  test_application.R = c(test_application.R = 0.521, test_application_partie_2.R = 0.479),
  test_p_mc_regime.R = c(test_p_mc_regime.R = 0.492, test_p_mc_regime_partie_2.R = 0.508))

# Dossier des tests unitaires, resolu depuis le chemin du script (--file=, comme
# tests/test_unitaires.R), pas depuis le repertoire courant. Rscript code les
# espaces du chemin en ~+~ dans --file= : decodes avant tout usage.
script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
script <- gsub("~+~", " ", script, fixed = TRUE)
dossier <- if (length(script)) file.path(dirname(script[1L]), "unitaires") else
           if (dir.exists("tests/unitaires")) "tests/unitaires" else "unitaires"

arguments <- commandArgs(trailingOnly = TRUE)
depot <- DEPOT_DEFAUT
sortie <- file.path(dirname(dossier), "durees_unitaires.tsv")
ids <- character(0)
for (a in arguments) {
  if (grepl("^--depot=", a)) depot <- sub("^--depot=", "", a)
  else if (grepl("^--sortie=", a)) sortie <- sub("^--sortie=", "", a)
  else if (grepl("^[0-9]+$", a)) ids <- c(ids, a)
  else stop("Argument inconnu : ", a, "\nUsage : Rscript tests/calculer_durees_unitaires.R [--depot=p/n] [--sortie=chemin] ID [ID ...]")
}
if (!length(ids)) stop("Aucune execution : donner au moins un identifiant d'execution de ci.yml.")
if (anyDuplicated(ids)) stop("Identifiant d'execution repete : ", paste(ids[duplicated(ids)], collapse = " "))
if (!nzchar(Sys.which("gh"))) stop("La commande gh est introuvable.")

gh <- function(chemin, ...) {
  r <- suppressWarnings(system2("gh", c("api", chemin, ...), stdout = TRUE, stderr = TRUE))
  statut <- attr(r, "status")
  if (!is.null(statut) && statut != 0L)
    stop("gh api ", chemin, " : code ", statut, "\n", paste(utils::head(r, 5L), collapse = "\n"))
  r
}

RX_FICHIER <- "^[^ ]+ ##### \\[[0-9]+/[0-9]+\\] ([^ ]+[.]R) : (OK|ECHEC), [0-9]+ assertions, ([0-9.]+) s$"
mesures <- list()
for (id in ids) {
  # Tous les jobs de lot, sans filtre de conclusion : identifiant, nom, conclusion
  # (null tant que le job n'est pas termine).
  liste <- gh(sprintf("repos/%s/actions/runs/%s/jobs", depot, id), "--paginate",
              "--jq", shQuote('.jobs[] | select(.name | startswith("Tests unitaires (lot")) | [.id, .name, (.conclusion // "null")] | @tsv'))
  liste <- liste[nzchar(liste)]
  if (!length(liste)) stop("Execution ", id, " : aucun job Tests unitaires (lot k/n).")
  champs <- strsplit(liste, "\t")
  if (!all(lengths(champs) == 3L)) stop("Execution ", id, " : liste des jobs illisible : ", paste(liste, collapse = " | "))
  jobs <- vapply(champs, `[`, "", 1L)
  noms <- vapply(champs, `[`, "", 2L)
  conclusions <- vapply(champs, `[`, "", 3L)
  rx_lot <- "^Tests unitaires \\(lot ([0-9]+)/([0-9]+)\\)$"
  if (!all(grepl(rx_lot, noms))) stop("Execution ", id, " : nom de job de lot illisible : ", paste(noms[!grepl(rx_lot, noms)], collapse = " | "))
  lot_k <- as.integer(sub(rx_lot, "\\1", noms))
  lot_n <- as.integer(sub(rx_lot, "\\2", noms))
  if (length(unique(lot_n)) != 1L) stop("Execution ", id, " : nombres de lots discordants dans les noms de jobs : ", paste(noms, collapse = " | "))
  n_lots <- lot_n[1L]
  manquants <- setdiff(seq_len(n_lots), lot_k)
  if (anyDuplicated(lot_k) || any(lot_k < 1L | lot_k > n_lots))
    stop("Execution ", id, " : numeros de lot incoherents avec n = ", n_lots, " : ", paste(noms, collapse = " | "))
  if (length(manquants))
    stop("Execution ", id, " refusee : lot(s) ", paste0(manquants, "/", n_lots, collapse = ", "), " absent(s) de la liste des jobs.")
  pas_reussis <- conclusions != "success"
  if (any(pas_reussis))
    stop("Execution ", id, " refusee : lot(s) non termine(s) avec succes (",
         paste0(lot_k[pas_reussis], "/", n_lots, " : ", conclusions[pas_reussis], collapse = ", "),
         "). Une execution n'est acceptee que si ses ", n_lots, " lots ont reussi.")
  for (j in jobs) {
    journal <- gh(sprintf("repos/%s/actions/jobs/%s/logs", depot, j))
    m <- regmatches(journal, regexec(RX_FICHIER, journal, useBytes = TRUE))
    m <- Filter(length, m)
    if (!length(m)) stop("Execution ", id, ", job ", j, " : aucune ligne de fichier dans le journal.")
    mesures[[length(mesures) + 1L]] <- data.frame(
      execution = id, fichier = vapply(m, `[`, "", 2L), statut = vapply(m, `[`, "", 3L),
      duree = as.numeric(vapply(m, `[`, "", 4L)), stringsAsFactors = FALSE)
  }
}
mesures <- do.call(rbind, mesures)
mesures <- mesures[mesures$statut == "OK", ]
if (anyDuplicated(mesures[c("execution", "fichier")]))
  stop("Un fichier figure deux fois dans une meme execution : ", paste(unique(mesures$fichier[duplicated(mesures[c("execution", "fichier")])]), collapse = " "))
moy <- tapply(mesures$duree, mesures$fichier, mean)
# Rapport de chaque duree a la moyenne de son fichier (avant toute repartition) :
# sert a l'en-tete de la table.
rapport <- mesures$duree / moy[mesures$fichier]

# Fichiers du disque (nom, comme le lanceur), dossier resolu plus haut ; sans
# dossier ou sans fichier test_*.R, erreur.
if (!dir.exists(dossier)) stop("Dossier des tests unitaires introuvable : ", dossier)
disque <- sort(basename(list.files(dossier, pattern = "^test_.*[.]R$")))
if (!length(disque)) stop("Aucun fichier test_*.R dans ", dossier)

# Coupes : repartition au prorata tant que les parties ne sont pas dans les journaux.
partage_applique <- character(0)
for (o in names(PARTAGE)) {
  p <- PARTAGE[[o]]
  autres <- setdiff(names(p), o)
  # Executions qui portent l'origine ou l'une de ses parties : toutes doivent
  # porter des parties, ou aucune (jamais un fichier entier moyenne avec une moitie).
  concernees <- unique(mesures$execution[mesures$fichier %in% names(p)])
  avec_parties <- vapply(concernees, function(e) any(autres %in% mesures$fichier[mesures$execution == e]), NA)
  if (any(avec_parties) && !all(avec_parties))
    stop("Executions d'avant et d'apres la coupe de ", o, " melangees : parties presentes dans ",
         paste(concernees[avec_parties], collapse = " "), ", absentes de ",
         paste(concernees[!avec_parties], collapse = " "),
         ". Donner des executions toutes anterieures, ou toutes posterieures, a la coupe.")
  if (any(autres %in% names(moy))) next
  if (!o %in% names(moy)) stop("Fichier d'origine ", o, " absent des journaux : coupe non repartissable.")
  if (abs(sum(p) - 1) > 1e-9) stop("Fractions de ", o, " : somme ", sum(p), " au lieu de 1.")
  d <- unname(moy[o])
  for (nom in names(p)) moy[nom] <- d * p[[nom]]
  partage_applique <- c(partage_applique, o)
}

absents <- setdiff(disque, names(moy))
en_trop <- setdiff(names(moy), disque)
if (length(absents)) stop("Fichier(s) du disque sans duree dans les journaux : ", paste(absents, collapse = " "))
if (length(en_trop)) cat("Fichier(s) des journaux absent(s) du disque, non ecrit(s) :", paste(en_trop, collapse = " "), "\n")
moy <- moy[disque]
ordre <- order(-round(moy, 1), names(moy), method = "radix")
moy <- moy[ordre]
if (any(round(moy, 1) <= 0)) stop("Duree nulle apres arrondi : ", paste(names(moy)[round(moy, 1) <= 0], collapse = " "))

entete <- c(
  "# Durees des fichiers de tests/unitaires/ (secondes), lues par tests/test_unitaires.R",
  "# pour repartir les fichiers en lots (--lot=k/n, LPT) et pour ordonner --parallele",
  "# (plus longs d'abord). Format : nom du fichier, tabulation, duree ; les lignes",
  "# vides et les lignes commencant par # sont ignorees. Un fichier absent de cette",
  "# table prend 60 s ; une ligne sans fichier sur le disque est ignoree.",
  "# FICHIER ECRIT PAR tests/calculer_durees_unitaires.R (procede decrit en tete de",
  "# ce script, rejouable ; ne pas retoucher a la main). Une ligne par fichier",
  "# tests/unitaires/test_*.R.",
  "# Source (issue #561) : moyenne, fichier par fichier, des durees lues dans les",
  "# journaux des jobs Tests unitaires (lot k/n), ligne ##### [i/n] fichier : OK,",
  sprintf("# N assertions, X s (quatre processus par lot), de %d executions reussies de", length(ids)),
  sprintf("# ci.yml : %s.", paste(ids, collapse = ", ")),
  if (length(ids) > 1L) c(
    sprintf("# Rapport de la duree d'un fichier a sa moyenne, sur ces executions : de %s a %s ;",
            format(floor(round(min(rapport) * 10, 6)) / 10, nsmall = 1L, decimal.mark = ","),
            format(ceiling(round(max(rapport) * 10, 6)) / 10, nsmall = 1L, decimal.mark = ",")),
    "# la moyenne attenue cette variation sans l'annuler."))
if (length(partage_applique)) {
  entete <- c(entete,
    "# Fichiers coupes depuis ces executions (issue #561) : la duree du fichier",
    "# d'origine y est repartie entre ses parties au prorata de leurs durees dans une",
    "# meme execution locale du lanceur (PARTAGE, dans le script) ; elle se remplace",
    "# par la mesure des journaux a la prochaine mise a jour sur des executions",
    "# posterieures a la coupe. Parties concernees :",
    sprintf("#   %s.", unlist(lapply(partage_applique, function(o) paste(names(PARTAGE[[o]]), collapse = ", ")))))
}
lignes <- sprintf("%s\t%.1f", names(moy), moy)
writeLines(c(entete, lignes), sortie, useBytes = TRUE)
cat(sprintf("%s : %d fichiers, %d executions, somme %.1f s.\n", sortie, length(lignes), length(ids), sum(round(moy, 1))))
