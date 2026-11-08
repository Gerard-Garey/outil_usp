# Essai (c4) : data.frame vides constants, construits une fois au chargement
# (objets identiques a ceux que data.frame() rend a chaque appel ; R copie a l'ecriture).
.MW_DF_VIDE_J_N <- data.frame(j = integer(0), n_facteurs = integer(0))
.mw_exclues_vide <- function()
  list(colonnes = .MW_DF_VIDE_J_N, eligibles = 0L)
.mw_table_non_identifiables <- function(jni, I, J, jd, n_min) {
  jn <- sort(unique(jni[jni %in% 0:(J - 1) & I - jni >= n_min & !(jni %in% jd)]))
  if (length(jn))
    structure(list(j = as.integer(jn), n_facteurs = as.integer(I - jn)),
              row.names = seq_along(jn), class = "data.frame") else
    .MW_DF_VIDE_J_N
}
