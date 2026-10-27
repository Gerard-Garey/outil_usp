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

---

# Relevé du 27/10/2026, second passage

> *Rédigé par Claude (même session de relevé), le 27/10/2026, sur seconde commande de la session principale de Fn (décision du mainteneur du 27/10/2026). Points demandés : Andrews (2000), Cleveland (1979), Davison et Hinkley p. 197-198 et § 5.7, Efron et Tibshirani chap. 22 et 10. Confrontation à la spécification D1-Fn (`docs/specifications/fn-incertitude-bootstrap.md`, § 1.1, 4, 5 et 6) sur la tête `192a84d`. Mêmes règles qu'au premier passage : pages lues en rendu graphique, aucune copie tierce, aucun fichier source dans le dépôt.*

## S2.0 Tableau récapitulatif du second passage

| # | Affirmation | Lieu (tête `192a84d`) | Ce qui est vérifié | Statut |
|---|---|---|---|---|
| A1 | Andrews (2000), pagination | `doc_tests_usp.tex:13084` (« 399--406 ») ; spécification § 6 (« 399-405 ») | Crossref, page de l'Econometric Society, OpenAlex : **p. 399-405** | `.tex` **[X]** ; spécification **[V]** |
| A2 | Andrews : « percentile plus que nominal au bord », moyenne contrainte | spécification § 5.5 ; `doc_tests_usp.tex:13129-13131`, `:6370`, `:6931` | version de travail CFDP 1157 (1997), lue en entier ; texte publié non lu | [P] → **[P+]** : contenu lu sur la version de travail, avec une précision (S2.1) |
| C1 | Cleveland (1979), notice | `doc_tests_usp.tex:13641-13642` | Crossref : JASA 74(368), 829-836, déc. 1979 | **[V]** |
| C2 | `lowess` : f = 2/3, 3 itérations robustes, fenêtre | spécification § 1.1 et 1.4 ; `R/engine.R:7891` | documentation et code C de R (`stats/src/lowess.c`) ; article non lu | **[V]** pour R ; « round(f·n) » de la spécification **[X]** (code : `floor`) ; article [NV] |
| D1 | D-H p. 197-198 (exemple 5.1) | — | lues | [NV] → **[V]** |
| D2 | D-H § 5.7, couverture à petit n | — | p. 230-231, tableau 5.8 | [NV] → **[V]** |
| E1 | E-T chap. 22 | — | p. 321, 323-326 lues (p. 322 absente de l'aperçu) | [NV] → **[V]** pour ces pages |
| E2 | E-T chap. 10, estimation du biais | spécification § 5.2 | p. 124-125, éq. (10.1)-(10.4) | [NV] → **[V]** |

## S2.1 Andrews (2000)

### Sources

| Source | URL | Résultat |
|---|---|---|
| Wiley (éditeur) | `https://doi.org/10.1111/1468-0262.00114` → `https://onlinelibrary.wiley.com/doi/10.1111/1468-0262.00114` ; `…/doi/pdf/…` | HTTP 403 |
| Econometric Society | `https://www.econometricsociety.org/publications/econometrica/2000/03/01/inconsistency-bootstrap-when-parameter-boundary-parameter-space` | HTTP 200 : notice « ECONOMETRICA: MAR, 2000, VOLUME 68, ISSUE 2 », « p. 399-405 » ; texte et résumé derrière « Log In To View Full Content » |
| JSTOR | `https://www.jstor.org/stable/2999432` | HTTP 200, page anti-robot (« Oops, something went wrong »), rien de lisible |
| Crossref, OpenAlex | `https://api.crossref.org/works/10.1111/1468-0262.00114` ; `https://api.openalex.org/works/doi:10.1111/1468-0262.00114` | HTTP 200 : titre exact, vol. 68, n° 2, **p. 399-405**, mars 2000 ; aucun résumé ni texte libre |
| Cowles Foundation, Discussion Paper 1157 | `https://cowles.yale.edu/sites/default/files/2022-08/d1157.pdf` | HTTP 200, PDF de 9 pages, lu en entier en rendu graphique (pdftoppm, 140 dpi) |

**Nature de la source lue.** Le CFDP 1157 est une **version de travail** : « A Simple Counterexample to the Bootstrap », Donald W. K. Andrews, « June 1997, Revised: July 1997 » (couverture : « August 1997 »), 6 pages de texte. Son titre diffère du texte publié ; la couverture rappelle que les Discussion Papers sont « preliminary materials ». Tout ce qui suit vaut pour cette version, pas nécessairement pour le texte publié, que je n'ai pas lu. D'où le statut **[P+]** : le contenu est lu, mais pas dans sa version publiée.

### Pagination [V]

Trois sources indépendantes (Crossref, Econometric Society, OpenAlex) donnent **p. 399-405**. Le `.tex` (`doc_tests_usp.tex:13084`, fiche `fiche:ic-bootstrap`) écrit « p.~399--406 » : **[X]**, à corriger par `docwriter`. La spécification (§ 6) est juste.

### Contenu (version de travail)

- **Cadre (p. 1-2).** X_i i.i.d. N(μ, 1), espace des paramètres μ ≥ 0 ; estimateur du maximum de vraisemblance μ̂_n = max(X̄_n, 0). Éq. (1) : n^{1/2}(μ̂_n − μ) converge en loi vers Z si μ > 0, et vers max(Z, 0) si μ = 0. Pour μ = 0, le bootstrap non paramétrique de n^{1/2}(μ̂\*_n − μ̂_n) n'est pas convergent : « with probability one […] the bootstrap distribution is not consistent » (p. 2), et « the bootstrap distribution is too small (i.e., has too much mass to the left) when μ = 0 ».
- **Portée (p. 3).** « This counterexample to the bootstrap generalizes to a wide variety of estimation problems », par exemple les variances de coefficients aléatoires nulles. Le résultat général est renvoyé à Andrews (1997), « Estimation When a Parameter Is on a Boundary » (manuscrit), non démontré dans ce texte.
- **Intervalles (§ 3, p. 5-6).** **Deux** intervalles « percentile » sont étudiés pour **μ**, le paramètre contraint lui-même :
  - **CI₁ = [μ̂_n − t̂_{1α₁}/n^{1/2}, μ̂_n + t̂_{2α₂}/n^{1/2}]** (éq. (7)), où t̂_{1α₁} est le quantile (1 − α₁) et −t̂_{2α₂} le quantile α₂ de **n^{1/2}(μ̂\*_n − μ̂_n)**. Le texte le dit « what Hall (1992) refers to as the bootstrap percentile confidence interval ». **Par construction, c'est l'intervalle « basic » de Davison et Hinkley (éq. (5.6))** : borne inférieure 2μ̂_n − q\*_{1−α₁}, borne supérieure 2μ̂_n − q\*_{α₂}, q\* étant les quantiles de μ̂\*_n. Cette identification est de moi, déduite de l'éq. (7) ; le mot « basic » n'est pas dans le texte.
  - **CI₂ = [q\*_{α₁}, q\*_{1−α₂}]** (éq. (10)), quantiles de μ̂\*_n : l'intervalle de percentile d'Efron et Tibshirani (1993), « what Efron and Tibshirani (1993) refer to as the bootstrap percentile confidence interval ».
  - **Résultat, asymptotique, à μ = 0** : CI₁ « never misses to the left. If α₂ > 0, then its asymptotic coverage probability exceeds its nominal level 1 − α when μ = 0 » ; de même pour CI₂ : « If α₂ > 0, then the asymptotic coverage probability of CI₂ exceeds its nominal level 1 − α when μ = 0 » (p. 6). Le résumé (p. 1) : « they both have asymptotic coverage probability that exceeds the nominal asymptotic level when the true value of the mean μ equals zero ».
  - **Coquille relevée dans la version de travail, sans conséquence sur la conclusion** : l'éq. (9) écrit la probabilité de couverture de CI₁ comme convergeant vers α₁, et le texte dit ensuite que la couverture asymptotique de CI₂ « is α₁ » ; α₁ est en fait la probabilité limite de **non**-couverture (manque à droite seulement), la couverture tendant vers 1 − α₁ > 1 − α quand α₂ > 0, ce que dit la phrase de conclusion. À ne pas citer en chiffre sans le texte publié.
- **Alternatives (§ 2, p. 4-5)** : estimateur de la loi asymptotique avec seuil η_n, sous-échantillonnage (Wu, 1990 ; Politis et Romano, 1994), bootstrap « m sur n » (n₀ < n, n₀ → ∞, n₀(ln ln n)/n → 0, éq. (6)).

### Confrontation à la spécification D1-Fn et au `.tex`

- Spécification § 5.5 : « la nuance "percentile plus que nominal au bord" […] comme portant sur la moyenne contrainte de son exemple ». **Conforme**, avec deux précisions :
  1. Le résultat porte sur **les deux** intervalles, et le premier (CI₁, « percentile » au sens de Hall) est **l'intervalle « basic »** de D-H (5.6). La spécification ne le rattache qu'au percentile ; il vaut aussi pour l'intervalle « basic » de S-Fn-4 (§ 4), dans le cadre d'Andrews.
  2. Le résultat est **asymptotique** (n → ∞), pour μ = 0 exactement, avec α₂ > 0, dans le modèle N(μ, 1) à variance connue et bootstrap non paramétrique. Il ne donne aucun chiffre à n fini, ni à T = 8.
- Spécification § 5.5, « elle ne se transpose pas à σ, dont δ n'est qu'un paramètre de nuisance » : c'est un raisonnement de la spécification, que le texte lu ne confirme ni n'infirme (il ne traite pas d'un paramètre d'intérêt distinct du paramètre au bord). Aucune contradiction.
- `doc_tests_usp.tex:13129-13131` (« Andrews (2000) montre que le bootstrap de l'estimateur sous contrainte n'est pas convergent lorsque le vrai paramètre est sur la frontière ») : conforme au contenu de la version de travail, pour l'exemple et sa généralisation annoncée [P+].

## S2.2 Cleveland (1979) et `lowess`

### Sources

| Source | URL | Résultat |
|---|---|---|
| Taylor & Francis | `https://www.tandfonline.com/doi/abs/10.1080/01621459.1979.10481038` ; `…/doi/pdf/…` | HTTP 403 |
| JSTOR | `https://www.jstor.org/stable/2286407` | HTTP 200, page anti-robot, rien de lisible |
| Page de l'auteur (Purdue) | `https://www.stat.purdue.edu/~wsc/` | échec TLS par curl (« unable to get local issuer certificate ») ; HTTP 502 par Chromium (« upstream request failed ») |
| Crossref, OpenAlex | `https://api.crossref.org/works/10.1080/01621459.1979.10481038` ; `https://api.openalex.org/works/doi:10.1080/01621459.1979.10481038` | HTTP 200 : notice ; résumé de l'éditeur (OpenAlex) |
| R 4.3.3, documentation de `lowess` | `tools::Rd_db("stats")[["lowess.Rd"]]` | lue |
| Code C de R | `https://raw.githubusercontent.com/wch/r-source/trunk/src/library/stats/src/lowess.c` (miroir du dépôt R, branche de développement) | HTTP 200, lu |

### Constat

- **Notice [V]** : Cleveland, W. S., « Robust Locally Weighted Regression and Smoothing Scatterplots », *JASA* 74(368), 829-836, décembre 1979 (Crossref). Celle du `.tex` (`doc_tests_usp.tex:13641-13642`) est **exacte**.
- **Résumé de l'éditeur [P]** (relayé par OpenAlex, texte) : la valeur lissée en x_k est « the value of a polynomial fit to the data using weighted least squares, where the weight for (x_i, y_i) is large if x_i is close to x_k and small if it is not. A robust fitting procedure is used that guards against deviant points ». **L'article lui-même n'est pas lu [NV]** : ni la définition de f dans le texte, ni le nombre d'itérations qu'il recommande.
- **Implémentation de R [V]** (documentation et code, R 4.3.3) : `lowess(x, y, f = 2/3, iter = 3, delta = 0.01 * diff(range(x)))` ; f « gives the proportion of points in the plot which influence the smooth at each value » ; voisinage défini par le « floor(f*n)th nearest neighbour », poids tricubes ; itérations robustes : poids biweight de Tukey, coupure à « 6 times the MAD of the residuals » (code : `cmad = 6 * median(|résidus|)`, `lowess.c:247-258`) ; arrêt si cette MAD est quasi nulle. Code : **`ns = imax2(2, imin2(n, (int)(f*n + 1e-7)))`** (`lowess.c:150`), soit la partie entière de f·n, bornée à [2, n].

### Confrontation à la spécification D1-Fn

- Spécification § 1.1 : « À T = 8, `lowess` avec f = 2/3 lisse sur 5 points (fenêtre `round(f·n)`) avec 3 itérations robustes ». **Écart d'écriture [X], sans effet à T = 8** : le code de R prend la partie entière (`floor`), pas l'arrondi. À n = 8, f·n = 5,33, et les deux donnent 5 ; ils diffèrent dès que la partie fractionnaire de f·n dépasse 0,5 (par exemple n = 10 : floor 6, round 7). Correction proposée : « fenêtre ⌊f·n⌋ (`lowess.c:150`) ».
- « 3 itérations robustes », « f = 2/3 » : **[V]** comme valeurs par défaut de R ; leur origine dans Cleveland (1979) reste **[NV]**.

## S2.3 Davison et Hinkley (1997), compléments [V]

Pages lues sur l'aperçu Google Books (`https://books.google.com/books?id=4aCDbm_t8jUC&pg=PA197`, `…PA230`, `…PA232`, `…PA234`), HTTP 200. Les p. 197-198, absentes à la première lecture, sont servies cette fois.

### Exemple 5.1, p. 197-198 (bootstrap **paramétrique**, n = 12)

Données de climatisation, modèle exponentiel, intervalle à 95 % pour la moyenne μ, solution exacte connue (bornes 65,9 et 209,2) :
- approximation normale (5.4) : 46,9 et 169,2 ; sur l'échelle logarithmique (5.9) : 61,4 et 190,3 ;
- **intervalle « basic » (5.6)**, R = 999 simulations sous le modèle exponentiel ajusté, statistiques d'ordre 25 et 975 : 39,8 et 162,9, « These are no better than the normal approximation limits » ;
- **intervalle « basic » sur l'échelle logarithmique (5.10)** : 66,2 et 218,8, « much better results » ; « In fact these are simulation approximations to the exact limits, which are based on the exact gamma distribution of Ȳ/μ » ;
- R = 99 imposerait une interpolation (5.8), car (99 + 1) × 0,025 = 2,5, « This involves quite extreme ordered values and so is somewhat unstable ».
- Coquille relevée, sans conséquence : la statistique d'ordre basse vaut 53,3 p. 197 et 53,4 p. 198.

Intérêt pour Fn : le seul exemple **paramétrique** lu où l'intervalle « basic » est comparé à une solution exacte ; sur l'échelle logarithmique, il retrouve la solution exacte parce que Ȳ/μ est un pivot exact du modèle. C'est l'argument de la variante I4 (échelle transformée) de la spécification § 4, que l'ouvrage illustre sans la démontrer pour d'autres modèles.

### § 5.7, p. 230-231 : comparaison empirique (bootstrap **non paramétrique**)

- Plan : rapport de moyennes θ = μ₁/μ₂ = 2 de deux échantillons gamma (μ₁ = 100, indice 0,7 ; μ₂ = 50, indice 1), estimé par ȳ₁/ȳ₂ ; 10 000 jeux simulés, R = 999 ; **n₁ = n₂ = 10** et n₁ = n₂ = 25 ; taux d'erreur à gauche et à droite.
- **Tableau 5.8**, taux d'erreur en %, **n₁ = n₂ = 10**, taux nominal 5 % de chaque côté (borne inférieure ; borne supérieure) :

| Méthode | borne inférieure (5 %) | borne supérieure (5 %) |
|---|---|---|
| Exacte | 5,5 | 4,8 |
| Approximation normale | 1,7 | 15,7 |
| **Basic** | **0,2** | **21,0** |
| Basic, échelle log | 8,1 | 7,5 |
| Studentisée | 4,6 | 6,7 |
| Studentisée, échelle log | 5,6 | 6,3 |
| **Percentile** | **6,5** | **8,9** |
| BC_a | 6,9 | 8,3 |
| ABC | 7,4 | 8,7 |

  Lus sur l'image. Mon arithmétique, non écrite dans l'ouvrage : pour un intervalle bilatéral à 90 %, la non-couverture totale est d'environ 21,2 % pour « basic » et 15,4 % pour le percentile (n = 10). L'ouvrage indique des erreurs standard de simulation « rates divided by 100 ».
- Conclusion de l'ouvrage (p. 231) : « the studentized method gives the best results, provided the log scale is used. Otherwise, the studentized method and the percentile, BC_a and ABC methods are comparable but only really satisfactory at the larger sample sizes » ; « the normal, percentile, BC_a and ABC intervals are short compared to the exact ones, and that taking logs improves the basic intervals ».
- **Portée** : bootstrap non paramétrique, autre modèle, n = 10 par échantillon. Ce n'est pas le plan du dépôt (bootstrap paramétrique réajusté, T = 8) ; aucun chiffre n'est transposable. Ce sont les seuls chiffres de couverture à n ≤ 10 trouvés pour « basic » et percentile côte à côte.

## S2.4 Efron et Tibshirani (1993), compléments [V]

Pages lues sur l'aperçu Google Books (`https://books.google.com/books?id=gLlpIUxRntoC&pg=PA321`, `…PA323`, `…PA325`, `…PA327`, `…PA124`), HTTP 200 ; p. 322 absente de l'aperçu.

### Chap. 22, « Further topics in bootstrap confidence intervals » (p. 321-326)

- § 22.2 (p. 321) : précision au premier ordre, Prob(θ ≤ θ̂[α]) = α + O(n^{−1/2}), éq. (22.2) ; au second ordre, α + O(n⁻¹), éq. (22.3).
- § 22.3 (p. 323) : P = √n(θ̂ − θ), P̂ = √n(θ̂\* − θ̂) (éq. (22.8)) ; point « un-Studentized » estimé **θ̂_UNS[α] = θ̂ − n^{−1/2} x̂^{(1−α)}** (éq. (22.12)), x̂ quantile de P̂. C'est **la borne de l'intervalle « basic »** (même construction que (13.9) et D-H (5.6) ; rapprochement de moi).
- P. 324 : « The confidence point θ̂_UNS based on P is only first [order] accurate », éq. (22.14) ; « in order for the bootstrap to improve upon the standard normal procedure it should be based on a studentized quantity, at least when it is used in this simple way ». P. 325, éq. (22.18) : var(P̂) = var(P) + O(n^{−1/2}), cause de cette précision du premier ordre seulement.
- § 22.4 (p. 325) : BC_a précis au second ordre (22.20) et égal au bootstrap-t à O_p(n^{−3/2}) près (22.21), démonstrations renvoyées à Hall (1988a). § 22.5 (p. 326) : le percentile généralise (22.23) par une transformation m(·) ; BC_a ajoute z₀ (« accounts for possible bias in φ̂ ») et a, « both of which are O_p(n^{−1/2}) ».
- **Aucun tableau de couverture à petit n dans les pages lues du chap. 22** ; la suite du chapitre (p. 327 et au-delà, ABC) n'est pas relevée.

### Chap. 10, « Estimates of bias » (p. 124-125)

- Biais : bias_F = E_F[s(x)] − t(F), éq. (10.1) ; estimation bootstrap bias_F̂ = E_F̂[s(x\*)] − t(F̂), éq. (10.2) ; à B fini, **bias^_B = θ̂\*(·) − t(F̂)**, θ̂\*(·) = Σ θ̂\*(b)/B, éq. (10.3)-(10.4).
- P. 124 : « One can use an estimate of bias to bias-correct an estimator. However this can be a dangerous practice, as discussed near the end of the chapter » (fin de chapitre non lue).

**Confrontation à la spécification D1-Fn § 5.2** (« l'écart moyenne(σ\*) − σ̂ est l'estimation bootstrap du biais de σ̂ ») : **conforme** à (10.4), avec θ̂ = t(F̂) = σ̂ et le bootstrap paramétrique à la place de F̂. L'ouvrage pose (10.2)-(10.4) dans le cadre non paramétrique, mais la définition ne dépend que de la loi de rééchantillonnage. La mise en garde de la p. 124 contre une correction de biais appuie le choix de la spécification (§ 5.3) de ne pas présenter √(9/7) comme une correction de biais.

## S2.5 Ce qui reste non vérifié

- Andrews (2000) : texte **publié** et résumé publié (Wiley 403, JSTOR anti-robot, Econometric Society réservée aux membres) ; le contenu ci-dessus vient de la version de travail.
- Cleveland (1979) : texte de l'article (Taylor & Francis 403, JSTOR anti-robot, page de l'auteur inaccessible).
- Efron et Tibshirani : p. 322, fin du chap. 10 (« dangerous practice »), p. 327 et suivantes du chap. 22.
- Aucune source lue ne chiffre la couverture à **n = 8**, ni pour un bootstrap **paramétrique** d'un modèle lognormal : le seul chiffre à n ≤ 10 pour « basic » et percentile côte à côte (D-H tableau 5.8, n = 10) porte sur un bootstrap non paramétrique d'un rapport de moyennes gamma.

*Formules et citations lues sur le rendu graphique des pages (Google Books, PDF de la Cowles Foundation) ; pour Cleveland et `lowess`, seuls la notice, le résumé de l'éditeur, la documentation et le code de R ont été lus, ce que disent les statuts.*
