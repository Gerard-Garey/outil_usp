###############################################################################
#  .github/actions/blas-reference/controle_blas.R
#
#  Controle de l'action composite blas-reference (ci.yml, references.yml ;
#  M34, ADR 0011 amende) : echoue (code 1), avant tout calcul, si R ne
#  charge pas le BLAS et le LAPACK de reference d'Ubuntu 22.04.
#
#  Criteres, sur extSoftVersion()["BLAS"], sessionInfo()$BLAS,
#  sessionInfo()$LAPACK et La_library() :
#    - aucun chemin vide ;
#    - aucun BLAS optimise (openblas, mkl, atlas, blis, flexiblas) ;
#    - BLAS : ^/usr/lib/x86_64-linux-gnu/blas/libblas\.so (paquet libblas3) ;
#    - LAPACK : ^/usr/lib/x86_64-linux-gnu/lapack/liblapack\.so (paquet
#      liblapack3) ;
#    - La_version() == "3.10.0" (LAPACK de reference d'Ubuntu 22.04).
#  Le BLAS ou le LAPACK interne de R (libRblas, libRlapack) est REFUSE : un R
#  compile avec eux serait un changement de plateforme de calcul, qui passe
#  par une bascule (M34, point 3), pas un cas a accepter en silence.
#
#  Source avec CONTROLE_BLAS_SOURCE=1, le fichier ne fait que definir
#  defauts_blas() (verification sur chemins simules).
###############################################################################

LA_VERSION_ATTENDUE <- "3.10.0"
MOTIF_BLAS   <- "^/usr/lib/x86_64-linux-gnu/blas/libblas\\.so"
MOTIF_LAPACK <- "^/usr/lib/x86_64-linux-gnu/lapack/liblapack\\.so"
MOTIF_OPTIMISE <- "openblas|mkl|atlas|blis|flexiblas"

# v : vecteur nomme des quatre chemins (deux BLAS puis deux LAPACK, dans cet
# ordre) ; la_version : La_version(). Renvoie les defauts (vide si conforme).
defauts_blas <- function(v, la_version) {
  v[is.na(v)] <- ""
  motifs <- c(MOTIF_BLAS, MOTIF_BLAS, MOTIF_LAPACK, MOTIF_LAPACK)
  defauts <- character(0)
  for (i in seq_along(v)) {
    if (!nzchar(v[[i]]))
      defauts <- c(defauts, sprintf("%s : chemin vide", names(v)[i]))
    else if (grepl(MOTIF_OPTIMISE, v[[i]], ignore.case = TRUE))
      defauts <- c(defauts, sprintf("%s : BLAS optimise (%s)", names(v)[i], v[[i]]))
    else if (!grepl(motifs[i], v[[i]]))
      defauts <- c(defauts, sprintf("%s : bibliotheque inattendue (%s)", names(v)[i], v[[i]]))
  }
  if (!identical(la_version, LA_VERSION_ATTENDUE))
    defauts <- c(defauts, sprintf("La_version() : %s au lieu de %s", la_version, LA_VERSION_ATTENDUE))
  defauts
}

if (!nzchar(Sys.getenv("CONTROLE_BLAS_SOURCE"))) {
  si <- sessionInfo()
  v <- c(
    "extSoftVersion()[\"BLAS\"]" = unname(extSoftVersion()["BLAS"]),
    "sessionInfo()$BLAS"         = if (is.null(si$BLAS)) "" else si$BLAS,
    "sessionInfo()$LAPACK"       = if (is.null(si$LAPACK)) "" else si$LAPACK,
    "La_library()"               = La_library()
  )
  cat("R :", R.version.string, "\n")
  cat("La_version() :", La_version(), "\n")
  cat("OPENBLAS_NUM_THREADS :", Sys.getenv("OPENBLAS_NUM_THREADS", "(non defini)"), "\n")
  for (k in names(v)) cat(sprintf("%-26s %s\n", k, v[[k]]))
  defauts <- defauts_blas(v, La_version())
  if (length(defauts)) {
    cat("\nBLAS / LAPACK NON CONFORMES (BLAS et LAPACK de reference d'Ubuntu 22.04 attendus) :\n",
        paste0("  ", defauts, "\n"), sep = "")
    cat("::error title=BLAS non conforme::", paste(defauts, collapse = " ; "), "\n", sep = "")
    quit(status = 1L)
  }
  cat("\nBLAS et LAPACK de reference charges par R.\n")
}
