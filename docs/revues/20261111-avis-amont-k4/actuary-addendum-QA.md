# K4, étape 2 : addendum Q-A et Q-C (champ `loi` des lignes non applicables, #533)

> *Rédigé par l'agent actuary (IA), le 11/11/2026, en relance ciblée après la décision du mainteneur du même jour : l'harmonisation du champ `loi` sur **toutes** les lignes non applicables entre dans K4 (#533), contre mon avis, et c'est acté ; Q-C : `NA_character_` sur les deux lignes de suites. Aucun fichier du dépôt n'a été modifié.*

## 1. Règle

**Une ligne de `type = "non applicable"` a `loi = NA_character_`, sans exception et sans chaîne de remplacement.**

Fondement (*vérifié*) :
- Depuis #427 (Q-47-7 (a), `CONTEXT.md`, « Ligne non applicable »), une ligne non applicable ne restitue **aucune** p-value : `p_exacte`, `p_asymptotique`, `p_mc` et `p_retenue` valent `NA`.
- Le champ `loi` décrit la loi de référence d'une p-value. Sans p-value, aucune loi de référence ne sert ; un libellé qui en nomme une (« exacte », « asymptotique », « -> Monte-Carlo ») qualifie une p-value absente.
- Le motif, obligatoire, est déjà dans le `detail`.
- C'est la forme déjà en vigueur sur six sites : Student, Fisher, R², D'Agostino (T < 8), Anscombe-Glynn hors π̂_t variable, distance de Cook.
- Une chaîne neutre unique (« sans objet ») n'apporterait rien de plus que le type et le motif. Une chaîne par ligne multiplierait les textes à maintenir.

Mise en œuvre : **ligne par ligne, au point où chaque garde pose le type**, comme pour les p-values (Q-47-7 (a)), sous la forme `loi = if (<condition non applicable>) NA_character_ else <libelle actuel>`. La condition est celle du champ `type` de la même ligne ; la calculer une fois évite de la dupliquer. Aucune règle générale de post-traitement dans `usp_tests()` ou `mw_tests()`.

## 2. Valeur cible ligne par ligne

### 2.1 Les 15 lignes de `na17.R`, plus les deux lignes de suites (entrée de l'étape 1, T = 5, volumes constants, n1 = n2 = 1)

| # | Ligne | Site (`R/engine.R`) | `loi` actuel en non applicable | Cible |
|---|---|---|---|---|
| 1 | Nullite de la constante (proportionnalite stricte) | add l. 5921, type l. 5924 | « t(%d) sous le modele auxiliaire pondere (poids estimes : loi approchee meme sous ce modele) ; non retenue » | `NA_character_` |
| 2 | Equivalence de la constante a zero (TOST) | type l. 5961, loi l. 5975 | « t(%d) sous le modele auxiliaire pondere (poids estimes : loi approchee) ; marge ... » | `NA_character_` |
| 3 | Test de Pitman sur la pente (lien positif pertes / volume) | type `type_pente` l. 6089, loi l. 6142 | « loi de permutation de t (enumeration des T! appariements) » ou « (permutations aleatoires) » | `NA_character_` |
| 4 | Test de Student sur la pente (modele auxiliaire MCO) | l. 6175-6181 | déjà `NA_character_` | inchangé |
| 5 | Test de Fisher (significativite globale) | l. 6199-6204 | déjà `NA_character_` | inchangé |
| 6 | Coefficient de determination R2 | l. 6216-6219 | déjà `NA` (aucun `loi` passé) | inchangé |
| 7 | RESET (forme fonctionnelle) | l. 6238-6240 | « F(2,%d) approx. » | `NA_character_` |
| 8 | Independance ratio S/P vs volume | branche non applicable l. 6274-6282 | `loi_r7("permutation exacte (T <= 9, sans ex aequo)", ...)` | `NA_character_` (la branche est toujours non applicable : écrire directement `loi = NA_character_`) |
| 9 | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | type l. 6411, loi l. 6412-6413 | « chi2(1) asymptotique » | `NA_character_` |
| 10 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | l. 6427-6430 | « chi2(1) asymptotique, SOUS NORMALITE » | `NA_character_` |
| 11 | Heteroscedasticite (forme quadratique) | l. 6443-6446 | « chi2(2) asymptotique » | `NA_character_` |
| 12 | Egalite des variances petits vs gros volumes | l. 6456-6459 | « F(%d,%d) approx. (residus issus d'un ajustement global) » | `NA_character_` |
| 13 | Homogeneite des dispersions (mediane) | l. 6469-6472 | « F(1,%d) approx. » | `NA_character_` |
| 14 | Asymetrie (D'Agostino, T >= 8) | l. 6730-6733 | déjà `NA` | inchangé |
| 15 | Aplatissement (Anscombe-Glynn, T >= 20), branche T < 20 ou b2 / Z non définis | l. 6770-6786 | déjà `NA` | inchangé |
| 16 | Test des suites (aleatoire des signes) | l. 6839-6843 | « loi combinatoire EXACTE de R » | `NA_character_` (Q-C) |
| 17 | Test des suites sur ratios bruts | l. 7212-7222 | « loi classique INDICATIVE (ratios heteroscedastiques) -> Monte-Carlo » | `NA_character_` (Q-C ; code du § 4 de l'avis) |

### 2.2 Autres lignes non applicables recensées par lecture du code

Recensement par `grep '"non applicable"'` et lecture de chaque site, *vérifié* ; aucune autre pose explicite dans `usp_tests()`, et aucune dans `mw_tests()`.

| # | Ligne | Site | `loi` actuel en non applicable | Cible |
|---|---|---|---|---|
| 18 | Egalite des lois petits vs gros volumes (2 ech.) (Smirnov), non calculable ou R13 | l. 6500-6506 | `loi_r7("exacte combinatoire (ks.test, sans ex aequo)", ...)` | `NA_character_` |
| 19 | Aplatissement (Anscombe-Glynn, T >= 20), branche T ≥ 20 et π̂_t variable | l. 6759-6766 | « N(0,1) approx. (Wilson-Hilferty) » | `NA_character_` |
| 20 | Points influents (distance de Cook), D_t non finie | l. 7076-7078 (`.usp_ligne_cook()`, l. 5570) | déjà `NA` (aucun `loi` passé) | inchangé |
| 21 | Rapport de vraisemblance : delta = 0 (variance lineaire en volume), LR non fini | l. 7452-7460 | `loi_lr` (« sous H0 : loi simulee par bootstrap parametrique restreint ... ; asymptotique : melange 1/2 chi2(0) + 1/2 chi2(1), non retenue ») | `NA_character_` |
| 22 | Rapport de vraisemblance : delta = 1 (variance quadratique en volume), LR non fini | même site | `loi_lr` | `NA_character_` |

### 2.3 Lignes rendues non applicables par `add()` (règle R3), en lognormale **et** en Merz-Wüthrich

`add()` (l. 4631-4634) rend non applicable toute ligne de `type = "test"` dont la p Monte-Carlo manque avec le motif `MOTIF_MC_OBS_NON_FINIE` et qui n'a pas de p exacte. Elle garde alors le `loi` reçu de l'appelant.

- **Portée** (*vérifié* par lecture) :
  - toutes les lignes lognormales à `mc_nom`, y compris celles que `type_diag()` laisse en « test » quand `stat_definie()` est fausse : Kolmogorov-Smirnov, Cramér–von Mises, Breusch-Pagan 1979, White, Goldfeld-Quandt, Brown-Forsythe, Smirnov, Spearman ratio / temps, les lignes R15 sur ratios bruts ;
  - **toutes** les lignes Monte-Carlo de `mw_tests()` : c'est la seule voie par laquelle une ligne Merz-Wüthrich devient non applicable (commentaire l. 12850-12853, *vérifié*).
- **Atteignabilité** : couverte par les tests à bootstrap fictif (`tests/unitaires/test_non_applicable.R`, `test_volumes_constants.R`, motif posé sur les statistiques non finies, *vérifié* par lecture). Pour un calcul réel, *hypothèse* : jeux dégénérés seulement. Mes trois jeux (pertes constantes, T = 5, triangle à colonnes dégénérées) n'en ont produit aucune (`na_jeux.R`).
- **Cible** : `NA_character_`. Le seul point de production est la branche R3 d'`add()`, avec une affectation, `loi <- NA_character_`, à côté de `type <- "non applicable"` (l. 4633). C'est bien « le point où la garde pose le type » ; aucun autre site ne permet de le faire sans règle générale.
- **Conflit avec le plan adopté** : la fiche K4 dit « `add()` n'est pas modifiée (K3b) ». La décision du mainteneur (« toutes les lignes ») ne peut donc être tenue entièrement **qu'en touchant `add()`**. Question nouvelle au mainteneur (Q-A2, § 5). Si elle est refusée, les lignes R3 sont l'exception à la règle, et `CONTEXT.md` ainsi que le `.tex` doivent le dire.

## 3. Références : aucun patch

*Vérifié* (`Rscript` sur `tests/reference/*.rds`) : les six références ne portent qu'une ligne non applicable par cas lognormal, « Aplatissement (Anscombe-Glynn, T >= 20) », branche T < 20, avec `loi = NA` déjà. `reserve2` n'en porte aucune (25 lignes, aucune non applicable).

Champ `loi` : **0 champ à patcher**, dans aucun des six cas. `comparer_references.R` doit rendre des références identiques pour ce commit. Le rapport figé des six cas est inchangé pour la même raison (*hypothèse* : il se construit sur ces objets).

## 4. Fixtures et affichage

**Fixtures de `tests/unitaires/`** :
- **Certaine** : `tests/unitaires/test_statistiques.R:215`, `identical(l$loi, "N(0,1) approx. (Wilson-Hilferty)")` sur la ligne Anscombe-Glynn non applicable à π̂_t variable (ligne 19), doit devenir `identical(l$loi, NA_character_)`.
- `test_inoperance.R:945` lit déjà `NA_character_` (ligne déjà à `NA`) : inchangée.
- *Hypothèse* : d'autres assertions lisent `$loi` sur des lignes qui peuvent être non applicables dans leur jeu (`test_constante_ponderee.R:132-155`, `test_textes_inconditionnels.R:114-152`, `test_lois_exactes.R:409`, `test_merz_wuthrich_suite.R` (l. 1607, 1811, 1910, 2208), `test_m5_diagnostic.R` (l. 60, 71)). D'après les intitulés, elles visent des lignes applicables ; `coder` doit le confirmer en lançant la batterie.
- À ajouter : un test d'invariant dans `test_non_applicable.R`, « toute ligne non applicable a `loi` NA » (sur les jeux de ce fichier et sur l'entrée de #533).

**Affichage** :
- `app.R` ne lit pas `loi` (*vérifié*, `grep`).
- `R/display_helpers.R:621` restitue `loi_sous_H0` (colonne « Loi sous H0 », alimentée par `engine_table_tests()`, l. 14754) par `.txt()`, qui rend « – » pour `NA` (l. 2931).
- Effet visible : un tiret au lieu du libellé sur les lignes non applicables seulement. Aucun code d'affichage ne change ; c'est hors périmètre d'`app-review`, sauf constat léger si la session le souhaite.

**Documentation** :
- `CONTEXT.md`, « Ligne non applicable » : y ajouter la règle `loi = NA` (`architect`).
- `.tex` : la description du champ `loi` et les fiches qui citent le libellé d'une ligne non applicable (l. 8499 pour les suites) : surface documentaire de `docwriter`, étape 10.

## 5. Questions résiduelles

- **Q-A2 (mainteneur)** : autoriser une affectation dans la branche R3 d'`add()` (l. 4633), contraire au trait « `add()` n'est pas modifiée (K3b) » de la fiche K4 ? Sans elle, la règle ne vaut pas pour les lignes R3, et c'est le cas de toutes les lignes non applicables de Merz-Wüthrich. Mon avis : l'autoriser, parce que c'est le seul point de production. Le changement est d'une ligne, sans effet sur les références ni sur un verdict. `add()` étant un contrat partagé, il passe par `coder-approfondi` et un `audit`.
- Aucun σ_USP, aucune p-value ni aucun verdict ne change. Aucun texte ne change la lecture d'un verdict (les lignes non applicables n'en ont pas).

## Retour

- **Statut** : complet ; le recensement de la R3 en calcul réel est une hypothèse.
- **Résultat** : `loi = NA_character_` sur toute ligne non applicable. 15 sites à modifier dans `usp_tests()` (lignes 1, 2, 3, 7, 8, 9 à 13, 16, 17, 18, 19 du tableau, et le site commun des lignes 21 et 22), plus la branche R3 d'`add()` sous réserve de Q-A2. Aucun patch de référence ; une fixture certaine (`test_statistiques.R:215`) ; affichage changé d'un tiret, sans code touché.
- **Preuves** : *vérifiées* : sites (`grep` et lecture) ; contenu des six références (`Rscript`) ; lecteurs de `loi` (`grep` dans `app.R`, `R/display_helpers.R`) ; la fixture l. 215. *Hypothèses* : les autres fixtures ; l'atteignabilité réelle de R3. Scripts : `docs/revues/20261111-avis-amont-k4/scripts-actuary/na17.R`, `na_jeux.R`.
- **Critères déclenchés** : désaccord avec le plan adopté (`add()` hors périmètre) ; contrat partagé (`add()`).
- **Prochaine action** : porter Q-A2 au mainteneur, puis l'étape 6 (#533) en `coder-approfondi`.
