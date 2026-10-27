# Vérification des références externes de la branche Fn (Davison et Hinkley, 1997)

> *Rédigé par Claude (session de relevé groupé des sources, à accès internet par le proxy de la session), le 25/10/2026. Commande de la session principale de Fk, sur ordre du mainteneur du 25/10/2026 (décision Q-41-7 ; brief du commentaire `6388285797` de la PR #374). Relevé versé sur la branche `claude/lecture-conjointe-familles` (PR brouillon #374), à reprendre par la branche Fn.* Forme reprise de `docs/references/verifications-fj.md`.

## Objet

Davison, A. C. et Hinkley, D. V. (1997), *Bootstrap Methods and their Application*, Cambridge University Press, chap. 4 et 5-6, pour :

- l'intervalle « basic » et l'intervalle de percentile (issue #305, point 4) ;
- les enveloppes ponctuelle et simultanée du QQ-plot (chap. 4) ;
- le bootstrap paramétrique sous le modèle nul ajusté (chap. 4).

**Relevé du 25/10/2026 : le texte n'a pas pu être lu** (§ 2). **Relevé du 27/10/2026 : pages utiles lues dans l'aperçu Google Books de l'ouvrage et d'Efron et Tibshirani (1993)** (section « Relevé du 27/10/2026 », en fin de fichier ; tableau récapitulatif mis à jour). Au 25/10, seuls la notice et la table des matières étaient vérifiés sur pièce (statuts du 27/10 : tableau « Statuts au 27/10/2026 ») ; les renvois de la documentation du paquet R *boot* (des mêmes auteurs) sont relevés comme sources secondaires (§ 3).

Les numéros de ligne citent la tête `269883a` de la branche `claude/lecture-conjointe-familles`.

## Méthode et statuts

Statuts de `verifications-fj.md` : **[V]** vérifié sur le texte ; **[P]** vérification partielle (notice, table des matières ou source secondaire lue sur pièce, raison donnée) ; **[X]** affirmation fausse, non trouvée, ou écart ; **[NV]** non vérifié (raison donnée). Aucun fichier source déposé dans le dépôt. Relevé du 25/10 : aucune formule n'est rapportée, aucune n'ayant pu être lue dans l'ouvrage ; relevé du 27/10 : formules lues sur le rendu graphique des pages (section « Relevé du 27/10/2026 »).

## Sources consultées (25/10/2026)

| Source | Accès | Contenu lu |
|---|---|---|
| Cambridge Core, page de l'ouvrage : `https://www.cambridge.org/core/books/bootstrap-methods-and-their-application/ED2FD043579F27952363566DC09CBD6A` | libre (HTTP 200) pour la page ; **chapitres payants** (« Get access ») | notice, DOI 10.1017/CBO9780511802843, table des matières avec pages |
| Texte des chapitres 4, 5 et 6 | **non obtenu** | accès sur abonnement ou achat seulement ; aucune version en libre accès ; aucune copie tierce cherchée ni utilisée |
| Paquet R *boot*, version 1.3-32 (29/08/2025), fichiers `man/envelope.Rd` et `man/boot.ci.Rd` du miroir CRAN `https://raw.githubusercontent.com/cran/boot/master/` | libre | sections `details`, `references`, `examples` (source secondaire : la documentation renvoie à l'ouvrage) |

---

## Tableau récapitulatif

| # | Affirmation | Lieu dans le dépôt | Ce qui est vérifié | Statut |
|---|---|---|---|---|
| 1 | Notice : Davison et Hinkley, *Bootstrap Methods and their Application*, CUP, 1997 | `doc_tests_usp.tex:12503-12504`, `:18651-18652` | Cambridge Core | [V] |
| 2 | Chap. 4 = tests ; bootstrap paramétrique sous le modèle nul ajusté | `doc_tests_usp.tex:12566`, `:18656-18658` ; `R/engine.R:6722`, `:6743` | titre du chap. 4 (« Tests », p. 136-190) seulement | [P] |
| 3 | Enveloppe simultanée (« globale ») du QQ-plot, chap. 4 | `doc_tests_usp.tex:13262-13267`, `:18696` ; `R/engine.R:7476` | documentation de `boot::envelope` : éq. (4.17), exemples 4.7 et 4.8 | [P] |
| 4 | Enveloppe ponctuelle : quantiles de chaque colonne | `doc_tests_usp.tex:13261` | documentation de `boot::envelope` | [P] |
| 5 | Intervalles « basic » et de percentile | issue #305, point 4 ; `doc_tests_usp.tex:12910`, `:12958` | documentation de `boot::boot.ci` : chap. 5 ; titre du chap. 5 (« Confidence Intervals », p. 191-255) | [P] |
| 6 | Chap. 6 (régression linéaire), redressement des résidus par le levier | `bloc-5.md:121` (demande de vérification) | titre du chap. 6 (« Linear Regression », p. 256-325) seulement | [NV] pour le contenu |
| 7 | Formules, pages précises, conditions de validité à petit échantillon | — | — | [NV] |

### Statuts au 27/10/2026 (relevé du 27/10, en fin de fichier ; ancien → nouveau)

Les lieux du dépôt sont cités sur la tête `2295d97` de la branche `claude/incertitude-bootstrap-graphiques`.

| # | Affirmation | Lieu (tête `2295d97`) | Ce qui est vérifié le 27/10 | Statut |
|---|---|---|---|---|
| 1 | Notice Davison et Hinkley (1997) | `doc_tests_usp.tex:12695-12696`, `:19361-19362` | inchangé | [V] → [V] |
| 2 | Chap. 4 : bootstrap paramétrique sous le modèle nul ajusté | `doc_tests_usp.tex:12760`, `:19366-19368` | § 4.2.3 « Parametric bootstrap tests », p. 148, éq. (4.13) | [P] → **[V]** |
| 3 | Enveloppe simultanée (« globale ») du QQ-plot, chap. 4 | `doc_tests_usp.tex:13456-13461`, `:19406` ; `R/engine.R:7843-7863` | § 4.2.4, p. 152-154, éq. (4.16)-(4.17), ex. 4.7-4.8 ; code de `boot::envelope` | [P] → **[V]** pour le rattachement au chap. 4 ; **[X]** pour « celle de la fonction *envelope* » : décalage d'un rang (R27.3) |
| 4 | Enveloppe ponctuelle : quantiles de chaque colonne | `doc_tests_usp.tex:13455` | p. 152 : bornes t\*₍ₖ₎(a), t\*₍R+1−k₎(a), k/(R+1) = p | [P] → **[V]** (au choix du quantile près, R27.3) |
| 5 | Intervalles « basic » et de percentile | issue #305, point 4 ; `doc_tests_usp.tex:13104`, `:13152` | D-H § 5.2, éq. (5.6), p. 194 ; § 5.3.1, éq. (5.18), p. 203 ; § 5.4.1, p. 213-214 ; E-T § 13.3, éq. (13.3)-(13.4), p. 170 ; § 13.4, éq. (13.9), p. 174 | [P] → **[V]** |
| 5a | Couverture à petit échantillon, effet du biais (D1-Fn) | issue #305 ; `doc_tests_usp.tex:13152-13154` | D-H p. 202, 203, 211-214 ; E-T p. 175-176 | nouveau : **[V]** (ce que disent les ouvrages ; aucun résultat à T = 8) |
| 6 | Chap. 6 : redressement des résidus par le levier | `bloc-5.md:7`, `:21` ; `doc_tests_usp.tex:4508-4521` | § 6.2.1, éq. (6.9), p. 259 ; algorithme 6.1, p. 262 | [NV] → **[V]** pour la formule de régression linéaire ; transposition au modèle de Mack : dérivation du dépôt, non de l'ouvrage |
| 7 | Formules, pages, conditions à petit échantillon | — | pages ci-dessus | [NV] → **[V]** pour les points 2 à 6 ; [NV] pour le reste de l'ouvrage (pages non relevées, p. 197-198 absentes de l'aperçu) |
| 8 | Efron et Tibshirani (1993) : intervalle de percentile, intervalle « basic », correction de biais | issue #305, point 4 ; `doc_tests_usp.tex:12299` (autre renvoi, non relu ici) | chap. 13, p. 168-177 ; chap. 14, p. 185-186 | nouveau : **[V]** ; le terme « hybrid » n'est **pas** trouvé dans les pages lues [NV] |

---

## 1. Notice et table des matières [V]

> A. C. Davison et D. V. Hinkley, *Bootstrap Methods and their Application*, Cambridge University Press, 1997, DOI 10.1017/CBO9780511802843 (594 p. selon la fiche de l'éditeur).

Table des matières (Cambridge Core) :

| Chapitre | Pages |
|---|---|
| 1 — Introduction | 1-10 |
| 2 — The Basic Bootstraps | 11-69 |
| 3 — Further Ideas | 70-135 |
| 4 — Tests | 136-190 |
| 5 — Confidence Intervals | 191-255 |
| 6 — Linear Regression | 256-325 |
| 7 — Further Topics in Regression | 326-384 |
| 8 — Complex Dependence | 385-436 |
| 9 — Improved Calculation | 437-498 |
| 10 — Semiparametric Likelihood Inference | 499-521 |
| 11 — Computer Implementation | 522-550 |

La notice du `.tex` (l. 12503-12504 et 18651-18652 : auteurs, titre, Cambridge University Press, 1997) est **exacte**. Le `.tex` ne donne pas de pages ; s'il en donne, celles de la table ci-dessus sont vérifiées.

## 2. Texte des chapitres 4 à 6 [NV au 25/10 ; dépassé par le relevé du 27/10, R27.2 à R27.4]

Chapitres derrière « Get access » sur Cambridge Core (abonnement institutionnel ou achat). Aucune autre voie légitime trouvée. **Aucune formule, aucune page intérieure et aucune citation de l'ouvrage n'est donc rapportée.**

Conséquence : les renvois du `.tex` à « Davison et Hinkley (1997, chap. 4) » (l. 12504, 12566, 13262, 18658, 18696) restent à dater « non relu sur le texte intégral » au sens de Q-Fc-10 et Q-37-10 (calendrier : « Davison et Hinkley (1997) avant Fk », non satisfait), sauf fourniture du livre par le mainteneur. *Dépassé le 27/10/2026* : les pages des chap. 4 à 6 utiles au dépôt ont été lues dans l'aperçu Google Books (R27.2 à R27.4) ; la phrase datée « non relu » ne vaut plus pour les points 2 à 6 et 8 du tableau du 27/10, et reste pour les pages non lues (R27.6).

## 3. Sources secondaires : documentation du paquet *boot* [P]

Le paquet *boot* est le code d'accompagnement de l'ouvrage. Sa documentation n'est pas l'ouvrage : elle donne des renvois, pas des énoncés vérifiés.

### 3.1 `envelope` (enveloppes de courbe)

- `details` : « The pointwise envelope is found by simply looking at the quantiles of the replicates at each point. The overall error for that envelope is then calculated using equation (4.17) of Davison and Hinkley (1997). A sequence of pointwise envelopes is then found until one of them has overall error approximately equal to the level required. »
- `examples` : « Testing whether the final series of measurements of the gravity data may come from a normal distribution. This is done in Examples 4.7 and 4.8 of Davison and Hinkley (1997). »

**Confrontation au dépôt.**

- `doc_tests_usp.tex:13262-13267` : bande simultanée « enveloppe globale de Davison et Hinkley (1997, chap. 4), celle de la fonction *envelope* du paquet *boot*, réécrite dans le moteur », k* le plus grand k tel que la proportion des lignes ayant une valeur hors bande ne dépasse pas 0,10. Le rattachement au **chap. 4** concorde avec la documentation (éq. (4.17), exemples 4.7-4.8, numérotés dans le chap. 4). **[P]** : cohérent, non lu dans l'ouvrage.
- Nuance de lecture, sans [X] : la documentation dit que l'erreur globale de l'enveloppe est rendue « approximately equal to the level required » par une suite d'enveloppes ponctuelles ; le `.tex` décrit une règle « ne dépasse pas 0,10 ». Que `boot::envelope` choisisse la dernière enveloppe sous le niveau ou la plus proche n'est pas dit dans la documentation lue ; la conformité de la réécriture du moteur à `boot::envelope` relève d'un test du code, pas de ce relevé.
- `doc_tests_usp.tex:13261` (bande ponctuelle, quantiles 5 % et 95 % de chaque colonne) : conforme à « quantiles of the replicates at each point » [P].

### 3.2 `boot.ci` (intervalles « basic » et de percentile)

- `description` : « the first order normal approximation, the basic bootstrap interval, the studentized bootstrap interval, the bootstrap percentile interval, and the adjusted bootstrap percentile (BCa) interval ».
- `details` : « The formulae on which the calculations are based can be found in Chapter 5 of Davison and Hinkley (1997). »
- `references` : « Davison, A.C. and Hinkley, D.V. (1997) *Bootstrap Methods and Their Application*, Chapter 5. »

**Confrontation au dépôt.** L'issue #305 (point 4) oppose l'intervalle de percentile, [q̂_{α/2}, q̂_{1−α/2}] (`doc_tests_usp.tex:12910`), à l'intervalle « basic » ; elle ne cite pas Davison et Hinkley mais Efron et Tibshirani (1993). Si Fn cite Davison et Hinkley pour l'un ou l'autre, le renvoi est le **chap. 5** (et non le chap. 4 ni le chap. 6) [P]. **La formule de l'intervalle « basic » n'est pas rapportée ici** : elle n'a pas été lue dans l'ouvrage.

### 3.3 Bootstrap paramétrique sous le modèle nul ajusté

`doc_tests_usp.tex:12566` et `:18656-18658` attribuent au chap. 4 le test par bootstrap paramétrique sous le modèle nul ajusté (rapport de vraisemblance sur δ ; `R/engine.R:6722`, `:6743`, champ `reference`). Le titre du chap. 4 (« Tests ») est compatible ; le contenu n'est pas lu. **[P]**, sans écart constaté.

### 3.4 Chap. 6 et redressement par le levier

`bloc-5.md:121` demande de « faire vérifier Davison & Hinkley (1997, chap. 6) pour le redressement par le levier (l. 4149) » ; `bloc-5.md:142` note que « la formule de Davison & Hinkley est de mémoire ». Le chap. 6 est bien « Linear Regression » (p. 256-325) ; la formule n'est **pas** vérifiée [NV].

---

## Voie d'accès

Achat des chapitres 4, 5 et 6 sur Cambridge Core, accès institutionnel, ou prêt de l'ouvrage (Q-37-10 ; commentaire `6238477255` de la PR #332, n° 4). Le présent relevé ne lève pas la condition « Davison et Hinkley (1997), chap. 4 et 6, avant Fk ».

*Aucune page, équation ni citation de l'ouvrage n'a été rapportée sans avoir été lue ; les numéros (4.17), 4.7 et 4.8 viennent de la documentation de* boot*, citée comme telle.*

---

# Relevé du 27/10/2026

> *Rédigé par Claude (session de relevé de sources, accès internet par le proxy de la session), le 27/10/2026, sur commande de la session principale de Fn et décision du mainteneur du 27/10/2026 (Q-42-12). Branche `claude/incertitude-bootstrap-graphiques` (PR brouillon #384). Le relevé du 25/10 ci-dessus est conservé tel quel ; les statuts nouveaux sont dans le second tableau récapitulatif.*

## R27.1 Sources consultées et méthode

| Source | URL essayée | Résultat |
|---|---|---|
| Google Books, Davison et Hinkley (1997), identifiant `4aCDbm_t8jUC` | `https://books.google.com/books?id=4aCDbm_t8jUC&pg=PA<n>` | HTTP 200 ; **aperçu limité autorisé par l'éditeur** (« Pages displayed by permission of Cambridge University Press ») ; pages lues : 148-149, 151-156, 193-196, 202-203, 211-215, 258-263 ; p. 197-198 absentes de l'aperçu (la visionneuse saute de 196 à 199) |
| Google Books, Efron et Tibshirani (1993), identifiant `gLlpIUxRntoC` | `https://books.google.com/books?id=gLlpIUxRntoC&pg=PA<n>` | HTTP 200 ; aperçu limité ; pages lues : 167-177, 180, 183-186 |
| Google Books, recherche dans le livre | `https://books.google.com/books?id=4aCDbm_t8jUC&q=percentile+method` | redirection vers `https://www.google.com/sorry/…` (CAPTCHA anti-robot) : **non contournée** ; navigation par numéro de page seulement, à faible cadence |
| API Google Books | `https://www.googleapis.com/books/v1/volumes?q=…` | HTTP 429 (quota) |
| Internet Archive, Efron et Tibshirani (1993) | `https://archive.org/details/introductiontobo0000efro` (métadonnées : `https://archive.org/metadata/introductiontobo0000efro`) | notice présente, `access-restricted-item: true` (prêt contrôlé, compte et emprunt nécessaires) : **non lu** |
| Internet Archive, Davison et Hinkley (1997) | `https://archive.org/advancedsearch.php?q=title:(bootstrap) AND creator:(davison)` | HTTP 200, **aucun exemplaire** |
| Cambridge Core | page de l'ouvrage (§ « Sources consultées (25/10/2026) ») | HTTP 200, chapitres toujours payants |
| Paquet *boot*, code source de `envelope()` | `https://raw.githubusercontent.com/cran/boot/master/R/bootfuns.q` (miroir CRAN) | HTTP 200, lignes 1872-1930 lues (R27.3) |

Méthode : chaque page a été rendue par Chromium (Playwright) et lue **sur l'image** (capture de l'élément-page de la visionneuse, échelle 2) ; aucune extraction de texte ni OCR. Aucune copie pirate cherchée ni utilisée. Aucun fichier source ni capture déposé dans le dépôt. Les citations sont courtes, en anglais ; les formules sont transcrites depuis l'image dans la notation de l'ouvrage.

Notation des deux ouvrages : un intervalle de niveau 1 − 2α (α par queue), là où la documentation du dépôt écrit 1 − α (α/2 par queue).

## R27.2 Davison et Hinkley (1997), chap. 5 — intervalles « basic » et de percentile [V]

### Intervalle « basic » (§ 5.2.1, p. 193-195)

- P. 193, point de départ : si a_p sont les quantiles de T − θ, l'intervalle équilibré de niveau 1 − 2α a pour bornes
  θ̂_α = t − a_{1−α}, θ̂_{1−α} = t − a_α — **éq. (5.3)**.
- P. 194, « Basic and studentized bootstrap methods » : les quantiles a_α, a_{1−α} sont estimés par ceux de T\* − t, d'où
  **θ̂_α = 2t − t\*₍(R+1)(1−α)₎, θ̂_{1−α} = 2t − t\*₍(R+1)α₎ — éq. (5.6)**, « These we refer to as the *basic bootstrap confidence limits* for θ ».
- P. 194-195 : (5.6) suppose (R + 1)α entier (« with R = 999 we can handle most conventional values of α ») ; sinon, interpolation sur l'échelle des quantiles normaux, **éq. (5.8)**, en échec si k = 0, R ou R + 1.
- P. 195, éq. (5.10) : version sur une échelle transformée, θ̂_α = h⁻¹{2h(t) − h(t\*₍(R+1)(1−α)₎)} ; « The accuracy of the basic bootstrap confidence limits (5.6) will also tend to be improved by use of such a transformation. »
- P. 202 (§ 5.2.3) : « if confidence levels 0.95 and 0.99 are to be used, then it is advisable to have R = 999 or more, if practically feasible ».

### Intervalle de percentile (§ 5.3.1, p. 202-203)

- Dérivation : on suppose une transformation inconnue U = h(T) de loi **symétrique** ; la symétrie (a_α = −a_{1−α}) appliquée à (5.6) sur l'échelle de U donne, ramené à l'échelle de θ,
  **t\*₍(R+1)α₎, t\*₍(R+1)(1−α)₎ — éq. (5.18)**, « known as the *bootstrap percentile interval* ».
- P. 203 : « the method turns out not to work very well with the nonparametric bootstrap even when a suitable transformation h does exist ».
- Exemple 5.4 (p. 203) : sur les données de climatisation, les intervalles de percentile, paramétrique et non paramétrique, « Neither is satisfactory » comparés à l'intervalle « basic » sur l'échelle logarithmique.

### Effet du biais (§ 5.3.2, p. 203)

« For the percentile method to work well, it would be necessary that T be unbiased on the transformed scale, so that the swap of quantile estimates be correct. This does not usually happen. » La méthode porte en outre le défaut de la méthode « basic » : la forme de la loi de T change quand la loi d'échantillonnage passe de F à F̂. D'où la méthode ajustée (BC_a), modèle (5.19) : U ~ N(φ − wσ(φ), σ²(φ)), σ(φ) = 1 + aφ, w facteur de correction de biais, a facteur d'asymétrie.

### Précision de la couverture (§ 5.4.1, p. 211-214)

- Cadre : développements à l'ordre n^{−1/2} (Cornish-Fisher, éq. (5.30)-(5.34)) ; « equality is correct to order n^{−1/2}, i.e. ignoring errors of order n^{−1} ».
- P. 212 : limite studentisée, Pr(θ ≤ θ̂_α) = α + O(n⁻¹), « second-order accuracy » ; approximation normale : α + O(n^{−1/2}).
- P. 213, « Basic and percentile methods » : « the basic bootstrap and percentile confidence limits are only first-order accurate. However, they are both superior to the normal approximation limits, in the sense that equi-tailed confidence intervals are second-order accurate. » Pour l'intervalle « basic » 2t − Ĝ⁻¹(1 − α), 2t − Ĝ⁻¹(α), erreur de chaque borne : Pr{θ ≤ 2t − Ĝ⁻¹(1 − α)} = 1 − Φ(z_{1−α} + n^{−1/2} m₁₁ z²_{1−α}) et Pr{θ ≥ 2t − Ĝ⁻¹(α)} = Φ(z_α + n^{−1/2} m₁₁ z²_α) ; les termes en n^{−1/2} se compensent sur la couverture bilatérale (= 2α à cet ordre).
- P. 214 : « only the adjusted percentile and studentized bootstrap methods correctly adjust for the effects of bias, nonconstant variance, and skewness ».

### Comportement observé à petit échantillon (simulation de l'ouvrage, pas un théorème)

- P. 202 : 500 échantillons de taille 10 (données de villes), intervalles studentisés à 90 % ; l'intervalle « basic » sur l'échelle transformée couvre **86,4 %** (studentisés : 90,4 % et 88,2 %). Seul chiffre de couverture d'un intervalle « basic » à n = 10 relevé dans les pages lues ; il porte sur un autre problème que celui du dépôt.
- **Rien, dans les pages lues, ne chiffre la couverture à n = 8** ni pour un modèle lognormal à deux paramètres. Les ordres O(n^{−1/2}), O(n⁻¹) sont asymptotiques et ne disent rien du niveau à T = 8 (règle « Rigueur statistique » de `CLAUDE.md`).

### Confrontation au dépôt

- `doc_tests_usp.tex:13104` : [q̂_{α/2}, q̂_{1−α/2}] « intervalle de percentile » = (5.18) en notation 1 − α. **[V]**. Écart de convention à noter pour D1-Fn, sans [X] : l'ouvrage prend les statistiques d'ordre de rang (R + 1)α (avec (R + 1)α entier, sinon (5.8)), le dépôt des quantiles empiriques (type 7 à la l. 13455 pour l'enveloppe ; la fiche de l'intervalle n'est pas relue ici).
- `doc_tests_usp.tex:13152-13154` : « l'intervalle de percentile n'est corrigé ni du biais ni de l'asymétrie -- les variantes BCa seraient plus exactes » : conforme à p. 203 et p. 214 **[V]** (« plus exactes » = précision du second ordre, asymptotique).
- Issue #305, point 4 : la formule de l'intervalle « basic » est désormais vérifiée, **(5.6), p. 194** : bornes 2t − t\*₍(R+1)(1−α)₎ et 2t − t\*₍(R+1)α₎.

## R27.3 Davison et Hinkley (1997), chap. 4 — tests, enveloppes [V], un écart [X]

### Bootstrap paramétrique sous le modèle nul ajusté (§ 4.2.3, p. 148) [V]

« the natural approach is to fit the null model F̂₀ and use (4.5) to compute the P-value, i.e. p = Pr(T ≥ t | F̂₀) » ; « Calculation of the P-value by (4.5) is referred to as a bootstrap test. » Par simulation : **p_boot = (1 + #{t\*_r ≥ t})/(R + 1) — éq. (4.13)**. Exemple 4.5 : rapport de vraisemblance (4.14) entre familles séparées. Le renvoi de `doc_tests_usp.tex:12760` et `:19366-19368` (« bootstrap paramétrique sous le modèle nul ajusté », chap. 4) est **exact**. La forme exacte de la p-value du moteur n'est pas confrontée ici (hors objet).

### Enveloppes du graphique (§ 4.2.4, p. 151-154) [V]

- P. 151-152 : sous H₀, pour chaque a, Pr(T(a) < T\*₍ⱼ₎(a) | H₀) = j/(R + 1) (éq. (4.15)) ; on choisit k avec k/(R + 1) = p et l'enveloppe **ℰ^{1−2p} = {[t\*₍ₖ₎(a), t\*₍R+1−k₎(a)] : a ∈ 𝒜} — éq. (4.16)**, enveloppe ponctuelle de niveau bilatéral 2p en chaque a.
- Exemple 4.7 (p. 152) : QQ-plot normal de n = 13 valeurs studentisées, p = 0,05, R = 19, k = 1 (enveloppe = min et max).
- P. 153 : la probabilité que l'enveloppe ponctuelle contienne le graphe entier est « far less than 1 − 2p » ; dans l'exemple 4.7, « the chance is about 0.5 that some point will fall outside the simulation envelope, in contrast to the pointwise chance 0.1 ». Pour R : « for p = 0.05, say, R = 19 is too small: the test envelope is too random. R = 99 would seem to be a more sensible choice ». Paramètres inconnus non éliminables : simuler sous F̂₀, (4.15) alors « approximately true provided n is not too small ».
- P. 153, **éq. (4.17)** : taux d'erreur global bilatéral estimé par rééchantillonnage, en comparant chaque graphe simulé r à l'enveloppe ℰ^{1−2p}_{−r} tirée des R − 1 **autres** :
  **#{r : {t\*_r(a), a ∈ 𝒜} exits ℰ^{1−2p}_{−r}} / R**.
- P. 154 : équivalence de calcul : le graphe r sort de ℰ^{1−2p}_{−r} « if and only if rank{t\*_r(a)} ≤ k or rank{t\*_r(a)} ≥ R + 1 − k for at least one value of a, where as before k = p(R + 1) » ; rangs par colonne d'un tableau R × N.
- Exemple 4.8 (p. 154) : « an overall two-sided error rate of approximately 0.1 requires R = 199 » ; figure 4.5 : enveloppe externe de taux global 0,1, interne de taux ponctuel 0,1 ; « the empirical error rate (4.17) for the outer envelope is 0.10 ».
- P. 154 : aucune règle unique ne contrôle l'erreur ; « it seems wise to plot envelopes corresponding to both pointwise one-sided error rate p and simultaneous one-sided error rate p, say with p = 0.05 ».

### Confrontation au dépôt

- `doc_tests_usp.tex:13455` (bande ponctuelle, quantiles 5 % et 95 % de chaque colonne) : principe conforme à (4.16) **[V]** ; l'ouvrage prend les statistiques d'ordre de rang k et R + 1 − k avec k/(R + 1) = p, le dépôt le quantile empirique de type 7 (écart de convention, sans [X]).
- `doc_tests_usp.tex:13456-13461`, `:19406` : rattachement de l'enveloppe globale au **chap. 4** : **[V]** (§ 4.2.4, éq. (4.17), ex. 4.8).
- **[X] — écart de définition, à porter à `actuary` et `audit`** : le `.tex` (l. 13456-13461) dit la bande simultanée « celle de la fonction *envelope* du paquet *boot*, réécrite dans le moteur », k\* étant « le plus grand k tel que la proportion des lignes de S ayant au moins une valeur **strictement hors de la bande** ne dépasse pas 0,10 ». Le moteur (`R/engine.R:7843-7857`, `taux_hors()`) compare chaque ligne à la bande [Sc[k, ], Sc[B_eff + 1 − k, ]] **construite sur toutes les lignes, elle comprise**. Une ligne est strictement hors de cette bande si et seulement si l'un de ses rangs de colonne est **< k** ou **> B_eff + 1 − k** (hors ex aequo), c'est-à-dire ≤ k − 1 ou ≥ B_eff + 2 − k. Le critère de (4.17), p. 154, et celui de `boot::envelope` (code lu : `kf <- function(x, k, R) 1*((min(x) <= k)|(max(x) >= R+1L-k))`, `bootfuns.q:1888`) est rang **≤ k** ou **≥ R + 1 − k**. Le taux du moteur au rang k est donc celui de (4.17) au rang **k − 1** (au dénominateur près : B_eff dans le moteur et dans (4.17), R + 1 dans `boot::envelope`, `bootfuns.q:1889`), et le k\* du moteur est en général **supérieur d'une unité** à celui de `boot::envelope` : bande simultanée plus étroite d'un rang. Le commentaire du moteur le reflète : « k = 1 toujours admissible, taux 0 par construction » (`R/engine.R:7815-7817`), alors que (4.17) à k = 1 donne un taux positif (« about 0.5 » à l'exemple 4.7) et que `boot::envelope` avertit « unable to achieve requested overall error rate » quand le taux à k = 1 dépasse le niveau (`bootfuns.q:1907-1908`). L'optimisme mesuré par le moteur (« taux auto-évalué », niveau réel voisin de 89 % au défaut B = 999, `R/engine.R:7806-7810`) est cohérent avec ce décalage, sans qu'il soit établi ici qu'il en est la seule cause. Ce relevé **ne mesure rien** : effet chiffré, choix de la correction (passer à `<=`/`>=` ou garder la règle actuelle et corriger la phrase du `.tex`) relèvent d'une issue, rédigée ci-dessous pour accord du mainteneur.

**Issue proposée** (*créée le 27/10/2026 sur décision du mainteneur : #385, `needs-triage`, rattachée à Fg*) — titre : « Enveloppe simultanée du QQ-plot : règle de sortie décalée d'un rang par rapport à Davison et Hinkley (1997, éq. (4.17)) et à `boot::envelope` » ; libellés : `needs-triage` ; corps : constat ci-dessus (lieux `R/engine.R:7843-7857`, `doc_tests_usp.tex:13456-13461`, `boot/R/bootfuns.q:1888-1889`), question pour `actuary` (quelle règle retenir ; effet sur le niveau réel déjà mesuré par le moteur), surface : tableau avant / après si la bande change (sorties graphiques seulement, aucune p-value ni verdict, ADR 0001).

## R27.4 Davison et Hinkley (1997), chap. 6 — résidus modifiés par le levier [V]

- P. 259, § 6.2.1 : « the most useful modification for our purposes is to change them to have constant variance, that is **r_j = (y_j − μ̂_j)/(1 − h_j)^{1/2}** » — **éq. (6.9)** ; « We shall refer to these as *modified residuals* », à distinguer des « standardized residuals » qui sont en outre divisés par l'écart-type de l'échantillon. Variante plus simple : facteur (1 − 2n⁻¹)^{−1/2} (levier moyen), « very similar effect only if the leverages h_j are fairly homogeneous ».
- P. 260 : la variance par la méthode delta remplace e_j par r_j (« to account for leverage »).
- P. 262, **algorithme 6.1** (« Model-based resampling in linear regression ») : ε\*_j tirés au hasard parmi **r₁ − r̄, …, r_n − r̄** (résidus modifiés **recentrés**), y\*_j = β̂₀ + β̂₁x_j + ε\*_j ; « n⁻¹ Σ(r_j − r̄)² ≐ (n − 2)⁻¹ Σ e²_j = s² ».

**Confrontation au dépôt.** `bloc-5.md:7` demandait de vérifier « Davison & Hinkley (1997, chap. 6) pour le redressement par le levier » ; `bloc-5.md:21` tenait la formule r/√(1 − h) pour « non vérifiée ». Elle l'est désormais pour la **régression linéaire** : (6.9), p. 259, avec recentrage du vivier (algorithme 6.1, p. 262). `doc_tests_usp.tex:4508-4521` dérive pour le modèle de Mack le levier h_ij = C(i,j)/S_j de l'estimation pondérée de f̂_j, puis r̃(i,j) = r(i,j)/√(1 − h_ij) recentré : même construction que (6.9) et l'algorithme 6.1, **transposée** par le dépôt (l'ouvrage, dans les pages lues, ne traite pas le modèle de Mack). Le `.tex` ne cite pas Davison et Hinkley à cet endroit ; s'il le fait, le renvoi juste est « chap. 6, éq. (6.9), p. 259, et algorithme 6.1, p. 262 », en précisant l'analogie.

## R27.5 Efron et Tibshirani (1993), *An Introduction to the Bootstrap*, Chapman & Hall [V]

Notice lue sur Google Books et Internet Archive (Chapman & Hall, New York, 1993, ISBN 0-412-04231-2, xvi + 436 p.). Pages lues : chap. 13 « Confidence intervals based on bootstrap percentiles », p. 168-177 ; chap. 14, p. 185-186.

- **Intervalle de percentile** (§ 13.3, p. 170) : Ĝ fonction de répartition de θ̂\* ; « The 1 − 2α *percentile interval* is defined by the α and 1 − α percentiles of Ĝ » : **[θ̂_{%,lo}, θ̂_{%,up}] = [Ĝ⁻¹(α), Ĝ⁻¹(1 − α)] — éq. (13.3)** ; = [θ̂\*^{(α)}, θ̂\*^{(1−α)}] — éq. (13.4). À B fini, θ̂\*^{(α)}_B est « the B · α th value in the ordered list of the B replications » (convention de rang B·α, différente du (R + 1)α de Davison et Hinkley).
- **Lemme** (p. 173) : si φ̂ = m(θ̂) ~ N(φ, c²) — éq. (13.8) — pour une transformation m, l'intervalle de percentile vaut [m⁻¹(φ̂ − z^{(1−α)}c), m⁻¹(φ̂ − z^{(α)}c)] ; propriété de respect des transformations (§ 13.6, éq. (13.10)) et de respect du domaine (§ 13.7, p. 176).
- **Intervalle « basic »** (§ 13.4 « Is the percentile interval backwards? », p. 174) : bootstrap-t simplifié sur θ̂ − θ (dénominateur 1), « the resulting interval is » **[2θ̂ − Ĝ⁻¹(1 − α), 2θ̂ − Ĝ⁻¹(α)] — éq. (13.9)** (problème 13.5, p. 177 : inversion de Ĥ⁻¹(α) ≤ θ̂ − θ ≤ Ĥ⁻¹(1 − α), Ĥ loi de θ̂\* − θ̂, éq. (13.12)). L'ouvrage **ne le nomme pas** dans les pages lues ; les termes « basic » et « hybrid » n'y figurent pas [NV pour le nom]. « Neither of these intervals works well in general » ; « the quantity θ̂ − θ is far from pivotal so that the interval (13.9) is not very accurate » dans l'exemple du coefficient de corrélation.
- **Couverture à petit échantillon** (§ 13.5, tableau 13.3, p. 175) : θ = exp(μ), échantillon normal de taille 10, intervalle à 95 % ; percentile non paramétrique : 4,8 % de manques à gauche, 5,2 % à droite (cible 2,5 % chacun) ; normal standard : 1,2 % et 8,8 %. « like the standard interval it still undercovers overall » ; l'intervalle « underestimates the tails of the distribution of θ̂\* ». Incohérence interne relevée sur la page, sans conséquence ici : la légende du tableau dit « 300 confidence interval realizations », le texte « 500 simulated samples ». Pas de ligne pour l'intervalle (13.9) dans ce tableau.
- **Biais** (§ 13.8, p. 176) : si θ̂ ~ N(θ + bias, ŝe²) — éq. (13.11) — « no transformation φ = m(θ) can fix things up » ; le chap. 14 étend la méthode pour traiter « both bias and transformations ». BC_a (p. 185-186) : bornes θ̂\*^{(α₁)}, θ̂\*^{(α₂)} — éq. (14.9)-(14.10) — avec la correction de biais **ẑ₀ = Φ⁻¹(#{θ̂\*(b) < θ̂}/B) — éq. (14.14)**, « Roughly speaking, ẑ₀ measures the median bias of θ̂\* », et l'accélération â (14.15, par jackknife) ; â = ẑ₀ = 0 redonne l'intervalle de percentile (14.11).

**Confrontation au dépôt.** L'issue #305 (point 4) cite Efron et Tibshirani (1993) pour l'opposition percentile / « basic » : la formule (13.9), p. 174, est l'intervalle « basic » de Davison et Hinkley (5.6) à l'ordre des statistiques près ; l'appellation « basic » est celle de Davison et Hinkley (p. 194), pas d'Efron et Tibshirani. Pour D1-Fn : citer Davison et Hinkley (1997, § 5.2.1, éq. (5.6), p. 194) pour le nom et la formule, Efron et Tibshirani (1993, § 13.4, éq. (13.9), p. 174) pour la même borne et la discussion « backwards ». Le renvoi de `doc_tests_usp.tex:12299` (« percentiles » p. 166) porte sur un autre texte et n'est pas relu ici.

## R27.6 Ce qui reste non vérifié

- Davison et Hinkley : pages hors des plages ci-dessus, dont p. 197-198 (absentes de l'aperçu), § 2.4 et § 2.6.1 (renvoyés p. 194 et 211), § 5.7 (comparaisons empiriques), exemple 8.9 ; le § 4.2.4 n'a pas été lu à partir de son début (p. 150 non capturée), mais (4.15)-(4.17) et les exemples 4.6-4.8 l'ont été.
- Efron et Tibshirani : chap. 10 (biais), 12 (bootstrap-t), 22 (« Further topics in bootstrap confidence intervals », où le tableau 13.3 et p. 174 renvoient) : non lus [NV].
- Aucune des pages lues ne chiffre la couverture des intervalles « basic » ou de percentile à n = 8, ni pour le modèle lognormal du dépôt : tout chiffre à T = 8 devra venir d'une simulation propre au dépôt, présentée comme telle.

*Toutes les formules et citations de cette section ont été lues sur le rendu graphique des pages ; aucune n'est rapportée de mémoire.*
