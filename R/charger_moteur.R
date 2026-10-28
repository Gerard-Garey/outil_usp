###############################################################################
#  R/charger_moteur.R  --  CHARGEUR DU MOTEUR (aucune logique quantitative)
#
#  Charge R/engine.R dans un environnement dedie, "usp_moteur", dont la chaine
#  de resolution des noms est fermee (ADR 0016, issue #200) :
#
#      usp_moteur  ->  imports:usp_moteur (exports de stats)  ->  base
#                  ->  environnement vide
#
#  Ni l'environnement global ni le chemin de recherche n'y figurent : un objet
#  de l'utilisateur (fonction c(), intersect(), pi...) ou un paquet attache
#  avant ou apres le chargement ne detourne plus le moteur. Un nom que le
#  moteur ne trouve ni en lui-meme, ni dans stats, ni dans base leve une
#  erreur au lieu de retomber en silence sur l'environnement global.
#
#  Usage (application, tests, revue independante) :
#      source("R/charger_moteur.R")
#      charger_moteur()                  # expose run_engine() et le moteur
#      res <- run_engine(...)
#
#  Exposition : chaque liaison du moteur (noms a point compris) est COPIEE
#  dans `dans` (par defaut l'environnement appelant), sans attach(). Les
#  fonctions copiees gardent pour enclos l'environnement du moteur : leurs
#  appels internes ne voient jamais `dans`. Une substitution de test se pose
#  donc dans environment(run_engine), jamais dans l'environnement global.
#  dans = NULL charge sans rien exposer (comparaison de deux versions).
#
#  Le chargeur n'appelle que des fonctions de base et son enclos est baseenv() :
#  un homonyme de l'environnement global ne le detourne pas lui-meme.
#  R/engine.R n'en depend pas et reste chargeable par source() (lecture du
#  code, point isole en session vierge), mais il est alors expose aux
#  homonymes de l'environnement global (#200).
###############################################################################

charger_moteur <- function(fichier = "R/engine.R", dans = parent.frame()) {
  if (!is.character(fichier) || length(fichier) != 1L || is.na(fichier) ||
      !nzchar(fichier))
    stop("charger_moteur() : `fichier` doit etre un chemin (chaine unique).",
         call. = FALSE)
  if (!file.exists(fichier))
    stop(sprintf("charger_moteur() : fichier introuvable : %s", fichier),
         call. = FALSE)
  if (!is.null(dans) && !is.environment(dans))
    stop("charger_moteur() : `dans` doit etre NULL ou un environnement.",
         call. = FALSE)
  # Environnement d'imports : exports de stats, parent base (chaine fermee).
  imports <- new.env(parent = baseenv())
  attr(imports, "name") <- "imports:usp_moteur"
  ns_stats <- asNamespace("stats")
  noms_stats <- getNamespaceExports(ns_stats)
  importIntoEnv(imports, noms_stats, ns_stats, noms_stats)
  # Environnement du moteur.
  moteur <- new.env(parent = imports)
  attr(moteur, "name") <- "usp_moteur"
  # keep.source = FALSE : meme etat que les executions par Rscript (CI,
  # references), ou source() ne garde pas non plus les sources.
  sys.source(fichier, envir = moteur, keep.source = FALSE)
  if (!is.null(dans)) {
    for (nom in ls(moteur, all.names = TRUE, sorted = TRUE))
      assign(nom, get(nom, envir = moteur, inherits = FALSE), envir = dans)
  }
  invisible(moteur)
}
charger_moteur <- base::`environment<-`(charger_moteur, baseenv())
