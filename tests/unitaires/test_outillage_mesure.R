###############################################################################
#  tests/unitaires/test_outillage_mesure.R  --  REPRISE, COMBINAISON ET
#  OUTILLAGE D'EXECUTION DES MESURES HORS CI (issue #248)
#
#  Sans calcul de mesure : definitions extraites du script par parse()
#  (jamais execute en mode calcul), sorties de tranche factices ecrites dans
#  tempdir() et combinees par le script lui-meme (--combiner --reduit, sans
#  calcul long), scripts de tests/outillage/ lances sur des dossiers
#  temporaires avec un faux script de mesure. Constats de #248 :
#  (m1) reprise en mode tranche : echantillon regulier de lignes reprises
#       recalculees (lignes_recalcul_reprise()), une ligne interieure y
#       entre ; mode oracle inchange ;
#  (m2) --combiner refuse une p de #119 hors de [0, 1] ou illisible, lue sur
#       le champ brut (invariants_sortie()) ;
#  (j)  --combiner --journal exige une ligne unique "- Sortie <nom> : md5
#       <md5>" de md5 egal a celui du fichier ; controler_md5.sh, meme regle ;
#  (s)  synchroniser_sauvegarde.sh signale un md5 du JOURNAL perime (sortie
#       regeneree ou partielle) ou des lignes multiples, et ne copie pas la
#       sortie ;
#  (l)  lancer_tranches.sh : verrou par sortie, une relance en parallele ne
#       renomme pas une sortie en ecriture ; verrou perime repris ;
#  (o)  --combiner --sortie : ecriture par lot, une erreur en cours
#       d'ecriture (file.copy() rendu defaillant par un profil R) ne laisse
#       aucun fichier.
#  Constats de #309 (tests/puissance_mw_t8.R, sans calcul de mesure) :
#  (p)  --lister : une ligne "nom<TAB>arguments" par sortie, nom et arguments
#       concordants (volet, loi ou plan, cellule, plage --b exacte, sans
#       correspondance de prefixe), chaque (plan, cellule, b) ou (loi, b)
#       couvert une fois et une seule, aux effectifs R du plan complet ;
#  (q)  favorise_xy() (K-300, second complement du 19/10/2026) sur comptes
#       construits : a CEL4 ET a CEL6 au moins un seuil en faveur de X, aucun
#       des quatre couples en faveur de Y ;
#  (r)  eval_k0x() (K0-x) : test exact de Fisher bilateral, seuil 0,025 par
#       cellule, sur comptes construits (175 / 500 : p = 0,0559, tenu).
#  Les tests qui demandent bash (>= 4.3, wait -n) sont sautes, avec
#  message, s'il manque.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_outillage_mesure.R")

.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
.tests <- normalizePath(file.path(.dossier, ".."))
RACINE_DEPOT <- normalizePath(file.path(.tests, ".."))
SCRIPT_MW <- file.path(.tests, "calibration_mc_mw_t8.R")
OUTILLAGE <- file.path(.tests, "outillage")
RSCRIPT <- file.path(R.home("bin"), "Rscript")
TMP <- tempfile("outillage248_"); dir.create(TMP)

PID_FOND <- file.path(TMP, "pid_fond.txt")
# Nettoyage garanti (finally), meme si le fichier s'interrompt : si le
# lanceur de fond n'a pas ecrit son BILAN, arret de ce lanceur et du Rscript
# qu'il lance (pid lus dans PID_FOND et dans les verrous encore tenus du
# dossier TMP/lanceur ; un lanceur termine n'est jamais vise, ni un pid
# dont la ligne de commande ne cite pas TMP : il a pu etre recycle),
# attente de leur fin (10 s au plus), puis retrait de TMP.
nettoyer_tmp <- function() {
  b <- Sys.which("bash")
  console <- file.path(TMP, "lanceur1.txt")
  fini <- file.exists(console) && any(grepl("^BILAN", readLines(console, warn = FALSE)))
  if (nzchar(b) && file.exists(PID_FOND) && !fini) {
    pids <- unique(unlist(lapply(c(PID_FOND, Sys.glob(file.path(TMP, "lanceur", "*.verrou", "pid"))), function(f)
      suppressWarnings(readLines(f, warn = FALSE)))))
    pids <- paste(pids[grepl("^[0-9]+$", pids)], collapse = " ")
    if (nzchar(pids)) {
      # seuls les processus vivants dont la ligne de commande cite TMP sont
      # vises (pid recycle par un processus etranger : jamais tue)
      cmd <- sprintf(paste0("v=; for p in %s; do grep -qaF %s /proc/$p/cmdline 2>/dev/null && v=\"$v $p\"; done; ",
                            "[ -z \"$v\" ] && exit 0; kill $v 2>/dev/null; ",
                            "for i in $(seq 100); do a=0; for p in $v; do kill -0 $p 2>/dev/null && a=1; done; [ $a -eq 0 ] && exit 0; sleep 0.1; done"),
                     pids, shQuote(basename(TMP)))
      suppressWarnings(system2(b, c("-c", shQuote(cmd)), stdout = FALSE, stderr = FALSE))
    }
  }
  unlink(TMP, recursive = TRUE)
}

tryCatch({
  # Definitions de premier niveau du script (affectations "nom <- ..."), dans
  # l'ordre du fichier, sans executer le reste.
  extraire_defs <- function(f, noms) {
    env <- new.env(parent = globalenv())
    for (e in as.list(parse(f, keep.source = FALSE)))
      if (is.call(e) && identical(e[[1]], as.name("<-")) && is.name(e[[2]]) && as.character(e[[2]]) %in% noms) eval(e, env)
    manquants <- setdiff(noms, ls(env))
    if (length(manquants)) stop("definitions absentes du script : ", paste(manquants, collapse = ", "))
    env
  }
  code_de <- function(o) if (is.null(attr(o, "status"))) 0L else as.integer(attr(o, "status"))

  ## --- (m1) echantillon de recalcul a la reprise ------------------------------
  E1 <- extraire_defs(SCRIPT_MW, c("N_ECH_REPRISE_ORACLE", "N_ECH_REPRISE_TRANCHE", "N_ECH_REPRISE", "lignes_recalcul_reprise"))
  lrr <- E1$lignes_recalcul_reprise
  # Regle d'avant #248, mode oracle (reference de non-regression).
  oracle_avant <- function(b_ok) {
    bo <- sort(b_ok)
    unique(c(b_ok[length(b_ok)], bo[unique(round(seq(1, length(bo), length.out = min(50L, length(bo)))))]))
  }
  verifier("(m1) tranche, 3 lignes reprises : toutes recalculees, la ligne interieure b = 2 comprise",
           setequal(lrr(1:3, "tranche"), 1:3))
  verifier("(m1) tranche de 250 lignes : 10 lignes regulierement espacees, premiere et derniere comprises, interieures presentes",
           { x <- lrr(1:250, "tranche"); length(x) == 10L && all(c(1L, 250L) %in% x) && sum(x > 1L & x < 250L) == 8L })
  verifier("(m1) tranche, lignes reprises dans le desordre : la derniere lue est recalculee, echantillon sur les lignes triees",
           { x <- lrr(c(5L, 1L, 9L, 3L), "tranche"); x[1] == 3L && setequal(x, c(1L, 3L, 5L, 9L)) })
  verifier("(m1) oracle : regle d'avant #248 inchangee (1, 7, 50, 51, 20 000 lignes reprises, ordre quelconque)",
           all(vapply(list(1L, 1:7, 1:50, 1:51, 1:20000, c(40L, 2L, 17L, 33L)),
                      function(b) identical(lrr(b, "oracle"), oracle_avant(b)), logical(1))))
  verifier("(m1) sous-mesure N : derniere ligne reprise seule (aucun echantillon)",
           identical(lrr(c(1:40), "sm"), 40L))
  verifier("(m1) aucune ligne reprise : aucun recalcul force",
           identical(lrr(integer(0), "tranche"), integer(0)))
  verifier("(m1) le script calcule B_RECALC_FORCE par lignes_recalcul_reprise(bs[ok], MODE)",
           any(grepl("B_RECALC_FORCE <- lignes_recalcul_reprise(bs[ok], MODE)", readLines(SCRIPT_MW), fixed = TRUE)))

  ## --- Sorties de tranche factices (combinees par le script) --------------------
  E2 <- extraire_defs(SCRIPT_MW, c("NL_MAX", "CLES", "NS", "QUEUE", "COLS_TRANCHE", "CLES_CONTEXTE", "ecart_journal_sortie"))
  EMP <- strrep("ab", 16)
  # Sortie de tranche terminee, INTEGRITE OK, n triangles admis aux p sur la
  # grille ; p119 : valeurs (caractere) de p_agr par ligne ; p_ceff idem.
  factice <- function(f, n = 3L, p_agr = rep("0.5", n), p_ceff = rep("0.5", n)) {
    ctx <- stats::setNames(rep("factice", length(E2$CLES_CONTEXTE)), E2$CLES_CONTEXTE)
    ctx[c("mode", "loi", "essai")] <- c("tranche", "N", "oui")
    ctx[["lignes"]] <- paste(sprintf("ligne %d", seq_len(E2$NL_MAX)), collapse = " ; ")
    ctx[["cle_ligne"]] <- paste(sprintf("%s=%d", E2$CLES, seq_along(E2$CLES)), collapse = " ; ")
    ctx[["empreinte_sc"]] <- sprintf("%s (md5 du fichier entier %s)", EMP, EMP)
    rep_l <- vapply(seq_len(n), function(b) {
      v <- stats::setNames(rep("NA", length(E2$COLS_TRANCHE)), E2$COLS_TRANCHE)
      v[c("b", "statut", "motif", "jd", "brut", "dur_R", "duree", "t_agr", "t_ceff")] <- c(b, "admis", "-", "-", "non", "1.000", "1.000", "0.5", "0.5")
      v[["p_agr"]] <- p_agr[b]; v[["p_ceff"]] <- p_ceff[b]
      v[c("verd_R", "verd_B", "nat_R", "nat_B")] <- c(strrep("O", E2$NL_MAX), "-", strrep("m", E2$NL_MAX), "-")
      for (s in E2$CLES) v[paste0(c("obs:", "pR:", "eR:", "BR:", "mR:", "mB:"), s)] <- c("1", "0.5", "0.01", "999", "-", "-")
      paste(c("REP", v), collapse = "\t")
    }, "")
    l <- c("PARAMETRES\tmode=tranche;loi=N;B=999;factice", sprintf("TRANCHE\t1\t%d\tredresse", n),
           sprintf("CONTEXTE\t%s\t%s", names(ctx), ctx), paste0("CLES\t", paste(sprintf("%s=%s", E2$CLES, E2$QUEUE), collapse = "\t")),
           paste0("COLS\t", paste(E2$COLS_TRANCHE, collapse = "\t")), rep_l, "",
           "DUREE\t1.000\t2.000", "INTEGRITE\tOK", sprintf("NLIG\t%d", n), sprintf("FIN\t%d", n))
    con <- file(f, open = "wb"); writeLines(l, con); close(con)
    unname(tools::md5sum(f))
  }
  dossier_factice <- function(nom, ...) {
    d <- file.path(TMP, nom); dir.create(d)
    m <- factice(file.path(d, "tranche-N-0001-0003.txt"), ...)
    list(d = d, nom = "tranche-N-0001-0003.txt", md5 = m)
  }
  journal <- function(f, lignes) {
    writeLines(c("# JOURNAL factice", "- Debit : factice", sprintf("- Empreinte sans commentaires : %s", EMP), lignes), f)
    f
  }
  combiner <- function(args, profil = NULL) {
    ancien <- setwd(RACINE_DEPOT); on.exit(setwd(ancien))
    if (!is.null(profil)) {
      avant <- Sys.getenv("R_PROFILE_USER", unset = NA)
      Sys.setenv(R_PROFILE_USER = profil)
      on.exit(if (is.na(avant)) Sys.unsetenv("R_PROFILE_USER") else Sys.setenv(R_PROFILE_USER = avant), add = TRUE)
    }
    suppressWarnings(system2(RSCRIPT, c(shQuote(SCRIPT_MW), "--combiner", args), stdout = TRUE, stderr = TRUE))
  }

  F0 <- dossier_factice("ok")
  o <- combiner(c(shQuote(F0$d), "--reduit"))
  verifier("Sortie factice conforme : combinee sans refus (--combiner --reduit, code 0)",
           code_de(o) == 0L && !any(grepl("REFUS", o, fixed = TRUE)))

  ## --- (m2) p de #119 hors de [0, 1] --------------------------------------------
  for (cas in list(list(nom = "p_agr = 1.5", p_agr = c("0.5", "1.5", "0.5"), col = "p_agr"),
                   list(nom = "p_ceff = -0.25", p_ceff = c("0.5", "0.5", "-0.25"), col = "p_ceff"),
                   list(nom = "p_agr = Inf", p_agr = c("Inf", "0.5", "0.5"), col = "p_agr"),
                   # valeurs corrompues non numeriques : as.numeric() en
                   # ferait NA, lues avant toute conversion (revue finale)
                   list(nom = "p_agr = 0,7", p_agr = c("0.5", "0,7", "0.5"), col = "p_agr"),
                   list(nom = "p_ceff = 1.5x", p_ceff = c("0.5", "1.5x", "0.5"), col = "p_ceff"),
                   list(nom = "p_agr = abc", p_agr = c("0.5", "0.5", "abc"), col = "p_agr"),
                   list(nom = "p_agr = NaN", p_agr = c("0.5", "NaN", "0.5"), col = "p_agr"))) {
    Fm <- do.call(dossier_factice, c(list(nom = paste0("m2_", make.names(cas$nom))), cas[intersect(names(cas), c("p_agr", "p_ceff"))]))
    o <- combiner(c(shQuote(Fm$d), "--reduit"))
    verifier(sprintf("(m2) ligne interieure a %s : --combiner refuse (code 1), invariant qui nomme la colonne", cas$nom),
             code_de(o) == 1L && any(grepl(sprintf("p hors de [0, 1] ou illisible (%s)", cas$col), o, fixed = TRUE)))
  }
  verifier("(m2) p_agr = 0 et 1 (bornes), NA (marqueur d'absence) ; p_ceff 1e-05 et 7.0041235189596963e-10 (forme %.17g) : admises",
           { Fb <- dossier_factice("m2_bornes", p_agr = c("0", "1", "NA"), p_ceff = c("1e-05", "7.0041235189596963e-10", "0.5"))
             code_de(combiner(c(shQuote(Fb$d), "--reduit"))) == 0L })

  ## --- (j) ligne du JOURNAL d'une sortie ------------------------------------------
  ej <- E2$ecart_journal_sortie
  L_OK <- sprintf("- Sortie %s : md5 %s, terminee, INTEGRITE OK, synchronisee 2026-10-11T00:00:00Z", F0$nom, F0$md5)
  FAUX <- strrep("0", 32)
  verifier("(j) ecart_journal_sortie() : ligne unique au md5 du fichier, conforme (avec ou sans suite)",
           is.null(ej(c("x", L_OK), F0$nom, F0$md5)) && is.null(ej(sprintf("- Sortie %s : md5 %s", F0$nom, F0$md5), F0$nom, F0$md5)))
  verifier("(j) ecart_journal_sortie() : md5 du fichier cite ailleurs, ligne de la sortie a un autre md5 : refus",
           grepl("different de celui du fichier",
                 ej(c(sprintf("- Sortie %s : md5 %s", F0$nom, FAUX), sprintf("note : %s %s", F0$nom, F0$md5)), F0$nom, F0$md5)))
  verifier("(j) ecart_journal_sortie() : deux lignes de la sortie (meme md5), refus ; aucune ligne, refus",
           grepl("^2 ligne", ej(c(L_OK, L_OK), F0$nom, F0$md5)) &&
             grepl("^0 ligne", ej(sprintf("  %s", L_OK), F0$nom, F0$md5)) &&
             grepl("^0 ligne", ej(sprintf("- Sortie %s : md5 %s0", F0$nom, F0$md5), F0$nom, F0$md5)))
  verifier("(j) ecart_journal_sortie() : une sortie au nom prefixe d'une autre n'est pas confondue",
           grepl("^0 ligne", ej(sprintf("- Sortie %s.bak : md5 %s", F0$nom, F0$md5), F0$nom, F0$md5)))
  # Chaque JOURNAL de mesure #206 versionne (tous, sans dependre de leur
  # ordre ni de leur nombre de sorties) : au moins une ligne "- Sortie", et
  # chacune conforme (une seule ligne par sortie).
  verifier("(j) JOURNAL(aux) de mesure #206 versionne(s) (docs/tableaux) : au moins une ligne \"- Sortie\", toutes conformes",
           { fj <- list.files(file.path(RACINE_DEPOT, "docs", "tableaux"), pattern = "issue206-journal-mesure\\.md$", full.names = TRUE)
             length(fj) >= 1L && all(vapply(fj, function(f) {
               jl <- readLines(f, warn = FALSE, encoding = "UTF-8")
               m <- Filter(length, regmatches(jl, regexec("^- Sortie (\\S+) : md5 ([0-9a-f]{32})", jl)))
               length(m) >= 1L && all(vapply(m, function(x) is.null(ej(jl, x[2], x[3])), logical(1)))
             }, logical(1))) })
  J_OK <- journal(file.path(TMP, "J_ok.md"), L_OK)
  J_AILLEURS <- journal(file.path(TMP, "J_ailleurs.md"), c(sprintf("- Sortie %s : md5 %s", F0$nom, FAUX), sprintf("note : %s %s", F0$nom, F0$md5)))
  J_DOUBLE <- journal(file.path(TMP, "J_double.md"), c(L_OK, L_OK))
  verifier("(j) --combiner --journal, ligne conforme : accepte (code 0)",
           code_de(combiner(c(shQuote(F0$d), "--reduit", "--journal", shQuote(J_OK)))) == 0L)
  verifier("(j) --combiner --journal, md5 cite hors de la ligne de la sortie, ligne a un autre md5 : refus (code 1)",
           { o <- combiner(c(shQuote(F0$d), "--reduit", "--journal", shQuote(J_AILLEURS)))
             code_de(o) == 1L && any(grepl("different de celui du fichier", o, fixed = TRUE)) })
  verifier("(j) --combiner --journal, ligne de la sortie en double : refus (code 1)",
           { o <- combiner(c(shQuote(F0$d), "--reduit", "--journal", shQuote(J_DOUBLE)))
             code_de(o) == 1L && any(grepl("2 ligne(s) \"- Sortie", o, fixed = TRUE)) })

  ## --- (o) --combiner --sortie : ecriture par lot --------------------------------
  fichiers_lot <- function(d) list.files(d, all.files = TRUE, no.. = TRUE)
  OUT1 <- file.path(TMP, "sortie_ok"); dir.create(OUT1); BRUT1 <- file.path(TMP, "brut_ok.tsv")
  o <- combiner(c(shQuote(F0$d), "--reduit", "--journal", shQuote(J_OK), "--sortie", shQuote(OUT1), "--brut", shQuote(BRUT1)))
  verifier("(o) --sortie et --brut sans erreur : cinq fichiers ecrits, copie brute ecrite, aucun temporaire restant",
           { f <- fichiers_lot(OUT1)
             code_de(o) == 0L && length(f) == 5L && all(grepl("^[0-9]{8}-issue(206|119)-", f)) && file.exists(BRUT1) &&
               !any(grepl("^\\.lot248-", fichiers_lot(TMP))) })
  verifier("(o) copie brute et fichier brut de --sortie identiques (md5), journal de la combinaison qui les cite",
           { fb <- file.path(OUT1, grep("calibration-mw-brut\\.tsv$", fichiers_lot(OUT1), value = TRUE))
             jc <- readLines(file.path(OUT1, grep("journal-combinaison\\.md$", fichiers_lot(OUT1), value = TRUE)), warn = FALSE)
             identical(unname(tools::md5sum(fb)), unname(tools::md5sum(BRUT1))) &&
               any(grepl(unname(tools::md5sum(fb)), jc, fixed = TRUE)) })
  # Profil R qui rend file.copy() defaillant pour la copie du JOURNAL (5e
  # fichier du lot, apres la copie --brut, la copie brute de --sortie et deux
  # tableaux).
  PROFIL <- file.path(TMP, "profil_echec.R")
  writeLines(c("local({", "  fc <- base::file.copy",
               "  assign(\"file.copy\", function(from, to, ...) if (any(grepl(\"journal-mesure\", to, fixed = TRUE))) FALSE else fc(from, to, ...),",
               "         envir = globalenv())", "})"), PROFIL)
  OUT2 <- file.path(TMP, "sortie_echec"); dir.create(OUT2); D_BRUT2 <- file.path(TMP, "brut_echec"); dir.create(D_BRUT2)
  BRUT2 <- file.path(D_BRUT2, "brut.tsv")
  o <- combiner(c(shQuote(F0$d), "--reduit", "--journal", shQuote(J_OK), "--sortie", shQuote(OUT2), "--brut", shQuote(BRUT2)), profil = PROFIL)
  verifier("(o) erreur en cours d'ecriture (copie du JOURNAL refusee) : refus (code 1) qui annonce l'annulation",
           code_de(o) == 1L && any(grepl("ecriture par lot annulee", o, fixed = TRUE)) && any(grepl("journal-mesure", o, fixed = TRUE)))
  verifier("(o) erreur en cours d'ecriture : aucun fichier dans --sortie ni a cote de --brut (ni cible, ni temporaire)",
           length(fichiers_lot(OUT2)) == 0L && length(fichiers_lot(D_BRUT2)) == 0L)

  ## --- Scripts shell de tests/outillage/ ------------------------------------------
  # Sous Windows, Sys.which("bash") peut trouver le bash de WSL (System32),
  # qui ne voit ni les chemins Windows ni Rscript : seul un bash Git Bash ou
  # MSYS (uname -s commencant par MINGW ou MSYS) est retenu, sinon saut.
  BASH <- Sys.which("bash")
  BASH_OK <- nzchar(BASH) && {
    v <- suppressWarnings(system2(BASH, c("-c", shQuote("echo ${BASH_VERSINFO[0]} ${BASH_VERSINFO[1]}")), stdout = TRUE, stderr = FALSE))
    v <- suppressWarnings(as.integer(strsplit(v[1], " ")[[1]]))
    length(v) == 2L && !anyNA(v) && (v[1] > 4L || (v[1] == 4L && v[2] >= 3L))
  } && {
    .Platform$OS.type != "windows" || {
      u <- suppressWarnings(system2(BASH, c("-c", shQuote("uname -s")), stdout = TRUE, stderr = FALSE))
      length(u) >= 1L && grepl("^(MINGW|MSYS)", u[1])
    }
  }
  sh <- function(script, args) {
    o <- suppressWarnings(system2(BASH, c(shQuote(file.path(OUTILLAGE, script)), args), stdout = TRUE, stderr = TRUE))
    list(o = o, code = code_de(o))
  }
  ecrire_sortie <- function(f, corps) { con <- file(f, open = "wb"); writeLines(c(corps, "INTEGRITE\tOK", "FIN\t1"), con); close(con) }
  if (BASH_OK) {
    ## (s) synchroniseur, essai a blanc (-n : aucune commande git)
    DS <- file.path(TMP, "sync"); WS <- file.path(TMP, "sync_wt"); dir.create(DS); dir.create(WS)
    writeLines("# JOURNAL", file.path(DS, "JOURNAL.md"))
    fs <- file.path(DS, "tranche-N-0001-0001.txt"); ecrire_sortie(fs, "REP\t1")
    m_av <- unname(tools::md5sum(fs))
    args_s <- c("-d", shQuote(DS), "-w", shQuote(WS), "-b", "claude/sauvegarde-test", "-c", "s", "-n")
    r1 <- sh("synchroniser_sauvegarde.sh", args_s)
    verifier("(s) premier passage : ligne du JOURNAL ajoutee, copie conforme (code 0)",
             r1$code == 0L && any(grepl(sprintf("^- Sortie tranche-N-0001-0001.txt : md5 %s, terminee", m_av), readLines(file.path(DS, "JOURNAL.md")))) &&
               identical(unname(tools::md5sum(file.path(WS, "s", "tranche-N-0001-0001.txt"))), m_av))
    ecrire_sortie(fs, "REP\t1 regeneree")
    r2 <- sh("synchroniser_sauvegarde.sh", args_s)
    verifier("(s) sortie regeneree apres synchronisation : PERIME signale (md5 du JOURNAL et du fichier), code 1",
             r2$code == 1L && any(grepl(sprintf("PERIME tranche-N-0001-0001.txt : JOURNAL %s, fichier %s", m_av, unname(tools::md5sum(fs))), r2$o, fixed = TRUE)))
    verifier("(s) sortie regeneree : copie de la sauvegarde inchangee (celle que cite le JOURNAL), JOURNAL inchange",
             identical(unname(tools::md5sum(file.path(WS, "s", "tranche-N-0001-0001.txt"))), m_av) &&
               sum(grepl("^- Sortie tranche-N-0001-0001.txt", readLines(file.path(DS, "JOURNAL.md")))) == 1L)
    # Sortie citee au JOURNAL, retiree puis relancee : partielle (sans FIN).
    con <- file(fs, open = "wb"); writeLines(c("PARAMETRES\tfaux", "COLS\tb"), con); close(con)
    r3s <- sh("synchroniser_sauvegarde.sh", args_s)
    verifier("(s) sortie citee au JOURNAL, relancee et encore partielle : PERIME signale, code 1",
             r3s$code == 1L && any(grepl(sprintf("PERIME tranche-N-0001-0001.txt : JOURNAL %s, fichier %s (sortie partielle", m_av, unname(tools::md5sum(fs))), r3s$o, fixed = TRUE)))
    verifier("(s) sortie partielle : la copie terminee de la sauvegarde n'est pas ecrasee, JOURNAL inchange",
             identical(unname(tools::md5sum(file.path(WS, "s", "tranche-N-0001-0001.txt"))), m_av) &&
               sum(grepl("^- Sortie tranche-N-0001-0001.txt", readLines(file.path(DS, "JOURNAL.md")))) == 1L)
    # Deux lignes identiques pour une sortie : meme regle que controler_md5.sh
    # et --combiner --journal (une ligne et une seule).
    DS2 <- file.path(TMP, "sync2"); WS2 <- file.path(TMP, "sync2_wt"); dir.create(DS2); dir.create(WS2)
    fs2 <- file.path(DS2, "a.txt"); ecrire_sortie(fs2, "REP\t1"); m2s <- unname(tools::md5sum(fs2))
    writeLines(c("# JOURNAL", rep(sprintf("- Sortie a.txt : md5 %s", m2s), 2)), file.path(DS2, "JOURNAL.md"))
    r4s <- sh("synchroniser_sauvegarde.sh", c("-d", shQuote(DS2), "-w", shQuote(WS2), "-b", "claude/sauvegarde-test", "-c", "s", "-n"))
    verifier("(s) deux lignes identiques \"- Sortie a.txt : md5 <md5>\" au JOURNAL : LIGNES MULTIPLES signale, sortie non copiee, code 1",
             r4s$code == 1L && any(grepl("LIGNES MULTIPLES a.txt : 2 lignes", r4s$o, fixed = TRUE)) &&
               !file.exists(file.path(WS2, "s", "a.txt")))

    ## (j) controler_md5.sh, meme regle que --combiner --journal
    DC <- file.path(TMP, "cmd5"); dir.create(DC)
    fc <- file.path(DC, "a.txt"); ecrire_sortie(fc, "REP\t1"); mc <- unname(tools::md5sum(fc))
    jc <- function(nom, l) { f <- file.path(TMP, nom); con <- file(f, open = "wb"); writeLines(l, con, sep = ""); close(con); f }
    cas_c <- list(list(nom = "ligne conforme", l = sprintf("- Sortie a.txt : md5 %s, terminee\n", mc), code = 0L, motif = "aucun ecart"),
                  list(nom = "ligne conforme, fin de ligne CRLF", l = sprintf("- Sortie a.txt : md5 %s\r\n", mc), code = 0L, motif = "aucun ecart"),
                  list(nom = "deux lignes de meme md5", l = rep(sprintf("- Sortie a.txt : md5 %s\n", mc), 2), code = 1L, motif = "LIGNES MULTIPLES a.txt"),
                  list(nom = "md5 cite hors debut de ligne", l = sprintf("note : - Sortie a.txt : md5 %s\n", mc), code = 1L, motif = "ABSENTE DU JOURNAL a.txt"),
                  list(nom = "md5 different", l = sprintf("- Sortie a.txt : md5 %s\n", FAUX), code = 1L, motif = "DIFFERENTE a.txt"))
    for (k in seq_along(cas_c)) {
      x <- cas_c[[k]]
      r <- sh("controler_md5.sh", c("-d", shQuote(DC), "-j", shQuote(jc(sprintf("Jc%d.md", k), x$l))))
      verifier(sprintf("(j) controler_md5.sh, %s : code %d", x$nom, x$code), r$code == x$code && any(grepl(x$motif, r$o, fixed = TRUE)))
    }

    ## (l) lanceur : relance en parallele, verrou perime
    FAUX_R <- file.path(TMP, "faux_mesure.R")
    writeLines(c("a <- commandArgs(trailingOnly = TRUE)", "f <- a[match(\"--sortie-tranche\", a) + 1L]",
                 "con <- file(f, open = \"wb\")", "writeLines(c(\"PARAMETRES\\tfaux\", \"COLS\\tb\"), con); flush(con)",
                 "Sys.sleep(if (file.exists(file.path(dirname(f), \"RAPIDE\"))) 0 else 4)",
                 "writeLines(c(\"REP\\t1\", \"INTEGRITE\\tOK\", \"NLIG\\t1\", \"FIN\\t1\"), con); close(con)"), FAUX_R)
    PLAN <- file.path(TMP, "plan.txt"); writeLines("tranche-N-0001-0001.txt\t--loi N --b 1:1 --pools redresse", PLAN)
    DL <- file.path(TMP, "lanceur"); dir.create(DL)
    sortie_l <- file.path(DL, "tranche-N-0001-0001.txt")
    args_l <- c("-p", shQuote(PLAN), "-d", shQuote(DL), "-s", shQuote(FAUX_R))
    CONSOLE1 <- file.path(TMP, "lanceur1.txt")
    # Lanceur de fond : son pid (celui du bash, que exec conserve) est ecrit
    # dans PID_FOND, pour l'arreter au nettoyage si le test s'interrompt.
    system2(BASH, c("-c", shQuote("echo $$ > \"$1\"; shift; exec bash \"$@\""), "_", shQuote(PID_FOND),
                    shQuote(file.path(OUTILLAGE, "lancer_tranches.sh")), args_l), stdout = CONSOLE1, stderr = CONSOLE1, wait = FALSE)
    t_lim <- Sys.time() + 20
    while (!file.exists(sortie_l) && Sys.time() < t_lim) Sys.sleep(0.1)
    r2 <- sh("lancer_tranches.sh", args_l)
    partiels_pendant <- grep("partiel", list.files(DL), value = TRUE)
    t_lim <- Sys.time() + 30
    while (!(file.exists(CONSOLE1) && any(grepl("^BILAN", readLines(CONSOLE1, warn = FALSE)))) && Sys.time() < t_lim) Sys.sleep(0.2)
    c1 <- readLines(CONSOLE1, warn = FALSE)
    verifier("(l) relance en parallele : la sortie en ecriture est sautee sans renommage (aucun .partielN), code 1 (non terminee)",
             r2$code == 1L && any(grepl("en cours dans un autre lanceur", r2$o, fixed = TRUE)) && !length(partiels_pendant))
    verifier("(l) premier lanceur : sortie terminee a son nom, INTEGRITE OK, verrou rendu, aucun .partielN",
             any(grepl("BILAN : toutes les sorties du plan sont terminees, INTEGRITE OK", c1, fixed = TRUE)) &&
               identical(utils::tail(readLines(sortie_l), 1L), "FIN\t1") && !dir.exists(paste0(sortie_l, ".verrou")) &&
               !length(grep("partiel", list.files(DL), value = TRUE)) && !dir.exists(file.path(DL, ".lanceur.mutex")))
    # Verrou perime : pid d'un processus termine, sortie partielle en place.
    DP <- file.path(TMP, "lanceur_perime"); dir.create(file.path(DP, "tranche-N-0001-0001.txt.verrou"), recursive = TRUE)
    writeLines("", file.path(DP, "RAPIDE"))
    pid_mort <- suppressWarnings(system2(BASH, c("-c", shQuote("echo $$")), stdout = TRUE))
    writeLines(pid_mort, file.path(DP, "tranche-N-0001-0001.txt.verrou", "pid"))
    writeLines(c("PARAMETRES\tfaux", "COLS\tb"), file.path(DP, "tranche-N-0001-0001.txt"))
    r3 <- sh("lancer_tranches.sh", c("-p", shQuote(PLAN), "-d", shQuote(DP), "-s", shQuote(FAUX_R)))
    verifier("(l) verrou perime (pid inactif) : signale, retire et repris ; partielle renommee puis reprise ; code 0",
             r3$code == 0L && any(grepl("verrou perime", r3$o, fixed = TRUE)) &&
               file.exists(file.path(DP, "tranche-N-0001-0001.txt.partiel1")) &&
               !dir.exists(file.path(DP, "tranche-N-0001-0001.txt.verrou")))
  } else {
    cat("  [saute] scripts de tests/outillage/ : bash >= 4.3 introuvable\n")
  }

  ## --- (p) puissance_mw_t8.R : plan des tranches (--lister), format du lanceur ----
  # Sans calcul : --lister n'ecrit rien et rend une ligne "nom<TAB>arguments"
  # par sortie (format de tests/outillage/lancer_tranches.sh). Plan complet de
  # #309 : volet A N 2 000, E 2 000, A 1 000 ; volet B P1 (13 cellules), P2
  # (6), P3 (3) aux R de la specification ; cinq oracles ; tranches de 250
  # triangles au plus. Pour chaque ligne, les arguments sont reconstruits a
  # partir du NOM (volet, loi ou plan, cellule, plage b1:b2) et compares par
  # identical() (une correspondance de prefixe, 1:250 contre 1:2500, echoue).
  SCRIPT_309 <- file.path(.tests, "puissance_mw_t8.R")
  pl309 <- suppressWarnings(system2(RSCRIPT, c(shQuote(SCRIPT_309), "--lister"), stdout = TRUE, stderr = TRUE))
  nm309 <- sub("\t.*$", "", pl309); ar309 <- sub("^[^\t]*\t", "", pl309)
  verifier("(p) --lister : une ligne \"nom<TAB>arguments\" par sortie, noms uniques et de la forme attendue (va-, vb-, ora-), code 0",
           is.null(attr(pl309, "status")) && all(grepl("\t", pl309)) && !anyDuplicated(nm309) &&
             all(grepl("^(va-[NEA]-[0-9]{4}-[0-9]{4}|vb-P[123]-[A-Za-z0-9]+-[0-9]{4}-[0-9]{4}|ora-(A-[NEA]|B-P[23]))\\.txt$", nm309)))
  args_attendus <- function(nm) {
    m <- regmatches(nm, regexec("^va-([NEA])-([0-9]{4})-([0-9]{4})\\.txt$", nm))[[1]]
    if (length(m)) return(sprintf("--volet A --loi %s --b %d:%d", m[2], as.integer(m[3]), as.integer(m[4])))
    m <- regmatches(nm, regexec("^vb-(P[123])-([A-Za-z0-9]+)-([0-9]{4})-([0-9]{4})\\.txt$", nm))[[1]]
    if (length(m)) return(sprintf("--volet B --plan %s --cellule %s --b %d:%d", m[2], m[3], as.integer(m[4]), as.integer(m[5])))
    m <- regmatches(nm, regexec("^ora-A-([NEA])\\.txt$", nm))[[1]]
    if (length(m)) return(sprintf("--oracle --volet A --loi %s", m[2]))
    m <- regmatches(nm, regexec("^ora-B-(P[23])\\.txt$", nm))[[1]]
    if (length(m)) return(sprintf("--oracle --volet B --plan %s", m[2]))
    NA_character_
  }
  verifier("(p) --lister : arguments identiques (identical(), plage --b exacte) a ceux reconstruits du nom, pour chacune des lignes",
           identical(unname(ar309), unname(vapply(nm309, args_attendus, ""))))
  # Couverture : jeu (loi du volet A, ou plan.cellule du volet B) -> effectif R attendu de la specification.
  R_attendu <- c(`A-N` = 2000L, `A-E` = 2000L, `A-A` = 1000L,
                 `P1-H0` = 1000L, `P1-CST20` = 1000L, `P1-EXP2` = 1000L, `P1-CEL4` = 1000L, `P1-CEL6` = 1000L,
                 `P1-CST10` = 500L, `P1-EXP0` = 500L, `P1-DFI` = 500L, `P1-CAL7` = 500L, `P1-CAL4` = 500L, `P1-DCAL` = 500L,
                 `P1-LIG` = 500L, `P1-CELx4` = 500L,
                 `P2-H0` = 1000L, `P2-CST20` = 1000L, `P2-EXP2` = 1000L, `P2-CST10` = 500L, `P2-EXP0` = 500L, `P2-DFI` = 500L,
                 `P3-H0` = 1000L, `P3-CST20` = 1000L, `P3-DFI` = 500L)
  tr309 <- grepl("^v[ab]-", nm309)
  jeu309 <- vapply(nm309[tr309], function(nm) {
    m <- regmatches(nm, regexec("^v[ab]-(.*)-[0-9]{4}-[0-9]{4}\\.txt$", nm))[[1]][2]
    if (startsWith(nm, "va-")) paste0("A-", m) else m }, "")
  bb309 <- do.call(rbind, lapply(regmatches(nm309[tr309], regexec("-([0-9]{4})-([0-9]{4})\\.txt$", nm309[tr309])), function(m) as.integer(m[2:3])))
  couv309 <- tapply(seq_along(jeu309), jeu309, function(i) sort(unlist(lapply(i, function(k) seq.int(bb309[k, 1], bb309[k, 2])))))
  verifier("(p) --lister : tranches de 250 triangles au plus ; chaque (plan, cellule, b) et (loi, b) couvert une fois et une seule, 1..R aux effectifs de la specification (25 jeux, 5 000 + 16 000 triangles) ; cinq oracles",
           all(bb309[, 2] - bb309[, 1] + 1L <= 250L) && setequal(names(couv309), names(R_attendu)) &&
             all(vapply(names(R_attendu), function(k) identical(as.integer(couv309[[k]]), seq_len(R_attendu[[k]])), logical(1))) &&
             sum(R_attendu[startsWith(names(R_attendu), "A-")]) == 5000L && sum(R_attendu[!startsWith(names(R_attendu), "A-")]) == 16000L &&
             sum(grepl("^ora-", nm309)) == 5L)

  ## --- (q) et (r) puissance_mw_t8.R : lectures de K-300 et de K0-x sur des comptes construits ---
  # Definitions extraites du script par parse() (jamais execute) : favorise_xy()
  # (second complement du 19/10/2026 : a CEL4 ET a CEL6 au moins un seuil donne
  # un McNemar exact < 0,05 en faveur de X, et aucun des quatre couples ne le
  # donne en faveur de Y) et eval_k0x() (Fisher bilateral, seuil 0,025 par cellule).
  E309 <- extraire_defs(SCRIPT_309, c("SEUILS", "IA", "CLASSES", "D_IC", "PUBLIE_K0X", "N_PUBLIE_K0X", "SEUIL_K0X", "num", "fmt_p", "ic_cp",
                                      "txt_ic", "txt_lec", "lecture", "cellule", "mcnemar", "mc_paire", "adm_de", "dec", "couples_paire",
                                      "favorise_xy", "eval_k0x"))
  # n triangles ; p_x, p_y : p_mc de X et de Y ; deux groupes discordants : k_x triangles ou seul X rejette a a (p = 0,03),
  # k_y ou seul Y rejette, le reste a 0,5.
  jeu_q <- function(n, k_x, k_y, p_rej = 0.03) {
    px <- py <- rep(0.5, n); px[seq_len(k_x)] <- p_rej; py[k_x + seq_len(k_y)] <- p_rej
    data.frame(statut = "admis", `p:MinP4` = px, `p:MinP` = py, check.names = FALSE, stringsAsFactors = FALSE)
  }
  ds309 <- function(c4_10, c4_05, c6_10, c6_05) {   # chaque argument : c(k_x, k_y)
    mk <- function(a, b) { x <- jeu_q(120, a[1], a[2], 0.03); y <- jeu_q(120, b[1], b[2], 0.08)
      # seuil 0,10 : p = 0,08 rejette a 0,10 et pas a 0,05 ; seuil 0,05 : p = 0,03 rejette aux deux
      rbind(y[, c("statut", "p:MinP4", "p:MinP")], x[, c("statut", "p:MinP4", "p:MinP")]) }
    list(tr = list(`B-P1.CEL4` = mk(c4_05, c4_10), `B-P1.CEL6` = mk(c6_05, c6_10)))
  }
  fav309 <- E309$favorise_xy
  environment(fav309) <- E309
  # MinP4 favorise a CEL4 aux deux seuils et a CEL6 au seuil 0,10 : favorise
  verifier("(q) favorise_xy : X favorise a CEL4 et a CEL6 (au moins un seuil chacune), Y jamais : TRUE",
           isTRUE(fav309(ds309(c(30, 2), c(30, 2), c(30, 2), c(0, 0)), "MinP4", "MinP")$ok))
  # Scenario de l'audit : X favorise a CEL4 au seuil 0,10 seulement, rien a CEL6 : FALSE
  verifier("(q) favorise_xy : X favorise a CEL4 / 0,10 seulement (rien a CEL6) : FALSE (MinP retenu)",
           isFALSE(fav309(ds309(c(30, 2), c(0, 0), c(0, 0), c(0, 0)), "MinP4", "MinP")$ok))
  # Un couple en faveur de Y suffit a empecher : FALSE
  # X reste favorise a CEL4 (0,10 et 0,05) et a CEL6 (0,10 : 62 contre 32) ; seul le couple CEL6 / 0,05 (2 contre 30) est en faveur de Y.
  verifier("(q) favorise_xy : sans le couple en faveur de Y, X est favorise (TRUE) ; avec le seul couple CEL6 / 0,05 en faveur de Y : FALSE",
           isTRUE(fav309(ds309(c(30, 2), c(30, 2), c(60, 2), c(0, 0)), "MinP4", "MinP")$ok) &&
             isFALSE(fav309(ds309(c(30, 2), c(30, 2), c(60, 2), c(2, 30)), "MinP4", "MinP")$ok))
  # k0x : 175 / 500 contre 401 / 1000 : Fisher p = 0,0559 >= 0,025, tenu ; 120 / 500 : p << 0,025, non tenu
  k0x309 <- E309$eval_k0x
  environment(k0x309) <- E309
  d_k0x <- function(k7, k4) { m <- function(k) data.frame(statut = "admis", `p:Calendrier` = c(rep(0.05, k), rep(0.5, 500 - k)), check.names = FALSE, stringsAsFactors = FALSE)
    list(tr = list(`B-P1.CAL7` = m(k7), `B-P1.CAL4` = m(k4))) }
  r1 <- k0x309(d_k0x(175L, 160L)); r2 <- k0x309(d_k0x(120L, 160L))
  verifier("(r) eval_k0x : CAL7 175 / 500 et CAL4 160 / 500 : Fisher p = 0,0559 et 1, K0-x tenu",
           isTRUE(r1$ok) && abs(r1$r[[1]]$p - 0.0559) < 5e-5 && abs(r1$r[[2]]$p - 1) < 1e-12)
  verifier("(r) eval_k0x : CAL7 120 / 500 : p < 0,025, K0-x non tenu",
           isFALSE(r2$ok) && r2$r[[1]]$p < 0.025)

}, finally = nettoyer_tmp())

fin_fichier()
