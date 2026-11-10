<!-- Rapport d'`actuary` (fiche de base, Opus 5.5), validation de fond de fin de branche (étape 10), sur la tête `91b16a4`, 10/11/2026. Texte intégral rendu par l'agent. -->

> *Rédigé par l'agent actuary (IA).* Visa de fond de fin de branche K5 (`claude/application`, PR #516, tête 91b16a4), règle 9. Rapport à verser intégralement dans `docs/revues/20261110-fin-de-branche-k5/`.

# Verdict global : **validé avec réserves**

Deux réserves majeures (R1 et R2) et deux mineures (R3 et R4). Aucune n'est bloquante, et aucune ne touche σ_USP, une p-value, un verdict ou une référence. R1 et R2 sont à corriger avant la sortie du brouillon, par un commit `docs:` de `docwriter` (Refs #524). Je revois ensuite ce diff seul.

## 0. Préalable : base de comparaison

Le `main` local est périmé (d783fe4). Avec lui, `git diff main...HEAD -- docs/latex/doc_tests_usp.tex` mélange des commits déjà fusionnés : 2 323 lignes, 18 commits. Avec `origin/main` (04f6922, après la fusion de #511), le diff du `.tex` ne contient que les quatre commits de `docwriter` : f6b4ac6, 9459573, c6ee5b5, 75c9c01. Le visa porte sur ce diff-là. La session doit faire `git fetch` avant toute revue finale (règle 10).

## 1. Diff du `.tex`

| Commit | Objet | Verdict |
|---|---|---|
| f6b4ac6 (#498) | index (`engine_regle_verdicts()`), sec:nature | **visa** |
| 9459573 (#499) | repères T < 10 et I + 1 < 10, sec:controles | **visa** |
| c6ee5b5 (#518) | `$avertissements_lecture`, lecture CSV | **visa** (technique, pas de fond statistique) |
| 75c9c01 (#524) | sec:notations, tableau des résidus, sec:base-residus, sec:h3, `\versiondoc` 3.2 | **visa avec réserves** R1, R2, R3 |

**f6b4ac6.** La règle énoncée en sec:nature est identique au code d'`add()` dans les deux sens. Sens « ne pas rejeter » : ECHEC si p < α/2, ALERTE si α/2 ≤ p < α. Sens « rejeter » : OK si p < α, ALERTE si α ≤ p < 0,30, ECHEC au-delà. La ligne d'index décrit fidèlement `R/engine.R` l. 12954-12985 : `character(4)`, virgule décimale, seuil lu dans `SEUIL_ECHEC_SENS_REJETER`, erreur R hors de ]0, seuil[, aucun champ de `usp_engine`. L'emplacement annoncé est vérifié : `html_regle_verdicts()`, `R/display_helpers.R` l. 400 et 3280-3282 (section « 5. Tests retenus »), `app.R` l. 1541.

**9459573.** La paraphrase reprend exactement les chaînes du moteur : `R/engine.R` l. 8093-8096 (lognormal) et l. 9184-9186 (Merz-Wüthrich). Le repère reste qualifié de convention non réglementaire et sans source, ce qui est exact. À T = 8, la phrase de non-rejet est justifiée par la faible puissance des tests documentée ailleurs dans le `.tex`.

**c6ee5b5.** Conforme à `engine_lire_triangle()` (`R/engine.R` l. 7569-7628) :
- le champ est vide pour un refus ;
- sinon il vaut `.mw_avert_sous_diagonale(m)` ;
- la validation est appelée sans segment ni annexe.

**75c9c01.** J'ai vérifié les calculs.
- μ_t = ln(βx_t) − ψ_t/2 redonne E[Y_t | x_t] = βx_t.
- La variance du ratio vaut σ²[(1−δ)x̄x_t + δx_t²]/x_t² = σ²[δ + (1−δ)x̄/x_t] = β²(e^{1/π_t} − 1), puisque σ = βe^γ.
- La preuve par translation est correcte, réciproque comprise.
- La condition « π_t constant ⇔ δ = 1 ou x_t tous égaux » est exacte (pour δ < 1, π_t ne dépend de t que par x̄/x_t).
- Le tableau des résidus (l. 3469) et la ligne H3 de sec:base-residus (l. 8561-8563) sont désormais exacts et cohérents avec sec:base-residus.

Restent R1, R2 et R3 ci-dessous.

## 2. Textes de fond

- **#509 (c5f54a1) : visa.** Le `ref` de F. et de M4 vaut « hors hypothèses de l'annexe XVII », et G., M6 et LC sont inchangés, conformément à l'avis amont. Sur le fond, la stabilité et les points aberrants ne figurent pas parmi les hypothèses i. à iv. de B(2)(g), C(2)(e) et D(2)(h). Le `.tex` ne citait pas l'ancien libellé (vérifié par grep). Observation non retenue comme réserve : pour F., le `sous` (« hors hypothèses réglementaires, mais conditionne leur lecture ») et le `ref` se recoupent. C'est sans inexactitude.
- **#498 (4f11194) : visa.** Les quatre phrases d'`engine_regle_verdicts()` sont, mot pour mot, celles de `docs/revues/20261110-avis-amont-k5/actuary-avis-amont.md` § « #498 », phrases 1 à 4, avec les arguments injectés dans le bon ordre : (α), (α, α, seuil, seuil), (α/2, α/2, α, α).
- **#499 (1b2f412) : visa.** Les chaînes d'`engine_valider_donnees()` et de `mw_valider_triangle()` sont identiques à celles de l'avis amont. La phrase est ajoutée aux deux repères, comme l'a décidé le mainteneur le 10/11.
- **#524, 2a3c239 (`CONTEXT.md`) : visa avec réserve mineure R4.** Le fond est juste. Il manque le conditionnement dans les formules de moments, et « volumes constants » est un prédicat à tolérance alors que la propriété porte sur les paramètres vrais (voir 3a).
- **#524, 2cea835 (« résidus standardisés ») : visa.** Quatre occurrences dans `app.R` et `R/display_helpers.R`. Le terme est celui de `CONTEXT.md` et du `.tex`.

## 3. Points signalés par `docwriter`

### a. « x_t tous égaux » ou « volumes constants »

**Avis : garder « x_t tous égaux » dans sec:notations.** C'est la bonne condition, nécessaire et suffisante. Avec π_t = [ln(1 + e^{2γ}(δ + (1−δ)x̄/x_t))]^{-1}, π_t est constant si et seulement si δ = 1 ou x̄/x_t ne dépend pas de t, c'est-à-dire si les x_t sont égaux. Sous cette condition, les ln r_t sont i.i.d. N(ln β − 1/(2π), 1/π) sachant les x_t ; sinon leurs variances diffèrent. La proposition porte sur le modèle aux paramètres vrais et doit donc employer l'égalité exacte.

« Volumes constants » est, dans `CONTEXT.md`, le prédicat `usp_volumes_constants()` : `diff(range(x)) <= TOL_DELTA_BORD * mean(x)`, `R/engine.R` l. 1956-1957. Avec δ̂ = 1, il fonde le régime estimé `pi_constant` (l. 2018). C'est le pendant opérationnel, et non la condition elle-même. L'avis Fable (π_t constant) est rejoint. R3 et R4 explicitent la distinction, ce qui suppose déjà admis que le régime est estimé sur les mêmes données (point traité ailleurs dans le `.tex`, sec:nature, l. 6519-6524).

### b. Paragraphe « Résidus » de sec:notations : **à corriger (R1, majeur)**

« approximativement indépendants et de loi N(0,1) » est faux à T = 8 et contredit le tableau de la l. 3469 corrigé par le même commit, sec:base-residus (l. 8378-8382) et le nouvel encadré H3. Dans le cadre de sec:base-residus (π̂_t tenu pour connu), z ~ N(0, P) avec P = I − √π√π′/Σπ, de rang T − 1. Les corrélations sont toutes négatives, −√(π_sπ_t)/Σπ. Elles ne sont pas négligeables : à π̂_t constant et T = 8, variance 7/8 et corrélation −1/7.

Mesure : `Rscript -e '...'` donne `0.875 -0.1428571` ; avec π = 1..8, la corrélation maximale est −0,039 et le rang 7.

Cette phrase tombe aussi sous le critère d'acceptation de #524 (« plus aucune occurrence de "i.i.d. N(0,1)" comme loi de z_t »). Elle n'est pas bloquante, puisque le code teste déjà z_t par Monte-Carlo sous le modèle ajusté et qu'aucun résultat n'est en cause. Elle est majeure : c'est la définition de référence des résidus dans un dossier ACPR.

### c. Encadré de H3 : relecture de `regulatory`

**Avis : utile, non bloquante.** La citation réglementaire est inchangée ; seule la « traduction dans le modèle réglementaire » change. Deux points relèvent bien de `regulatory` :
1. le texte dit « les pertes agrégées suivent une distribution log-normale », sans conditionnement : la lecture « sachant x_t » est un choix de l'outil, à confirmer comme lecture admissible ;
2. ce que H3 pose seule, par rapport à H1 et H2.

Sur ce second point, la rédaction actuelle a un défaut de fond (R2). Si `regulatory` voit deux lectures possibles de « suivent une distribution log-normale » (marginale ou conditionnelle), le mainteneur tranche.

## 4. Réserves et textes de remplacement

Tous les textes portent sur `docs/latex/doc_tests_usp.tex`, sauf R4. Les lignes sont celles de la tête 91b16a4.

### R1 : majeur (point 3b), l. 3210-3211

Ancien :
```
qui, si le modèle est correctement spécifié, sont \emph{approximativement} indépendants et de loi
$\mathcal{N}(0,1)$. On note
```
Nouveau :
```
qui, si le modèle est correctement spécifié et les $\hat\pi_t$ tenus pour connus, suivent la loi
$\mathcal{N}(0, P)$, $P$ projecteur de rang $T-1$ (section~\ref{sec:base-residus}), et non
$\mathcal{N}(0, I_T)$~: ils sont centrés, de variances $1 - \hat\pi_t/\sum_s \hat\pi_s$ et
corrélés négativement deux à deux~; à $\hat\pi_t$ constant et $T = 8$, chaque variance vaut $7/8$
et chaque corrélation $-1/7$. Ce calcul ne rend pas compte de ce que $\hat\delta$ et $\hat\gamma$
sont estimés sur les mêmes données. On note
```

### R2 : majeur (point 3c), encadré de sec:h3, l. 10509-10517

Le défaut : la première phrase donne à H3 les paramètres (μ_t, ψ_t), donc l'espérance et la variance de H1 et H2. La phrase suivante (« Avec l'espérance et la variance du modèle… ») devient alors redondante. Surtout, la conclusion (« un rejet peut venir de H1 ou de H2 même quand la loi de y_t est lognormale ») n'a de sens que si H3 seule est « y_t lognormal » sans paramètres imposés. L'indépendance des années, qui entre dans l'équivalence avec les ε_t, manque aussi parmi les causes possibles d'un rejet.

Ancien (depuis « l'hypothèse s'énonce sous » jusqu'à « est lognormale. ») :
```
l'hypothèse s'énonce sous
deux formes équivalentes à $x_t$ connu, $y_t$ lognormal de paramètres $(\mu_t, \psi_t)$, ou
$\ln r_t$ normal d'espérance $\ln\beta - 1/(2\pi_t)$ et de variance $1/\pi_t$, propres à l'année.
Avec l'espérance et la variance du modèle et l'indépendance des années, elle équivaut à
$\varepsilon_t = \sqrt{\pi_t}\,\big(\ln r_t - \ln\beta + 1/(2\pi_t)\big)$ i.i.d.
$\mathcal{N}(0,1)$ aux paramètres vrais~; cette équivalence est exacte pour les $\varepsilon_t$,
non observés. L'outil teste la normalité des résidus standardisés $z_t$, qui les remplacent aux
paramètres estimés (section~\ref{sec:base-residus})~: un rejet sur les $z_t$ peut aussi venir
d'un écart à H1 ou à H2, qui déforme les $z_t$ même quand la loi de $y_t$ est lognormale.
```
Nouveau :
```
à $x_t$ connu,
l'hypothèse s'énonce sous deux formes équivalentes, $y_t$ lognormal ou $\ln r_t$ normal, l'une
se déduisant de l'autre par la translation de $\ln y_t$ par $\ln x_t$. Avec l'espérance et la
variance du modèle (H1 et H2), les paramètres sont $(\mu_t, \psi_t)$ pour $y_t$, soit, pour
$\ln r_t$, l'espérance $\ln\beta - 1/(2\pi_t)$ et la variance $1/\pi_t$, propres à l'année~; avec
de plus l'indépendance des années, l'ensemble équivaut à
$\varepsilon_t = \sqrt{\pi_t}\,\big(\ln r_t - \ln\beta + 1/(2\pi_t)\big)$ i.i.d.
$\mathcal{N}(0,1)$ aux paramètres vrais~; cette équivalence est exacte pour les $\varepsilon_t$,
non observés. L'outil teste la normalité des résidus standardisés $z_t$, qui les remplacent aux
paramètres estimés (section~\ref{sec:base-residus})~: un rejet sur les $z_t$ peut aussi venir
d'un écart à H1, à H2 ou à l'indépendance des années, qui déforme la loi des $z_t$ même quand
chaque $y_t$ suit une loi lognormale.
```

### R3 : mineur (point 3a), sec:notations, l. 3197-3199

Ancien :
```
Les ratios sont indépendants et de même
espérance~$\beta$, mais ne sont identiquement distribués que si $\pi_t$ est constant, soit
$\delta = 1$, soit des $x_t$ tous égaux~:
```
Nouveau :
```
Sachant les $x_t$, les ratios sont indépendants et de
même espérance~$\beta$, mais ne sont identiquement distribués que si $\pi_t$ est constant, soit
$\delta = 1$, soit des $x_t$ tous égaux (condition sur les paramètres vrais~; son pendant estimé
est le régime $\hat\pi_t$ constant, $\hat\delta$ au bord~1 ou volumes constants au sens de
\code{usp\_volumes\_constants()}, section~\ref{sec:base-residus})~:
```
Après ce changement, lancer `concordance_doc_moteur.R --strict` ; `usp_volumes_constants()` est déjà cité dans le `.tex` (l. ~4049).

### R4 : mineur, `CONTEXT.md` l. 8, entrée « Modèle réglementaire »

`CONTEXT.md` n'est pas écrit par `docwriter` : la session décide qui l'applique. Trois remplacements dans la ligne :
- « E[Y_t] = β x_t et Var(Y_t) = σ²[(1 − δ) x̄ x_t + δ x_t²] » → « E[Y_t | x_t] = β x_t et Var(Y_t | x_t) = σ²[(1 − δ) x̄ x_t + δ x_t²], les Y_t indépendants conditionnellement aux x_t » ;
- « les ratios sont indépendants, de même espérance β » → « les ratios sont, sachant les x_t, indépendants, de même espérance β » ;
- « (δ = 1 ou volumes constants) (#524) » → « (δ = 1 ou x_t tous égaux ; pendant estimé : régime π̂_t constant, δ̂ = 1 ou volumes constants) (#524) ».

Observation sans réserve : dans sec:notations, x̄ dans Var(Y_t | x_t) fait dépendre la loi de tous les volumes. « Sachant x_t » se lit volumes connus, ce qui est la convention constante du document. Aucun changement demandé.

## Retour

- **Statut** : `complet`.
- **Résultat** : visa avec réserves. f6b4ac6, 9459573 et c6ee5b5 : visa. 75c9c01 : réserves R1 et R2 (majeures), R3 (mineure). #509, #498, #499 et 2cea835 : visa. 2a3c239 : réserve R4 (mineure). Point 3a : « x_t tous égaux », condition exacte et nécessaire et suffisante. Point 3b : correction requise (R1). Point 3c : relecture `regulatory` utile, non bloquante ; points 1 et 2 du § 3c.
- **Preuves vérifiées** :
  - `git show` des quatre commits `docwriter`, de c5f54a1, 2a3c239 et 2cea835 ;
  - `git log origin/main..HEAD -- docs/latex/doc_tests_usp.tex`, qui donne quatre commits ;
  - code lu : `R/engine.R` l. 1956-1957, 2018, 7565-7628, 8093-8097, 9184-9187, 12938-12985 ; `R/display_helpers.R` l. 400-404 et 3272-3282 ; `app.R` l. 1541 ;
  - texte de référence de l'avis amont, `docs/revues/20261110-avis-amont-k5/actuary-avis-amont.md` ;
  - corps de #524 (outil GitHub) ;
  - mesure R de P à T = 8 : variance 0,875, corrélation −0,1428571 ; avec π variable, corrélation maximale −0,039 et rang 7 ;
  - calculs de μ_t, de la variance du ratio et de la condition π_t constant, refaits à la main (ci-dessus).
- **Hypothèses** : les textes de l'avis amont versés par la session sont fidèles au rapport d'origine. Le fichier le dit lui-même : la seule trace est le handoff 6752459057.
- **Non vérifié** : compilation du PDF et `concordance --strict` après R1 à R3 (à faire par `compiler-doc`) ; l'intégralité des commentaires de #524, au-delà du corps de l'issue.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : la lecture « conditionnellement aux x_t » de B(2)(g)(iii) et C(2)(e)(iii) relève de `regulatory`, puis du mainteneur s'il y a deux lectures. L'agent qui applique R4 à `CONTEXT.md` est à désigner par la session.
- **Critères déclenchés** : deux lectures possibles d'une source (lecture marginale ou conditionnelle de « suivent une distribution log-normale »), à décrire par `regulatory` ; ce n'est pas un problème de documentation disponible. Aucun changement de résultat. Aucun désaccord avec `audit`, avec l'avis Fable sur #524 (rejoint sur π_t constant) ni avec un ADR.
- **Prochaine action recommandée** :
  1. `docwriter` applique R1, R2 et R3 dans un commit `docs:` (Refs #524), puis `compiler-doc` et `concordance --strict` ;
  2. R4 est appliquée dans `CONTEXT.md` ;
  3. je revois ce diff seul ;
  4. revue finale (règle 10) sur `git diff origin/main...HEAD`, après `git fetch`.
