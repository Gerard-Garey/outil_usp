> *Rapport de l'agent coder (IA), fiche de base, étape 1 de K3b (rejeu des six constats, lecture seule), rendu le 12/11/2026. Versé intégralement par la session principale (Refs #537). Les scripts de rejeu et le prototype, restés dans le scratchpad de la session, ne sont pas versés.*

# K3b, étape 1 : rejeu des six constats (lecture seule)

Base : branche `claude/registre-restes`, `R/` et `tests/` identiques à `7d5e998` (`git diff --quiet 7d5e998 HEAD -- R tests` : vrai ; la tête a avancé de quatre commits `docs:` pendant le rejeu, sans effet sur les lignes citées). Aucun fichier suivi par Git modifié (`git status --short` vide en fin de rejeu). R 4.3.3, `LC_ALL=C.UTF-8`, `openxlsx` **absent** de la session (`requireNamespace("openxlsx")` : FALSE) : le chemin xlsx mesuré est le lecteur interne seul.

Scripts et sorties : `/tmp/claude-0/-home-user-outil-usp/9084d3be-6ccb-528b-9492-8366b2de2f0b/scratchpad/k3b-etape1/` (`rejeu_*.R`, `sortie_*.txt`, `corpus_add.R`, `refs_chaines.R`, `proto/`).

## Contrôle de base

`LC_ALL=C.UTF-8 Rscript tests/test_reproductibilite.R` sur la tête : `OK : reproductibilite et non-regression verifiees pour 6 cas.`, exit 0 ; six cas `CONFORME`, 0 non strictement identique, écart maximal 0.000e+00 (`base_repro.txt`). La batterie unitaire complète n'a **pas** été lancée sur la tête (seulement `test_statistiques.R` : 81/81 et `test_non_applicable.R` : 25/25).

## Prototype de mesure (scratchpad, jamais dans le dépôt)

Pour chiffrer les risques de #537, #535 et #536, une copie de `R/engine.R` (`proto/engine_proto.R`, diff dans `patch_proto.R`) porte : `format(val, digits = 17)` (#537), la variable `rang` posée par le bloc de hiérarchie (#535), l'aide `.motif_mc_indisponible()` (#536). Mesures :

| Mesure | Commande | Résultat |
|---|---|---|
| Corpus d'`add()` : 4800 appels (9 motifs × 3 types × p_ex × p_as × p_min × 5 détails × effectifs × mc_nom ; champs `detail`, `type`, `nature_p`, `verdict`, `inoperant`, `loi`, `p_retenue` et messages d'erreur) | `Rscript corpus_add.R <moteur> <rds>` sur la tête puis sur le prototype ; `identical()` des deux listes | **TRUE**, 0 cas différent ; couverture : 834 détails « m. », 160 « m, … non retenue. », 102 « m, aucune p-value disponible… », 34 « TEST INOPERANT … Monte-Carlo indisponible », 80 « test non applicable », 30 erreurs identiques (p_min avec p non simulée seule) |
| Batterie unitaire complète sur le prototype (racine copiée, `--parallele`) | `LC_ALL=C.UTF-8 Rscript tests/test_unitaires.R --parallele` | 3744 assertions, 3743 ok, **1 échec** : `test_registre_add.R` « C2 add() : p_ex = 1,7 et p_ex = -0,2 », causé par `digits = 17` (voir #537), aucun autre |
| Références sur le prototype | `LC_ALL=C.UTF-8 Rscript tests/test_reproductibilite.R` | six cas `CONFORME`, écart maximal 0.000e+00, exit 0 (`proto_repro.txt`) |

---

## #537 : message de refus d'une p hors de [0, 1]

**Constat : reproduit.** `R/engine.R` l. 4669-4677 (`verifier_p()` d'`add()`), l. 4675 : `format(val)`. Sortie (`rejeu_537.R`) :

```
val = 1.0000000010000001 -> add() : p-value hors de [0, 1] : p_ex = 1 (t)
val = -1.0000000000000001e-09 -> add() : p-value hors de [0, 1] : p_ex = -1e-09 (t)
val = 1.00000000001 -> ... p_ex = 1 (t)        (1 + 1e-11)
val = 1.000000000002 -> ... p_ex = 1 (t)       (1 + 2e-12, hors tolérance 1e-12)
```

**Constat nouveau, important : `digits = 17` casse un test existant.** Mesure (`rejeu_537b.R`) :

```
val                  format()  digits=15       digits=17                  aller-retour minimal (15 à 17)
-0.2                 -0.2      -0.2            -0.20000000000000001       -0.2
1.0000000010000001   1         1.000000001     1.0000000010000001         1.000000001
-1.0000000000000001e-09  -1e-09  -1e-09        -1.0000000000000001e-09    -1e-09
(1.7, 1.2, -0.01, 2, 1.5, -0.5 : identiques aux quatre colonnes)
```

`tests/unitaires/test_registre_add.R` l. 53-54 compare `identical(msg484(ligne484(p_ex = -0.2)), "add() : p-value hors de [0, 1] : p_ex = -0.2 (t)")` : avec `digits = 17` le message devient « p_ex = -0.20000000000000001 » et le test échoue (mesuré sur le prototype). Le critère « tests de #484 verts » est donc incompatible avec la lettre « `digits = 17` » ; l'issue dit « (ou équivalent) ». Deux équivalents mesurés qui laissent -0,2, 1,7, etc. inchangés : `format(val, digits = 15)` (1 + 1e-9 s'écrit « 1.000000001 », 1 + 2e-12 « 1.000000000002 » : tout dépassement hors tolérance (> 1e-12) est visible à 15 chiffres) ; ou la plus courte écriture qui se relit à l'identique (boucle `d` de 15 à 17, `as.numeric(format(val, digits = d)) == val`). Choix de texte à faire à l'étape 2 (actuary, ou décision du mainteneur : fidélité au bit ou lisibilité).

**Sites.** `R/engine.R` l. 4675 (une seule ligne) ; commentaire l. 4659-4668 inchangé.

**Tests.** `test_registre_add.R` l. 51-66 (C2), l. 84-89 (C2 : `grepl` sur le préfixe « p-value hors de [0, 1] : p_ex = » pour 1 + 1e-9 et −1e-9, insensible au chiffre) ; à ajouter : un test qui lit la valeur écrite pour 1 + 1e-9 et −1e-9 (critère du plan). Aucune fixture dont un texte changerait, **sauf** l. 54 si `digits = 17`.

**Surfaces doc.** `.tex` l. 1303 (`\label{sec:inventaire}`) et l. 3717 (`\label{sec:convention-restitution}`) citent la règle de refus (« hors de $[0, 1]$ à `TOL_P_BORNE` près »), **pas** la forme de la valeur imprimée (grep `format(val`, `p\_ex = ` dans le `.tex` : aucune occurrence) : impact probablement nul, à confirmer par `docwriter`. `CONTEXT.md` et ADR 0001/0003 ne citent pas le message.

**Références.** Aucune chaîne « p-value hors de » dans les six `.rds` (0).

**Risques.** Casse de `test_registre_add.R` l. 54 selon l'équivalent choisi (voir ci-dessus). **Effort :** très petit (une ligne, un test).

---

## #535 : rang de `nature_forcee` recalculé

**Constat : reproduit.** Bloc de hiérarchie `R/engine.R` l. 4884-4895 (`p_ret`, `nature`) ; contrôle l. 4963-4974, avec la cascade recopiée l. 4964-4965 (`rang <- if (is.finite(p_ex)) "exacte" else if (is.finite(p_mc)) "Monte-Carlo" else "p non simulee"`). Entre les deux blocs, ni `p_ex`, ni `p_mc`, ni `p_as`, ni `type` ne changent (lecture l. 4896-4962) : les deux cascades sont équivalentes (confirmé par le prototype : aucun test ni cas du corpus ne diffère).

Rejeu (`rejeu_535.R`, sortie identique sur la tête) :

```
rang exacte    : add() : nature_forcee incompatible avec le rang de la p retenue (exacte) : Monte-Carlo bidon (t)
rang MC        : ... (Monte-Carlo) : exacte x (t)
rang p non sim.: ... (p non simulee) : Monte-Carlo x (t)
rang p non sim. (exacte): ... (p non simulee) : exacte x (t)
MC ext          : ... (Monte-Carlo) : exacte x (t)
aucune p (p_ret NA) : pas d'erreur, nature_p = NA ; diagnostic : nature_p = NA
```

**Sites.** `R/engine.R` l. 4884-4895 (poser `rang` : `"exacte"`, `"Monte-Carlo"`, `"p non simulee"`, `NA_character_`, dans les quatre branches) ; l. 4964-4965 (retirées). Les libellés de rang sont ceux du message d'erreur, **distincts** de `nature_mc` / `nature_as` (ne pas réutiliser `nature`). Prototype testé : ce schéma passe toute la batterie.

**Tests.** `test_registre_add.R` l. 131-160 : couvre les trois rangs (l. 139-141 exacte, 142-146 Monte-Carlo par `mc_nom` et `p_mc_ext`, 147-151 p non simulée), la conformité (l. 152-155) et l'absence de contrôle sans verdict ou sans p (l. 156-160). Aucun rang à compléter. Appels réels : TOST (`R/engine.R` l. 6086), Pitman (l. 6255).

**Surfaces doc.** Aucune citation de la cascade du contrôle ; `.tex` l. 1303 et 3717 décrivent le refus, pas son implémentation. Impact doc : aucun (à confirmer).

**Références.** Identiques (prototype : écart maximal 0). **Risques.** Faibles : rang NA avec `p_ret` NA (le contrôle exige `is.finite(p_ret)`). **Effort :** petit.

---

## #536 : deux formes du motif « Monte-Carlo indisponible »

**Constat : reproduit** (trois compositions, deux gardes copiées ; forme à virgule voulue, textes inchangés, Q-60-2 (a)).

### Inventaire exhaustif (`grep -n "Monte-Carlo indisponible" R/engine.R`, six occurrences, dont trois du code)

| Ligne | Site | Forme produite | Garde |
|---|---|---|---|
| 4218, 4578, 13544 | commentaires | citent « m. » et « m, libelle non retenue » | — |
| 4222-4227 | `.prefixe_motif_mc()` | dégénéré : « <m> : aucune p-value retenue. » + complément ; **autre** : `paste0("Monte-Carlo indisponible : ", motif, ".")` (l. 4226) | non |
| 4716 | `add()`, ligne posée `diagnostic` par l'appelant | `.engine_joindre(.prefixe_motif_mc(motif_boot), trimws(detail))` (toute classe de motif) | non |
| 4720 | `add()`, `test` à motif dégénéré | `.prefixe_motif_mc(motif_boot)` (forme dégénérée) | non |
| 4732-4733 | `add()`, `test` sans p exacte, avec p non simulée | `paste0("Monte-Carlo indisponible : ", motif_boot, ", ", libelle_p_as, " non retenue. ", detail)` (**forme « , »**, M3) | non |
| 4842-4844 | `add()`, R1 `p_min >= alpha` | `.prefixe_motif_mc(motif_boot)` (forme « m. », M1) après la phrase « TEST INOPERANT » | `!grepl(motif_boot, detail, fixed = TRUE)` (copie 1) |
| 4876-4880 | `add()`, bloc `aucune_p` | `paste0("Monte-Carlo indisponible : ", motif_boot, ", ")` + « aucune p-value disponible sur ces donnees : aucun verdict. » (**forme « , »**, M9) | `!grepl(motif_boot, detail, fixed = TRUE)` (copie 2) |

Branche hors aide (dérogation Q-A2) : l. 4721-4724, `MOTIF_MC_OBS_NON_FINIE`, compose `paste0(motif_boot, " : test non applicable. ", detail)`, sans préfixe ni garde. Aucun appel à `.prefixe_motif_mc()` ni aucune composition du préfixe ailleurs dans `R/` (`grep` sur `R/display_helpers.R` et `app.R` : 0).

Domaine des motifs aux sites gardés (lecture, confirmée par le corpus à 4800 cas) : l. 4842 et 4877 ne reçoivent que des motifs non dégénérés, hors `MOTIF_MC_OBS_NON_FINIE`, sans p non simulée (un motif dégénéré a basculé la ligne en diagnostic l. 4718-4720 ; `OBS_NON_FINIE` sans p exacte la rend non applicable ; avec p non simulée, l. 4725-4733 bascule en diagnostic) ; les deux gardes sont exclusives (R1 bascule le type avant le bloc `aucune_p`).

### Proposition de signature (testée sur le prototype, 4800 cas identiques, batterie verte)

```r
# Compose "Monte-Carlo indisponible : <motif>" suivi de "." si rien ne suit, de ", <suite>" sinon.
# Si `detail` est fourni et contient deja le motif (grepl fixed), rend `suite` seule
# (character(0) sans suite) : la garde anti-doublon.
.motif_mc_indisponible <- function(motif, suite = character(0), detail = NULL) {
  if (!is.null(detail) && grepl(motif, detail, fixed = TRUE)) return(suite)
  if (length(suite)) paste0("Monte-Carlo indisponible : ", motif, ", ", suite)
  else paste0("Monte-Carlo indisponible : ", motif, ".")
}
```

Usages dans le prototype : `.prefixe_motif_mc()` l. 4226 → `.motif_mc_indisponible(motif)` ; l. 4732 → `.motif_mc_indisponible(motif_boot, paste0(libelle_p_as, " non retenue."))` joint à `detail` par `paste(c(., detail), collapse = " ")` puis `trimws` (sans `detail` passé : pas de garde, comme aujourd'hui) ; l. 4842 → `.motif_mc_indisponible(motif_boot, detail = detail)` (garde par l'aide, **sans** passer par `.prefixe_motif_mc()`) ; l. 4876 → `.motif_mc_indisponible(motif_boot, "aucune p-value disponible sur ces donnees : aucun verdict.", detail)` (avec garde, le texte « aucune p-value… » reste, comme aujourd'hui).

Point de conception à trancher (non bloquant) : au site l. 4842 le prototype appelle l'aide directement, ce qui abandonne la branche dégénérée de `.prefixe_motif_mc()` à ce site ; elle y est inatteignable par lecture (voir le domaine ci-dessus) et le corpus (motifs dégénérés × `test` × p_min) est identique. Variante sans ce point : conserver `.prefixe_motif_mc()` au site 4842 et n'extraire que la garde (`.motif_deja_dit(motif, detail)`).

**Tests.** Fichiers citant « Monte-Carlo indisponible » (comptes `grep -c`) : `outils_unitaires.R` 3 (**grammaire des gabarits, l. 195-196 M3 et M1_indisponible, l. 221 M9** : la forme « , » et « . » y est un contrat de format), `test_inoperance.R` 14 (l. 255-258, 363-374, 402, 418, 430, 453, 1049-1079, 1278, 1308), `test_sans_repli_p_non_simulee.R` 14 (l. 29, 53, 86, 97, 119, 167), `test_regimes_p_exactes.R` 11, `test_affichage_regime_t8.R` 2, `test_b_effectif_mw.R` 2, `test_detail_deux_phrases.R` 2, `test_merz_wuthrich.R` 3, `test_merz_wuthrich_suite.R` 2, `test_p_mc_regime.R` 3, `test_statistiques.R` 1 (l. 465) ; hors `tests/unitaires/` : `tests/p_conditionnelle_regime_t8.R` (5), `tests/puissance_t8.R` (1) (scripts de mesure, hors CI). **Aucune chaîne à modifier** si les textes restent identiques octet pour octet (prototype : 0 échec dans ces fichiers). Cas à ajouter pour la garde de l'aide (test direct de la fonction, avec et sans `suite`, avec et sans motif déjà présent).

**Surfaces doc.** `.tex` : index des fonctions, tableau d'inventaire `\label{sec:inventaire}` l. 1266-1282 (ligne de `.prefixe\_motif\_mc()` : « appelée par `add()` seule… », l. 1275, et de `.complement\_motif\_mc()` l. 1280) : **y ajouter la fonction nouvelle** (concordance `--strict`) ; `\label{sec:nature}` l. 6183, 6385, 6456 (« forme `Monte-Carlo indisponible : <motif>.` »), 6565 (forme « `Monte-Carlo indisponible : motif,` » du bloc `aucune_p`), 20041 (`.prefixe\_motif\_mc()`) ; l. 1270-1271, 5476-5479 (`\label{sec:boot-mw}`), 5870, 9302, 9876, 10134 (`\label{fiche:cox-stuart}`), 12337 (`\label{fiche:suites-ratios-bruts}`), 20035 : citent les textes, inchangés. `CONTEXT.md` l. 59 (« Test sans p-value retenue ») et ADR 0003 (annotation du 12/10/2026, l. 62, 152, 186) citent les formes : inchangés (Q-60-2 (a), aucune annotation).

**Références.** « Monte-Carlo indisponible » : 0 occurrence dans les six `.rds`. Les références portent « aucune p-value retenue » (2 chaînes distinctes par cas premium et reserve1) : forme **dégénérée** de `.prefixe_motif_mc()`, hors de l'aide ; « non retenue » y est le même texte (2). Prototype : six cas `CONFORME`, écart 0.

**Risques.** Faibles ; le contrat de format des gabarits (M1/M3/M9 de `outils_unitaires.R`) borne les formes. **Effort :** moyen (aide, quatre sites, un test direct, une ligne d'index du `.tex`).

---

## Dérogation Q-A2 de K4

Relecture : une seule affectation `loi <- NA_character_` dans `add()` (`grep -n "loi <- NA_character_" R/engine.R` : l. 4723 seule), dans la branche `!is.finite(p_ex) && identical(motif_boot, MOTIF_MC_OBS_NON_FINIE)` (l. 4721-4724), qui compose son texte sans préfixe « Monte-Carlo indisponible ». **#535 et #536 ne la touchent pas** (diff du prototype : aucune ligne entre 4721 et 4724 changée ; la branche n'appelle ni l'aide ni la cascade du rang).

**Correction à la fiche : la fixture `tests/unitaires/test_statistiques.R:215` ne garde pas cette affectation.** Elle vérifie `identical(l$loi, NA_character_)` de la ligne Anscombe-Glynn à π_t variable, dont l'appelant (`usp_tests()`) passe lui-même `loi = NA_character_`. Mesure : copie du moteur sans la ligne 4723 (`proto/racine_mut`) :

```
== test_statistiques (mutant) : 81 assertions : 81 ok, 0 echec(s)
== test_non_applicable (mutant) :
  [ECHEC] #533 R12 (T = 200, reg ecarte) : toute ligne non applicable a loi NA
  [ECHEC] #533 ajustement exact (x = 1:8, y = 2x) : toute ligne non applicable a loi NA
  [ECHEC] #533 add(), regle R3 : ligne rendue non applicable a loi NA malgre un loi fourni
   25 assertions : 22 ok, 3 echec(s)
```

Les gardes de l'affectation sont donc **`tests/unitaires/test_non_applicable.R` l. 158-171** (« #533 add(), règle R3 : ligne rendue non applicable à loi NA malgré un loi fourni ») et les deux autres cas #533 du même fichier. Sur la tête : `test_statistiques.R` 81/81 et `test_non_applicable.R` 25/25 verts (mesuré). Le critère « fixture Q-A2 verte à chaque commit » du plan doit citer `test_non_applicable.R` (en plus de `test_statistiques.R:215`, vert mais sans pouvoir de détection ici).

---

## #532 : branche 2b de `detail_runsr`

**Constat : reproduit, avec une nuance.** `R/engine.R` l. 7286-7312 (`detail_runsr`), branche 2b l. 7300-7303 (`else if (isTRUE(pi_constant))`), texte « … sans p exacte (un seul cote de la mediane represente). ». Commentaire de régime l. 7255-7267 (« 2b : pi_t constant, signes identiques, mais p exacte non définie ») et l. 7282 (« branches 1, 2 et 2b »).

**Inatteignable par `run_engine()`, atteignable par un objet bootstrap incohérent.** 2b exige : `stats_obs$Runsr` finie (sinon la ligne est « non applicable » et `detail_runsr` n'est pas lu, l. 7349-7352), π_t constant, signes de `z` et `u` égaux, et `p_ex_r` non finie. Or `stats_obs$Runsr = test_runs(u, plancher_u)$stat` (catalogue l. 4061-4064), finie seulement si n1 ≥ 1, n2 ≥ 1 et non (1, 1) ; dans ce cas `runs_p_exacte(u, plancher_u)` est finie (l. 2718-2727) : un π_t constant à signes égaux donne `p_ex_r` finie. Mesures :

```
rejeu_532.R : tirages : 72000 ; Runsr finie : 57219 ; dont p_ex_r NA (pi_constant, signes z/u egaux) : 0 ;
              predicat de la branche 2b : 0
              Runsr finie => runs_p_exacte(u) finie (plancher 1, 48000 tirages) : TRUE
rejeu_532b.R : jeu a ratios (0.8 x7, 1.4), delta = 1 (pi_t constant), bootstrap issu du moteur :
               Runsr observee = NA -> type "non applicable", detail "un seul cote de la mediane represente : loi de R non definie, test non applicable"
               puis stats_obs$Runsr force a 1 (objet bootstrap fictif) -> type "diagnostic", detail "CONTROLE SANS OBJET ICI : pi_t constant, quasi-doublon ... sans p e[xacte...]" (branche 2b atteinte)
```

La branche n'est donc atteinte que par un bootstrap dont `stats_obs$Runsr` est finie alors que `u` est d'un seul côté de la médiane (incohérent). Le cas « un seul côté » réel passe par la ligne non applicable (tests `test_statistiques.R` l. 236, 286, 304). Aucun test n'atteint 2b : le commentaire de `test_detail_deux_phrases.R` l. 379 (« S22 Runsr branche 2b et 2 ») annonce un scénario 2b qu'aucun `verifier` du fichier ne porte (lecture, `grep` : seules les branches 1, 1b et 3 y figurent).

**Options (décision actuary à l'étape 2).** (i) retirer 2b et son commentaire ; (ii) retirer 2b et lever `stop()` pour le bootstrap incohérent (modèle l. 7366-7367 : « assertion de programmation ») ; (iii) conserver avec un test qui construit l'objet fictif ci-dessus. **Attention (lecture, non mesuré)** : le retrait simple fait tomber le cas fictif dans le `else` (branche 3), dont le texte parle de π_t variable alors que `pi_constant` est vrai.

**Sites.** `R/engine.R` l. 7246 (« Runsr d'un seul côté de la médiane compris » : reste vrai par la ligne non applicable), 7255-7267, 7282, 7300-7303.

**Tests.** `test_detail_deux_phrases.R` l. 283, 285 (branches 1 et 1b), 328, 334 (S12 : motifs variés, branche 3), 379 (commentaire à corriger) ; `test_regimes_p_exactes.R` l. 213, 242 (branche 2) ; `test_lois_exactes.R` l. 464. Aucune fixture ne cite le texte de 2b.

**Surfaces doc.** `.tex` l. 12333-12334 (`\label{fiche:suites-ratios-bruts}`, fiche « Test des suites sur ratios bruts ») : « quand un seul côté de la médiane est représenté, il dit « sans p exacte (un seul cote de la mediane represente) » ». Aucune citation dans `CONTEXT.md` ni les ADR.

**Références.** « un seul cote de la mediane » et « sans p exacte » : 0 occurrence dans les six `.rds` ; « CONTROLE SANS OBJET ICI » : 5 par cas premium / reserve1 (non ventilé par branche), 0 de texte de 2b. **Effort :** petit (option i) à petit-moyen (iii).

---

## #534 : `b2_non_defini` levé pour tout b2 non fini

**Constat : reproduit.** `test_anscombe_kurt()` `R/engine.R` l. 2411-2430 ; l. 2414-2417 : `if (!is.finite(b2)) return(list(…, b2_non_defini = TRUE, …))` ; le motif qui lit le champ, l. 6896-6899, dit « moment centre d'ordre 2 des residus nul : residus constants ». Mesures (`rejeu_534.R`, n ≥ 20) :

```
constants 0.5 / 0.1 / 1/3 / 0 (n = 25) : b2_non_defini=TRUE, m2 = 0, m4 = 0, b2 = NaN     (cas "residus constants" : motif exact)
un NA                      : b2_non_defini=TRUE, m2 = NA,  m4 = NA,  b2 = NA               (motif faux)
un NaN                     : b2_non_defini=TRUE, m2 = NaN, m4 = NaN, b2 = NaN              (motif faux)
un Inf                     : b2_non_defini=TRUE, m2 = NaN, m4 = NaN, b2 = NaN              (motif faux)
1e80 / -1e80 dans 23 normales : TRUE, m2 = 8e+158, m4 = Inf, b2 = NaN                      (depassement de m4 : motif faux)
1e100 / -1e100             : TRUE, m2 = 8e+198, m4 = Inf, b2 = NaN                         (idem)
un 1e60 : b2_non_defini=FALSE (m4 = 3.4e+238 fini, b2 = 23.04)                              (calcul normal)
n = 15 : b2_non_defini=FALSE (n < 20 avant tout calcul)
```

`rejeu_534b.R` : 12 300 séries constantes (n de 20 à 60, constantes de 10^-3 à 10^3 d'ordre) : m2 > 0 par arrondi de `mean()` dans 0 cas ; `m2 == 0` identifie bien les résidus constants.

Via `usp_tests()` (`rejeu_534c.R`, résidus `z` substitués, bootstrap fictif) : `z` constant : « … residus constants … » (exact) ; dépassement 1e80 : **le même texte « residus constants », faux** ; un `NA` : erreur R « incompatible dimensions » **levée ailleurs que dans `test_anscombe_kurt()`** (origine non recherchée).

Atteignabilité par `run_engine()` : non démontrée ; les résidus d'un ajustement validé sont finis et le dépassement de m4 exigerait des résidus d'ordre 1e77 ou plus (hypothèse : cas dégénéré inatteignable, comme l'écrit l'issue).

**Sites.** `R/engine.R` l. 2408-2410 (commentaire), 2411-2430 (fonction), 6896-6899 (motif ; commentaire l. 6890-6892). Pour un b2 non fini d'une autre cause : un second champ ou une cause en texte (l'interface de `test_anscombe_kurt()` est lue par `usp_tests()` seul, `grep b2_non_defini R/*.R app.R` : l. 2409-2428 et 6891-6896).

**Tests.** `test_statistiques.R` l. 140-159 (`rep(0, 40)` → `b2_non_defini` TRUE ; Z non définie → FALSE), l. 189-200 (appel direct d'`usp_tests()` à `z` constant : texte « … residus constants … » identique, conservé pour m2 = 0). À ajouter : `NA` et dépassement de m4 en appel direct de `test_anscombe_kurt()` (critère du plan).

**Surfaces doc.** `.tex` l. 11368 (`\label{fiche:anscombe-glynn-aplatissement}`) : « b2 non défini (m2 = 0, résidus constants ; champ `b2_non_defini`) » ; texte de l'étape 9 selon le motif décidé à l'étape 2. Rien dans `CONTEXT.md` ni les ADR.

**Références.** « residus constants », « aplatissement b2 », « b2_non_defini » : 0 dans les six `.rds`. **Effort :** petit.

---

## #555 : lecteurs, nom de colonne `NA` et colonne `i`

Fixture des rejeux : triangle 6 × 6 valide (cumulés croissants, partie basse vide), lu par `engine_lire_triangle()` après passage par les deux chemins de l'application : CSV (`utils::read.csv(colClasses = "character", blank.lines.skip = FALSE, check.names = FALSE, na.strings = character(0), row.names = NULL)`, paramètres de `lire_tableau()` d'`app.R` l. 249-251) et classeur (`engine_ecrire_xlsx()` puis `engine_lire_xlsx()`, lecteur interne ; **`openxlsx` absent : parité non mesurée**).

### Constat 1 : nom de colonne `NA` : reproduit

```
nom de colonne NA (j1)        ERREUR R BRUTE : undefined columns selected
nom de colonne NA (a la place de i)  idem
nom de colonne NA (derniere)  idem
```

Mécanisme (`rejeu_555d.R`, R 4.3.3) : `d[, names(d) != "i", drop = FALSE]` avec un nom `NA` rend « undefined columns selected » ; la ligne fautive est l. 7985 (`df <- df[, names(df) != "i", drop = FALSE]`). `!(names(d) %in% "i")` rend TRUE pour le nom `NA`. `regle <- names(df) != "i"` l. 7805 de `.retirer_lignes_colonnes_vides()` propage aussi un `NA`, sans erreur à cet endroit (appel direct : pas d'erreur). **Un nom `NA` ne vient d'aucun des deux chemins de fichier mesurés** : CSV d'en-tête vide → nom `""` (`rejeu_555f.R` : `<i><j0><><j2>`, NA ? FALSE) ; classeur interne d'en-tête vide → nom `V3` (`rejeu_555c.R`, NA ? FALSE) ; chemin `openxlsx` non mesuré. Il ne s'obtient que par un `data.frame` en mémoire (appel direct), comme l'écrit l'issue.

### Constat 2 : en-tête `i` en double : reproduit

```
deux colonnes i (i, j0..j5, i)  ok = FALSE ; D(2)(e) : le nombre d'annees d'accident ne peut etre inferieur au nombre d'annees de developpement. || Triangle non carre (6 annees d'accident, 7 annees de developpement) : cas non couvert par les formules des paragraphes 4 et 5 de la section D de l'annexe XVII.
deux colonnes i adjacentes     idem
```

**Mécanisme (nouveau, important pour le placement du contrôle)** : `.retirer_lignes_colonnes_vides()` se termine par `df[, !retirer, drop = FALSE]` (l. 7841), et `[.data.frame` à sélection de colonnes **renomme le doublon** : `rejeu_555b.R` : « noms : i j0 … j5 i » → « apres .retirer_lignes_colonnes_vides : i j0 … j5 **i.1** » ; l. 7985 ne retire donc que le premier `i`, le second devient une colonne de développement (7 colonnes, d'où « 7 années de développement »). `rejeu_555d.R` : `names(d[, c(TRUE,TRUE,TRUE), drop = FALSE])` → `i a i.1`, tandis que `d[1:3, , drop = FALSE]` garde `i a i` (la sélection de lignes ne renomme pas). **Le doublon d'en-tête `i` doit donc être détecté avant la l. 7841 (au début de `.retirer_lignes_colonnes_vides()` ou dans `engine_lire_triangle()` avant son appel)**, sur les noms reçus.

### Constat 3 : colonne `i` à doublons, vides, ordre inverse : reproduit, accepté sans message

Sortie (`sortie_555.txt`) : `ok = TRUE ; erreurs = (aucune)` pour **les 12 cas × deux chemins (CSV et xlsx)** : `i` propre 1..6 ; sans colonne `i` ; 0..5 ; doublons (1,1,2,3,4,5) ; vide (1,NA,3,4,5,6) ; inverse (6..1) ; **non consécutif (1,2,4,5,6,7)** ; **non entier (1.5…6.5)** ; **texte (a..f)** ; **constant (1,1,1,1,1,1)** ; **hors ordre (1,3,2,4,5,6)** ; **négatif (−2..3)**. Triangle rendu identique pour tous (écart maximal 0 en CSV, 2,3e-13 en xlsx par rapport à la lecture CSV, pour l'écriture à 17 chiffres du xlsx contre 15 en CSV : sans rapport avec `i`) : le calcul suit l'ordre des lignes du fichier, la colonne `i` n'est jamais lue (`R/engine.R` l. 7985 : `df[, names(df) != "i"]`, avant `brut <- lapply(df, …)`).

**Sonde d'architect confirmée : une colonne `i` à valeurs non consécutives (1,2,4,5,6,7) est acceptée sans message** (CSV et classeur). L'annexe XVII, D(2)(b) n'est lue ici que dans le moteur et le `.tex` : `R/engine.R` l. 7782 (« l'annexe XVII, D(2)(b), exige des annees d'accident consecutives »), motif des lignes vides l. 7807-7831, et `.tex` l. 3879 (« une ligne vide intercalée ou en tête est refusée comme année d'accident manquante présumée (D(2)(b)) ») ; le texte du règlement n'a pas été relu pour ce rapport.

Sondes supplémentaires (`rejeu_555e.R`, hors critères, à signaler) : en-tête `I` majuscule, ` i ` (blancs) ou matrice sans noms (`V<k>`) : refus « D(2)(e) … Triangle non carre (6 annees d'accident, 7 annees de developpement) » (la colonne n'est pas reconnue comme `i`, la comparaison de nom est exacte) ; `i` contenant `Inf` : `ok = TRUE`.

### Ce qui serait une extension des critères de l'issue (décision du mainteneur à l'étape 2, sans trancher)

Critères de l'issue : jamais d'erreur R brute et refus motivé pour (a) nom `NA`, (b) `i` en double, (c) colonne `i` à **doublons**, (d) colonne `i` à **vides**. Au-delà (extension) : `i` **non croissante / ordre inverse** (6..1, 1,3,2,…) ; `i` **non consécutive** (D(2)(b) pour les années manquantes) ; `i` **non entière** ; `i` **non numérique** (étiquettes de texte, acceptées aujourd'hui) ; `i` **constante** (cas particulier des doublons : couvert par (c)) ; `i` négative ; en-tête `i` en majuscule ou à blancs ; `Inf`. Éléments de décision mesurés ou lus : l'export de l'application écrit `i = 0..I` (`app.R` l. 1893 ; `tests/unitaires/test_controles_entree.R` l. 4522) alors que `tests/donnees/triangle_mw.csv` porte `i = 1..` (le fichier de démonstration) : **aucune convention 0- ou 1-basée n'est fixée** ; un contrôle de consécutivité ne doit donc porter que sur l'écart entre valeurs, pas sur la valeur de départ ; des années civiles (2015, 2016, …) ou des étiquettes de texte sont un usage plausible de la colonne (hypothèse, non mesurée sur des fichiers d'utilisateurs).

**Sites.** `R/engine.R` : `engine_lire_triangle()` l. 7961-8010 (BOM l. 7971, ligne 1 vide l. 7976, `.retirer_lignes_colonnes_vides()` l. 7979, sélection l. 7985, `retirer` ci-dessus) ; `.retirer_lignes_colonnes_vides()` l. 7769-7842 (`regle` l. 7805, `ii <- which(names(df) == "i")` l. 7818, fin l. 7841) ; commentaires l. 7655-7700 (« colonne `i` du triangle hors règle, elle est ignorée par `engine_lire_triangle()` ») ; commentaire d'en-tête de `engine_lire_triangle()` l. 7944-7948 (« colonne "i" facultative ignorée »). Les valeurs de `i` sont lisibles avant la l. 7985 dans `lv$df` (lignes de fin vides déjà retirées, même nombre de lignes que les cellules).

**Tests.** `engine_lire_triangle` : 111 appels dans `test_controles_entree.R`, 20 dans `test_application.R`, 4 dans `test_calibration.R`, 5 dans `test_outdec.R`, 1 dans `test_merz_wuthrich.R`. Fixtures qui portent une colonne `i` à ne pas casser : `test_controles_entree.R` l. 1828-1834 (`fichier_tri()`, `i = seq_len`), 2031-2160 (lignes et colonnes vides, `i` en position variable, l. 2118-2131, 2157, 2438), **l. 2362-2367 (« colonnes de nom dupliqué toutes gardées » : `c("i", rep("j", 5))` : seul un doublon de `i` est visé, les autres noms dupliqués restent acceptés)**, l. 3586 (BOM, `i`), 4522-4528 (export `i = 0:(n-1)` relu). À ajouter : un test par cas (nom `NA`, `i` en double, doublons, vides, et selon la portée décidée), par CSV et classeur (parité `openxlsx` en session de CI).

**Surfaces doc.** `.tex` l. 845 (`\label{sec:inventaire}`, ligne de `.retirer\_lignes\_colonnes\_vides()`), l. 3885-3903 (`\label{sec:controles}`, paragraphe de la colonne `i` au bord gauche) ; `\code{engine\_lire\_triangle()}` l. 3874 ; l. 4674 (« la colonne `i` d'un triangle ne serait pas écartée »). `CONTEXT.md` et les ADR : aucune mention de la colonne `i` (`grep`).

**Références.** Aucune des six références ne passe par les lecteurs du moteur (`tests/outils_tests.R` l. 72-77, d'après la fiche, non relu ici) ; aucune chaîne « Triangle non carre » ni « undefined columns » (0). Les six chargent par `read.csv` : #555 ne touche aucun objet de référence. **Comportement hors références** : un fichier à `i` à doublons ou vides, calculé aujourd'hui (`ok = TRUE`), devient un refus (tableau avant / après à joindre au commit).

**Risques.** Moyens : ordre des motifs en cas de causes multiples (refus cumulés ou premier refus) ; interaction avec les motifs de colonnes vides (#520) ; parité `openxlsx` non mesurable ici ; ne pas refuser les triangles dont `i` est légitimement 0- ou 1-basé ou en années civiles. **Effort :** moyen à grand (selon la portée) : trois à quatre motifs, tests par cas × deux chemins, refonte de commentaires.

---

## Vérification 6 : chaînes visées dans les six références

`LC_ALL=C.UTF-8 Rscript refs_chaines.R` (parcours de tous les caractères et noms des six `.rds`) : « Monte-Carlo indisponible », « un seul cote de la mediane », « residus constants », « test non applicable », « p-value hors de », « nature_forcee incompatible », « Triangle non carre », « undefined columns », « aucune p-value disponible », « aplatissement b2 », « b2_non_defini », « sans p exacte » : **0 occurrence** dans chacune des six. Présentes : « aucune p-value retenue » et « non retenue » (2 par cas premium, premium_ii6, premium_interieur, premium_net, reserve1 ; 0 pour reserve2), « TEST INOPERANT » (1), « CONTROLE SANS OBJET ICI » (5 ; 0 pour premium_interieur et reserve2) : aucune n'est dans une forme que K3b modifie (la forme dégénérée de `.prefixe_motif_mc()` reste hors de l'aide ; les cinq occurrences de « CONTROLE SANS OBJET ICI » ne sont pas ventilées par branche ici, mais « un seul cote de la mediane » et « sans p exacte » sont absentes : le texte de 2b n'y figure pas).

---

## Doutes à porter à `actuary` ou au mainteneur

1. **#537, forme du message.** `digits = 17` casse `test_registre_add.R` l. 54 (« -0.2 » devient « -0.20000000000000001 ») ; le critère « tests de #484 verts » exige un équivalent : `digits = 15` (écrit 1 + 1e-9 en « 1.000000001 ») ou le plus court aller-retour exact. Lequel ? Ou le test l. 54 est-il modifié (hors critère) ?
2. **#532, sort de 2b.** Retrait simple, retrait avec `stop()` pour le bootstrap incohérent, ou conservation avec test : le retrait simple fait tomber le cas fictif dans la branche 3 (π_t variable, texte faux, par lecture non mesurée).
3. **#534, motif d'un b2 non fini d'une autre cause** (NA, NaN, Inf, dépassement de m4) : texte, ou refus ; le chemin NA d'`usp_tests()` échoue de toute façon avant (« incompatible dimensions », origine non recherchée).
4. **#536, site l. 4842** : appeler l'aide directement (prototype) ou garder `.prefixe_motif_mc()` et n'extraire que la garde ; branche dégénérée inatteignable à ce site (lecture + corpus), à valider par `audit`.
5. **Critère Q-A2** : la fixture `test_statistiques.R:215` ne détecte pas le retrait de `loi <- NA_character_` (mesure) ; le critère doit citer `test_non_applicable.R` l. 158-171.
6. **#555, portée** (mainteneur) : ordre, consécutivité, non entier, texte, majuscule/blancs de l'en-tête ; absence de convention 0-/1-basée ; années civiles plausibles ; ordre et cumul des motifs ; le contrôle du doublon `i` doit précéder la l. 7841 (renommage `i.1`).
7. **#555, nom `NA`** : aucun chemin de fichier mesuré n'en produit (CSV : `""`, xlsx interne : `V<k>`) ; chemin `openxlsx` non mesuré (paquet absent) ; la correction reste de la robustesse d'appel direct.
8. **Batterie unitaire sur la tête non lancée en entier** : seules les mesures citées ; la batterie complète a tourné sur le prototype (1 échec attendu).
