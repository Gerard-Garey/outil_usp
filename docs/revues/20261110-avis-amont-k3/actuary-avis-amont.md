# Avis amont de la branche K3 « Registre » (actuary, lecture seule)

> *Rapport d'`actuary` (fiche de base, Opus 5.5), 10/11/2026, reproduit intégralement par la session principale (Q-54-10). Branche `claude/registre`, tête `6b1690d`.*

Lectures : `.claude/rules/moteur.md`, fiche K3 de `docs/feuille-de-route.md`, issues #484, #469, #485, #486, #521 ; dans `R/engine.R` : `add()` (l. 4461-4800), appel TOST (l. 5843-5880), appel Pitman (l. 5955-6037), `mention_r7()` (l. 5633-5642), `usp_regime()` (l. 2008-2024), `test_anscombe_kurt()` (l. 2314-2327) et ligne Anscombe-Glynn (l. 6617-6650), `test_runs()`, `.runs_z()`, `.runs_extremes()` (l. 2498-2516, 3765-3773), lignes des suites (l. 6693-6713, 7068-7082, 12665-12720), ligne Kruskal (l. 12609-12636) ; `tests/unitaires/test_merz_wuthrich_suite.R` (l. 397-433). Deux mesures `Rscript`.

**En bref** : #484, #469, #486 et #521 complets. #485 porté au mainteneur : texte d'Anscombe et Glynn (1983) non lu ; la racine cubique signée inverse le signe de Z ; statistique non définie recommandée, avec un motif propre.

---

## 1. #484 : `add()` d'`engine_registre_tests()` (complet)

**Contrainte sur `nature_forcee` : souhaitable, compatible avec ses deux usages si elle ne porte que sur une ligne qui garde un verdict.**

- **Piège vérifié.** La ligne Pitman passe `nature_forcee = "exacte par permutation…"` même quand elle est non applicable (`p_as = p_student` passé sans condition, l. 6031), cas des volumes constants dans la bande de tolérance : t fini, donc `p_student` fini. Sur une telle ligne, la p retenue avant la remise à `NA` (l. 4772-4774) est une p non simulée. Un contrôle posé à la l. 4708, conditionné à `is.finite(p_ret)` seul, lèverait une erreur sur un appel légitime.
- **Règle exacte.** `nature_forcee` n'est appliquée et contrôlée que si la ligne porte un verdict (`type == "test"` après toutes les bascules, même condition que `porte_verdict`) et si `p_ret` est finie : la l. 4708 passe après le calcul de `porte_verdict`. Préfixe exigé selon le rang de la p retenue :
  - p exacte retenue (`is.finite(p_ex)`) : commence par `exacte` ;
  - p Monte-Carlo retenue (`p_mc` finie, `p_mc_ext` comprise) : commence par `Monte-Carlo` ;
  - p non simulée retenue : ne commence ni par `exacte` ni par `Monte-Carlo`.
- **Contrôle de forme** à l'entrée, sur le modèle de `nature_as` : `NA` ou chaîne de longueur 1 non vide.
- **Message** : `stop("add() : nature_forcee incompatible avec le rang de la p retenue (", rang, ") : ", nature_forcee, " (", nom, ")", call. = FALSE)`, `rang` parmi `"exacte"`, `"Monte-Carlo"`, `"p non simulee"`.
- **Compatibilité (lecture)** :

| Appel | Cas | p retenue | Préfixe de `nature_forcee` | Contrôle |
|---|---|---|---|---|
| TOST (l. 5867) | type test | `p_as` (non simulée) | « sous le modele auxiliaire pondere… » | passe |
| TOST | diagnostic R14 ou non applicable | aucun verdict | — | pas de contrôle |
| Pitman (l. 6033) | énumération | `p_ex` (exacte) | « exacte par permutation… » | passe |
| Pitman | permutations aléatoires | `p_mc_ext` (Monte-Carlo, prioritaire sur `p_as`) | « Monte-Carlo (permutations aleatoires… » | passe |
| Pitman | non applicable | aucun verdict | — | pas de contrôle |

  Sortie inchangée pour tous les appels actuels (nature d'une ligne sans verdict déjà remise à `NA`).
- **Motif** : applique au point où `nature_p` est écrite la règle « exacte > Monte-Carlo > p non simulée, jamais lue à l'envers » (ADR 0001, ADR 0003). La remarque R1 de l'issue, sous sa forme « exacte / Monte-Carlo / asymptotique », est écartée : elle refuserait le libellé de TOST.

**`sens`.** Valeurs réelles (`grep`) : défaut `"ne pas rejeter"` (l. 4474), `"rejeter"` (l. 5870 TOST, l. 6031 Pitman) ; l'enveloppe `add()` de `mw_tests()` (l. 12293) transmet `...`. Contrôle à l'entrée, même forme que `type` :
`if (!is.character(sens) || length(sens) != 1L || is.na(sens) || !sens %in% c("rejeter", "ne pas rejeter")) stop("add() : sens inconnu : ", paste(format(sens), collapse = " "), " (", nom, ")", call. = FALSE)`

**p-values finies hors de [0, 1] : confirmé.** Arguments `p_ex`, `p_as`, `p_mc_ext`, `p_min` ; valeurs lues par `mc_nom` : `p_mc` (`boot$p_mc`) et `p_min_mc` (`boot$p_min_mc`), contrôlées juste après leur lecture (l. 4524 et 4583), avant toute restriction de branche. Ne pas contrôler `err_mc_ext`. Une valeur non finie reste admise comme absente. Message : `stop("add() : p-value hors de [0, 1] : ", arg, " = ", format(val), " (", nom, ")", call. = FALSE)`. Intervalle fermé (`.p_borne()` l. 2049 ; `engine_p_mc()` `pmin(p, 1)` l. 4166) : ni 0 ni 1 refusé.

**Suppression de `verdict` : confirmée.** Aucun appel du registre ne le passe (les `verdict =` des l. 1226, 1755, 13394 sont des contrôles). À retirer : l'argument (l. 4474), `is.null(verdict)` (l. 4723, 4745), le `stop()` (l. 4769-4770), la branche de la l. 4775. `.tex` l. 19712 (refus d'un verdict fourni hors type test) sans objet : surface documentaire.

---

## 2. #469 (complet ; information au mainteneur sur le type)

**Point 1.** Une ligne arrive de type `test` dans la branche R1 non Monte-Carlo (l. 4652) avec un `motif_boot` renseigné dans deux cas :

- **(a) p exacte finie** : retenue ; `add()` n'imprime jamais le motif Monte-Carlo dans ce cas, même hors R1 (l. 4538-4561). **Pas de motif.**
- **(b) ni p exacte ni p non simulée** (`aucune_p`), motif non dégénéré autre que `MOTIF_MC_OBS_NON_FINIE` (`MOTIF_MC_AUCUNE_REPLIC`, `MOTIF_MC_REPLIC_INSUFFISANTES`, `MOTIF_MC_REGIME_RARE`) : hors R1, le bloc `aucune_p` (l. 4688-4693) mettrait « Monte-Carlo indisponible : <motif> » ; la bascule R1 fait passer la ligne en diagnostic avant : le motif est perdu. **C'est le vrai trou.**

Atteignabilité (*hypothèse*, à établir par fixture) : appel direct avec B < `B_MIN_USAGE` ; ligne Merz-Wüthrich à `mc_nom` et `p_min`, sans `p_as` (par exemple `CorrDev`), dans un petit triangle où `p_min >= alpha`.

Règle : seulement si `!is.finite(p_ex)` et `motif_boot` renseigné, joindre `.prefixe_motif_mc(motif_boot)` juste après la phrase « TEST INOPERANT… » (préfixe en tête, règle #129), même garde anti-doublon que la l. 4689. Forme :
`TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 1.0000, aucun verdict. Monte-Carlo indisponible : aucune replication finie (B_effectif = 0). <detail de l'appelant>`

**Point 2 : ligne Kruskal–Wallis à un résidu par année (`ka$un_par_annee`).**

- **Type : `diagnostic`, posé explicitement par `mw_tests()`** (`type = if (isTRUE(ka$un_par_annee)) "diagnostic" else "test"`). H = N − 1 est une identité (avec un résidu par groupe, H = (N − 1) Σ(R_i − R̄)² / Σ(R_i − R̄)²), indépendante de la loi et de T : aucune hypothèse testée.
- **Nom inchangé** : « Homogeneite des residus entre annees de survenance ».
- **Dans ce seul cas** : `H0 = "sans objet : un residu de Mack par annee de survenance, H = N - 1 par construction"`, `H1 = "sans objet"` ; textes actuels inchangés ailleurs.
- **Verdicts** : aucun changement sur les fixtures existantes (test l. 397-415 : `type == "diagnostic"`, `verdict == "INFO"`, motif « loi simulee de dispersion nulle » sur `col0_192(1e-11)` et `sauf_une`) ; même préfixe par la première branche (l. 4538-4543) ; `inoperant = FALSE`, `p_min_mc = NA` identiques. Seul changement hypothétique : bootstrap sans motif de dispersion nulle (bruit numérique) : test aujourd'hui, diagnostic INFO après. Information au mainteneur (Q-57-7).
- `regulatory` non requis.

---

## 3. #485 : Anscombe–Glynn, QA1 (question au mainteneur, routage § 4.4)

**Texte d'Anscombe et Glynn (1983) non vérifié** (`academic.oup.com`, `www.jstor.org` injoignables ; `docs/references/inventaire-non-relu.md` l. 81 : [P], texte entier non relu ; D'Agostino, Belanger et D'Agostino (1990) non lu).

**Établi sans le texte** (calcul sur la formule de `test_anscombe_kurt()`) :
- Le dénominateur 1 + x√(2/(A−4)) croît avec b2 ≥ 1 ; minimum en b2 = 1 ; strictement positif pour 20 ≤ T ≤ 34, ≤ 0 près de b2 = 1 dès **T = 35**. Inatteignable à T = 8.
- **La racine cubique réelle signée inverse le signe de Z** : T = 40, b2 = 1 → Z = +35,9 ; T = 100, b2 = 1,2 → Z = +33,1. Racine signée écartée, sauf prescription explicite du texte.
- Lecture plausible, non vérifiée : dénominateur ≤ 0 hors du support de l'approximation (Wilson–Hilferty), limite cohérente Z = −∞, p = 0 ; non proposée sans source.

**Recommandation provisoire : statistique non définie** (`stat = NA_real_`, `p = NA_real_`, cause rendue, dès que le dénominateur est ≤ 0) ; ligne non applicable comme aujourd'hui, aucun verdict changé.

**Motifs** (priorité T < 20, π_t variable, Z non définie) :
- `sprintf("T = %d < 20 : test non defini", T)` (inchangé) ;
- `approximation a n fini etablie pour un echantillon i.i.d. normal, sans objet a pi_t variable (z = P epsilon non i.i.d.) ; aucune p-value de Monte-Carlo prevue : test non applicable` (inchangé) ;
- `statistique Z non definie : 1 + x sqrt(2/(A - 4)) <= 0 (aplatissement b2 tres inferieur a 3, hors du domaine de la transformation de Wilson-Hilferty) ; aucune p-value de Monte-Carlo prevue : test non applicable` (nouveau).

**QA1** : (a) statistique non définie (recommandé) ; (b) trancher sur le texte ; (c) Z = −∞, p = 0 (changement de verdict, sans source).

---

## 4. #486 : `test_runs()` (complet)

V = 2n1n2(2n1n2 − n)/(n²(n − 1)) ; 2n1n2 − n1 − n2 = n1(n2 − 1) + n2(n1 − 1) : V = 0 si et seulement si n1 = n2 = 1 (R = 2 pour les deux arrangements). Mesure : `test_runs(c(1,2,2,2,3))` → `stat = NaN`, `runs = 2`.

Dans `test_runs()` : `NA_real_` à n1 = n2 = 1 ; cause rendue dans les deux cas :
- n1 = 0 ou n2 = 0 : `un seul cote de la mediane represente : loi de R non definie`
- n1 = n2 = 1 : `une seule valeur de chaque cote de la mediane (n1 = n2 = 1) : R = 2 pour tout arrangement, loi de R degeneree (variance nulle)`

**Lignes lognormales** (z, l. 6713 ; `Runsr`, l. 7080) : `paste0(<racine>, ", test non applicable")`, soit la chaîne actuelle à l'identique pour n1 = 0 ou n2 = 0 et `une seule valeur de chaque cote de la mediane (n1 = n2 = 1) : R = 2 pour tout arrangement, loi de R degeneree (variance nulle), test non applicable`. Pour `Runsr`, cause lue sur `u` avec `plancher = plancher_u`, ou par `eff_u`.

**Ligne Merz-Wüthrich** (« Test des suites sur les residus de Mack ») : `detail_ru` (aujourd'hui `""`) prend la phrase de la cause :
- `Un seul cote de la mediane represente : loi de R non definie.`
- `Une seule valeur de chaque cote de la mediane (n1 = n2 = 1) : R = 2 pour tout arrangement, loi de R degeneree (variance nulle).`

**`.runs_z()` inchangée : confirmé** (garde dans `test_runs()` avant l'appel ; `.runs_extremes()` traite déjà la variance nulle, l. 3771). À contrôler : `Runs` et `Runsr` du catalogue appellent `test_runs()` ; une réplication à n1 = n2 = 1 passerait de NaN à NA dans les objets du bootstrap (improbable à T = 8, absent des références) : `identical()`.

Hors périmètre : branche 2b de `detail_runsr` (l. 7028-7030) paraît inatteignable ; à signaler à `audit`.

---

## 5. #521 : `mention_r7()` (complet, sans avis de fond)

Équivalence de deux prédicats : dans la branche atteinte, `diff(range(x)) == 0` ⇔ `isTRUE(regime$volumes_constants) && !isTRUE(regime$volumes_dans_bande)` (même `x` : l. 5490, 5526 ; `usp_volumes_constants()` : `diff(range(x)) <= tol * mean(x)`, `mean(x) > 0`). Hypothèse : volumes strictement positifs et finis (garantis par `engine_valider_donnees()`, pas pour un appel direct non validé). Critères de l'issue suffisants.

---

## Questions au mainteneur

1. QA1 (#485) : (a), (b) ou (c) ; recommandation (a).
2. #469 point 2, pour information : diagnostic d'office, aucun verdict changé sur les fixtures.

## Retour

- **Statut** : revue requise, limité à QA1 ; le reste complet.
- **Preuves** : lecture du code (lignes citées) ; `Rscript` (dénominateur ≤ 0 dès T = 35 ; Z signée = +35,9 ; `test_anscombe_kurt(rep(c(-1,1),20))` → NaN ; `test_runs(c(1,2,2,2,3))` → NaN) ; algèbre (H = N − 1 ; V = 0 ⇔ n1 = n2 = 1 ; équivalence de #521).
- **Non vérifié** : Anscombe et Glynn (1983) ; D'Agostino, Belanger et D'Agostino (1990).
- **Critères** : source introuvable (§ 4.4) ; changement de résultat hors références si QA1 (c).
